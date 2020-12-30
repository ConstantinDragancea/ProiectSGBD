-- Cerinta 10

-- Magazinul isi face totalurile in activitatilor economice la sfarsitul fiecarui
-- trimestru. In momentul in care face aceste totaluri, vrem sa ne asiguram ca
-- datele sunt cat mai exacte, astfel nu vrem ca o cumparatura facuta sa apara intr-un
-- calcul, iar in altul nu (daca de exemplu intre completarea fisierelor/tabelelor
-- 1 si 2 se mai face o comanda).
-- Solutia este ca in momentul in care se efectueaza aceste totaluri, sa fie blocata
-- posbilitatea plasarii unei comenzi. Totalurile se fac in cadrul orelor de lucru.

-- Astfel, in fiecare an, pe 31 martie, 30 iunie, 30 septembrie, 31 decembrie,
-- in intervalul de ore 9:00-17:00, este blocata posibilitatea plasarii unei comenzi.

set serveroutput on;

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

-- Pentru declansare incercam o inserare fie in una din cele 4 dati de mai sus,
-- fie adaugam in if sa verifice pentru ziua curenta
insert into PlasareComanda values(1, 3, 1);