CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    date_of_birth DATE,
    gender VARCHAR(10),
    phone VARCHAR(15),
    age INT,
    email VARCHAR(100),
    address TEXT,
    insurance_id VARCHAR(50),
    emergency_contact VARCHAR(100)
);

CREATE TABLE insurance (
    insurance_id VARCHAR(50) PRIMARY KEY,
    provider_name VARCHAR(100),
    policy_number VARCHAR(50),
    coverage_details TEXT
);

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(50),
    location VARCHAR(100)
);

CREATE TABLE staff (
    staff_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    role VARCHAR(50),
    department_id INT REFERENCES departments(department_id),
    phone VARCHAR(15),
    email VARCHAR(100),
    address TEXT,
    date_of_joining DATE,
    salary NUMERIC(10, 2)
);

CREATE TABLE shifts (
    shift_id SERIAL PRIMARY KEY,
    staff_id INT REFERENCES staff(staff_id),
    shift_date DATE,
    start_time TIME,
    end_time TIME
);



CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    staff_id INT REFERENCES staff(staff_id),
    appointment_date DATE,
    appointment_time TIME,
    reason TEXT,
    status VARCHAR(20)
);

CREATE TABLE appointment_status (
    status VARCHAR(20) PRIMARY KEY,
    description TEXT
);

CREATE TABLE medical_records (
    record_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    staff_id INT REFERENCES staff(staff_id),
    record_date DATE,
    diagnosis TEXT,
    treatment TEXT,
    prescription TEXT,
    follow_up_date DATE
);

CREATE TABLE prescriptions (
    prescription_id SERIAL PRIMARY KEY,
    record_id INT REFERENCES medical_records(record_id),
    medication_name VARCHAR(100),
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    duration VARCHAR(50)
);

CREATE TABLE billing (
    bill_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    bill_date DATE,
    amount NUMERIC(10, 2),
    status VARCHAR(20)
);

CREATE TABLE payment_methods (
    method_id SERIAL PRIMARY KEY,
    method_name VARCHAR(50)
);

CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    bill_id INT REFERENCES billing(bill_id),
    payment_date DATE,
    amount NUMERIC(10, 2),
    method_id INT REFERENCES payment_methods(method_id)
);

CREATE TABLE inventory (
    item_id SERIAL PRIMARY KEY,
    item_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    unit_price NUMERIC(10, 2),
    supplier_id INT
);

CREATE TABLE suppliers (
    supplier_id SERIAL PRIMARY KEY,
    supplier_name VARCHAR(100),
    contact_name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    address TEXT
);

CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES suppliers(supplier_id),
    order_date DATE,
    total_amount NUMERIC(10, 2),
    status VARCHAR(20)
);

CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(order_id),
    item_id INT REFERENCES inventory(item_id),
    quantity INT,
    unit_price NUMERIC(10, 2)
);

CREATE VIEW prescription_details AS
SELECT
    pr.prescription_id,
    mr.record_id,
    mr.patient_id,
    mr.staff_id,
    pr.medication_name,
    pr.dosage,
    pr.frequency,
    pr.duration
FROM
    prescriptions pr
JOIN
    medical_records mr ON pr.record_id = mr.record_id;

CREATE VIEW patient_appointments AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.reason,
    a.status
FROM
    patients p
JOIN
    appointments a ON p.patient_id = a.patient_id;

CREATE VIEW staff_schedule AS
SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    sh.shift_id,
    sh.shift_date,
    sh.start_time,
    sh.end_time
FROM
    staff s
JOIN
    shifts sh ON s.staff_id = sh.staff_id;

CREATE VIEW billing_summary AS
SELECT
    b.bill_id,
    p.patient_id,
    p.first_name,
    p.last_name,
    b.bill_date,
    b.amount,
    b.status
FROM
    billing b
JOIN
    patients p ON b.patient_id = p.patient_id;

CREATE VIEW inventory_status AS
SELECT
    i.item_id,
    i.item_name,
    i.category,
    i.quantity,
    i.unit_price,
    s.supplier_name
FROM
    inventory i
JOIN
    suppliers s ON i.supplier_id = s.supplier_id;

CREATE VIEW prescription_details AS
SELECT
    pr.prescription_id,
    mr.record_id,
    mr.patient_id,
    mr.staff_id,
    pr.medication_name,
    pr.dosage,
    pr.frequency,
    pr.duration
FROM
    prescriptions pr
JOIN
    medical_records mr ON pr.record_id = mr.record_id;

CREATE VIEW staff_details AS
SELECT
    s.staff_id,
    s.first_name,
    s.last_name,
    s.role,
    d.department_name,
    s.phone,
    s.email,
    s.date_of_joining
FROM
    staff s
JOIN
    departments d ON s.department_id = d.department_id;

CREATE VIEW patient_medical_history AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    mr.record_id,
    mr.record_date,
    mr.diagnosis,
    mr.treatment,
    mr.prescription,
    mr.follow_up_date
FROM
    patients p
JOIN
    medical_records mr ON p.patient_id = mr.patient_id;

CREATE INDEX idx_patients_last_name ON patients(last_name);
CREATE INDEX idx_staff_last_name ON staff(last_name);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_medical_records_date ON medical_records(record_date);
CREATE INDEX idx_billing_date ON billing(bill_date);
CREATE INDEX idx_inventory_category ON inventory(category);

INSERT INTO departments (department_name, location) VALUES
('Cardiology', 'Building A'),
('Neurology', 'Building B'),
('Pediatrics', 'Building C');

INSERT INTO appointment_status (status, description) VALUES
('Scheduled', 'Appointment is scheduled'),
('Completed', 'Appointment is completed'),
('Cancelled', 'Appointment is cancelled');

INSERT INTO payment_methods (method_name) VALUES
('Cash'),
('Credit Card'),
('Insurance');

CREATE TABLE lab_tests (
    test_id SERIAL PRIMARY KEY,
    test_name VARCHAR(100),
    description TEXT,
    normal_range VARCHAR(50)
);

CREATE TABLE patient_tests (
    patient_test_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    test_id INT REFERENCES lab_tests(test_id),
    test_date DATE,
    result VARCHAR(100),
    status VARCHAR(20)
);

CREATE TABLE radiology_tests (
    radiology_test_id SERIAL PRIMARY KEY,
    test_name VARCHAR(100),
    description TEXT
);

CREATE TABLE patient_radiology (
    patient_radiology_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    radiology_test_id INT REFERENCES radiology_tests(radiology_test_id),
    test_date DATE,
    result TEXT,
    status VARCHAR(20)
);

CREATE TABLE surgeries (
    surgery_id SERIAL PRIMARY KEY,
    surgery_name VARCHAR(100),
    description TEXT
);

CREATE TABLE patient_surgeries (
    patient_surgery_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    surgery_id INT REFERENCES surgeries(surgery_id),
    surgery_date DATE,
    outcome TEXT,
    status VARCHAR(20)
);

CREATE TABLE referrals (
    referral_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    referring_staff_id INT REFERENCES staff(staff_id),
    referred_to_staff_id INT REFERENCES staff(staff_id),
    referral_date DATE,
    reason TEXT,
    status VARCHAR(20)
);

CREATE TABLE feedback (
    feedback_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    staff_id INT REFERENCES staff(staff_id),
    feedback_date DATE,
    feedback TEXT,
    rating INT CHECK (rating BETWEEN 1 AND 5)
);

CREATE TABLE vaccinations (
    vaccination_id SERIAL PRIMARY KEY,
    vaccine_name VARCHAR(100),
    description TEXT,
    manufacturer VARCHAR(100)
);

CREATE TABLE patient_vaccinations (
    patient_vaccination_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    vaccination_id INT REFERENCES vaccinations(vaccination_id),
    vaccination_date DATE,
    dose_number INT,
    administered_by_staff_id INT REFERENCES staff(staff_id)
);

CREATE TABLE allergies (
    allergy_id SERIAL PRIMARY KEY,
    allergy_name VARCHAR(100),
    description TEXT
);

CREATE TABLE patient_allergies (
    patient_allergy_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    allergy_id INT REFERENCES allergies(allergy_id),
    reaction VARCHAR(100),
    severity VARCHAR(50)
);

CREATE TABLE chronic_conditions (
    condition_id SERIAL PRIMARY KEY,
    condition_name VARCHAR(100),
    description TEXT
);

CREATE TABLE patient_conditions (
    patient_condition_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    condition_id INT REFERENCES chronic_conditions(condition_id),
    diagnosis_date DATE,
    status VARCHAR(20)
);

CREATE TABLE immunizations (
    immunization_id SERIAL PRIMARY KEY,
    immunization_name VARCHAR(100),
    description TEXT
);

CREATE TABLE patient_immunizations (
    patient_immunization_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    immunization_id INT REFERENCES immunizations(immunization_id),
    immunization_date DATE,
    administered_by_staff_id INT REFERENCES staff(staff_id)
);

CREATE TABLE wards (
    ward_id SERIAL PRIMARY KEY,
    ward_name VARCHAR(50),
    location VARCHAR(100),
    capacity INT
);

CREATE TABLE beds (
    bed_id SERIAL PRIMARY KEY,
    ward_id INT REFERENCES wards(ward_id),
    bed_number VARCHAR(10),
    status VARCHAR(20)
);

CREATE TABLE patient_beds (
    patient_bed_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    bed_id INT REFERENCES beds(bed_id),
    admission_date DATE,
    discharge_date DATE,
    status VARCHAR(20)
);

CREATE TABLE dietary_plans (
    dietary_plan_id SERIAL PRIMARY KEY,
    plan_name VARCHAR(100),
    description TEXT
);

CREATE TABLE patient_dietary_plans (
    patient_dietary_plan_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    dietary_plan_id INT REFERENCES dietary_plans(dietary_plan_id),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);

CREATE TABLE insurance_claims (
    claim_id SERIAL PRIMARY KEY,
    insurance_id VARCHAR(50) REFERENCES insurance(insurance_id),
    patient_id INT REFERENCES patients(patient_id),
    bill_id INT REFERENCES billing(bill_id),
    claim_date DATE,
    amount_claimed NUMERIC(10, 2),
    amount_approved NUMERIC(10, 2),
    status VARCHAR(20)
);

CREATE TABLE medications (
    medication_id SERIAL PRIMARY KEY,
    medication_name VARCHAR(100),
    description TEXT,
    stock INT,
    unit_price NUMERIC(10, 2)
);

CREATE TABLE patient_medications (
    patient_medication_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    medication_id INT REFERENCES medications(medication_id),
    prescription_date DATE,
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    duration VARCHAR(50)
);

CREATE TABLE supplier_orders (
    supplier_order_id SERIAL PRIMARY KEY,
    supplier_id INT REFERENCES suppliers(supplier_id),
    order_date DATE,
    total_amount NUMERIC(10, 2),
    status VARCHAR(20)
);

CREATE TABLE supplier_order_items (
    supplier_order_item_id SERIAL PRIMARY KEY,
    supplier_order_id INT REFERENCES supplier_orders(supplier_order_id),
    item_id INT REFERENCES inventory(item_id),
    quantity INT,
    unit_price NUMERIC(10, 2)
);

CREATE TABLE equipment (
    equipment_id SERIAL PRIMARY KEY,
    equipment_name VARCHAR(100),
    category VARCHAR(50),
    purchase_date DATE,
    status VARCHAR(20)
);

CREATE TABLE maintenance (
    maintenance_id SERIAL PRIMARY KEY,
    equipment_id INT REFERENCES equipment(equipment_id),
    maintenance_date DATE,
    description TEXT,
    cost NUMERIC(10, 2),
    performed_by_staff_id INT REFERENCES staff(staff_id)
);

CREATE TABLE blood_types (
    blood_type_id SERIAL PRIMARY KEY,
    blood_type VARCHAR(5)
);

CREATE TABLE blood_donations (
    donation_id SERIAL PRIMARY KEY,
    donor_name VARCHAR(100),
    blood_type_id INT REFERENCES blood_types(blood_type_id),
    donation_date DATE,
    quantity INT
);

CREATE TABLE patient_blood_transfusions (
    transfusion_id SERIAL PRIMARY KEY,
    patient_id INT REFERENCES patients(patient_id),
    blood_type_id INT REFERENCES blood_types(blood_type_id),
    transfusion_date DATE,
    quantity INT,
    performed_by_staff_id INT REFERENCES staff(staff_id)
);

CREATE VIEW patient_lab_tests AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    pt.patient_test_id,
    lt.test_name,
    pt.test_date,
    pt.result,
    pt.status
FROM
    patients p
JOIN
    patient_tests pt ON p.patient_id = pt.patient_id
JOIN
    lab_tests lt ON pt.test_id = lt.test_id;

CREATE VIEW patient_radiology_tests AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    pr.patient_radiology_id,
    rt.test_name,
    pr.test_date,
    pr.result,
    pr.status
FROM
    patients p
JOIN
    patient_radiology pr ON p.patient_id = pr.patient_id
JOIN
    radiology_tests rt ON pr.radiology_test_id = rt.radiology_test_id;

CREATE VIEW patient_surgeries_details AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    ps.patient_surgery_id,
    s.surgery_name,
    ps.surgery_date,
    ps.outcome,
    ps.status
FROM
    patients p
JOIN
    patient_surgeries ps ON p.patient_id = ps.patient_id
JOIN
    surgeries s ON ps.surgery_id = s.surgery_id;

CREATE VIEW patient_referrals AS
SELECT
    r.referral_id,
    r.patient_id,
    p.first_name,
    p.last_name,
    r.referring_staff_id,
    rs.first_name AS referring_first_name,
    rs.last_name AS referring_last_name,
    r.referred_to_staff_id,
    rt.first_name AS referred_first_name,
    rt.last_name AS referred_last_name,
    r.referral_date,
    r.reason,
    r.status
FROM
    referrals r
JOIN
    patients p ON r.patient_id = p.patient_id
JOIN
    staff rs ON r.referring_staff_id = rs.staff_id
JOIN
    staff rt ON r.referred_to_staff_id = rt.staff_id;

CREATE VIEW patient_feedback_details AS
SELECT
    f.feedback_id,
    f.patient_id,
    p.first_name,
    p.last_name,
    f.staff_id,
    s.first_name AS staff_first_name,
    s.last_name AS staff_last_name,
    f.feedback_date,
    f.feedback,
    f.rating
FROM
    feedback f
JOIN
    patients p ON f.patient_id = p.patient_id
JOIN
    staff s ON f.staff_id = s.staff_id;

CREATE VIEW patient_vaccinations_details AS
SELECT
    pv.patient_vaccination_id,
    pv.patient_id,
    p.first_name,
    p.last_name,
    pv.vaccination_id,
    v.vaccine_name,
    pv.vaccination_date,
    pv.dose_number,
    pv.administered_by_staff_id,
    s.first_name AS staff_first_name,
    s.last_name AS staff_last_name
FROM
    patient_vaccinations pv
JOIN
    patients p ON pv.patient_id = p.patient_id
JOIN
    vaccinations v ON pv.vaccination_id = v.vaccination_id
JOIN
    staff s ON pv.administered_by_staff_id = s.staff_id;

CREATE TEMP TABLE temp_female_patients AS
    SELECT * FROM patients
    WHERE gender = 'Female';

CREATE TABLE female_patients AS SELECT * FROM temp_female_patients;

CREATE OR REPLACE FUNCTION calculate_age(birth_date DATE)
RETURNS INT AS $$
BEGIN
    RETURN DATE_PART('year', AGE(birth_date));
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE FUNCTION get_patient_full_name(patient INT)
RETURNS VARCHAR AS $$
DECLARE
    full_name VARCHAR;
BEGIN
    SELECT first_name || ' ' || last_name INTO full_name
    FROM patients
    WHERE patient_id = patient;

    RETURN full_name;
END;
$$ LANGUAGE plpgsql;

CREATE OR REPLACE PROCEDURE add_new_patient(
    p_first_name VARCHAR,
    p_last_name VARCHAR,
    p_dob DATE,
    p_gender VARCHAR,
    p_phone VARCHAR,
    p_email VARCHAR,
    p_address TEXT,
    p_insurance_id VARCHAR,
    p_emergency_contact VARCHAR
)
LANGUAGE plpgsql
AS $$
BEGIN
    INSERT INTO patients (
        first_name, last_name, date_of_birth, gender, phone, email, address, insurance_id, emergency_contact
    ) VALUES (
        p_first_name, p_last_name, p_dob, p_gender, p_phone, p_email, p_address, p_insurance_id, p_emergency_contact
    );
END;
$$;

CREATE OR REPLACE PROCEDURE update_patient_age(patient INT)
LANGUAGE plpgsql
AS $$
DECLARE
    birth_date DATE;
    age INT;
BEGIN
    SELECT date_of_birth INTO birth_date
    FROM patients p
    WHERE patient_id = patient;

    age := calculate_age(birth_date);

    UPDATE patients
    SET age = age
    WHERE patient_id = patient;

    PERFORM get_patient_full_name(patient);
END;
$$;

CREATE OR REPLACE PROCEDURE create_and_populate_new_table()
LANGUAGE plpgsql
AS $$
BEGIN
    CREATE TEMP TABLE temp_patient_data AS
    SELECT * FROM patients
    WHERE gender = 'Female';

    CREATE TABLE IF NOT EXISTS female_patients AS
    SELECT * FROM temp_patient_data;

    INSERT INTO female_patients (first_name, last_name, date_of_birth, gender, phone, email, address, insurance_id, emergency_contact)
    VALUES ('Jane', 'Doe', '1980-05-05', 'Female', '1234567890', 'jane.doe@example.com', '123 Main St', 'INS123', 'John Doe');

    DROP TABLE IF EXISTS temp_patient_data;
END;
$$;

CREATE TEMPORARY TABLE shift_temp AS SELECT
st.first_name, st.last_name, sh.start_time, sh.end_time, st.department_id
FROM staff st JOIN shifts sh ON st.staff_id = sh.staff_id;

CREATE TABLE staff_first_shift AS SELECT st.*, d.location
FROM shift_temp st JOIN departments d ON st.department_id = d.department_id;

CREATE TEMPORARY TABLE temp_patients_appointments AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    pa.appointment_id,
    pa.appointment_date,
    pa.appointment_time,
    pa.reason,
    pa.status
FROM
    patients p
JOIN
    patient_appointments pa ON p.patient_id = pa.patient_id
WHERE
    pa.status = 'Scheduled';

CREATE TABLE patients_scheduled_appointments AS
SELECT
    t.patient_id,
    t.first_name,
    t.last_name,
    t.appointment_id,
    t.appointment_date,
    t.appointment_time,
    t.reason,
    t.status,
    s.first_name AS staff_first_name,
    s.last_name AS staff_last_name,
    s.role AS staff_role
FROM
    temp_patients_appointments t
JOIN
    appointments a ON t.appointment_id = a.appointment_id
JOIN
    staff s ON a.staff_id = s.staff_id
WHERE
    s.role = 'Doctor';