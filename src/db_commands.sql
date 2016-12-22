-- ----------------------
-- CREATE SCHEMA
-- ----------------------

CREATE SCHEMA moip;

-- Treating client table
alter table moip.client alter column birth_number type varchar using birth_number::varchar;
ALTER TABLE moip.client ADD COLUMN birthdate DATE;
ALTER TABLE moip.client ADD COLUMN client_age INT;
UPDATE moip.client SET birthdate = TO_DATE('19' || birth_number, 'YYYYMMDD');
UPDATE moip.client SET client_age = date_part('year',age(birthdate));
ALTER TABLE moip.client DROP COLUMN birth_number;

-- Treating client table
alter table moip.loan alter column date type varchar using date::varchar;
ALTER TABLE moip.loan ADD COLUMN loan_date DATE;
UPDATE moip.loan SET loan_date = TO_DATE('19' || date, 'YYYYMMDD');
ALTER TABLE moip.loan DROP COLUMN date;

-- Loans study Master table
SELECT * INTO moip.master_table from(
SELECT disp_id, LLHS.client_id, account_id, loan_id, amount, duration, payments, status, loan_date, district_id, birthdate
from (SELECT disp_id, LHS.client_id, LHS.account_id, loan_id, amount, duration, payments, status, loan_date FROM
  (select * from moip.disposition where type = 'OWNER') as LHS
  Inner JOIN
  (select * from moip.loan) as RHS
  ON  LHS.account_id = RHS.account_id) as LLHS
LEFT JOIN
  (select * from moip.client) as RRHS
ON LLHS.client_id = RRHS.client_id) as master;

-- time series x = yearmonth y = cnt/amount
select cast(date_trunc('month',loan_date) as date) year_month, count(*) as cnt, sum(amount) as total_amount
from moip.master_table
group by 1;

-- time series x = yearmonth y = cnt/amount by status
select cast(date_trunc('month',loan_date) as date) year_month,status, count(*) as cnt, sum(amount) as total_amount
from moip.master_table
group by 1,status;


-- status, credit_card type, count, amount
select status, type,count(*) as cnt,sum(amount) as total_amount from(
select * from moip.master_table as LHS
LEFT JOIN
  (select disp_id, type from moip.credit_card) as credit_table
ON LHS.disp_id = credit_table.disp_id) as subq
group by status, type;

-- status, region, count, amount
select status, region,count(*) as cnt,sum(amount) as total_amount from(
select * from moip.master_table as LHS
LEFT JOIN
  (select "A1" as district_id, "A3" as region from moip.demograph) as demograph_table
ON LHS.district_id = demograph_table.district_id) as subq
group by status, region;

-- monthly payments
select payments,status from moip.master_table;

-- duration
select duration,status from moip.master_table;