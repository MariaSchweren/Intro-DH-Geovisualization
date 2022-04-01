import re

import pandas as pd

with open("../source_data/text_extracts.csv", "r", encoding="utf8") as file:
    text = file.read()

text = text.replace("­", "")  # remove soft hyphen tokens as they break the parser

data = []
splits = ["Außenlager KZ", "Außenlager des KZ", "Transport zwischen"]  # this list must include all possible types (excluding location name) from the first line of each entry (bold font in PDF) in order of appearance
previous = None

"""
Section for separating the individual entries for further processing.
"""
for split_ in splits:
    text = text.split(split_)
    if previous is not None:  # skip first iteration
        data.append(previous + text[0])
    for entry in text[1:-1]:  # omit last element in slice as it contains the rest of source text
        data.append(split_ + entry)  # add separator + entry to list because split() removes separator
    text = text[-1]
    previous = split_  # save current separator for combination with remaining leading element after split in next iteration
data.append(splits[-1] + text)  # add last entry as it isn't included in inner loop

df = pd.DataFrame()

"""
Section for separating the rows in each entry into their respective column in the .csv.
"""
for entry in data:
    rows_dict = {}
    key = ""
    value = ""
    hyphen = False
    for counter, line in enumerate(entry.splitlines()):  # split text on \n
        if hyphen:
            hyphen = False
            split_ = re.split(r"[ ]{2,}", line)
            if counter <= 1:
                if split_[0].islower():
                    rows_dict["Name"] = rows_dict["Name"][:-1] + split_[0]
                else:
                    rows_dict["Name"] += split_[0]
                if len(split_) > 1:
                    rows_dict["Ort"] += split_[1]
            else:
                if split_[0].islower():
                    key = key[:-1] + split_[0]
                else:
                    key += split_[0]
                value += split_[1]
            continue
        if re.search(r"\w(-)?[ ]{2,}", line):  # if line contains character followed by two whitespaces (with potential hyphen inbetween)
            if re.search(r"\w-[ ]{2,}", line):
                hyphen = True
            split_ = re.split(r"[ ]{2,}", line)  # split the line on the whitespaces (without preceding character as it would get removed)
            """
            The if statement below adds the previously parsed lines to the dictionary.
            Iteration 1 is skipped as its handled separately below and Iteration 2 is skipped as well because Iteration
            1 doesn't add to the key/value pair (would add a blank entry otherwise).
            """
            if counter > 1:
                value = " ".join(value.split()).strip()  # merge lines after stripping whitespaces in case the source entry consisted of multiple lines
                if key and value:
                    rows_dict[key] = value  # add to dictionary
                value = ""  # reset value because its only modified by appending
            if counter == 0:
                rows_dict["Name"] = split_[0]
                rows_dict["Ort"] = split_[1]
            else:
                key = split_[0]
                value += split_[1]
        else:
            if len(rows_dict) == 2 and not key:
                rows_dict["Ort"] += " " + line.strip()
            else:
                value += line
    df = df.append(rows_dict, ignore_index=True)

"""
Section for merging columns with the same meaning but different names.
"""

df.loc[0:60, "Typ"] = "Aussenlager"
df.loc[61:83, "Typ"] = "Marsch"
df.loc[84:, "Typ"] = "Transport"
df.loc[96:, "Name"] = "Transport"

for index, row in df.iterrows():
    # for camps in Saxony
    if row["Typ"] == "Aussenlager":
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

    # for marches through Saxony
    elif row["Typ"] == "Marsch":
        if pd.isna(row["Stärke der Kolonne"]):
            if pd.notna(row["Häftlingsstärke"]):
                df.loc[index, "Stärke der Kolonne"] = row["Häftlingsstärke"]

        if pd.isna(row["Marsch auf sächsischem Gebiet"]):
            if pd.notna(row["Verlauf/Orte"]):
                df.loc[index, "Marsch auf sächsischem Gebiet"] = row["Verlauf/Orte"]

        if pd.isna(row["Ende/Befreiung"]):
            if pd.notna(row["Ende der Evakuierung"]):
                df.loc[index, "Ende/Befreiung"] = row["Ende der Evakuierung"]

    # for transports through Saxony
    elif row["Typ"] == "Transport":
        if pd.isna(row["Dauer und Weg des Bahntransports"]):
            if pd.notna(row["Dauer und Weg des Transports"]):
                df.loc[index, "Dauer und Weg des Bahntransports"] = row["Dauer und Weg des Transports"]
            elif pd.notna(row["Fahrstrecke"]):
                df.loc[index, "Dauer und Weg des Bahntransports"] = row["Fahrstrecke"]

        if pd.isna(row["Dauer des Bahntransports"]):
            if pd.notna(row["Dauer der Evakuierung"]):
                df.loc[index, "Dauer des Bahntransports"] = row["Dauer der Evakuierung"]

        if pd.isna(row["Anzahl Todesopfer"]):
            if pd.notna(row["Bekannte Opfer"]):
                df.loc[index, "Anzahl Todesopfer"] = row["Bekannte Opfer"]

        if pd.isna(row["Verbleib"]):
            if pd.notna(row["Dauer des Bahntransports"]):
                df.loc[index, "Verbleib"] = row["Dauer des Bahntransports"]

        if pd.isna(row["Evakuierung"]):
            if pd.notna(row["Dauer und Weg des Bahntransports"]):
                df.loc[index, "Evakuierung"] = row["Dauer und Weg des Bahntransports"]

dates = pd.read_csv("dates.csv")
df["Evakuierungsbeginn"] = dates["Evakuierungsbeginn"]  # add formatted dates to dataframe

df["Name"] = df["Name"].str.replace("ß", "ss")
df["Name"] = df["Name"].str.replace("ü", "ue")
df["Name"] = df["Name"].str.replace("ö", "oe")
df["Name"] = df["Name"].str.replace("ä", "ae")

df = df.fillna("Nicht bekannt.")  # format empty values

df = df.drop(["Betrieb des Rüstungskonzerns", "Rückstellungen", "Verlauf/Orte/Todesopfer", "Orte",
              "Standort", "Überstellungen", "Zugänge aus anderen Lager", "Auflösung", "Transport",
              "Weiterer Arbeitseinsatz", "Bestehen des Lagers", "Quellen", "Dauer und Weg des Transports",
              "Fahrstrecke", "Dauer der Evakuierung", "Dauer des Bahntransports", "Bekannte Opfer",
              "Dauer und Weg des Bahntransports"], axis="columns")  # remove merged columns

df.index += 1
df.to_csv("data.csv", index_label="id")
