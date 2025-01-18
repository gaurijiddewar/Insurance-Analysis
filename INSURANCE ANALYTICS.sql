create DATABASE INSURANCE;

use insurance;
select * from brokerage;
select * from fees;
select * from individual_Budgets;
select * from invoice;
select * from Meeting1;
select * from opportunity;

update meeting1
set meeting_date=str_to_date(meeting_date,"%d-%m-%Y");

DESC MEETING1;

Alter table Meeting1 modify column meeting_date date;

ALTER TABLE Meeting1 RENAME COLUMN Account_Executive TO Account_Executive;


-- KPI 1 : NUMBER OF INVOICE BY ACCOUNT EXECUTIVE
SELECT Account_Executive,
SUM(CASE WHEN INCOME_CLASS= "CROSS SELL"  THEN 1 ELSE 0 END) AS CROSS_SELL_COUNT,
SUM(CASE WHEN INCOME_CLASS = 'NEW' THEN 1 ELSE 0 END) AS NEW_COUNT,
SUM(CASE WHEN INCOME_CLASS= "RENEWAL"  THEN 1 ELSE 0 END) AS RENEWAL_COUNT,
SUM(CASE WHEN INCOME_CLASS='' THEN 1 ELSE 0 END) AS NULL_INVOICE_COUNT,
COUNT(INVOICE_NUMBER) AS INVOICE_COUNT
From invoice1
GROUP BY Account_Executive
ORDER BY INVOICE_COUNT desc;



-- KPI 2 : YEARLY MEETING COUNT
SELECT YEAR(MEETING_DATE) AS MEETING_YEAR , COUNT(*) AS MEETING_COUNT
FROM MEETING1
GROUP BY MEETING_YEAR;


-- KPI 4 : STAGE FUNNEL BY REVENUE
SELECT STAGE ,SUM(REVENUE_AMOUNT) AS REVENUE_AMOUNT FROM OPPORTUNITY
GROUP BY STAGE
ORDER BY REVENUE_AMOUNT DESC;

-- KPI 5 : NUMBER OF MEETING BY ACCOUNT EXCCUTIVE
SELECT ACCOUNT_EXECUTIVE,COUNT(*) AS MEETING_COUNT FROM MEETING1
GROUP BY ACCOUNT_EXECUTIVE
ORDER BY MEETING_COUNT DESC;


-- KPI 6 : TOP 5 OPPORTUNITY BY REVENUE
SELECT OPPORTUNITY_NAME ,SUM(REVENUE_AMOUNT) AS REVENUE_AMT
FROM OPPORTUNITY
GROUP BY OPPORTUNITY_NAME
ORDER BY REVENUE_AMT DESC LIMIT 5;



SELECT CONCAT(ROUND((SELECT SUM(renewal_budget) FROM budgets) / 1000000, 2), ' mn') AS Renewal_target,
CONCAT(ROUND(((SELECT COALESCE(SUM(amount), 0) FROM brokerage WHERE income_class = 'Renewal') +
(SELECT COALESCE(SUM(amount), 0) FROM fees WHERE income_class = 'Renewal')) / 1000000, 2), ' mn') AS Renewal_achieved,
CONCAT(ROUND(((SELECT COALESCE(SUM(amount), 0) FROM brokerage WHERE income_class = 'Renewal') +
(SELECT COALESCE(SUM(amount), 0) FROM fees WHERE income_class = 'Renewal')) / NULLIF((SELECT SUM(renewal_budget) FROM budgets), 0) * 100, 2), '%'
) AS Achieved_percentage,
CONCAT(ROUND((SELECT SUM(amount) FROM invoice WHERE income_class = 'Renewal') / 1000000, 2), ' mn') AS Renewal_invoice,
CONCAT(ROUND((SELECT SUM(amount) FROM invoice WHERE income_class = 'Renewal') / NULLIF((SELECT SUM(renewal_budget) FROM budgets), 0) * 100, 2), '%'
) AS Invoice_percentage;
