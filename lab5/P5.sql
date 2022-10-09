USE `sakila`;

SHOW TABLES;

SET
foreign_key_checks = 0;
-- 1. Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de Películas.
DROP TABLE IF EXISTS directors;

CREATE TABLE IF NOT EXISTS directors (
	director_id INT UNSIGNED NOT NULL AUTO_INCREMENT,
	PRIMARY KEY(director_id),
	first_name VARCHAR(255) NOT NULL,
	last_name VARCHAR(255) NOT NULL,
	n_of_films INT
);
-- 2. El top 5 de actrices y actores de la tabla `actors` que tienen la mayor experiencia 
-- (i.e. el mayor número de películas filmadas) son también directores de las películas en las que participaron. 
-- Basados en esta información, inserten, utilizando una subquery los valores correspondientes en la tabla `directors`.
INSERT
	INTO
	directors (first_name,
	last_name,
	n_of_films)
WITH most_experienced_performers AS (
	SELECT 
		actor_id,
		COUNT(*) AS n_of_films
	FROM 
		film_actor
	GROUP BY
		(actor_id)
	ORDER BY
		n_of_films DESC
	LIMIT 5
),
	most_experienced_performers_names AS (
	SELECT 
		first_name,
		last_name,
		n_of_films
	FROM 
		actor a1
	INNER JOIN 
		most_experienced_performers a2 ON
		(a1.actor_id = a2.actor_id)
)
SELECT
	*
FROM
	most_experienced_performers_names;

SELECT
	*
FROM
	directors;

-- 3. Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de acuerdo a si el cliente es "premium" o no. 
-- Por defecto ningún cliente será premium.
ALTER TABLE customer ADD COLUMN premium_customer ENUM ('T',
'F') DEFAULT 'F';

-- 4. Modifique la tabla customer. Marque con 'T' en la columna `premium_customer` de los 10 clientes 
-- con mayor dinero gastado en la plataforma.
UPDATE
	CUSTOMER AS C
SET
	c.premium_customer = 'T'
WHERE
	c.customer_id IN (
	SELECT 
			*
	FROM
			(
		SELECT
				p.customer_id
		FROM
				payment AS p
		GROUP BY
			customer_id
		ORDER BY
			SUM(p.amount) DESC
		LIMIT 10) AS table_payment
	);

-- 5. Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings de las películas existentes 
-- (Hint: rating se refiere en este caso a la clasificación según edad: G, PG, R, etc).
SELECT
	rating,
	COUNT(rating)
FROM
	film
GROUP BY
	rating
ORDER BY
	COUNT(rating) DESC;

-- 6. ¿Cuáles fueron la primera y última fecha donde hubo pagos?
SELECT
	MIN(payment_date) AS "First payment",
	MAX(payment_date) AS "Last payment"
FROM
	payment;

-- 7. Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el
-- nombre del mes de una fecha).
SELECT
	MONTHNAME(payment_date) AS "Payment month",
	AVG(amount) AS "Average payment"
FROM
	payment
GROUP BY
	MONTHNAME(payment_date);

-- 8. Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la cantidad total
-- de alquileres).
SELECT 
	SUM(rxc.total) AS rents_total,
	a.district
FROM
	(
	SELECT
		COUNT(r.rental_id) AS total,
		r.customer_id,
		c.address_id
	FROM
		rental AS r
	INNER JOIN
		customer AS c ON
		(r.customer_id = c.customer_id)
	GROUP BY
		r.customer_id,
		c.address_id) AS rxc
INNER JOIN
	address AS a ON
	(rxc.address_id = a.address_id)
GROUP BY
	a.district
ORDER BY
	rents_total DESC
LIMIT 10;

-- 9. Modifique la table `inventory_id` agregando una columna `stock` que sea un número
-- entero y representa la cantidad de copias de una misma película que tiene
-- determinada tienda. El número por defecto debería ser 5 copias.
ALTER TABLE inventory ADD COLUMN stock INTEGER DEFAULT 5;

-- 10. Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la tabla rental, 
-- haga un update en la tabla `inventory` restando una copia al stock de la
-- película rentada (Hint: revisar que el rental no tiene información directa sobre la
-- tienda, sino sobre el cliente, que está asociado a una tienda en particular).
CREATE TRIGGER update_stock AFTER
INSERT
	ON
	rental FOR EACH ROW
BEGIN
	UPDATE
	inventory
SET 
			stock = stock - 1
WHERE 
			inventory_id = new.inventory_id
	AND stock > 0;
END;

-- 11. Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El primero es
-- una clave foránea a la tabla rental y el segundo es un valor numérico con dos
-- decimales.
DROP TABLE IF EXISTS fines;

CREATE TABLE IF NOT EXISTS fines (
	rental_id INT NOT NULL AUTO_INCREMENT,
	PRIMARY KEY (rental_id),
	amount DECIMAL(5,2),
	CONSTRAINT fk_rental_id FOREIGN KEY (rental_id)
		REFERENCES rental (rental_id)
);

-- 12. Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree un
-- registro en la tabla `fines` por cada `rental` cuya devolución (return_date) haya tardado más de 3 días 
-- (comparación con rental_date). El valor de la multa será el número de días de retraso multiplicado por 1.5.
CREATE PROCEDURE check_date_and_fine()
	INSERT
	INTO 
		fines (rental_id, amount)
	SELECT 
		rental_id, 
		DATEDIFF(return_date, rental_date)* 1.5 AS difference
	FROM 
		rental
	WHERE 
		DATEDIFF(return_date, rental_date) >= 3;

CALL check_date_and_fine();

-- 13. Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización a la tabla `rental`.
CREATE ROLE employee;

GRANT
INSERT,
DELETE,
UPDATE
	ON
	rental
TO employee;

-- 14. Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que tenga todos los privilegios 
-- sobre la BD `sakila`.
REVOKE
DELETE
	ON
	rental FROM employee;

CREATE ROLE administrator;

GRANT
INSERT,
DELETE,
UPDATE,
SELECT
	ON
	rental TO administrator;

-- 15. Crear dos empleados con acceso local. A uno asignarle los permisos de `employee` y al otro de `administrator`.

