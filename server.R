##############################################################################
# Coursera Developing Data products class - Shiny project assignment.
#
# The server code sets up the R environment, get the ebola dataset and
# preprocess the data in order to be used and displayed interactively.
#
###############################################################################
# server.R

# load the libraries
options(warning = FALSE)
library(dplyr)
library(ggplot2)
library(foreign)
library(magrittr)
library(RColorBrewer)
library(RCurl)
library(reshape2)
library(scales)
library(shiny)
library(stringr)

#Get the ebola dataset at the specific url
url <- "https://raw.githubusercontent.com/cmrivers/ebola/master/country_timeseries.csv"
data <- getURL(url, ssl.verifypeer = FALSE)
#Form a dataframe from the *.csv file
df <- read.csv(textConnection(data))
#Remove the Date. We will align the recorded cases on a singe plot
df <- df[, !names(df) %in% c("Date")]
#Order the data by country alphabetically
dfo<-df[order(colnames(df))]
#Format the data to long table with day, type_place, ans cases counts
long <- na.omit(melt(dfo, id.vars = c("Day")))
#Split the data by type and place
long[, c("type", "place")] <- colsplit(long$variable, "_", c("type", "place"))
#Remove delimited col
long <- long[,-2] 
#Rename for the desired display on the plots
long$type[long$type == "Cases"] <- "Cases of positive tests"
long$type[long$type == "Deaths"] <- "Fatal outcome cases"
names(long)[1] <- "absolute.days"
names(long)[2] <- "count"

long <- long %>%
    group_by(place) %>%
    mutate(relative.days = absolute.days - min(absolute.days)) %>%
    mutate(count = as.numeric(count))
#Combine all data
all_data <- unique(long$place)
#Set the color theme
set_color <- brewer.pal(length(all_data), 'Set1')
names(set_color) <- all_data

theme_set(theme_minimal())
#initialise the server
shinyServer(function(input, output) {
  #setup the reactive plotwith radio buttons to provide Log plot view to emphasize the low count values 
  data_plot <- reactive({
      df_plot <- long
      selection <- input$countries
      if("All" %in% input$countries || length(input$countries) == 0)    selection <- all_data
      else    selection <- input$countries
      df_plot %>% filter(place %in% selection)
    })

    output$countriesList <- renderUI({
        checkboxGroupInput("countries", label = h3("Sellect data and display method"),
                           choices = all_data, selected = "All")
    })
    #radio button for linear plot view
    plot <- reactive({
        type = paste0(input$date_offset, ".days")
        linear_plot <- ggplot(data = data_plot(), aes_string(x = type, y = "count",
                                               group = "place", color = "place")) +
            geom_point() + geom_line() + facet_grid(~ type) +
            scale_x_continuous(name = "Days after first recorded case") +
            scale_y_continuous(name = "Number of recorded cases") +
            scale_colour_manual(name = "Country", values = set_color) +
            ggtitle("Documented cases after first positive test on record") +
          theme(panel.background = element_rect(colour = "blue")) +
          theme(panel.background = element_rect(fill = "lightblue")) +
          theme(axis.text = element_text(colour = "darkblue", face = "bold")) +
          theme(axis.title.y = element_text(size = 16, colour = "navy", face = "bold")) +
          theme(axis.title.x = element_text(size = 16, colour = "navy", face = "bold")) +
          theme(plot.title = element_text(size = 18, colour = "navy", face = "bold")) +
          theme(strip.background = element_rect(fill = "cornsilk", color = "blue", size = 14)) +
          theme(strip.text = element_text(face = "bold", size = 15, colour = "white")) +
          theme(legend.key = element_rect(fill = "lightblue"), 
                legend.background = element_rect(colour = "blue"),
                legend.background = element_rect(fill = "white")) +    
          theme(legend.text = element_text(size = 14, colour = "blue")) +
          theme(legend.title = element_text(size = 18, colour = "darkblue")) 
        
        if("lin" %in% input$scale){
            return(linear_plot)
        }
        #radio button to provide Log plot view to emphasize the low count values
        else{
            log_plot <- linear_plot + scale_y_continuous(trans = log10_trans()) +
                  scale_y_log10(name = "Number of recorded cases [log10]") +
                  ggtitle("Documented cases after first positive test on record")
            return(log_plot)
        }
    })
    #display
    output$plot <- renderPlot({
        print(plot())
    })
})
