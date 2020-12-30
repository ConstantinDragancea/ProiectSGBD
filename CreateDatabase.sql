drop table Utilizator cascade constraints;
drop table Depozit cascade constraints;
drop table DisponibilitateDepozit cascade constraints;
drop table Produs cascade constraints;
drop table Recenzie cascade constraints;
drop table Locatie cascade constraints;
drop table Categorie cascade constraints;
drop table Comanda cascade constraints;
drop table PlasareComanda cascade constraints;
drop table Curier cascade constraints;

drop trigger audit_schema;
drop trigger logoff_write_logs;
drop table audit_user;
drop trigger shutdown_write_logs;
drop trigger log_erori;

create table Locatie(
	locatie_id number primary key,
	adresa     varchar2(100),
	oras       varchar2(100),
	tara	   varchar2(100)
);

create table Utilizator(
	utilizator_id		number primary key,
	nume				varchar2(20) not null,
	prenume				varchar2(20),
	tip 				varchar2(20) not null,
	email				varchar2(60),
	telefon				varchar2(10),
	DataInregistrare	date,
	locatie_id			number not null,
	foreign key (locatie_id) references Locatie(locatie_id) on delete set null
);

create table Categorie(
	categorie_id	number primary key,
	numeCategorie	varchar2(50),
	PretMinim		number,
	pretMaxim		number
);

create table Produs(
	produs_id		number primary key,
	vanzator_id		number not null,
	categorie_id	number not null,
	titlu			varchar2(200),
	descriere		varchar2(3000),
	pret			number(10, 2),
	rating			number(2, 1),
	foreign key (vanzator_id) references Utilizator(utilizator_id) on delete cascade,
	foreign key (categorie_id) references Categorie(categorie_id) on delete cascade
);

create table Recenzie(
	recenzie_id		number primary key,
	utilizator_id	number not null,
	produs_id		number not null,
	stele			number(2, 1),
	continut		varchar2(3000),
	data			date,
	foreign key (utilizator_id) references Utilizator(utilizator_id) on delete cascade,
	foreign key (produs_id) references Produs(produs_id) on delete cascade
);

create table Curier(
	curier_id		number primary key,
	nume			varchar2(20),
	prenume			varchar2(20),
	telefon			varchar2(10),
	email			varchar2(60)
);

create table Comanda(
	comanda_id		number primary key,
	utilizator_id	number not null,
	data			date,
	curier_id		number not null,
	foreign key (utilizator_id) references Utilizator(utilizator_id) on delete cascade,
	foreign key (curier_id) references Curier(curier_id) on delete set null
);

create table PlasareComanda(
	produs_id		number,
	comanda_id		number,
	cantitate		number,
	primary key (produs_id, comanda_id),
	foreign key (produs_id) references Produs(produs_id) on delete cascade,
	foreign key (comanda_id) references Comanda(comanda_id) on delete cascade
);

create table Depozit(
	depozit_id		number primary key,
	locatie_id		number not null,
	telefon			varchar2(10),
	email			varchar2(60),
	foreign key (locatie_id) references Locatie(locatie_id) on delete set null
);

create table DisponibilitateDepozit(
	produs_id		number,
	depozit_id		number,
	cantitate		number,
	primary key (produs_id, depozit_id),
	foreign key (produs_id) references Produs(produs_id) on delete cascade,
	foreign key (depozit_id) references Depozit(depozit_id) on delete cascade
);

describe locatie;
describe curier;
describe categorie;
describe utilizator;
describe produs;
describe recenzie;
describe depozit;
describe DisponibilitateDepozit;
describe comanda;
describe PlasareComanda;

-- Adaugam triggerii creati la cerintele 10, 11, 12

create or replace trigger SfarsitTrimestru
before insert or delete or update on PlasareComanda
begin
    if (to_char(sysdate, 'DD/MM') = '31/03' or
        to_char(sysdate, 'DD/MM') = '30/06' or
        to_char(sysdate, 'DD/MM') = '30/09' or
        to_char(sysdate, 'DD/MM') = '29/12') then
        
        raise_application_error(-20010, 'Plasarea/Modificarea/Stergerea comenzilor 
            este interzise in zilele in care se fac totalurile trimestrului!');
    end if;
end;
/

create or replace trigger categ_minmax_price
after insert or update on produs
for each row
declare
    min_pr      number;
    max_pr      number;
    categ       categorie%rowtype;
begin    
    min_pr := :new.pret;
    max_pr := :new.pret;
    
    select * into categ
    from categorie
    where categorie_id = :new.categorie_id;
    
    if nvl(categ.PretMinim, min_pr) < min_pr then
        min_pr := categ.PretMinim;
    end if;
    
    if nvl(categ.PretMaxim, max_pr) > max_pr then
        max_pr := categ.PretMaxim;
    end if;
    
    update categorie
    set PretMinim = min_pr,
        PretMaxim = max_pr
    where categorie_id = :new.categorie_id;
end;
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

-- presupunem ca exista directorul folosit de functie, si userul are acces la pachetele
-- utl_file si dbms_sql, precum si drepturi de read write asupra acelui director
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