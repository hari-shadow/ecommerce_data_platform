WITH source AS (
    SELECT _raw_data, _stg_file_name, _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.OLIST.ORDERS_RAW
)

SELECT
    _raw_data:order_id::TEXT                        AS order_id,
    _raw_data:customer_id::TEXT                     AS customer_id,
    _raw_data:order_status::TEXT                    AS order_status,
    TRY_TO_TIMESTAMP(_raw_data:order_purchase_timestamp::TEXT)        AS order_purchase_timestamp,
    TRY_TO_TIMESTAMP(_raw_data:order_approved_at::TEXT)               AS order_approved_at,
    TRY_TO_TIMESTAMP(_raw_data:order_delivered_carrier_date::TEXT)    AS order_delivered_carrier_date,
    TRY_TO_TIMESTAMP(_raw_data:order_delivered_customer_date::TEXT)   AS order_delivered_customer_date,
    TRY_TO_TIMESTAMP(_raw_data:order_estimated_delivery_date::TEXT)   AS order_estimated_delivery_date,
    _raw_data:created_at::TIMESTAMPTZ               AS created_at,
    _stg_file_name,
    _stg_load_time
FROM source