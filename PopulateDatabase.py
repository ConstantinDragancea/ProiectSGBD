import random
import csv

fout = open('PopulateDatabase.sql', 'w')

# array of arrays of form [city, country, subcountry, ]
cities = []
# array of arrays of form [product_name, Category, Lingerie, price, description]
products = None
firstnames = None
lastnames = None
addresses = None
reviews = None
dates = None


def parse_csv(file: str):
    with open(file, encoding='cp850') as fin:
        csv_reader = csv.reader(fin)
        return [row for row in csv_reader][1:]

def parse_txt(file: str):
    with open(file, encoding='cp850') as fin:
        txt_reader = fin.read().split('\n')
        return txt_reader

def ParseDatasets():
    global cities, products, firstnames, lastnames, addresses, reviews, dates
    
    # array of arrays of form [city, country, subcountry, geoid]
    # we want just country and subcountry
    cities = parse_csv()

lol = parse_csv('./datasets/worldcities.csv')
print(lol[:5])
