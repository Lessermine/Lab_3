library('shiny')               # создание интерактивных приложений
library('lattice')             # графики lattice
library('data.table')          # работаем с объектами "таблица данных"
library('ggplot2')             # графики ggplot2
library('dplyr')               # трансформации данных
library('lubridate')           # работа с датами, ceiling_date()
library('zoo')                 # работа с датами, as.yearmon()

# функция, реализующая API (источник: UN COMTRADE)
source("https://raw.githubusercontent.com/aksyuk/R-data/master/API/comtrade_API.R")

# Получаем данные с UN COMTRADE за период 2010-2020 года, по следующим кодам
code = c('0701', '0702', '0703', '0704', '0705', '0706')
DF = data.frame()
for (i in code){
  for (j in 2010:2020){
    Sys.sleep(5)
    s1 <- get.Comtrade(r = 'all', p = 643,
                       ps = as.character(j), freq = "M",
                       cc = i, fmt = 'csv')
    DF <- rbind(DF, s1$data)
    print(paste("Код:", i, '; Год:', j))
  }
}

# Загружаем полученные данные в файл, чтобы не выгружать их в дальнейшем заново
file.name <- paste('./data/UN_COMTRADE.csv', sep = '')
write.csv(DF, file.name, row.names = FALSE)

write(paste('Файл',
            paste('UN_COMTRADE.csv', sep = ''),
            'загружен', Sys.time()), file = './data/download.log', append=TRUE)

DF <- read.csv('./data/UN_COMTRADE.csv')
DF <- DF[, c(2, 8, 10, 22, 30, 32)]
DF <- DF[!is.na(DF$Netweight..kg.) & !is.na(DF$Trade.Value..US..), ]
DF

file.name <- paste('./data/UN_COMTRADE_red.csv', sep = '')
write.csv(DF, file.name, row.names = FALSE)

# код товара
filter.code <- as.character(unique(DF$Commodity.Code))
names(filter.code) <- filter.code
filter.code <- as.list(filter.code)

# торговый поток
filter.trade.flow <- as.character(unique(DF$Trade.Flow))
names(filter.code) <- filter.trade.flow
filter.trade.flow <- as.list(filter.trade.flow)

DF <- read.csv('./data/UN_COMTRADE_red.csv', header = T, sep = ',')

# фильтруем данные
DF.filter <- DF[DF$Commodity.Code == filter.code[1] & DF$Trade.Flow == filter.trade.flow[1], ]
DF.filter

# график
ggplot(data = DF.filter, aes_string(x = DF.filter$Netweight..kg., y = DF.filter$Trade.Value..US..)) +
  geom_point() + xlab('Масса поставок') + ylab('Стоимость') +
  ggtitle('Зависимость массы поставки от ее стоимости') +
  geom_hline(aes(yintercept = median(Netweight..kg.)), color = 'red')


# Запуск приложения
runApp('./un_comtrade_app', launch.browser = TRUE,
       display.mode = 'showcase')
