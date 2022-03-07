import re

import pandas as pd

with open("text_extracts_aussenlager.csv", "r", encoding="utf8") as file:
    text = file.read()

text = text.replace("­", "")  # remove soft hyphen tokens as they break the parser

data = []
splits = ["Außenlager KZ"]  # this list must include all possible types (excluding location name) from the first line of each entry (bold font in PDF) in order of appearance
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
    for counter, line in enumerate(entry.splitlines()):  # split text on \n
        if re.search(r"\w(-)?[ ]{2,}", line):  # if line contains character followed by two whitespaces (with potential hyphen inbetween)
            split_ = re.split(r"[ ]{2,}", line)  # split the line on the whitespaces (without preceding character as it would get removed)
            """
            The if statement below adds the previously parsed lines to the dictionary.
            Iteration 1 is skipped as its handled separately below and Iteration 2 is skipped as well because Iteration
            1 doesn't add to the key/value pair (would add a blank entry otherwise).
            """
            if counter > 1:
                value = " ".join(
                    value.split()).strip()  # merge lines after stripping whitespaces in case the source entry consisted of multiple lines
                rows_dict[key] = value  # add to dictionary
                value = ""  # reset value because its only modified by appending
            if counter == 0:
                rows_dict["Name"] = split_[0]
                rows_dict["Ort"] = split_[1]
            else:
                key = split_[0]
                value += split_[1]
        else:
            value += line
    df = df.append(rows_dict, ignore_index=True)

"""
Section for merging columns with the same meaning but different names.
"""
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

df = df.fillna("Nicht bekannt.")  # format empty values

df = df.drop(["Betrieb des Rüstungskonzerns", "Rückstellungen", "Verlauf/Orte/Todesopfer", "Orte", "Besonderheiten",
              "Standort", "Überstellungen", "Zugänge aus anderen Lager", "Auflösung", "Transport",
              "Weiterer Arbeitseinsatz", "Bestehen des Lagers", "Quellen"], axis="columns")  # remove merged columns

df.to_csv("formatted.csv", index_label="id")
