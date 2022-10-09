USE `world`;

SHOW TABLES;
SET foreign_key_checks = 0;

-- PARTE I

DROP TABLE IF EXISTS country;
CREATE TABLE IF NOT EXISTS country (
	Code CHAR(3) NOT NULL,	
	PRIMARY KEY(Code),
	Name VARCHAR(255) NOT NULL,
	Continent VARCHAR(50) NOT NULL,
	Region VARCHAR(50) NOT NULL,
	SurfaceArea DECIMAL(12,2) NOT NULL,
	IndepYear INT,
	Population INT NOT NULL,
	LifeExpectancy FLOAT,
	GNP FLOAT NOT NULL,
	GNPOld FLOAT, 
	LocalName VARCHAR(50) NOT NULL,
	GovernmentForm VARCHAR(50) NOT NULL,
	HeadOfState VARCHAR(50),
	Capital INT,
	Code2 CHAR(3) NOT NULL
);

DROP TABLE IF EXISTS city;
CREATE TABLE IF NOT EXISTS city (
	ID INT NOT NULL,	
	PRIMARY KEY(ID),
	Name VARCHAR(100) NOT NULL,
	CountryCode CHAR(3) NOT NULL,
	District VARCHAR(50) NOT NULL,
	Population INT NOT NULL,
	
	CONSTRAINT `City_FK` FOREIGN KEY (`CountryCode`) 
		REFERENCES `country` (`Code`)
);

DROP TABLE IF EXISTS countrylanguage;
CREATE TABLE IF NOT EXISTS countrylanguage (
	CountryCode CHAR(3) NOT NULL,	
	Language VARCHAR(50) NOT NULL,
	PRIMARY KEY(CountryCode, Language),
	IsOfficial CHAR(1) NOT NULL,
	Percentage DECIMAL(9,2) NOT NULL,
	
	CONSTRAINT `CountryLanguage_FK` FOREIGN KEY (`CountryCode`) 
		REFERENCES `country` (`Code`)
);

DROP TABLE IF EXISTS continent;
CREATE TABLE IF NOT EXISTS continent (
	Name VARCHAR(250) NOT NULL,
	PRIMARY KEY(Name),
	Area INT NOT NULL,
	Percentage DECIMAL(5,2) NOT NULL,
	MostPopulatedCity VARCHAR(50) REFERENCES `city`(`Name`) ON DELETE SET NULL
);

INSERT INTO `city` VALUES (4080, 'McMurdo Station', 'ATA', 'Ross Dependency', 1258);

INSERT INTO `continent` VALUES
	('Africa', 30370000, 20.4, 'Cairo, Egypt'),
	('Antarctica', 14000000, 9.2, 'McMurdo Station'),
	('Asia', 44579000, 29.5, 'Mumbai, India'),
	('Europe', 10180000, 6.8, 'Istanbul, Turquia'),
	('North America', 24709000, 16.5, 'Ciudad de Mexico, Mexico'),
	('Oceania', 8600000, 5.9, 'Sydney, Australia'),
	('South America', 17840000, 12.0, 'Sao Paulo, Brazil')
;

ALTER TABLE `country` MODIFY COLUMN `Continent` varchar(52);
ALTER TABLE `country` ADD CONSTRAINT `CountryContinent_FK` FOREIGN KEY (`Continent`) REFERENCES `continent` (`Name`);

-- PARTE II

-- Devuelva una lista de los nombres y las regiones a las que pertenece cada país ordenada alfabéticamente.
SELECT Name, Region FROM country ORDER BY Name;

-- Liste el nombre y la población de las 10 ciudades más pobladas del mundo.
SELECT Name, Population FROM country ORDER BY Population LIMIT 10;

-- Liste el nombre, región, superficie y forma de gobierno de los 10 países con menor superficie.
SELECT Name, Region, SurfaceArea, GovernmentForm FROM country ORDER BY SurfaceArea ASC LIMIT 10;

-- Liste todos los países que no tienen independencia (hint: ver que define la independencia de un país en la BD).
SELECT Name FROM country WHERE IndepYear IS NULL;

-- Liste el nombre y el porcentaje de hablantes que tienen todos los idiomas declarados oficiales.
SELECT Language, Percentage FROM countrylanguage WHERE IsOfficial = 'T'; 

-- ADICIONAL

-- Actualizar el valor de porcentaje del idioma inglés en el país con código 'AIA' a 100.0
UPDATE countrylanguage SET Percentage = 100.0 WHERE CountryCode = 'AIA'; 

-- Listar las ciudades que pertenecen a Córdoba (District) dentro de Argentina.
SELECT Name FROM city WHERE District = 'Córdoba' AND CountryCode = 'ARG';

-- Eliminar todas las ciudades que pertenezcan a Córdoba fuera de Argentina.
DELETE FROM city WHERE District = 'Córdoba' AND NOT(CountryCode = 'ARG');

-- Listar los países cuyo Jefe de Estado se llame John.
SELECT Name FROM country WHERE HeadOfState LIKE 'John%';

-- Listar los países cuya población esté entre 35 M y 45 M ordenados por población de forma descendente.
SELECT Name, Population FROM country WHERE Population BETWEEN 35000000 AND 45000000 ORDER BY Population DESC;

-- Identificar las redundancias en el esquema final.




