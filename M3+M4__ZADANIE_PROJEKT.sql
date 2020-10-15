--Zadanie projektowe Modul 3 oraz 4



--1.Stwórz nowego uzytkownika o nazwie expense_tracker_user z mozliwoscia zalogowania sie do bazy danych i haslem silnym 
DROP ROLE IF EXISTS expense_tracker_user;
CREATE ROLE expense_tracker_user WITH LOGIN PASSWORD '1sniegnadywanie!';


--2.. Korzystajac ze skladni REVOKE, odbierz uprawnienia tworzenia obiektów w schemacie
--public roli PUBLIC
REVOKE CREATE ON SCHEMA public FROM PUBLIC;


--3.3. Jezeli w Twoim srodowisku istnieje juz schemat expense_tracker (z obiektami tabel) usuñ
--go korzystaj¹c z polecenie DROP CASCADE.
DROP SCHEMA IF EXISTS expense_tracker CASCADE;


--Element pozwalajacy odtwarzac strukture bazy
REASSIGN OWNED BY expense_tracker_group TO postgres;
DROP OWNED BY expense_tracker_group;


--4.Utwórz nowa role expense_tracker_group.
DROP ROLE IF EXISTS expense_tracker_group;
CREATE ROLE expense_tracker_group;


--5.Utwórz schemat expense_tracker, korzystajac z atrybutu AUTHORIZATION, ustalajac
--w³asnoœæna rolê expense_tracker_group.
DROP SCHEMA IF EXISTS expense_tracker CASCADE;
CREATE SCHEMA expense_tracker AUTHORIZATION expense_tracker_group;


--6. Dla roli expense_tracker_group dodaj przywilej laczenia do bazy danych postgres i dodaj wszystkie przywileje do schematu expense_tracker
GRANT CONNECT ON DATABASE postgres TO expense_tracker_group;
GRANT ALL PRIVILEGES ON SCHEMA expense_tracker TO expense_tracker_group ;


--7.Dodaj role expense_tracker_group uzytkownikowi expense_tracker_user
GRANT expense_tracker_group TO expense_tracker_user;






DROP TABLE IF EXISTS expense_tracker.bank_account_owner CASCADE;
CREATE TABLE IF NOT EXISTS expense_tracker.bank_account_owner(
	 id_ba_own integer PRIMARY KEY,
	 owner_name varchar(50) NOT NULL ,
	 owner_desc varchar(250),
	 user_login integer NOT NULL,
	 active boolean DEFAULT true NOT NULL  ,
	 insert_date timestamp DEFAULT (current_timestamp),
	 update_date timestamp DEFAULT (current_timestamp)
 );




DROP TABLE IF EXISTS expense_tracker.bank_account_types CASCADE;
CREATE TABLE IF NOT EXISTS expense_tracker.bank_account_types(
	 id_ba_type integer PRIMARY KEY,
	 ba_type varchar(50) NOT NULL ,
	 ba_desc varchar(250),
	 active boolean DEFAULT true NOT NULL  ,
	 is_common_account boolean DEFAULT false NOT NULL  ,
	 id_ba_own integer,
	 insert_date timestamp DEFAULT (current_timestamp),
	 update_date timestamp DEFAULT (current_timestamp),
	 CONSTRAINT bank_account_owner_fk FOREIGN KEY (id_ba_own) REFERENCES expense_tracker.bank_account_owner(id_ba_own)
 );




DROP TABLE IF EXISTS expense_tracker.transaction_bank_accounts CASCADE;
CREATE TABLE IF NOT EXISTS expense_tracker.transaction_bank_accounts(
	 id_trans_ba integer PRIMARY KEY ,
	 id_ba_own integer ,
	 id_ba_typ integer,
	 bank_account_name varchar(50) NOT NULL ,
	 bank_account_desc varchar(250),
	 active boolean DEFAULT TRUE NOT NULL  ,
	 insert_date timestamp DEFAULT (current_timestamp),
	 update_date timestamp DEFAULT (current_timestamp),
	 CONSTRAINT bank_account_owner_fk FOREIGN KEY (id_ba_own) REFERENCES  expense_tracker.bank_account_owner(id_ba_own),
	 CONSTRAINT bank_account_types_fk FOREIGN KEY (id_ba_typ) REFERENCES  expense_tracker.bank_account_types(id_ba_type)
 );




DROP TABLE IF EXISTS expense_tracker.transaction_category CASCADE;
CREATE TABLE IF NOT EXISTS expense_tracker.transaction_category(
	 id_trans_cat integer PRIMARY KEY ,
	 category_name varchar(50) NOT NULL,
	 category_description varchar(250),
	 active boolean DEFAULT TRUE NOT NULL  ,
	 insert_date timestamp DEFAULT (current_timestamp),
	 update_date timestamp DEFAULT (current_timestamp)
  );
 
 
 
 
DROP TABLE IF EXISTS expense_tracker.transaction_subcategory CASCADE;
CREATE TABLE IF NOT EXISTS expense_tracker.transaction_subcategory(
	 id_trans_subcat integer PRIMARY KEY ,
	 id_trans_cat integer,
	 subcategory_name varchar(50) NOT NULL,
	 subcategory_description varchar(250),
	 active boolean DEFAULT TRUE NOT NULL  ,
	 insert_date timestamp DEFAULT (current_timestamp),
	 update_date timestamp DEFAULT (current_timestamp),
	 CONSTRAINT transaction_category_fk FOREIGN KEY (id_trans_cat) REFERENCES  expense_tracker.transaction_category(id_trans_cat)
 );




 DROP TABLE IF EXISTS expense_tracker.transaction_type CASCADE;
 CREATE TABLE IF NOT EXISTS expense_tracker.transaction_type(
 	id_trans_type integer PRIMARY KEY,
 	transaction_type varchar(50) NOT NULL ,
 	transaction_type_desc varchar(250),
 	active boolean DEFAULT TRUE NOT NULL  ,
 	insert_date timestamp DEFAULT (current_timestamp),
 	update_date timestamp DEFAULT (current_timestamp)
 );




DROP TABLE IF EXISTS expense_tracker.users CASCADE;
CREATE TABLE IF NOT EXISTS expense_tracker.users(
	 id_user integer PRIMARY KEY ,
	 user_login varchar(25) NOT NULL ,
	 user_name varchar(50) NOT NULL ,
	 user_password varchar(100) NOT NULL ,
	 password_salt varchar(100) NOT NULL ,
	 active boolean DEFAULT TRUE NOT NULL  ,
	 insert_date timestamp DEFAULT (current_timestamp),
	 update_date timestamp DEFAULT (current_timestamp)
 );




DROP TABLE IF EXISTS expense_tracker.transactions CASCADE;
CREATE TABLE IF NOT EXISTS expense_tracker.transactions(
	 id_transaction integer PRIMARY KEY,
	 id_trans_ba integer ,
	 id_trans_cat integer ,
	 id_trans_subcat integer,
	 id_trans_type integer ,
	 id_user integer,
	 transaction_date date DEFAULT current_date,
	 transaction_value numeric(9,2),
	 TRANSACTION_description text,
	 insert_date timestamp DEFAULT (current_timestamp),
	 update_date timestamp DEFAULT (current_timestamp),
	 CONSTRAINT transaction_bank_accounts_fk FOREIGN KEY (id_trans_ba) REFERENCES expense_tracker.transaction_bank_accounts (id_trans_ba),
	 CONSTRAINT transaction_category_fk FOREIGN KEY (id_trans_cat) REFERENCES expense_tracker.transaction_category(id_trans_cat),
	 CONSTRAINT transaction_subcategory_fk FOREIGN KEY (id_trans_subcat) REFERENCES expense_tracker.transaction_subcategory(id_trans_subcat),
	 CONSTRAINT transaction_type_fk FOREIGN KEY (id_trans_type) REFERENCES expense_tracker.transaction_type(id_trans_type),
	 CONSTRAINT users_fk FOREIGN KEY (id_user) REFERENCES expense_tracker.users(id_user)
 );
 







