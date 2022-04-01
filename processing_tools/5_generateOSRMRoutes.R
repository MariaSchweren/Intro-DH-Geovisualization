library(osrm)

# make sure your working directory points to the correct folder or set the complete path manually
locations <- read.csv(file="locations_matched.csv", encoding="UTF-8")

empty_vec <- rep(0, locations[, "id"]) # create columns for the OSRM data
locations$osrm_lat <- empty_vec
locations$osrm_lng <- empty_vec

for(i in 1:length(locations[, "id"])) {
  print(paste0(i, "/", length(locations[, "id"]), " ", locations[i, "location"]))  # discount progress bar
  lat <- as.numeric(strsplit(locations[i, "location_lat"], " ")[[1]])  # convert coordinates from string to integers
  lng <- as.numeric(strsplit(locations[i, "location_lng"], " ")[[1]])
  if(length(lat) == 1) {  # skip the OSRM processing if the route consists of only a single coordinate pair
    osrm_lat <- lat
    osrm_lng <- lng
  } else {
    for(x in 1:(length(lat) - 1)) {  # iterate to second to last route stop
      route_tmp <- osrmRoute(src = c(lng[x], lat[x]), dst = c(lng[x + 1], lat[x + 1])) # osrmRoute format is lng/lat! (???)
      if(x == 1) {  # if it's the first route just add it to the list
        route <- route_tmp  
      } else {  # otherwise merge the route with the existing coordinates
        route <- rbind(route, route_tmp)  
      }
    }
    osrm_lat <- as.character(route$lat)
    osrm_lng <- as.character(route$lon)
  }
  locations[i, "osrm_lat"] <- toString(osrm_lat)
  locations[i, "osrm_lng"] <- toString(osrm_lng)
}

write.csv(locations, "locations_matched_osrm.csv", row.names = FALSE, fileEncoding="UTF-8")
