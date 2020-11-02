DROP TABLE IF EXISTS products;
CREATE TABLE products (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),
	manufactured_date DATE,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);


INSERT INTO products (product_name, product_code, product_quantity,
manufactured_date)
 SELECT 'Product '||floor(random() * 10 + 1)::int,
 'PRD'||floor(random() * 10 + 1)::int,
 random() * 10 + 1,
 CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date)
 FROM generate_series(1, 10) s(i);



DROP TABLE IF EXISTS sales;
CREATE TABLE sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_qty NUMERIC(10,2),
	sal_product_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);


INSERT INTO sales (sal_description, sal_date, sal_value, sal_qty, sal_product_id)
 SELECT left(md5(i::text), 15),
 CAST((NOW() - (random() * (interval '60 days'))) AS DATE),
 random() * 100 + 1,
 floor(random() * 10 + 1)::int,
 floor(random() * 10)::int
 FROM generate_series(1, 10000) s(i);
 


--1.
SELECT DISTINCT manufactured_date 
FROM products
ORDER BY manufactured_date ;

--2.

--Najpierws sprawdzam ile jest ogólnie rekordów 

SELECT product_code 
FROM products;

--Nastêpnie sprawdzam ile jest unikatowych kodów produktu

SELECT DISTINCT product_code 
FROM products;

--Jednak jest to podejœcie dobre dla ma³ej iloœci rekordów. Mozna to zrobic lepiej

SELECT count(product_code) AS Liczba_ogolna,
	   count(DISTINCT product_code) AS Liczba_unikatowych
FROM products;

--3.

SELECT product_code	   
FROM products
WHERE product_code IN ('PRD1','PRD9');


--4.

SELECT *
FROM sales
WHERE sal_date BETWEEN '2020-08-01' AND '2020-08-31'
ORDER BY sal_value DESC, sal_date ;


--5.

SELECT *
FROM products p
WHERE NOT EXISTS (SELECT 1 FROM sales s WHERE s.sal_product_id = p.id);


--6.

SELECT *
FROM products p 
WHERE p.id = ANY (SELECT sal_product_id 
				  FROM sales s
  				  WHERE s.sal_value > 100);

--7.

DROP TABLE IF EXISTS PRODUCTS_OLD_WAREHOUSE;
CREATE TABLE PRODUCTS_OLD_WAREHOUSE (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),
	manufactured_date DATE,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);


INSERT INTO PRODUCTS_OLD_WAREHOUSE (product_name, product_code, product_quantity,
manufactured_date)
 SELECT 'Product '||floor(random() * 10 + 1)::int,
 'PRD'||floor(random() * 10 + 1)::int,
 random() * 10 + 1,
 CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date)
 FROM generate_series(1, 10) s(i);



SELECT *
FROM PRODUCTS_OLD_WAREHOUSE;

--8.	
SELECT po.product_name, po.product_code
FROM products_old_warehouse po
UNION 
SELECT p.product_name, p.product_code
FROM products p;


SELECT po.product_name, po.product_code
FROM products_old_warehouse po
UNION ALL
SELECT p.product_name, p.product_code
FROM products p;

-- w tym przypadku union zwróci³o jeden rekord mniej ni¿ union all bo po prostu tak sie z³o¿y³o, ¿e losowane rekordy tylko raz siê na³o¿y³y


--9

SELECT po.product_code
FROM products_old_warehouse po
EXCEPT 
SELECT p.product_code
FROM products p; 


--10.

SELECT s.*
FROM sales s
ORDER BY sal_value DESC
LIMIT 10;

--11.
SELECT SUBSTRING(s.sal_description,1,3), s.*
FROM sales s
LIMIT 3;


--12.

SELECT s.*
FROM sales s 
WHERE sal_description LIKE 'c4c%';
