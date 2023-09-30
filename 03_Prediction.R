
setwd("C:/Users/g_all/OneDrive/Dokumente/Fernerkundung/Projekt SOse23/Datengrundlage")

library(raster)




################################################################################
######## Daten laden 
################################################################################

predstack <- rast("predstack.tif")
predstack_future <- rast("predstack_future.tif")
veg_waelder <- rast("veg_waelder.tif")
model <- readRDS("RFModel.RDS")
model50 <- readRDS("RFModel_ntree50.RDS")
model100 <- readRDS("RFModel_ntree100.RDS")



################################################################################
###### Heute PNV: mit verschiedenem ntree

prediction <- terra::predict(predstack, model, na.rm = TRUE)
prediction50 <- terra::predict(predstack, model50, na.rm = TRUE)
prediction100 <- terra::predict(predstack, model100, na.rm = TRUE)


# export raster
writeRaster(prediction,"prediction.tif",overwrite=TRUE)
writeRaster(prediction50,"prediction50.tif",overwrite=TRUE)
writeRaster(prediction100,"prediction100.tif",overwrite=TRUE)





###############################################################################
############## Zukunft

predstack_future$twi[is.infinite(predstack_future$twi)] <-NA # daten bereinigen
prediction_future <- terra::predict(predstack_future, model, na.rm = TRUE)

#export
writeRaster(prediction_future,"prediction_future.tif",overwrite=TRUE)








