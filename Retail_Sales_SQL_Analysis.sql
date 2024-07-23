select * from df_orders
drop table df_orders
--top 10 producty by revenue
select top 10 sub_category, sum(sales_price) from df_orders
group by sub_category
order by sum(sales_price) desc

--top 5 highest selling products in each region
with cte as (
select region, sub_category, sum(sales_price) as sales
from df_orders
group by region, sub_category)
select * from (
select *,
row_number() over(partition by region order by sales desc) as rn
from cte) a 
where rn <=5

--month over month growth comparison for 2022 and 2023 sales
with cte as (
select year(order_date) order_year, month(order_date) order_month,
sum(sales_price) as sales 
from df_orders
group by year(order_date), month(order_date))
--order by year(order_date), month(order_date))
select order_month
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by order_month

--which month had highest sales for each category
with cte as (select category, format(order_date,'yyyyMM') as order_year_month
, sum(sales_price) as sales
from df_orders
group by category, format(order_date,'yyyyMM'))
--order by category, format(order_date,'yyyyMM')
select * from (
select *,
row_number() over(partition by category order by sales desc) as rn
from cte) a
where rn = 1

--which sub category had highest growth by profit in 2023 compared to 2022

with cte as (
select sub_category, year(order_date) order_year,
sum(sales_price) as sales 
from df_orders
group by sub_category, year(order_date))
--order by year(order_date), month(order_date))
,cte2 as (
select sub_category
, sum(case when order_year=2022 then sales else 0 end) as sales_2022
, sum(case when order_year=2023 then sales else 0 end) as sales_2023
from cte
group by sub_category
)
select *
,(sales_2023 - sales_2022)
from cte2
order by (sales_2023 - sales_2022)