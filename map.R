library(shiny)
library(leaflet)

m <- leaflet()
m <- setView(m, lng=13.5, lat=50.95, zoom=8)
m <- addTiles(m)

lat = c(51.4047, 51.3848, 51.3244, 51.3145, 51.3012, 51.2882, 51.2749, 51.1253, 51.1130, 51.0843)
lng = c(14.2678, 14.2445, 14.1611, 14.1385, 14.1227, 14.1481, 14.1025, 14.1842, 13.9142, 14.0193)

df <- data.frame(lat, lng)

m <- addMarkers(m, data=df, lat=df$lat, lng=df$lng)
m <- addPolylines(m, data=df, lat=df$lat, lng=df$lng)

ui <- fluidPage(
  leafletOutput("map", width=800, height=800),
  sliderInput("time", "Time test", min=0, max=10, value=5)
)

server <- function(input, output, session) {
  output$map <- renderLeaflet(m)
}

shinyApp(ui, server)