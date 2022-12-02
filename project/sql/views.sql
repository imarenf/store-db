 --- Views creation

-- List of available products
create view available_products as
select name, price from db_project.Product;

-- Get all orders made in the current date
create view cur_day_order as
select name, order_time, cost from db_project.Order
natural join db_project.Client
where order_time::date = current_date;

-- List all free couriers
create or replace view list_couriers as
select * from db_project.Courier
natural join db_project.Delivery
natural join db_project.Order
where current_timestamp <= order_time
or current_timestamp >= delivery_time;