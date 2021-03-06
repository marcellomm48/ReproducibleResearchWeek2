#extracts data from csv
rawdata <- read.csv("activity.csv")

#Group by date and then summarize by total steps taken
library(dplyr)
stepsPerDay <- group_by(rawdata, date) %>% 
               summarise("stepsDay" = sum(steps, na.rm = TRUE))

#graphs histogram of steps per day
hist(stepsPerDay$stepsDay, 
     breaks = 50, 
     xlab = "Steps per Day", 
     main = "Histogram: Frequency of Steps per Day")

#calculates and then prints the Mean and Median of steps per day over timeframe
summarise(stepsPerDay, "Mean Steps per Day" = mean(stepsDay), 
                      "Median Steps per Day" = median(stepsDay))
   
#Make a time series plot
##5-min interval (x-axis) vs avg # steps taken across all days (y-axis)
stepsPerInterval <- group_by(rawdata, interval) %>% 
                     summarise("stepsInterval" = mean(steps, na.rm = TRUE))

plot(data = stepsPerInterval, 
     stepsInterval ~ interval, 
     type = "l")

stepsPerInterval[stepsPerInterval$stepsInterval == max(stepsPerInterval$stepsInterval), ]


#count NA's------------------Post NA work------------------------------------------------
nrow(rawdata[is.na(rawdata$steps) == TRUE, ]) / nrow(rawdata)

imputedata <- rawdata

#substitute all NA for the steps of average overall days of the given interval
for(i in 1:nrow(rawdata)){
   if(is.na(rawdata$steps[i])) {
      imputedata$steps[i] <- 
               stepsPerInterval[stepsPerInterval$interval == rawdata[i, 'interval'], 
                                'stepsInterval']
   }
}

imputedata$steps <- as.vector(unlist(imputedata$steps))

#same calcs different data set
stepsPerDay2 <- group_by(imputedata, date) %>% 
                  summarise("stepsDay" = sum(steps))

hist(stepsPerDay2$stepsDay, 
     breaks = 50, 
     xlab = "Steps per Day", 
     main = "Histogram: Frequency of Steps per Day")

summarise(stepsPerDay2, "Mean Steps per Day" = mean(stepsDay), 
          "Median Steps per Day" = median(stepsDay))

imputedata <- mutate(imputedata, "dayofweek" = ifelse(
   weekdays(as.Date(date)) == "Saturday" | weekdays(as.Date(date)) == "Sunday",
   "Weekend",
   "Weekday"))

imputedata$dayofweek <- as.factor(imputedata$dayofweek)

stepsPerInterval2 <- group_by(imputedata, interval, dayofweek) %>% summarise("stepsInterval" = mean(steps))

par(mfrow = c(2, 1))
for (i in levels(stepsPerInterval2$dayofweek)){
            plot(as.matrix(stepsPerInterval2[stepsPerInterval2$dayofweek == i, 3]) 
                 ~ as.matrix(stepsPerInterval2[stepsPerInterval2$dayofweek == i, 1]),
                 type = "l",
                 main = i,
                 xlab = "Interval",
                 ylab = "Avg Steps",
                 ylim = c(1,225))
}
