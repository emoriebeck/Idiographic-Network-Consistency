library(MASS);library(plyr);library(prettyR);library(memisc);library(foreign)
library(car);library(data.table);library(psych)
library(tidyr);library(xlsx);library(stringr);library(lubridate)

# set working directory #
setwd("~/Desktop/PAIRS/ESM wave 4")
# load data #
d.1 <- read.csv("esm_RENAMED_NOTCLEAN_w4.csv", stringsAsFactors = F)
head(d.1)

d.1$esm.startDateTime.w4.pos <- format(as.POSIXct(strptime(d.1$esm.startDateTime.w4,"%m/%d/%y %H:%M",tz="")) ,format = "%m/%d/%Y %H:%M")
d.1$esm.endDateTime.w4.pos <- format(as.POSIXct(strptime(d.1$esm.endDateTime.w4,"%m/%d/%y %H:%M",tz="")) ,format = "%m/%d/%Y %H:%M")

# seperate the dates and the times #
d.1$esm.startDate.w4 <- as.Date(d.1$esm.startDateTime.w4, format = "%m/%d/%y %H:%M")
d.1$esm.startTime.w4 <- format(as.POSIXct(strptime(d.1$esm.startDateTime.w4,"%m/%d/%y %H:%M",tz="")) ,format = "%H:%M")
d.1$esm.endTime.w4 <- format(as.POSIXct(strptime(d.1$esm.endDateTime.w4,"%m/%d/%y %H:%M",tz="")) ,format = "%H:%M")
d.1$esm.endDate.w4 <- as.Date(d.1$esm.endDateTime.w4, format = "%m/%d/%y %H:%M")

# create day of the week variable #
# get text of days of the week #
d.1$startday.text.w4 <- weekdays(d.1$esm.startDate.w4)
d.1$endday.text.w4 <- weekdays(d.1$esm.endDate.w4)

# recode text days into numeric days #
# create PRO06 (endtime) and version of PRO06 for the starttime #
d.1$esm.startPRO06.w4 <- recode(d.1$startday.text.w4, "'Monday'= 1; 'Tuesday' = 2; 'Wednesday' = 3; 
       'Thursday' = 4; 'Friday' = 5; 'Saturday' = 6; 'Sunday' = 7")
d.1$esm.PRO06.w4 <- recode(d.1$endday.text.w4, "'Monday'= 1; 'Tuesday' = 2; 'Wednesday' = 3; 
       'Thursday' = 4; 'Friday' = 5; 'Saturday' = 6; 'Sunday' = 7")
# recode PRO06 and startPRO06 into start/PRO07 (weekend variable) #
d.1$esm.PRO07.w4 <- recode(d.1$esm.PRO06.w4, "c(1,2,3,4,5) = 0; c(6,7) = 1")
d.1$esm.startPRO07.w4 <- recode(d.1$esm.startPRO06.w4, "c(1,2,3,4,5) = 0; c(6,7) = 1")

# make time numeric (e.g. 10:30 = 1030 or 18:55 = 1855)
d.1$esm.startTime.w4.num <- as.numeric(gsub(":", "", d.1$esm.startTime.w4))
d.1$esm.endTime.w4.num <- as.numeric(gsub(":", "", d.1$esm.endTime.w4))

# recode practice items to the nearest hour block #
d.1$esm.PRO03.w4 <- d.1$esm.PRO02.w4
d.1$esm.PRO03.w4[which(d.1$esm.PRO02.w4 == 5)] <- 
       ifelse(d.1$esm.startTime.w4.num[which(d.1$esm.PRO02.w4 == 5)] <= 1330,1, # 12 PM block
       ifelse(d.1$esm.startTime.w4.num[which(d.1$esm.PRO02.w4 == 5)] <= 1630,2, # 3 PM block
       ifelse(d.1$esm.startTime.w4.num[which(d.1$esm.PRO02.w4 == 5)] <= 1930,3, # 6 PM block
       ifelse(d.1$esm.startTime.w4.num[which(d.1$esm.PRO02.w4 == 5)] <= 2400,4, NA)))) # 9 PM block


##########################################
########### exclusion criteria ###########
##########################################

# completed > 3 hours after sent #
# create variable with latest time of completion for each hour block #
# because of how R stores time, dates are also included for later comparison to completion times #
d.1$esm.maxDateTime.w4 <- 
  lubridate::ymd_hm(with(d.1, ifelse(esm.PRO02.w4 == 1, paste(esm.startDate.w4,"15:00", sep = " "),
                   ifelse(esm.PRO02.w4 == 2, paste(esm.startDate.w4,"18:00", sep = " "),  
                   ifelse(esm.PRO02.w4 == 3, paste(esm.startDate.w4,"21:00", sep = " "), 
                   ifelse(esm.PRO02.w4 == 4, paste((esm.startDate.w4 + 1),"00:00", sep = " "),NA))))))
# reformat date as POSIXct #
d.1$esm.startDateTime.w4.pos <- ymd_hm(with(d.1,paste(esm.startDate.w4, esm.startTime.w4, sep = " ")))

# Subtract actual start time from max time #
d.1$time.exceeded <- NA
d.1$time.exceeded[which(d.1$esm.PRO02.w4 == 1 & 
                       (d.1$esm.startTime.w4.num < 1200 | d.1$esm.startTime.w4.num >= 1500))] <- 1
d.1$time.exceeded[which(d.1$esm.PRO02.w4 == 2 & 
                       (d.1$esm.startTime.w4.num < 1500 | d.1$esm.startTime.w4.num >= 1800))] <- 1
d.1$time.exceeded[which(d.1$esm.PRO02.w4 == 3 & 
                       (d.1$esm.startTime.w4.num < 1800 | d.1$esm.startTime.w4.num >= 2100))] <- 1
d.1$time.exceeded[which(d.1$esm.PRO02.w4 == 4 & 
                        d.1$esm.startTime.w4.num < 2100)] <- 1

#depracated code
#d.1$time.exceeded[which(d.1$esm.maxDateTime.w4 - d.1$esm.startDateTime.w4.pos < 0)] <- 1 


# participant sleeping during hour block before completion #
d.1$esm.OR.w4 <- as.character(d.1$esm.OR.w4)
d.1$esm.OR.w4[3116] <- 1 # response did not convert
d.1$esm.SL.w4[which(grepl("sleep", as.character(d.1$esm.OR.w4)) == T|
                  grepl("nap", as.character(d.1$esm.OR.w4)) == T|
                  grepl("bed", as.character(d.1$esm.OR.w4)) == T)] <- 1 # 1 = invalid response to be excluded

# < 75% of survey completed #
# create empty variable #
d.1$incomplete <- NA
# count NA values in original 66 columns #
# create proportion completed, skipping esm.SL.w4 because it is NA for all subjects #
d.1$incomplete[which((rowSums(is.na(d.1[8:24,26:50]))/17) > .25)] <- 1 # 1 = invalid response to be excluded

# >= 70% of responses identical #
ident.fun <- function(x) {
  tab <- t(table(t(x))) # counts number of responses for each value (0-5)
  perc <- tab/sum(tab) # divide number of responses for each value by total responses
  ifelse(sum(perc > .7) == 1, 1, NA) # code rows with 70% or more identical responses as 1 (invalid)
}

d.1$identical.resp <- apply(d.1[,c(8:24,26:50, 53:64)], 1, ident.fun)

# find and change or remove invalid subject IDs #
# fix subject IDs that accidentally included letters #
d.1$esm.IDnum.w4 <- gsub("b", "", d.1$esm.IDnum.w4)
d.1$esm.IDnum.w4 <- gsub("B", "", d.1$esm.IDnum.w4)
d.1$esm.IDnum.w4 <- gsub("c", "", d.1$esm.IDnum.w4)
# remove subjects who entered names or character strings #
d.1 <- d.1[d.1$esm.IDnum.w4 != "Anonymous" &
           d.1$esm.IDnum.w4 != "" &
           d.1$esm.IDnum.w4 != "Lindsey" &
           d.1$esm.IDnum.w4 != "Mihelle",]
# convert to numeric #
d.1$esm.IDnum.w4 <- as.numeric(d.1$esm.IDnum.w4)
# remove subjects whose IDs don't fit the ID conventions #
d.1 <- d.1[d.1$esm.IDnum.w4 < 11000,]

# create variable indicating valid responses #
d.1$valid <- 0
d.1$valid[which(d.1$time.exceeded == 1 |
                d.1$esm.SL.w4 == 1 |
                d.1$incomplete == 1 |
                d.1$identical.resp == 1)] <- 1
#remove, but don't delete! invalid responses
d.1.inval <- d.1[d.1$valid == 1,]
d.2 <- d.1[d.1$valid == 0,]

# create frequency variable (PRO01) #
data.frame(table(d.2$esm.IDnum.w4))
freq <- data.frame(table(d.1$esm.IDnum.w4))
head(freq)
freq <- freq[which(freq$Freq > 5),]

# create session variable (1-60; PRO05) #
# sort by subject, date, and time (#
d.2 <- d.2[order(d.2$esm.IDnum.w4,d.2$esm.startDate.w4,d.2$esm.startTime.w4),]
d.2$esm.PRO05.w4 <- NA
d.2$esm.PRO04.w4 <- NA
# write short loop for session variable. #
# will probably replace this with a plyr function later #
# looping through for each individual subject by ID #
triggers <- 0
for (i in unique(d.2$esm.IDnum.w4)){
  # create object for first day for participant #
  first.day <- 
    min(d.2$esm.startDate.w4[which(d.2$esm.IDnum.w4 == i)], na.rm = T)
  # create object for the total days elapsed between first and last surveys #
  total.days <- as.numeric(max(d.2$esm.startDate.w4[which(d.2$esm.IDnum.w4 == i)], na.rm = T) - 
                           first.day)
  # looping through each potential day in the study for participant i #
  k <- 1
  while (k <= total.days+1){
    theday <- first.day + k - 1
    if(theday %in% d.2$esm.startDate.w4[which(d.2$esm.IDnum.w4 == i)]){
    d.2$esm.PRO04.w4[which(d.2$esm.IDnum.w4 == i & d.2$esm.startDate.w4 == theday)] <- k
    }
    k <- k + 1
  }
  # esm.PRO05.w4 is the session variable #
  # value is assigned based on the following formula: #
  # 4 * day of study - (4 - hour block of study) #
  # figure out first full day of study #
  # if practice survey was taken before 1st hour block, then first session #
  # is coded as session 0; otherwise, it is simply coded at the nearest hour block #
  # So first, we find the date of the first full day of the study that didn't #
  # include the practice survey. If the practice survey was taken on the first full day #
  # then we code it as 0. #
  d.2$esm.PRO05.w4[which(d.2$esm.IDnum.w4 == i)] <- 
    (4*d.2$esm.PRO04.w4[which(d.2$esm.IDnum.w4 == i)] - 
       (4 - d.2$esm.PRO03.w4[which(d.2$esm.IDnum.w4 == i)]))
  first.full.day <- 
    min(d.2$esm.startDate.w4[which(d.2$esm.IDnum.w4 == i & 
                                     d.2$esm.PRO02.w4 != 5 )], na.rm = T)
  if (first.full.day == first.day &
      "5" %in% d.2$esm.PRO02.w4[which(d.2$esm.IDnum.w4 == i & 
                                      d.2$esm.startDate.w4 == first.full.day)]){
    d.2$esm.PRO05.w4[which(d.2$esm.IDnum.w4 == i &
                           d.2$esm.PRO02.w4 == 5 &
                           d.2$esm.PRO03.w4 == 1 &
                           d.2$esm.startTime.w4.num < 1200 &
                           d.2$esm.endTime.w4.num < 1500)] <- 0
  }
}

# identify participants who received surveys beyond 15 days and save them to a different df #
d.2.addl <- d.2[which(d.2$esm.PRO04.w4 > 15),]
# remove additional responses and unnecessary columns #
d.3 <- d.2[which(d.2$esm.PRO04.w4 <= 15),-c(1,70,71,82:83, 85:89)]

# create PRO01 (frequency) #
freq <- as.data.frame(table(d.3$esm.IDnum.w4))
colnames(freq) <- c("esm.IDnum.w4","esm.PRO01.w4")
d.4 <- merge(d.3, freq, by = "esm.IDnum.w4")

refcols <- c(colnames(d.4[,1:3]),paste("esm.PRO0",1:7,".w4", sep = ""))
d.5 <- d.4[,c(refcols,setdiff(names(d.4), refcols))]

# 
# # move PRO columns to the front #
# moveMe <- function(data, tomove, where = "last", ba = NULL) {
#   temp <- setdiff(names(data), tomove)
#   x <- switch(
#     where,
#     first = data[c(tomove, temp)],
#     last = data[c(temp, tomove)],
#     before = {
#       if (is.null(ba)) stop("must specify ba column")
#       if (length(ba) > 1) stop("ba must be a single character string")
#       data[append(temp, values = tomove, after = (match(ba, temp)-1))]
#     },
#     after = {
#       if (is.null(ba)) stop("must specify ba column")
#       if (length(ba) > 1) stop("ba must be a single character string")
#       data[append(temp, values = tomove, after = (match(ba, temp)))]
#     })
#   x
# }  
# 
# d.5 <- moveMe(d.4, "esm.PRO01.w4", where = "before", ba = "esm.PRO02.w4")
# d.6 <- moveMe(d.5, c("esm.PRO03.w4","esm.PRO04.w4","esm.PRO05.w4","esm.PRO06.w4","esm.PRO07.w4"), where = "before", ba = "esm.SL.w4")

# save resulting final dataset to a .csv #
write.csv(d.5, "esm_w4_RENAMED_v9.csv", row.names = F)

