# This is the user-interface definition of a Shiny web application.

# Only load packages that are necessary for the user interface
library(shiny)
library(historydata)
library(leaflet)

# Define UI inside this function
shinyUI(fluidPage(

  # Application title
  titlePanel("Paulist Missions"),

  # fluidRow() and column() control the grid layout
  fluidRow(column(12,

      # A slider to control the year of the missions.
      # Notice that we set the input based on the values in our data.
      sliderInput("mission_year",
                  "Year",
                  min = min(paulist_missions$year),
                  max = max(paulist_missions$year),
                  value = min(paulist_missions$year),
                  animate = animationOptions(interval = 1000),
                  sep = ""),

      # A checkbox to determine whether to show Catholic dioceses
      checkboxInput("dioceses", "Show dioceses", value = FALSE)
    )),

    # The outputs will be defined in server.R
    fluidRow(
      column(6, plotOutput("confessions_vs_converts")),
      column(6, leafletOutput("paulist_map"))
    )
  )
)
