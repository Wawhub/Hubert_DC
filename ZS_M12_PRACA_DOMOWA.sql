

--1.
SELECT schemaname, 
       tablename, 
       't' AS "type",
       tableowner AS "owner"
  FROM pg_catalog.pg_tables pt
  UNION ALL
SELECT schemaname ,
       viewname , 
       'v' AS "type",
       viewowner
  FROM pg_catalog.pg_views pv 
  UNION ALL
SELECT schemaname, 
       tablename,
       'i' AS "type",
       indexname
  FROM pg_catalog.pg_indexes pi2;
  
 

 
 
--2.
CREATE EXTENSION pgcrypto;
 
 SELECT encrypt('ultraSilneHa3l0$567'::bytea, 'pass_salt'::bytea,'aes');


 SELECT crypt('ultraSilneHa3l0$567', gen_salt('md5'));     
 SELECT (case when 
            '$1$sD6GT.Wx$BJosUKZFZ/Yex9W8ev/84.' = crypt('ultraSilneHa3l0$567','$1$sD6GT.Wx$BJosUKZFZ/Yex9W8ev/84.')
            then 'Haslo zgodne'
            else 'Haslo niezgodne'
            end);
 
           
 
--3.

DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers (
id SERIAL,
c_name TEXT,
c_mail TEXT,
c_phone VARCHAR(9),
c_description TEXT
);
INSERT INTO customers (c_name, c_mail, c_phone, c_description)
 VALUES ('Krzysztof Bury', 'kbur@domein.pl', '123789456',
left(md5(random()::text), 15)),
 ('Onufry Zag³oba', 'zagloba@ogniemimieczem.pl',
'100000001', left(md5(random()::text), 15)),
('Krzysztof Bury', 'kbur@domein.pl', '123789456',
left(md5(random()::text), 15)),
('Pan Wo³odyjowski', 'p.wolodyj@polska.pl',
'987654321', left(md5(random()::text), 15)),
('Micha³ Skrzetuski', 'michal<at>zamek.pl',
'654987231', left(md5(random()::text), 15)),
('Bohun Tuhajbejowicz', NULL, NULL,
left(md5(random()::text), 15));


SELECT * FROM customers ;


--a)
 select c_name, c_mail, c_phone
 from customers
 GROUP BY c_name,c_mail, c_phone;


--b) i c)
SELECT id, c_name, 
	   CONCAT(LEFT(c_mail,1), '@',
	   COALESCE( SUBSTRING(c_mail FROM '@(.*)$'),
	   		    SUBSTRING(c_mail FROM '<at>(.*)$'))) as DOMAIN,
	   		   	CONCAT ('XXX XXX', RIGHT(c_phone,3)),
	   		   	c_description
FROM customers;

 

 


 
 
 
 
 