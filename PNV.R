setwd("C:/Users/Lennart Spreckmeyer/Desktop/Loek/Fernerkundung/PNV")

library(sf)
library(mapview)
library(geodata)
library(terra)


### Einlesen der PNV500 ###

pnv500 <-st_read("pnv500.json")
Veg <-st_read("Vegetationsgebiete.json")
Veg$Veggeb
pnv500$Verbr

# Visualisieren aller Polygone im mapview überfordert meinen Laptop
#mapview(pnv500)


### Einlesen der BioClim-Daten ###
# resolution 2,5 minuten (da das die maximale Auflösung der Zufkunftsszenarien ist)

# Aktuelle Klimadaten #
clim_heute <- worldclim_country("Germany",var= "bio", res=2.5, path=tempdir(), version=2.1)
clim_h_pro <- st_transform(clim_heute, 3035)

plot(clim_heute$wc2.1_30s_bio_1)
# Projizierte Klimadaten # 
#cmip6_world(model, ssp, time, var, res, path, ...)
# - Welches modell?

clim_future <- cmip6_tile(46.9-55.2,4.4-16.6,"EC-Earth3-Veg-LR", "370", "2061-2080", var="bioc", res=2.5, path=tempdir())
clim_f_pro <- project(clim_future, 3035)
?cmip6_tile
clim_future
names(clim_future)
values(clim_future)
?plot

## Einladen Soilgrids

pH_1 <- rast("soil/pH/out.tif")
pH_2 <- rast("soil/pH/out (1).tif")
pH_3 <- rast("soil/pH/out (2).tif")
pH_4 <- rast("soil/pH/out (3).tif")
pH_5 <- rast("soil/pH/out (4).tif")
pH_6 <- rast("soil/pH/out (5).tif")
pH_7 <- rast("soil/pH/out (6).tif")
pH_8 <- rast("soil/pH/out (7).tif")
pH_9 <- rast("soil/pH/out (8).tif")
pH_10 <- rast("soil/pH/out (9).tif")
pH_11 <- rast("soil/pH/out (10).tif")
pH_12 <- rast("soil/pH/out (11).tif")
pH_13 <- rast("soil/pH/out (12).tif")
pH_14 <- rast("soil/pH/out (13).tif")
pH_15 <- rast("soil/pH/out (14).tif")
pH_16 <- rast("soil/pH/out (15).tif")
pH_17 <- rast("soil/pH/out (16).tif")
pH_18 <- rast("soil/pH/out (17).tif")
pH_19 <- rast("soil/pH/out (18).tif")
pH_20 <- rast("soil/pH/out (19).tif")
?merge
pH_m <- merge(pH_1,pH_2,pH_3,pH_4,pH_5,pH_6,pH_7,pH_8,pH_9,pH_10,pH_11,pH_12,pH_13,pH_14,pH_15,pH_16,pH_17,pH_18,pH_19,pH_20)
pH_p <- project(pH_m, D_waelder)
pH <- mask(pH_p, D_waelder)

writeRaster(pH, "clay.tif")


#plot(pH_1)
#plot(pH_m)
#plot(pH)

clay <- rast("clay.tif")
plot(clay)

#sand <- rast("sand.tif")
#plot(sand)

#soc <- rast("soc.tif")
#plot(soc)


#cec <- rast("cec.tif")
#plot(cec)


#soilN <- rast("soilN.tif")
#plot(soilN)
### Einladen des DGM ###

e40n20 <- rast("eu_dem_v11_E40N20/eu_dem_v11_E40N20.tif")
e40n30 <- rast("eu_dem_v11_E40N30/eu_dem_v11_E40N30.tif")
dem <- merge(e40n20, e40n30)
plot(dem)

?terrain
slope <- terrain(dem, v="slope", unit="degrees",neighbors=8, filename="slope.tif", overwrite=TRUE)

slope <- rast("slope.tif")
plot(slope)
aspect <- rast("aspect.tif")

aspect <- terrain(dem, v="aspect", unit="degrees", neighbors=8, filename="aspect.tif", overwrite=TRUE)
plot(aspect)

### Einladen der Corine-Landnutzung ###
D <- rast("Deutschland_Landnutzung.tif")

?mask
D_waelder <- mask(D, D, inverse=TRUE, maskvalues=c(22,23,24,25), 
                  updatevalue=NA, filename="D_waelder.tif")
D_waelder <- rast("D_waelder.tif")
plot(D_waelder)


masktest <- project(D_waelder,dem)
dem_dw <- mask(dem, masktest)
slope_dw <- mask(slope, masktest)
aspect_dw <- mask(aspect, masktest)

writeRaster(dem_dw, "dem_dw.tif")
writeRaster(slope_dw, "slope_dw.tif")
writeRaster(aspect_dw, "aspect_dw.tif")

?writeRaster
clim_h_dw <- mask(clim_heute, D_waelder)
clim_f_dw <- mask(clim_future, D_waelder)


masktest <- project(D_waelder,clim_heute)
clim_f_dw <- mask(clim_future, masktest)
writeRaster(clim_f_dw, "clim_f_dw.tif")

clim_h_dw <- mask(clim_heute, masktest)
writeRaster(clim_h_dw, "clim_h_dw.tif")

plot(clim_h_dw)
D_waelder

