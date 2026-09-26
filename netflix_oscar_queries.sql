-- Analisis de BBDD de Netflix
-- Iara Medina
-- 
-- Descripcion: Creacion de tablas, queries multi-tablas.

USE netflix;

-- Creacion de la tabla oscar a partir de las definiciones
CREATE TABLE IF NOT EXISTS oscar(
    id_oscar INTEGER NOT NULL,
    id_inf INTEGER DEFAULT NULL,
    id_res INTEGER DEFAULT NULL,
    id_content INTEGER DEFAULT NULL,
    title_oscar VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
    year_ceremony INTEGER DEFAULT NULL,
    category VARCHAR(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
    name VARCHAR(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
    winner TINYINT DEFAULT NULL,
    directed_by VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
    based_on VARCHAR(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
    starring VARCHAR(512) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
    distributed_by VARCHAR(256) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
    budget VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
    budget_x_million DOUBLE DEFAULT NULL,
    box_office VARCHAR(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci DEFAULT NULL,
    box_office_x_million DOUBLE DEFAULT NULL,
    imdb DOUBLE DEFAULT NULL,
    metascore INTEGER DEFAULT NULL,
    rotten_tomatoes INTEGER DEFAULT NULL
)

-- Exploracion de los datos y su calidad en la tabla
SELECT COUNT(*) FROM netflix.oscar WHERE id_oscar IS NOT NULL
SELECT COUNT(*) FROM netflix.oscar WHERE id_oscar IS NULL
SELECT COUNT(*) FROM netflix.oscar WHERE id_oscar LIKE ""
SELECT COUNT(DISTINCT id_oscar) FROM netflix.oscar

-- Consultas
-- Titulos con runtime superior a 90 y lenguaje Frances ordenados de menor a mayor
SELECT content.title_content AS titulo,
       content.listed_in AS contenido
FROM netflix.content
INNER JOIN netflix.production
ON content.id_content = production.id_content
WHERE production.runtime > 90 AND production.language LIKE 'French'
ORDER BY titulo ASC

-- Titulos que poseen director, pais de origen y un Runtime mayor a 70 ordenados de manera ascendente
SELECT content.title_content AS titulo
FROM netflix.content
INNER JOIN netflix.production
ON content.id_content = production.id_content
WHERE director IS NOT NULL AND country IS NOT NULL AND runtime > 70
ORDER BY titulo ASC

-- Suma del Runtime de las peliculas que tengan como unico pais de origen EEUU, India, Japon, España y Mexico, discriminando y ordenando por pais
SELECT content.country AS pais_de_origen,
       SUM(runtime) AS suma_duracion,
       production.genre AS genero
FROM netflix.content
INNER JOIN netflix.production
ON content.id_content = production.id_content
WHERE country IN ('United States','India','Japan','Spain','Mexico')
GROUP BY pais_de_origen

-- Peliculas clasificadas como drama, que ganaron el Oscar entre 2010 y 2020 y estan en la plataforma
SELECT content.title_content AS titulo,
       production.genre AS genero,
       oscar.year_ceremony AS año
FROM netflix.content
INNER JOIN netflix.production 
INNER JOIN netflix.oscar
ON content.id_content = production.id_content = oscar.id_oscar
WHERE production.genre LIKE 'Drama' AND oscar.year_ceremony BETWEEN 2010 AND 2020 AND oscar.distributed_by LIKE 'Netflix'

-- Titulo y el genero de las peliculas puntuadas por IMDB entre 7 y 9 en idioma ingles
SELECT content.title_content AS titulo,
       production.genre AS genero
FROM netflix.content
INNER JOIN netflix.production
ON content.id_content = production.id_content
WHERE production.imdb_score BETWEEN 7 AND 9
AND language LIKE 'English'

-- Cantidad de titulos de cada genero de la tabla productions ordenados de manera descendente por las cantidades y ascendente por el genero
SELECT genre AS genero,
       COUNT(id_content) AS cantidad_de_titulos
FROM netflix.production
GROUP BY genre
ORDER BY cantidad_de_titulos DESC, genero ASC

-- Peliculas que ganaron el Oscar a Best Picture ordenadas de manera descendente por año ganador
SELECT title_content AS pelicula
FROM netflix.oscar
INNER JOIN netflix.content
ON oscar.id_oscar = content.id_content
WHERE oscar.category LIKE 'Best Picture'
ORDER BY oscar.year_ceremony DESC

-- Título y año de ceremonia de los oscar para las peliculas puntuadas por IMDB entre 7 y 9 ordenados alfabeticamente por titulos y de mayor a menor por año de ceremonia
SELECT content.title_content AS titulo,
       oscar.year_ceremony AS año
FROM netflix.content
INNER JOIN netflix.production 
INNER JOIN netflix.oscar
ON content.id_content = production.id_content = oscar.id_oscar
WHERE production.imdb_score BETWEEN 7 AND 9
ORDER BY titulo ASC, año DESC
