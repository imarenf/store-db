 --- Indexes creation

-- We use column name because the courier's name is almost certainly unique (search condition is selective),
-- is very rarely changed for workers already in the database and new data are rarely added
-- to the table itself (only when a new person is hired)
create index courier_name on db_project.Courier(name);

-- We use product name as index because it's unique (search condition is selective), constant and
-- new products are inserted not very often
create index product_name on db_project.Product(name);
