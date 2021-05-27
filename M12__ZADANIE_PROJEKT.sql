

--1.
UPDATE expense_tracker.users  SET user_password = crypt(user_password, gen_salt('md5'));
ALTER TABLE  expense_tracker.users DROP COLUMN password_salt;

--2.
--a)Zobacz ile wierszy dla tabel posiadaj¹cych klucze obce ma w sobie wartoœæ -1 (<unknown>).


--Sprawdzenie zawartosci schematu 
SELECT * 
  FROM pg_catalog.pg_tables pt
 WHERE schemaname = 'expense_tracker';
 


--Sprawdzenie która tabela zawiera klucz obcy
--Kombinowalem tu bardzo dlugo aby wyciagnac w jakiej kolumnie jest ten klucz, ale bezskutecznie

SELECT  DISTINCT tcc.table_name 
FROM information_schema.table_constraints tcc   											 
WHERE tcc.constraint_type like 'FOREIGN KEY' AND tcc.table_schema = 'expense_tracker' 



-- Zliczanie wartoœci (<unknown>) w wierszach tabel

SELECT count(*)
FROM expense_tracker.bank_account_types bat 
WHERE bat.id_ba_type = -1;

SELECT count(*)
FROM expense_tracker.transaction_bank_accounts tba 
WHERE tba.id_trans_ba = -1;

SELECT count(*)
FROM expense_tracker.transaction_subcategory ts 
WHERE ts.id_trans_subcat = -1;

SELECT count(*)
FROM expense_tracker.transactions t 
WHERE t.id_transaction = -1;


SELECT count(*)
FROM expense_tracker.transactions_partitioned tp 
WHERE tp.id_transaction = -1;



--b)Czy w atrybutach tabeli TRANSACTIONS s¹ wartoœci nieokreœlone (NULL) - na jakich atrybutach? Jaki procent ca³ego zbioru danych one stanowi¹?


WITH dane AS (select
(SELECT count (*) FROM expense_tracker.transactions t )*(select count(*) from information_schema."columns" c  where table_name ='transactions') AS ilosc_rekordow,
	SUM(CASE WHEN id_transaction IS NULL THEN 1 ELSE 0 END) + 
	SUM(CASE WHEN id_trans_ba IS NULL THEN 1 ELSE 0 END) +
	SUM(CASE WHEN id_trans_cat IS NULL THEN 1 ELSE 0 END) +
	SUM(CASE WHEN id_trans_subcat IS NULL THEN 1 ELSE 0 END) +
	SUM(CASE WHEN id_trans_type IS NULL THEN 1 ELSE 0 END) +
	SUM(CASE WHEN id_user IS NULL THEN 1 ELSE 0 END) +
	SUM(CASE WHEN transaction_date IS NULL THEN 1 ELSE 0 END) +
	SUM(CASE WHEN transaction_value  IS NULL THEN 1 ELSE 0 END) +
	SUM(CASE WHEN transaction_description IS NULL THEN 1 ELSE 0 END) +
	SUM(CASE WHEN insert_date IS NULL THEN 1 ELSE 0 END) +
	SUM(CASE WHEN update_date IS NULL THEN 1 ELSE 0 END) AS ilosc_nulli
	FROM expense_tracker.transactions t)
SELECT  ilosc_rekordow, ilosc_nulli , ilosc_nulli::float / ilosc_rekordow*100 AS wynik FROM dane;



--3.
--Z doœwiadzcenia, które naby³em w pracy mogê œmia³o stwierdzic iz lepiej, aby ka¿de œrodowisko (rodzina) mia³a swój osobny schemat, poniewa¿:
--W przypadku jakichkolwiek problemów wy³aczamy tylko jedn¹ rodzine, a reszta dziala bez problemu
--Moga przytrafic sie sytuacje w ktorej klient bedzie chcial wprowadzic jakies drobne modyfikacje. Generealnie z zalozenia ma byc to produkt o scisle okreslonych elementach. Jednak jesli ktos dobrze placi, to
--byc moze warto dla niego zlamac ta zasade. Oczywiscie w granicach rozsadku, aby nie miec 1000 roznych rozwiazan. 
--Dzieki trzymaniu kazdej rodziny  w osobnym schemacie, mozemy korzystac z uniwersalnych struktur. Majac wszystko w jednym schemacie, zapewne musielibysmy dodawac przed nazwe tabeli nazwisko rodziny aby je rozrozniac.

--Mysle, ze w kwestii uzytkownikow stworzylbym konto lokalnego admina (Glowa rodziny, albo ten najstarszy syn, co troche zna te komputery :)  ). Natomiast mialby on dostep tylko do resetu hasla. Dodawanie 
--uzytkownikow zostawilbym dla siebie, poniewaz rodzina definiuje ilosc czlonkow przy zakupie produktu. A raczej nie przybedzie nagle 10 dzieci Pani Grazynce, aby musiala je co chwile dopisywac. Dajac im calkowita 
--kontrole moglo by dojsc do sporego balaganu.


-- Usunalbym kolumne password_salt
-- Nie usuwa³bym ¿adnych kluczy obcych
-- Jesli produkt bedzie uzywany przez kilka lat, to warto wprowadzic partycjonowanie tabeli transaction, poniewaz bedzie ona miala ogromne ilosci danych
-- Wprowadzilbym triggery na bardziej znaczacych tabelach jak users czy transaction_bank_account aby automatycznie tworzyc kopie zapasowa nadpisywanych danych
-- Na sam koniec stworzylbym raport Qlikview, ktory podliczalby ile Grazynka wydaje na waciki :)



--4.Zostawilem dane , poniewaz latwiej jest mi przypominac sobie zasade dzialania, gdy mam kompletny przyklad :)

--Utworzenie schematu 
CREATE SCHEMA nazwa_schematu;
--Usuwanie schematu
DROP SCHEMA IF EXISTS nazwa_schematu CASCADE;

--Stworzenie nowego uzytkownika z mozliwoscoia zalogowania si? do bazy danych i haslem
DROP ROLE IF EXISTS expense_tracker_user;
CREATE ROLE expense_tracker_user WITH LOGIN PASSWORD '1sniegnadywanie!';

--Odbieranie uprawnien tworzenia obiketow w schemacie
REVOKE CREATE ON SCHEMA public FROM PUBLIC;

--Tworzenie nowej roli
DROP ROLE IF EXISTS expense_tracker_group;
CREATE ROLE expense_tracker_group;

--Nadawwanie przywileju laczenia sie do bazy danych dla danej roli
GRANT CONNECT ON DATABASE postgres TO expense_tracker_group;
GRANT ALL PRIVILEGES ON SCHEMA expense_tracker TO expense_tracker_group ;


--Utworzenie tabeli
DROP TABLE IF EXISTS expense_tracker.bank_account_types CASCADE;
CREATE TABLE IF NOT EXISTS expense_tracker.bank_account_types(
	 id_ba_type serial PRIMARY KEY,
	 ba_type varchar(50) NOT NULL ,
	 ba_desc varchar(250),
	 active boolean DEFAULT true NOT NULL  ,
	 is_common_account boolean DEFAULT false NOT NULL  ,
	 id_ba_own integer,
	 insert_date timestamp DEFAULT (current_timestamp),
	 update_date timestamp DEFAULT (current_timestamp),
	 CONSTRAINT bank_account_owner_fk FOREIGN KEY (id_ba_own) REFERENCES expense_tracker.bank_account_owner(id_ba_own)
 );


--Insertowanie danych do tabeli
INSERT INTO expense_tracker.bank_account_owner (id_ba_own,owner_name,owner_desc,user_login)
 			VALUES (1, 'wawhub','Hubert',99);
 		

 		
 		
 --Tworzenie kluczy podczas definiowania tabeli
 CONSTRAINT bank_account_owner_fk FOREIGN KEY (id_ba_own) REFERENCES expense_tracker.bank_account_owner(id_ba_own)
 
 		
 		
--Tworzenie indexow
create index nazwa_indexu on expense_tracker.transaction_category (category_name); 		
 		
 		
 		
--Tworzenie partycji
CREATE TABLE IF NOT EXISTS EXPENSE_TRACKER.TRANSACTIONS_PARTITIONED ( 
        ID_TRANSACTION serial, 
        ID_TRANS_BA integer REFERENCES EXPENSE_TRACKER.TRANSACTION_BANK_ACCOUNTS (ID_TRANS_BA), 
        ID_TRANS_CAT integer REFERENCES EXPENSE_TRACKER.TRANSACTION_CATEGORY (ID_TRANS_CAT), 
        ID_TRANS_SUBCAT integer REFERENCES EXPENSE_TRACKER.TRANSACTION_SUBCATEGORY (ID_TRANS_SUBCAT),
        ID_TRANS_TYPE integer REFERENCES EXPENSE_TRACKER.TRANSACTION_TYPE (ID_TRANS_TYPE), 
        ID_USER integer REFERENCES EXPENSE_TRACKER.USERS (ID_USER), 
        TRANSACTION_DATE date default current_date, 
        TRANSACTION_VALUE numeric(9,2), 
        TRANSACTION_DESCRIPTION text, INSERT_DATE timestamp default current_timestamp, 
        UPDATE_DATE timestamp default current_timestamp,
        primary key (ID_TRANSACTION, TRANSACTION_DATE) )
        PARTITION BY RANGE(TRANSACTION_DATE);
      
      CREATE TABLE transactions_y2015 PARTITION OF EXPENSE_TRACKER.TRANSACTIONS_PARTITIONED
 FOR VALUES FROM ('2015-01-01') TO ('2016-01-01');
CREATE TABLE transactions_y2016 PARTITION OF EXPENSE_TRACKER.TRANSACTIONS_PARTITIONED
 FOR VALUES FROM ('2016-01-01') TO ('2017-01-01');

CREATE TABLE transactions_y2017 PARTITION OF EXPENSE_TRACKER.TRANSACTIONS_PARTITIONED
 FOR VALUES FROM ('2017-01-01') TO ('2018-01-01');
CREATE TABLE transactions_y2018 PARTITION OF EXPENSE_TRACKER.TRANSACTIONS_PARTITIONED
 FOR VALUES FROM ('2018-01-01') TO ('2019-01-01');
CREATE TABLE transactions_y2019 PARTITION OF EXPENSE_TRACKER.TRANSACTIONS_PARTITIONED
 FOR VALUES FROM ('2019-01-01') TO ('2020-01-01');

CREATE TABLE transactions_y2020 PARTITION OF EXPENSE_TRACKER.TRANSACTIONS_PARTITIONED
 FOR VALUES FROM ('2020-01-01') TO ('2021-01-01'); 		
 		
 		
 		

 		

--Tworzenie widoku bazodanowego
CREATE OR REPLACE VIEW expense_tracker.transactions_janusz AS
SELECT t.id_trans_type , 
				t.transaction_date,
				EXTRACT(YEAR FROM t.transaction_date),
				t.transaction_value,
				tc.category_name, 
				ts.subcategory_name,
				tba.bank_account_name,
				bao.owner_name,
				tt.transaction_type_name 
FROM expense_tracker.transaction_bank_accounts tba 
	JOIN  expense_tracker.transactions t 
			ON tba.id_trans_ba = t.id_trans_ba 
	JOIN expense_tracker.transaction_category tc 
			ON tc.id_trans_cat = t.id_trans_cat
  JOIN expense_tracker.transaction_subcategory ts 
  			ON ts.id_trans_subcat = t.id_trans_subcat
            AND ts.id_trans_cat = tc.id_trans_cat	
   JOIN expense_tracker.bank_account_owner bao ON bao.id_ba_own = tba.id_ba_own 
      JOIN expense_tracker.transaction_type tt ON tt.id_trans_type = t.id_trans_type 
           WHERE bao.owner_name = 'Janusz Kowalski';	 		
 		
 		
          
          
--Tworzenie widoku zmaterializowanego
CREATE  MATERIALIZED VIEW expense_tracker.transactions_janusz_materials AS
SELECT t.id_trans_type , 
				t.transaction_date,
				EXTRACT(YEAR FROM t.transaction_date),
				t.transaction_value,
				tc.category_name, 
				ts.subcategory_name,
				tba.bank_account_name,
				bao.owner_name,
				tt.transaction_type_name 
FROM expense_tracker.transaction_bank_accounts tba 
	JOIN  expense_tracker.transactions t 
			ON tba.id_trans_ba = t.id_trans_ba 
	JOIN expense_tracker.transaction_category tc 
			ON tc.id_trans_cat = t.id_trans_cat
  JOIN expense_tracker.transaction_subcategory ts 
  			ON ts.id_trans_subcat = t.id_trans_subcat
            AND ts.id_trans_cat = tc.id_trans_cat	
   JOIN expense_tracker.bank_account_owner bao ON bao.id_ba_own = tba.id_ba_own 
      JOIN expense_tracker.transaction_type tt ON tt.id_trans_type = t.id_trans_type 
           WHERE bao.owner_name = 'Janusz Kowalski';
      		
 		
 	
 		
 --Tworzenie funkcji z triggerem
 		CREATE FUNCTION expense_tracker.finance_control() 
   RETURNS TRIGGER 
   LANGUAGE plpgsql
	AS $$
		BEGIN
	      	IF (TG_OP = 'UPDATE') THEN
				UPDATE expense_tracker.monthly_budget_planned
				   SET left_budget = left_budget + OLD.transaction_value;
			ELSEIF (TG_OP = 'INSERT') THEN
				UPDATE expense_tracker.monthly_budget_planned
				   SET left_budget = left_budget + NEW.transaction_value;
		    ELSEIF (TG_OP = 'DELETE') THEN 
				UPDATE expense_tracker.monthly_budget_planned
				   SET left_budget = left_budget + CASE
				  										WHEN OLD.transaction_value < 0 THEN OLD.transaction_value * -1
				  										ELSE OLD.transaction_value
				  									END;
	        END IF;
	        RETURN NULL; 
		END;
	$$;
		
CREATE TRIGGER finance_control_trigger
	AFTER INSERT OR UPDATE OR DELETE
   	ON expense_tracker.transactions 
	FOR EACH ROW 
    EXECUTE PROCEDURE expense_tracker.finance_control();
   








