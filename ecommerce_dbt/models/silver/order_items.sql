{{
    config(
        materialized='incremental',
        unique_key=['order_id', 'order_item_id'],
        on_schema_change='sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ ref('stg_order_items') }}

    {% if is_incremental() %}
        WHERE _stg_load_time > (SELECT COALESCE(MAX(t._silver_loaded_at), '1900-01-01'::TIMESTAMP) FROM {{ this }} t)
    {% endif %}
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id, order_item_id
            ORDER BY _stg_load_time DESC
        ) AS rn
    FROM source
),

final AS (
    SELECT
        order_id,
        order_item_id,
        product_id,
        seller_id,
        shipping_limit_date,
        price,
        freight_value,
        CURRENT_TIMESTAMP() AS _silver_loaded_at
    FROM deduped
    WHERE rn = 1
)

SELECT * FROM final