{{
    config(
        materialized='table',
        database='ECOMMERCE_GOLD_DB',
        schema='PRODUCT'
    )
}}

WITH order_items AS (
    SELECT * FROM {{ ref('order_items') }}
),

products AS (
    SELECT * FROM {{ ref('products') }}
),

reviews AS (
    SELECT
        order_id,
        AVG(review_score) AS avg_review_score
    FROM {{ ref('order_reviews') }}
    GROUP BY order_id
),

product_stats AS (
    SELECT
        oi.product_id,
        COUNT(DISTINCT oi.order_id)     AS total_orders,
        SUM(oi.order_item_id)           AS total_units_sold,
        SUM(oi.price)                   AS total_revenue,
        AVG(oi.price)                   AS avg_price,
        SUM(oi.freight_value)           AS total_freight,
        AVG(r.avg_review_score)         AS avg_review_score
    FROM order_items oi
    LEFT JOIN reviews r ON oi.order_id = r.order_id
    GROUP BY oi.product_id
),

final AS (
    SELECT
        p.product_id,
        p.product_category_name,
        p.product_weight_g,
        ps.total_orders,
        ps.total_units_sold,
        ps.total_revenue,
        ps.avg_price,
        ps.total_freight,
        ROUND(ps.avg_review_score, 2)   AS avg_review_score,
        CASE
            WHEN ps.total_revenue >= 10000 THEN 'Top Performer'
            WHEN ps.total_revenue >= 5000  THEN 'Mid Performer'
            ELSE 'Low Performer'
        END                             AS performance_tier,
        CURRENT_TIMESTAMP()             AS _gold_loaded_at
    FROM products p
    LEFT JOIN product_stats ps ON p.product_id = ps.product_id
)

SELECT * FROM final