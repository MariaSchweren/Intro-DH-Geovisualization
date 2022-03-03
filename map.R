library(shiny)
library(leaflet)
library(osrm)
library(rlist)

lat = c(51.4047, 51.3848, 51.3244, 51.3145, 51.3012, 51.2882, 51.2749, 51.1253, 51.1130, 51.0843)
lng = c(14.2678, 14.2445, 14.1611, 14.1385, 14.1227, 14.1481, 14.1025, 14.1842, 13.9142, 14.0193)
date = "1945-04-19"
data <- list(lat=lat, lng=lng, date=date)
lat2 = c(51.3298, 51.3599, 51.3698, 51.3006)
lng2 = c(12.2936, 12.7119, 12.7436, 13.1059)
date2 = "1945-03-29"
data2 <- list(lat=lat2, lng=lng2, date=date2)
a <- list(data, data2)

demo1_lat = 51.010409
demo1_lng = 16.29121

df <- data.frame(lat, lng)
csv <- read.csv(file="C:\\Users\\Fabian\\Documents\\data\\data.csv", encoding="UTF-8")

ui <- fluidPage(

  sidebarLayout(position = "right",
                sidebarPanel(h4("Name"),
                             verbatimTextOutput("name"),
                             h4("Ort"),
                             verbatimTextOutput("ort"),
                             h4("Betreiber"),
                             verbatimTextOutput("betreiber"),
                             h4("Dauer des Bestehens"),
                             verbatimTextOutput("dauer"),
                             h4("Haeftlingsbelegung"),
                             verbatimTextOutput("belegung"),
                             h4("Unterbringung"),
                             verbatimTextOutput("unterbringung"),
                             h4("Art der Arbeiten"),
                             verbatimTextOutput("arbeiten"),
                             h4("Todesopfer"),
                             verbatimTextOutput("todesopfer"),
                             h4("Rueckueberstellungen"),
                             verbatimTextOutput("rueckueberstellungen"),
                             h4("Fluchten"),
                             verbatimTextOutput("fluchten"),
                             h4("Zugaenge aus anderen Lagern"),
                             verbatimTextOutput("zugaenge")),
                mainPanel(leafletOutput("map", width=1200, height=800),
                          dateRangeInput("time", NULL, start="1945-01-01", end="1945-05-08", language="de", weekstart=1, width="500px"),
                          checkboxInput("osrm", "OSRM", FALSE),
                          actionButton("center", "Center"),)
  )
)

square_green <-
  makeIcon(iconUrl = "http://www.clipartbest.com/cliparts/niE/yKR/niEyKRyoT.jpeg", iconWidth = 18, iconHeight = 18)

server <- function(input, output, session) {
  output$map <- renderLeaflet(leaflet() %>% setView(lng=13.5, lat=50.95, zoom=8) %>% addTiles() %>% addMarkers(lat=demo1_lat, lng=demo1_lng))
  
  for(i in 1:length(a)) {
    leafletProxy('map') %>% addMarkers(layerId=i, lat=a[[i]]$lat, lng=a[[i]]$lng, icon=square_green) %>% addPolylines(layerId=i, lat=a[[i]]$lat, lng=a[[i]]$lng, color="red")
  }
  
  observeEvent(input$map_marker_click, { 
    p <- input$map_marker_click
    output$name <- renderText({csv$Name[p$id]})
    output$ort <- renderText({csv$Ort[p$id]})
    output$betreiber <- renderText({csv$Betreiber[p$id]})
    output$dauer <- renderText({csv$Dauer.des.Bestehens[p$id]})
    output$belegung <- renderText({csv$H.ftlingsbelegung[p$id]})
    output$unterbringung <- renderText({csv$Unterbringung[p$id]})
    output$arbeiten <- renderText({csv$Art.der.Arbeiten[p$id]})
    output$todesopfer <- renderText({csv$Todesopfer[p$id]})
    output$rueckueberstellungen <- renderText({csv$R.ck.berstellungen[p$id]})
    output$fluchten <- renderText({csv$Fluchten[p$id]})
    output$zugaenge <- renderText({csv$Zug.nge.aus.anderen.Lagern[p$id]})
  })
  
  observeEvent(input$map_shape_click, { 
    p <- input$map_shape_click
    output$name <- renderText({csv$Name[p$id]})
    output$ort <- renderText({csv$Ort[p$id]})
    output$betreiber <- renderText({csv$Betreiber[p$id]})
    output$dauer <- renderText({csv$Dauer.des.Bestehens[p$id]})
    output$belegung <- renderText({csv$H.ftlingsbelegung[p$id]})
    output$unterbringung <- renderText({csv$Unterbringung[p$id]})
    output$arbeiten <- renderText({csv$Art.der.Arbeiten[p$id]})
    output$todesopfer <- renderText({csv$Todesopfer[p$id]})
    output$rueckueberstellungen <- renderText({csv$R.ck.berstellungen[p$id]})
    output$fluchten <- renderText({csv$Fluchten[p$id]})
    output$zugaenge <- renderText({csv$Zug.nge.aus.anderen.Lagern[p$id]})
  })
  
  observeEvent(input$time, {
    leafletProxy('map') %>% clearMarkers() %>% clearShapes()
    for(i in 1:length(a)) {
      if(a[[i]]$date >= input$time[1] & a[[i]]$date <=input$time[2]) {
        leafletProxy('map') %>% addMarkers(lat=a[[i]]$lat, lng=a[[i]]$lng) %>% addPolylines(lat=a[[i]]$lat, lng=a[[i]]$lng)
      }
    }
  }, ignoreInit = TRUE)
  
  observeEvent(input$center, {
    leafletProxy('map') %>% setView(lng=13.5, lat=50.95, zoom=8)
  }, ignoreInit = TRUE)
  
  observeEvent(input$osrm, {
    if(input$osrm) {
      leafletProxy('map') %>% clearShapes()
      for(i in 1:length(a)) {
        if(a[[i]]$date >= input$time[1] & a[[i]]$date <=input$time[2]) {
          for(x in 1:(length(a[[i]]$lat)-1)) {
            route <- osrmRoute(src=c(a[[i]]$lng[x], a[[i]]$lat[x]), dst=c(a[[i]]$lng[x+1], a[[i]]$lat[x+1]))
            leafletProxy('map') %>% addPolylines(route$lon,route$lat)
          }
        }
      }
    } else {
      leafletProxy('map') %>% clearShapes()
      for(i in 1:length(a)) {
        if(a[[i]]$date >= input$time[1] & a[[i]]$date <=input$time[2]) {
          leafletProxy('map') %>% addPolylines(lat=a[[i]]$lat, lng=a[[i]]$lng)
        }
      }
    }
  }, ignoreInit = TRUE)
}

shinyApp(ui, server)