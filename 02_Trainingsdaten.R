library(terra)
library(geodata)
library(dplyr)
library(sf)
library(mapview)
library(sp)
library(raster)
#install.packages("rgeos")
library(rgeos)
library(caret)
#install.packages("spatstat")
library(spatstat)

setwd("C:/Users/g_all/OneDrive/Dokumente/Fernerkundung/Projekt SOse23/Datengrundlage")





############################################################################################
## Prädiktoren einladen #########################################################################

#Geländedaten
dem_fin <- rast( "dem_fin.tif")
slope_fin <- rast( "slope_fin.tif")
aspect_fin <- rast( "aspect_fin.tif")
twi <- rast("TWI_PNV.tif")

#Klimadaten
clim_h_fin <- rast( "clim_h_fin.tif")
clim_f_fin <- rast( "clim_f_fin.tif")

#Bodendaten


#Groundtruth
veg_geb <- st_read("veg_geb.shp")
pnv <- st_read("pnv_pro.shp")

#Umriss
D_waelder <- rast("D_waelder.tif")

#Flüsse
fldist <- rast("fldist.tif")
fldist <- mask(fldist, D_waelder)
#writeRaster(fldist,"fldist1.tif")
fldist <- rast("fldist1.tif")


veg_rast <- rasterize(veg_geb, D_waelder, field="Veggeb")
vegID_rast <- rasterize(veg_geb, D_waelder, field="OBJECTID")
#writeRaster(veg_rast, "veg_rast.tif")
veg_rast <- rast("veg_rast.tif")

veg_waelder <- crop(veg_rast, D_waelder)
veg_waelder <- mask(veg_waelder, D_waelder)

plot(veg_waelder)
writeRaster(veg_waelder, "veg_waelder.tif")

#######################################################################################################################
############### Predstack #############################################################################################

predstack <- rast(c("dem_fin.tif",
                            "slope_fin.tif",
                            "aspect_fin.tif",
                            "TWI_PNV.tif",
                            "clim_h_fin.tif",
                            "fldist1.tif",
                            "soilN.tif",
                            "soc.tif",
                            "sand.tif",
                            "clay.tif",
                            "pH.tif",
                            "cec.tif"))


values(predstack)
predstack$veg
#########################################################################################################
########### umbennenen und Veg. einheiten hinzufügen ###################################################

predstack$veg <- veg_rast
predstack$vegID <- vegID_rast
names(predstack)

new_names <- c("dem","slope","aspect","twi","bio1","bio2","bio3","bio4","bio5","bio6","bio7",
               "bio8","bio9","bio10","bio11","bio12","bio13","bio14","bio15","bio16","bio17","bio18",
               "bio19","dist","soilN","soc","sand","clay","pH","cec","veg","vegID")

names(predstack) <- new_names

names(predstack)

writeRaster(predstack, "predstack.tif", overwrite=TRUE)

predstack <- rast("predstack.tif")

predstack


#trainDat <- as.data.frame(predstack)

###############################################################################################################
#### Koordinaten ziehen: ######################################################################################


coords<- spatSample(D_waelder, 50000, method="random", replace=F, na.rm=T, as.df=T, values=F, xy=T)
write.table(coords, file="coords.csv", sep=";", col.names = T, row.names = T)
coords<-read.csv2("coords.csv", sep=";", header=T)

trainDat <- extract(predstack, coords)
trainDat$veg <- as.character(trainDat$veg)


#################################################################################################################################
##### Ab hier Skript verwenden#############################################################################################################

trainDat <- readRDS("Trainingsdaten.rds")
trainDat <- na.omit(trainDat)

saveRDS(trainDat, file="Trainingsdaten.rds")
trainDat1 <- readRDS("Trainingsdaten.rds")

trainDat$veg <- as.character(trainDat$veg)
trainDat
table(trainDat$veg)




predictors <- c("dem","slope", "aspect", "twi", "bio1","bio2","bio3","bio4",
                "bio5","bio6","bio7","bio8", "bio9","bio10","bio11","bio12",
                "bio13","bio14","bio15","bio16", "bio17","bio18","bio19","dist",
                "soilN","soc","sand","clay","pH","cec")



model <- train(trainDat[,predictors], 
               trainDat$veg, 
               method= "rf",
               ntree=50, tuneLength = 10) #kreuzvalidierung mit rein und ntree höher
model


saveRDS(model,file="RFModel_ntree50.RDS")
saveRDS(model,file="RFModel_ntree100.RDS")
saveRDS(model,file="RFModel.RDS")

model <- readRDS("RFModel.rds")
model50 <- readRDS("RFModel_ntree50.RDS")
model100 <- readRDS("RFModel_ntree100.RDS")



####################################################################################################
############## Zukunfts Daten downloaden #########################################################

clim_future <- rast("Worldclim_future.tif")

crs(clim_future)
clim_f_pro <- project(clim_future, D_waelder)
clim_f_pro <- project(clim_future, "3035")
clim_f_pro <- mask(clim_f_pro,D_waelder)


crs(clim_f_pro)
plot(clim_f_pro)

clim_h_fin<- rast("clim_h_fin.tif")
crs(clim_h_fin)


###########################################################################################################################
#### Zukunfts Klimadaten Predstack erstellen ########################################################################################
clim_f_pro <- rast("clim_f_pro.tif")

names(clim_f_pro)

# Die aktuellen Spaltennamen (entsprechend Ihren "lyr" Namen) abrufen
current_colnames <- names(clim_f_pro)

# Erstellen die neuen Namen mit der gewünschten Struktur
new_names <- paste0("bio", 1:19)

# Ändern die Spaltennamen im SpatialRaster
names(clim_f_pro) <- new_names

# Überprüfen die neuen Spaltennamen
names(clim_f_fin)
#writeRaster(clim_f_pro, "clim_f_pro.tif",overwrite=TRUE)
clim_f_pro <- rast(clim_f_pro,"clim_f_pro.tif")

predstack_future <- rast(c("dem_fin.tif",
                           "slope_fin.tif",
                           "aspect_fin.tif",
                           "TWI_PNV.tif",
                           "clim_f_pro.tif",
                           "fldist1.tif",
                           "soilN.tif",
                           "soc.tif",
                           "sand.tif",
                           "clay.tif",
                           "pH.tif",
                           "cec.tif"))

predstack_future$veg <- veg_rast
predstack_future$vegID <- vegID_rast
names(predstack_future)

new_names <- c("dem","slope","aspect","twi","bio1","bio2","bio3","bio4","bio5","bio6","bio7",
               "bio8","bio9","bio10","bio11","bio12","bio13","bio14","bio15","bio16","bio17","bio18",
               "bio19","dist","soilN","soc","sand","clay","pH","cec","veg","vegID")

names(predstack_future) <- new_names

names(predstack_future)

writeRaster(predstack_future, "predstack_future.tif", overwrite=TRUE)

names(clim_f_pro)
clim_f_pro
clim_h_fin
