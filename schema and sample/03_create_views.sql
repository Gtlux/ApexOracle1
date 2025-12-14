-- ============================================================================
-- LIGONINĖS VALDYMO SISTEMA - VIEWS
-- Oracle APEX 22.1.0
-- Versija: 1.0
-- Data: 2025-12-13
-- ============================================================================
-- Šis scriptas sukuria:
-- - Views APEX Interactive Reports
-- - Materialized Views statistikai
-- - Complex queries upaprastinimui
-- ============================================================================

-- ============================================================================
-- 1. PACIENTŲ VIEWS
-- ============================================================================

-- Pilna paciento informacija su statistika
CREATE OR REPLACE VIEW v_patients_full AS
SELECT
    p.patient_id,
    p.first_name,
    p.last_name,
    p.first_name || ' ' || p.last_name AS full_name,
    p.date_of_birth,
    TRUNC((SYSDATE - p.date_of_birth) / 365.25) AS age,
    p.gender,
    CASE p.gender
        WHEN 'M' THEN 'Vyras'
        WHEN 'F' THEN 'Moteris'
        ELSE 'Kita'
    END AS gender_display,
    p.blood_type,
    p.email,
    p.phone_number,
    p.emergency_contact_name,
    p.emergency_contact_phone,
    p.address,
    p.city,
    p.postal_code,
    p.insurance_number,
    p.registration_date,
    p.is_active,
    -- Statistika
    (SELECT COUNT(*) FROM appointments WHERE patient_id = p.patient_id) AS total_appointments,
    (SELECT COUNT(*) FROM admissions WHERE patient_id = p.patient_id) AS total_admissions,
    (SELECT COUNT(*) FROM bills WHERE patient_id = p.patient_id AND payment_status != 'PAID') AS unpaid_bills_count,
    (SELECT SUM(balance) FROM bills WHERE patient_id = p.patient_id AND payment_status != 'PAID') AS outstanding_balance,
    -- Paskutinis vizitas
    (SELECT MAX(appointment_date) FROM appointments WHERE patient_id = p.patient_id) AS last_appointment_date,
    -- Ar šiuo metu hospitalizuotas
    CASE WHEN EXISTS (
        SELECT 1 FROM admissions
        WHERE patient_id = p.patient_id AND status = 'ADMITTED'
    ) THEN 'Y' ELSE 'N' END AS currently_admitted
FROM patients p;


-- ============================================================================
-- 2. GYDYTOJŲ VIEWS
-- ============================================================================

-- Gydytojų sąrašas su skyriaus informacija
CREATE OR REPLACE VIEW v_doctors_full AS
SELECT
    d.doctor_id,
    e.first_name,
    e.last_name,
    e.first_name || ' ' || e.last_name AS full_name,
    e.email,
    e.phone_number,
    e.employment_status,
    d.specialization,
    d.license_number,
    d.consultation_fee,
    d.years_of_experience,
    d.education,
    d.available_for_emergency,
    -- Skyriaus info
    dept.department_id,
    dept.department_name,
    dept.building,
    dept.floor_number,
    -- Statistika
    (SELECT COUNT(*) FROM appointments WHERE doctor_id = d.doctor_id) AS total_appointments,
    (SELECT COUNT(*) FROM appointments
     WHERE doctor_id = d.doctor_id
     AND appointment_date = TRUNC(SYSDATE)
     AND status IN ('SCHEDULED', 'CONFIRMED')) AS today_appointments,
    (SELECT COUNT(*) FROM patient_diagnoses WHERE doctor_id = d.doctor_id) AS total_diagnoses,
    (SELECT SUM(consultation_fee)
     FROM appointments a
     WHERE a.doctor_id = d.doctor_id
     AND a.status = 'COMPLETED') AS total_revenue
FROM doctors d
JOIN employees e ON d.doctor_id = e.employee_id
JOIN departments dept ON d.department_id = dept.department_id;


-- ============================================================================
-- 3. VIZITŲ (APPOINTMENTS) VIEWS
-- ============================================================================

-- Vizitų kalendoriui view
CREATE OR REPLACE VIEW v_appointments_calendar AS
SELECT
    a.appointment_id,
    a.appointment_date,
    a.appointment_time,
    a.appointment_date + INTERVAL '0' DAY + TO_DSINTERVAL('00:' || a.appointment_time || ':00') AS appointment_datetime,
    a.duration_minutes,
    a.appointment_type,
    a.status,
    a.notes,
    -- Paciento info
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.phone_number AS patient_phone,
    -- Gydytojo info
    d.doctor_id,
    e.first_name || ' ' || e.last_name AS doctor_name,
    doc.specialization,
    doc.consultation_fee,
    -- Skyriaus info
    dept.department_name,
    dept.building,
    dept.floor_number,
    -- Spalvinis kodavimas pagal statusą (APEX calendar)
    CASE a.status
        WHEN 'SCHEDULED' THEN '#3498db'  -- mėlyna
        WHEN 'CONFIRMED' THEN '#2ecc71'  -- žalia
        WHEN 'COMPLETED' THEN '#95a5a6'  -- pilka
        WHEN 'CANCELLED' THEN '#e74c3c'  -- raudona
        WHEN 'NO_SHOW' THEN '#e67e22'    -- oranžinė
    END AS status_color,
    -- Display text
    a.appointment_time || ' - ' || p.first_name || ' ' || p.last_name AS display_text
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN employees e ON d.doctor_id = e.employee_id
JOIN doctors doc ON d.doctor_id = doc.doctor_id
JOIN departments dept ON doc.department_id = dept.department_id;


-- ============================================================================
-- 4. PRIĖMIMŲ (ADMISSIONS) VIEWS
-- ============================================================================

-- Aktualūs priėmimai su visa informacija
CREATE OR REPLACE VIEW v_admissions_current AS
SELECT
    a.admission_id,
    a.admission_date,
    a.discharge_date,
    TRUNC(NVL(a.discharge_date, SYSDATE) - a.admission_date) AS length_of_stay,
    a.admission_type,
    a.admission_reason,
    a.status,
    -- Paciento info
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.date_of_birth,
    TRUNC((SYSDATE - p.date_of_birth) / 365.25) AS patient_age,
    p.gender,
    p.blood_type,
    p.phone_number AS patient_phone,
    -- Lovos info
    b.bed_id,
    b.bed_number,
    b.bed_status,
    -- Palatos info
    r.room_id,
    r.room_number,
    r.room_type,
    r.floor_number,
    r.daily_rate,
    -- Skyriaus info
    dept.department_id,
    dept.department_name,
    dept.building,
    -- Gydytojo info
    d.doctor_id,
    e.first_name || ' ' || e.last_name AS doctor_name,
    doc.specialization,
    -- Sąskaitos info
    (SELECT SUM(total_amount) FROM bills WHERE admission_id = a.admission_id) AS total_billed,
    (SELECT SUM(balance) FROM bills WHERE admission_id = a.admission_id) AS balance_due
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
JOIN beds b ON a.bed_id = b.bed_id
JOIN rooms r ON b.room_id = r.room_id
JOIN departments dept ON r.department_id = dept.department_id
JOIN doctors d ON a.admitting_doctor_id = d.doctor_id
JOIN employees e ON d.doctor_id = e.employee_id
JOIN doctors doc ON d.doctor_id = doc.doctor_id
WHERE a.status = 'ADMITTED';


-- ============================================================================
-- 5. SĄSKAITŲ (BILLS) VIEWS
-- ============================================================================

-- Sąskaitos su visa informacija
CREATE OR REPLACE VIEW v_bills_detailed AS
SELECT
    b.bill_id,
    b.bill_date,
    b.due_date,
    b.total_amount,
    b.paid_amount,
    b.balance,
    b.payment_status,
    b.payment_method,
    b.payment_date,
    b.discount_percent,
    b.tax_amount,
    -- Status display
    CASE b.payment_status
        WHEN 'UNPAID' THEN 'Neapmokėta'
        WHEN 'PARTIAL' THEN 'Dalinai apmokėta'
        WHEN 'PAID' THEN 'Apmokėta'
        WHEN 'OVERDUE' THEN 'Vėluojama'
    END AS payment_status_lt,
    -- Spalvinis kodavimas
    CASE b.payment_status
        WHEN 'PAID' THEN '#2ecc71'
        WHEN 'PARTIAL' THEN '#f39c12'
        WHEN 'UNPAID' THEN '#95a5a6'
        WHEN 'OVERDUE' THEN '#e74c3c'
    END AS status_color,
    -- Ar vėluojama
    CASE WHEN b.due_date < SYSDATE AND b.payment_status != 'PAID'
         THEN 'Y' ELSE 'N' END AS is_overdue,
    CASE WHEN b.due_date < SYSDATE AND b.payment_status != 'PAID'
         THEN TRUNC(SYSDATE - b.due_date) ELSE 0 END AS days_overdue,
    -- Paciento info
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.phone_number AS patient_phone,
    p.email AS patient_email,
    p.insurance_number,
    -- Priėmimo/Vizito info
    b.admission_id,
    b.appointment_id,
    CASE
        WHEN b.admission_id IS NOT NULL THEN 'Hospitalizacija'
        WHEN b.appointment_id IS NOT NULL THEN 'Vizitas'
        ELSE 'Kita'
    END AS bill_source
FROM bills b
JOIN patients p ON b.patient_id = p.patient_id;


-- Nepamokėtos sąskaitos
CREATE OR REPLACE VIEW v_bills_unpaid AS
SELECT * FROM v_bills_detailed
WHERE payment_status IN ('UNPAID', 'PARTIAL', 'OVERDUE')
ORDER BY due_date;


-- ============================================================================
-- 6. LOVŲ UŽIMTUMO VIEW
-- ============================================================================

-- Lovos su visa informacija ir užimtumu
CREATE OR REPLACE VIEW v_beds_occupancy AS
SELECT
    b.bed_id,
    b.bed_number,
    b.bed_status,
    b.last_maintenance_date,
    -- Status display
    CASE b.bed_status
        WHEN 'AVAILABLE' THEN 'Laisva'
        WHEN 'OCCUPIED' THEN 'Užimta'
        WHEN 'MAINTENANCE' THEN 'Remontuojama'
        WHEN 'RESERVED' THEN 'Rezervuota'
    END AS bed_status_lt,
    -- Spalvinis kodavimas
    CASE b.bed_status
        WHEN 'AVAILABLE' THEN '#2ecc71'
        WHEN 'OCCUPIED' THEN '#e74c3c'
        WHEN 'MAINTENANCE' THEN '#f39c12'
        WHEN 'RESERVED' THEN '#3498db'
    END AS status_color,
    -- Palatos info
    r.room_id,
    r.room_number,
    r.room_type,
    r.floor_number,
    r.daily_rate,
    -- Skyriaus info
    dept.department_id,
    dept.department_name,
    dept.building,
    -- Paciento info (jei užimta)
    a.admission_id,
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.gender,
    TRUNC((SYSDATE - p.date_of_birth) / 365.25) AS patient_age,
    a.admission_date,
    TRUNC(SYSDATE - a.admission_date) AS days_in_hospital
FROM beds b
JOIN rooms r ON b.room_id = r.room_id
JOIN departments dept ON r.department_id = dept.department_id
LEFT JOIN admissions a ON b.bed_id = a.bed_id AND a.status = 'ADMITTED'
LEFT JOIN patients p ON a.patient_id = p.patient_id;


-- ============================================================================
-- 7. DIAGNOSTIKOS VIEW
-- ============================================================================

-- Pacientų diagnozės su detalia informacija
CREATE OR REPLACE VIEW v_patient_diagnoses_full AS
SELECT
    pd.patient_diagnosis_id,
    pd.diagnosis_date,
    pd.notes,
    pd.is_primary,
    pd.status,
    -- Status display
    CASE pd.status
        WHEN 'ACTIVE' THEN 'Aktyvi'
        WHEN 'RESOLVED' THEN 'Išspręsta'
        WHEN 'CHRONIC' THEN 'Lėtinė'
    END AS status_lt,
    -- Paciento info
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    -- Diagnozės info
    d.diagnosis_id,
    d.diagnosis_code,
    d.diagnosis_name,
    d.category,
    d.severity_level,
    d.description,
    -- Gydytojo info
    doc.doctor_id,
    e.first_name || ' ' || e.last_name AS doctor_name,
    dt.specialization
FROM patient_diagnoses pd
JOIN patients p ON pd.patient_id = p.patient_id
JOIN diagnoses d ON pd.diagnosis_id = d.diagnosis_id
JOIN doctors doc ON pd.doctor_id = doc.doctor_id
JOIN employees e ON doc.doctor_id = e.employee_id
JOIN doctors dt ON doc.doctor_id = dt.doctor_id;


-- ============================================================================
-- 8. RECEPTŲ VIEW
-- ============================================================================

-- Receptai su visa informacija
CREATE OR REPLACE VIEW v_prescriptions_full AS
SELECT
    pr.prescription_id,
    pr.prescription_date,
    pr.dosage,
    pr.frequency,
    pr.duration_days,
    pr.quantity,
    pr.refills_allowed,
    pr.instructions,
    pr.status,
    -- Status display
    CASE pr.status
        WHEN 'ACTIVE' THEN 'Aktyvus'
        WHEN 'COMPLETED' THEN 'Užbaigtas'
        WHEN 'CANCELLED' THEN 'Atšauktas'
    END AS status_lt,
    -- Galiojimo pabaiga
    pr.prescription_date + pr.duration_days AS expiry_date,
    CASE WHEN pr.prescription_date + pr.duration_days < SYSDATE
         THEN 'Y' ELSE 'N' END AS is_expired,
    -- Paciento info
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.phone_number AS patient_phone,
    -- Vaisto info
    m.medication_id,
    m.medication_name,
    m.generic_name,
    m.dosage_form,
    m.strength,
    m.unit_price,
    m.stock_quantity,
    -- Bendra kaina
    pr.quantity * m.unit_price AS total_cost,
    -- Gydytojo info
    d.doctor_id,
    e.first_name || ' ' || e.last_name AS doctor_name,
    dt.specialization,
    dt.license_number
FROM prescriptions pr
JOIN patients p ON pr.patient_id = p.patient_id
JOIN medications m ON pr.medication_id = m.medication_id
JOIN doctors d ON pr.doctor_id = d.doctor_id
JOIN employees e ON d.doctor_id = e.employee_id
JOIN doctors dt ON d.doctor_id = dt.doctor_id;


-- ============================================================================
-- 9. LABORATORINIŲ TYRIMŲ VIEW
-- ============================================================================

-- Lab testai su visa informacija
CREATE OR REPLACE VIEW v_lab_tests_full AS
SELECT
    lt.lab_test_id,
    lt.test_type,
    lt.test_date,
    lt.test_time,
    lt.status,
    -- Status display
    CASE lt.status
        WHEN 'ORDERED' THEN 'Užsakytas'
        WHEN 'IN_PROGRESS' THEN 'Vykdomas'
        WHEN 'COMPLETED' THEN 'Užbaigtas'
        WHEN 'CANCELLED' THEN 'Atšauktas'
    END AS status_lt,
    -- Spalvinis kodavimas
    CASE lt.status
        WHEN 'ORDERED' THEN '#3498db'
        WHEN 'IN_PROGRESS' THEN '#f39c12'
        WHEN 'COMPLETED' THEN '#2ecc71'
        WHEN 'CANCELLED' THEN '#95a5a6'
    END AS status_color,
    lt.results,
    lt.normal_range,
    lt.lab_technician_name,
    lt.cost,
    lt.notes,
    -- Paciento info
    p.patient_id,
    p.first_name || ' ' || p.last_name AS patient_name,
    p.date_of_birth,
    TRUNC((SYSDATE - p.date_of_birth) / 365.25) AS patient_age,
    p.gender,
    -- Gydytojo info
    d.doctor_id,
    e.first_name || ' ' || e.last_name AS doctor_name,
    dt.specialization
FROM lab_tests lt
JOIN patients p ON lt.patient_id = p.patient_id
JOIN doctors d ON lt.doctor_id = d.doctor_id
JOIN employees e ON d.doctor_id = e.employee_id
JOIN doctors dt ON d.doctor_id = dt.doctor_id;


-- ============================================================================
-- 10. DASHBOARD STATISTICS VIEWS
-- ============================================================================

-- Bendroji statistika dashboard'ui
CREATE OR REPLACE VIEW v_dashboard_stats AS
SELECT
    (SELECT COUNT(*) FROM patients WHERE is_active = 'Y') AS total_active_patients,
    (SELECT COUNT(*) FROM admissions WHERE status = 'ADMITTED') AS current_admissions,
    (SELECT COUNT(*) FROM appointments
     WHERE appointment_date = TRUNC(SYSDATE)
     AND status IN ('SCHEDULED', 'CONFIRMED')) AS today_appointments,
    (SELECT COUNT(*) FROM beds WHERE bed_status = 'AVAILABLE') AS available_beds,
    (SELECT COUNT(*) FROM beds WHERE bed_status = 'OCCUPIED') AS occupied_beds,
    (SELECT COUNT(*) FROM bills WHERE payment_status IN ('UNPAID', 'OVERDUE')) AS unpaid_bills,
    (SELECT SUM(balance) FROM bills WHERE payment_status != 'PAID') AS total_outstanding,
    (SELECT SUM(paid_amount) FROM bills WHERE TRUNC(payment_date) = TRUNC(SYSDATE)) AS today_revenue,
    (SELECT COUNT(*) FROM medications WHERE stock_quantity <= minimum_stock_level) AS low_stock_meds,
    (SELECT COUNT(*) FROM doctors d JOIN employees e ON d.doctor_id = e.employee_id
     WHERE e.employment_status = 'ACTIVE') AS active_doctors,
    (SELECT COUNT(*) FROM nurses n JOIN employees e ON n.nurse_id = e.employee_id
     WHERE e.employment_status = 'ACTIVE') AS active_nurses
FROM dual;


-- Skyriaus statistika
CREATE OR REPLACE VIEW v_department_stats AS
SELECT
    d.department_id,
    d.department_name,
    d.building,
    d.budget,
    -- Personalas
    (SELECT COUNT(*) FROM doctors WHERE department_id = d.department_id) AS doctor_count,
    (SELECT COUNT(*) FROM nurses WHERE department_id = d.department_id) AS nurse_count,
    -- Palatai ir lovos
    (SELECT COUNT(*) FROM rooms WHERE department_id = d.department_id) AS room_count,
    (SELECT COUNT(*) FROM beds b
     JOIN rooms r ON b.room_id = r.room_id
     WHERE r.department_id = d.department_id) AS bed_count,
    (SELECT COUNT(*) FROM beds b
     JOIN rooms r ON b.room_id = r.room_id
     WHERE r.department_id = d.department_id
     AND b.bed_status = 'OCCUPIED') AS occupied_bed_count,
    -- Pacientai
    (SELECT COUNT(*) FROM admissions a
     JOIN beds b ON a.bed_id = b.bed_id
     JOIN rooms r ON b.room_id = r.room_id
     WHERE r.department_id = d.department_id
     AND a.status = 'ADMITTED') AS current_patients,
    -- Pajamos
    (SELECT SUM(bl.paid_amount)
     FROM bills bl
     JOIN admissions adm ON bl.admission_id = adm.admission_id
     JOIN beds bd ON adm.bed_id = bd.bed_id
     JOIN rooms rm ON bd.room_id = rm.room_id
     WHERE rm.department_id = d.department_id
     AND TRUNC(bl.payment_date) >= TRUNC(ADD_MONTHS(SYSDATE, -1))) AS revenue_last_month
FROM departments d
WHERE d.is_active = 'Y';


-- ============================================================================
-- PABAIGA: Visi views sėkmingai sukurti
-- ============================================================================

SELECT 'Sukurta ' || COUNT(*) || ' views' AS info
  FROM user_views
 WHERE view_name LIKE 'V_%';

COMMIT;
