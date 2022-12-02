import random
import time
from collections import defaultdict
from copy import deepcopy
from enum import Enum
from typing import Tuple, Sequence

from mimesis import Person, Address, Food
from mimesis.enums import Gender

INSERT_PATTERN = 'insert into {} {} values '


class Table(Enum):
    order = 'db_project.Order'
    order_products = 'db_project.Order_products'
    client = 'db_project.Client'
    courier = 'db_project.Courier'
    delivery = 'db_project.Delivery'
    product = 'db_project.Product'


COLUMNS = {
    Table.client: '(name, phone_number, address)',
    Table.order: '(client_id, order_time, cost)',
    Table.courier: '(name, phone_number)',
    Table.product: '(name, price)',
    Table.order_products: '(order_id, product_id, number)',
    Table.delivery: '(order_id, courier_id, delivery_time, arrived)'
}


TABLE_NAMES = [Table.client,
               Table.product,
               Table.courier,
               Table.order,
               Table.order_products,
               Table.delivery]


class TableInfo:
    def __init__(self):
        self.table_sizes = defaultdict(int)
        for t_name in TABLE_NAMES:
            self.table_sizes[t_name.value] = 0
        self.products = []
        self.product_cost = defaultdict(int)
        self.order_products = []
        self.delivery_set = set()
        self.order_timestamps = defaultdict(str)


def generate_random_timestamp(start_timestamp=None):
    def str_time_prop(start, end, time_format, prop):
        stime = time.mktime(time.strptime(start, time_format))
        etime = time.mktime(time.strptime(end, time_format))
        ptime = stime + prop * (etime - stime)
        return time.strftime(time_format, time.localtime(ptime))

    def random_date(start, end, prop):
        return str_time_prop(start, end, '%Y-%m-%d %H:%M:%S', prop)

    if start_timestamp is None:
        return random_date("2021-11-19 15:30:00", "2022-04-05 15:57:00", random.random())
    else:
        return random_date(start_timestamp, "2022-04-05 15:57:00", random.random())


def generate_random_cost():
    price = random.randrange(10000) + random.random()
    return '{:.2f}'.format(price)


def get_random_values(table_name, table_info) -> Tuple[Sequence[str]]:
    if table_name == Table.client:
        person = Person('ru')
        gender = random.choice([Gender.MALE, Gender.FEMALE])
        name = person.full_name(gender=gender)
        phone_number = person.telephone()
        address = Address('ru').address()
        return name, phone_number, address
    elif table_name == Table.courier:
        person = Person('ru')
        gender = random.choice([Gender.MALE, Gender.FEMALE])
        name = person.full_name(gender=gender)
        phone_number = person.telephone()
        return name, phone_number
    elif table_name == Table.product:
        def choose_random_product():
            food = Food()
            res = random.choice([1, 2, 3, 4])
            if res == 1:
                return food.dish()
            elif res == 2:
                return food.drink()
            elif res == 3:
                return food.vegetable()
            elif res == 4:
                return food.fruit()
        prod_name = choose_random_product()
        table_info.products.append(prod_name)
        price = generate_random_cost()
        table_info.product_cost[prod_name] = price
        return prod_name, price
    elif table_name == Table.order:
        client_id = random.randrange(0, table_info.table_sizes[Table.client.value]) + 1
        order_time = generate_random_timestamp()
        product_unique_cnt = random.randrange(1, 6)
        prods_copy = deepcopy(table_info.products)
        random.shuffle(prods_copy)
        order_products = prods_copy[:product_unique_cnt]
        count = [random.randint(1, 4) for _ in range(product_unique_cnt)]
        total_cost = sum(map(lambda x, y: float(table_info.product_cost[x]) * y, order_products, count))
        order_id = table_info.table_sizes[Table.order.value] + 1
        table_info.delivery_set.add(order_id)
        table_info.order_timestamps[order_id] = order_time
        for i in range(product_unique_cnt):
            table_info.order_products.append((order_id, table_info.products.index(order_products[i]) + 1, count[i]))
        return client_id, order_time, '{:.2f}'.format(total_cost)
    elif table_name == Table.delivery:
        if len(table_info.delivery_set) == 0:
            return tuple()
        order_id = table_info.delivery_set.pop()
        arrive_chance = random.random()
        arrived = True
        if arrive_chance < 0.1:
            table_info.delivery_set.add(order_id)
            arrived = False
        courier_id = random.randint(0, table_info.table_sizes[Table.courier.value]) + 1
        timestamp = generate_random_timestamp(table_info.order_timestamps[order_id])
        return order_id, courier_id, timestamp, arrived


def generate_inserts():
    table_info = TableInfo()
    for table_name in TABLE_NAMES:
        if table_name == Table.order_products:
            continue
        real_name = table_name.value
        print(f'\n --- Inserts for table {real_name}: \n')
        for i in range(50):
            values = get_random_values(table_name, table_info)
            print(INSERT_PATTERN.format(real_name, COLUMNS[table_name]) + str(values) + ';')
            table_info.table_sizes[real_name] += 1
    print(f'\n --- Inserts for table {Table.order_products.value}: \n')
    for elem in table_info.order_products:
        print(INSERT_PATTERN.format(Table.order_products.value, COLUMNS[Table.order_products]) + str(elem) + ';')


if __name__ == '__main__':
    generate_inserts()
