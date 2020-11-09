

--1.
	SELECT bao.owner_name ,
				bao.owner_desc , 
				bat.ba_type , 
				bat.ba_desc, 
				bat.active,
				tba.bank_account_name, 
				u.user_login
	FROM expense_tracker.bank_account_owner bao
JOIN expense_tracker.bank_account_types bat 
		ON bat.id_ba_own = bao.id_ba_own 
JOIN expense_tracker.transaction_bank_accounts tba 
		ON tba.id_trans_ba = bat.id_ba_type 
JOIN expense_tracker.users u 
		ON u.user_name = bao.owner_name 
	WHERE bao.owner_name LIKE 'Janusz Kowalski';



--2.
	SELECT tc.category_name, 
			   ts.subcategory_name
	FROM expense_tracker.transaction_category tc 
LEFT JOIN expense_tracker.transaction_subcategory ts 
		ON ts.id_trans_cat =tc.id_trans_cat
WHERE tc.active = '1'
ORDER BY tc.id_trans_cat; 


 
 --3.
 	SELECT t.*, 
 			tc.category_name 
 	FROM expense_tracker.transactions t 
 JOIN expense_tracker.transaction_category tc ON tc.id_trans_cat = t.id_trans_cat 
 WHERE tc.category_name LIKE 'JEDZENIE' 
						AND  EXTRACT(YEAR FROM t.transaction_date)=2016;

					

--4.

SELECT *
FROM expense_tracker.transaction_subcategory ts ;


INSERT INTO expense_tracker.transaction_subcategory (id_trans_cat, subcategory_name,subcategory_description)
	  VALUES (1,'Sumplementy', 'Suplementy');
	  	

WITH formula AS (
    SELECT t.*,
           tc.category_name
      FROM expense_tracker.transactions t
      JOIN expense_tracker.transaction_category tc ON tc.id_trans_cat = t.id_trans_cat
     WHERE tc.category_name LIKE 'JEDZENIE'
       AND EXTRACT(YEAR FROM t.transaction_date)=2016
       AND t.id_trans_subcat = -1
)
 UPDATE expense_tracker.transactions t
   SET id_trans_subcat = 54
 WHERE EXISTS (SELECT 1
                 FROM formula f
				WHERE f.id_transaction = t.id_transaction);				
				
				


--5.
	SELECT t.id_trans_type , 
				t.transaction_date,
				t.transaction_value,
				tc.category_name, 
				ts.subcategory_name,
				tba.bank_account_name 
FROM expense_tracker.transaction_bank_accounts tba 
	JOIN  expense_tracker.transactions t 
			ON tba.id_trans_ba = t.id_trans_ba 
	JOIN expense_tracker.transaction_category tc 
			ON tc.id_trans_cat = t.id_trans_cat 
	JOIN expense_tracker.transaction_subcategory ts 
			ON ts.id_trans_cat =tc.id_trans_cat
WHERE tba.id_trans_ba = 6  
		AND  EXTRACT(YEAR FROM t.transaction_date)=2020;




