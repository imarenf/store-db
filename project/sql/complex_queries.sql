 --- Complicated sql queries ---

-- Get products count in orders from clients whose name starts with 'A'
select order_id, count(product_id) as product_number, name from db_project.Order_products
inner join db_project.Order using(order_id)
inner join db_project.Client using (client_id)
where name like 'А%'
group by order_id, name
having count(product_id) > 2
order by product_number desc;

-- Get cumulative summary of order cost for all clients
select client_id, sum(cost) over (
    partition by client_id
    order by cost
) as avg_order_cost
from db_project.Delivery
inner join db_project.Order using(order_id);

-- Get number of orders for every client by date and numerate order for client
select name, order_time::date as date, count(order_id) over (
    partition by name, order_time::date
) as orders_in_current_date,
row_number() over (
    partition by name
) as order_number
from db_project.Order
natural join db_project.Client;

-- Get average product price and number of products for every order
select order_id, avg(price) over (
    partition by order_id
) as avg_product_price,
first_value(number) over (
    partition by order_id
) as number_of_products,
name as product_name
from db_project.Order_products
inner join db_project.Product using(product_id);

--Get cumulative order count for product
select product_id, count(order_id) over (
    partition by product_id
    order by order_id
) as cumulative_order_cnt
from db_project.Product
left join db_project.Order_products
using (product_id);