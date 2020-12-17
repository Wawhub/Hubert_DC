
--1.Dodanie indexu typu Tree na kolumne category_name w tabeli transaction_category

DISCARD ALL;
EXPLAIN ANALYZE 
	SELECT tc.category_name, 
			   ts.subcategory_name
	FROM expense_tracker.transaction_category tc 
LEFT JOIN expense_tracker.transaction_subcategory ts 
		ON ts.id_trans_cat =tc.id_trans_cat
WHERE tc.active = '1'
ORDER BY tc.id_trans_cat; 

/*
Sort  (cost=2.90..2.91 rows=5 width=240) (actual time=0.813..0.816 rows=54 loops=1)
  Sort Key: tc.id_trans_cat
  Sort Method: quicksort  Memory: 29kB
  ->  Hash Right Join  (cost=1.15..2.84 rows=5 width=240) (actual time=0.741..0.757 rows=54 loops=1)
        Hash Cond: (ts.id_trans_cat = tc.id_trans_cat)
        ->  Seq Scan on transaction_subcategory ts  (cost=0.00..1.54 rows=54 width=122) (actual time=0.336..0.339 rows=54 loops=1)
        ->  Hash  (cost=1.14..1.14 rows=1 width=122) (actual time=0.389..0.389 rows=11 loops=1)
              Buckets: 1024  Batches: 1  Memory Usage: 9kB
              ->  Seq Scan on transaction_category tc  (cost=0.00..1.14 rows=1 width=122) (actual time=0.360..0.362 rows=11 loops=1)
                    Filter: (active = '1'::bpchar)
Planning Time: 5.341 ms
Execution Time: 0.971 ms
*/





CREATE INDEX index_transaction_category_category_name ON expense_tracker.transaction_category  USING btree(category_name);
DROP INDEX index_transaction_category_category_name;

/*
Sort  (cost=2.90..2.91 rows=5 width=240) (actual time=0.083..0.086 rows=54 loops=1)
  Sort Key: tc.id_trans_cat
  Sort Method: quicksort  Memory: 29kB
  ->  Hash Right Join  (cost=1.15..2.84 rows=5 width=240) (actual time=0.052..0.068 rows=54 loops=1)
        Hash Cond: (ts.id_trans_cat = tc.id_trans_cat)
        ->  Seq Scan on transaction_subcategory ts  (cost=0.00..1.54 rows=54 width=122) (actual time=0.006..0.009 rows=54 loops=1)
        ->  Hash  (cost=1.14..1.14 rows=1 width=122) (actual time=0.019..0.020 rows=11 loops=1)
              Buckets: 1024  Batches: 1  Memory Usage: 9kB
              ->  Seq Scan on transaction_category tc  (cost=0.00..1.14 rows=1 width=122) (actual time=0.012..0.014 rows=11 loops=1)
                    Filter: (active = '1'::bpchar)
Planning Time: 0.669 ms
Execution Time: 0.111 ms
*/


--2. Stworzenie widoku dla transakcji z konta, którego  w³aœcicielem jest Janusz 

DISCARD ALL;
EXPLAIN ANALYZE 
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
  
          
 /*         
 Hash Join  (cost=6.88..203.94 rows=221 width=612) (actual time=2.333..9.587 rows=2010 loops=1)
  Hash Cond: (t.id_trans_cat = tc.id_trans_cat)
  ->  Hash Join  (cost=5.64..201.43 rows=45 width=494) (actual time=2.229..8.817 rows=2010 loops=1)
        Hash Cond: (t.id_trans_ba = tba.id_trans_ba)
        ->  Hash Join  (cost=3.46..198.36 rows=135 width=262) (actual time=1.103..6.952 rows=6402 loops=1)
              Hash Cond: (t.id_trans_type = tt.id_trans_type)
              ->  Hash Join  (cost=2.35..196.59 rows=135 width=144) (actual time=0.371..5.035 rows=6402 loops=1)
                    Hash Cond: ((t.id_trans_cat = ts.id_trans_cat) AND (t.id_trans_subcat = ts.id_trans_subcat))
                    ->  Seq Scan on transactions t  (cost=0.00..155.92 rows=7292 width=26) (actual time=0.309..2.984 rows=7116 loops=1)
                    ->  Hash  (cost=1.54..1.54 rows=54 width=126) (actual time=0.038..0.038 rows=53 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 11kB
                          ->  Seq Scan on transaction_subcategory ts  (cost=0.00..1.54 rows=54 width=126) (actual time=0.018..0.022 rows=54 loops=1)
              ->  Hash  (cost=1.05..1.05 rows=5 width=122) (actual time=0.722..0.722 rows=5 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 9kB
                    ->  Seq Scan on transaction_type tt  (cost=0.00..1.05 rows=5 width=122) (actual time=0.707..0.708 rows=5 loops=1)
        ->  Hash  (cost=2.15..2.15 rows=2 width=240) (actual time=1.115..1.116 rows=2 loops=1)
              Buckets: 1024  Batches: 1  Memory Usage: 9kB
              ->  Hash Join  (cost=1.05..2.15 rows=2 width=240) (actual time=1.106..1.108 rows=2 loops=1)
                    Hash Cond: (tba.id_ba_own = bao.id_ba_own)
                    ->  Seq Scan on transaction_bank_accounts tba  (cost=0.00..1.07 rows=7 width=126) (actual time=0.401..0.402 rows=7 loops=1)
                    ->  Hash  (cost=1.04..1.04 rows=1 width=122) (actual time=0.684..0.685 rows=1 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 9kB
                          ->  Seq Scan on bank_account_owner bao  (cost=0.00..1.04 rows=1 width=122) (actual time=0.670..0.671 rows=1 loops=1)
                                Filter: ((owner_name)::text = 'Janusz Kowalski'::text)
                                Rows Removed by Filter: 2
  ->  Hash  (cost=1.11..1.11 rows=11 width=122) (actual time=0.029..0.029 rows=11 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 9kB
        ->  Seq Scan on transaction_category tc  (cost=0.00..1.11 rows=11 width=122) (actual time=0.016..0.017 rows=11 loops=1)
Planning Time: 5.927 ms
Execution Time: 9.744 ms         
 */         
          
          
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


DISCARD ALL;
EXPLAIN ANALYZE 
          SELECT * FROM expense_tracker.transactions_janusz;

  /*       
  Hash Join  (cost=6.88..203.94 rows=221 width=612) (actual time=0.112..4.260 rows=2010 loops=1)
  Hash Cond: (t.id_trans_cat = tc.id_trans_cat)
  ->  Hash Join  (cost=5.64..201.43 rows=45 width=494) (actual time=0.087..3.735 rows=2010 loops=1)
        Hash Cond: (t.id_trans_ba = tba.id_trans_ba)
        ->  Hash Join  (cost=3.46..198.36 rows=135 width=262) (actual time=0.056..3.123 rows=6402 loops=1)
              Hash Cond: (t.id_trans_type = tt.id_trans_type)
              ->  Hash Join  (cost=2.35..196.59 rows=135 width=144) (actual time=0.031..2.174 rows=6402 loops=1)
                    Hash Cond: ((t.id_trans_cat = ts.id_trans_cat) AND (t.id_trans_subcat = ts.id_trans_subcat))
                    ->  Seq Scan on transactions t  (cost=0.00..155.92 rows=7292 width=26) (actual time=0.006..0.554 rows=7116 loops=1)
                    ->  Hash  (cost=1.54..1.54 rows=54 width=126) (actual time=0.018..0.018 rows=53 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 11kB
                          ->  Seq Scan on transaction_subcategory ts  (cost=0.00..1.54 rows=54 width=126) (actual time=0.006..0.010 rows=54 loops=1)
              ->  Hash  (cost=1.05..1.05 rows=5 width=122) (actual time=0.009..0.009 rows=5 loops=1)
                    Buckets: 1024  Batches: 1  Memory Usage: 9kB
                    ->  Seq Scan on transaction_type tt  (cost=0.00..1.05 rows=5 width=122) (actual time=0.006..0.007 rows=5 loops=1)
        ->  Hash  (cost=2.15..2.15 rows=2 width=240) (actual time=0.025..0.025 rows=2 loops=1)
              Buckets: 1024  Batches: 1  Memory Usage: 9kB
              ->  Hash Join  (cost=1.05..2.15 rows=2 width=240) (actual time=0.021..0.023 rows=2 loops=1)
                    Hash Cond: (tba.id_ba_own = bao.id_ba_own)
                    ->  Seq Scan on transaction_bank_accounts tba  (cost=0.00..1.07 rows=7 width=126) (actual time=0.006..0.006 rows=7 loops=1)
                    ->  Hash  (cost=1.04..1.04 rows=1 width=122) (actual time=0.009..0.009 rows=1 loops=1)
                          Buckets: 1024  Batches: 1  Memory Usage: 9kB
                          ->  Seq Scan on bank_account_owner bao  (cost=0.00..1.04 rows=1 width=122) (actual time=0.006..0.007 rows=1 loops=1)
                                Filter: ((owner_name)::text = 'Janusz Kowalski'::text)
                                Rows Removed by Filter: 2
  ->  Hash  (cost=1.11..1.11 rows=11 width=122) (actual time=0.018..0.018 rows=11 loops=1)
        Buckets: 1024  Batches: 1  Memory Usage: 9kB
        ->  Seq Scan on transaction_category tc  (cost=0.00..1.11 rows=11 width=122) (actual time=0.010..0.012 rows=11 loops=1)
Planning Time: 0.688 ms
Execution Time: 4.393 ms       
*/
         
         
--3.Porównanie widoku z poprzedniego punktu z widokiem zmaterializowanym

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
     

 DISCARD ALL;
EXPLAIN ANALYZE 
          SELECT * FROM expense_tracker.transactions_janusz_materials;        
          
 -- Seq Scan on transactions_janusz_materials  (cost=0.00..33.60 rows=360 width=620) (actual time=0.011..0.185 rows=2010 loops=1)
--Planning Time: 0.238 ms
--Execution Time: 0.241 ms        
          
--Zapytanie z widokiem zmaterializowanym jest jeszcze szybsze 
 
         
--4.Zapytanie z tabeli partycjonowanej po dacie vs tabeli z transakcjami z ca³ego zakresu 

         
DISCARD ALL;
EXPLAIN ANALYZE          
SELECT t.*,
           tc.category_name
      FROM expense_tracker.transactions t
      JOIN expense_tracker.transaction_category tc ON tc.id_trans_cat = t.id_trans_cat
     WHERE tc.category_name = 'JEDZENIE'
       AND EXTRACT(YEAR FROM t.transaction_date)=2016
       AND t.id_trans_subcat = -1 ;
/*      
  Nested Loop  (cost=0.00..230.03 rows=1 width=172) (actual time=0.110..0.804 rows=70 loops=1)
  Join Filter: (t.id_trans_cat = tc.id_trans_cat)
  Rows Removed by Join Filter: 92
  ->  Seq Scan on transaction_category tc  (cost=0.00..1.14 rows=1 width=122) (actual time=0.011..0.013 rows=1 loops=1)
        Filter: ((category_name)::text = 'JEDZENIE'::text)
        Rows Removed by Filter: 10
  ->  Seq Scan on transactions t  (cost=0.00..228.84 rows=4 width=54) (actual time=0.096..0.774 rows=162 loops=1)
        Filter: ((id_trans_subcat = '-1'::integer) AND (date_part('year'::text, (transaction_date)::timestamp without time zone) = '2016'::double precision))
        Rows Removed by Filter: 6954
Planning Time: 0.272 ms
Execution Time: 0.822 ms       
*/

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



insert into transactions_y2016 (select * from expense_tracker.transactions where transaction_date between '2016-01-01' and '2016-12-31');
      

DISCARD ALL;
EXPLAIN ANALYZE          
SELECT td.*,
           tc.category_name
      FROM expense_tracker.transactions_partitioned td
      JOIN expense_tracker.transaction_category tc ON tc.id_trans_cat = td.id_trans_cat
     WHERE tc.category_name = 'JEDZENIE'  AND EXTRACT(YEAR FROM td.transaction_date)=2016
       AND td.id_trans_subcat = -1 ;
/*         

Nested Loop  (cost=0.00..169.26 rows=1 width=202) (actual time=0.033..0.223 rows=70 loops=1)
  Join Filter: (td.id_trans_cat = tc.id_trans_cat)
  Rows Removed by Join Filter: 92
  ->  Seq Scan on transaction_category tc  (cost=0.00..1.14 rows=1 width=122) (actual time=0.010..0.011 rows=1 loops=1)
        Filter: ((category_name)::text = 'JEDZENIE'::text)
        Rows Removed by Filter: 10
  ->  Append  (cost=0.00..168.05 rows=6 width=84) (actual time=0.020..0.193 rows=162 loops=1)
        ->  Seq Scan on transactions_y2015 td  (cost=0.00..23.80 rows=1 width=90) (actual time=0.004..0.004 rows=0 loops=1)
              Filter: ((id_trans_subcat = '-1'::integer) AND (date_part('year'::text, (transaction_date)::timestamp without time zone) = '2016'::double precision))
        ->  Seq Scan on transactions_y2016 td_1  (cost=0.00..49.02 rows=1 width=54) (actual time=0.015..0.165 rows=162 loops=1)
              Filter: ((id_trans_subcat = '-1'::integer) AND (date_part('year'::text, (transaction_date)::timestamp without time zone) = '2016'::double precision))
              Rows Removed by Filter: 1389
        ->  Seq Scan on transactions_y2017 td_2  (cost=0.00..23.80 rows=1 width=90) (actual time=0.004..0.004 rows=0 loops=1)
              Filter: ((id_trans_subcat = '-1'::integer) AND (date_part('year'::text, (transaction_date)::timestamp without time zone) = '2016'::double precision))
        ->  Seq Scan on transactions_y2018 td_3  (cost=0.00..23.80 rows=1 width=90) (actual time=0.004..0.004 rows=0 loops=1)
              Filter: ((id_trans_subcat = '-1'::integer) AND (date_part('year'::text, (transaction_date)::timestamp without time zone) = '2016'::double precision))
        ->  Seq Scan on transactions_y2019 td_4  (cost=0.00..23.80 rows=1 width=90) (actual time=0.004..0.004 rows=0 loops=1)
              Filter: ((id_trans_subcat = '-1'::integer) AND (date_part('year'::text, (transaction_date)::timestamp without time zone) = '2016'::double precision))
        ->  Seq Scan on transactions_y2020 td_5  (cost=0.00..23.80 rows=1 width=90) (actual time=0.004..0.004 rows=0 loops=1)
              Filter: ((id_trans_subcat = '-1'::integer) AND (date_part('year'::text, (transaction_date)::timestamp without time zone) = '2016'::double precision))
Planning Time: 0.796 ms
Execution Time: 0.252 ms     
 */
      
      
 --W tym przypadku dla tabeli partycjonowanej wykonanie zapytania trwa³o co prawda krocej , ale niestety czas budowania planu zapytania byl dluzszy
 
 --5. Do tego wszytskiego doda³bym zmiany zaproponowane w komentarzach do modulu numer 10.
      