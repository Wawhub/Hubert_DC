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
  CREATE OR REPLACE VIEW last_quarter_2020 AS
	SELECT p.product_name,
		   p.product_code,
		   p.product_quantity,
		   p.manufactured_date,
		   EXTRACT(YEAR FROM p.manufactured_date) AS rok ,
		   EXTRACT(quarter FROM p.manufactured_date) AS kwartal
      FROM products p
      JOIN public.product_manufactured_region pmr ON pmr.id = p.product_man_region AND pmr.region_name = 'EMEA'
     WHERE EXTRACT(YEAR FROM p.manufactured_date) = 2020 AND extract(quarter FROM p.manufactured_date) = 4;
    
      
    
      
--2.
CREATE  MATERIALIZED VIEW last_quarter_2020_2 AS
	SELECT s2.*,
		p.product_name,
		   p.product_code,
		   p.product_quantity,
		   p.manufactured_date,
		   sum(s2.sal_value) over(PARTITION BY p.product_code ORDER BY s2.sal_date) AS suma_sprzedazy
      FROM products p
      JOIN public.sales s2 
      		ON s2.sal_prd_id = p.id 
      JOIN public.product_manufactured_region pmr 
      		ON pmr.id = p.product_man_region 
      		AND pmr.region_name = 'EMEA'
      WHERE EXTRACT(YEAR FROM s2.sal_date) = 2020 
     		AND extract(quarter FROM s2.sal_date) = 4
      WITH DATA;
       
     CREATE UNIQUE INDEX idx_last_quarter_2020_2_id 
     					ON last_quarter_2020_2 (id);
      
    
     				
     				
 --3.
       SELECT p.product_code,
     		pmr.region_name,
     		array_agg(p.product_name) AS products_names
       FROM products p
  LEFT JOIN product_manufactured_region pmr 
  			ON pmr.id = p.product_man_region 
       GROUP BY p.product_code, pmr.region_name;  
      
      
      
      
  --4.
CREATE TABLE kod_region_nazwa_lista AS 
			WITH kod_region_nazwa AS (  
    			 SELECT p.product_code,
     					pmr.region_name,
     					array_agg(p.product_name) AS nazwa_produktow
       		     FROM products p
            LEFT JOIN product_manufactured_region pmr 
            		  ON pmr.id = p.product_man_region 
                 GROUP BY p.product_code, pmr.region_name
) SELECT krn.*,
		 CASE  (array_length(krn.nazwa_produktow,1)) > 1
		    WHEN TRUE THEN TRUE 
		 	ELSE 
		 	FALSE
		 END powtarzajace_produkty
  FROM kod_region_nazwa krn;
  
   
  
  
   --5.
  
  CREATE TABLE sales_archive (
	id SERIAL,
	sal_description TEXT,
	sal_date DATE,
	sal_value NUMERIC(10,2),
	sal_prd_id INTEGER,
	added_by TEXT DEFAULT 'admin',
	operation_type VARCHAR(1) NOT NULL,
	archived_at TIMESTAMP DEFAULT NOW()
	
);
  
  
  
--6.

  CREATE FUNCTION poprzednie_wartosci() 
   RETURNS TRIGGER 
   LANGUAGE plpgsql
	AS $$
		BEGIN
	        IF (TG_OP = 'DELETE') THEN
	            INSERT INTO sales_archive (operation_type,sal_description, sal_date, sal_value, sal_prd_id )
	                 VALUES ('D', OLD.sal_description, OLD.sal_date, OLD.sal_value, OLD.sal_prd_id);
	        ELSIF (TG_OP = 'UPDATE') THEN
	            INSERT INTO sales_archive (operation_type, sal_description, sal_date, sal_value, sal_prd_id)
	                 VALUES ('U',OLD.sal_description, OLD.sal_date, OLD.sal_value, OLD.sal_prd_id);
	        END IF;
	        RETURN NULL; 
		END;
	$$;
		
CREATE TRIGGER inwentaryzacja_trigger 
	AFTER INSERT OR UPDATE OR DELETE
   	ON sales
	FOR EACH ROW 
    EXECUTE PROCEDURE poprzednie_wartosci();
   
  
  DELETE FROM sales s
	  WHERE EXTRACT(YEAR FROM s.sal_date) = 2020 AND extract(MONTH FROM s.sal_date) = 10; 
	 
SELECT * FROM sales_archive;
  

  
      
      