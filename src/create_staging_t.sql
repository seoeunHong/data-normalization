DROP TABLE IF EXISTS staging_caers_event_product;
CREATE TABLE staging_caers_event_product(
    fda_first_received_report_date date,
    report_id varchar(255),
    event_date date,
    product_type text,
    product text,
    product_code varchar(255),
    description text,
    patient_age decimal,
    age_units varchar(255),
    sex varchar(255),
    case_meddra_preferred_terms text,
    case_outcome text
);