#####################################################################################
# Código de generar un modelo de Distribución especies con Random Forest
# Basado en: https://geofabio.com/2023/01/26/modelo-random-forest-para-estimacion-del-nicho-ecologico-de-una-especie-forestal/
#####################################################################################


# https://geofabio.com/2023/01/26/modelo-random-forest-para-estimacion-del-nicho-ecologico-de-una-especie-forestal/
# Limpiar la consola y el espacio de trabajo --------------------------------
g <- gc(reset = T)
rm(list = ls())
options(scipen = 999, warn = -1)

#install.packages('pacman')
# Cargar paquetes ----------------------------------------------------------
require(pacman)
pacman::p_load(rnaturalearthdata, rnaturalearth, cptcity, SSDM, ggspatial, raster, terra, sf, fs, glue, tidyverse, rgbif, geodata)

# Cargar datos -------------------------------------------------------------
# Nombre científico de la especie de interés
spce <- 'Wettinia_kalbreyeri'

# Obtener los registros de ocurrencia de la especie
occr <- occ_data(scientificName = spce, limit = 2e5, hasCoordinate = T, hasGeospatialIssue = F)
head(occr)

# Seleccionar el dataframe del objeto
occr <- occr[[2]]
colnames(occr)

# Obtener los países donde se encontró la especie
unique(occr$country) %>% sort()

# Seleccionar únicamente los registros de la especie encontrados en Colombia
occr <- filter(occr, country == 'Colombia')

# Shapefiles
# Obtener los límites de los países
wrld <- ne_countries(returnclass = 'sf', scale = 50)

# Obtener los límites de Colombia
col <- geodata::gadm(country = 'COL', level = 1, path = 'tmpr')

# Visualizar los datos ------------------------------------------------------
plot(st_geometry(wrld))
plot(col)
points(occr$decimalLongitude, occr$decimalLatitude, pch = 16, col = 'red')

# Obtener las variables ambientales en formato raster
tmin <- raster("D:/Spatial_DB/Curso/raster/modelo/tmin.tif")
tmax <- raster("D:/Spatial_DB/Curso/raster/modelo/tmax.tif")
elev <- raster("D:/Spatial_DB/Curso/raster/modelo/elev.tif")
clc <- raster("D:/Spatial_DB/Curso/raster/modelo/clc.tif")
fpf <- raster("D:/Spatial_DB/Curso/raster/modelo/fpf.tif")
prec <- raster("D:/Spatial_DB/Curso/raster/modelo/prec.tif")
tpi <- raster("D:/Spatial_DB/Curso/raster/modelo/tpi.tif")
pop <- raster("D:/Spatial_DB/Curso/raster/modelo/pop.tif")

# Crear un objeto RasterStack con las variables ambientales
rs <- stack(tmin, tmax, elev, clc, fpf, prec, tpi, pop)

# Convertir el objeto RasterStack a un objeto SpatRaster
bioc <- rast(rs)

# Extraer los valores de las variables ambientales en los puntos de ocurrencia de la especie
occr <- dplyr::select(occr, x = decimalLongitude, y = decimalLatitude)
vles <- terra::extract(bioc, occr[,c('x', 'y')])
occr <- cbind(occr[,c('x', 'y')], vles[,-1])
occr <- as_tibble(occr)
occr <- mutate(occr, pb = 1)
head(occr)

# Generar areas de No presencia (Background)
cell <- terra::extract(bioc[[1]], occr[,1:2], cells = T)$cell
duplicated(cell) # Identificar duplicados
mask <- bioc[[1]] * 0 # Crear máscara de 0
mask[cell] <- NA # Poner NA en puntos
back <- terra::as.data.frame(mask, xy = T) %>% as_tibble() # Convertir a dataframe
back <- sample_n(back, size = nrow(occr) * 2, replace = FALSE) # Tomar una muestra aleatoria
colnames(back)[3] <- 'pb' # Cambiar nombre de columna
back <- mutate(back, pb = 0) # Agregar columna pb
back <- cbind(back, terra::extract(bioc, back[,c(1, 2)])[,-1]) # Extraer variables de la abioticas en el background
back <- as_tibble(back) # Convertir a dataframe

# Unir los datos de presencia y pseudo-ausencias
tble <- rbind(occr, back)
head(tble)

# Random forest 
  
# Convertir ambientales en raster stack
bioc <- stack(bioc)
tble <- as.data.frame(tble) # Convertir a dataframe

# Modelo Random Forest
sdrf <- modelling(algorithm = 'RF', 
                  Env = bioc, 
                  Occurrences = tble, 
                  Pcol = 'pb', 
                  Xcol = 'x', Ycol = 'y',
                  cv.parm = c(0.75, 0.25), metric = 'ROC', select.metric = 'AUC')

#  Gráfico de proyección
plot(sdrf@projection)

# Gráfico binario
plot(sdrf@binary)

# Parámetros del modelo
sdrf@parameters

# Nombre del modelo
sdrf@name

# Importancia de variables
sdrf@variable.importance
as.numeric(sdrf@variable.importance) %>% sum()

# Convertir a raster
rstr <- sdrf@projection
rstr <- terra::rast(rstr)

# Convertir a dataframe
rslt <- terra::as.data.frame(rstr, xy = T) %>% as_tibble()

# Crear mapa 
# Fuente
windowsFonts(georg = windowsFont('Georgia'))

# Gráfico
gmap <- ggplot() + 
  geom_tile(data = rslt, aes(x = x, y = y, fill = Projection)) +
  scale_fill_gradientn(colors = cpt(pal = 'imagej_gyr_centre', n = 10, rev = TRUE)) +
  geom_sf(data = wrld, fill = NA, col = 'grey40', lwd = 0.2) + 
  geom_sf(data = st_as_sf(col), fill = NA, col = 'grey40', lwd = 0.3) + 
  coord_sf(xlim = ext(col)[1:2], ylim = ext(col)[3:4]) + 
  labs(x = 'Lon', y = 'Lat', fill = 'Puntaje de idoneidad') + 
  ggtitle(label = 'Idoneidad para la especie Coyol en el país de México', subtitle = 'Modelo Random Forest') +
  theme_bw() + 
  theme(text = element_text(family = 'georg', color = 'grey50'), 
        legend.position = 'bottom', 
        plot.title = element_text(hjust = 0.5, face = 'bold', color = 'grey30'),
        plot.subtitle = element_text(hjust = 0.5, face = 'bold', color = 'grey30'),
        # legend.key.width = unit(3, 'line'),
        panel.border = element_rect(color = 'grey80')) +
  guides(fill = guide_legend( 
    direction = 'horizontal',
    keyheight = unit(1.15, units = "mm"),
    keywidth = unit(15, units = "mm"),
    title.position = 'top',
    title.hjust = 0.5,
    label.hjust = .5,
    nrow = 1,
    byrow = T,
    reverse = F,
    label.position = "bottom"
  )) + 
  annotation_scale(location =  "bl", width_hint = 0.5, text_family = 'georg', text_col = 'grey60', bar_cols = c('grey60', 'grey99'), line_width = 0.2) +
  annotation_north_arrow(location = "tr", which_north = "true", 
                         pad_x = unit(0.1, "in"), pad_y = unit(0.2, "in"), 
                         style = north_arrow_fancy_orienteering(text_family = 'georg', text_col = 'grey40', line_col = 'grey60', fill = c('grey60', 'grey99'))) 

# Guardar la imagen del gráfico
#ggsave(plot = gmap, filename = 'png/mapa_rf.png', units = 'in', width = 9, height = 7, dpi = 300)

# Guardar el raster
writeRaster(rstr,"D:/Spatial_DB/Curso/output/Modelo_variablesRF2.tif")
