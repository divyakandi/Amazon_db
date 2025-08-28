--Identify the least-selling product category for each state.
--Challenge: Include the total sales for that category within each state.
with ranking_table 
as(
select c.state,
ca.category_name,
sum(oi.total_sale) as total_sale,
rank() over(partition by c.state order by sum(oi.total_sale)asc ) as rank
from orders o
join customers c
on o.customer_id =c.customer_id
join order_items oi
on oi.order_id =o.order_id
join products p
on oi.product_id = p.product_id
join category ca
on p.category_id =ca.category_id
group by 1,2
)
select * from ranking_table
where rank =1

--Customer Lifetime Value (CLTV)
--Calculate the total value of orders placed by each customer over their lifetime.
--Challenge: Rank customers based on their CLTV.

select c.customer_id,
concat('c.first_name',' ','c.last_name') as full_name,
sum(total_sale) as CLTV,
dense_rank() over ( order by sum(total_sale) desc) as cx_ranking
from customers c
join orders o
on c.customer_id =o.customer_id
join order_items oi
on oi.order_id = o.order_id
group by 1,2


--Query products with stock levels below a certain threshold (e.g., less than 10 units).
--Challenge: Include last restock date and warehouse information.


select 
i.inventory_id,
product_name,
stock as current_stock_left,
i.last_stock_date,
warehouse_id
from products p
join inventory i
on p.product_id = i.product_id
where stock < 10


--Shipping Delays
--Identify orders where the shipping date is later than 3 days after the order date.
--Challenge: Include customer, order details, and delivery provider

select 
c.*,
o.*,
(s.shipping_date)- (o.order_date) as days_of_delivery,
s.shipping_providers as delivery_provider
from orders o
join customers c
on c.customer_id = o.customer_id
join shipping s
on o.order_id =s.order_id
where (s.shipping_date)- (o.order_date) >3

--10. Payment Success Rate 
--Calculate the percentage of successful payments across all orders.
--Challenge: Include breakdowns by payment status (e.g., failed, pending).








