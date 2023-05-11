#####################################################################################
# Código para preparar archivo csv de especies para MAxent
# Autor: Claudia Huertas
#####################################################################################

library(rgbif)

# Cargar datos -------------------------------------------------------------
# Nombre científico de la especie de interés
#spce <- 'Wettinia_kalbreyeri'
spce <- 'Boissonneaua_flavescens'

# Pais code (ISO-3166-1), GBIF se necesita el código y no nombre
enumeration_country()
pais<-"CO" # Colombia iso-2



# Obtener los registros de ocurrencia de la especie
occr <- occ_data(scientificName = spce,country=pais, limit = 2e5, hasCoordinate = T, hasGeospatialIssue = F)

head(occr)

# Seleccionar el dataframe del objeto
occr <- occr[[2]]
colnames(occr)

# Obtener los países donde se encontró la especie
unique(occr$country) %>% sort()

head(occr)
names(occr)

# Crear los vectores con los datos
species <- occr$species
longitude <- occr$decimalLongitude
latitude <- occr$decimalLatitude


# Crear el dataframe
df <- data.frame(species, longitude, latitude)

head(df)

# Guardar el dataframe en un archivo CSV con separación por comas
write.csv(df, file = "ruta/del/archivo.csv", row.names = FALSE)
