{{ config(
    materialized='table',
    database='ECOMMERCE_GOLD_DB',
    schema='SALES'
) }}

WITH orders AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        order_purchase_timestamp,
        DATE(order_purchase_timestamp) AS order_date
    FROM {{ ref('orders') }}
    WHERE order_status = 'delivered'
      AND order_purchase_timestamp IS NOT NULL
),

payments AS (
    SELECT
        order_id,
        SUM(payment_value) AS total_brl
    FROM {{ ref('order_payments') }}
    GROUP BY order_id
),

joined AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_status,
        o.order_purchase_timestamp,
        o.order_date,
        p.total_brl,
        e.rate AS brl_to_usd
    FROM orders o
    LEFT JOIN payments p ON o.order_id = p.order_id
    ASOF JOIN {{ ref('exchange_rates') }} e
        MATCH_CONDITION (o.order_date >= e.rate_date)
)

SELECT
    order_id,
    customer_id,
    order_status,
    order_purchase_timestamp,
    order_date,
    total_brl,
    brl_to_usd,
    ROUND(total_brl * brl_to_usd, 2) AS total_usd,
    CURRENT_TIMESTAMP() AS _gold_loaded_at
FROM joined
WHERE total_brl IS NOT NULL