library(gstat)
library(sp)
library(spacetime)
library(raster)
library(rgdal)
library(rgeos)

print('read data')
train_data <- read.table("../splitupdata/split_0/train_features.csv", sep=",", header=T)
train_label <- read.table("../splitupdata/split_0/train_labels.csv", sep=",", header=T)
train_data$Car <- train_label$Car
train_data$gentime <- as.POSIXlt(paste("2019-02-16 ",(paste(train_data$Time))),tz="CEST")

#Create a SpatialPointsDataFrame
coordinates(train_data)=~Longitude+Latitude
projection(train_data)=CRS("+init=epsg:4326")
print('Mercator projection')
#Transform into Mercator Projection
vehicles.UTM <- spTransform(train_data,CRS("+init=epsg:3395"))

# Dataframes for STIDF
vehiclesSP <- SpatialPoints(vehicles.UTM@coords,CRS("+init=epsg:3395"))
vehiclesTM <- as.POSIXct(vehicles.UTM$gentime,tz="CET")
vehiclesDF <- data.frame(Cars=vehicles.UTM$Car)
print('create STIDF')
# Merge
timeDF <- STIDF(vehiclesSP,vehiclesTM,data=vehiclesDF) 
print('creating variogram')
# Variogram
var <- variogramST(Cars~1,data=timeDF,tunit="mins",tlags=5*(0:72),assumeRegular=F,na.omit=T)
print('done')
# Save the data
save.image(file="var_car.RData")