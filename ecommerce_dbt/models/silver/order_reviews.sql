{{
    config(
        materialized='incremental',
        unique_key='review_id',
        on_schema_change='sync_all_columns'
    )
}}

WITH source AS (
    SELECT * FROM {{ ref('stg_order_reviews') }}

    {% if is_incremental() %}
        WHERE created_at > (SELECT MAX(created_at) FROM {{ this }})
    {% endif %}
),

deduped AS (
    SELECT *,
        ROW_NUMBER() OVER (
            PARTITION BY review_id
            ORDER BY created_at DESC
        ) AS rn
    FROM source
    WHERE review_id IS NOT NULL
),

final AS (
    SELECT
        review_id,
        order_id,
        review_score,
        review_comment_title,
        review_comment_message,
        review_creation_date,
        review_answer_timestamp,
        created_at,
        CURRENT_TIMESTAMP() AS _silver_loaded_at
    FROM deduped
    WHERE rn = 1
)

SELECT * FROM final