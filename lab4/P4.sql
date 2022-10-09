USE `world`;

SHOW TABLES;
SET foreign_key_checks = 0;

-- 1. Listar el nombre de la ciudad y el nombre del país de todas las ciudades que pertenezcan a países con una población 
-- menor a 10000 habitantes.
SELECT 
	city.Name, country.Name
FROM
	city
		INNER JOIN
	country ON city.CountryCode = country.Code
WHERE
	country.Code IN
		(SELECT
			country.Code
		FROM
			country AS co
		WHERE
			co.Population < 10000
				AND co.Code = country.Code)

-- 2. Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.
SELECT 
	city.Name
FROM
	city
WHERE
	city.Population > (SELECT
			AVG(Population)
		FROM
			city)
ORDER BY Population;	
	
-- 3. Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total de algún país de Asia.
SELECT
	city.Name
FROM
	country
		INNER JOIN
	city ON country.Code = city.CountryCode
WHERE 
	country.Continent != 'Asia'
		AND city.Population >= SOME (SELECT
			Population
		FROM
			country
		WHERE
			country.Continent = 'Asia')
ORDER BY city.ID;	

-- 4. Listar aquellos países junto a sus idiomas no oficiales, que superen en porcentaje de hablantes a cada uno 
-- de los idiomas oficiales del país.
SELECT
	country.Name, countrylanguage.Language
FROM
	country
		INNER JOIN
	countrylanguage ON country.Code = countrylanguage.CountryCode
		AND countrylanguage.IsOfficial = 'F'
WHERE 
	countrylanguage.Percentage > ALL (SELECT
		Percentage
	FROM
		countrylanguage
	WHERE
		countrylanguage.IsOfficial = 'T'
			AND countrylanguage.CountryCode = country.Code);

-- 5. Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 y exista (en el país) 
-- al menos una ciudad con más de 100000 habitantes. (Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas).
SELECT 
	country.Region
FROM
	country
WHERE
	country.SurfaceArea < 1000
		AND country.Code IN (SELECT
			CountryCode
		FROM
			city
		WHERE
			Population > 100000);

-- 6. Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada. 
-- (Hint: Hay dos maneras de llegar al mismo resultado. Usando consultas escalares o usando agrupaciones, encontrar ambas).
SELECT 
	country.Name, MAX(city.Population)
FROM
	country
		INNER JOIN
	city ON country.Code = city.CountryCode
GROUP BY country.Name;

-- 7. Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de hablantes sea mayor al promedio 
-- de hablantes de los lenguajes oficiales.
SELECT
	country.Name, countrylanguage.Language
FROM
	country
		INNER JOIN
	countrylanguage ON country.Code = countrylanguage.CountryCode 
		AND countrylanguage.IsOfficial = 'F'
WHERE
	countrylanguage.Percentage > ALL (SELECT
		AVG(countrylanguage.Percentage)
	FROM
		countrylanguage
	WHERE
		countrylanguage.IsOfficial = 'T'
			AND country.Code = countrylanguage.CountryCode);

-- 8. Listar la cantidad de habitantes por continente ordenado en forma descendiente.
SELECT
	Continent, SUM(Population)
FROM
	country
GROUP BY continent
ORDER BY SUM(Population) DESC; 

-- 9. Listar el promedio de esperanza de vida (LifeExpectancy) por continente con una
-- esperanza de vida entre 40 y 70 años.
SELECT
	Continent, AVG(LifeExpectancy)
FROM
	country
GROUP BY Continent
HAVING AVG(LifeExpectancy) BETWEEN 40 AND 70;

-- 10. Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente.
SELECT
	Continent, MAX(Population), MIN(Population), AVG(Population), SUM(Population)
FROM
	country
GROUP BY Continent;
