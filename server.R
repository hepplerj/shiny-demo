# This file maps the list of inputs defined in ui.R to the outputs defined in
# ui.R

# Anything here will be loaded one time for all users of the application.
# Load any packages or data here, and define any helper functions.

library(shiny)
library(dplyr)
library(leaflet)
library(ggplot2)
library(lubridate)

# Normally we would load the data from some external file, but in this case
# we are getting it from a package.
library(historydata)

# This is a helper function that turns a number of confessions in the Paulist
# data into a suitable radius for a marker on a map
value_to_radius <- function(x, multiplier = 2000) {
  out <- scales::rescale(sqrt(x),
                  to = c(0, 1),
                  from = c(0, max(paulist_missions$confessions, na.rm = TRUE)))
  out * multiplier
}

# The logic for the server goes inside this function
shinyServer(function(input, output, session) {

  # We can define a "reactive" based on one of the inputs. This is like defining
  # a function which returns a value based on one of the inputs. It will be
  # updated whenever the inputs are updated. Notice that we access the inputs
  # as a list: `input$mission_year`
  #
  # Get a data frame of the Paulist Missions for a single year
  filtered_missions <- reactive({
    paulist_missions %>%
      filter(year == input$mission_year)
  })

  # Get the Catholic dioceses that were founded in that year or before
  filtered_dioceses <- reactive({
    catholic_dioceses %>%
      filter(year(date) <= input$mission_year, event == "erected")
  })

  # Create a ggplot object. Because it depents on the `filtered_mission()`
  # reactive, it will be updated whenever that is updated, and
  # `filtered_missions()` will be updated whenever `input$mission_year` is
  # updated.
  output$confessions_vs_converts <- renderPlot({
    # We get the data frame from the `filtered_missions()` reactive
    df <- filtered_missions()
    ggplot(df, aes(x = confessions, y = converts)) +
    geom_point() +
    labs(title = paste0("Paulist missions for ", input$mission_year)) +
    theme_minimal()
  })

  # Define a Leaflet map based on `filtered_missions()`. Note that we save the
  # map to the correct slot in the output list: `output$paulist_map`
  output$paulist_map <- renderLeaflet({
    df <- filtered_missions()
    map <- leaflet(df) %>%
      addTiles() %>%
      addCircleMarkers(radius = ~value_to_radius(confessions),
                       lat = ~lat, lng = ~long,
                       popup = ~paste0(church, ", ", city, ", ", state))

    # If the `input$dioceses` checkbox is checked (i.e., TRUE) then add markers
    # for the `filtered_dioceses()`
    if (input$dioceses) {
      map <- map %>%
        addMarkers(data = filtered_dioceses(), popup = ~diocese,
                   lat = ~lat, lng = ~long)
    }

    # Note that we have to return an object, just like when defining a function
    map

  })

  # A better way to do the Leaflet map
  # output$paulist_map <- renderLeaflet({
  #   leaflet(paulist_missions) %>%
  #     addTiles() %>%
  #     fitBounds(~min(long), ~min(lat), ~max(long), ~max(lat))
  # })
  #
  # observe({
  #   df <- filtered_missions()
  #
  #   leafletProxy("paulist_map", data = df) %>%
  #     clearMarkers()
  #
  #   if (nrow(df) > 0) {
  #     leafletProxy("paulist_map", data = df) %>%
  #       addCircleMarkers(radius = ~value_to_radius(confessions),
  #                  lat = ~lat, lng = ~long,
  #                  popup = ~paste0(church, ", ", city, ", ", state))
  #   }
  #
  #   if (input$dioceses) {
  #     leafletProxy("paulist_map", data = df) %>%
  #       addMarkers(data = filtered_dioceses(), popup = ~diocese,
  #                  lat = ~lat, lng = ~long)
  #   }
  #
  # })


})
