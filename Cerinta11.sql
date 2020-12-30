-- Cerinta 11

-- Vrem sa mentinem in tabelul de categorii niste contoare a pretului minim
-- respectiv maxim a unui produs din acea categorie.
-- Astfel, trebuie sa avem grija sa modificam aceste campuri cand se adauga
-- un produs nou, sau modifica unul existent, intrucat nu trebuie sa fie
-- grija unui utilizator simplu a bazei de date.

-- Il facem trigger de tip after ca sa se faca automat check-urile constrangerii
-- de tip foreign key

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

-- Pentru declansare, inseram un produs nou
insert into Produs(produs_id, vanzator_id, categorie_id, titlu)
values ((select max(produs_id) from produs) + 1, 1, 1, 'Produs Test');
rollback;