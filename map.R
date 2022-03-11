library(shiny)
library(leaflet)
library(osrm)

csv <- read.csv(file="C:\\Users\\Fabian\\Documents\\data\\data.csv", encoding="UTF-8")
locations <- read.csv(file="C:\\Users\\Fabian\\Documents\\data\\locations_matched.csv", encoding="UTF-8")

data <- list()
for(i in locations[,1]) {
  location_lat = strsplit(locations[i+1,4], " ")
  location_lng = strsplit(locations[i+1,5], " ")
  entry <- list(lat=location_lat,lng=location_lng)
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
                mainPanel(leafletOutput("map", width=1200, height=800),
                          dateRangeInput("time", NULL, start="1945-01-01", end="1945-05-08", language="de", weekstart=1, width="500px"),
                          checkboxInput("osrm", "OSRM", FALSE),
                          actionButton("center", "Center"),)
  )
)

square_black <- makeIcon(iconUrl = "http://www.clipartbest.com/cliparts/niE/yKR/niEyKRyoT.jpeg", iconWidth = 18, iconHeight = 18)
polyline_color <- "red"
polyline_width <- 3
prev <- FALSE

server <- function(input, output, session) {
  output$map <- renderLeaflet(leaflet() %>% setView(lng=13.5, lat=50.95, zoom=8) %>% addTiles())
  
  for(i in 1:length(data)) {
    lat <- as.numeric(data[[i]]$lat[[1]])
    lng <- as.numeric(data[[i]]$lng[[1]])
    leafletProxy('map') %>% addMarkers(layerId=i, group=as.character(i), lat=lat, lng=lng, icon=square_black) %>% addPolylines(layerId=i, group=as.character(i), lat=lat, lng=lng, color=polyline_color, weight=polyline_width)
  }

  observeEvent(input$map_marker_click, { 
    p <- input$map_marker_click
    id <- p$id-1
    if(prev) {
      leafletProxy('map') %>% clearGroup(group=as.character(prev)) %>% 
        addMarkers(layerId=prev, group=as.character(prev), lat=as.numeric(data[[prev]]$lat[[1]]), lng=as.numeric(data[[prev]]$lng[[1]]), icon=square_black) %>%
        addPolylines(layerId=prev, group=as.character(prev), lat=as.numeric(data[[prev]]$lat[[1]]), lng=as.numeric(data[[prev]]$lng[[1]]), color=polyline_color, weight=polyline_width)
    }
    prev <<- id+1
    leafletProxy('map') %>% clearGroup(group=as.character(id+1)) %>% 
      addMarkers(layerId=id+1, group=as.character(id+1), lat=as.numeric(data[[id+1]]$lat[[1]]), lng=as.numeric(data[[id+1]]$lng[[1]]), icon=square_black) %>%
      addPolylines(layerId=id+1, group=as.character(id+1), lat=as.numeric(data[[id+1]]$lat[[1]]), lng=as.numeric(data[[id+1]]$lng[[1]]), color="black", weight=polyline_width+3)
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
  })
  
  observeEvent(input$map_shape_click, { 
    p <- input$map_shape_click
    id <- p$id-1
    if(prev) {
      leafletProxy('map') %>% clearGroup(group=as.character(prev)) %>% 
        addMarkers(layerId=prev, group=as.character(prev), lat=as.numeric(data[[prev]]$lat[[1]]), lng=as.numeric(data[[prev]]$lng[[1]]), icon=square_black) %>%
        addPolylines(layerId=prev, group=as.character(prev), lat=as.numeric(data[[prev]]$lat[[1]]), lng=as.numeric(data[[prev]]$lng[[1]]), color=polyline_color, weight=polyline_width)
    }
    prev <<- id+1
    leafletProxy('map') %>% clearGroup(group=as.character(id+1)) %>% 
      addMarkers(layerId=id+1, group=as.character(id+1), lat=as.numeric(data[[id+1]]$lat[[1]]), lng=as.numeric(data[[id+1]]$lng[[1]]), icon=square_black) %>%
      addPolylines(layerId=id+1, group=as.character(id+1), lat=as.numeric(data[[id+1]]$lat[[1]]), lng=as.numeric(data[[id+1]]$lng[[1]]), color="black", weight=polyline_width+3)
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
  })
  
  observeEvent(input$time, {
    leafletProxy('map') %>% clearMarkers() %>% clearShapes()
    for(i in 1:length(csv)) {
      lat <- as.numeric(data[[i]]$lat[[1]])
      lng <- as.numeric(data[[i]]$lng[[1]])
      if(csv[[i, "Datum"]] >= input$time[1] & csv[[i, "Datum"]] <= input$time[2]) {
        leafletProxy('map') %>% addMarkers(layerId=i, lat=lat, lng=lng, icon=square_black) %>% addPolylines(layerId=i, lat=lat, lng=lng, color=polyline_color)
      }
    }
  }, ignoreInit = TRUE)
  
  observeEvent(input$center, {
    leafletProxy('map') %>% setView(lng=13.5, lat=50.95, zoom=8)
  }, ignoreInit = TRUE)

  # observeEvent(input$osrm, {
  #   if(input$osrm) {
  #     leafletProxy('map') %>% clearShapes()
  #     for(i in 1:length(a)) {
  #       if(a[[i]]$date >= input$time[1] & a[[i]]$date <=input$time[2]) {
  #         for(x in 1:(length(a[[i]]$lat)-1)) {
  #           route <- osrmRoute(src=c(a[[i]]$lng[x], a[[i]]$lat[x]), dst=c(a[[i]]$lng[x+1], a[[i]]$lat[x+1]))
  #           leafletProxy('map') %>% addPolylines(route$lon,route$lat)
  #         }
  #       }
  #     }
  #   } else {
  #     leafletProxy('map') %>% clearShapes()
  #     for(i in 1:length(a)) {
  #       if(a[[i]]$date >= input$time[1] & a[[i]]$date <=input$time[2]) {
  #         leafletProxy('map') %>% addPolylines(lat=a[[i]]$lat, lng=a[[i]]$lng)
  #       }
  #     }
  #   }
  # }, ignoreInit = TRUE)
}

shinyApp(ui, server)