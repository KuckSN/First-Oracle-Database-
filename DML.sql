-- 1) List out all the customer or merchant who hasn’t register an account for transaction purposes and provide us with their email

SELECT MERCHANT_NAME AS Name, MERCHANT_EMAIL AS EMAIL
FROM AS_MERCHANT
WHERE MERCHANT_ID 
    NOT IN (SELECT DISTINCT MERCHANT_ID FROM AS_ACCOUNT)
UNION
SELECT CUSTOMER_FIRST_NAME || ' ' || CUSTOMER_LAST_NAME as customerName, CUSTOMER_EMAIL
FROM AS_CUSTOMER
WHERE CUSTOMER_ID 
    NOT IN (SELECT DISTINCT CUSTOMER_ID FROM AS_ACCOUNT WHERE CUSTOMER_ID IS NOT NULL);

-- 2) By examining the risk factor of each merchant, classify them into their own district area and find out the trust level of merchants from the same district. Put appropriate labeling to indicate the level of trust.


SELECT City, Avg(Risk_Factor) as Trust,
    (CASE 
        WHEN Avg(Risk_Factor) < 2.5 THEN 'RED ALERT'
        WHEN Avg(Risk_Factor) BETWEEN 2.5 AND 4 THEN 'YELLOW ALERT'
        WHEN Avg(Risk_Factor) > 4 THEN 'GREEN ALERT'
    END) customerGroup
FROM AS_ACCOUNT
    INNER JOIN 
        (SELECT MERCHANT_ID, RISK_FACTOR FROM AS_MERCHANT
            INNER JOIN AS_LOAN_MANAGEMENT USING (MERCHANT_ID)
        ) USING (MERCHANT_ID)
    INNER JOIN AS_DISTRICT USING (DISTRICT_ID)
GROUP BY CITY
ORDER BY Trust DESC;

-- 3) Get the number of investments made by each investor, along with their names and emails, arrange them in descending order according to the number of investments made.

SELECT INVESTOR_ID, FIRST_NAME, LAST_NAME, INVESTOR_EMAIL, 
COUNT(*) AS NUM_INVESTMENTS
FROM AS_INVESTOR
INNER JOIN AS_INVESTMENT USING (INVESTOR_ID)
GROUP BY INVESTOR_ID, FIRST_NAME, LAST_NAME, INVESTOR_EMAIL
ORDER BY NUM_INVESTMENTS DESC;

-- 4) Find the top 3 customers who have made the most transactions, along with the total number of transactions made and the total amount spent.


SELECT * FROM (
  SELECT CUSTOMER_FIRST_NAME || ' ' || CUSTOMER_LAST_NAME as CUSTOMER_NAME, COUNT(CUSTOMER_ID) as NUM_TRANSACTIONS, SUM(AMOUNT) as TOTAL_SPEND
  FROM AS_MER_CUST_TRANSACTION
  INNER JOIN AS_CUSTOMER USING (CUSTOMER_ID)
  GROUP BY CUSTOMER_FIRST_NAME, CUSTOMER_LAST_NAME
  ORDER BY NUM_TRANSACTIONS DESC
) WHERE ROWNUM <= 3;


-- 5) Get the district id, region and city where the average salary is more than 4500 and arrange them in ascending order.

SELECT DISTRICT_ID, REGION, CITY, AVG_SALARY
FROM AS_DISTRICT
WHERE AVG_SALARY > 4500
ORDER BY AVG_SALARY ASC;

-- 6) List out the merchant risk id where its total risk weightage is less than 4 and arrange them in ascending order.

SELECT MERCHANT_RISK_ID, TOTAL_RISK_WEIGHTAGE, TOTAL_LOAN_WEIGHTAGE
FROM AS_RISK_ENGINE
WHERE TOTAL_RISK_WEIGHTAGE <4
ORDER BY TOTAL_RISK_WEIGHTAGE ASC;

-- 7) List out all the merchant’s transactions along with their SSM, email, name and average weekly sales (AWS) and arrange them in descending order by the amount of the transactions. 

SELECT SSM, MERCHANT_NAME, MERCHANT_EMAIL, AWS, AMMOUNT, TRANS_DATE FROM (
    SELECT ACCOUNT_ID, TRANS_TYPE, AMMOUNT, ACCOUNT_NAME, MERCHANT_ID, TRANS_DATE
    FROM AS_TRANSACTION 
    INNER JOIN AS_ACCOUNT USING (ACCOUNT_ID) 
) INNER JOIN AS_MERCHANT USING (MERCHANT_ID)
    ORDER BY AMMOUNT DESC


-- 8) By examining the actual owed assets and liability of each merchant, calculate their respective Debt Per Assets in percentage and arrange them in descending order by this attribute.

SELECT 
    MERCHANT_NAME, SSM, MERCHANT_EMAIL, 
    ACTUAL_OWNED_ASSET_VALUE, ASSET_TYPE, 
    LIABILITY_OUTSTANDING, LIABILITY_TYPE, 
    CAST(LIABILITY_OUTSTANDING/ACTUAL_OWNED_ASSET_VALUE*100 AS DECIMAL(9,4)) AS DEBTPERASSETS_PERCENTAGE
FROM(
    SELECT 
        MERCHANT_ID, 
        ASSET_VALUE*OWNERSHIP_PERCENTAGE/100 as ACTUAL_OWNED_ASSET_VALUE 
    FROM AS_MERCHANT_ASSET 
)
INNER JOIN AS_MERCHANT USING (MERCHANT_ID)
INNER JOIN AS_MERCHANT_ASSET USING (MERCHANT_ID)
INNER JOIN AS_MERCHANT_LIABILITY USING (MERCHANT_ID)
ORDER BY DEBTPERASSETS_PERCENTAGE DESC;

-- 9) List out all attributes of the capital management where only positive ROI is taken into consideration whilst arranging them based on descending order of capital amount.

SELECT CM_ID, SOURCE, CAPITAL_AMOUNT, ROI, CE_ID, BUSINESS_ID
FROM AS_CAPITAL_MANAGEMENT
WHERE ROI > 0
ORDER BY CAPITAL_AMOUNT DESC;

-- 10) Determine the total from the loan amount multiplied with the risk factor and store it in a new table named new_data which is then arranged in ascending order.

SELECT LOAN_MANAGEMENT_ID, 
LOAN_AMOUNT*RISK_FACTOR AS NEW_DATA
FROM AS_LOAN_MANAGEMENT
ORDER BY NEW_DATA ASC;


