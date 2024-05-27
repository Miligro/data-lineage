CREATE DATABASE healthcare;
GO

USE healthcare;
GO


CREATE TABLE patients (
    patient_id INT IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    date_of_birth DATE NOT NULL,
    gender VARCHAR(10) NOT NULL,
    phone VARCHAR(15),
    age INT,
    email VARCHAR(100),
    address VARCHAR(MAX),
    insurance_id VARCHAR(50),
    emergency_contact VARCHAR(100)
);
GO

CREATE TABLE insurance (
    insurance_id VARCHAR(50) PRIMARY KEY,
    provider_name VARCHAR(100),
    policy_number VARCHAR(50),
    coverage_details VARCHAR(MAX)
);
GO

CREATE TABLE staff (
    staff_id INT IDENTITY PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    role VARCHAR(50),
    department_id INT,
    phone VARCHAR(15),
    email VARCHAR(100),
    address VARCHAR(MAX),
    date_of_joining DATE,
    salary DECIMAL(10, 2)
);
GO

CREATE TABLE departments (
    department_id INT IDENTITY PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    location VARCHAR(100)
);
GO

CREATE TABLE shifts (
    shift_id INT IDENTITY PRIMARY KEY,
    staff_id INT FOREIGN KEY REFERENCES staff(staff_id),
    shift_date DATE,
    start_time TIME,
    end_time TIME
);
GO

CREATE TABLE appointments (
    appointment_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    staff_id INT FOREIGN KEY REFERENCES staff(staff_id),
    appointment_date DATE,
    appointment_time TIME,
    reason VARCHAR(MAX),
    status VARCHAR(20)
);
GO

CREATE TABLE appointment_status (
    status VARCHAR(20) PRIMARY KEY,
    description VARCHAR(MAX)
);
GO

CREATE TABLE medical_records (
    record_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    staff_id INT FOREIGN KEY REFERENCES staff(staff_id),
    record_date DATE,
    diagnosis VARCHAR(MAX),
    treatment VARCHAR(MAX),
    prescription VARCHAR(MAX),
    follow_up_date DATE
);
GO

CREATE TABLE prescriptions (
    prescription_id INT IDENTITY PRIMARY KEY,
    record_id INT FOREIGN KEY REFERENCES medical_records(record_id),
    medication_name VARCHAR(100),
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    duration VARCHAR(50)
);
GO

CREATE TABLE billing (
    bill_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    bill_date DATE,
    amount DECIMAL(10, 2),
    status VARCHAR(20)
);
GO

CREATE TABLE payment_methods (
    method_id INT IDENTITY PRIMARY KEY,
    method_name VARCHAR(50)
);
GO

CREATE TABLE payments (
    payment_id INT IDENTITY PRIMARY KEY,
    bill_id INT FOREIGN KEY REFERENCES billing(bill_id),
    payment_date DATE,
    amount DECIMAL(10, 2),
    method_id INT FOREIGN KEY REFERENCES payment_methods(method_id)
);
GO

CREATE TABLE suppliers (
    supplier_id INT IDENTITY PRIMARY KEY,
    supplier_name VARCHAR(100),
    contact_name VARCHAR(100),
    phone VARCHAR(15),
    email VARCHAR(100),
    address VARCHAR(MAX)
);
GO

CREATE TABLE inventory (
    item_id INT IDENTITY PRIMARY KEY,
    item_name VARCHAR(100),
    category VARCHAR(50),
    quantity INT,
    unit_price DECIMAL(10, 2),
    supplier_id INT FOREIGN KEY REFERENCES suppliers(supplier_id)
);
GO

CREATE TABLE orders (
    order_id INT IDENTITY PRIMARY KEY,
    supplier_id INT FOREIGN KEY REFERENCES suppliers(supplier_id),
    order_date DATE,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20)
);
GO

CREATE TABLE order_items (
    order_item_id INT IDENTITY PRIMARY KEY,
    order_id INT FOREIGN KEY REFERENCES orders(order_id),
    item_id INT FOREIGN KEY REFERENCES inventory(item_id),
    quantity INT,
    unit_price DECIMAL(10, 2)
);
GO

-- Definicje widoków

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

-- Indeksy

CREATE INDEX idx_patients_last_name ON patients(last_name);
CREATE INDEX idx_staff_last_name ON staff(last_name);
CREATE INDEX idx_appointments_date ON appointments(appointment_date);
CREATE INDEX idx_medical_records_date ON medical_records(record_date);
CREATE INDEX idx_billing_date ON billing(bill_date);
CREATE INDEX idx_inventory_category ON inventory(category);
GO

-- Dodatkowe dane testowe

INSERT INTO departments (department_name, location) VALUES
('Cardiology', 'Building A'),
('Neurology', 'Building B'),
('Pediatrics', 'Building C');
GO

INSERT INTO appointment_status (status, description) VALUES
('Scheduled', 'Appointment is scheduled'),
('Completed', 'Appointment is completed'),
('Cancelled', 'Appointment is cancelled');
GO

INSERT INTO payment_methods (method_name) VALUES
('Cash'),
('Credit Card'),
('Insurance');
GO

-- Definicje dalszych tabel

CREATE TABLE lab_tests (
    test_id INT IDENTITY PRIMARY KEY,
    test_name VARCHAR(100),
    description VARCHAR(MAX),
    normal_range VARCHAR(50)
);
GO

CREATE TABLE patient_tests (
    patient_test_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    test_id INT FOREIGN KEY REFERENCES lab_tests(test_id),
    test_date DATE,
    result VARCHAR(100),
    status VARCHAR(20)
);
GO

CREATE TABLE radiology_tests (
    radiology_test_id INT IDENTITY PRIMARY KEY,
    test_name VARCHAR(100),
    description VARCHAR(MAX)
);
GO

CREATE TABLE patient_radiology (
    patient_radiology_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    radiology_test_id INT FOREIGN KEY REFERENCES radiology_tests(radiology_test_id),
    test_date DATE,
    result VARCHAR(MAX),
    status VARCHAR(20)
);
GO

CREATE TABLE surgeries (
    surgery_id INT IDENTITY PRIMARY KEY,
    surgery_name VARCHAR(100),
    description VARCHAR(MAX)
);
GO

CREATE TABLE patient_surgeries (
    patient_surgery_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    surgery_id INT FOREIGN KEY REFERENCES surgeries(surgery_id),
    surgery_date DATE,
    outcome VARCHAR(MAX),
    status VARCHAR(20)
);
GO

CREATE TABLE referrals (
    referral_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    referring_staff_id INT FOREIGN KEY REFERENCES staff(staff_id),
    referred_to_staff_id INT FOREIGN KEY REFERENCES staff(staff_id),
    referral_date DATE,
    reason VARCHAR(MAX),
    status VARCHAR(20)
);
GO

CREATE TABLE feedback (
    feedback_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    staff_id INT FOREIGN KEY REFERENCES staff(staff_id),
    feedback_date DATE,
    feedback VARCHAR(MAX),
    rating INT CHECK (rating BETWEEN 1 AND 5)
);
GO

CREATE TABLE vaccinations (
    vaccination_id INT IDENTITY PRIMARY KEY,
    vaccine_name VARCHAR(100),
    description VARCHAR(MAX),
    manufacturer VARCHAR(100)
);
GO

CREATE TABLE patient_vaccinations (
    patient_vaccination_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    vaccination_id INT FOREIGN KEY REFERENCES vaccinations(vaccination_id),
    vaccination_date DATE,
    dose_number INT,
    administered_by_staff_id INT FOREIGN KEY REFERENCES staff(staff_id)
);
GO

CREATE TABLE allergies (
    allergy_id INT IDENTITY PRIMARY KEY,
    allergy_name VARCHAR(100),
    description VARCHAR(MAX)
);
GO

CREATE TABLE patient_allergies (
    patient_allergy_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    allergy_id INT FOREIGN KEY REFERENCES allergies(allergy_id),
    reaction VARCHAR(100),
    severity VARCHAR(50)
);
GO

CREATE TABLE chronic_conditions (
    condition_id INT IDENTITY PRIMARY KEY,
    condition_name VARCHAR(100),
    description VARCHAR(MAX)
);
GO

CREATE TABLE patient_conditions (
    patient_condition_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    condition_id INT FOREIGN KEY REFERENCES chronic_conditions(condition_id),
    diagnosis_date DATE,
    status VARCHAR(20)
);
GO

CREATE TABLE immunizations (
    immunization_id INT IDENTITY PRIMARY KEY,
    immunization_name VARCHAR(100),
    description VARCHAR(MAX)
);
GO

CREATE TABLE patient_immunizations (
    patient_immunization_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    immunization_id INT FOREIGN KEY REFERENCES immunizations(immunization_id),
    immunization_date DATE,
    administered_by_staff_id INT FOREIGN KEY REFERENCES staff(staff_id)
);
GO

CREATE TABLE wards (
    ward_id INT IDENTITY PRIMARY KEY,
    ward_name VARCHAR(50),
    location VARCHAR(100),
    capacity INT
);
GO

CREATE TABLE beds (
    bed_id INT IDENTITY PRIMARY KEY,
    ward_id INT FOREIGN KEY REFERENCES wards(ward_id),
    bed_number VARCHAR(10),
    status VARCHAR(20)
);
GO

CREATE TABLE patient_beds (
    patient_bed_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    bed_id INT FOREIGN KEY REFERENCES beds(bed_id),
    admission_date DATE,
    discharge_date DATE,
    status VARCHAR(20)
);
GO

CREATE TABLE dietary_plans (
    dietary_plan_id INT IDENTITY PRIMARY KEY,
    plan_name VARCHAR(100),
    description VARCHAR(MAX)
);
GO

CREATE TABLE patient_dietary_plans (
    patient_dietary_plan_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    dietary_plan_id INT FOREIGN KEY REFERENCES dietary_plans(dietary_plan_id),
    start_date DATE,
    end_date DATE,
    status VARCHAR(20)
);
GO

CREATE TABLE insurance_claims (
    claim_id INT IDENTITY PRIMARY KEY,
    insurance_id VARCHAR(50) FOREIGN KEY REFERENCES insurance(insurance_id),
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    bill_id INT FOREIGN KEY REFERENCES billing(bill_id),
    claim_date DATE,
    amount_claimed DECIMAL(10, 2),
    amount_approved DECIMAL(10, 2),
    status VARCHAR(20)
);
GO

CREATE TABLE medications (
    medication_id INT IDENTITY PRIMARY KEY,
    medication_name VARCHAR(100),
    description VARCHAR(MAX),
    stock INT,
    unit_price DECIMAL(10, 2)
);
GO

CREATE TABLE patient_medications (
    patient_medication_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    medication_id INT FOREIGN KEY REFERENCES medications(medication_id),
    prescription_date DATE,
    dosage VARCHAR(50),
    frequency VARCHAR(50),
    duration VARCHAR(50)
);
GO

CREATE TABLE supplier_orders (
    supplier_order_id INT IDENTITY PRIMARY KEY,
    supplier_id INT FOREIGN KEY REFERENCES suppliers(supplier_id),
    order_date DATE,
    total_amount DECIMAL(10, 2),
    status VARCHAR(20)
);
GO

CREATE TABLE supplier_order_items (
    supplier_order_item_id INT IDENTITY PRIMARY KEY,
    supplier_order_id INT FOREIGN KEY REFERENCES supplier_orders(supplier_order_id),
    item_id INT FOREIGN KEY REFERENCES inventory(item_id),
    quantity INT,
    unit_price DECIMAL(10, 2)
);
GO

CREATE TABLE equipment (
    equipment_id INT IDENTITY PRIMARY KEY,
    equipment_name VARCHAR(100),
    category VARCHAR(50),
    purchase_date DATE,
    status VARCHAR(20)
);
GO

CREATE TABLE maintenance (
    maintenance_id INT IDENTITY PRIMARY KEY,
    equipment_id INT FOREIGN KEY REFERENCES equipment(equipment_id),
    maintenance_date DATE,
    description VARCHAR(MAX),
    cost DECIMAL(10, 2),
    performed_by_staff_id INT FOREIGN KEY REFERENCES staff(staff_id)
);
GO

CREATE TABLE blood_types (
    blood_type_id INT IDENTITY PRIMARY KEY,
    blood_type VARCHAR(5)
);
GO

CREATE TABLE blood_donations (
    donation_id INT IDENTITY PRIMARY KEY,
    donor_name VARCHAR(100),
    blood_type_id INT FOREIGN KEY REFERENCES blood_types(blood_type_id),
    donation_date DATE,
    quantity INT
);
GO

CREATE TABLE patient_blood_transfusions (
    transfusion_id INT IDENTITY PRIMARY KEY,
    patient_id INT FOREIGN KEY REFERENCES patients(patient_id),
    blood_type_id INT FOREIGN KEY REFERENCES blood_types(blood_type_id),
    transfusion_date DATE,
    quantity INT,
    performed_by_staff_id INT FOREIGN KEY REFERENCES staff(staff_id)
);
GO

-- Definicje dalszych widoków

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
GO

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
GO

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
GO

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
GO

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
GO

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
GO

SELECT * INTO #temp_female_patients
FROM patients
WHERE gender = 'Female';
GO

SELECT * INTO female_patients FROM #temp_female_patients;
GO

CREATE FUNCTION calculate_age (@birth_date DATE)
RETURNS INT
AS
BEGIN
    RETURN DATEDIFF(YEAR, @birth_date, GETDATE()) -
           CASE WHEN (MONTH(@birth_date) > MONTH(GETDATE()))
                     OR (MONTH(@birth_date) = MONTH(GETDATE()) AND DAY(@birth_date) > DAY(GETDATE()))
                THEN 1 ELSE 0 END;
END;
GO

CREATE FUNCTION get_patient_full_name (@patient INT)
RETURNS VARCHAR(255)
AS
BEGIN
    DECLARE @full_name VARCHAR(255);
    SELECT @full_name = first_name + ' ' + last_name
    FROM patients
    WHERE patient_id = @patient;

    RETURN @full_name;
END;
GO

CREATE PROCEDURE add_new_patient
    @p_first_name VARCHAR(255),
    @p_last_name VARCHAR(255),
    @p_dob DATE,
    @p_gender VARCHAR(50),
    @p_phone VARCHAR(50),
    @p_email VARCHAR(255),
    @p_address TEXT,
    @p_insurance_id VARCHAR(50),
    @p_emergency_contact VARCHAR(255)
AS
BEGIN
    INSERT INTO patients (
        first_name, last_name, date_of_birth, gender, phone, email, address, insurance_id, emergency_contact
    ) VALUES (
        @p_first_name, @p_last_name, @p_dob, @p_gender, @p_phone, @p_email, @p_address, @p_insurance_id, @p_emergency_contact
    );
END;
GO

CREATE PROCEDURE update_patient_age
    @patient INT
AS
BEGIN
    DECLARE @birth_date DATE;
    DECLARE @age INT;

    SELECT @birth_date = date_of_birth
    FROM patients
    WHERE patient_id = @patient;

    SET @age = dbo.calculate_age(@birth_date);

    UPDATE patients
    SET age = @age
    WHERE patient_id = @patient;

    DECLARE @full_name VARCHAR(255);
    SET @full_name = dbo.get_patient_full_name(@patient);
END;
GO

CREATE PROCEDURE create_and_populate_new_table
AS
BEGIN
    SELECT * INTO #temp_patient_data FROM patients
    WHERE gender = 'Female';

    IF NOT EXISTS (SELECT * FROM sysobjects WHERE name='female_patients' AND xtype='U')
    BEGIN
        SELECT * INTO female_patients FROM #temp_patient_data;
    END

    INSERT INTO female_patients (first_name, last_name, date_of_birth, gender, phone, email, address, insurance_id, emergency_contact)
    VALUES ('Jane', 'Doe', '1980-05-05', 'Female', '1234567890', 'jane.doe@example.com', '123 Main St', 'INS123', 'John Doe');

    DROP TABLE IF EXISTS #temp_patient_data;
END;
GO