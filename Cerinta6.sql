-- Cerinta nr 6

-- Magazinul nostru vrea sa se asigure ca are un cashflow cat mai are.
-- Daca un produs este prea scump, nu va fi cumparat atat de des. Atunci
-- compania prefera sa isi micsoreze profitul per unitate si sa vanda
-- mai multe unitati.
-- Atfel, are nevoie de o procedura SQL care va micsora cu 5% pretul
-- la cel mai putin vandut produs in ultima luna.

set serveroutput on;

create or replace procedure AplicaReducere
is
    type tablou      is table of number index by binary_integer;
    type tablou_imbr is table of number;
    Produse tablou_imbr;
    
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
            select pc.* from PlasareComanda pc, comanda c
            where pc.comanda_id = c.comanda_id and
                months_between(sysdate, c.data) <= 1
        ) loop
            v(vanzare.produs_id) := v(vanzare.produs_id) + vanzare.cantitate;
        end loop;
        
        mn := v(v.first);
        for i in v.first .. v.last loop
            if v(i) < mn then
                mn := v(i);
                rasp.delete(rasp.first, rasp.last);
                rasp.extend;
                rasp(rasp.last) := i;
            elsif v(i) = mn then
                rasp.extend;
                rasp(rasp.last) := i;
            end if;
        end loop;
        
        return rasp;
    -- nu poate exista exceptia no data found, deoarece apelam functia 
    -- facand un group by inainte
    -- nu poate exista exceptia too many rows deoarece avem where
    -- rownum <= 1
    end AflaProduse;
    
begin
    Produse := AflaProduse;
    
    for i in Produse.first .. Produse.last loop
        update produs
        set pret = round(0.95 * pret, 2)
        where produs_id = Produse(i);
    end loop;
    commit;
end;
/

Execute AplicaReducere;