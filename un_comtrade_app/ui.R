library('shiny')
library('RCurl')

url.csv <- 'https://raw.githubusercontent.com/Lessermine/Lab_3/main/data/UN_COMTRADE_red.csv'

DF <- read.csv(url.csv)

# Торговые потоки, переменная для фильтра фрейма
filter.trade.flow <- as.character(unique(DF$Trade.Flow))
names(filter.trade.flow) <- filter.trade.flow
filter.trade.flow <- as.list(filter.trade.flow)

shinyUI(
  pageWithSidebar(
    headerPanel("График разброса массы поставок в зависимости от ее стоимости"),
    sidebarPanel(
      # Выбор кода продукции
      selectInput('sp.to.plot',
                  'Код товара',
                  list('Картофель' = '701',
                       'Томаты' = '702',
                       'Лук, лук-шалот, чеснок, лук-порей и др.' = '703',
                       'Капуста, цветная капуста, кольраби, капуста и др.' = '704',
                       'Салат и цикорий' = '705',
                       'морковь, турнепс, свекла, сельдерей, редис и т.д.' = '706'),
                  selected = '701'),
      # Товарный поток
      selectInput('trade.to.plot',
                  'Выберите торговый поток:',
                  filter.trade.flow),
      # Период, по годам
      sliderInput('year.range', 'Года:',
                  min = 2010, max = 2020, value = c(2010, 2020),
                  width = '100%', sep = '')
    ),
    mainPanel(
      plotOutput('sp.ggplot')
    )
  )
)