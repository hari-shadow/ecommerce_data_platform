{{
    config(
        materialized='table',
        database='ECOMMERCE_GOLD_DB',
        schema='SALES'
    )
}}

WITH customers AS (
    SELECT * FROM {{ ref('customers') }}
),

order_stats AS (
    SELECT
        customer_id,
        COUNT(order_id)                     AS total_orders,
        SUM(total_payment_value)            AS total_spent,
        AVG(total_payment_value)            AS avg_order_value,
        MIN(order_purchase_timestamp)       AS first_order_date,
        MAX(order_purchase_timestamp)       AS last_order_date,
        AVG(actual_delivery_days)           AS avg_delivery_days
    FROM {{ ref('fact_orders') }}
    GROUP BY customer_id
),

final AS (
    SELECT
        c.customer_id,
        c.customer_unique_id,
        c.customer_city,
        c.customer_state,
        COALESCE(os.total_orders, 0)        AS total_orders,
        COALESCE(os.total_spent, 0)         AS total_spent,
        COALESCE(os.avg_order_value, 0)     AS avg_order_value,
        os.first_order_date,
        os.last_order_date,
        COALESCE(os.avg_delivery_days, 0)   AS avg_delivery_days,
        CASE
            WHEN os.total_spent >= 1000 THEN 'High Value'
            WHEN os.total_spent >= 500  THEN 'Mid Value'
            ELSE 'Low Value'
        END                                 AS customer_segment,
        CURRENT_TIMESTAMP()                 AS _gold_loaded_at
    FROM customers c
    LEFT JOIN order_stats os ON c.customer_id = os.customer_id
)

SELECT * FROM final