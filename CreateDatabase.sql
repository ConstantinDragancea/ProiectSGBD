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

create table Locatie(
	locatie_id number primary key,
	adresa     varchar2(100),
	oras       varchar2(50),
	tara	   varchar2(30)
);

create table Utilizator(
	utilizator_id		number primary key,
	nume				varchar2(20),
	prenume				varchar2(20),
	tip 				varchar2(20),
	email				varchar2(60),
	telefon				varchar2(10),
	DataInregistrare	date,
	locatie_id			number,
	foreign key (locatie_id) references Locatie(locatie_id) on delete set null
);

create table Categorie(
	categorie_id	number primary key,
	numeCategorie	varchar2(50)
);

create table Produs(
	produs_id		number primary key,
	vanzator_id		number,
	categorie_id	number,
	titlu			varchar2(200),
	descriere		varchar2(500),
	pret			number(10, 2),
	rating			number(2, 1),
	foreign key (vanzator_id) references Utilizator(utilizator_id) on delete cascade,
	foreign key (categorie_id) references Categorie(categorie_id) on delete cascade
);

create table Recenzie(
	recenzie_id		number primary key,
	utilizator_id	number,
	produs_id		number,
	stele			number(2, 1),
	continut		varchar2(300),
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
	utilizator_id	number,
	data			date,
	curier_id		number,
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
	locatie_id		number,
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