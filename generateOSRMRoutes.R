library(shiny)
library(leaflet)
library(osrm)
library(geojsonio)

csv <- read.csv(file="C:\\Users\\Fabian\\Documents\\data\\data.csv", encoding="UTF-8")
locations <- read.csv(file="C:\\Users\\Fabian\\Documents\\data\\locations_matched.csv", encoding="UTF-8")

data <- list()
for(i in locations[,1]) {
  location_lat = strsplit(locations[i+1,4], " ")
  location_lng = strsplit(locations[i+1,5], " ")
  data[[i+1]] <- list(lat=location_lat,lng=location_lng)
}

empty_vec <- rep(1, length(data))
locations$osrm_lat <- empty_vec
locations$osrm_lng <- empty_vec

for(i in 1:length(data)) {
  lat <- as.numeric(data[[i]]$lat[[1]])
  lng <- as.numeric(data[[i]]$lng[[1]])
  if(length(data[[i]]$lat[[1]]) == 1) {
    val1 <- lat
    val2 <- lng
  } else {
    for(x in 1:(length(lat)-1)) {
      route_tmp <- osrmRoute(src=c(lng[x], lat[x]), dst=c(lng[x+1], lat[x+1])) # osrmRoute format is lng/lat!
      if(x == 1) {
        route <- route_tmp
      } else {
        route <- rbind(route, route_tmp)
      }
    }
    val1 <- as.character(route$lat)
    val2 <- as.character(route$lon)
  }
  locations[i,6] <- toString(val1)
  locations[i,7] <- toString(val2)
}

write.csv(locations, "C:\\Users\\Fabian\\Documents\\data\\locations_matched_osrm.csv", row.names = FALSE)