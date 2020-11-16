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
      SELECT pmr.region_name, avg(p.product_quantity) AS srednia
      FROM products p 
     		LEFT JOIN product_manufactured_region pmr 
     				ON pmr.id  = p.product_man_region 
      GROUP BY pmr.region_name 
      ORDER BY srednia DESC;
      
  
      --2.
      SELECT pmr.region_name, STRING_AGG ( p.product_name, ',' ORDER BY p.product_name ASC)
      FROM products p 
     		LEFT JOIN product_manufactured_region pmr
     				ON pmr.id  = p.product_man_region 
      GROUP BY pmr.region_name ;
      
      
       --3.
      SELECT pmr.region_name , p2.product_name , count (s.id)
      FROM sales s 
       		JOIN products p2 
       			ON p2.id  = s.sal_prd_id 
            JOIN product_manufactured_region pmr 
       			ON pmr.id  = p2.product_man_region  
                AND pmr.region_name = 'EMEA'
      GROUP BY p2.product_name, pmr.region_name ;
     
     
       --4.
       SELECT sum(s.sal_value) sprzedaz,	
     		  EXTRACT(YEAR FROM s.sal_date)||'_'||EXTRACT(MONTH FROM s.sal_date) AS ROK_MIESIAC
       FROM sales s
       GROUP BY ROK_MIESIAC
       ORDER BY sprzedaz DESC;
  
  
  
       --5.
       SELECT p.product_code, EXTRACT(YEAR FROM p.manufactured_date) AS ROK, 
       		  pmr.region_name,
              GROUPING(p.product_code, 
			         EXTRACT(YEAR FROM p.manufactured_date), 
		             pmr.region_name) AS grupy_do_grupoweania,
    	      AVG(p.product_quantity) AS srednia
       FROM products p 
     		JOIN product_manufactured_region pmr 
     			ON pmr.id  = p.product_man_region 
       GROUP BY GROUPING SETS (p.product_code,
						ROK,
					    pmr.region_name); 
      
      
		--6.

	   SELECT p.product_name,
    	    p.product_code,
    	    p.manufactured_date,
    	    p.product_man_region,
    	    pmr.region_name,
    	    sum(p.product_quantity) OVER (PARTITION BY pmr.region_name)
       FROM products p
  LEFT JOIN product_manufactured_region pmr 
 			ON pmr.id = p.product_man_region; 				   
					   
					   
          --7.
		WITH ilosc_produktu AS (
		SELECT p.product_name,
	    	   p.product_code,
	    	   p.manufactured_date,
	    	   p.product_man_region,
	    	   pmr.region_name,
	    	   sum(p.product_quantity) OVER (PARTITION BY pmr.region_name) AS suma_per_region
	      FROM products p
	 LEFT JOIN product_manufactured_region pmr 
	 			ON pmr.id = p.product_man_region),
		 ranking_produktu AS (
  		 SELECT product_name,
		 region_name,
		 suma_per_region,
		 DENSE_RANK() OVER (ORDER BY suma_per_region DESC) rank_d
  	  FROM ilosc_produktu)
	 SELECT product_name,
		 region_name,
		 suma_per_region
    	FROM ranking_produktu
 	    WHERE rank_d = 2;					   
					   
					   
					   
					   
				