import os
import random
import psycopg2
from faker import Faker
from datetime import datetime, timedelta
from dotenv import load_dotenv

load_dotenv()

fake = Faker('pt_BR')  # Brazilian locale to match Olist data

DB_URL = os.getenv("NEONDB_URL")

PRODUCT_CATEGORIES = [
    'cama_mesa_banho', 'beleza_saude', 'esporte_lazer', 'informatica_acessorios',
    'moveis_decoracao', 'utilidades_domesticas', 'relogios_presentes', 'telefonia',
    'automotivo', 'brinquedos'
]

ORDER_STATUSES = ['delivered', 'shipped', 'processing', 'canceled']

PAYMENT_TYPES = ['credit_card', 'boleto', 'voucher', 'debit_card']

BRAZILIAN_STATES = [
    'SP', 'RJ', 'MG', 'RS', 'PR', 'SC', 'BA', 'GO', 'ES', 'PE'
]


def get_existing_ids(cur, table, id_col):
    cur.execute(f"SELECT {id_col} FROM {table}")
    return [row[0] for row in cur.fetchall()]


def insert_customer(cur):
    customer_id = fake.uuid4()
    cur.execute("""
        INSERT INTO customers (
            customer_id, customer_unique_id, customer_zip_code_prefix,
            customer_city, customer_state
        ) VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (customer_id) DO NOTHING
    """, (
        customer_id,
        fake.uuid4(),
        fake.postcode()[:5],
        fake.city(),
        random.choice(BRAZILIAN_STATES)
    ))
    return customer_id


def insert_seller(cur):
    seller_id = fake.uuid4()
    cur.execute("""
        INSERT INTO sellers (
            seller_id, seller_zip_code_prefix, seller_city, seller_state
        ) VALUES (%s, %s, %s, %s)
        ON CONFLICT (seller_id) DO NOTHING
    """, (
        seller_id,
        fake.postcode()[:5],
        fake.city(),
        random.choice(BRAZILIAN_STATES)
    ))
    return seller_id


def insert_product(cur):
    product_id = fake.uuid4()
    cur.execute("""
        INSERT INTO products (
            product_id, product_category_name, product_name_lenght,
            product_description_lenght, product_photos_qty,
            product_weight_g, product_length_cm, product_height_cm, product_width_cm
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (product_id) DO NOTHING
    """, (
        product_id,
        random.choice(PRODUCT_CATEGORIES),
        random.randint(20, 60),
        random.randint(100, 500),
        random.randint(1, 5),
        random.randint(100, 5000),
        random.randint(10, 50),
        random.randint(5, 30),
        random.randint(10, 50)
    ))
    return product_id


def insert_order(cur, customer_id):
    order_id = fake.uuid4()
    purchase_time = datetime.now() - timedelta(minutes=random.randint(0, 60))
    status = random.choice(ORDER_STATUSES)

    approved = purchase_time + timedelta(minutes=random.randint(10, 60))
    delivered_carrier = approved + timedelta(days=random.randint(1, 3))
    delivered_customer = delivered_carrier + timedelta(days=random.randint(3, 10))
    estimated_delivery = delivered_carrier + timedelta(days=random.randint(5, 15))

    cur.execute("""
        INSERT INTO orders (
            order_id, customer_id, order_status,
            order_purchase_timestamp, order_approved_at,
            order_delivered_carrier_date, order_delivered_customer_date,
            order_estimated_delivery_date
        ) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (order_id) DO NOTHING
    """, (
        order_id, customer_id, status,
        purchase_time, approved,
        delivered_carrier,
        delivered_customer if status == 'delivered' else None,
        estimated_delivery
    ))
    return order_id


def insert_order_items(cur, order_id, seller_id, product_id):
    num_items = random.randint(1, 3)
    for i in range(1, num_items + 1):
        cur.execute("""
            INSERT INTO order_items (
                order_id, order_item_id, product_id, seller_id,
                shipping_limit_date, price, freight_value
            ) VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            order_id, i, product_id, seller_id,
            datetime.now() + timedelta(days=random.randint(3, 10)),
            round(random.uniform(20, 500), 2),
            round(random.uniform(5, 50), 2)
        ))


def insert_order_payment(cur, order_id):
    cur.execute("""
        INSERT INTO order_payments (
            order_id, payment_sequential, payment_type,
            payment_installments, payment_value
        ) VALUES (%s, %s, %s, %s, %s)
    """, (
        order_id, 1,
        random.choice(PAYMENT_TYPES),
        random.choice([1, 2, 3, 6, 12]),
        round(random.uniform(20, 600), 2)
    ))


def insert_order_review(cur, order_id):
    if random.random() < 0.7:  # 70% chance of review
        score = random.randint(1, 5)
        cur.execute("""
            INSERT INTO order_reviews (
                review_id, order_id, review_score,
                review_comment_title, review_comment_message,
                review_creation_date, review_answer_timestamp
            ) VALUES (%s, %s, %s, %s, %s, %s, %s)
        """, (
            fake.uuid4(), order_id, score,
            fake.sentence(nb_words=4) if score >= 4 else None,
            fake.sentence(nb_words=10),
            datetime.now(),
            datetime.now() + timedelta(days=random.randint(1, 3))
        ))


def generate_batch(num_orders=5):
    conn = psycopg2.connect(DB_URL)
    cur = conn.cursor()

    for _ in range(num_orders):
        customer_id = insert_customer(cur)
        seller_id = insert_seller(cur)
        product_id = insert_product(cur)
        order_id = insert_order(cur, customer_id)
        insert_order_items(cur, order_id, seller_id, product_id)
        insert_order_payment(cur, order_id)
        insert_order_review(cur, order_id)

    conn.commit()
    cur.close()
    conn.close()
    print(f"Inserted {num_orders} new orders at {datetime.now()}")


if __name__ == "__main__":
    generate_batch(num_orders=5)