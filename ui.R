library(shiny)

shinyUI(
  fluidPage(
    titlePanel("Developing Data Products - Coursera"),
    headerPanel("Ebola cases data"),
      sidebarLayout(
        sidebarPanel(
            "Interactive plot components:", uiOutput("countriesList"),
            radioButtons(inputId = "date_offset", label = "Data timeline scale:",
                         choices = c("Relative timeline"="relative", "Absolute timeline"="absolute")),
            radioButtons(inputId = "scale", label = "Y-axis type",
                         choices = c("Linear" = "lin", "Log10" = "log"))
            
        ),    
        mainPanel(
            p("This interactive graph plots the recorded ebola cases and fatal outcome cases
            (deaths) for all of the selected country. The timeline is normalized to the 
            relative outbreak date to allow an easier comparison. The Ebola cases data was taken from Caitlin River's Github repository accessible",
            a('here', href = 'https://github.com/cmrivers/ebola'),"."),
            
            p("Quick start guide: By default, all data for all countries is displayed. Use the 
            check-boxes to select specific countries. The radio-buttons may be use to select the plot
            timeline (X-axis) and the scale type (Y-axis). The relative time line provide an easy
            comparison of the magnitude of the outbreak. The log scale displays better the data with
            lower values."),
        
            
            plotOutput("plot")
        )
      )
  )
)
