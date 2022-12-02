 --- Functions, procedures and triggers ---

-- Calculates order price after new order inserted
create or replace function calculate_sum()
returns trigger
as $$
declare
    val int := 0;
    ord_id int;
begin
    select new.order_id into ord_id;

    select sum(ord.number * p.price)
    into strict val
    from db_project.Order_products ord
    inner join db_project.Product p using(product_id)
    where order_id = ord_id;

    update db_project.Order
    set cost = val
    where order_id = ord_id;

    return new;
end;
$$ language plpgsql;

-- Trigger to automatically calculate order price when a new order appears
drop trigger if exists calculate_order_value on db_project.Order;
create trigger calculate_order_value
    after update on db_project.Order
    execute function calculate_sum();

-- The procedure which should be used to insert a new order
create or replace procedure add_order(cl_id int, products_mapping int[], ord_time timestamp default null)
as $$
declare
    ord_id int;
    map int[];
begin
    if ord_time is null then
        select current_timestamp(0)::timestamp into ord_time;
    end if;

    select count(*) + 1 from db_project.Order into ord_id;

    insert into db_project.Order (order_id, client_id, order_time, cost)
    values (ord_id, cl_id, ord_time, null);

    foreach map slice 1 in array products_mapping
    loop
        insert into db_project.order_products (order_id, product_id, number)
        values (ord_id, map[0], map[1]);
    end loop;

    -- Call trigger
    update db_project.Order
    set cost = 0.01
    where order_id = ord_id;

end;
$$ language plpgsql;