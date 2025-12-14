-- ============================================================================
-- LIGONINĖS VALDYMO SISTEMA - TRIGGERS & BUSINESS LOGIC
-- Oracle APEX 22.1.0
-- Versija: 1.0
-- Data: 2025-12-13
-- ============================================================================
-- Šis scriptas sukuria:
-- - Automatinius timestampų atnaujinimo triggerius
-- - Verslo logikos triggerius
-- - Auditui ir vientisumui užtikrinti triggerius
-- ============================================================================

-- ============================================================================
-- 1. TIMESTAMP TRIGGERS - automatinis modified_date atnaujinimas
-- ============================================================================

-- EMPLOYEES
CREATE OR REPLACE TRIGGER trg_emp_modified
BEFORE UPDATE ON employees
FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
END;
/

-- PATIENTS
CREATE OR REPLACE TRIGGER trg_pat_modified
BEFORE UPDATE ON patients
FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
END;
/

-- APPOINTMENTS
CREATE OR REPLACE TRIGGER trg_appt_modified
BEFORE UPDATE ON appointments
FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
END;
/

-- ADMISSIONS
CREATE OR REPLACE TRIGGER trg_adm_modified
BEFORE UPDATE ON admissions
FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
END;
/

-- MEDICATIONS
CREATE OR REPLACE TRIGGER trg_med_modified
BEFORE UPDATE ON medications
FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
END;
/

-- PRESCRIPTIONS
CREATE OR REPLACE TRIGGER trg_presc_modified
BEFORE UPDATE ON prescriptions
FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
END;
/

-- LAB_TESTS
CREATE OR REPLACE TRIGGER trg_lab_modified
BEFORE UPDATE ON lab_tests
FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
END;
/

-- BILLS
CREATE OR REPLACE TRIGGER trg_bill_modified
BEFORE UPDATE ON bills
FOR EACH ROW
BEGIN
    :NEW.modified_date := SYSDATE;
END;
/

-- ============================================================================
-- 2. BED STATUS MANAGEMENT - automatinis lovų statuso valdymas
-- ============================================================================

-- Kai sukuriamas ADMISSION, lova tampa OCCUPIED
CREATE OR REPLACE TRIGGER trg_adm_bed_occupy
AFTER INSERT ON admissions
FOR EACH ROW
WHEN (NEW.status = 'ADMITTED')
BEGIN
    UPDATE beds
    SET bed_status = 'OCCUPIED'
    WHERE bed_id = :NEW.bed_id;
END;
/

-- Kai pacientas išrašomas, lova tampa AVAILABLE
CREATE OR REPLACE TRIGGER trg_adm_bed_release
AFTER UPDATE OF status ON admissions
FOR EACH ROW
WHEN (NEW.status IN ('DISCHARGED', 'TRANSFERRED') AND OLD.status = 'ADMITTED')
BEGIN
    UPDATE beds
    SET bed_status = 'AVAILABLE'
    WHERE bed_id = :NEW.bed_id;
END;
/

-- Kai ištrinamas ADMISSION, lova tampa AVAILABLE
CREATE OR REPLACE TRIGGER trg_adm_bed_delete
AFTER DELETE ON admissions
FOR EACH ROW
BEGIN
    UPDATE beds
    SET bed_status = 'AVAILABLE'
    WHERE bed_id = :OLD.bed_id;
END;
/

-- ============================================================================
-- 3. BILL PAYMENT STATUS - automatinis sąskaitos statuso atnaujinimas
-- ============================================================================

CREATE OR REPLACE TRIGGER trg_bill_payment_status
BEFORE INSERT OR UPDATE OF paid_amount, total_amount ON bills
FOR EACH ROW
DECLARE
    v_balance NUMBER;
BEGIN
    -- Skaičiuojame balansą
    v_balance := :NEW.total_amount - :NEW.paid_amount;

    -- Nustatome payment_status pagal balansą
    IF v_balance <= 0 THEN
        :NEW.payment_status := 'PAID';
    ELSIF :NEW.paid_amount > 0 THEN
        :NEW.payment_status := 'PARTIAL';
    ELSIF :NEW.due_date < SYSDATE THEN
        :NEW.payment_status := 'OVERDUE';
    ELSE
        :NEW.payment_status := 'UNPAID';
    END IF;

    -- Jei visiškai apmokėta, nustatome payment_date
    IF v_balance <= 0 AND :NEW.payment_date IS NULL THEN
        :NEW.payment_date := SYSDATE;
    END IF;
END;
/

-- ============================================================================
-- 4. MEDICATION STOCK MANAGEMENT - vaistų atsargų valdymas
-- ============================================================================

-- Kai išrašomas receptas, sumažiname vaisto atsargas
CREATE OR REPLACE TRIGGER trg_presc_stock_reduce
AFTER INSERT ON prescriptions
FOR EACH ROW
WHEN (NEW.status = 'ACTIVE')
BEGIN
    UPDATE medications
    SET stock_quantity = stock_quantity - :NEW.quantity
    WHERE medication_id = :NEW.medication_id;

    -- Patikrinimas ar nepritrūko atsargų (bus užloginta trigger)
    -- Realybėje čia galėtų būti alert sistema
END;
/

-- Kai receptas atšaukiamas, grąžiname vaisto atsargas
CREATE OR REPLACE TRIGGER trg_presc_stock_return
AFTER UPDATE OF status ON prescriptions
FOR EACH ROW
WHEN (NEW.status = 'CANCELLED' AND OLD.status = 'ACTIVE')
BEGIN
    UPDATE medications
    SET stock_quantity = stock_quantity + :OLD.quantity
    WHERE medication_id = :OLD.medication_id;
END;
/

-- ============================================================================
-- 5. BUSINESS RULE VALIDATIONS - verslo taisyklių patikrinimas
-- ============================================================================

-- Pacientas negali turėti daugiau nei vieno aktyvaus ADMISSION vienu metu
CREATE OR REPLACE TRIGGER trg_adm_single_active
BEFORE INSERT OR UPDATE ON admissions
FOR EACH ROW
WHEN (NEW.status = 'ADMITTED')
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM admissions
    WHERE patient_id = :NEW.patient_id
      AND status = 'ADMITTED'
      AND admission_id != NVL(:NEW.admission_id, -1);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20001,
            'Pacientas jau turi aktyvų priėmimą. Negalima sukurti antrojo.');
    END IF;
END;
/

-- Lova negali būti priskirta keliems pacientams tuo pačiu metu
CREATE OR REPLACE TRIGGER trg_bed_single_patient
BEFORE INSERT OR UPDATE ON admissions
FOR EACH ROW
WHEN (NEW.status = 'ADMITTED')
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_count
    FROM admissions
    WHERE bed_id = :NEW.bed_id
      AND status = 'ADMITTED'
      AND admission_id != NVL(:NEW.admission_id, -1);

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20002,
            'Ši lova jau yra užimta kito paciento. Pasirinkite kitą lovą.');
    END IF;
END;
/

-- Gydytojas negali turėti sutampančių vizitų (overlapping appointments)
CREATE OR REPLACE TRIGGER trg_appt_no_overlap
BEFORE INSERT OR UPDATE ON appointments
FOR EACH ROW
WHEN (NEW.status IN ('SCHEDULED', 'CONFIRMED'))
DECLARE
    v_count NUMBER;
    v_appointment_datetime TIMESTAMP;
    v_end_datetime TIMESTAMP;
BEGIN
    -- Konvertuojame date ir time į timestamp
    v_appointment_datetime := TO_TIMESTAMP(
        TO_CHAR(:NEW.appointment_date, 'YYYY-MM-DD') || ' ' || :NEW.appointment_time,
        'YYYY-MM-DD HH24:MI'
    );
    v_end_datetime := v_appointment_datetime + NUMTODSINTERVAL(:NEW.duration_minutes, 'MINUTE');

    -- Tikriname ar nėra sutampančių vizitų tam pačiam gydytojui
    SELECT COUNT(*)
    INTO v_count
    FROM appointments
    WHERE doctor_id = :NEW.doctor_id
      AND status IN ('SCHEDULED', 'CONFIRMED')
      AND appointment_id != NVL(:NEW.appointment_id, -1)
      AND appointment_date = :NEW.appointment_date
      AND TO_TIMESTAMP(
              TO_CHAR(appointment_date, 'YYYY-MM-DD') || ' ' || appointment_time,
              'YYYY-MM-DD HH24:MI'
          ) < v_end_datetime
      AND TO_TIMESTAMP(
              TO_CHAR(appointment_date, 'YYYY-MM-DD') || ' ' || appointment_time,
              'YYYY-MM-DD HH24:MI'
          ) + NUMTODSINTERVAL(duration_minutes, 'MINUTE') > v_appointment_datetime;

    IF v_count > 0 THEN
        RAISE_APPLICATION_ERROR(-20003,
            'Gydytojas jau turi vizitą šiuo laiku. Pasirinkite kitą laiką.');
    END IF;
END;
/

-- Negalima išrašyti recepto už neegzistuojantį vaistą ar neaktyvų vaistą
CREATE OR REPLACE TRIGGER trg_presc_med_check
BEFORE INSERT OR UPDATE ON prescriptions
FOR EACH ROW
DECLARE
    v_available CHAR(1);
    v_med_name VARCHAR2(200);
BEGIN
    SELECT is_available, medication_name
    INTO v_available, v_med_name
    FROM medications
    WHERE medication_id = :NEW.medication_id;

    IF v_available = 'N' THEN
        RAISE_APPLICATION_ERROR(-20004,
            'Vaistas "' || v_med_name || '" šiuo metu neprieinamas. Negalima išrašyti recepto.');
    END IF;
EXCEPTION
    WHEN NO_DATA_FOUND THEN
        RAISE_APPLICATION_ERROR(-20005,
            'Vaistas su ID ' || :NEW.medication_id || ' nerastas sistemoje.');
END;
/

-- Automatinis discharge_date nustatymas kai status keičiasi į DISCHARGED
CREATE OR REPLACE TRIGGER trg_adm_auto_discharge_date
BEFORE UPDATE OF status ON admissions
FOR EACH ROW
WHEN (NEW.status = 'DISCHARGED' AND OLD.status != 'DISCHARGED')
BEGIN
    IF :NEW.discharge_date IS NULL THEN
        :NEW.discharge_date := SYSDATE;
    END IF;
END;
/

-- ============================================================================
-- 6. LOW STOCK ALERT - žemų atsargų įspėjimas (logging į sistemą)
-- ============================================================================

-- Sukuriame lentelę stock alerts (jei dar neegzistuoja)
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE medication_stock_alerts (
        alert_id        NUMBER GENERATED BY DEFAULT AS IDENTITY,
        medication_id   NUMBER NOT NULL,
        medication_name VARCHAR2(200),
        current_stock   NUMBER,
        minimum_level   NUMBER,
        alert_date      DATE DEFAULT SYSDATE,
        CONSTRAINT pk_stock_alerts PRIMARY KEY (alert_id)
    )';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN -- ignore "table already exists"
            RAISE;
        END IF;
END;
/

-- Trigger low stock alert
CREATE OR REPLACE TRIGGER trg_med_low_stock_alert
AFTER UPDATE OF stock_quantity ON medications
FOR EACH ROW
WHEN (NEW.stock_quantity <= NEW.minimum_stock_level AND OLD.stock_quantity > OLD.minimum_stock_level)
BEGIN
    INSERT INTO medication_stock_alerts (
        medication_id,
        medication_name,
        current_stock,
        minimum_level
    ) VALUES (
        :NEW.medication_id,
        :NEW.medication_name,
        :NEW.stock_quantity,
        :NEW.minimum_stock_level
    );

    -- Čia galėtų būti email/SMS alert sistema
    -- DBMS_OUTPUT.PUT_LINE('ALERT: Low stock for ' || :NEW.medication_name);
END;
/

-- ============================================================================
-- 7. APPOINTMENT AUTO-COMPLETION - automatinis vizitų užbaigimas
-- ============================================================================

-- Kai vizito data + trukmė praeina ir jis dar SCHEDULED/CONFIRMED, keisti į COMPLETED
-- (Šis trigger bus paleidžiamas UPDATE komanda, ne automatiškai - reikėtų scheduled job)

-- ============================================================================
-- 8. AUDIT TRAIL - audito sekimas svarbioms operacijoms
-- ============================================================================

-- Sukuriame audit lentelę
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE audit_log (
        audit_id        NUMBER GENERATED BY DEFAULT AS IDENTITY,
        table_name      VARCHAR2(30),
        operation       VARCHAR2(10),
        record_id       NUMBER,
        old_values      CLOB,
        new_values      CLOB,
        changed_by      VARCHAR2(100),
        changed_date    DATE DEFAULT SYSDATE,
        CONSTRAINT pk_audit_log PRIMARY KEY (audit_id)
    )';
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -955 THEN
            RAISE;
        END IF;
END;
/

CREATE INDEX idx_audit_table ON audit_log(table_name);
CREATE INDEX idx_audit_date ON audit_log(changed_date);

-- Audit trigger pavyzdys BILLS lentelei
CREATE OR REPLACE TRIGGER trg_audit_bills
AFTER INSERT OR UPDATE OR DELETE ON bills
FOR EACH ROW
DECLARE
    v_operation VARCHAR2(10);
    v_old_values CLOB;
    v_new_values CLOB;
    v_user VARCHAR2(100);
BEGIN
    -- Nustatome operacijos tipą
    IF INSERTING THEN
        v_operation := 'INSERT';
    ELSIF UPDATING THEN
        v_operation := 'UPDATE';
    ELSIF DELETING THEN
        v_operation := 'DELETE';
    END IF;

    -- Gauname current user (APEX context)
    BEGIN
        v_user := APEX_APPLICATION.G_USER;
    EXCEPTION
        WHEN OTHERS THEN
            v_user := USER;
    END;

    -- Formuojame old ir new values (JSON formatu)
    IF DELETING OR UPDATING THEN
        v_old_values := '{"bill_id":' || :OLD.bill_id ||
                       ',"total_amount":' || :OLD.total_amount ||
                       ',"paid_amount":' || :OLD.paid_amount ||
                       ',"payment_status":"' || :OLD.payment_status || '"}';
    END IF;

    IF INSERTING OR UPDATING THEN
        v_new_values := '{"bill_id":' || :NEW.bill_id ||
                       ',"total_amount":' || :NEW.total_amount ||
                       ',"paid_amount":' || :NEW.paid_amount ||
                       ',"payment_status":"' || :NEW.payment_status || '"}';
    END IF;

    -- Įrašome į audit log
    INSERT INTO audit_log (
        table_name,
        operation,
        record_id,
        old_values,
        new_values,
        changed_by
    ) VALUES (
        'BILLS',
        v_operation,
        NVL(:NEW.bill_id, :OLD.bill_id),
        v_old_values,
        v_new_values,
        v_user
    );
END;
/

-- ============================================================================
-- 9. ROOM AVAILABILITY - automatinis palatų prieinamumo atnaujinimas
-- ============================================================================

-- DISABLED: Kai visos lovos palatoje užimtos, palata tampa unavailable
-- Šis trigger'is sukelia ORA-04091 mutating table problemą APEX SQL Scripts aplinkoje
-- Room availability bus skaičiuojamas per VIEW v_beds_occupancy vietoj trigger'io
/*
CREATE OR REPLACE TRIGGER trg_room_availability
AFTER INSERT OR UPDATE OR DELETE ON beds
FOR EACH ROW
DECLARE
    v_room_id NUMBER;
    v_total_beds NUMBER;
    v_available_beds NUMBER;
BEGIN
    v_room_id := NVL(:NEW.room_id, :OLD.room_id);
    SELECT COUNT(*), SUM(CASE WHEN bed_status = 'AVAILABLE' THEN 1 ELSE 0 END)
    INTO v_total_beds, v_available_beds
    FROM beds
    WHERE room_id = v_room_id;

    IF v_available_beds > 0 THEN
        UPDATE rooms SET is_available = 'Y' WHERE room_id = v_room_id;
    ELSE
        UPDATE rooms SET is_available = 'N' WHERE room_id = v_room_id;
    END IF;
END;
/
*/

-- ============================================================================
-- 10. VALIDATION TRIGGERS - papildomi validacijos triggeriai
-- ============================================================================

-- Negalima priimti paciento į lovą, kuri yra maintenance arba occupied
CREATE OR REPLACE TRIGGER trg_adm_bed_available
BEFORE INSERT OR UPDATE ON admissions
FOR EACH ROW
WHEN (NEW.status = 'ADMITTED')
DECLARE
    v_bed_status VARCHAR2(20);
    v_room_number VARCHAR2(20);
    v_bed_number VARCHAR2(10);
BEGIN
    BEGIN
        SELECT b.bed_status, r.room_number, b.bed_number
        INTO v_bed_status, v_room_number, v_bed_number
        FROM beds b
        JOIN rooms r ON b.room_id = r.room_id
        WHERE b.bed_id = :NEW.bed_id;

        IF v_bed_status NOT IN ('AVAILABLE', 'RESERVED') THEN
            RAISE_APPLICATION_ERROR(-20006,
                'Lova ' || v_room_number || '-' || v_bed_number ||
                ' yra ' || v_bed_status || '. Negalima priimti paciento.');
        END IF;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20007,
                'Lova su ID ' || :NEW.bed_id || ' neegzistuoja. Pirmiausia sukurkite lovą.');
    END;
END;
/

-- Gydytojas negali diagnozuoti savo skyriui nepriklausančio paciento (optional - priklauso nuo reikalavimų)
-- Šį triggerį galima aktyvuoti jei reikia tokio apribojimo

-- ============================================================================
-- PABAIGA: Visi triggeriai sėkmingai sukurti
-- ============================================================================

-- Informacija apie sukurtus triggerius
SELECT 'Sukurta ' || COUNT(*) || ' triggerių' AS info
  FROM user_triggers
 WHERE table_name IN (
    'BILLS', 'LAB_TESTS', 'PRESCRIPTIONS', 'PATIENT_DIAGNOSES',
    'APPOINTMENTS', 'ADMISSIONS', 'DIAGNOSES', 'MEDICATIONS',
    'BEDS', 'ROOMS', 'NURSES', 'DOCTORS', 'EMPLOYEES',
    'DEPARTMENTS', 'PATIENTS'
);

COMMIT;
