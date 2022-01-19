library(shiny)
library(leaflet)

m <- leaflet()
m <- setView(m, lng=13.5, lat=50.95, zoom=8)
m <- addTiles(m)

m <- addMarkers(m, lng=12.387530, lat=51.202301)

ui <- fluidPage(
  leafletOutput("map", width=800, height=800),
  sliderInput("time", "Time test", min=0, max=10, value=5)
)

server <- function(input, output, session) {
  output$map <- renderLeaflet(m)
}

shinyApp(ui, server)