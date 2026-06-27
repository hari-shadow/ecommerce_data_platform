{{
    config(
        materialized='incremental',
        unique_key='order_id',
        on_schema_change='sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ ref('stg_orders') }}

    {% if is_incremental() %}
        WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})
    {% endif %}
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id
            ORDER BY created_at DESC
        ) AS rn
    FROM source
    WHERE order_id IS NOT NULL
),

final AS (
    SELECT
        order_id,
        customer_id,
        order_status,
        TRY_TO_TIMESTAMP(order_purchase_timestamp::TEXT)        AS order_purchase_timestamp,
        TRY_TO_TIMESTAMP(order_approved_at::TEXT)               AS order_approved_at,
        TRY_TO_TIMESTAMP(order_delivered_carrier_date::TEXT)    AS order_delivered_carrier_date,
        TRY_TO_TIMESTAMP(order_delivered_customer_date::TEXT)   AS order_delivered_customer_date,
        TRY_TO_TIMESTAMP(order_estimated_delivery_date::TEXT)   AS order_estimated_delivery_date,
        created_at,
        CURRENT_TIMESTAMP() AS _silver_loaded_at
    FROM deduped
    WHERE rn = 1
)

SELECT * FROM final