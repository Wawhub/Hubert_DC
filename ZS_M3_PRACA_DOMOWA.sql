
CREATE SCHEMA training;
ALTER SCHEMA training RENAME TO training_zs;



CREATE TABLE training_zs.products (
id integer,
production_qty NUMERIC(10,2),
product_name varchar(100),
product_code varchar(10),
description text,
manufacturing_date date
);



ALTER TABLE training_zs.products  ADD PRIMARY KEY (id); 
DROP TABLE IF EXISTS training_zs.sales;



CREATE TABLE training_zs.sales (
id integer PRIMARY KEY,
sales_date timestamp NOT NULL, 
sales_amount NUMERIC(38,2) CONSTRAINT sales_over_1k CHECK (sales_amount > 1000) ,
sales_qty NUMERIC(10,2),
product_id integer,
added_by TEXT DEFAULT 'admin'
);


ALTER TABLE training_zs.sales ADD FOREIGN KEY (product_id) REFERENCES training_zs.products (id) ON DELETE CASCADE;

DROP SCHEMA training_zs CASCADE;


