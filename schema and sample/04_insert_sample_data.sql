-- ============================================================================
-- LIGONINĖS VALDYMO SISTEMA - SAMPLE DATA
-- Oracle APEX 22.1.0
-- Versija: 1.0
-- Data: 2025-12-13
-- ============================================================================
-- Šis scriptas įterpia pavyzdinius duomenis testavimui ir demonstravimui
-- ============================================================================

-- ============================================================================
-- 1. DEPARTMENTS (Skyriai)
-- ============================================================================
INSERT INTO departments (department_name, description, phone_number, building, floor_number, budget, is_active)
VALUES ('Kardiologija', 'Širdies ir kraujagyslių ligų skyrius', '+370 5 2601001', 'A korpusas', 3, 500000, 'Y');

INSERT INTO departments (department_name, description, phone_number, building, floor_number, budget, is_active)
VALUES ('Chirurgija', 'Bendroji chirurgija ir operacijos', '+370 5 2601002', 'A korpusas', 2, 750000, 'Y');

INSERT INTO departments (department_name, description, phone_number, building, floor_number, budget, is_active)
VALUES ('Pediatrija', 'Vaikų ligų skyrius', '+370 5 2601003', 'B korpusas', 1, 400000, 'Y');

INSERT INTO departments (department_name, description, phone_number, building, floor_number, budget, is_active)
VALUES ('Onkologija', 'Vėžio ligų gydymo skyrius', '+370 5 2601004', 'C korpusas', 4, 600000, 'Y');

INSERT INTO departments (department_name, description, phone_number, building, floor_number, budget, is_active)
VALUES ('Neurologija', 'Nervų sistemos ligų skyrius', '+370 5 2601005', 'A korpusas', 4, 450000, 'Y');

INSERT INTO departments (department_name, description, phone_number, building, floor_number, budget, is_active)
VALUES ('Ortopedija', 'Kaulų ir sąnarių skyrius', '+370 5 2601006', 'B korpusas', 2, 550000, 'Y');

COMMIT;

-- ============================================================================
-- 2. EMPLOYEES (Darbuotojai)
-- ============================================================================
-- Gydytojai
INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Jonas', 'Petraitis', DATE '1975-03-15', 'M', 'jonas.petraitis@hospital.lt', '+370 600 11111', 'Gedimino g. 15', 'Vilnius', 'LT-01103', DATE '2010-01-15', 'ACTIVE', 4500);

INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Rūta', 'Kazlauskienė', DATE '1980-07-22', 'F', 'ruta.kazlauskiene@hospital.lt', '+370 600 22222', 'Verkių g. 28', 'Vilnius', 'LT-08221', DATE '2012-03-01', 'ACTIVE', 4200);

INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Mindaugas', 'Jankauskas', DATE '1978-11-10', 'M', 'mindaugas.jankauskas@hospital.lt', '+370 600 33333', 'Pilaitės pr. 5', 'Vilnius', 'LT-04352', DATE '2008-06-15', 'ACTIVE', 4800);

INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Laura', 'Balčiūnaitė', DATE '1985-05-18', 'F', 'laura.balciunaite@hospital.lt', '+370 600 44444', 'Savanorių pr. 123', 'Vilnius', 'LT-03116', DATE '2015-09-01', 'ACTIVE', 3800);

INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Tomas', 'Vasiliauskas', DATE '1972-02-28', 'M', 'tomas.vasiliauskas@hospital.lt', '+370 600 55555', 'Konstitucijos pr. 7', 'Vilnius', 'LT-09308', DATE '2005-11-20', 'ACTIVE', 5200);

INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Jūratė', 'Adamkutė', DATE '1983-09-05', 'F', 'jurate.adamkute@hospital.lt', '+370 600 66666', 'Ukmergės g. 234', 'Vilnius', 'LT-07157', DATE '2014-04-10', 'ACTIVE', 4000);

-- Seserys
INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Vida', 'Paulauskienė', DATE '1988-06-12', 'F', 'vida.paulauskiene@hospital.lt', '+370 600 77777', 'Kalvarijų g. 45', 'Vilnius', 'LT-08310', DATE '2013-02-01', 'ACTIVE', 2200);

INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Ingrida', 'Juškevičienė', DATE '1990-04-20', 'F', 'ingrida.juskeviciene@hospital.lt', '+370 600 88888', 'Žirmūnų g. 67', 'Vilnius', 'LT-09239', DATE '2016-08-15', 'ACTIVE', 2100);

INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Greta', 'Norkūnaitė', DATE '1992-01-15', 'F', 'greta.norkunaite@hospital.lt', '+370 600 99999', 'Antakalnio g. 89', 'Vilnius', 'LT-10312', DATE '2018-05-01', 'ACTIVE', 2000);

INSERT INTO employees (first_name, last_name, date_of_birth, gender, email, phone_number, address, city, postal_code, hire_date, employment_status, salary)
VALUES ('Neringa', 'Mockutė', DATE '1989-12-08', 'F', 'neringa.mockute@hospital.lt', '+370 600 10101', 'Fabijoniškių g. 12', 'Vilnius', 'LT-07101', DATE '2017-01-10', 'ACTIVE', 2150);

COMMIT;

-- ============================================================================
-- 3. DOCTORS (Gydytojai)
-- ============================================================================
INSERT INTO doctors (doctor_id, department_id, specialization, license_number, consultation_fee, years_of_experience, education, available_for_emergency)
VALUES (1, 1, 'Kardiologas', 'LT-DOC-001234', 80, 15, 'Vilniaus universitetas, Medicinos fakultetas', 'Y');

INSERT INTO doctors (doctor_id, department_id, specialization, license_number, consultation_fee, years_of_experience, education, available_for_emergency)
VALUES (2, 2, 'Chirurgas', 'LT-DOC-002345', 100, 13, 'Kauno medicinos universitetas, Chirurgijos rezidentūra', 'Y');

INSERT INTO doctors (doctor_id, department_id, specialization, license_number, consultation_fee, years_of_experience, education, available_for_emergency)
VALUES (3, 3, 'Pediatras', 'LT-DOC-003456', 70, 17, 'Vilniaus universitetas, Pediatrijos specializacija', 'Y');

INSERT INTO doctors (doctor_id, department_id, specialization, license_number, consultation_fee, years_of_experience, education, available_for_emergency)
VALUES (4, 4, 'Onkologas', 'LT-DOC-004567', 120, 10, 'Vilniaus universitetas, Onkologijos centras', 'N');

INSERT INTO doctors (doctor_id, department_id, specialization, license_number, consultation_fee, years_of_experience, education, available_for_emergency)
VALUES (5, 5, 'Neurologas', 'LT-DOC-005678', 90, 20, 'Kauno medicinos universitetas, Neurologijos klinika', 'Y');

INSERT INTO doctors (doctor_id, department_id, specialization, license_number, consultation_fee, years_of_experience, education, available_for_emergency)
VALUES (6, 6, 'Ortopedas-Traumatologas', 'LT-DOC-006789', 110, 12, 'Vilniaus universitetas, Ortopedijos ir traumatologijos centras', 'Y');

COMMIT;

-- Nustatome skyriams vadovus
UPDATE departments SET head_doctor_id = 1 WHERE department_id = 1;
UPDATE departments SET head_doctor_id = 2 WHERE department_id = 2;
UPDATE departments SET head_doctor_id = 3 WHERE department_id = 3;
UPDATE departments SET head_doctor_id = 4 WHERE department_id = 4;
UPDATE departments SET head_doctor_id = 5 WHERE department_id = 5;
UPDATE departments SET head_doctor_id = 6 WHERE department_id = 6;

COMMIT;

-- ============================================================================
-- 4. NURSES (Medicinos seserys)
-- ============================================================================
INSERT INTO nurses (nurse_id, department_id, certification_level, shift_preference, license_number)
VALUES (7, 1, 'Aukštasis', 'DAY', 'LT-NRS-007890');

INSERT INTO nurses (nurse_id, department_id, certification_level, shift_preference, license_number)
VALUES (8, 2, 'Aukštasis', 'NIGHT', 'LT-NRS-008901');

INSERT INTO nurses (nurse_id, department_id, certification_level, shift_preference, license_number)
VALUES (9, 3, 'Profesinis bakalauras', 'ROTATING', 'LT-NRS-009012');

INSERT INTO nurses (nurse_id, department_id, certification_level, shift_preference, license_number)
VALUES (10, 4, 'Aukštasis', 'DAY', 'LT-NRS-010123');

COMMIT;

-- ============================================================================
-- 5. ROOMS (Palatai)
-- ============================================================================
-- Kardiologija
INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (1, 'A301', 'PRIVATE', 3, 'Y', 150);

INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (1, 'A302', 'SEMI_PRIVATE', 3, 'Y', 100);

INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (1, 'A303', 'ICU', 3, 'Y', 300);

-- Chirurgija
INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (2, 'A201', 'PRIVATE', 2, 'Y', 150);

INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (2, 'A202', 'SEMI_PRIVATE', 2, 'Y', 100);

INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (2, 'A203', 'OPERATING', 2, 'Y', 500);

-- Pediatrija
INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (3, 'B101', 'PRIVATE', 1, 'Y', 120);

INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (3, 'B102', 'SEMI_PRIVATE', 1, 'Y', 80);

-- Onkologija
INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (4, 'C401', 'PRIVATE', 4, 'Y', 200);

INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (4, 'C402', 'SEMI_PRIVATE', 4, 'Y', 150);

-- Neurologija
INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (5, 'A401', 'PRIVATE', 4, 'Y', 160);

INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (5, 'A402', 'ICU', 4, 'Y', 300);

-- Ortopedija
INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (6, 'B201', 'PRIVATE', 2, 'Y', 140);

INSERT INTO rooms (department_id, room_number, room_type, floor_number, is_available, daily_rate)
VALUES (6, 'B202', 'SEMI_PRIVATE', 2, 'Y', 90);

COMMIT;

-- ============================================================================
-- 6. BEDS (Lovos)
-- ============================================================================
-- A301 - Private (1 lova)
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (1, '1', 'AVAILABLE');

-- A302 - Semi-Private (2 lovos)
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (2, '1', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (2, '2', 'AVAILABLE');

-- A303 - ICU (4 lovos)
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (3, '1', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (3, '2', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (3, '3', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (3, '4', 'AVAILABLE');

-- A201 - Private
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (4, '1', 'AVAILABLE');

-- A202 - Semi-Private
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (5, '1', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (5, '2', 'AVAILABLE');

-- A203 - Operating (1 operacinė stalas)
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (6, '1', 'AVAILABLE');

-- B101 - Private
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (7, '1', 'AVAILABLE');

-- B102 - Semi-Private
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (8, '1', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (8, '2', 'AVAILABLE');

-- C401 - Private
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (9, '1', 'AVAILABLE');

-- C402 - Semi-Private
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (10, '1', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (10, '2', 'AVAILABLE');

-- A401 - Private
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (11, '1', 'AVAILABLE');

-- A402 - ICU
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (12, '1', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (12, '2', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (12, '3', 'AVAILABLE');

-- B201 - Private
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (13, '1', 'AVAILABLE');

-- B202 - Semi-Private
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (14, '1', 'AVAILABLE');
INSERT INTO beds (room_id, bed_number, bed_status) VALUES (14, '2', 'AVAILABLE');

COMMIT;

-- ============================================================================
-- 7. PATIENTS (Pacientai)
-- ============================================================================
INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Petras', 'Sabonis', DATE '1965-04-12', 'M', 'A+', 'petras.sabonis@gmail.com', '+370 601 11111', 'Ona Sabonienė', '+370 601 11112', 'Ozo g. 25', 'Vilnius', 'LT-08200', 'LT-INS-12345678', 'Y');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Ona', 'Jakutienė', DATE '1978-08-20', 'F', 'B+', 'ona.jakutiene@yahoo.com', '+370 602 22222', 'Mindaugas Jakutis', '+370 602 22223', 'Žalgirio g. 112', 'Vilnius', 'LT-08217', 'LT-INS-23456789', 'Y');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Marija', 'Urbanavičiūtė', DATE '2010-06-15', 'F', 'O+', 'jurga.urbanaviciene@gmail.com', '+370 603 33333', 'Jurga Urbanavičienė', '+370 603 33334', 'Taikos g. 45', 'Vilnius', 'LT-10210', 'LT-INS-34567890', 'Y');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Antanas', 'Grigas', DATE '1952-11-30', 'M', 'AB+', 'antanas.grigas@inbox.lt', '+370 604 44444', 'Aldona Grigienė', '+370 604 44445', 'Laisvės pr. 78', 'Vilnius', 'LT-04215', 'LT-INS-45678901', 'Y');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Jurgita', 'Valančiūnaitė', DATE '1992-03-08', 'F', 'A-', 'jurgita.val@gmail.com', '+370 605 55555', 'Darius Valančius', '+370 605 55556', 'Viršuliškių g. 23', 'Vilnius', 'LT-05124', 'LT-INS-56789012', 'Y');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Darius', 'Šimkus', DATE '1985-07-25', 'M', 'O-', 'darius.simkus@hotmail.com', '+370 606 66666', 'Rasa Šimkienė', '+370 606 66667', 'Lazdynų g. 67', 'Vilnius', 'LT-04200', 'LT-INS-67890123', 'Y');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Gintarė', 'Rimkutė', DATE '2015-12-10', 'F', 'B+', 'laima.rimkiene@gmail.com', '+370 607 77777', 'Laima Rimkienė', '+370 607 77778', 'Justiniškių g. 89', 'Vilnius', 'LT-05230', 'LT-INS-78901234', 'Y');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Vytautas', 'Kazlauskas', DATE '1970-09-18', 'M', 'A+', 'vytautas.k@gmail.com', '+370 608 88888', 'Irena Kazlauskienė', '+370 608 88889', 'Šeškinės g. 34', 'Vilnius', 'LT-07156', 'LT-INS-89012345', 'Y');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Eglė', 'Butkutė', DATE '1988-02-14', 'F', 'O+', 'egle.butkute@yahoo.com', '+370 609 99999', 'Jonas Butkus', '+370 609 99990', 'Fabijoniškių g. 56', 'Vilnius', 'LT-07121', 'LT-INS-90123456', 'Y');

INSERT INTO patients (first_name, last_name, date_of_birth, gender, blood_type, email, phone_number, emergency_contact_name, emergency_contact_phone, address, city, postal_code, insurance_number, is_active)
VALUES ('Aurimas', 'Lukošius', DATE '1995-05-22', 'M', 'AB-', 'aurimas.lukosius@gmail.com', '+370 610 10101', 'Monika Lukošiūtė', '+370 610 10102', 'Pašilaičių g. 12', 'Vilnius', 'LT-05223', 'LT-INS-01234567', 'Y');

COMMIT;

-- ============================================================================
-- 8. DIAGNOSES (Diagnozių katalogas - ICD-10 tipo)
-- ============================================================================
INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('I21.0', 'Ūminis transmurinis priekinio miokardo infarktas', 'Širdies ligos', 'CRITICAL', 'Ūminis širdies priepuolis su pilno storio miokardo pažeidimu', 'Y');

INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('I10', 'Esminė (pirminė) hipertenzija', 'Širdies ligos', 'MODERATE', 'Aukštas kraujospūdis be nustatytos priežasties', 'Y');

INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('E11', 'Cukrinis diabetas II tipo', 'Endokrininės ligos', 'MODERATE', 'Metabolinė liga su padidėjusiu gliukozės kiekiu kraujyje', 'Y');

INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('J18', 'Plaučių uždegimas', 'Kvėpavimo takų ligos', 'SEVERE', 'Plaučių infekcija', 'Y');

INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('S72.0', 'Šlaunikaulio kaklelio lūžis', 'Traumos', 'SEVERE', 'Šlaunikaulio viršutinės dalies lūžis', 'Y');

INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('C50', 'Krūties vėžys', 'Onkologinės ligos', 'CRITICAL', 'Piktybinis krūties navikas', 'Y');

INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('G40', 'Epilepsija', 'Nervų sistemos ligos', 'MODERATE', 'Lėtinis neurologinis sutrikimas su priepuoliais', 'Y');

INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('K35', 'Ūminis apendicitas', 'Virškinimo sistemos ligos', 'SEVERE', 'Aklo žarnos ataugo uždegimas', 'Y');

INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('J03', 'Ūminis tonzilitas', 'Kvėpavimo takų ligos', 'MILD', 'Gomurių uždegimas', 'Y');

INSERT INTO diagnoses (diagnosis_code, diagnosis_name, category, severity_level, description, is_active)
VALUES ('M54.5', 'Apatinės nugaros dalies skausmas', 'Raumenų-skeleto ligos', 'MILD', 'Juosmens srities skausmas', 'Y');

COMMIT;

-- ============================================================================
-- 9. MEDICATIONS (Vaistai)
-- ============================================================================
INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Aspirin Cardio', 'Acetilsalicilo rūgštis', 'Bayer', 'Antiagregantai', 8.50, 500, 100, 'TABLET', '100mg', 'N', 'Y');

INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Metformin', 'Metforminas', 'Teva', 'Antidiabetikai', 12.00, 350, 80, 'TABLET', '500mg', 'Y', 'Y');

INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Amoxicillin', 'Amoksicilinas', 'Sandoz', 'Antibiotikai', 15.50, 200, 50, 'CAPSULE', '500mg', 'Y', 'Y');

INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Paracetamol', 'Paracetamolis', 'Eurovaistinė', 'Analgetikai', 5.00, 800, 150, 'TABLET', '500mg', 'N', 'Y');

INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Ibuprofen', 'Ibuprofenas', 'Actavis', 'Analgetikai', 7.20, 600, 120, 'TABLET', '400mg', 'N', 'Y');

INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Enalapril', 'Enalaprilis', 'Gedeon Richter', 'Antihipertenziniai', 10.50, 300, 70, 'TABLET', '10mg', 'Y', 'Y');

INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Omeprazole', 'Omeprazolis', 'Krka', 'Virškinimo sistemos vaistai', 14.00, 250, 60, 'CAPSULE', '20mg', 'Y', 'Y');

INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Insulin Glargine', 'Insulino glarginai', 'Sanofi', 'Insulinai', 85.00, 50, 20, 'INJECTION', '100 vnt/ml', 'Y', 'Y');

INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Diazepam', 'Diazepamas', 'Roche', 'Trankvilizatoriai', 18.50, 80, 30, 'TABLET', '5mg', 'Y', 'Y');

INSERT INTO medications (medication_name, generic_name, manufacturer, category, unit_price, stock_quantity, minimum_stock_level, dosage_form, strength, requires_prescription, is_available)
VALUES ('Cough Syrup', 'Dekstrometorfanas', 'Reckitt Benckiser', 'Kvėpavimo takų vaistai', 9.50, 150, 40, 'SYRUP', '100ml', 'N', 'Y');

COMMIT;

-- ============================================================================
-- 10. APPOINTMENTS (Vizitai)
-- ============================================================================
-- Šiandienos vizitai
INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, duration_minutes, appointment_type, status, notes)
VALUES (1, 1, TRUNC(SYSDATE), '09:00', 30, 'CHECKUP', 'CONFIRMED', 'Kontrolinis širdies patikrinimas po miokardo infarkto');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, duration_minutes, appointment_type, status, notes)
VALUES (2, 3, TRUNC(SYSDATE), '10:30', 45, 'CONSULTATION', 'SCHEDULED', 'Konsultacija dėl vaiko sveikatos');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, duration_minutes, appointment_type, status, notes)
VALUES (5, 2, TRUNC(SYSDATE), '14:00', 60, 'FOLLOWUP', 'CONFIRMED', 'Pooperacinis patikrinimas');

-- Rytojaus vizitai
INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, duration_minutes, appointment_type, status, notes)
VALUES (4, 5, TRUNC(SYSDATE) + 1, '11:00', 30, 'CONSULTATION', 'SCHEDULED', 'Neurologinė konsultacija dėl galvos skausmų');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, duration_minutes, appointment_type, status, notes)
VALUES (6, 6, TRUNC(SYSDATE) + 1, '15:30', 45, 'CHECKUP', 'SCHEDULED', 'Kelio sąnario patikrinimas');

-- Praeities vizitai
INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, duration_minutes, appointment_type, status, notes)
VALUES (1, 1, TRUNC(SYSDATE) - 30, '09:30', 45, 'EMERGENCY', 'COMPLETED', 'Skubus priėmimas dėl krūtinės skausmo');

INSERT INTO appointments (patient_id, doctor_id, appointment_date, appointment_time, duration_minutes, appointment_type, status, notes)
VALUES (8, 2, TRUNC(SYSDATE) - 15, '13:00', 30, 'CONSULTATION', 'COMPLETED', 'Konsultacija prieš operaciją');

COMMIT;

-- ============================================================================
-- 11. ADMISSIONS (Priėmimai)
-- ============================================================================
-- Aktyvūs priėmimai
INSERT INTO admissions (patient_id, bed_id, admitting_doctor_id, admission_date, discharge_date, admission_type, admission_reason, status)
VALUES (1, 1, 1, TRUNC(SYSDATE) - 3, NULL, 'EMERGENCY', 'Ūminis miokardo infarktas, reikia stebėjimo intensyvios terapijos skyriuje', 'ADMITTED');

INSERT INTO admissions (patient_id, bed_id, admitting_doctor_id, admission_date, discharge_date, admission_type, admission_reason, status)
VALUES (4, 11, 5, TRUNC(SYSDATE) - 2, NULL, 'PLANNED', 'Planuotas neurologinis stebėjimas dėl epilepsijos priepuolių', 'ADMITTED');

INSERT INTO admissions (patient_id, bed_id, admitting_doctor_id, admission_date, discharge_date, admission_type, admission_reason, status)
VALUES (8, 4, 2, TRUNC(SYSDATE) - 1, NULL, 'PLANNED', 'Planuota apendicito operacija', 'ADMITTED');

-- Išrašyti pacientai
INSERT INTO admissions (patient_id, bed_id, admitting_doctor_id, admission_date, discharge_date, admission_type, admission_reason, discharge_notes, status)
VALUES (2, 7, 3, TRUNC(SYSDATE) - 10, TRUNC(SYSDATE) - 5, 'EMERGENCY', 'Sunkus plaučių uždegimas', 'Pacientė pasveiko, gali tęsti gydymą ambulatoriškai', 'DISCHARGED');

INSERT INTO admissions (patient_id, bed_id, admitting_doctor_id, admission_date, discharge_date, admission_type, admission_reason, discharge_notes, status)
VALUES (6, 13, 6, TRUNC(SYSDATE) - 20, TRUNC(SYSDATE) - 12, 'EMERGENCY', 'Šlaunikaulio kaklelio lūžis po kritimo', 'Po sėkmingos operacijos ir reabilitacijos išrašytas', 'DISCHARGED');

COMMIT;

-- ============================================================================
-- 12. PATIENT_DIAGNOSES (Pacientų diagnozės)
-- ============================================================================
INSERT INTO patient_diagnoses (patient_id, diagnosis_id, doctor_id, diagnosis_date, notes, is_primary, status)
VALUES (1, 1, 1, TRUNC(SYSDATE) - 30, 'Ūminis miokardo infarktas su ST segmento pakilimu', 'Y', 'CHRONIC');

INSERT INTO patient_diagnoses (patient_id, diagnosis_id, doctor_id, diagnosis_date, notes, is_primary, status)
VALUES (1, 2, 1, TRUNC(SYSDATE) - 100, 'Esminė hipertenzija, kontroliuojama vaistais', 'N', 'CHRONIC');

INSERT INTO patient_diagnoses (patient_id, diagnosis_id, doctor_id, diagnosis_date, notes, is_primary, status)
VALUES (2, 4, 3, TRUNC(SYSDATE) - 10, 'Bakterinis plaučių uždegimas', 'Y', 'RESOLVED');

INSERT INTO patient_diagnoses (patient_id, diagnosis_id, doctor_id, diagnosis_date, notes, is_primary, status)
VALUES (4, 3, 5, TRUNC(SYSDATE) - 365, 'Cukrinis diabetas II tipo, gydomas metforminu', 'Y', 'CHRONIC');

INSERT INTO patient_diagnoses (patient_id, diagnosis_id, doctor_id, diagnosis_date, notes, is_primary, status)
VALUES (4, 7, 5, TRUNC(SYSDATE) - 2, 'Epilepsija su generalizuotais priepuoliais', 'Y', 'ACTIVE');

INSERT INTO patient_diagnoses (patient_id, diagnosis_id, doctor_id, diagnosis_date, notes, is_primary, status)
VALUES (6, 5, 6, TRUNC(SYSDATE) - 20, 'Šlaunikaulio kaklelio lūžis po traumos', 'Y', 'RESOLVED');

INSERT INTO patient_diagnoses (patient_id, diagnosis_id, doctor_id, diagnosis_date, notes, is_primary, status)
VALUES (8, 8, 2, TRUNC(SYSDATE) - 1, 'Ūminis apendicitas su perforacija grėsme', 'Y', 'ACTIVE');

INSERT INTO patient_diagnoses (patient_id, diagnosis_id, doctor_id, diagnosis_date, notes, is_primary, status)
VALUES (5, 10, 6, TRUNC(SYSDATE) - 60, 'Lėtinis juosmens skausmas', 'Y', 'CHRONIC');

COMMIT;

-- ============================================================================
-- 13. PRESCRIPTIONS (Receptai)
-- ============================================================================
INSERT INTO prescriptions (patient_id, doctor_id, medication_id, prescription_date, dosage, frequency, duration_days, quantity, refills_allowed, instructions, status)
VALUES (1, 1, 1, TRUNC(SYSDATE) - 30, '100mg', '1 kartą per dieną', 90, 90, 2, 'Gerti rytais po pusryčių', 'ACTIVE');

INSERT INTO prescriptions (patient_id, doctor_id, medication_id, prescription_date, dosage, frequency, duration_days, quantity, refills_allowed, instructions, status)
VALUES (1, 1, 6, TRUNC(SYSDATE) - 30, '10mg', '1 kartą per dieną', 90, 90, 2, 'Gerti rytais', 'ACTIVE');

INSERT INTO prescriptions (patient_id, doctor_id, medication_id, prescription_date, dosage, frequency, duration_days, quantity, refills_allowed, instructions, status)
VALUES (4, 5, 2, TRUNC(SYSDATE) - 365, '500mg', '2 kartus per dieną', 90, 180, 3, 'Gerti su maistu rytais ir vakarais', 'ACTIVE');

INSERT INTO prescriptions (patient_id, doctor_id, medication_id, prescription_date, dosage, frequency, duration_days, quantity, refills_allowed, instructions, status)
VALUES (2, 3, 3, TRUNC(SYSDATE) - 10, '500mg', '3 kartus per dieną', 7, 21, 0, 'Gerti 8 val. intervalu', 'COMPLETED');

INSERT INTO prescriptions (patient_id, doctor_id, medication_id, prescription_date, dosage, frequency, duration_days, quantity, refills_allowed, instructions, status)
VALUES (8, 2, 3, TRUNC(SYSDATE) - 1, '500mg', '3 kartus per dieną', 10, 30, 0, 'Antibiotikų kursas po operacijos', 'ACTIVE');

INSERT INTO prescriptions (patient_id, doctor_id, medication_id, prescription_date, dosage, frequency, duration_days, quantity, refills_allowed, instructions, status)
VALUES (5, 6, 5, TRUNC(SYSDATE) - 60, '400mg', 'Pagal poreikį, ne daugiau 3 kartų per dieną', 30, 30, 1, 'Gerti skausmo metu', 'ACTIVE');

COMMIT;

-- ============================================================================
-- 14. LAB_TESTS (Laboratoriniai tyrimai)
-- ============================================================================
INSERT INTO lab_tests (patient_id, doctor_id, test_type, test_date, test_time, status, results, normal_range, lab_technician_name, cost, notes)
VALUES (1, 1, 'BLOOD', TRUNC(SYSDATE) - 3, '08:30', 'COMPLETED', 'Troponinas: 2.5 ng/ml (padidėjęs)', '< 0.04 ng/ml', 'Dr. Vilma Stakėnaitė', 45.00, 'Patvirtintas miokardo infarktas');

INSERT INTO lab_tests (patient_id, doctor_id, test_type, test_date, test_time, status, results, normal_range, lab_technician_name, cost, notes)
VALUES (1, 1, 'ECG', TRUNC(SYSDATE) - 3, '09:00', 'COMPLETED', 'ST segmento pakėlimas V2-V4 derivacijose', 'N/A', 'Kardiologijos sesuo', 30.00, 'EKG rodo ūminį priekinį infarktą');

INSERT INTO lab_tests (patient_id, doctor_id, test_type, test_date, test_time, status, results, normal_range, lab_technician_name, cost)
VALUES (2, 3, 'XRAY', TRUNC(SYSDATE) - 10, '10:15', 'COMPLETED', 'Dešiniojo plaučio apatinėje dalyje infiltratas', 'N/A', 'Radiologas V. Norkus', 60.00);

INSERT INTO lab_tests (patient_id, doctor_id, test_type, test_date, test_time, status, results, normal_range, lab_technician_name, cost)
VALUES (4, 5, 'BLOOD', TRUNC(SYSDATE) - 2, '07:45', 'COMPLETED', 'Gliukozė: 8.2 mmol/l (pakitusi)', '3.9-6.1 mmol/l', 'Dr. V. Stakėnaitė', 25.00);

INSERT INTO lab_tests (patient_id, doctor_id, test_type, test_date, test_time, status, results, normal_range, lab_technician_name, cost)
VALUES (4, 5, 'EEG', TRUNC(SYSDATE) - 2, '11:00', 'COMPLETED', 'Difuzinė lėtųjų bangų aktivacija epilepsinio židinio zonoje', 'N/A', 'Neurologijos technikė', 120.00);

INSERT INTO lab_tests (patient_id, doctor_id, test_type, test_date, test_time, status, results, normal_range, lab_technician_name, cost)
VALUES (6, 6, 'XRAY', TRUNC(SYSDATE) - 20, '14:30', 'COMPLETED', 'Šlaunikaulio kaklelio lūžis su nedideliu poslinkiu', 'N/A', 'Radiologas V. Norkus', 65.00);

INSERT INTO lab_tests (patient_id, doctor_id, test_type, test_date, test_time, status, results, normal_range, cost, notes)
VALUES (8, 2, 'ULTRASOUND', TRUNC(SYSDATE) - 1, '16:00', 'COMPLETED', 'Padidėjęs aklo žarnos ataugas, skysčio žymių pilvaplėvės ertmėje', 'N/A', 80.00, 'Būtina skubi operacija');

INSERT INTO lab_tests (patient_id, doctor_id, test_type, test_date, test_time, status, cost)
VALUES (5, 2, 'MRI', TRUNC(SYSDATE) + 2, '09:00', 'ORDERED', 350.00);

INSERT INTO lab_tests (patient_id, doctor_id, test_type, test_date, test_time, status, cost, notes)
VALUES (1, 1, 'BLOOD', TRUNC(SYSDATE), '07:00', 'IN_PROGRESS', 35.00, 'Kontrolinis kraujo tyrimas');

COMMIT;

-- ============================================================================
-- 15. BILLS (Sąskaitos)
-- ============================================================================
-- Sąskaitos už priėmimus
INSERT INTO bills (patient_id, admission_id, bill_date, due_date, total_amount, paid_amount, payment_status, payment_method, discount_percent, tax_amount, notes)
VALUES (1, 1, TRUNC(SYSDATE) - 3, TRUNC(SYSDATE) + 27, 1250.00, 0, 'UNPAID', NULL, 0, 50.00, 'Hospitalizacija kardiologijos skyriuje');

INSERT INTO bills (patient_id, admission_id, bill_date, due_date, total_amount, paid_amount, payment_status, payment_method, discount_percent, tax_amount, notes)
VALUES (4, 2, TRUNC(SYSDATE) - 2, TRUNC(SYSDATE) + 28, 850.00, 0, 'UNPAID', NULL, 0, 34.00, 'Neurologinio stebėjimo išlaidos');

INSERT INTO bills (patient_id, admission_id, bill_date, due_date, total_amount, paid_amount, payment_status, payment_method, discount_percent, tax_amount, notes)
VALUES (8, 3, TRUNC(SYSDATE) - 1, TRUNC(SYSDATE) + 29, 1800.00, 0, 'UNPAID', NULL, 0, 72.00, 'Apendicito operacija ir pooperacinė priežiūra');

INSERT INTO bills (patient_id, admission_id, bill_date, due_date, total_amount, paid_amount, payment_status, payment_method, payment_date, discount_percent, tax_amount, notes)
VALUES (2, 4, TRUNC(SYSDATE) - 5, TRUNC(SYSDATE) + 25, 920.00, 920.00, 'PAID', 'INSURANCE', TRUNC(SYSDATE) - 2, 10, 36.80, 'Plaučių uždegimo gydymas - apmokėta draudimo');

INSERT INTO bills (patient_id, admission_id, bill_date, due_date, total_amount, paid_amount, payment_status, payment_method, payment_date, discount_percent, tax_amount, notes)
VALUES (6, 5, TRUNC(SYSDATE) - 12, TRUNC(SYSDATE) + 18, 3500.00, 3500.00, 'PAID', 'CARD', TRUNC(SYSDATE) - 10, 0, 140.00, 'Šlaunikaulio operacija ir reabilitacija');

-- Sąskaitos už vizitus
INSERT INTO bills (patient_id, appointment_id, bill_date, due_date, total_amount, paid_amount, payment_status, payment_method, payment_date, discount_percent, tax_amount)
VALUES (1, 6, TRUNC(SYSDATE) - 30, TRUNC(SYSDATE), 80.00, 40.00, 'PARTIAL', 'CASH', TRUNC(SYSDATE) - 29, 0, 3.20);

INSERT INTO bills (patient_id, appointment_id, bill_date, due_date, total_amount, paid_amount, payment_status, payment_method, payment_date, discount_percent, tax_amount)
VALUES (8, 7, TRUNC(SYSDATE) - 15, TRUNC(SYSDATE) + 15, 100.00, 100.00, 'PAID', 'CARD', TRUNC(SYSDATE) - 14, 0, 4.00);

-- Vėluojanti sąskaita
INSERT INTO bills (patient_id, appointment_id, bill_date, due_date, total_amount, paid_amount, payment_status, discount_percent, tax_amount, notes)
VALUES (5, 3, TRUNC(SYSDATE) - 45, TRUNC(SYSDATE) - 15, 100.00, 0, 'OVERDUE', 0, 4.00, 'Vėluojama apmokėti jau 15 dienų');

COMMIT;

-- ============================================================================
-- PABAIGA: Visi pavyzdiniai duomenys įterpti
-- ============================================================================

-- Statistika
SELECT 'Įterpti duomenys:' AS info FROM dual
UNION ALL
SELECT '- Skyriai: ' || COUNT(*) FROM departments
UNION ALL
SELECT '- Darbuotojai: ' || COUNT(*) FROM employees
UNION ALL
SELECT '- Gydytojai: ' || COUNT(*) FROM doctors
UNION ALL
SELECT '- Seserys: ' || COUNT(*) FROM nurses
UNION ALL
SELECT '- Palatai: ' || COUNT(*) FROM rooms
UNION ALL
SELECT '- Lovos: ' || COUNT(*) FROM beds
UNION ALL
SELECT '- Pacientai: ' || COUNT(*) FROM patients
UNION ALL
SELECT '- Diagnozės: ' || COUNT(*) FROM diagnoses
UNION ALL
SELECT '- Vaistai: ' || COUNT(*) FROM medications
UNION ALL
SELECT '- Vizitai: ' || COUNT(*) FROM appointments
UNION ALL
SELECT '- Priėmimai: ' || COUNT(*) FROM admissions
UNION ALL
SELECT '- Pacientų diagnozės: ' || COUNT(*) FROM patient_diagnoses
UNION ALL
SELECT '- Receptai: ' || COUNT(*) FROM prescriptions
UNION ALL
SELECT '- Lab testai: ' || COUNT(*) FROM lab_tests
UNION ALL
SELECT '- Sąskaitos: ' || COUNT(*) FROM bills;

COMMIT;
