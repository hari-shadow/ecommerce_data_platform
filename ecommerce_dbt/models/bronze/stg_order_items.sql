WITH source AS (
    SELECT _raw_data, _stg_file_name, _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.OLIST.ORDER_ITEMS_RAW
)

SELECT
    _raw_data:order_id::TEXT                    AS order_id,
    _raw_data:order_item_id::INTEGER            AS order_item_id,
    _raw_data:product_id::TEXT                  AS product_id,
    _raw_data:seller_id::TEXT                   AS seller_id,
    _raw_data:shipping_limit_date::TIMESTAMPTZ  AS shipping_limit_date,
    _raw_data:price::NUMERIC(10,2)              AS price,
    _raw_data:freight_value::NUMERIC(10,2)      AS freight_value,
    _stg_file_name,
    _stg_load_time
FROM source