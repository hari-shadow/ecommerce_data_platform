WITH source AS (
    SELECT _raw_data, _stg_file_name, _stg_load_time
    FROM ECOMMERCE_BRONZE_DB.OLIST.ORDER_PAYMENTS_RAW
)

SELECT
    _raw_data:order_id::TEXT                AS order_id,
    _raw_data:payment_sequential::INTEGER   AS payment_sequential,
    _raw_data:payment_type::TEXT            AS payment_type,
    _raw_data:payment_installments::INTEGER AS payment_installments,
    _raw_data:payment_value::NUMERIC(10,2)  AS payment_value,
    _stg_file_name,
    _stg_load_time
FROM source