-- Payment Success Rate 
--Calculate the percentage of successful payments across all orders.
--Challenge: Include breakdowns by payment status (e.g., failed, pending).

SELECT 
p. payment_status,
count(o.order_id) as total_count_of_orders,
count(o.order_id)::numeric/(select count(*) from payments)::numeric *100 as percent_of_successfull_payments
from orders o
join payments p
on o.order_id = p.order_id
group by 1


--Top Performing Sellers
--Find the top 5 sellers based on total sales value.
--Challenge: Include both successful and failed orders, and display their percentage of successful orders.
with top_sellers as(
select 
s.seller_id,
s.seller_name,
sum(total_sale) as total_sale
from orders o
join seller s
 on o.seller_id =s.seller_id
 join order_items oi
 on o.order_id =oi.order_id
 group by 1,2
 order by 3 desc
 limit 5
),
sellers_report as 
(select
o.seller_id,
ts.seller_name,
o.order_status,
count(*) as total_orders
from orders o
join top_sellers ts
on o.seller_id = ts.seller_id
where o.order_status  not in ('Inprogress','Returned')
group by 1, 2, 3)
select
seller_id,
seller_name,
sum(case when order_status = 'Completed' then total_orders else 0 end) as completed_orders,
sum(case when order_status = 'Cancelled' then total_orders else 0 end) as Cancelled_orders,
sum(total_orders) as total_orders,
sum(case when order_status = 'Completed' then total_orders else 0 end)::numeric/
sum(total_orders):: numeric *100 as successful_orders_percentage
from 
sellers_report
group by 1,2

--12. Product Profit Margin
--Calculate the profit margin for each product (difference between price and cost of goods sold).
--Challenge: Rank products by their profit margin, showing highest to lowest.
select 
product_id,
product_name,
profit_margin,
dense_rank() over(order by profit_margin desc) as product_ranking
from
(select 
oi.product_id,
p.product_name,
sum(oi.total_sale -(p.cogs*oi.quantity)) as profits, ---cogs = cost of good sold
sum(oi.total_sale -(p.cogs*oi.quantity))/sum(total_sale)*100 as profit_margin
from
order_items oi
join products p
on oi.product_id =p.product_id
group by 1,2
) as t1


--. Most Returned Products
--Query the top 10 products by the number of returns.
--Challenge: Display the return rate as a percentage of total units sold for each product.


SELECT 
p.product_id,
p.product_name,
COUNT(*) as total_unit_sold,
SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) as total_returned,
SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END)::numeric/COUNT(*)::numeric * 100 as return_percentage
FROM order_items as oi
JOIN 
products as p
ON oi.product_id = p.product_id
JOIN orders o
ON o.order_id = oi.order_id
GROUP BY 1, 2
ORDER BY 5 DESC

--inactive Sellers
--Identify sellers who haven’t made any sales in the last 6 months.
--Challenge: Show the last sale date and total sales from those sellers.

with inactive_sellers as (
select * from seller
where seller_id not in (select seller_id from orders where order_date >= current_date - interval '6 months')
)
select o.seller_id,
max(o.order_date) as last_sale_date,
max(oi.total_sale) as last_sale_amount
from orders o
join inactive_sellers ins
on o.seller_id = ins.seller_id
join order_items oi
on o.order_id = oi.order_id
group by 1

--IDENTITY customers into returning or new
--if the customer has done more than 5 return categorize them as returning otherwise new
--Challenge: List customers id, name, total orders, total returns
SELECT 
c_full_name as customers,
total_orders,
total_return,
CASE
	WHEN total_return > 5 THEN 'Returning_customers' ELSE 'New'
END as cx_category
FROM
(SELECT 
	CONCAT(c.first_name, ' ', c.last_name) as c_full_name,
	COUNT(o.order_id) as total_orders,
	SUM(CASE WHEN o.order_status = 'Returned' THEN 1 ELSE 0 END) as total_return	
FROM orders as o
JOIN 
customers as c
ON c.customer_id = o.customer_id
JOIN
order_items as oi
ON oi.order_id = o.order_id
GROUP BY 1
)

--Top 5 Customers by Orders in Each State
--Identify the top 5 customers with the highest number of orders for each state.
--Challenge: Include the number of orders and total sales for each customer.
select * from(
select 
c.state,
concat(c.first_name,' ',c.last_name),
count(o.order_id) as total_ordes,
sum(total_sale) as total_sale,
dense_rank() over(partition by c.state order by count(o.order_id) desc) as rank
from orders o
join order_items oi
on o.order_id = oi.order_id
join customers c
on o.customer_id = c.customer_id
group by 1,2)
 as t1 where 
 rank <=5








