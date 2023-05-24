COPY staging_caers_event_product 
(
    fda_first_received_report_date,
    report_id,
    event_date,
    product_type,
    product,
    product_code,
    description,
    patient_age,
    age_units,
    sex,
    case_meddra_preferred_terms,
    case_outcome
)
FROM '/tmp/CAERS-Quarterly--20220930-EXCEL.csv' 
(FORMAT CSV, HEADER, NULL '', ENCODING 'LATIN1');