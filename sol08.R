dbmetrics <- read.csv("sysmetric_history_PRD.csv", header=T)


summary(dbmetrics)
names(dbmetrics)

library(ggplot2)
ggplot(dbmetrics, aes( y=sqlrespt)) + geom_line()
summary(dbmetrics)
library(lubridate)
library(dplyr)

dbmetrics$TSEnd <- ymd_hms(dbmetrics["ENDTIME"])
head(dbmetrics)
dbmetrics %>% mutate( tsbegin = BEGINTIME ) %>% head
db2 <- dbmetrics %>% mutate( tsbegin = ymd_hms(BEGINTIME), tsend = ymd_hms(ENDTIME) )
head(dbmetrics) 
head(db2)

y<-ymd_hms("2018-06-03 02:01:20")
names(db2)
db2[1:3,"CUPSEC"]
df <- db2 %>% filter( tsbegin >= ymd_hms('2018-06-11 20:00:00'), tsend <= ymd_hms('2018-06-12 02:00:00') ) %>% select (tsbegin,CUPSEC,HOSTCUPSEC)
summary(df) 
head(df)
names(df)
db2 %>% select ( cupsec)
head(db2)
select (db2, cupsec)
str(db2)
ggplot2( db2, aes(x=CUPSEC)) + geom_histogram(binwidth=0.1)
ggplot( df, aes(x=CUPSEC)) + geom_histogram(binwidth=1)
summary(df)
