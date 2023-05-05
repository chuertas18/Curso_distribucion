/* Código para la descarga de Factores abióticos GEE
   Versión 1.0
   Autor: Claudia Huertas
   Curso: Taller distribución de especies
   Descripción: Este código que se ejecuta en Google Earth Engine (GEE)
   permite la descarga de imágenes de entrada en los modelos de distribución
   de las especies
*/

// Código para la descarga de Factores abióticos
// Define la ubicación y tamaño del rectángulo que delimita el área de interés
var rectangle = ee.Geometry.Rectangle(-83.55, -6.74, -65.84, 13.93);

// Define el período de tiempo para el que se descargará los datos
var startDate = ee.Date('2019-01-01');
var endDate = ee.Date('2020-01-01');

// Carga los datos de elevación
var elevation = ee.Image('USGS/SRTMGL1_003')
    .clip(rectangle);


// Carga la colección de imágenes de precipitación diaria CHIRPS
var prec = ee.ImageCollection('UCSB-CHG/CHIRPS/DAILY')
  .filterDate(startDate, endDate)
  .select('precipitation')
  .sum()
  .clip(rectangle);

// Carga los datos de densidad de población
var population = ee.ImageCollection('WorldPop/GP/100m/pop')
  .filterDate(startDate, endDate)
  .map(function(image){return image.clip(rectangle)})
  .mean();

// Cargar los datos de Land cover
var clc = ee.Image('COPERNICUS/Landcover/100m/Proba-V-C3/Global/2019')
  .select('discrete_classification')
  .clip(rectangle);

// Cargar los datos de TPI
var tpi = ee.Image('CSP/ERGo/1_0/Global/ALOS_mTPI')
  .select('AVE')
  .clip(rectangle);
  
// Cargar Forest proximate people (FPP)
var fpp = ee.ImageCollection('FAO/SOFO/1/FPP')
    .mean()
    .select('FPP_1km')
    .clip(rectangle);

// Cargar la Temperatura máxima
var tmax = ee.ImageCollection('IDAHO_EPSCOR/TERRACLIMATE')
                  .filterDate(startDate, endDate)
                  .select('tmmx')
                  .map(function(image){return image.clip(rectangle).multiply(0.1)})
                  .mean();

// Cargar la Temperatura mínima
var tmin = ee.ImageCollection('IDAHO_EPSCOR/TERRACLIMATE')
                  .filterDate(startDate, endDate)
                  .select('tmmn')
                  .map(function(image){return image.clip(rectangle)
                  .multiply(0.1)})
                  .mean();


// Crea un mapa y añade las capas de elevación, temperatura, precipitación, bosque y no bosque
Map.centerObject(rectangle);
Map.addLayer(elevation, {min:0, max:3000}, 'Elevación');
Map.addLayer(population, {min:0, max:50}, 'Población');
Map.addLayer(clc,{}, 'Land Cover');
Map.addLayer(tpi,{min:-200, max:200}, 'Topographic Position Index');
Map.addLayer(fpp,{min: 0, max: 12, palette: ['blue', 'yellow', 'red']}, 'Forest proximate people – 1km cutoff distance');
Map.addLayer(prec, {min:0, max:8000, palette:['blue', "yellow",'orange','red']}, 'Precipitación Total (mm)');
Map.addLayer(tmax, {min:0, max:30, palette: ['#d7191c','#fdae61','#ffffbf','#abd9e9'],}, 'Temperatura max');
Map.addLayer(tmin, {min:0, max:30, palette: ['#d7191c','#fdae61','#ffffbf','#abd9e9'],}, 'Temperatura min');


Export.image.toDrive({
image: prec,
description: "precipitation",
folder: "Curso_distribucion",
scale: 5566,
region: rectangle,
maxPixels: 1e13,
crs: "EPSG:4326"
});

Export.image.toDrive({
image: population,
description: "population",
folder: "Curso_distribucion",
scale: 92.77,
region: rectangle,
maxPixels: 1e13,
crs: "EPSG:4326"
});

Export.image.toDrive({
image: clc,
description: "clc",
folder: "Curso_distribucion",
scale: 100,
region: rectangle,
maxPixels: 1e13,
crs: "EPSG:4326"
});

Export.image.toDrive({
image: tpi,
description: "tpi",
folder: "Curso_distribucion",
scale: 270,
region: rectangle,
maxPixels: 1e13,
crs: "EPSG:4326"
});

Export.image.toDrive({
image: tmax,
description: "Tmax",
folder: "Curso_distribucion",
scale: 4638.3,
region: rectangle,
maxPixels: 1e13,
crs: "EPSG:4326"
});


Export.image.toDrive({
image: tmin,
description: "Tmin",
folder: "Curso_distribucion",
scale: 4638.3,
region: rectangle,
maxPixels: 1e13,
crs: "EPSG:4326"
});

// Descarga de datos
Export.image.toDrive({
image: fpp,
description: "Forest_prox_people",
folder: "Curso_distribucion",
scale: 100,
region: rectangle,
maxPixels: 1e13,
crs: "EPSG:4326"
});


// Descarga de datos
Export.image.toDrive({
image: elevation,
description: "elevation",
folder: "Curso_distribucion",
scale: 90,
region: rectangle,
maxPixels: 1e13,
crs: "EPSG:4326"
});