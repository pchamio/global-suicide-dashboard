#load required packages
library(ggplot2)
library(shiny)
library(shinydashboard)
library(plotly)
library(ggthemes)
library(tmap)
library(RColorBrewer)
library(googleVis)




#ui component begins here
shinyUI(
  dashboardPage(
    
    skin='green',
    dashboardHeader(title = "World of suicide"),
    
    
    dashboardSidebar(
      sidebarMenu(
      menuItem("World map",tabName ="map" ,icon = icon("fas fa-arrow-down")),
      menuItem("Line chart",tabName ="line",icon = icon("fas fa-arrow-down")),
      menuItem("Bubble chart",tabName ="bubble",icon = icon("fas fa-arrow-down")))),
    
    
    dashboardBody(
      tabItems(
        tabItem(tabName = "bubble",
                h1("Rich VS Poor"),
                fluidRow(box(title="Bubble chart of GDP impact on suicide from 1985 to 2016",
                             starus="primary",
                             solidHeader=T,
                             plotlyOutput("plot1"),
                             width=90,height = 500))),
        
        tabItem(tabName = "line",
                h1("Trend of the world suicide"),    
                fluidRow(
                  box(plotlyOutput("plot2")),
                  box(title="Choose countries of interest",status = "warning",solidHeader = T,
                      selectizeInput("selectcountry",
                      label=NULL,
                      choices = unique(suicides_by_country$country),
                      multiple = TRUE,
                      options = list(maxItems = 20))))),
        
        tabItem(tabName = "map",
               h1("Timeline of the world suicide"),
              fluidRow(
                box(h3(textOutput("year")),htmlOutput("gvis"),width = 8,height=650),
                box(sliderInput("Year", label="Choose year to be displayed:", 
                                min = 1985,
                                max = 2016,
                                value=1985,
                                step=1,
                                format="###0",animate=TRUE))
              ))
        #tabItem(tabName = "map",
         #       h1("Timeline of the world suicide"),
          #      fluidPage(plotOutput("plot3",height="560px",width="950px")))
      ))

      
  )
)
