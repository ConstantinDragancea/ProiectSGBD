-- Cerinte 13, 14

set serveroutput on;

create or replace package proiect
is
    type tablou         is table of number index by binary_integer;
    type tablou_imbr    is table of number;
    type tip_rasp_com   is record(
        utilizator_id   utilizator.utilizator_id%type,
        nume            utilizator.nume%type,
        prenume         utilizator.prenume%type,
        valoare         number);
    type tablou_raspuns is table of tip_rasp_com;
    
    procedure AplicaReducere;
    
    function AflaProduse return tablou_imbr;
    
    procedure LichidareStoc;
    
    function DepozitCantitateMin(
        prod_id     number
    ) return number;
    
    procedure VizualizareComenzi(
        nume_oras   locatie.oras%type,
        k           integer);
    
    function AflaPretProdus(
        prod_id     produs.produs_id%type
    ) return produs.pret%type;
    
    function AflaValoareComenzi(
        u_id        utilizator.utilizator_id%type,
        k           integer
    ) return number;
end proiect;
/

create or replace package body proiect
is
    function AflaProduse
    return tablou_imbr
    is
        v       tablou;
        rasp    tablou_imbr:=tablou_imbr();
        mn      number;
    begin
        for prod in (
            select * from produs
        ) loop
            v(prod.produs_id) := 0;
        end loop;
        
        for vanzare in (
            select pc.* from PlasareComanda pc, Comanda c
            where pc.comanda_id = c.comanda_id and
                months_between(sysdate, c.data) <= 1
        ) loop
            v(vanzare.produs_id) := v(vanzare.produs_id) + vanzare.cantitate;
        end loop;
        
        mn := v(v.first);
        for i in v.first .. v.last loop
            if v(i) < mn then
                rasp.delete(rasp.first, rasp.last);
                rasp.extend;
                rasp(rasp.last) := i;
            elsif v(i) = mn then
                rasp.extend;
                rasp(rasp.last) := i;
            end if;
        end loop;
        
        return rasp;
    end Aflaproduse;
    
    procedure AplicaReducere
    is
        Produse     tablou_imbr;
    begin
        Produse := AflaProduse;
        
        for i in Produse.first .. Produse.last loop
            update produs
            set pret = round(0.95 * pret, 2)
            where produs_id = Produse(i);
        end loop;
        commit;
    end AplicaReducere;
    
    function DepozitCantitateMin(
        prod_id     number
    ) return number
    is
        dep_id  number;
    begin
        select depozit_id into dep_id
        from (
            select * from DisponibilitateDepozit
            where produs_id = prod_id
            order by cantitate
        )
        where rownum <= 1;
        
        return dep_id;
    exception
        when no_data_found then
            raise_application_error(-20020, 'Produsul dat nu se gaseste in
                niciun depozit');
    end DepozitcantitateMin;
    
    procedure LichidareStoc
    is
        Depozite    tablou;
        prod_id     number;
    begin
        for dp in (
            select produs_id from DisponibilitateDepozit
            group by produs_id) loop
            
            Depozite(dp.produs_id) := DepozitCantitateMin(dp.produs_id);
        end loop;
        
        for i in Depozite.first .. Depozite.last loop
            if Depozite(i) is not null then
                dbms_output.put_line('Produs id: '||i||' Depozit id: '||Depozite(i));
            end if;
        end loop;
    end LichidareStoc;
    
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
            raise_application_error(-20021, 'Nu exista produs cu id-ul dat');
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
            raise_application_error(-20022, 'Nu exista utilizator cu acest id');
    end AflaDataInregistrare;
    
    function AflaValoareComenzi(
        u_id    utilizator.utilizator_id%type,
        k       integer
    ) return number
    is
        suma    number:=0;
        dataReg date;
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
    
    procedure VizualizareComenzi(
        nume_oras       locatie.oras%type,
        k               integer)
    is
        raspuns     tablou_raspuns;
        cnt         integer;
    begin
        select count(*) into cnt
        from locatie
        where oras = nume_oras;
        
        if cnt = 0 then
            raise_application_error(-20023, 'Nu exista oras cu numele dat in baza de date');
        end if;
        
        if k < 0 then
            raise_application_error(-20024, 'S-a dat un numar negativ de luni ca parametru');
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
            raspuns(i).valoare := AflaValoareComenzi(raspuns(i).utilizator_id, k);
            dbms_output.put_line(raspuns(i).utilizator_id||' '|| raspuns(i).nume||' '
                ||raspuns(i).prenume||' '||raspuns(i).valoare);
        end loop;
    exception
    when no_data_found then
        raise_application_error(-20001, 'Nu exista oras cu numele dat in baza de date');
    end VizualizareComenzi;
end proiect;
/