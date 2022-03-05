import re

with open("Ortsverzeichnis.csv", mode="r", encoding="utf8") as file:
    text = file.read()

remove_parentheses = True  # if True the text in parentheses behind the location names will be removed

with open("ortsverzeichnis.txt", mode="w", encoding="utf8") as file:
    start = False  # for start condition
    for line in text.splitlines():
        if "Stadt/Gemeinde" in line:  # start parsing
            start = True
        if "Aufstellung Nummern der Todesmärsche (TM) und Bahntransporte {BT}" in line:  # stop parsing
            break
        if start:
            if re.search(r"[ ]{2,}", line) and "Ortsverzeichnis" not in line:
                s = re.split(r"[ ]{2,}", line)  # split where two or more spaces occur
                if s[0] and "Stadt/Gemeinde" not in s[0]:  # write to file if not empty and relevant
                    location = s[0]
                    if remove_parentheses:
                        location = re.sub(r"\([^()]*\)", "", location)  # delete text between parentheses
                    file.write(location.strip() + "\n")
