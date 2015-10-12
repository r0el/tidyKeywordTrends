################################
## Loading libraries and data ##
################################

## Libraries
require(dplyr)
require(reshape2)
require(stringr)
require(lubridate)
require(data.table)
require(xlsx)

## Run this in case of error 'invalid multibyte string'
Sys.setlocale("LC_ALL", "C")

## Makes an index of the csv-files in the current working directory
files <- list.files(pattern="*.csv")
  
## Reads and combines the files in the index
data <- NULL
for(i in 1:length(files)) {
  assign(paste("data",i,sep=""),
         read.csv(files[i], sep="\t", header=TRUE, skipNul=TRUE)
  )
  data <- rbind(data,eval(as.name(paste("data",i,sep=""))))
}
  

##########################
## Create monthly data  ##
##########################

## This code transforms data from the Google Keyword Planner into a tidy dataframe
## data frame with three columns: keyword, date and volume

## returnDate extracts the date from the data and returns it properly formatted
returnDate <- function(var) {
  paste("01",
        str_extract(var,regex("\\..(.[a-z])\\.",perl=TRUE)),
        str_extract(var,regex("201.")),
        sep="") %>% strptime("%d.%b.%Y") %>% as.Date(fomat="%Y-%m-%d")
}

## Melt all data along the keyword column
datalong <- data %>% melt(id=c("Keyword"))
    
## Convert the data to a data.table for quick manipulation
dt <- as.data.table(datalong)
    
## Extracts the date out of the data and puts it in the date column
## using the returnDate function.
dt[grepl("jan",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("feb",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("mar",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("apr",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("may",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("jun",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("jul",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("aug",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("sep",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("oct",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("nov",variable, ignore.case=TRUE),date:=returnDate(variable)]
dt[grepl("dec",variable, ignore.case=TRUE),date:=returnDate(variable)]
    
## Cleans up empty cells, non-keywords, NA's, etc.
monthlydata <- dt[nchar(as.character(Keyword))>0 & !is.na(value) & nchar(value)<8 & !is.na(date)] 
    
## Groups the data by keyword and date and displays volume
monthlydata <- monthlydata %>% 
      as.data.frame %>% 
      group_by(Keyword,date) %>%
      summarize(volume=sum(as.integer(value))) %>%
      select(Keyword,volume,date)
  
################################################
## Extrapolate volume data for missing months ##
################################################

## During the first days of the month, Google does not provide keyword
## data for the previous month. This code extrapolates the volumes
## by calculating the avarage for the months before and after the
## missing month

if(length(unique(monthlydata$date))<12) {
    
  ## Determine the earliest date, latest date without data and latest 
  ## date with data.
  min <- min(monthlydata$date)
  max <- max(monthlydata$date)
  target <- max(monthlydata$date)+months(1)
    
  ## Calculates the mean of the months before and after the missing month
  ## for every keyword
  temp <- monthlydata %>% 
    filter(date==min | date==max) %>% 
    group_by(Keyword) %>% 
    summarize(volume=mean(volume)) %>% 
    mutate(date=as.Date(target))
    
  ## Creates a subset of the monthly data without the month with
  ## missing volumes in order to join it with the calculated data
  mdata <- monthlydata %>%
    filter(date!=target)
    
  ## Joins the data frames and makes sure the data column is well
  ## properly formatted
  monthlydata <- full_join(mdata,temp)
  monthlydata$date <- as.Date(monthlydata$date)
    
}
  
############################
## Create quarterly data  ##
############################

## Exports the monthlydata to csv, and imports that csv again.   
## This is a dirty hack to prevent errors due to corrupt data frames.
write.csv(monthlydata,"temp.csv", quote=FALSE, row.names=FALSE)
trend <- read.csv("temp.csv",header=TRUE)

## Converts the data frame to a data table for quick manipulation
dt2 <- as.data.table(trend)
    
## Creates a new column - monthflat - with an integer for the month
dt2[,monthflat:=month(date)]
    
## Deducts the quarter from the integer in monthflat and writes 
## corresponding quarter in collumn Q
dt2[monthflat==1:3,Q:="Q1"]
dt2[monthflat==4:6,Q:="Q2"]
dt2[monthflat==7:9,Q:="Q3"]
dt2[monthflat==10:12,Q:="Q4"]
    
## Transforms data into a data frame with quarterly volume for every keyword
qdata <- dt2 %>%
  as.data.frame %>%
  select(Keyword, volume, Q) %>%
  group_by(Keyword,Q) %>% 
  summarise(volume=sum(volume,na.rm=TRUE))
  
####################################
## Exports the data as csv-files  ##
####################################
  
if(exists("qdata")){
  write.csv(qdata, file="quarterly.csv")
}
  
if(exists("monthlydata")){
  write.csv(monthlydata, file="monthly")
}