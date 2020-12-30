-- Cerinta nr 8

-- Administratorii site-ului vor sa stie pentru fiecare categorie de produse,
-- care e depozitul care detine cea mai mare cantitate de produse din acea
-- categorie.

-- Avem nevoie de tabelele Categorie, Produs, si DisponibilitateDepozit

set serveroutput on;

-- Functia va returna numarul de Categorii care se regasesc in macar un depozit
create or replace function IdentificareDepozite
return number
is
    type tablou      is table of number index by binary_integer;
    type tablou_string is table of categorie.NumeCategorie%type index by binary_integer;
    Categorii        tablou;
    NumeCategorii    tablou_string;
    dep_id           number;
    ans              number := 0;
    
begin
    for categ in (
        select * from categorie
    ) loop
        NumeCategorii(categ.categorie_id) := categ.NumeCategorie;
        begin
            select depozit_id into dep_id
            from (
                select dp.depozit_id, sum(dp.cantitate) as numar_produse
                from produs p, DisponibilitateDepozit dp
                where p.categorie_id = categ.categorie_id and
                    dp.produs_id = p.produs_id
                group by dp.depozit_id
                order by numar_produse desc                    
            )
            where rownum <= 1;
            Categorii(categ.categorie_id) := dep_id;
        exception
            -- nu putem avea exceptia too many rows deoarece am un
            -- where rownum <= 1, deci putem avea maxim 1 rezultat
            when no_data_found then
                Categorii(categ.categorie_id) := null;
        end;
    end loop;
    
    for i in Categorii.first .. Categorii.last loop
        if Categorii(i) is null then
            dbms_output.put_line('Categoria '||NumeCategorii(i)||' nu se regaseste in niciun depozit');
        else
            dbms_output.put_line('Categoria: '|| NumeCategorii(i));
            dbms_output.put_line('Depozitul cu id-ul: '|| Categorii(i));
            ans := ans + 1;
        end if;
    end loop;
    return ans;
end;
/

begin
    dbms_output.put_line('Categorii care se regasesc in cel putin 1 depozit: '||IdentificareDepozite());
end;

-- Adaugam o categorie noua, astfel suntem siguri ca nu se regaseste
-- in niciun depozit
insert into categorie(categorie_id, NumeCategorie) values((select max(categorie_id) from categorie) + 1, 'CategorieNula');
begin
    dbms_output.put_line('Categorii care se regasesc in cel putin 1 depozit: '||IdentificareDepozite());
end;
rollback;