-- Cerinta 14

-- Un pachet ce contine functiile necesare pentru a scrie continutul unui tabel intr-un fisier

create or replace package wfile
is
    procedure write_to_file(
        nume_tabel      user_tables.table_name%type,
        nume_fisier     varchar2
    );
    
    procedure check_table_exists(
        nume_tabel  user_tables.table_name%type
    );
end wfile;
/

create or replace package body wfile
is
    procedure check_table_exists(
        nume_tabel   user_tables.table_name%type
    )
    is
        cnt integer;
    begin
        select count(*) into cnt
        from user_tables
        where lower(table_name) = lower(nume_tabel);
        
        if (cnt = 0) then
            raise_application_error(-20050, 'Nu exista acest tabel in user space');
        end if;
        return;
    end check_table_exists;
    
    procedure write_to_file(
        nume_tabel      user_tables.table_name%type,
        nume_fisier     varchar2)
    is
        fisier          utl_file.file_type;
        p_sql_query     varchar2(300):='select * from ';
        l_cursor_handle integer;
        l_dummy         number;
        l_rec_tab       dbms_sql.desc_tab;
        l_col_cnt       integer;
        l_current_line  varchar(2047);
        l_current_col   number(16);
        l_record_count  number(16):=0;
        l_column_value  varchar2(300);
        l_print_text    varchar2(300);
    begin
        check_table_exists(nume_tabel);
    
        p_sql_query := p_sql_query || nume_tabel;
        -- deschide fisierul pentru write
        -- LOGS reprezinta un directory creat din sql, ce are incorporata si adresa pe disk unde se va scrie fisierul
        -- pentru a scrie in alta locatie, trebuie sa declaram acel directory, si sa acordam drepturi de read-write
        -- utilizatorului pentru acel fisier
        fisier := utl_file.fopen('LOGS', nume_fisier, 'w', 2047);
        
        -- deschide un cursor cu selectul din audit_user
        l_cursor_handle := dbms_sql.open_cursor;
        dbms_sql.parse(l_cursor_handle, p_sql_query, dbms_sql.native);
        l_dummy := dbms_sql.execute(l_cursor_handle);
        
        -- afla numele coloanelor
        dbms_sql.describe_columns(l_cursor_handle, l_col_cnt, l_rec_tab);
        
        -- append to file column headers
        l_current_col := l_rec_tab.first;
        if (l_current_col is not null) then
            loop
                dbms_sql.define_column(l_cursor_handle, l_current_col, l_column_value, 300);
                l_print_text := l_rec_tab(l_current_col).col_name || ' ';
                utl_file.put(fisier, l_print_text);
                l_current_col := l_rec_tab.next(l_current_col);
                exit when (l_current_col is null);
            end loop;
        end if;
        utl_file.put_line(fisier, ' ');
        
        -- append data for each row
        loop
            exit when dbms_sql.fetch_rows(l_cursor_handle) = 0;
            
            l_current_line := '';
            for l_current_col in 1..l_col_cnt loop
                dbms_sql.column_value(l_cursor_handle, l_current_col, l_column_value);
                l_print_text := l_column_value;
                
                l_current_line := l_current_line || l_column_value || ' ';
            end loop;
            
            l_record_count := l_record_count + 1;
            utl_file.put_line(fisier, l_current_line);
        end loop;
        
        utl_file.fclose(fisier);
        dbms_sql.close_cursor(l_cursor_handle);
        
    exception
        when others then
            -- eliberam resursele de sistem
            if dbms_sql.is_open(l_cursor_handle) then
                dbms_sql.close_cursor(l_cursor_handle);
            end if;
            
            if utl_file.is_open(fisier) then
                utl_file.fclose(fisier);
            end if;
            
            dbms_output.put_line(dbms_utility.format_error_stack);
    end write_to_file;
    
end wfile;
/


Execute wfile.write_to_file('audit_user', 'test.txt');