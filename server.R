#load required packages
library(ggplot2)
library(shiny)
library(shinydashboard)
library(plotly)
library(ggthemes)
library(tmap)
library(RColorBrewer)
library(manipulate)
library(googleVis)





#server component begins here
server<-function(input,output,session){
  
  
# output$plot3 <- renderPlot({
#    
#            colourPalette <- brewer.pal(5,'RdPu')
#            mapCountryData(countrydata, 
#                            nameColumnToPlot="suicides_per_100k",
#                            mapRegion = "world",
#                            mapTitle="", 
#                            colourPalette = colourPalette, 
#                            borderCol = "black",
#                            oceanCol="lightblue", 
#                            missingCountryCol="white", 
#                            catMethod = "pretty")
#   
    
#  })
  
  #output for map

  myYear <- reactive({
    input$Year
  })
  
  output$year<-renderText({
    paste("Suicide in", myYear())
  })
  
  output$gvis<-renderGvis({
    
    myData<-subset(suicides_by_country,
                   (year > (myYear()-1)) & (year < (myYear()+1)))
    gvisGeoChart(myData,
                 locationvar = "country_code",
                 colorvar = "suicides_per_100k",
                 hovervar = 'suicides_per_100k',
                 chartid = 'map',
                 options=list(height=500,width=900,
                              region='world',
                              dataMode='continent')
    )
    
    
  })
  
  
  #data_input<-reactive({ suicides_by_country %>%
  #  filter(year >= input$Year[1]) %>%
  #  filter(year <= input$Year[2])

  #})
  
  #data_input_ordered<-reactive({
  #  data_input()
  #})
  #DatasetInput<-reactive({
  #  myData<-subset(suicides_by_country,
  #                 (year > (myYear()-1)) & (year < (myYear()+1)),
  #                 select=c(country,suicides_per_100k,country_code,continent))
  #})
  #output$gvis<-renderGvis({
  #  data=DatasetInput
  #  map<-gvisGeoChart(DatasetInput,
  #                locationvar = "country_code",
  #                colorvar = "suicides_per_100k",
  #                hovervar = 'suicides_per_100k',
  #                chartid = 'map',
  #                options=list(height=500,width=900,dataMode='continent'))
  #  return(map)
  #  
  #})
  
  #myData<-reactive({
  #  myDataFilter<-suicides_by_country %>%
  #    filter(.,(year > (myYear()-1)) & (year < (myYear()+1)))
  #})
  

  
  #Output for line graph  
  output$plot2 <- renderPlotly({
    if (is.null(input$selectcountry)) 
      return(NULL)
    
    else {
      df <- suicides_by_country  %>%
        filter(country %in% input$selectcountry)
      
      plt <- ggplot(df,aes(x=year, y=suicides_per_100k, color=country)) +
        geom_line(aes(x=year, y=suicides_per_100k, by=country, color=country)) +
        geom_point()+
        labs(x = "Year") +
        labs(y = "Suicide rate") +
        labs(title = "Suicide rate for Countries") +
        scale_colour_hue("Countries",l=70, c=150) +
        theme_few()+
        theme(legend.direction = "horizontal", legend.position = "bottom")
       
      
      # Year range
      min_Year <- min(df$year)
      max_Year <- max(df$year)
      
      # use gg2list() to convert from ggplot->plotly
      gg <- gg2list(plt)
      

    }
  })
  #selection of line graph
  updateSelectizeInput(session,"selectcountry",choices = unique(suicides_by_country$country),server=TRUE,selected = "Australia")
  
  
  #output for bubble chart
  output$plot1<-renderPlotly({
    
    p<-ggplot(suicides_by_country,aes(x = suicides_per_100k, 
                                      y = gdp_per_capita,
                                      color = continent,
                                      size = population,
                                      frame = year,
                                      group = country
                                      ))+
      geom_point(aes(alpha = 1 - estimated*0.5)) +
      scale_x_log10() +    
      scale_alpha_continuous(range = c(0.4, 0.8)) + 
      xlab("suicide rate")+
      ylab("gdp per capita")+
      theme_minimal()
    
    ggplotly(p)#, tooltip = c('country', 'population', 'suicides rate', 'gdp per capita'))
    
  })

  
}