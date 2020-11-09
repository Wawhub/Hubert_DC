DROP TABLE IF EXISTS products, sales, product_manufactured_region CASCADE;

CREATE TABLE products (
	id SERIAL,
	product_name VARCHAR(100),
	product_code VARCHAR(10),
	product_quantity NUMERIC(10,2),	
	manufactured_date DATE,
	product_man_region INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE sales (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	created_date TIMESTAMP DEFAULT now()
);

CREATE TABLE product_manufactured_region (
	id SERIAL,
	region_name VARCHAR(25),
	region_code VARCHAR(10),
	established_year INTEGER
);

INSERT INTO product_manufactured_region (region_name, region_code, established_year)
	  VALUES ('EMEA', 'E_EMEA', 2010),
	  		 ('EMEA', 'W_EMEA', 2012),
	  		 ('APAC', NULL, 2019),
	  		 ('North America', NULL, 2012),
	  		 ('Africa', NULL, 2012);

INSERT INTO products (product_name, product_code, product_quantity, manufactured_date, product_man_region)
     SELECT 'Product '||floor(random() * 10 + 1)::int,
            'PRD'||floor(random() * 10 + 1)::int,
            random() * 10 + 1,
            CAST((NOW() - (random() * (interval '90 days')))::timestamp AS date),
            CEIL(random()*(10-5))::int
       FROM generate_series(1, 10) s(i);  
      
INSERT INTO sales (sal_description, sal_date, sal_value, sal_prd_id)
     SELECT left(md5(i::text), 15),
     		CAST((NOW() - (random() * (interval '60 days'))) AS DATE),	
     		random() * 100 + 1,
        	floor(random() * 10)+1::int            
       FROM generate_series(1, 10000) s(i);  
       
      
      
      --1.
      SELECT s2.*,
      		 p.*, 
      		 pmr2.*
      FROM sales s2 
      INNER JOIN products p 
      		ON p.id = s2.sal_prd_id
      INNER JOIN product_manufactured_region pmr2 
      		ON pmr2.id = p.product_man_region 
      		AND pmr2.region_name = 'EMEA'
      LIMIT 100;
     
      
     
      --2.
     SELECT  p.*, 
     		 pmr.region_name 
     FROM products p
     LEFT JOIN product_manufactured_region pmr 
    		ON pmr.id = p.product_man_region 
    		AND pmr.established_year > 2012;
      
    
      --3.
     SELECT  p.*, 
     		 pmr.region_name 
     FROM products p
     LEFT JOIN product_manufactured_region pmr 
     		ON pmr.id = p.product_man_region 
     WHERE pmr.established_year > 2012;
      
      
    --4.
    
    SELECT DISTINCT 
     		p2.product_name,
     		EXTRACT(YEAR FROM s.sal_date)||'_'||EXTRACT(MONTH FROM s.sal_date) AS ROK_MIESIAC
     FROM sales s
     RIGHT JOIN (SELECT p.* FROM products p WHERE p.product_quantity >5) p2 ON p2.id = s.sal_prd_id 
     ORDER BY p2.product_name DESC;
     
    
     --5.
      
INSERT INTO product_manufactured_region (region_name, region_code, established_year)
	  VALUES ('Australia', 'AUS', 2020);
	  		 
      SELECT p.*, 
      		 pmr.*
      FROM products p 
      FULL JOIN product_manufactured_region pmr 
      			ON pmr.id = p.product_man_region 
      ORDER BY 1 ;
      
      
     
      --6.
      SELECT p.*,
 	 		pmr.*
     FROM products p 
     LEFT JOIN product_manufactured_region pmr 
     		ON pmr.id = p.product_man_region 
     UNION 
     SELECT p.*,
      		pmr.*
     FROM products p 
     RIGHT JOIN product_manufactured_region pmr 
    		 ON pmr.id = p.product_man_region  ;
      
      
      
      --7.
      
      WITH product_over_5 AS (SELECT p.* FROM products p WHERE p.product_quantity >5)
      SELECT DISTINCT 
     		p2.product_name,
     		EXTRACT(YEAR FROM s.sal_date)||'_'||EXTRACT(MONTH FROM s.sal_date) AS ROK_MIESIAC
     FROM sales s
     RIGHT JOIN product_over_5 p2 
     	   ON p2.id = s.sal_prd_id 
     ORDER BY p2.product_name DESC;
     

   --8.
 
   DELETE FROM products p
      WHERE EXISTS (SELECT 1 
					  FROM products p1
					  JOIN product_manufactured_region pmr 
					  	ON pmr.id = p1.id
					   	   AND pmr.id = p1.product_man_region 
					   	   AND pmr.region_code = 'E_EMEA'  
					   	   AND pmr.region_name = 'EMEA' 									
				   )
  RETURNING *;
   
      