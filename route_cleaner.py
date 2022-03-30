import os

import pandas as pd
from termcolor import colored

file_name = "data.csv"
df = pd.read_csv(file_name)  # create dataframe from csv

# try opening an existing processed locations file, if it doesn't exist create a new dataframe
try:
    output = pd.read_csv("locations.csv")
except:
    output = pd.DataFrame(columns=["location", "route"])

start = int(input("Start with index number: "))  # for starting in the middle of the dataframe
for index, row in df.iterrows():  # iterate each row of the source data
    entry = {}
    if index >= start:  # start when previously entered index number is reached in the frame
        print("###################")
        print("Ort: " + row["Ort"])
        if "Standort des Lagers" in df.columns:
            print("Standort des Lagers: " + row["Standort des Lagers"])
        print("###################")
        while True:
            try:
                location = input("Enter location name: ")
                entry["location"] = location
                break
            except ValueError:
                print("Enter a valid string.")
        print("###################")
        if row["Typ"] == "Aussenlager":
            print("Evakuierung: " + row["Evakuierung"])
            print("Verlauf/Orte: " + row["Verlauf/Orte"])
            print("Ende der Evakuierung: " + row["Ende der Evakuierung"])
        elif row["Typ"] == "Marsch":
            print("Beginn der Evakuierung: " + str(row["Beginn der Evakuierung"]))
            print("Marsch auf sächsischem Gebiet: " + str(row["Marsch auf sächsischem Gebiet"]))
            print("weitere Evakuierung: " + str(row["weitere Evakuierung"]))
            print("Ende/Befreiung: " + str(row["Ende/Befreiung"]))
            print("Verlauf/Orte: " + str(row["Verlauf/Orte"]))
        elif row["Typ"] == "Transport":
            print("Evakuierung: " + str(row["Evakuierung"]))
            print("Verbleib: " + str(row["Verbleib"]))
            print("Dauer des Bahntransports: " + str(row["Dauer des Bahntransports"]))
            print("Dauer der Evakuierung: " + str(row["Dauer der Evakuierung"]))
        print("###################")
        print(colored("Enter 'n' to finish route", "red"))
        route = []
        while True:
            try:
                route_stop = input("Enter route stop: ")
                if route_stop == "n":  # finish route when 'n' is entered in the terminal
                    os.system('cls' if os.name == 'nt' else 'clear')  # clear terminal after finishing entry
                    break
                else:
                    route.append(route_stop)
            except ValueError:
                print("Enter a valid string.")
        entry["route"] = route
        output = output.append(entry, ignore_index=True)  # add entry to dataframe
        output.to_csv("locations.csv", index=False)  # transform dataframe to .csv
    else:
        continue
