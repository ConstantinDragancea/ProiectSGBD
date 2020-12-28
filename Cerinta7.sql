-- Cerinta nr 7

-- Magazinul nostru online vrea ca atunci cand intr-un depozit se afla putine
-- unitati ale unui produs, sa organizeze o promotie de lichidare de stoc,
-- pentru a face loc pentru alte produse.
-- Astfel, are nevoie de functie care la orice moment de timp, sa afiseze
-- pentru fiecare produs detaliile depozitului ce contine cantitatea cea mai mica
-- de produs respectiv. Evident ne intereseaza doar depozitele care au macar o
-- unitate de produs respectiv.
-- Daca un produs nu se afla in nici o cantitate
-- in vreunul din depozite, nu i se poate organiza o promotie de lichidare de stoc, 
-- deci nu ne intereseaza.

-- Vom defini un subprogram si vom folosi un ciclu cursor

set serveroutput on;

create or replace procedure LichidareStoc
is
    type tablou is table of number index by binary_integer;
    Depozite    tablou;
    prod_id      number;
    
    function DepozitCantitateMin(
        prod_id     number
    )
    return number
    is
        dep_id  number;
    begin
        select depozit_id
        into dep_id
        from (
            select * from DisponibilitateDepozit
            where produs_id = prod_id
            order by cantitate
        )
        where rownum <= 1;
        
        return dep_id;
    -- nu poate exista exceptia no data found, deoarece apelam functia 
    -- facand un group by inainte
    -- nu poate exista exceptia too many rows deoarece avem where
    -- rownum <= 1
    end DepozitCantitateMin;
    
begin
    for dp in (
        select produs_id from DisponibilitateDepozit
        group by produs_id) loop
        Depozite(dp.produs_id) := DepozitCantitateMin(dp.produs_id);
    end loop;
    
    for i in Depozite.first .. Depozite.last loop
        dbms_output.put_line('Produs id: '|| i||' Depozit id: '||Depozite(i));
    end loop;
end;
/

Execute LichidareStoc;