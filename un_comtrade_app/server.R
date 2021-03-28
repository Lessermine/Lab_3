library('shiny')
library('dplyr')
library('data.table')
library('RCurl')
library('ggplot2')
library('lattice')
library('zoo')
library('lubridate')

url.csv <- 'https://raw.githubusercontent.com/Lessermine/Lab_3/main/data/UN_COMTRADE_red.csv'

DF <- read.csv(url.csv)

DF <- data.table(DF)

shinyServer(function(input, output){
  DT <- reactive({
    DT <- DF[between(Year, input$year.range[1], input$year.range[2]) &
                     Commodity.Code == input$sp.to.plot &
                     Trade.Flow == input$trade.to.plot, ]
    DT <- data.table(DT)
  })
  output$sp.ggplot <- renderPlot({
    ggplot(data = DT(), aes(x = Netweight..kg., y = Trade.Value..US..)) +
      geom_point() + xlab('Масса поставок') + ylab('Стоимость') +
      ggtitle('Зависимость массы поставки от ее стоимости') +
      geom_hline(aes(yintercept = median(Netweight..kg.)), color = 'red')
  })
})