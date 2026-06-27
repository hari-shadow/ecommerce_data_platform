{{
    config(
        materialized='table',
        database='ECOMMERCE_GOLD_DB',
        schema='SALES'
    )
}}

WITH orders AS (
    SELECT * FROM {{ ref('orders') }}
),

customers AS (
    SELECT * FROM {{ ref('customers') }}
),

payments AS (
    SELECT
        order_id,
        SUM(payment_value)          AS total_payment_value,
        COUNT(payment_sequential)   AS total_payment_installments,
        MAX(payment_type)           AS payment_type
    FROM {{ ref('order_payments') }}
    GROUP BY order_id
),

order_items AS (
    SELECT
        order_id,
        COUNT(order_item_id)        AS total_items,
        SUM(price)                  AS total_price,
        SUM(freight_value)          AS total_freight
    FROM {{ ref('order_items') }}
    GROUP BY order_id
),

final AS (
    SELECT
        o.order_id,
        o.customer_id,
        c.customer_city,
        c.customer_state,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_approved_at,
        o.order_delivered_customer_date,
        o.order_estimated_delivery_date,
        DATEDIFF('day',
            o.order_purchase_timestamp,
            o.order_delivered_customer_date)    AS actual_delivery_days,
        DATEDIFF('day',
            o.order_purchase_timestamp,
            o.order_estimated_delivery_date)    AS estimated_delivery_days,
        oi.total_items,
        oi.total_price,
        oi.total_freight,
        p.total_payment_value,
        p.payment_type,
        p.total_payment_installments,
        CURRENT_TIMESTAMP()                     AS _gold_loaded_at
    FROM orders o
    LEFT JOIN customers c ON o.customer_id = c.customer_id
    LEFT JOIN payments p ON o.order_id = p.order_id
    LEFT JOIN order_items oi ON o.order_id = oi.order_id
)

SELECT * FROM final