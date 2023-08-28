--1 write a query to print top 5 cities with highest spends and 
--their percentage contribution of total credit card spends

with a as (select city,SUM(amount) as city_spent from credit_card_transactions
group by city ),
b as (select SUM(amount) as total_spent from credit_card_transactions)
select top 5 city,city_spent,(city_spent * 1.00/total_spent)*100 as percentage_city from a,b
order by city_spent desc,percentage_city desc


--2.write a query to print highest spend month and amount spent in that month 
--for each card type

with a  as (select card_type,DATEPART(YEAR,date) as year_name ,
DATEPART(month,date) as month_name,sum(amount) as month_spend 
from credit_card_transactions
group by card_type,DATEPART(YEAR,date),DATEPART(month,date)),
b as (select *,DENSE_RANK() over (partition by card_type order by month_spend desc) AS DRNK
from a)
select * from b where DRNK=1

/*
3 write a query to print the transaction details(all columns from the table) 
for each card type when it reaches a cumulative of 1000000 total spends
(We should have 4 rows in the o/p one for each card type)
*/
with a as (select *,SUM(amount) over(partition by card_type order by id,date) as total_spend 
from credit_card_transactions),
b as (select *,DENSE_RANK() over (partition by card_type order by total_spend desc) as drnk
from a where total_spend >= 1000000 )
select * from b where drnk=1

--4 write a query to find city which had lowest percentage spend for gold card type
with a as (select card_type,city,sum(amount) as ct_amnt from credit_card_transactions
where card_type like 'Gold'
group by card_type,city),
 b as (select city,SUM(amount) as total_amnt from credit_card_transactions
 group by city),
 c as (select a.*,b.total_amnt from a join b on a.city=b.city)
 select  city,(ct_amnt * 1.00/total_amnt) as percentage from c
 order by percentage asc

 --5 write a query to print 3 columns:  city, highest_expense_type , lowest_expense_type 
 --(example format : Delhi , bills, Fuel)

--select * from credit_card_transactions

with a as (select city,exp_type,sum(amount) as expense from credit_card_transactions 
group by city,exp_type),
b as (select *,DENSE_RANK() over (partition by city order by expense desc) as drnk from a),
c as (select *,DENSE_RANK() over (partition by city order by expense asc) as drnk from a),
d as (select city,exp_type as highest_expense_type from b where drnk=1),
f as (select city,exp_type as lowest_expense_type from c where drnk=1)
select d.city,d.highest_expense_type,f.lowest_expense_type 
from d join f on d.city=f.city

-- 6 write a query to find percentage contribution of spends by
--females for each expense type

with a as (select exp_type,SUM(amount) as f_spend from credit_card_transactions
where gender like 'F'
group by exp_type),
b as (select exp_type,SUM(amount) as total_spend from credit_card_transactions
group by exp_type)
select a.exp_type,(a.f_spend * 1.00/b.total_spend) as f_percentage
from a join b on a.exp_type=b.exp_type
order by f_percentage DESC

-- 7 which card and expense type combination saw highest month over month growth
--in Jan-2014


with a as(select card_type,exp_type,datepart(year,date) as year,
datepart(month,date) as month
,sum(amount) as spend from credit_card_transactions
group by card_type,exp_type,datepart(year,date),datepart(month,date)),
b as (select *,LAG(spend,1) over (partition by card_type,exp_type order by year,month) 
as prev_month_spend from a )
select top 1 card_type,exp_type,year,month,spend,prev_month_spend,(spend-prev_month_spend) as growth 
from b where year=2014 and month=1
order by growth desc

--8 during weekends which city has highest total spend to total no of transcations ratio.
select top 1 city,sum(amount)/COUNT(id) as expected_ratio
from credit_card_transactions
where datename(weekday,date) in ('Saturday','Sunday')
group by city
order by expected_ratio desc


--9 which city took least number of days to reach its 500th transaction after the 
--first transaction in that city

with a as (select * ,ROW_NUMBER() over (partition by city order by date,id) as rn 
from credit_card_transactions)
select  city,DATEDIFF(day,min(date),max(date)) as total_days from a
where rn=1 or rn =500
group by city
having count(city)=2
order by total_days 


