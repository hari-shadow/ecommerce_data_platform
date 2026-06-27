{{
    config(
        materialized='incremental',
        unique_key='customer_id',
        on_schema_change='sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ ref('stg_customers') }}

    {% if is_incremental() %}
        WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})
    {% endif %}
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY customer_id 
            ORDER BY created_at DESC
        ) AS rn
    FROM source
    WHERE customer_id IS NOT NULL
),

final AS (
    SELECT
        customer_id,
        customer_unique_id,
        customer_zip_code_prefix,
        INITCAP(customer_city)  AS customer_city,
        customer_state,
        created_at,
        CURRENT_TIMESTAMP()     AS _silver_loaded_at
    FROM deduped
    WHERE rn = 1
)

SELECT * FROM final