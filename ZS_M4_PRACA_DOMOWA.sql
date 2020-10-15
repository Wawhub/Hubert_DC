
--1.Korzystaj¹c ze sk³adni CREATE ROLE, stwórz nowego u¿ytkownika o nazwie user_training z
--mo¿liwoœci¹ zalogowania siê do bazy danych i has³em silnym
DROP ROLE IF EXISTS user_training;
CREATE ROLE user_training WITH LOGIN PASSWORD '1sniegnadywanie!';


--2.Korzystaj¹c z atrybutu AUTHORIZATION dla sk³adni CREATE SCHEMA. Utwórz schemat
--training, którego w³aœcicielem bêdzie u¿ytkownik user_training.
DROP SCHEMA IF EXISTS training ;
CREATE SCHEMA training AUTHORIZATION user_training;


--3.Bêd¹c zalogowany na super u¿ytkowniku postgres, spróbuj usun¹æ rolê (u¿ytkownika)user_training.
DROP ROLE user_training;
--nie mo¿na usun¹æ, poniewa¿ istniej¹ obiekty zale¿ne


--4.Przeka¿ w³asnoœæ nad utworzonym dla / przez u¿ytkownika user_training obiektami na role postgres. Nastêpnie usuñ role user_training.
REASSIGN OWNED BY user_training TO postgres;
DROP OWNED BY user_training;
DROP ROLE user_training;


--5.Utwórz now¹ rolê reporting_ro, która bêdzie grup¹ dostêpów, dla u¿ytkowników warstwy analitycznej o nastêpuj¹cych przywilejach:
-- dostêp do bazy, schematu, tworzenia obiektów w schemacie training oraz dostêp do wszystkich uprawnieñ do tabel w schemacie training
CREATE ROLE reporting_ro;
GRANT CONNECT ON DATABASE postgres TO reporting_ro;
GRANT CREATE,USAGE ON SCHEMA training TO reporting_ro;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA training TO reporting_ro;


--6.Utwórz nowego u¿ytkownika reporting_user z mo¿liwoœci¹ logowania siê do bazy danych i
--haœle silnym :) (coœ wymyœl). Przypisz temu u¿ytkownikowi role reporting ro
CREATE ROLE reporting_user WITH LOGIN PASSWORD '1sniegnadywanie!';
GRANT reporting_ro TO reporting_user;


--7.Bêd¹c zalogowany na u¿ytkownika reporting_user, spróbuj utworzyæ now¹ tabele (dowoln¹) w schemacie training.
DROP TABLE IF EXISTS training.nowa;
CREATE TABLE training.nowa (id Integer);
--uda³o siê utworzyæ


--8.Zabierz uprawnienia roli reporting_ro do tworzenia obiektów w schemacie training
REVOKE CREATE ON SCHEMA training FROM reporting_ro;


--9.Zaloguj siê ponownie na u¿ytkownika reporting_user, sprawdŸ czy mo¿esz utworzyæ now¹
--tabelê w schemacie training oraz czy mo¿esz tak¹ tabelê utworzyæ w schemacie public.
CREATE TABLE training.test (id Integer);
--odmowa dostêpu
CREATE TABLE public.test (id Integer);
--odmowa dostêpu



