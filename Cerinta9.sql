-- Cerinta nr 9

-- Magazinul are nevoie de o procedura care sa afle valoarea comenzilor plasata de userii
-- dintr-un anumit oras, in primele k luni de la crearea contului

-- Avem nevoie de tabelele Locatie, Utilizator, Comanda, Produs si PlasareComanda

set serveroutput on;

-- Functia va returna numarul de Categorii care se regasesc in macar un depozit
create or replace procedure VizualizareComenzi(
    nume_oras    locatie.oras%type,
    k            integer
)
is
    type tip_raspuns is record (utilizator_id   utilizator.utilizator_id%type,
                                nume            utilizator.nume%type,
                                prenume         utilizator.prenume%type,
                                valoare         number);
    type tablou is table of tip_raspuns;
    raspuns tablou;
    cnt     integer;
    
    function AflaPretProdus(
        prod_id     produs.produs_id%type
    ) return produs.pret%type
    is
        prod_pret   number;
    begin
        select pret into prod_pret
        from produs
        where produs_id = prod_id;
        
        return prod_pret;
    exception
        when no_data_found then
            raise_application_error(-20003, 'Nu exista produs cu id-ul dat in baza de date');
        -- nu putem avea exceptia too many rows doarece produs_id este cheie primara
    end AflaPretProdus;
    
    function AflaDataInregistrare(
        u_id    utilizator.utilizator_id%type
    ) return utilizator.DataInregistrare%type
    is
        dataReg     utilizator.DataInregistrare%type;
    begin
        select DataInregistrare into dataReg
        from utilizator
        where utilizator_id = u_id;
        
        return dataReg;
    exception
        when no_data_found then
            raise_application_error(-20000, 'Nu exista utilizator cu acest id');
        -- nu putem avea exceptia too many rows deoarece utilizator_id este cheie primara
    end AflaDataInregistrare;        
    
    function AflaValoareComenzi(
        u_id    utilizator.utilizator_id%type
    )
    return number
    is
        suma        number:=0;
        dataReg     date;
    begin   
        dataReg := AflaDataInregistrare(u_id);
        for my_comanda in (
            select pc.* from comanda c, PlasareComanda pc
            where utilizator_id = u_id and
                months_between(data, dataReg) <= k and
                c.comanda_id = pc.comanda_id
        ) loop
            suma := suma + my_comanda.cantitate * AflaPretProdus(my_comanda.produs_id);
        end loop;
        return suma;
    end AflaValoareComenzi;
begin
    select count(*) into cnt
    from locatie
    where oras = nume_oras;
    
    if cnt = 0 then
        raise_application_error(-20001, 'Nu exista oras cu numele dat in baza de date');
    end if;
    
    if k < 0 then
        raise_application_error(-20002, 'S-a dat un numar negativ de luni ca parametru');
    end if;
    
    select u.utilizator_id, u.nume, u.prenume, 0 as valoare
    bulk collect into raspuns
    from utilizator u, locatie l
    where l.oras = nume_oras and
        l.locatie_id = u.locatie_id;
    
    dbms_output.put_line('Valoarea comenzilor utilizatorilor din orasul '||nume_oras||
        ' in ultimele '||k||' luni');
    dbms_output.put_line('Id | Nume | Prenume | Valoarea comenzilor');
    for i in raspuns.first .. raspuns.last loop
        raspuns(i).valoare := AflaValoareComenzi(raspuns(i).utilizator_id);
        dbms_output.put_line(raspuns(i).utilizator_id||' '|| raspuns(i).nume||' '
            ||raspuns(i).prenume||' '||raspuns(i).valoare);
    end loop;
exception
    when no_data_found then
        raise_application_error(-20001, 'Nu exista oras cu numele dat in baza de date');
end;
/

-- trebuie pasat un oras care sa exista, sa consultam mai intai tabelul locatie
execute VizualizareComenzi('Florida', 1);

-- Dam un oras care nu exista
execute VizualizareComenzi('ABCD', 1);

-- Dam un numar negativ ca parametru pentru numarul de luni
execute VizualizareComenzi('Bucuresti', -1);