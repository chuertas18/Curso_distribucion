# Curso_distribucion
 Modelos del curso de distribución de especies

Estos códigos corresponden al curso de Distribución de especies con el algoritmo de Machine Learning Random Forest y Algoritmo de Máxima entropía (MAXENT)
El flujo de trabajo de Random Forest que se recomienda seguir es el siguiente:
1.	Descarga de factores abióticos (variables ambientales) en Google Earth Engien empleando javascript y el script: Descarga_datos_raster_GEE.js
2.	Aplicar el modelo de Random Forest en R: Distribucion_especies_R_Random_Forest.R

![imagen](https://github.com/chuertas18/Curso_distribucion/assets/45825082/638c7430-1d70-4745-bc2c-8629337d3928)


El flujo de trabajo de Máxima entropía que se recomienda seguir es el siguiente:
1.	Descarga de factores abióticos (variables ambientales) en Google Earth Engien empleando javascript y el script: Descarga_datos_raster_GEE.js
2.	Preparación de los puntos de localización en R: Preparacion_samples_csv_maxent.R
3.	Preparación de los factores abióticos en el formato ASCII en R: Preparacion_raster_maxent.R
4.	Descarga del software https://biodiversityinformatics.amnh.org/open_source/maxent/
5.	Aplicación en el programa. 

![imagen](https://github.com/chuertas18/Curso_distribucion/assets/45825082/f34a101a-3f2a-48e7-88f5-407732b23967)

