-- Cerinta 12

-- Vom face un sistem de log-uri pentru baza noastra de date
-- pentru aceasta vom avea nevoie de mai multe privilegii de trebuie acordate
-- de administratorul bazei de date utilizatorului nostru.

-- grant execute on utl_file to constantin;
-- permite folosirea pachetului utl_file, ce are definite functii de IO cu fisier

-- grant execute on dbms_sql to constantin;
-- permite folosirea pachetului dbms_sql, pentru a putea deschide cursori in
-- modul necesar noua

-- create directory logs as 'E:\OracleLogs';
-- creaza folder-ul unde vor fi scrise log-urile;

-- grant read, write on directory logs to constantin;
-- da privilegiile necesare pentru a putea face operatii de IO in acel directory

set serveroutput on;
/

create table audit_user(
    nume_bd             varchar2(50),
    user_logat          varchar2(30),
    eveniment           varchar2(100),
    tip_obiect_referit  varchar2(100),
    nume_obiect_referit varchar2(100),
    data                timestamp(3),
    nr_tabele           integer,
    nr_triggere         integer
);
/
create or replace trigger audit_schema
after create or drop or alter on schema
begin
    insert into audit_user values(
        sys.database_name,
        sys.login_user,
        sys.sysevent,
        sys.dictionary_obj_type,
        sys.dictionary_obj_name,
        systimestamp(3),
        (select count(*) from user_tables),
        (select count(*) from user_triggers)
    );
end;
/

-- Combinand acest trigger cu unul care sa scrie intr-un fisier aceste loguri
-- atunci cand user-ul iese, sau baza de date se inchide sau intampina o
-- eroare, o sa avem aceste loguri fara nevoia de a mai intra inapoi in baza
-- de date.

-- vom defini o functie ce o vom utiliza in urmatoarele triggere
-- dupa executarea acestei functii, in directorul si fisierul cu numele specificat, se va afla
-- continutul tabelului audit_schema
create or replace procedure writelogs
is
    fisier  utl_file.file_type;
    p_sql_query varchar2(300):='select 
        nume_bd, user_logat, eveniment, tip_obiect_referit,
        nume_obiect_referit, data, nr_tabele, nr_triggere
    from audit_user';
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
    -- deschide fisierul pentru write
    fisier := utl_file.fopen('LOGS', 'logs.txt', 'w', 2047);
    
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
end;
/

create or replace trigger logoff_write_logs
before logoff on schema
begin
    writelogs;
end;
/

create or replace trigger log_erori
after servererror on schema
begin
    writelogs;
end;
/

create or replace trigger shutdown_write_logs
before shutdown on schema
begin
    writelogs;
end;
/