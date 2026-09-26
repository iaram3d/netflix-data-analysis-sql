-- Analisis de BBDD de Netflix
-- Iara Medina
-- 
-- Descripcion: Exploracion y filtrado de tablas.

USE netflix;

-- Exploracion de los datos y su calidad en las tablas
DESCRIBE netflix.content
SELECT COUNT(id_content) FROM netflix.content
SELECT COUNT(*) FROM netflix.content WHERE description IS NOT NULL
SELECT COUNT(*) FROM netflix.content WHERE description IS NULL
SELECT COUNT(*) FROM netflix.content WHERE description LIKE ""
SELECT COUNT(DISTINCT description) FROM netflix.content

DESCRIBE netflix.production
SELECT COUNT(id_production) FROM netflix.production
SELECT COUNT(*) FROM netflix.production WHERE language IS NOT NULL
SELECT COUNT(*) FROM netflix.production WHERE language IS NULL
SELECT COUNT(*) FROM netflix.production WHERE language LIKE ""
SELECT COUNT(DISTINCT language) FROM netflix.production

-- Visualizacion de los registros
SELECT type AS Tipo,
       title_content AS Título, 
       country AS País, 
       rating AS Clasificación_público, 
       duration AS Duración, 
       listed_in AS Categorías
FROM netflix.content;

SELECT id_content AS ID, 
       title_production AS Título, 
       genre AS Género, 
       runtime AS Duración, 
       imdb_score AS Puntaje_IMDB 
FROM netflix.production;

-- Consultas
-- Listado de registros en los que participa Argentina
SELECT id_content AS ID, 
       type AS Tipo, 
       title_content AS Título, 
       director AS Dirección, 
       cast AS Reparto, 
       rating AS Clasificación, 
       duration AS Duración, 
       listed_in AS Categorías
FROM netflix.content
WHERE country LIKE "Argentina";

-- Listado de registros con puntaje IMDB mayor a 7.5
SELECT id_production AS ID, 
       title_production AS Título, 
       genre AS Género, 
       language AS Idioma, 
       imdb_score AS Puntaje_IMDB
FROM netflix.production
WHERE imdb_score > 7.5;

-- Listado de registros admitidas para todas las edades
SELECT id_content AS ID, 
       type AS Tipo, 
       title_content AS Título, 
       listed_in AS Categorías
FROM netflix.content
WHERE rating LIKE "TV-G";

-- Listado de registros con duracion entre 60 y 105 minutos
SELECT id_production AS ID, 
       title_production AS Título, 
       genre AS Género, 
       runtime AS duracion
FROM netflix.production
WHERE runtime BETWEEN 60 AND 105;

-- Cantidad de registros por tipo y clasificacion ordenados alfabeticamente por rating y type
SELECT type AS Tipo,
       rating AS Clasificación, 
       COUNT(*) AS Registros
FROM netflix.content
GROUP BY type, rating
ORDER BY rating, type;

-- Cantidad de registros en los idiomas portugues, frances, aleman, italiano y español, ordenados por cantidad, de mayor a menor
SELECT language AS Idioma,
       COUNT(*) AS Cantidad
FROM netflix.production
WHERE language IN ('Portuguese', 'French', 'German', 'Italian', 'Spanish')
GROUP BY language
ORDER BY Cantidad DESC;