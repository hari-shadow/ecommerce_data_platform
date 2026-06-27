WITH source AS (
    SELECT _raw_data, _stg_file_name, _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.OLIST.ORDER_REVIEWS_RAW
)

SELECT
    _raw_data:review_id::TEXT                       AS review_id,
    _raw_data:order_id::TEXT                        AS order_id,
    _raw_data:review_score::INTEGER                 AS review_score,
    _raw_data:review_comment_title::TEXT            AS review_comment_title,
    _raw_data:review_comment_message::TEXT          AS review_comment_message,
    _raw_data:review_creation_date::TIMESTAMPTZ     AS review_creation_date,
    _raw_data:review_answer_timestamp::TIMESTAMPTZ  AS review_answer_timestamp,
    _raw_data:created_at::TIMESTAMPTZ               AS created_at,
    _stg_file_name,
    _stg_load_time
FROM source