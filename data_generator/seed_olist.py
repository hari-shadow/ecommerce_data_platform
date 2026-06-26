import pandas as pd
import psycopg2
from dotenv import load_dotenv
import os

load_dotenv()

conn = psycopg2.connect(os.getenv("SUPABASE_URL"))
cur = conn.cursor()

# Path to your CSV files
DATA_PATH = "D:\\Downloads\\olist_data\\"

def load_csv(filename):
    return pd.read_csv(DATA_PATH + filename)

# 1. Customers
print("Loading customers...")
customers = load_csv("olist_customers_dataset.csv")
for _, row in customers.iterrows():
    cur.execute("""
        INSERT INTO customers (customer_id, customer_unique_id, customer_zip_code_prefix, customer_city, customer_state)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (customer_id) DO NOTHING
    """, (row.customer_id, row.customer_unique_id, str(row.customer_zip_code_prefix), row.customer_city, row.customer_state))

# 2. Sellers
print("Loading sellers...")
sellers = load_csv("olist_sellers_dataset.csv")
for _, row in sellers.iterrows():
    cur.execute("""
        INSERT INTO sellers (seller_id, seller_zip_code_prefix, seller_city, seller_state)
        VALUES (%s, %s, %s, %s)
        ON CONFLICT (seller_id) DO NOTHING
    """, (row.seller_id, str(row.seller_zip_code_prefix), row.seller_city, row.seller_state))

# 3. Products
print("Loading products...")
products = load_csv("olist_products_dataset.csv")
for _, row in products.iterrows():
    cur.execute("""
        INSERT INTO products (product_id, product_category_name, product_name_lenght, product_description_lenght, product_photos_qty, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (product_id) DO NOTHING
    """, (row.product_id, row.product_category_name, row.product_name_lenght, row.product_description_lenght,
          row.product_photos_qty, row.product_weight_g, row.product_length_cm, row.product_height_cm, row.product_width_cm))

# 4. Orders
print("Loading orders...")
orders = load_csv("olist_orders_dataset.csv")
orders = orders.where(pd.notnull(orders), None)
for _, row in orders.iterrows():
    cur.execute("""
        INSERT INTO orders (order_id, customer_id, order_status, order_purchase_timestamp, order_approved_at, order_delivered_carrier_date, order_delivered_customer_date, order_estimated_delivery_date)
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (order_id) DO NOTHING
    """, (row.order_id, row.customer_id, row.order_status, row.order_purchase_timestamp,
          row.order_approved_at, row.order_delivered_carrier_date, row.order_delivered_customer_date,
          row.order_estimated_delivery_date))

# 5. Order Items
print("Loading order items...")
order_items = load_csv("olist_order_items_dataset.csv")
order_items = order_items.where(pd.notnull(order_items), None)
for _, row in order_items.iterrows():
    cur.execute("""
        INSERT INTO order_items (order_id, order_item_id, product_id, seller_id, shipping_limit_date, price, freight_value)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (order_id, order_item_id) DO NOTHING
    """, (row.order_id, row.order_item_id, row.product_id, row.seller_id,
          row.shipping_limit_date, row.price, row.freight_value))

# 6. Order Payments
print("Loading order payments...")
payments = load_csv("olist_order_payments_dataset.csv")
for _, row in payments.iterrows():
    cur.execute("""
        INSERT INTO order_payments (order_id, payment_sequential, payment_type, payment_installments, payment_value)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT (order_id, payment_sequential) DO NOTHING
    """, (row.order_id, row.payment_sequential, row.payment_type, row.payment_installments, row.payment_value))

# 7. Order Reviews
print("Loading order reviews...")
reviews = load_csv("olist_order_reviews_dataset.csv")
reviews = reviews.where(pd.notnull(reviews), None)
for _, row in reviews.iterrows():
    cur.execute("""
        INSERT INTO order_reviews (review_id, order_id, review_score, review_comment_title, review_comment_message, review_creation_date, review_answer_timestamp)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (review_id) DO NOTHING
    """, (row.review_id, row.order_id, row.review_score, row.review_comment_title,
          row.review_comment_message, row.review_creation_date, row.review_answer_timestamp))

conn.commit()
cur.close()
conn.close()
print("All data loaded successfully.")