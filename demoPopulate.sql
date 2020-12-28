insert into locatie values(1, 'Splaiul Independentei 204', 'Bucuresti', 'Romania');
insert into locatie values(2, 'Bulevardul Iuliu Maniua 104', 'Bucuresti', 'Romania');
insert into locatie values(3, 'Strada Zavoiului 39', 'Chisinau', 'Republica Moldova');
insert into locatie values(4, 'Bergen Strasse 3', 'Berlin', 'Germania');
insert into locatie values(5, 'Bulevardul Alba Iulia 69', 'Cluj-Napoca', 'Romania');

insert into curier values(1, 'Gigel', 'Klaus', '0737777777', 'gigel.klaus@email.com');
insert into curier values(2, 'Dorel', 'Klaus', '0711111111', 'dorel.klaus@email.com');
insert into curier values(3, 'Gica', 'Dorica', '0722222222', 'gica.dorica@email.com');
insert into curier values(4, 'Ion', 'Popescu', '0733333333', 'ion.popescu@email.com');
insert into curier values(5, 'Bogdan', 'Dobrescu', '0737444444', 'bogdan.popescu@email.com');

insert into depozit values(1, 1, '0747111111', 'depozit1@email.com');
insert into depozit values(2, 2, '0737222222', 'depozit2@email.com');
insert into depozit values(3, 4, '0737222322', 'depozit3@email.com');
insert into depozit values(4, 5, '0737222422', 'depozit4@email.com');
insert into depozit values(5, 3, '0737252222', 'depozit5@email.com');

insert into utilizator values(1, 'Ion', 'Popescu', 'Administrator', 'ion.popescu@email.com', '0737111111', sysdate, 4);
insert into utilizator values(2, 'Gicu', 'Gigel', 'Utilizator', 'gicu.gigel@email.com', '0737222222', sysdate, 3);
insert into utilizator values(3, 'Dorel', 'Dori', 'Partener', 'dorel.dori@email.com', '0737333333', sysdate, 1);
insert into utilizator values(4, 'Teo', 'Costel', 'Utilizator', 'teo.costel@email.com', '0737204222', sysdate, 4);
insert into utilizator values(5, 'Ana', 'Maria', 'Utilizator', 'ana.maria@email.com', '0737202202', sysdate, 2);

insert into categorie values(1, 'Tech');
insert into categorie values(2, 'Religie');
insert into categorie values(3, 'Pijama');
insert into categorie values(4, 'Incaltaminte');
insert into categorie values(5, 'Utilitare');

insert into produs values(1, 3, 1, 'Iphone 12 Pro 64GB', 'Cel mai cel mai', 1099.99, 5);
insert into produs values(2, 1, 2, 'Biblia', 'Efectiv cartea cartilor', 333, 3);
insert into produs values(3, 3, 4, 'Crose alergat', 'Adidas cel mai bun pentru alergat, tripaloski', 699, 4);
insert into produs values(4, 3, 5, 'Banda adeziva', 'Repara orice', 15, 5);
insert into produs values(5, 3, 3, 'Pijama unicorn', 'E o pijama unicorn', 49.99, 2.5);

insert into DisponibilitateDepozit values(1, 4, 40);
insert into DisponibilitateDepozit values(1, 5, 50);
insert into DisponibilitateDepozit values(1, 2, 100);
insert into DisponibilitateDepozit values(1, 1, 220);
insert into DisponibilitateDepozit values(2, 3, 100);
insert into DisponibilitateDepozit values(2, 2, 10);
insert into DisponibilitateDepozit values(2, 4, 25);
insert into DisponibilitateDepozit values(3, 5, 69);
insert into DisponibilitateDepozit values(3, 2, 420);
insert into DisponibilitateDepozit values(3, 1, 12);
insert into DisponibilitateDepozit values(4, 1, 55);
insert into DisponibilitateDepozit values(4, 2, 69420);
insert into DisponibilitateDepozit values(4, 3, 34);
insert into DisponibilitateDepozit values(4, 4, 21);
insert into DisponibilitateDepozit values(4, 5, 9);

insert into recenzie values(1, 2, 1, 1, 'Android for life', sysdate);
insert into recenzie values(2, 4, 2, 5, 'M-a facut din ateist om de cruce', sysdate);
insert into recenzie values(3, 5, 3, 2, 'Am alergat doar 12km in ei', sysdate);
insert into recenzie values(4, 3, 4, 3, 'Banda mea adeziva ar fi mai buna', sysdate);
insert into recenzie values(5, 5, 5, 4, 'M-am simtit cu adevarat unicorn', sysdate);

insert into comanda values(1, 1, sysdate, 1);
insert into comanda values(2, 5, sysdate, 3);
insert into comanda values(3, 2, sysdate, 5);
insert into comanda values(4, 3, sysdate, 2);
insert into comanda values(5, 4, sysdate, 4);

insert into PlasareComanda values(1, 1, 2);
insert into PlasareComanda values(1, 2, 4);
insert into PlasareComanda values(2, 4, 5);
insert into PlasareComanda values(2, 3, 8);
insert into PlasareComanda values(2, 5, 2);
insert into PlasareComanda values(3, 1, 1);
insert into PlasareComanda values(3, 2, 3);
insert into PlasareComanda values(3, 5, 1);
insert into PlasareComanda values(4, 4, 2);
insert into PlasareComanda values(4, 3, 7);
insert into PlasareComanda values(5, 3, 3);
insert into PlasareComanda values(5, 1, 2);

commit;