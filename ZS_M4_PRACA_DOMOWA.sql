
--1.Korzystajac ze skladni CREATE ROLE, stwórz nowego uzytkownika o nazwie user_training z
--mozliwoscia zalogowania siê do bazy danych i haslem silnym
DROP ROLE IF EXISTS user_training;
CREATE ROLE user_training WITH LOGIN PASSWORD '1sniegnadywanie!';


--2.Korzystajac z atrybutu AUTHORIZATION dla skladni CREATE SCHEMA. Utwórz schemat
--training, którego wlascicielem bedzie uzytkownik user_training.
DROP SCHEMA IF EXISTS training ;
CREATE SCHEMA training AUTHORIZATION user_training;


--3.Bedac zalogowany na super uzytkowniku postgres, spróbuj usunac role (uzytkownika)user_training.
DROP ROLE user_training;
--nie mozna usunac, poniewaz istnieja obiekty zalezne


--4.Przekaz wlasnosc nad utworzonym dla / przez uzytkownika user_training obiektami na role postgres. Nastepnie usun role user_training.
REASSIGN OWNED BY user_training TO postgres;
DROP OWNED BY user_training;
DROP ROLE user_training;


--5.Utwórz nowa role reporting_ro, która bedzie grupa dostepów, dla uzytkowników warstwy analitycznej o nastepujacych przywilejach:
-- dostep do bazy, schematu, tworzenia obiektów w schemacie training oraz dostep do wszystkich uprawnien do tabel w schemacie training
CREATE ROLE reporting_ro;
GRANT CONNECT ON DATABASE postgres TO reporting_ro;
GRANT CREATE,USAGE ON SCHEMA training TO reporting_ro;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA training TO reporting_ro;


--6.Utwórz nowego uzytkownika reporting_user z mozliwoœcia logowania sie do bazy danych i
--hasle silnym. Przypisz temu uzytkownikowi role reporting ro
CREATE ROLE reporting_user WITH LOGIN PASSWORD '1sniegnadywanie!';
GRANT reporting_ro TO reporting_user;


--7.Bedac zalogowany na uzytkownika reporting_user, spróbuj utworzyc nowa tabele (dowolna) w schemacie training.
DROP TABLE IF EXISTS training.nowa;
CREATE TABLE training.nowa (id Integer);
--udalo sie utworzyc


--8.Zabierz uprawnienia roli reporting_ro do tworzenia obiektów w schemacie training
REVOKE CREATE ON SCHEMA training FROM reporting_ro;


--9.Zaloguj sie ponownie na uzytkownika reporting_user, sprawdz czy mozesz utworzyc nowa
--tabele w schemacie training oraz czy mozesz taka tabele utworzyc w schemacie public.
CREATE TABLE training.test (id Integer);
--odmowa dostepu
CREATE TABLE public.test (id Integer);
--odmowa dostepu



