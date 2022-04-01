options(stringsAsFactors = FALSE)
require(quanteda)
require(dplyr)
install.packages("tidyverse")
install.packages("dplyr")
library(dplyr)

install.packages("readtext")                                                    #Package macht Auslesen unabhängig vom Dateiformat mgl.
data_files <- list.files(path = "newdata", full.names = T, recursive = T)
head(data_files, 3)                                                             #zeigt die ersten 3 PDF-Dateien im Ordner newdata an(in dem sich die PDF Ortsverzeichnisse befindet) 

require("readtext")                                                             #um Package (readtext) zu benutzen
extract_text <- readtext(data_files, docvarsfrom = "filepaths", dvsep = "/")    #readtext extrahiert Texte und speichert in var extract_text
head(extract_text)
cat(substr(extract_text$text[1], 0, 4500))                                      #Anzeigen der ersten 4500 Zeichen 

                                                                                
write.csv2(extract_text, file = "newdata/Ortsverzeichnis.csv", fileEncoding = "UTF-8") #überführen in CSV Datei 
