
--1.UtwĂłrz nowy schemat dml_exercises
DROP SCHEMA IF EXISTS dml_exercises CASCADE ;
CREATE SCHEMA dml_exercises;



--2.UtwĂłrz nowÄ… tabelÄ™ sales w schemacie dml_exercises wedĹ‚ug opisu:
--Tabela: sales;
--Kolumny:
--ď‚· id - typ SERIAL, klucz gĹ‚Ăłwny,
--ď‚· sales_date - typ data i czas (data + czÄ™Ĺ›Ä‡ godziny, minuty, sekundy), to pole ma nie
--zawieraÄ‡ wartoĹ›ci nieokreĹ›lonych NULL,
--ď‚· sales_amount - typ zmiennoprzecinkowy (NUMERIC 38 znakĂłw, do 2 znakĂłw po przecinku)
--ď‚· sales_qty - typ zmiennoprzecinkowy (NUMERIC 10 znakĂłw, do 2 znakĂłw po przecinku)
--ď‚· added_by - typ tekstowy (nielimitowana iloĹ›Ä‡ znakĂłw), z wartoĹ›ciÄ… domyĹ›lnÄ… 'admin'
--ď‚· korzystajÄ…c z definiowania przy tworzeniu tabeli, po definicji kolumn, dodaje
--ograniczenie o nazwie sales_less_1k na polu sales_amount typu CHECK takie, ĹĽe
--wartoĹ›ci w polu sales_amount muszÄ… byÄ‡ mniejsze lub rĂłwne 1000
DROP TABLE IF EXISTS dml_exercises.sales;
CREATE TABLE dml_exercises.sales(
			id SERIAL PRIMARY KEY,
			sales_date TIMESTAMP NOT NULL,
			sales_amount NUMERIC(38,2) CONSTRAINT sales_less_1k CHECK (sales_amount <= 1000) ,
			sales_qty NUMERIC(10,2),
			added_by TEXT DEFAULT 'admin'
);




--3.Dodaj to tabeli kilka wierszy korzystajÄ…c ze skĹ‚adni INSERT INTO
--3.1 Tak, aby id byĹ‚o generowane przez sekwencjÄ™
--3.2 Tak by pod pole added_by wpisaÄ‡ wartoĹ›Ä‡ nieokreĹ›lonÄ… NULL
--3.3 Tak, aby sprawdziÄ‡ zachowanie ograniczenia sales_less_1k, gdy wpiszemy wartoĹ›ci wiÄ™ksze od 1000

--INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by) 2019-10-21
--     		VALUES ('2019-10-21 12:12:00', 1200, 100, 'wawhub');

--SQL Error [23514]: BĹ�Ä„D: nowy rekord dla relacji "sales" narusza ograniczenie sprawdzajÄ…ce "sales_less_1k"
--  Detail: Niepoprawne ograniczenia wiersza (1, 2019-10-21 12:12:00, 1200.00, 100.00, wawhub).


INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by)
     		VALUES ('21/10/2020 12:12:00', 999, 100, 'wawhub');
    	
INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by)
     		VALUES ('21/10/2020 12:12:00', 999, 100, NULL);
     	
SELECT *
FROM dml_exercises.sales;




--4. Co zostanie wstawione, jako format godzina (HH), minuta (MM), sekunda (SS), w polu
--sales_date, jak wstawimy do tabeli nastÄ™pujÄ…cy rekord.
INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by)
 			VALUES ('20/11/2019', 101, 50, NULL);
 --WstawiĹ‚o zera w pole godzin, minut i sekund

 		
 		
--5.Jaka bÄ™dzie wartoĹ›Ä‡ w atrybucie sales_date, po wstawieniu wiersza jak poniĹĽej. Jak
--zintepretujesz miesiÄ…c i dzieĹ„, ĹĽeby mieÄ‡ pewnoĹ›Ä‡, o jaki konkretnie chodzi.
INSERT INTO dml_exercises.sales (sales_date, sales_amount,sales_qty, added_by)
 			VALUES ('04/04/2020', 101, 50, NULL);

--2020-04-04 00:00:00
SHOW datestyle;
--DMY Year-Month-Day



--6. Dodaj do tabeli sales wstaw wiersze korzystajÄ…c z poniĹĽszego polecenia
INSERT INTO dml_exercises.sales (sales_date, sales_amount, sales_qty,added_by)
 	   SELECT NOW() + (random() * (interval '90 days')) + '30 days',
              random() * 500 + 1,
              random() * 100 + 1,
       NULL
       FROM generate_series(1, 20000) s(i);


--7.KorzystajÄ…c ze skĹ‚adni UPDATE, zaktualizuj atrybut added_by, wpisujÄ…c mu wartoĹ›Ä‡
--'sales_over_200', gdy wartoĹ›Ä‡ sprzedaĹĽy (sales_amount jest wiÄ™ksza lub rĂłwna 200)

UPDATE dml_exercises.sales 
   SET added_by = 'sales_over_200'
 WHERE sales_amount >= 200;


--8.KorzystajÄ…c ze skĹ‚adni DELETE, usuĹ„ te wiersze z tabeli sales, dla ktĂłrych wartoĹ›Ä‡ w polu
--added_by jest wartoĹ›ciÄ… nieokreĹ›lonÄ… NULL. SprawdĹş rĂłĹĽnicÄ™ miÄ™dzy zapisemm added_by =
--NULL, a added_by IS NULL

DELETE FROM dml_exercises.sales 
WHERE added_by IS NULL;

DELETE FROM dml_exercises.sales 
WHERE added_by = NULL;
--Nie usunelo wartosci


SELECT *
FROM dml_exercises.sales;



--9.WyczyĹ›Ä‡ wszystkie dane z tabeli sales i zrestartuj sekwencje
TRUNCATE TABLE dml_exercises.sales RESTART IDENTITY;


--10.UtwĂłrz kopiÄ™ zapasowÄ… tabeli do pliku. NastÄ™pnie usuĹ„ tabelÄ™ ze schematu dml_exercises i odtwĂłrz jÄ… z kopii zapasowej.

INSERT INTO dml_exercises.sales (sales_date, sales_amount, sales_qty,added_by)
 	   SELECT NOW() + (random() * (interval '90 days')) + '30 days',
              random() * 500 + 1,
              random() * 100 + 1,
       NULL
       FROM generate_series(1, 20000) s(i);


DROP TABLE dml_exercises.sales CASCADE;

SELECT *
FROM dml_exercises.sales;

