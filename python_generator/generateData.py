# coding=utf-8
from faker import Factory
import sys
from datetime import *
import random

fake = Factory.create()

def generateStudent():
    for _ in range (0, 1000):
        firstname = fake.first_name().replace("'", "")
        lastname = fake.last_name().replace("'", "")
        street = fake.street_name().replace("'", "")
        housenumber = fake.building_number()
        phonenumber = fake.phone_number().replace(" ", "")
        city = fake.city().replace("'", "")
        country = fake.country().replace("'", "")
        pesel = fake.ean13()[0:11]
        studentidcard = fake.ean8()

        Print = sys.stdout.write
        Print("exec Add_Individual_Client ")
        Print("'")
        Print(firstname)
        Print("','")
        Print(lastname)
        Print("','")
        Print(street)
        Print("','")
        Print(housenumber)
        Print("','")
        Print(city)
        Print("','")
        Print(country)
        Print("',")
        Print(studentidcard)
        Print(",'")
        Print(phonenumber)
        Print("',")
        Print(pesel +'\n')

def generateIndividualClients():
    for _ in range (0, 1000):
        firstname = fake.first_name().replace("'", "")
        lastname = fake.last_name().replace("'", "")
        street = fake.street_name().replace("'", "")
        housenumber = fake.building_number()
        phonenumber = fake.phone_number().replace(" ", "")
        city = fake.city().replace("'", "")
        country = fake.country().replace("'", "")
        pesel = fake.ean13()[0:11]
        idcard = fake.ean8()

        Print = sys.stdout.write
        Print("exec Add_Individual_Client ")
        Print("'")
        Print(firstname)
        Print("','")
        Print(lastname)
        Print("','")
        Print(street)
        Print("','")
        Print(housenumber)
        Print("','")
        Print(city)
        Print("','")
        Print(country)
        Print("',")
        Print("NULL")
        Print(",'")
        Print(phonenumber)
        Print("',")
        Print(pesel +'\n')

def generateConferences():
    for _ in range(0,100):
        conference_name = fake.catch_phrase().replace("'", "").replace("-", "")
        date1 = fake.date_time_between(start_date="-3y", end_date="now")
        date2 = date1 + timedelta(days=random.randint(1,5))
        start_date = date1.strftime("%Y/%m/%d")
        end_date = date2.strftime("%Y/%m/%d")
        street = fake.street_name().replace("'", "")
        housenumber = fake.building_number()
        city = fake.city().replace("'", "")
        country = fake.country().replace("'", "")
        student_discount = random.randint(0, 90)

        Print = sys.stdout.write
        Print("exec Add_Conference ")
        Print("'")
        Print(conference_name)
        Print("','")
        Print(start_date)
        Print("','")
        Print(end_date)
        Print("','")
        Print(street)
        Print("','")
        Print(housenumber)
        Print("','")
        Print(city)
        Print("','")
        Print(country)
        Print("',")
        Print(str(student_discount))
        Print(""+'\n')

def generateConferenceDays():
    for i in range (1,100):
        totalPlaces = random.randint(50,200)
        totalMoney = random.randint(50,1000)

        Print = sys.stdout.write
        Print("exec Add_Conference_Day_Conference_ID ")
        Print(str(i))
        Print(",")
        Print(str(totalPlaces))
        Print(",")
        Print(str(totalMoney))
        Print('\n')

def generatePriceRate():
    for i in range (1,200):
            discountPercent = random.randint(0,45)
            howManyDaysAgo = random.randint(10,20)
            Print = sys.stdout.write
            Print("exec Add_Conference_Price_Date_Given_ConferenceDayID")
            Print(" ");Print(str(i));Print(",")
            Print(str(howManyDaysAgo));Print(",");Print(str(discountPercent))
            Print('\n')
            
            
            discountPercent = random.randint(46,70)
            howManyDaysAgo = random.randint(30,40)
            Print = sys.stdout.write
            Print("exec Add_Conference_Price_Date_Given_ConferenceDayID")
            Print(" ");Print(str(i));Print(",")
            Print(str(howManyDaysAgo));Print(",");Print(str(discountPercent))
            Print('\n')
            

def generateIndividualReservation():
    for i in range (1,200):
        daysbefore = random.randint(1,100)
        firstname = fake.first_name().replace("'", "")
        lastname = fake.last_name().replace("'", "")
        street = fake.street_name().replace("'", "")
        housenumber = fake.building_number()
        phonenumber = fake.phone_number().replace(" ", "")
        city = fake.city().replace("'", "")
        country = fake.country().replace("'", "")
        pesel = fake.ean13()[0:11]
        studentidcard = fake.ean8()
        paymenttype = 'CASH'

        Print = sys.stdout.write
        Print("exec Add_Conference_Day_Individual_Reservation ")
        Print(str(i)); Print(",'")
        Print(firstname);Print("','")
        Print(lastname);Print("','")
        Print(street);Print("','")
        Print(housenumber);Print("','")
        Print(city);Print("','")
        Print(country);Print("',")
        Print(studentidcard);Print(",'")
        Print(phonenumber);Print("',")
        Print(pesel);Print(",'")
        Print(paymenttype);Print("',")
        Print(str(daysbefore));Print('\n')


def generateWorkshop():
    for i in range(1,198):
        workshopname = fake.catch_phrase().replace("'", "").replace("-", "")
        starthour = fake.date_time()
        endhour = starthour + timedelta(hours=random.randint(1,5))

        starthourToPrint = starthour.strftime("%H:%M")
        endhourToPrint = endhour.strftime("%H:%M")
        price = random.randint(5,500)
        totalplaces = random.randint(5,25)

        Print = sys.stdout.write
        Print("exec Add_Workshop ")
        Print(str(i))
        Print(",'")
        Print(workshopname)
        Print("','")
        Print(str(starthourToPrint))
        Print("','")
        Print(str(endhourToPrint))
        Print("','")
        Print(str(price))
        Print("',")
        Print(str(totalplaces))
        Print('\n')

def generateWorkshopIndividualReservations():
    for i in range(1,198):
        for j in range (1, random.randint(5,20)):
            daysbefore = random.randint(1,100)
            firstname = fake.first_name().replace("'", "")
            lastname = fake.last_name().replace("'", "")
            street = fake.street_name().replace("'", "")
            housenumber = fake.building_number()
            phonenumber = fake.phone_number().replace(" ", "")
            city = fake.city().replace("'", "")
            country = fake.country().replace("'", "")
            pesel = fake.ean13()[0:11]
            studentidcard = fake.ean8()
            paymenttype = 'CASH'

            Print = sys.stdout.write
            Print("exec Add_Workshop_IndividualClient_Reservation ")
            Print(str(i))
            Print(",'")
            Print(firstname)
            Print("','")
            Print(lastname)
            Print("','")
            Print(street);Print("','")
            Print(housenumber);Print("','")
            Print(city);Print("','")
            Print(country);Print("',")
            Print(studentidcard);Print(",'")
            Print(phonenumber);Print("',")
            Print(pesel);Print(",'")
            Print(paymenttype);Print("',")
            Print(str(daysbefore));Print('\n')





generateWorkshopIndividualReservations()
