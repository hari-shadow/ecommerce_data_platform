{{
    config(
        materialized='incremental',
        unique_key=['order_id', 'payment_sequential'],
        on_schema_change='sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ ref('stg_order_payments') }}

    {% if is_incremental() %}
        WHERE _stg_load_time > (SELECT COALESCE(MAX(t._silver_loaded_at), '1900-01-01'::TIMESTAMP) FROM {{ this }} t)
    {% endif %}
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY order_id, payment_sequential
            ORDER BY _stg_load_time DESC
        ) AS rn
    FROM source
),

final AS (
    SELECT
        order_id,
        payment_sequential,
        payment_type,
        payment_installments,
        payment_value,
        CURRENT_TIMESTAMP() AS _silver_loaded_at
    FROM deduped
    WHERE rn = 1
)

SELECT * FROM final