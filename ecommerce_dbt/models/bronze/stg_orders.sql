WITH source AS (
    SELECT _raw_data, _stg_file_name, _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.OLIST.ORDERS_RAW
)

SELECT
    _raw_data:order_id::TEXT                        AS order_id,
    _raw_data:customer_id::TEXT                     AS customer_id,
    _raw_data:order_status::TEXT                    AS order_status,
    _raw_data:order_purchase_timestamp::TIMESTAMPTZ AS order_purchase_timestamp,
    _raw_data:order_approved_at::TIMESTAMPTZ        AS order_approved_at,
    _raw_data:order_delivered_carrier_date::TIMESTAMPTZ AS order_delivered_carrier_date,
    _raw_data:order_delivered_customer_date::TIMESTAMPTZ AS order_delivered_customer_date,
    _raw_data:order_estimated_delivery_date::TIMESTAMPTZ AS order_estimated_delivery_date,
    _raw_data:created_at::TIMESTAMPTZ               AS created_at,
    _stg_file_name,
    _stg_load_time
FROM source