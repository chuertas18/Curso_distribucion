#####################################################################################
# Código para preparar los ráster ambientales para realizar la distribución
# de especies con Maxent
#####################################################################################


# Cargar libreria
library(raster)

#set up extent parameter for use throughout script
ext <- extent(-82, -66, -5.5, 12)

# Obtener las variables ambientales en formato raster
tmin <- raster("D:/Spatial_DB/Curso/raster/geotif_500/Tmin.tif")
tmax <- raster("D:/Spatial_DB/Curso/raster/geotif_500/Tmax.tif")
elev <- raster("D:/Spatial_DB/Curso/raster/geotif_500/elevation.tif")
clc <- raster("D:/Spatial_DB/Curso/raster/geotif_500/clc.tif")
fpf <- raster("D:/Spatial_DB/Curso/raster/geotif_500/Forest_prox_people.tif")
prec <- raster("D:/Spatial_DB/Curso/raster/geotif_500/precipitation.tif")
tpi <- raster("D:/Spatial_DB/Curso/raster/geotif_500/tpi.tif")
pop <- raster("D:/Spatial_DB/Curso/raster/geotif_500/population.tif")

# Cortarlas por una misma extensión
tmin_tend <- extend(tmin, ext, value=NA)
tmax_tend <- extend(tmax, ext, value=NA)
elev_tend <- extend(elev, ext, value=NA)
clc_tend <- extend(clc, ext, value=NA)
fpf_tend <- extend(fpf, ext, value=NA)
prec_tend <- extend(prec, ext, value=NA)
tpi_tend <- extend(tpi, ext, value=NA)
pop_tend <- extend(pop, ext, value=NA)

# Directorio de salida
setwd("D:/Spatial_DB/Curso/raster/maxent")

# Guardar los raster
writeRaster(tmin_tend, filename="tmin.asc", format="ascii", overwrite=TRUE)
writeRaster(tmax_tend, filename="tmax.asc", format="ascii", overwrite=TRUE)
writeRaster(elev_tend, filename="elev.asc", format="ascii", overwrite=TRUE)
writeRaster(clc_tend, filename="clc.asc", format="ascii", overwrite=TRUE)
writeRaster(fpf_tend, filename="fpf.asc", format="ascii", overwrite=TRUE)
writeRaster(prec_tend, filename="prec.asc", format="ascii", overwrite=TRUE)
writeRaster(tpi_tend, filename="tpi.asc", format="ascii", overwrite=TRUE)
writeRaster(pop_tend, filename="pop.asc", format="ascii", overwrite=TRUE)