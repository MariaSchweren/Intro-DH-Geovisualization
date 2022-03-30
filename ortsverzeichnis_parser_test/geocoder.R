library(tibble)
library(dplyr)
library(tidygeocoder)

address_components <- tribble(
  ~city, ~country,
  "Leipzig", "Germany",
  "Wurzen", "Germany",
)

address <- address_components %>%
  geocode(city=city, country=country, method="osm")

print(address[1,]$lat)
print(address[1,]$long)
