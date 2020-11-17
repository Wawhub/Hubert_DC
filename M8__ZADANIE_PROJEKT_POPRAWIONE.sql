

--1.
SELECT   tc.category_name, sum(t.transaction_value)
      FROM expense_tracker.transactions t 
		   LEFT JOIN expense_tracker.transaction_category tc ON tc.id_trans_cat = t.id_trans_cat 
		  GROUP BY tc.category_name ;
		  
--2.
 	SELECT tc.category_name ,sum(t.transaction_value)
 	FROM expense_tracker.transactions t 	
  		 JOIN expense_tracker.transaction_category tc 
 						ON tc.id_trans_cat = t.id_trans_cat 
						AND  tc.category_name LIKE 'U¯YWKI' 
						AND  EXTRACT(YEAR FROM t.transaction_date)=2020		
	LEFT JOIN expense_tracker.transaction_bank_accounts tba ON tba.id_trans_ba = t.id_trans_ba AND tba.bank_account_name = 'ROR - Janusz'
	GROUP BY tc.category_name ; 
	


--3.

  SELECT EXTRACT(YEAR FROM t.transaction_date) AS ROK, 
         EXTRACT(YEAR FROM t.transaction_date)||'_'||EXTRACT( QUARTER FROM t.transaction_date) AS ROK_KWARTAL, 
         EXTRACT(YEAR FROM t.transaction_date)||'_'||EXTRACT(MONTH FROM t.transaction_date) AS ROK_MIESIAC,
         GROUPING((EXTRACT(YEAR FROM t.transaction_date)),
         (EXTRACT(YEAR FROM t.transaction_date)||'_'||EXTRACT( QUARTER FROM t.transaction_date)) , 
         (EXTRACT(YEAR FROM t.transaction_date)||'_'||EXTRACT(MONTH FROM t.transaction_date))),
        sum(t.transaction_value)
    FROM expense_tracker.transactions t 
    	JOIN expense_tracker.transaction_bank_accounts tba2 
    		ON tba2.id_trans_ba = t.id_trans_ba 
    		AND tba2.bank_account_name LIKE 'ROR - Janusz i Gra¿ynka'
 		JOIN expense_tracker.transaction_type tp 
 			ON tp.id_trans_type = t.id_trans_type 
 			AND tp.transaction_type_name LIKE 'Obci¹¿enie' 
 			AND EXTRACT(YEAR FROM t.transaction_date)=2019
    GROUP BY ROLLUP (ROK, ROK_KWARTAL, ROK_MIESIAC)
   ORDER BY GROUPING;
    
				
		
				
--4.

WITH yearly_sales AS (
	SELECT EXTRACT(YEAR FROM t.transaction_date) year_sal, sum(t.transaction_value) total_sales
 			FROM expense_tracker.transactions t 	
 			JOIN expense_tracker.transaction_bank_accounts tba2 ON tba2.id_trans_ba = t.id_trans_ba AND tba2.bank_account_name LIKE 'ROR - Janusz i Gra¿ynka'
 			JOIN expense_tracker.transaction_type tp ON tp.id_trans_type = t.id_trans_type AND tp.transaction_type_name LIKE 'Obci¹¿enie'
 GROUP BY 1),
 sales_yoy AS (
  SELECT *,
		 lag(total_sales) OVER (ORDER BY year_sal) AS previous_year_sales
    FROM yearly_sales 
    WHERE year_sal >= 2015 
    ORDER BY 1) 
 SELECT  year_sal,  
	     total_sales,
		 previous_year_sales,
		 previous_year_sales-total_sales AS yoy
    FROM sales_yoy;
    

   
 --5.
SELECT t.id_transaction ,
t.transaction_date,
       t.transaction_value,  
       t.transaction_description,
       tc.category_name,
       ts.subcategory_name,
       last_value(EXTRACT(YEAR FROM t.transaction_date)) 
       		OVER (ORDER BY t.transaction_date ASC RANGE BETWEEN 
            								UNBOUNDED PRECEDING AND 
            								UNBOUNDED FOLLOWING),
            								t.transaction_date - FIRST_VALUE(t.transaction_date) OVER (ORDER BY t.transaction_date) AS days_after_last_purchase 
  FROM expense_tracker.transactions t
 	JOIN expense_tracker.transaction_bank_accounts tba2 
 			ON tba2.id_trans_ba = t.id_trans_ba 
 			AND tba2.bank_account_name LIKE 'ROR - Janusz'
    JOIN expense_tracker.transaction_type tp 
    		ON tp.id_trans_type = t.id_trans_type 
    		AND tp.transaction_type_name LIKE 'Obci¹¿enie' 
    		AND   t.transaction_date BETWEEN '2020-01-01' AND '2020-03-31'  
   JOIN expense_tracker.transaction_subcategory ts 
 			ON t.id_trans_subcat = ts.id_trans_subcat 
 			AND ts.subcategory_name = 'Technologie'
 			JOIN expense_tracker.transaction_category tc 
 			ON tc.id_trans_cat = ts.id_trans_cat 
 	ORDER BY t.transaction_date 
 ;












	