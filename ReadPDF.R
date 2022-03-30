options(stringsAsFactors = FALSE)
require(quanteda)
require(dplyr)
install.packages("tidyverse")
install.packages("dplyr")
library(dplyr)

install.packages("readtext")                                                    #Package macht Auslesen unabhängig vom Dateiformat mgl.
data_files <- list.files(path = "data", full.names = T, recursive = T)
head(data_files, 3)                                                             #zeigt die ersten 3 PDF-Dateien an 

require("readtext")                                                             #um Package (readtext) zu benutzen
extracted_texts <- readtext(data_files, docvarsfrom = "filepaths", dvsep = "/") #readtext extrahiert texte und speichert in var extracted_texts
head(extracted_texts)
cat(substr(extracted_texts$text[2], 0, 300))                                    #zeigt Anfang des 2. extrahierten Texts an 

cat(substr(extracted_texts$text[2], 0, 1000))                                   #zeigt die ersten 1000 Zeichen des Textes an 

write.csv2(extracted_texts, file = "data/text_extracts.csv", fileEncoding = "UTF-8") #überführen in CSV Datei 


