{{
    config(
        materialized='incremental',
        unique_key='product_id',
        on_schema_change='sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ ref('stg_products') }}

    {% if is_incremental() %}
        WHERE _stg_load_time > (SELECT MAX(t._silver_loaded_at) FROM {{ this }} t)
    {% endif %}
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY product_id
            ORDER BY _stg_load_time DESC
        ) AS rn
    FROM source
    WHERE product_id IS NOT NULL
),

final AS (
    SELECT
        product_id,
        product_category_name,
        TRY_TO_NUMBER(product_name_length)          AS product_name_length,
        TRY_TO_NUMBER(product_description_length)   AS product_description_length,
        TRY_TO_NUMBER(product_photos_qty)           AS product_photos_qty,
        TRY_TO_NUMBER(product_weight_g, 10, 2)      AS product_weight_g,
        TRY_TO_NUMBER(product_length_cm, 10, 2)     AS product_length_cm,
        TRY_TO_NUMBER(product_height_cm, 10, 2)     AS product_height_cm,
        TRY_TO_NUMBER(product_width_cm, 10, 2)      AS product_width_cm,
        CURRENT_TIMESTAMP() AS _silver_loaded_at
    FROM deduped
    WHERE rn = 1
)

SELECT * FROM final