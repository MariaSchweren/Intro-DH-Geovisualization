import pandas
import re

data = []

with open("data.csv", "r", encoding="utf8") as file:
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

df = pandas.DataFrame()

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

df.to_csv("formatted.csv", index=False)