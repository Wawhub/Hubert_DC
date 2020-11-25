	

--1.	
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
	
          
          CREATE OR REPLACE VIEW expense_tracker.transactions_grazynka AS
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
           WHERE bao.owner_name = 'Gra¿yna Kowalska';	
			
          
          
CREATE OR REPLACE VIEW expense_tracker.transactions_janusz_i_grazynka AS
SELECT t.id_trans_type , 
				t.transaction_date,
				EXTRACT(YEAR FROM t.transaction_date),
				t.transaction_value,
				tc.category_name, 
				ts.subcategory_name,
				tba.bank_account_name,
				bao.owner_name ,
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
           WHERE bao.owner_name = 'Janusz i Gra¿ynka';	
			          
      
          
 --2.
  SELECT *
  FROM expense_tracker.transactions_janusz_i_grazynka tjig ;      
          
          
  SELECT EXTRACT(YEAR FROM tjig.transaction_date) transaction_year,
  		tjig.transaction_type_name,
  		tjig.category_name,
  		array_agg(DISTINCT tjig.subcategory_name) subcategories_list,
  		sum(tjig.transaction_value)
  FROM expense_tracker.transactions_janusz_i_grazynka tjig 
  GROUP BY tjig.transaction_date, tjig.transaction_type_name, tjig.category_name
  ORDER BY transaction_year ASC ;
         
 
          
 
--3.
 CREATE TABLE IF NOT EXISTS expense_tracker.monthly_budget_planned(
 		year_month varchar(7) PRIMARY KEY ,
 		budget_planned NUMERIC(10,2),
		 left_budget NUMERIC(10,2)
 );
 
     
INSERT INTO expense_tracker.monthly_budget_planned (year_month,budget_planned,left_budget)
	  VALUES ('2020-11', 5000, 5000);
          

    
	 
--4.
	 
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
   
   
 
  --Kasowanie triggera i tabeli w celach testowych 
  DROP TRIGGER finance_control_trigger ON expense_tracker.transactions CASCADE; 
  DROP TABLE expense_tracker.monthly_budget_planned CASCADE;
 
 
 
  --5. 
   
 --Testowanie wyzwalacza
 
 SELECT * FROM expense_tracker.monthly_budget_planned mbp ;
  
 
INSERT INTO expense_tracker.transactions (id_trans_ba,id_trans_cat,id_trans_subcat,id_trans_type,id_user,transaction_value,transaction_description)
 			VALUES (1,1,1,1,1,-5000.5,'opis');       
 
  
  DELETE FROM expense_tracker.transactions t
	  WHERE EXTRACT(YEAR FROM t.transaction_date) = 2020 AND extract(MONTH FROM t.transaction_date) = 10; 
	 

UPDATE expense_tracker.transactions 
SET transaction_value  = - 100
WHERE EXTRACT(YEAR FROM transaction_date) = 2019 AND extract(MONTH FROM transaction_date) = 10; 
          
     

          
  --6.
           
 --Wydaje mi siê, ¿ê warto dodaæ jakiœ warunek,
 -- który bêdzie automatycznie tworzy³ budzet dla nowego miesi¹ca i  umieszcza³ w nim nowe dane.
 -- Warto te¿ zapewne usystematyzowaæ jaki zakres dat tranzakcji ma byæ w danym miesi¹cu, a jaki w drugim. 
 -- Chodzi o to, ¿e czêsto ludzie rozliczaj¹ swe wydatki od 10tego do 10tego.  
 -- Wystêpuj¹cy problem to wlasnie naliczanie siê danych z nieodpowiedniego miesiaca
       
          
          
          
          
          
          
          
          
          
          