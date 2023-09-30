setwd("C:/Users/Lennart Spreckmeyer/Desktop/Loek/Fernerkundung/PNV")

library(sf)
library(mapview)
library(geodata)
library(raster)
library(terra)
library(rgeos)
library(RSAGA)

rivers_b <- st_read("Flusse/Flüsse.shp")
rivers_b <- st_as_sf(rivers_b)
rivers_s <- st_read("centerlines_europe/centerlines_europe.shp")
rivers_s <- st_as_sf(rivers_s)

rivers <- st_join(rivers_s, rivers_b)

?st_join

clim_h <- rast("clim_h_dw.tif")
clim_f <- rast("clim_f_dw.tif")

dem <- rast("dem_dw.tif")
slope <- rast("slope_dw.tif")
aspect <- rast("aspect_dw.tif")

D_waelder <- rast("D_waelder.tif")

dem_pro <- project(dem, D_waelder)

slope_pro <- project(slope, D_waelder)
aspect_pro <- project(aspect, D_waelder)

clim_h_pro <- project(clim_h,D_waelder)
clim_f_pro <- project(clim_f,D_waelder)

par(mfrow=c(1,3))
plot(dem_pro, main="DEM")
plot(slope_pro, main= "Slope")
plot(aspect_pro, main="Aspect")

par(mfrow=c(1,1))
plot(clim_h_pro)
plot(clim_f, main="Zukunft")

clim_h_pro <- rast("clim_h_fin.tif")


D_flue <- mask(D, D, inverse=TRUE, maskvalues=c(38:44), 
                  updatevalue=NA, filename="D_fluesse.tif", overwrite=TRUE)

fldist <- terra::distance(D_flue, target=NA)
writeRaster(fldist, "fldist.tif")
distpro <- project(fldist, D_waelder)
fldist <- rast("fldist.tif")
plot(distpro)
dist <- mask(distpro, D_waelder)
plot(dist)
writeRaster(dist, "dist.tif")

?distance
plot(fldist)
values(predstack$veg)

writeRaster(dem_pro, "dem_fin.tif")
writeRaster(slope_pro, "slope_fin.tif")
writeRaster(aspect_pro, "aspect_fin.tif")
writeRaster(clim_f_pro, "clim_f_fin.tif")
writeRaster(clim_h_pro, "clim_h_fin.tif")

dem_fin <- rast( "dem_fin.tif")
slope_fin <- rast( "slope_fin.tif")
aspect_fin <- rast( "aspect_fin.tif")
clim_h_fin <- rast( "clim_f_fin.tif")
clim_f_fin <- rast( "clim_h_fin.tif")
twi <- rast("TWI_PNV.tif")
buek <- st_read("buek.shp")
veg_geb <- st_read("veg_geb.shp")


pnv500 <-st_read("pnv500.json")
pnv_pro <- st_transform(pnv500, 3035)
st_write(pnv_pro, "pnv_pro.shp")

veg_geb <- st_read("Vegetationsgebiete.json")
veg_geb <- st_transform(veg_geb, 3035)
st_write(veg_geb, "Veg_geb.shp")


pr <- as.polygons(D_waelder)
plot(pr)
p <- st_as_sf(pr)

pnv_dw <- st_crop( pnv_pro, p)

test=pnv_pro[p,]

testmapview(pnv_pro)


Bodenkarte <- st_read("buek1000de_v21/buek1000de_v21.shp") 
crs(Bodenkarte)
Bodenkarte <- st_transform(Bodenkarte, 3035) #Koordinatensytem anpassen     ext <- extent(3720138,4339840,2292176,3129428)
Bodenkarte$Legende <- as.factor(Bodenkarte$Legende)
head(Bodenkarte)

st_write(Bodenkarte, "buek.shp")

twi <- rast("TWI_PNV.tif")
plot(twi)

D <- rast("Deutschland_Landnutzung.tif")

coords<- spatSample(europe_crop, 20000, method="random", replace=F, na.rm=T, as.df=T, values=F, xy=T)
sample<-as.data.frame(coords)
