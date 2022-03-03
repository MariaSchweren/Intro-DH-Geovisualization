import re

import pandas as pd

data = []

with open("text_extracts_aussenlager.csv", "r", encoding="utf8") as file:
    text = file.read()

text = text.replace("­", "")
text = text.split("Außenlager KZ")

for entry in text[1:-1]:
    data.append("Außenlager KZ" + entry)

text = text[-1]
text = text.split("Außenlager des KZ")

data.append("Außenlager KZ" + text[0])

for entry in text[1:-1]:
    data.append("Außenlager des KZ" + entry)

text = text[-1]
text = text.split("Transport zwischen")

data.append("Außenlager des KZ" + text[0])

for entry in text[1:]:
    data.append("Transport zwischen" + entry)

df = pd.DataFrame()

for entry in data:
    entries = {}
    entries_num = 0
    key = ""
    value = ""
    hyphen_flag = False
    for line in entry.splitlines():
        if hyphen_flag:
            s = re.split(r"[ ]{2,}", line)
            entries["Name"] = name_tmp + s[0]
            entries["Ort"] = loc_tmp
            if len(s) > 1:
                value += s[1]
            hyphen_flag = False
            continue
        if re.search(r"\w(-)?(-)?[ ]{2,}|Außenlager KZ \w+(-\w+)? \w", line):
            entries_num += 1
            if entries_num > 2:
                value = " ".join(value.split()).strip()
                entries[key] = value
                value = ""
            if re.search(r"Außenlager KZ \w+(-\w+)? \w", line):
                s[0] = " ".join(line.split(" ")[:3])
                s[1] = " ".join(line.split(" ")[3:])
            else:
                s = re.split(r"[ ]{2,}", line)
            if entries_num == 1:
                if re.search(r"\w-[ ]{2,}", line):
                    name_tmp = s[0][:-1]
                    loc_tmp = s[1]
                    hyphen_flag = True
                elif "Transport zwischen" in line:
                    entries["Name"] = "Transport"
                    entries["Ort"] = s[1]
                else:
                    entries["Name"] = s[0]
                    entries["Ort"] = s[1]
            else:
                key = s[0]
                value += s[1]
        elif entries_num == 1:
            entries["Ort"] += line
            entries["Ort"] = " ".join(entries["Ort"].split())
        else:
            value += line
    df = df.append(entries, ignore_index=True)

for index, row in df.iterrows():
    if pd.isna(row["Betreiber"]):
        if pd.notna(row["Betrieb des Rüstungskonzerns"]):
            df.loc[index, "Betreiber"] = row["Betrieb des Rüstungskonzerns"]

    if pd.isna(row["Rücküberstellungen"]):
        if pd.notna(row["Rückstellungen"]):
            df.loc[index, "Rücküberstellungen"] = row["Rückstellungen"]
        elif pd.notna(row["Überstellungen"]):
            df.loc[index, "Rücküberstellungen"] = row["Überstellungen"]

    if pd.isna(row["Zugänge aus anderen Lagern"]):
        if pd.notna(row["Zugänge aus anderen Lager"]):
            df.loc[index, "Zugänge aus anderen Lagern"] = row["Zugänge aus anderen Lager"]

    if pd.isna(row["Evakuierung"]):
        if pd.notna(row["Auflösung"]):
            df.loc[index, "Evakuierung"] = row["Auflösung"]

    if pd.isna(row["Besonderheiten des Lagers"]):
        if pd.notna(row["Besonderheiten"]):
            df.loc[index, "Besonderheiten des Lagers"] = row["Besonderheiten"]

    if pd.isna(row["Verlauf/Orte"]):
        if pd.notna(row["Verlauf/Orte/Todesopfer"]):
            df.loc[index, "Verlauf/Orte"] = row["Verlauf/Orte/Todesopfer"]
        elif pd.notna(row["Orte"]):
            df.loc[index, "Verlauf/Orte"] = row["Orte"]
        elif pd.notna(row["Transport"]):
            df.loc[index, "Verlauf/Orte"] = row["Transport"]
        elif pd.notna(row["Evakuierung"]):
            df.loc[index, "Verlauf/Orte"] = row["Evakuierung"]

df = df.fillna("Nicht bekannt.")
df = df.drop(61)

df = df.drop(["Betrieb des Rüstungskonzerns", "Rückstellungen", "Verlauf/Orte/Todesopfer", "Orte", "Besonderheiten",
              "Standort", "Überstellungen", "Zugänge aus anderen Lager", "Auflösung", "Transport",
              "Weiterer Arbeitseinsatz", "Bestehen des Lagers", "Quellen"], axis="columns")

df.to_csv("formatted.csv", index=False)
