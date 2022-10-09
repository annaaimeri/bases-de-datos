USE `world`;

SHOW TABLES;
SET foreign_key_checks = 0;

-- PARTE I

-- 1. Lista el nombre de la ciudad, nombre del país, región y forma de gobierno de las 10 ciudades más pobladas del mundo.
SELECT 
	city.Name, country.Name, country.Region, country.GovernmentForm 
FROM 
	city 
		INNER JOIN 
	country ON city.CountryCode = country.Code 
ORDER BY 
	city.Population DESC LIMIT 10;

-- 2. Listar los 10 países con menor población del mundo, junto a sus ciudades capitales 
-- (Hint: puede que uno de estos países no tenga ciudad capital asignada, en este caso deberá mostrar "NULL").
SELECT 
	country.Name, city.Name 
FROM 
	country 
		LEFT JOIN 
	city ON country.Capital = city.ID 
ORDER BY 
	country.Population LIMIT 10;

-- 3. Listar el nombre, continente y todos los lenguajes oficiales de cada país. 
-- (Hint: habrá más de una fila por país si tiene varios idiomas oficiales).
SELECT 
	country.Name, country.Continent, countrylanguage.Language 
FROM 
	country 
		INNER JOIN 
	countrylanguage ON country.Code = countrylanguage.CountryCode 
			AND IsOfficial = 'T';

-- 4. Listar el nombre del país y nombre de capital, de los 20 países con mayor superficie del mundo.
SELECT 
	country.Name, city.Name, country.SurfaceArea 
FROM 
	country 
		INNER JOIN 
	city ON country.Capital = city.ID 
ORDER BY 
	country.SurfaceArea DESC LIMIT 20; 

-- 5. Listar las ciudades junto a sus idiomas oficiales (ordenado por la población de la ciudad) y el porcentaje de hablantes del idioma.
SELECT 
	city.Name, countrylanguage.Language, countrylanguage.Percentage, city.Population  
FROM 
	city 
		INNER JOIN 
	countrylanguage ON city.CountryCode = countrylanguage.CountryCode 
			AND IsOfficial = 'T' 
			AND countrylanguage.Percentage != 0 
ORDER BY city.Population, countrylanguage.Percentage DESC; 

-- 6. Listar los 10 países con mayor población y los 10 países con menor población (que tengan al menos 100 habitantes) en la misma consulta.
(SELECT country.Name 
	FROM country 
ORDER BY country.Population DESC LIMIT 10) 
		UNION 
(SELECT country.Name 
	FROM country 
ORDER BY country.Population LIMIT 10);

-- 7. Listar aquellos países cuyos lenguajes oficiales son el Inglés y el Francés (hint: no debería haber filas duplicadas).
SELECT 
	country.Name 
FROM 
	country 
WHERE 
	country.Code IN 
		(SELECT 
			countrylanguage.countryCode 
		FROM 
			countrylanguage 
		WHERE countrylanguage.Language = 'French' 
			AND countrylanguage.IsOfficial = 'T')
	AND country.Code IN 
		(SELECT 
			countrylanguage.countryCode 
		FROM 
			countrylanguage
		WHERE countrylanguage.Language = 'English' 
			AND countrylanguage.IsOfficial = 'T');

-- 8. Listar aquellos países que tengan hablantes del Inglés pero no del Español en su población.
SELECT 
	country.Name 
FROM 
	country 
WHERE 
	country.Code IN 
		(SELECT 
			countrylanguage.CountryCode 
		FROM 
			countrylanguage
		WHERE 
			countrylanguage.Language = 'English' 
				AND countrylanguage.Percentage > 0) 
	AND country.Code NOT IN 
		(SELECT 
			countrylanguage.CountryCode 
		FROM 
			countrylanguage 
		WHERE countrylanguage.Language = 'Spanish');

