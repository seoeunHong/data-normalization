CREATE TABLE product_description (
    product_code varchar(3),
    description varchar(44),
    PRIMARY KEY (product_code)
);

CREATE TABLE product (
    product_id serial,
    product_code varchar(3) NOT NULL,
    product_type varchar(11) NOT NULL,
    product varchar(200) NOT NULL,
    PRIMARY KEY (product_id),
    CONSTRAINT product_ibfk_1 FOREIGN KEY (product_code) REFERENCES product_description (product_code)
);

CREATE TABLE patient_info (
    patient_id serial,
    age int,
    sex varchar(12),
    PRIMARY KEY (patient_id)
);

CREATE TABLE caers_case (
    id serial,
    report_id varchar(15) NOT NULL,
    patient_id int NOT NULL,
    product_id int NOT NULL,
    fda_first_received_report_date date NOT NULL,
    event_date date,
    PRIMARY KEY (id),
    CONSTRAINT caers_case_ibfk_1 FOREIGN KEY (patient_id) REFERENCES patient_info (patient_id),
    CONSTRAINT caers_case_ibfk_2 FOREIGN KEY (product_id) REFERENCES product (product_id)
);

CREATE TABLE terms(
    term_id serial,
    term varchar(255) NOT NULL,
    PRIMARY KEY (term_id)
);

CREATE TABLE case_terms (
    id int NOT NULL,
    term_id int NOT NULL,
    CONSTRAINT case_terms_ibfk_1 FOREIGN KEY (id) REFERENCES caers_case (id),
    CONSTRAINT case_terms_ibfk_2 FOREIGN KEY (term_id) REFERENCES terms (term_id)
);

CREATE TABLE outcomes (
    outcome_id serial,
    outcome varchar(255) NOT NULL,
    PRIMARY KEY(outcome_id)
);

CREATE TABLE case_outcomes (
    id int NOT NULL,
    outcome_id int NOT NULL,
    CONSTRAINT case_outcomes_ibfk_1 FOREIGN KEY (id) REFERENCES caers_case (id),
    CONSTRAINT case_outcomes_ibfk_2 FOREIGN KEY (outcome_id) REFERENCES outcomes (outcome_id)
);