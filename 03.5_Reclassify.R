
setwd("C:/Users/g_all/OneDrive/Dokumente/Fernerkundung/Projekt SOse23/Datengrundlage")
library(raster)
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




###############################################################################
##### Daten einladen:
prediction_future <- rast("prediction_future.tif")
prediction <- rast("prediction.tif")


#####################################################################################
################# Reclassify 


###### Prediction heute ###########################################

häufigkeiten_klassen <- freq(prediction) # schauen wie oft welche Klasse vorkommt
levels(prediction) # alle Klassen anzeigen lassen

recl_tab <- data.frame("from"=c(6,  11,  13,   14.6, 17.6, 22.9, 24.9, 29.9, 33.9, 36.9, 38.9, 41.9, 46.9, 50.9, 52.9, 55.9, 59.9),
                       "to"=  c(8.5,12.5,14.5, 17.5, 19.5, 24.5, 26.5, 31.5, 36.5, 38.5, 41.4, 46.4, 49.4, 51.4, 54.4, 59.4, 61.4),
                       "new"= c(6,  11,  13,   15,   18,   23,   25,   30,   33,   37,   39,   42,   47,   50,   52,   56,   61))


pred_reclass <- classify(prediction, recl_tab)


#jetzt sind labels leider weg. Wieder zuweisen (leider etwas Bastelarbeit):
## neue Levels anpassen

newvalues <- unique(values(pred_reclass))[complete.cases(unique(values(pred_reclass))),]
newlevels <- levels(prediction)[[1]][newvalues,]

levels(pred_reclass) <- newlevels
levels(pred_reclass)

writeRaster(pred_reclass, "pred_reclass.grd")
pred_reclass <- rast("pred_reclass.tif")





######## Prediction Zukunft #################################################################


recl_tab <- data.frame("from"=c(6,  10,  12,   13.6, 16.6, 21.9, 23.9, 28.9, 32.9, 35.9, 37.9, 40.9, 45.9, 49.9, 51.9, 54.9, 57.9),
                       "to"=  c(7.5,11.5,13.5, 16.5, 18.5, 23.5, 25.5, 30.5, 35.5, 37.5, 40.4, 45.4, 48.4, 50.4, 53.4, 57.4, 58.4),
                       "new"= c(6,  10,  12,   14,   17,   22,   24,   29,   32,   36,   38,   41,   46,   49,   51,   55,   59))


pred_reclass_future <- classify(prediction_future, recl_tab)

#jetzt sind labels leider weg. Wieder zuweisen (leider etwas Bastelarbeit):
## neue Levels anpassen

newvalues <- unique(values(pred_reclass_future))[complete.cases(unique(values(pred_reclass_future))),]
newlevels <- levels(prediction_future)[[1]][newvalues,]

levels(pred_reclass_future) <- newlevels

levels(pred_reclass_future)

writeRaster(pred_reclass_future_new, "pred_reclass_future_new.grd", overwrite=TRUE)

pred_reclass_future_new <- rast("pred_reclass_future_new.tif")










#### VERSUCH


############# PNV ######################################################

### zahlen noch ändern
#veg_waelder <- rast("veg_waelder.tif")
#recl_tab_pnv <- data.frame("from"=c(1.9,  3,    7.9,  12.9,  15,  17,   20,   24.9, 26.9, 31.9, 34.9, 38.9, 40.9, 43.9, 48.9, 51.9, 53.9, 57.9, 61.9),
"to"=  c(2.4,  4.4,  10.5, 14.5, 16.5, 19.5 , 21.5, 26.5, 28.5, 33.5, 38.5, 40.5, 43.4, 48.4, 51.4, 53.4, 56.4, 61.4, 64.4),
"new"= c( 1,   3,    8,    13,    15,  17   , 20,   25,   27,   32,   35,   39,   41,   44,   49,   52,   54,   58,   64))

#pred_reclass_pnv <- classify(veg_waelder, recl_tab_pnv)
#newvalues <- unique(values(pred_reclass_pnv))[complete.cases(unique(values(pred_reclass_pnv))),]
#newlevels <- levels(veg_waelder)[[1]][newvalues,]
#levels(pred_reclass_pnv) <- newlevels
#levels(pred_reclass_pnv)
#writeRaster(pred_reclass_pnv, "pred_reclass_pnv.tif")
#plot(pred_reclass_pnv)



