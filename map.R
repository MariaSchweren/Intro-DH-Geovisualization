library(shiny)
library(leaflet)
library(osrm)
library(geojsonio)

csv <- read.csv(file="C:\\Users\\Fabian\\Documents\\data\\data.csv", encoding="UTF-8")
locations <- read.csv(file="C:\\Users\\Fabian\\Documents\\data\\locations_matched_osrm.csv", encoding="UTF-8")

data <- list()
for(i in locations[,1]) { # TODO increase id in csv by one
  location_lat = strsplit(locations[i+1,4], " ")
  location_lng = strsplit(locations[i+1,5], " ")
  osrm_lat = strsplit(locations[i+1, "osrm_lat"], ", ")
  osrm_lng = strsplit(locations[i+1, "osrm_lng"], ", ")
  entry <- list(lat=location_lat,lng=location_lng,osrm_lat=osrm_lat,osrm_lng=osrm_lng)
  data[[i+1]] <- entry 
}

ui <- fluidPage(
  sidebarLayout(position = "right",
                sidebarPanel(h4("Name"),
                             textOutput("name"),
                             h4("Ort"),
                             textOutput("ort"),
                             h4("Betreiber"),
                             textOutput("betreiber"),
                             h4("Dauer des Bestehens"),
                             textOutput("dauer"),
                             h4("Haeftlingsbelegung"),
                             textOutput("belegung"),
                             h4("Unterbringung"),
                             textOutput("unterbringung"),
                             h4("Art der Arbeiten"),
                             textOutput("arbeiten"),
                             h4("Todesopfer"),
                             textOutput("todesopfer"),
                             h4("Rueckueberstellungen"),
                             textOutput("rueckueberstellungen"),
                             h4("Fluchten"),
                             textOutput("fluchten"),
                             h4("Zugaenge aus anderen Lagern"),
                             textOutput("zugaenge")),
                mainPanel(leafletOutput("map", height="85vh"),
                          dateRangeInput("time", NULL, start="1945-01-01", end="1945-05-08", language="de", weekstart=1, width="500px"),
                          checkboxInput("osrm", "OSRM", FALSE),
                          actionButton("center", "Center"))
  )
)

square_black <- makeIcon(iconUrl = "http://www.clipartbest.com/cliparts/niE/yKR/niEyKRyoT.jpeg", iconWidth = 10, iconHeight = 10)
polyline_color <- "red"
selected_polyline_color <- "black"
polyline_width <- 3
selected_polyline_width <- 6
prev <- FALSE
osrm <- FALSE
saxony_geojson <- geojson_read("C:\\Users\\Fabian\\Documents\\data\\saxony.geojson")  # source: http://opendatalab.de/projects/geojson-utilities/

server <- function(input, output, session) {
  
  output$map <- renderLeaflet(leaflet() %>% 
                              addTiles() %>%
                              setView(lng=13.5, lat=50.95, zoom=8) %>%
                              addGeoJSON(saxony_geojson, color="blue", fill=FALSE))
  
  addRoute <- function(id, color, weight) {
    lat <- as.numeric(data[[id]]$lat[[1]])
    lng <- as.numeric(data[[id]]$lng[[1]])
    osrm_lat <- as.numeric(data[[id]]$osrm_lat[[1]])
    osrm_lng <- as.numeric(data[[id]]$osrm_lng[[1]])
    if(osrm) {
      leafletProxy('map') %>% 
        addMarkers(layerId=id, group=as.character(id), lat=lat, lng=lng, icon=square_black) %>%
        addPolylines(layerId=id, group=as.character(id), lat=osrm_lat, lng=osrm_lng, color=color, weight=weight)
    } else {
      leafletProxy('map') %>% 
        addMarkers(layerId=id, group=as.character(id), lat=lat, lng=lng, icon=square_black) %>%
        addPolylines(layerId=id, group=as.character(id), lat=lat, lng=lng, color=color, weight=weight)
    }
  }
  
  for(i in 1:length(data)) {
    addRoute(i, polyline_color, polyline_width)
  }
  
  selectRoute <- function(id) {
    if(prev) {
      leafletProxy('map') %>% clearGroup(group=as.character(prev))
      addRoute(prev, polyline_color, polyline_width)
    }
    prev <<- id
    leafletProxy('map') %>% clearGroup(group=as.character(id))
    addRoute(id, selected_polyline_color, selected_polyline_width)
    output$name <- renderText({csv$Name[id]})
    output$ort <- renderText({csv$Ort[id]})
    output$betreiber <- renderText({csv$Betreiber[id]})
    output$dauer <- renderText({csv$Dauer.des.Bestehens[id]})
    output$belegung <- renderText({csv$H.ftlingsbelegung[id]})
    output$unterbringung <- renderText({csv$Unterbringung[id]})
    output$arbeiten <- renderText({csv$Art.der.Arbeiten[id]})
    output$todesopfer <- renderText({csv$Todesopfer[id]})
    output$rueckueberstellungen <- renderText({csv$R.ck.berstellungen[id]})
    output$fluchten <- renderText({csv$Fluchten[id]})
    output$zugaenge <- renderText({csv$Zug.nge.aus.anderen.Lagern[id]})
  }
  
  observeEvent(input$map_marker_click, {
    p <- input$map_marker_click
    id <- p$id
    selectRoute(id)
  })
  
  observeEvent(input$map_shape_click, { 
    p <- input$map_shape_click
    id <- p$id
    selectRoute(id)
  })
  
  observeEvent(input$time, {
    leafletProxy('map') %>% clearMarkers() %>% clearShapes()
    for(i in 1:length(data)) {
      if(csv[[i, "Datum"]] >= input$time[1] & csv[[i, "Datum"]] <= input$time[2]) {
        addRoute(i, polyline_color, polyline_width)
      }
    }
  }, ignoreInit = TRUE)
  
  observeEvent(input$center, {
    leafletProxy('map') %>% setView(lng=13.5, lat=50.95, zoom=8)
  }, ignoreInit = TRUE)

  observeEvent(input$osrm, {
    if(input$osrm) {
      osrm <<- TRUE
      leafletProxy('map') %>% clearShapes()
      for(i in 1:length(data)) {
        if(csv[[i, "Datum"]] >= input$time[1] & csv[[i, "Datum"]] <= input$time[2]) {
          addRoute(i, polyline_color, polyline_width)
        }
      }
    } else {
      osrm <<- FALSE
      leafletProxy('map') %>% clearMarkers() %>% clearShapes()
      for(i in 1:length(data)) {
        if(csv[[i, "Datum"]] >= input$time[1] & csv[[i, "Datum"]] <= input$time[2]) {
          addRoute(i, polyline_color, polyline_width)
        }
      }
    }
  }, ignoreInit = TRUE)
}

shinyApp(ui, server)