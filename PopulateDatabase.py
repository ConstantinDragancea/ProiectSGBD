import random
import csv
import pandas as pd

fout = open('PopulateDatabase.sql', 'w')

LOCATIE_COUNT = 500
DEPOZIT_COUNT = 500
PLASARECOMANDA_COUNT = 1500
PRODUS_COUNT = 500
CURIER_COUNT = 500
DISPONIBILITATEDEPOZIT_COUNT = 1500
UTILIZATOR_COUNT = 500
LOCATIE_COUNT = 500
COMANDA_COUNT = 500
RECENZIE_COUNT = 500

alphanum1 = [chr(i) for i in range(ord('a'), ord('z') + 1)]
alphanum2 = [chr(i) for i in range(ord('A'), ord('Z') + 1)]
alphanum3 = [chr(i) for i in range(ord('0'), ord('9') + 1)]
alphanum = alphanum1 + alphanum2 + alphanum3 + [' ']

# array of arrays of form [city, country, subcountry, ]
cities = []
# array of arrays of form [product_name, Category, price, description]
products = None
# array of strings of firstnames
firstnames = None
# array of strings of lastnames
lastnames = None
# arrays of strings addresses
addresses = None
# arrays of arrays of from [Score, Text]
reviews = None
dates = None

# taken from amazon.com
categories = ['Books', 'Films', 'Games', 'TV', 'Electronics', 'Computers', 'PC', 'Home',
            'Garden', 'Beauty', 'Health', 'Toys', 'Children', 'Baby', 'Shoes',
            'Watches', 'Lingerie', 'Sports', 'Outdoors', 'Clothes']


def parse_csv(file: str):
    with open(file, encoding='cp850') as fin:
        csv_reader = csv.reader(fin)
        return [row for row in csv_reader][1:]

def parse_txt(file: str):
    with open(file, encoding='cp850') as fin:
        txt_reader = fin.read().split('\n')
        return txt_reader

def check(s: str):
    for c in s:
        if (c not in alphanum):
            return False
    return True

def ParseDatasets():
    global cities, products, firstnames, lastnames, addresses, reviews, dates
    
    # array of arrays of form [city, country, subcountry, geoid]
    cities = parse_csv('./datasets/worldcities.csv')
    cities = [row for row in cities if (check(row[0]) and check(row[1]))]

    products = parse_csv('./datasets/products.csv')
    products = [prod for prod in products if prod[2] != '']
    products = [prod for prod in products if ('\'' not in prod[3])]
    products = [prod for prod in products if (len(prod[3]) < 3000)]
    products = [prod for prod in products if (len(prod[0]) < 200)]
    products = [prod for prod in products if ('&' not in prod[3])]

    firstnames = parse_txt('./datasets/firstnames.txt')

    lastnames = parse_txt('./datasets/lastnames.txt')

    addresses = parse_txt('./datasets/addresses.txt')

    dates = parse_txt('./datasets/dates.txt')

    reviews = parse_csv('./datasets/recenzii.csv')
    reviews = [rew for rew in reviews if ('\'' not in rew[1])]
    reviews = [rew for rew in reviews if ('&' not in rew[1])]

def GetSQLDateParser(ddate):
    return 'to_date(\'{}\', \'yyyy-mm-dd hh24:mi:ss\')'.format(ddate)

def GenerateTelefon():
    return '07{}'.format(random.randint(10000000, 99999999))

def GenerateLocations():
    fout.write('--------- GENERATING LOCATIONS -----------------------------\n')
    for i in range(LOCATIE_COUNT):
        street = random.choice(addresses)
        gen_city = random.choice(cities)
        fout.write('insert into locatie values({}, \'{}\', \'{}\', \'{}\');\n'.format(
            i + 1, street, gen_city[0], gen_city[1]
        ))
    fout.write('\n\n\n\n')

def GenerateCurier():
    fout.write('--------------------- GENERATING CURIERI ----------------------\n')
    for i in range(CURIER_COUNT):
        curier_nume = random.choice(lastnames)
        curier_prenume = random.choice(firstnames)
        curier_telefon = GenerateTelefon()
        curier_email = '{}.{}@email.com'.format(curier_nume, curier_prenume)
        fout.write('insert into curier values({}, \'{}\', \'{}\', \'{}\',\'{}\');\n'.format(
            i + 1, curier_nume, curier_prenume, curier_telefon, curier_email
        ))
    fout.write('\n\n\n')

def GenerateDepozit():
    fout.write('-------------------- GENERATING DEPOZIT ----------------------\n')
    for i in range(DEPOZIT_COUNT):
        d_loc_id = random.randint(1, LOCATIE_COUNT)
        d_tel = GenerateTelefon()
        d_email = 'depozit_{}@email.com'.format(i)
        fout.write('insert into depozit values({}, {}, \'{}\', \'{}\');\n'.format(
            i + 1, d_loc_id, d_tel, d_email
        ))
    fout.write('\n\n\n')

def GenerateCategorie():
    fout.write('---------------------- GENERATING CATEGORIE ----------------------\n')
    for i in range(len(categories)):
        fout.write('insert into categorie(categorie_id, NumeCategorie) values({}, \'{}\');\n'.format(
            i + 1, categories[i]
        ))
    fout.write('\n\n\n')

def GenerateUtilizator():
    fout.write('---------------------- GENERATING UTILIZATOR ----------------------\n')
    # first 5 users are admins
    for i in range(1, 6):
        nume = random.choice(lastnames)
        prenume = random.choice(firstnames)
        email = '{}.{}@email.com'.format(nume, prenume)
        telefon = GenerateTelefon()
        locatie = random.randint(1, LOCATIE_COUNT)
        dataReg = random.choice(dates)
        tip = 'ADMIN'
        fout.write('insert into utilizator values({}, \'{}\', \'{}\', \'{}\', \'{}\', \'{}\', {}, {});\n'.format(
            i, nume, prenume, tip, email, telefon, GetSQLDateParser(dataReg), locatie
        ))
    # next 95 users are partners/sellers
    for i in range(6, 101):
        nume = random.choice(lastnames)
        prenume = random.choice(firstnames)
        email = '{}.{}@email.com'.format(nume, prenume)
        telefon = GenerateTelefon()
        locatie = random.randint(1, LOCATIE_COUNT)
        dataReg = random.choice(dates)
        tip = 'PARTENER'
        fout.write('insert into utilizator values({}, \'{}\', \'{}\', \'{}\', \'{}\', \'{}\', {}, {});\n'.format(
            i, nume, prenume, tip, email, telefon, GetSQLDateParser(dataReg), locatie
        ))
    # the rest 400 users are simple users
    for i in range(101, UTILIZATOR_COUNT + 1):
        nume = random.choice(lastnames)
        prenume = random.choice(firstnames)
        email = '{}.{}@email.com'.format(nume, prenume)
        telefon = GenerateTelefon()
        locatie = random.randint(1, LOCATIE_COUNT)
        dataReg = random.choice(dates)
        tip = 'USER'
        
        fout.write('insert into utilizator values({}, \'{}\', \'{}\', \'{}\', \'{}\', \'{}\', {}, {});\n'.format(
            i, nume, prenume, tip, email, telefon, GetSQLDateParser(dataReg), locatie
        ))
    fout.write('\n\n\n')

def GenerateProdus():
    fout.write('-------------------- GENERATING PRODUS -------------------\n')
    for i in range(PRODUS_COUNT):
        v_id = random.randint(1, 100)
        c_id = random.randint(1, len(categories))
        prod = random.choice(products)
        titlu = prod[0]
        descriere = prod[3]
        pret = float(prod[2])
        rating = random.randint(1, 10) / 2
        fout.write('insert into produs values({}, {}, {}, \'{}\', \'{}\', {:.2f}, {:.2f});\n'.format(
            i + 1, v_id, c_id, titlu, descriere, pret, rating
        ))
    fout.write('\n\n\n')

def GenerateRecenzie():
    fout.write('----------------- GENERATING RECENZIE --------------------\n')
    for i in range(RECENZIE_COUNT):
        u_id = random.randint(1, UTILIZATOR_COUNT)
        p_id = random.randint(1, PRODUS_COUNT)
        rew = random.choice(reviews)
        stele = float(rew[0])
        continut = rew[1]
        fout.write('insert into recenzie values({}, {}, {}, {:.2f}, \'{}\', sysdate);\n'.format(
            i + 1, u_id, p_id, stele, continut
        ))
    fout.write('\n\n\n')

def GenerateComanda():
    fout.write('----------------------- GENERATE COMANDA ---------------------\n')
    for i in range(COMANDA_COUNT):
        u_id = random.randint(1, UTILIZATOR_COUNT)
        c_id = random.randint(1, CURIER_COUNT)
        fout.write('insert into comanda values({}, {}, sysdate, {});\n'.format(
            i + 1, u_id, c_id
        ))
    fout.write('\n\n\n')

def GeneratePlasareComanda():
    fout.write('------------------------ GENERATE PLASARE COMANDA ---------------------\n')
    mydict = dict()
    for i in range(PLASARECOMANDA_COUNT):
        p_id = random.randint(1, PRODUS_COUNT)
        c_id = random.randint(1, COMANDA_COUNT)
        while ((p_id, c_id) in mydict):
            p_id = random.randint(1, PRODUS_COUNT)
            c_id = random.randint(1, COMANDA_COUNT)
        mydict.update({(p_id, c_id): 1})
        cantitate =random.randint(1, 50)
        fout.write('insert into PlasareComanda values({}, {}, {});\n'.format(
            p_id, c_id, cantitate
        ))
    fout.write('\n\n\n')

def GenerateDisponibilitateDepozit():
    fout.write('--------------------- GENERATE DISPONIBILITATE DEPOZIT -------------------\n')
    mydict = dict()
    for i in range(DISPONIBILITATEDEPOZIT_COUNT):
        p_id = random.randint(1, PRODUS_COUNT)
        d_id = random.randint(1, DEPOZIT_COUNT)
        while ((p_id, d_id) in mydict):
            p_id = random.randint(1, PRODUS_COUNT)
            d_id = random.randint(1, DEPOZIT_COUNT)
        mydict.update({(p_id, d_id) : 1})
        cantitate = random.randint(10, 500)
        fout.write('insert into DisponibilitateDepozit values({}, {}, {});\n'.format(
            p_id, d_id, cantitate
        ))
    fout.write('\n\n\n')

ParseDatasets()

GenerateLocations()
GenerateCurier()
GenerateDepozit()
GenerateUtilizator()
GenerateCategorie()
GenerateProdus()
GenerateRecenzie()
GenerateComanda()
GeneratePlasareComanda()
GenerateDisponibilitateDepozit()

fout.write('commit;')
fout.close()

# print(reviews[0])