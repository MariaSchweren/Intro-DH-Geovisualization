library(shiny)
library(leaflet)
library(osrm)
library(geojsonio)
library(shinyjs)

csv <- read.csv(file="data.csv", encoding="UTF-8")
locations <- read.csv(file="locations_matched_osrm.csv", encoding="UTF-8")
saxony_geojson <- geojson_read("saxony.geojson")  # source: http://opendatalab.de/projects/geojson-utilities/

data <- list()
for(i in locations[,1]) {
  location_lat = strsplit(locations[i, "location_lat"], " ")
  location_lng = strsplit(locations[i, "location_lng"], " ")
  osrm_lat = strsplit(locations[i, "osrm_lat"], ", ")
  osrm_lng = strsplit(locations[i, "osrm_lng"], ", ")
  entry <- list(lat=location_lat,lng=location_lng,osrm_lat=osrm_lat,osrm_lng=osrm_lng)
  data[[i]] <- entry 
}

square_black <- makeIcon(iconUrl = "http://www.clipartbest.com/cliparts/niE/yKR/niEyKRyoT.jpeg", iconWidth = 5, iconHeight = 5)
square_green <- makeIcon(iconUrl = "http://www.clipartbest.com/cliparts/nTE/Kyb/nTEKyb8TA.png", iconWidth = 10, iconHeight = 10)
polyline_color <- "red"
polyline_width <- 3
selected_polyline_color <- "black"
selected_polyline_width <- 6
selected_previous_route <- FALSE
osrm <- FALSE
selected_route_id <- -1

ui <- fluidPage(
  tags$head(tags$style(type = "text/css", paste0(".selectize-dropdown {
                                                     bottom:100% !important;
                                                     top:auto !important;
                                                 }}"))),
  shinyjs::useShinyjs(),
  sidebarLayout(position = "right",
                sidebarPanel(
                  h4("Name"),
                  textOutput("name"),
                  h4("Ort"),
                  textOutput("ort"),
                  h4("Betreiber"),
                  textOutput("betreiber"),
                  div(id="aussenlager", 
                      h4("Standort des Lagers"),
                      textOutput("standort_aussenlager"),
                      h4("Dauer des Bestehens"),
                      textOutput("dauer_aussenlager"),
                      h4("Haeftlingsbelegung"),
                      textOutput("belegung_aussenlager"),
                      h4("Unterbringung"),
                      textOutput("unterbringung_aussenlager"),
                      h4("Art der Arbeiten"),
                      textOutput("arbeiten_aussenlager"),
                      h4("Todesopfer"),
                      textOutput("todesopfer_aussenlager"),
                      h4("Rueckueberstellungen"),
                      textOutput("rueckueberstellungen_aussenlager"),
                      h4("Fluchten"),
                      textOutput("fluchten_aussenlager"),
                      h4("Zugaenge aus anderen Lagern"),
                      textOutput("zugaenge_aussenlager"),
                      h4("Evakuierung"),
                      textOutput("evakuierung_aussenlager"),
                      h4("Juristische Aufarbeitung"),
                      textOutput("aufarbeitung_aussenlager"),
                      h4("Besonderheiten der Evakuierung"),
                      textOutput("evakuierung_besonderheiten_aussenlager"),
                      h4("Besonderheiten des Lagers"),
                      textOutput("lager_besonderheiten_aussenlager"),
                      h4("Ende der Evakuierung"),
                      textOutput("evakuierung_ende_aussenlager"),
                      h4("Todesopfer/Vorkommnisse"),
                      textOutput("vorkommnisse_aussenlager"),
                      h4("Verlauf/Orte"),
                      textOutput("verlauf_aussenlager")),
                  hidden(div(id="marsch", 
                             h4("Staerke der Kolonne"),
                             textOutput("kolonne_marsch"),
                             h4("Beginn der Evakuierung"),
                             textOutput("evakuierung_beginn_marsch"),
                             h4("Marsch auf saechsischem Gebiet"),
                             textOutput("sachsen_marsch"),
                             h4("weitere Evakuierung"),
                             textOutput("evakuierung_weitere_marsch"),
                             h4("Ende/Befreiung"),
                             textOutput("ende_marsch"),
                             h4("Besonderheiten"),
                             textOutput("besonderheiten_marsch"))),
                  hidden(div(id="transport", 
                             h4("Haeftlingsstaerke"),
                             textOutput("haeftlinge_transport"),
                             h4("Evakuierung"),
                             textOutput("evakuierung_transport"),
                             h4("Verleib"),
                             textOutput("verbleib_transport"),
                             h4("Arbeitseinsatz"),
                             textOutput("arbeit_transport"),
                             h4("Herkunft"),
                             textOutput("herkunft_transport"),
                             h4("Anzahl Todesopfer"),
                             textOutput("todesopfer_transport")))
                ),
                mainPanel(leafletOutput("map", height="70vh"),
                          br(),
                          dateRangeInput("time", NULL, start="1945-01-01", end="1945-05-08", language="de", weekstart=1, width="500px"),
                          checkboxInput("osrm", "OSRM", FALSE),
                          selectInput("route_selector", "Route", choices=csv[["Ort"]]),
                          checkboxInput("route_only", "Nur ausgewaehlte Route anzeigen: ", FALSE),
                          selectInput("type_selector", "Typ", choices=c("Alle", "Aussenlager in Sachsen" = "Aussenlager", "Maersche durch Sachsen" = "Marsch", "Bahntransporte durch Sachsen" = "Transport")),
                          actionButton("center", "Karte zentrieren"))
  )
)

server <- function(input, output, session) {
  
  output$map <- renderLeaflet(leaflet() %>% 
                                addTiles() %>%
                                setView(lng=13.5, lat=50.95, zoom=8) %>%
                                addGeoJSON(saxony_geojson, color="blue", fill=FALSE))
  
  getColor <- function(id) {
    name <- csv[id, "Name"]
    if(name == "Aussenlager KZ Flossenbuerg") {
      color <- "orange"
    } else if(name == "Aussenlager KZ Gross-Rosen" || name == "Aussenlager des KZ Gross-Rosen") {
      color <- "purple"
    } else if(name == "Aussenlager KZ Buchenwald" || name == "Aussenlager des KZ Buchenwald") {
      color <- "green"
    } else if(name == "Aussenlager KZ Dora-Mittelbau" || name == "Aussenlager des KZ Dora-Mittelbau") {
      color <- "teal"
    } else if(name == "Aussenlager KZ Sachsenhausen")  {
      color <- "brown"
    } else {
      color <- "red"
    }
    return(color)
  }
  
  addRoute <- function(id, color, weight) {
    lat <- as.numeric(data[[id]]$lat[[1]])
    lng <- as.numeric(data[[id]]$lng[[1]])
    osrm_lat <- as.numeric(data[[id]]$osrm_lat[[1]])
    osrm_lng <- as.numeric(data[[id]]$osrm_lng[[1]])
    if(osrm) {
      if(length(data[[id]]$lat[[1]]) == 1) {
        leafletProxy('map') %>% 
          addMarkers(layerId=id, group=as.character(id), lat=lat[1], lng=lng[1], icon=square_green)
      } else {
        leafletProxy('map') %>% 
          addMarkers(layerId=id, group=as.character(id), lat=lat[1], lng=lng[1], icon=square_green) %>%
          addMarkers(layerId=id, group=as.character(id), lat=lat[2:length(lat)], lng=lng[2:length(lat)], icon=square_black) %>%
          addPolylines(layerId=id, group=as.character(id), lat=osrm_lat, lng=osrm_lng, color=color, weight=weight)
      }
    } else {
      if(length(data[[id]]$lat[[1]]) == 1) {
        leafletProxy('map') %>% 
          addMarkers(layerId=id, group=as.character(id), lat=lat[1], lng=lng[1], icon=square_green)
      } else {
        leafletProxy('map') %>% 
          addMarkers(layerId=id, group=as.character(id), lat=lat[1], lng=lng[1], icon=square_green) %>%
          addMarkers(layerId=id, group=as.character(id), lat=lat[2:length(lat)], lng=lng[2:length(lat)], icon=square_black) %>%
          addPolylines(layerId=id, group=as.character(id), lat=lat, lng=lng, color=color, weight=weight)
      }
    }
  }
  
  selectRoute <- function(id) {
    selected_route_id <<- id
    updateSelectInput(session, "route_selector", selected = csv[id,"Ort"])
    type <- csv[[id, "Typ"]]
    if(selected_previous_route) {
      leafletProxy('map') %>% clearGroup(group=as.character(selected_previous_route))
      addRoute(selected_previous_route, getColor(selected_previous_route), polyline_width)
    }
    selected_previous_route <<- id
    leafletProxy('map') %>% clearGroup(group=as.character(id))
    addRoute(id, selected_polyline_color, selected_polyline_width)
    if(type == "Aussenlager") {
      shinyjs::hide(id="marsch")
      shinyjs::hide(id="transport")
      shinyjs::show(id="aussenlager")
      output$name <- renderText({csv$Name[id]})
      output$ort <- renderText({csv$Ort[id]})
      output$betreiber <- renderText({csv$Betreiber[id]})
      output$standort_aussenlager <- renderText({csv$Standort.des.Lagers[id]})
      output$dauer_aussenlager <- renderText({csv$Dauer.des.Bestehens[id]})
      output$belegung_aussenlager <- renderText({csv$H.ftlingsbelegung[id]})
      output$unterbringung_aussenlager <- renderText({csv$Unterbringung[id]})
      output$arbeiten_aussenlager <- renderText({csv$Art.der.Arbeiten[id]})
      output$todesopfer_aussenlager <- renderText({csv$Todesopfer[id]})
      output$rueckueberstellungen_aussenlager <- renderText({csv$R.ck.berstellungen[id]})
      output$fluchten_aussenlager <- renderText({csv$Fluchten[id]})
      output$zugaenge_aussenlager <- renderText({csv$Zug.nge.aus.anderen.Lagern[id]})
      output$evakuierung_aussenlager <- renderText({csv$Evakuierung[id]})
      output$aufarbeitung_aussenlager <- renderText({csv$Juristische.Aufarbeitung[id]})
      output$evakuierung_besonderheiten_aussenlager <- renderText({csv$Besonderheiten.der.Evakuierung[id]})
      output$lager_besonderheiten_aussenlager <- renderText({csv$Besonderheiten.des.Lagers[id]})
      output$evakuierung_ende_aussenlager <- renderText({csv$Ende.der.Evakuierung[id]})
      output$vorkommnisse_aussenlager <- renderText({csv$Todesopfer.Vorkommnisse[id]})
      output$verlauf_aussenlager <- renderText({csv$Verlauf.Orte[id]})
    } else if(type == "Marsch") {
      shinyjs::hide(id="aussenlager")
      shinyjs::hide(id="transport")
      shinyjs::show(id="marsch")
      output$name <- renderText({csv$Name[id]})
      output$ort <- renderText({csv$Ort[id]})
      output$betreiber <- renderText({csv$Betreiber[id]})
      output$kolonne_marsch <- renderText({csv$St.rke.der.Kolonne[id]})
      output$evakuierung_beginn_marsch <- renderText({csv$Beginn.der.Evakuierung[id]})
      output$sachsen_marsch <- renderText({csv$Marsch.auf.s.chsischem.Gebiet[id]})
      output$evakuierung_weitere_marsch <- renderText({csv$weitere.Evakuierung[id]})
      output$ende_marsch <- renderText({csv$Ende.der.Evakuierung[id]})
      output$besonderheiten_marsch <- renderText({csv$Besonderheiten[id]})
      output$vorkommnisse_marsch <- renderText({csv$Todesopfer.Vorkommnisse[id]})
    } else if(type == "Transport") {
      shinyjs::hide(id="aussenlager")
      shinyjs::hide(id="marsch")
      shinyjs::show(id="transport")
      output$name <- renderText({csv$Name[id]})
      output$ort <- renderText({csv$Ort[id]})
      output$betreiber <- renderText({csv$Betreiber[id]})
      output$haeftlinge_transport <- renderText({csv$H.ftlingsst.rke[id]})
      output$evakuierung_transport <- renderText({csv$Evakuierung[id]})
      output$verbleib_transport <- renderText({csv$Verbleib[id]})
      output$arbeit_transport <- renderText({csv$Arbeitseinsatz[id]})
      output$herkunft_transport <- renderText({csv$Herkunft[id]})
      output$todesopfer_transport <- renderText({csv$Anzahl.Todesopfer[id]})
    }
  }
  
  for(i in 1:length(data)) {
    addRoute(i, getColor(i), polyline_width)
  }
  selectRoute(1)
  
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
  
  observeEvent(input$route_only, { 
    if(selected_route_id != -1) {
      if(input$route_only) {
        leafletProxy('map') %>% hideGroup(csv[["id"]][-selected_route_id])
      } else {
        leafletProxy('map') %>% showGroup(csv[["id"]][-selected_route_id])
      }
    }
  }, ignoreInit = TRUE)
  
  observeEvent(input$route_selector, { 
    route_start <- input$route_selector
    id <- which(csv$Ort == route_start)
    if(input$route_only & selected_route_id != -1) {
      leafletProxy('map') %>% hideGroup(selected_route_id)
      leafletProxy('map') %>% showGroup(id)
    }
    selectRoute(id)
  }, ignoreInit = TRUE)
  
  observeEvent(input$type_selector, { 
    type <- input$type_selector
    if(type == "Alle") {
      leafletProxy('map') %>% showGroup(csv[["id"]])
    } else if(type == "Aussenlager") {
      leafletProxy('map') %>% hideGroup(which(csv[["Typ"]] != "Aussenlager"))
      leafletProxy('map') %>% showGroup(which(csv[["Typ"]] == "Aussenlager"))
    } else if(type == "Marsch") {
      leafletProxy('map') %>% hideGroup(which(csv[["Typ"]] != "Marsch"))
      leafletProxy('map') %>% showGroup(which(csv[["Typ"]] == "Marsch"))
    } else if(type == "Transport") {
      leafletProxy('map') %>% hideGroup(which(csv[["Typ"]] != "Transport"))
      leafletProxy('map') %>% showGroup(which(csv[["Typ"]] == "Transport"))
    }
  }, ignoreInit = TRUE)
  
  observeEvent(input$time, {
    leafletProxy('map') %>% clearMarkers() %>% clearShapes()
    for(i in 1:length(data)) {
      if(csv[[i, "Evakuierungsbeginn"]] >= input$time[1] & csv[[i, "Evakuierungsbeginn"]] <= input$time[2]) {
        addRoute(i, getColor(i), polyline_width)
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
        if(csv[[i, "Evakuierungsbeginn"]] >= input$time[1] & csv[[i, "Evakuierungsbeginn"]] <= input$time[2]) {
          addRoute(i, getColor(i), polyline_width)
        }
      }
    } else {
      osrm <<- FALSE
      leafletProxy('map') %>% clearMarkers() %>% clearShapes()
      for(i in 1:length(data)) {
        if(csv[[i, "Evakuierungsbeginn"]] >= input$time[1] & csv[[i, "Evakuierungsbeginn"]] <= input$time[2]) {
          addRoute(i, getColor(i), polyline_width)
        }
      }
    }
  }, ignoreInit = TRUE)
}

shinyApp(ui, server)