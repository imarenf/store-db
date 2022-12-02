 ------------------------- PROJECT BEGINNING ---------------------------

 --- DDL script for database creation ---

create schema db_project;

create table db_project.Order (
    order_id serial primary key,
    client_id serial,
    order_time timestamp not null,
    cost numeric(8, 2) check ( cost > 0 )
);

create table db_project.Client (
  client_id serial primary key,
  name varchar(40) not null,
  phone_number varchar(15) not null unique,
  address text not null
);

create table db_project.Courier (
    courier_id serial primary key,
    name varchar(40) not null,
    phone_number varchar(15) not null unique
);

create table db_project.Product (
    product_id serial primary key,
    name varchar(40) not null unique,
    price numeric(6, 2) check ( price > 0 )
);

create table db_project.Order_products (
    id serial primary key,
    order_id serial,
    product_id serial,
    number int not null
);

create table db_project.Delivery (
    delivery_id serial primary key,
    order_id serial,
    courier_id serial,
    delivery_time timestamp,
    arrived bool
);

alter table db_project.Order add foreign key (client_id)
    references db_project.Client (client_id);
alter table db_project.Order_products add foreign key (order_id)
    references db_project.Order (order_id);
alter table db_project.Order_products add foreign key (product_id)
    references db_project.Product (product_id);
alter table db_project.Delivery add foreign key (order_id)
    references db_project.Order (order_id);
alter table db_project.Delivery add foreign key (courier_id)
    references db_project.Courier (courier_id);

alter table db_project.Client
alter column phone_number set data type varchar(25);

alter table db_project.Courier
alter column phone_number set data type varchar(25);