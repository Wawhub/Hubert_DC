
--1.

SELECT s.*,
	p.product_name,
	p.product_code,
	p.product_name,
	pmr.region_name 
FROM sales s
LEFT JOIN products p ON p.id = s.sal_prd_id  
LEFT JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
WHERE s.sal_date BETWEEN (now() - (INTERVAL '2 months')) AND now()
				 AND p.product_code LIKE 'PRD8';
				 
		
--2.
DISCARD ALL;
EXPLAIN ANALYZE 				
				
SELECT s.*,
	p.product_name,
	p.product_code,
	p.product_name,
	pmr.region_name 
FROM sales s
LEFT JOIN products p ON p.id = s.sal_prd_id  
LEFT JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
WHERE s.sal_date BETWEEN (now() - (INTERVAL '2 months')) AND now()
				 AND p.product_code LIKE 'PRD8';
				
				
-- Skan sekwencyjny, nie u¿ywamy indexu 
-- Wystepuja 3 skany
-- Filtr where wykluczyl 9 wierszy
-- Uzycie pamieci przy kazdym z skanow to 9kB
-- algorytm zlaczenia hash join 
-- Czas planowania to 0.346 ms, natomiast czas wykonania to 1505.081 ms


				
--3.
SELECT 
count(DISTINCT product_code) unikatowe_kody,
count(*) wszystkie_kody,
count(DISTINCT product_code)::float / count(*) AS selektywnosc
FROM products AS selectivity; 

--4.

CREATE INDEX index_products_product_code ON products USING btree(product_code);
DROP INDEX index_products_product_code;

--5.

DISCARD ALL;
EXPLAIN ANALYZE 				
				
SELECT s.*,
	p.product_name,
	p.product_code,
	p.product_name,
	pmr.region_name 
FROM sales s
LEFT JOIN products p ON p.id = s.sal_prd_id  
LEFT JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
WHERE s.sal_date BETWEEN (now() - (INTERVAL '2 months')) AND now()
				 AND p.product_code LIKE 'PRD8';
				
--Plan zapytania nadal nie u¿ywa indexu

				
--6.

CREATE INDEX index_sales_sal_date ON sales USING btree(sal_date);
DROP INDEX index_sales_sal_date;

--7.
DISCARD ALL;
EXPLAIN ANALYZE 				
				
SELECT s.*,
	p.product_name,
	p.product_code,
	p.product_name,
	pmr.region_name 
FROM sales s
LEFT JOIN products p ON p.id = s.sal_prd_id  
LEFT JOIN product_manufactured_region pmr ON pmr.id = p.product_man_region 
WHERE s.sal_date BETWEEN (now() - (INTERVAL '2 months')) AND now()
				 AND p.product_code LIKE 'PRD8';
				
--W dalszym ciagu indexy nie s¹ uzywane		


--8.
DROP TABLE IF EXISTS sales, sales_partitioned CASCADE;

CREATE TABLE sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);
  
CREATE TABLE sales_partitioned (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
) PARTITION BY RANGE (sal_date);

CREATE TABLE sales_y2018 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2018-01-01') TO ('2019-01-01');

CREATE TABLE sales_y2019 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');
   
CREATE TABLE sales_y2020 PARTITION OF sales_partitioned
    FOR VALUES FROM ('2020-01-01') TO ('2021-01-01');

EXPLAIN ANALYZE
INSERT INTO sales (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 1000000) s(i);     

EXPLAIN ANALYZE
INSERT INTO sales_partitioned (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 1000000) s(i);         

--Insert do tabeli partycjonowanej odbywa siê dluzej, poniewaz zapytanie musi dopasowac wstawiana wartosc do danej partycji				

				