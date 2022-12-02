  --- Simple sql queries ---

-- Find all deliveries which didn't arrive
select order_id
from db_project.Delivery
where arrived = false;

-- Find all customers sorted by name
select name
from db_project.Client
order by name;

-- Force all deliveries arrive to their destination
update db_project.Delivery
set arrived = true
where order_id in (
    select order_id
    from db_project.Delivery
    where not arrived
);

-- Fire all couriers who doesn't work
delete from db_project.Courier
where courier_id not in (
    select courier_id
    from db_project.Delivery
);