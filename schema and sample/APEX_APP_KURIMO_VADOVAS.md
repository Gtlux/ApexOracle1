# LIGONINĖS VALDYMO SISTEMA
## Oracle APEX 22.1.0 Aplikacijos Kūrimo Vadovas

---

## TURINYS

1. [Duomenų bazės paruošimas](#1-duomenų-bazės-paruošimas)
2. [Naujos aplikacijos sukūrimas](#2-naujos-aplikacijos-sukūrimas)
3. [Pradinis puslapis (Dashboard)](#3-pradinis-puslapis-dashboard)
4. [Navigacijos meniu konfigūravimas](#4-navigacijos-meniu-konfigūravimas)
5. [LOV (List of Values) kūrimas](#5-lov-list-of-values-kūrimas)
6. [Pacientų valdymo modulis](#6-pacientų-valdymo-modulis)
7. [Gydytojų valdymo modulis](#7-gydytojų-valdymo-modulis)
8. [Vizitų modulis su kalendoriumi](#8-vizitų-modulis-su-kalendoriumi)
9. [Hospitalizacijos Master-Detail modulis](#9-hospitalizacijos-master-detail-modulis)
10. [Vaistų ir receptų modulis](#10-vaistų-ir-receptų-modulis)
11. [Laboratorinių tyrimų modulis](#11-laboratorinių-tyrimų-modulis)
12. [Sąskaitų modulis](#12-sąskaitų-modulis)
13. [Skyrių ir lovų valdymas](#13-skyrių-ir-lovų-valdymas)
14. [Testavimo instrukcijos](#14-testavimo-instrukcijos)

---

## 1. DUOMENŲ BAZĖS PARUOŠIMAS

### 1.1 SQL skriptų paleidimo tvarka

Prieš kuriant APEX aplikaciją, paleiskite SQL skriptus **SQL Workshop → SQL Scripts**:

```
1. 01_create_tables.sql    - Sukuria visas 15 lentelių
2. 02_create_triggers.sql  - Sukuria verslo logikos triggerius
3. 03_create_views.sql     - Sukuria rodinius (views)
4. 04_insert_sample_data.sql - Įterpia testinius duomenis
```

### 1.2 Duomenų bazės struktūra

**15 lentelių:**

| Lentelė | Aprašymas |
|---------|-----------|
| DEPARTMENTS | Ligoninės skyriai |
| EMPLOYEES | Darbuotojai (bazinė lentelė) |
| DOCTORS | Gydytojai (FK → employees) |
| NURSES | Medicinos seserys (FK → employees) |
| ROOMS | Palatai |
| BEDS | Lovos |
| PATIENTS | Pacientai |
| APPOINTMENTS | Vizitai/Konsultacijos |
| ADMISSIONS | Priėmimai/Hospitalizacija |
| DIAGNOSES | Diagnozių katalogas |
| PATIENT_DIAGNOSES | Pacientų diagnozės |
| MEDICATIONS | Vaistų katalogas |
| PRESCRIPTIONS | Receptai |
| LAB_TESTS | Laboratoriniai tyrimai |
| BILLS | Sąskaitos |

**Pagrindiniai rodiniai (Views):**

| Rodinys | Naudojimas |
|---------|------------|
| V_PATIENTS_FULL | Pacientų sąrašas su statistika |
| V_DOCTORS_FULL | Gydytojai su skyrių info |
| V_APPOINTMENTS_CALENDAR | Kalendoriaus duomenys |
| V_ADMISSIONS_CURRENT | Aktyvūs priėmimai |
| V_BILLS_DETAILED | Sąskaitos su detalia info |
| V_BEDS_OCCUPANCY | Lovų užimtumas |
| V_PATIENT_DIAGNOSES_FULL | Pacientų diagnozės |
| V_PRESCRIPTIONS_FULL | Receptai |
| V_LAB_TESTS_FULL | Lab tyrimai |
| V_DASHBOARD_STATS | Dashboard statistika |

---

## 2. NAUJOS APLIKACIJOS SUKŪRIMAS

### 2.1 Create Application Wizard

1. Prisijunkite prie Oracle APEX Workspace
2. Spauskite **App Builder**
3. Spauskite **Create** mygtuką
4. Pasirinkite **New Application**

### 2.2 Application Properties

5. Užpildykite formos laukus:
   - **Name:** `Ligoninės valdymo sistema`
   - **Application ID:** Palikite automatinį arba įveskite `100`
   - **Appearance → Theme Style:** Pasirinkite `Vita` arba `Vita - Dark`
   - **Appearance → Icon:** Pasirinkite medicininę ikoną

### 2.3 Pages sekcija

6. Pašalinkite default puslapį jei reikia
7. Spauskite **Add Page** ir pridėkite:
   - **Blank Page** (tai bus Dashboard)

### 2.4 Features sekcija

8. Pažymėkite:
   - ✅ **Install Supporting Objects**
   - ✅ **Check All** (rekomenduojama)

### 2.5 Settings sekcija

9. **Application Definition → Logging:** Yes

10. Spauskite **Create Application**

---

## 3. PRADINIS PUSLAPIS (DASHBOARD)

### 3.1 Dashboard puslapio redagavimas

1. Atidarykite **Page 1** (Home) per Page Designer
2. Dešiniuoju pelės klavišu spauskite ant **Body** → **Create Region**

### 3.2 Statistikos kortelių regionas (Cards)

**Regionas: Statistikos kortelės**

1. **Create Region** → nustatykite:
   - **Title:** `Statistika`
   - **Type:** `Cards`

2. **Source** sekcijoje:
   - **Type:** `SQL Query`
   - **SQL Query:**

```sql
SELECT
    'Aktyvūs pacientai' AS card_title,
    TO_CHAR((SELECT COUNT(*) FROM patients WHERE is_active = 'Y')) AS card_value,
    'fa-users' AS card_icon,
    'u-color-1' AS card_color,
    5 AS target_page
FROM dual
UNION ALL
SELECT
    'Šiandien vizitų',
    TO_CHAR((SELECT COUNT(*) FROM appointments
     WHERE appointment_date = TRUNC(SYSDATE)
     AND status IN ('SCHEDULED', 'CONFIRMED'))),
    'fa-calendar-check-o',
    'u-color-2',
    10
FROM dual
UNION ALL
SELECT
    'Hospitalizuoti',
    TO_CHAR((SELECT COUNT(*) FROM admissions WHERE status = 'ADMITTED')),
    'fa-bed',
    'u-color-3',
    15
FROM dual
UNION ALL
SELECT
    'Laisvos lovos',
    TO_CHAR((SELECT COUNT(*) FROM beds WHERE bed_status = 'AVAILABLE')),
    'fa-check-circle',
    'u-color-4',
    27
FROM dual
UNION ALL
SELECT
    'Neapmokėtos sąskaitos',
    TO_CHAR((SELECT COUNT(*) FROM bills WHERE payment_status IN ('UNPAID', 'OVERDUE'))),
    'fa-money',
    'u-color-5',
    30
FROM dual
UNION ALL
SELECT
    'Mažos vaistų atsargos',
    TO_CHAR((SELECT COUNT(*) FROM medications WHERE stock_quantity <= minimum_stock_level)),
    'fa-exclamation-triangle',
    'u-color-6',
    20
FROM dual
```

3. **Attributes** sekcijoje:
   - **Card → Primary Key Column 1:** `CARD_TITLE`
   - **Title Column:** `CARD_TITLE`
   - **Body → Advanced Formatting:** On
   - **Body → HTML Expression:**
   ```html
   <span class="fa &CARD_ICON." style="font-size: 24px;"></span>
   <span style="font-size: 32px; font-weight: bold;">&CARD_VALUE.</span>
   ```
   - **Icon and Badge → Icon Source:** `Icon Class`
   - **Icon and Badge → Icon Column:** `CARD_ICON`
   - **Card → CSS Classes Column:** `CARD_COLOR`

4. **Action sukūrimas (kad kortelė būtų paspaudžiama):**

   **Rendering** skydelyje po Cards regionu:
   - Išskleiskite **Cards** regioną
   - Dešiniuoju spauskite ant **Actions** → **Create Action**

   **Action** nustatymai (Property Editor):
   - **Identification → Type:** `Full Card` (visa kortelė paspaudžiama)
   - **Link → Type:** `Redirect to Page in this Application`
   - **Link → Target:** Spauskite `No Link Defined`

   **Link Builder - Target** dialoge:
   - **Page:** Įveskite stulpelio pavadinimą naudodami **&** ir **.** sintaksę: `&TARGET_PAGE.`
   - **SVARBU:** Stulpelio pavadinimas turi tiksliai atitikti SQL užklausos alias (didžiosios/mažosios raidės nesvarbu APEX'e, bet rekomenduojama naudoti vienodą rašybą)
   - **Alternatyva:** Galite naudoti Item substitution - pasirinkite **Item** ir įveskite `TARGET_PAGE`
   - Spauskite **OK**

   > **Pastaba pagal Oracle APEX 22.1 dokumentaciją:** Kai naudojate Link Builder su Cards regionu, galite tiesiogiai nurodyti stulpelio reikšmę kaip puslapio numerį. APEX automatiškai pakeičia substitution string'us į tikras reikšmes iš SQL užklausos rezultatų.

### 3.3 Šiandienos vizitų regionas

1. **Create Region** → nustatykite:
   - **Title:** `Šiandienos vizitai`
   - **Type:** `Classic Report`

2. **Source → SQL Query:**

```sql
SELECT
    a.appointment_time AS laikas,
    p.first_name || ' ' || p.last_name AS pacientas,
    e.first_name || ' ' || e.last_name AS gydytojas,
    d.specialization AS specializacija,
    DECODE(a.appointment_type,
        'CHECKUP', 'Patikrinimas',
        'CONSULTATION', 'Konsultacija',
        'FOLLOWUP', 'Pakartotinis',
        'EMERGENCY', 'Skubus',
        a.appointment_type) AS tipas,
    DECODE(a.status,
        'SCHEDULED', 'Suplanuotas',
        'CONFIRMED', 'Patvirtintas',
        'COMPLETED', 'Įvykęs',
        'CANCELLED', 'Atšauktas',
        a.status) AS busena
FROM appointments a
JOIN patients p ON a.patient_id = p.patient_id
JOIN doctors d ON a.doctor_id = d.doctor_id
JOIN employees e ON d.doctor_id = e.employee_id
WHERE a.appointment_date = TRUNC(SYSDATE)
ORDER BY a.appointment_time
```

3. **Attributes → Appearance:**
   - **Template:** `Standard`

4. **Columns** - pakeiskite **Heading** (stulpelių pavadinimus):
   - LAIKAS → `Laikas`
   - PACIENTAS → `Pacientas`
   - GYDYTOJAS → `Gydytojas`
   - SPECIALIZACIJA → `Specializacija`
   - TIPAS → `Tipas`
   - BUSENA → `Būsena`

### 3.4 Aktyvių priėmimų regionas

1. **Create Region:**
   - **Title:** `Aktyvūs priėmimai`
   - **Type:** `Classic Report`

2. **Source → SQL Query:**

```sql
SELECT
    p.first_name || ' ' || p.last_name AS pacientas,
    dept.department_name AS skyrius,
    r.room_number || '-' || b.bed_number AS palata_lova,
    a.admission_date AS priemimo_data,
    TRUNC(SYSDATE - a.admission_date) AS dienu_skaicius
FROM admissions a
JOIN patients p ON a.patient_id = p.patient_id
JOIN beds b ON a.bed_id = b.bed_id
JOIN rooms r ON b.room_id = r.room_id
JOIN departments dept ON r.department_id = dept.department_id
WHERE a.status = 'ADMITTED'
ORDER BY a.admission_date
```

---

## 4. NAVIGACIJOS MENIU KONFIGŪRAVIMAS

### 4.1 Navigation Menu atidarymas

1. Eikite į **Shared Components** (Application puslapyje spauskite Shared Components)
2. **Navigation and Search** sekcijoje spauskite **Navigation Menu**
3. Spauskite ant **Desktop Navigation Menu**

### 4.2 Meniu įrašų kūrimas

Spauskite **Create Entry** kiekvienam meniu punktui:

**Pagrindinis meniu struktūra:**

| Seq | List Entry Label | Target Page | Icon Class | Parent |
|-----|------------------|-------------|------------|--------|
| 10 | Pagrindinis | 1 | fa-home | - |
| 20 | Pacientai | - | fa-users | - |
| 21 | Pacientų sąrašas | 5 | fa-list | Pacientai |
| 22 | Naujas pacientas | 6 | fa-user-plus | Pacientai |
| 30 | Gydytojai | - | fa-user-md | - |
| 31 | Gydytojų sąrašas | 7 | fa-list | Gydytojai |
| 32 | Medicinos seserys | 8 | fa-list | Gydytojai |
| 40 | Vizitai | - | fa-calendar | - |
| 41 | Vizitų sąrašas | 10 | fa-list | Vizitai |
| 42 | Vizitų kalendorius | 11 | fa-calendar | Vizitai |
| 43 | Naujas vizitas | 12 | fa-calendar-plus-o | Vizitai |
| 50 | Hospitalizacija | - | fa-hospital-o | - |
| 51 | Aktyvūs priėmimai | 15 | fa-bed | Hospitalizacija |
| 52 | Priėmimų istorija | 16 | fa-history | Hospitalizacija |
| 53 | Naujas priėmimas | 17 | fa-plus-circle | Hospitalizacija |
| 60 | Vaistai ir receptai | - | fa-medkit | - |
| 61 | Vaistų katalogas | 20 | fa-pills | Vaistai ir receptai |
| 62 | Receptai | 21 | fa-prescription | Vaistai ir receptai |
| 70 | Lab tyrimai | 23 | fa-flask | - |
| 80 | Infrastruktūra | - | fa-building | - |
| 81 | Skyriai | 25 | fa-sitemap | Infrastruktūra |
| 82 | Palatai ir lovos | 27 | fa-bed | Infrastruktūra |
| 90 | Finansai | - | fa-euro | - |
| 91 | Sąskaitos | 30 | fa-file-text-o | Finansai |

### 4.3 Entry kūrimo žingsniai

Kiekvienam įrašui:

1. Spauskite **Create Entry**
2. Užpildykite laukus:
   - **Sequence:** Eilės numeris iš lentelės
   - **Image/Class:** Icon Class iš lentelės (pvz., `fa-home`)
   - **List Entry Label:** Lietuviškas pavadinimas
   - **Target → Page:** Puslapio numeris (arba palikite tuščią jei tik parent)
   - **Parent List Entry:** Pasirinkite tėvinį meniu punktą (submeniu atveju)
3. Spauskite **Create List Entry**

---

## 5. LOV (LIST OF VALUES) KŪRIMAS

### 5.1 LOV tipai APEX 22.1

> **Pagal Oracle APEX 22.1 oficialią dokumentaciją:**
> LOV (List of Values) yra statinė arba dinaminė reikšmių sąrašo apibrėžtis, naudojama puslapio elementuose kaip Select List, Popup LOV, Checkbox, Radio Group ar Multiple Select List.
>
> Šaltinis: [Creating Lists of Values at the Application-Level](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/creating-lists-of-values-at-the-application-level.html)

Oracle APEX 22.1 palaiko du LOV tipus:
- **Static** - reikšmės įvedamos rankiniu būdu (Display Value / Return Value poros). Naudokite kai reikšmių sąrašas mažas ir nesikeičia (pvz., lytis, būsenos).
- **Dynamic** - reikšmės gaunamos iš SQL užklausos. Naudokite kai duomenys turi būti aktualūs iš duomenų bazės.

**Privalumai kuriant LOV kaip Shared Component:**
- Galite pakartotinai naudoti bet kuriame puslapyje
- Visi LOV apibrėžimai saugomi vienoje vietoje
- Lengva atnaujinti - pakeitimas taikomas visur
- Palaiko multi-column, icon ir grouping funkcionalumą

### 5.2 Static LOV kūrimas

**Navigacija:** Application Builder → Jūsų aplikacija → **Shared Components** → Other Components → **List of Values** → **Create**

#### LOV 1: LYTIS_LOV (Static)

1. Spauskite **Create**
2. **Source:** Pasirinkite **From Scratch**
3. Spauskite **Next**
4. **Name:** `LYTIS_LOV`
5. **Type:** Pasirinkite **Static**
6. Spauskite **Next**
7. **Static Values** - įveskite poras (spauskite **Add Value** kiekvienai):

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Vyras | M |
| 2 | Moteris | F |
| 3 | Kita | O |

8. Spauskite **Create List of Values**

#### LOV 2: KRAUJO_GRUPE_LOV (Static)

1. **Create** → **From Scratch** → **Next**
2. **Name:** `KRAUJO_GRUPE_LOV`
3. **Type:** `Static`
4. **Static Values:**

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | A+ | A+ |
| 2 | A- | A- |
| 3 | B+ | B+ |
| 4 | B- | B- |
| 5 | AB+ | AB+ |
| 6 | AB- | AB- |
| 7 | O+ | O+ |
| 8 | O- | O- |

#### LOV 3: VIZITO_TIPAS_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Patikrinimas | CHECKUP |
| 2 | Konsultacija | CONSULTATION |
| 3 | Pakartotinis vizitas | FOLLOWUP |
| 4 | Skubus | EMERGENCY |

#### LOV 4: VIZITO_BUSENA_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Suplanuotas | SCHEDULED |
| 2 | Patvirtintas | CONFIRMED |
| 3 | Įvykęs | COMPLETED |
| 4 | Atšauktas | CANCELLED |
| 5 | Neatvyko | NO_SHOW |

#### LOV 5: PRIEMIMO_TIPAS_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Skubus | EMERGENCY |
| 2 | Planuotas | PLANNED |
| 3 | Perkėlimas | TRANSFER |

#### LOV 6: LOVOS_BUSENA_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Laisva | AVAILABLE |
| 2 | Užimta | OCCUPIED |
| 3 | Remontuojama | MAINTENANCE |
| 4 | Rezervuota | RESERVED |

#### LOV 7: PALATOS_TIPAS_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Vienvietė | PRIVATE |
| 2 | Dvivietė | SEMI_PRIVATE |
| 3 | Intensyvi priežiūra | ICU |
| 4 | Skubios pagalbos | EMERGENCY |
| 5 | Operacinė | OPERATING |

#### LOV 8: MOKEJIMO_BUSENA_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Neapmokėta | UNPAID |
| 2 | Dalinai apmokėta | PARTIAL |
| 3 | Apmokėta | PAID |
| 4 | Vėluojama | OVERDUE |

#### LOV 9: MOKEJIMO_METODAS_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Grynais | CASH |
| 2 | Kortele | CARD |
| 3 | Draudimas | INSURANCE |
| 4 | Banko pavedimas | BANK_TRANSFER |

#### LOV 10: TYRIMO_TIPAS_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Kraujo tyrimas | BLOOD |
| 2 | Šlapimo tyrimas | URINE |
| 3 | Rentgenas | XRAY |
| 4 | MRT | MRI |
| 5 | KT | CT_SCAN |
| 6 | Echoskopija | ULTRASOUND |
| 7 | EKG | ECG |
| 8 | EEG | EEG |
| 9 | Biopsija | BIOPSY |

#### LOV 11: VAISTO_FORMA_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Tabletė | TABLET |
| 2 | Kapsulė | CAPSULE |
| 3 | Injekcija | INJECTION |
| 4 | Sirupas | SYRUP |
| 5 | Tepalas | CREAM |
| 6 | Lašai | DROPS |
| 7 | Inhaliatorius | INHALER |

#### LOV 12: TAIP_NE_LOV (Static)

| Sequence | Display Value | Return Value |
|----------|---------------|--------------|
| 1 | Taip | Y |
| 2 | Ne | N |

### 5.3 Dynamic LOV kūrimas

**Navigacija:** Shared Components → **List of Values** → **Create**

#### LOV 13: SKYRIAI_LOV (Dynamic)

1. **Create** → **From Scratch** → **Next**
2. **Name:** `SKYRIAI_LOV`
3. **Type:** `Dynamic`
4. Spauskite **Next**
5. **Query:**

```sql
SELECT department_name AS d,
       department_id AS r
FROM departments
WHERE is_active = 'Y'
ORDER BY department_name
```

6. Spauskite **Create List of Values**

#### LOV 14: GYDYTOJAI_LOV (Dynamic)

```sql
SELECT e.first_name || ' ' || e.last_name || ' (' || d.specialization || ')' AS d,
       d.doctor_id AS r
FROM doctors d
JOIN employees e ON d.doctor_id = e.employee_id
WHERE e.employment_status = 'ACTIVE'
ORDER BY e.last_name, e.first_name
```

#### LOV 15: PACIENTAI_LOV (Dynamic)

```sql
SELECT p.first_name || ' ' || p.last_name ||
       ' (gim. ' || TO_CHAR(p.date_of_birth, 'YYYY-MM-DD') || ')' AS d,
       p.patient_id AS r
FROM patients p
WHERE p.is_active = 'Y'
ORDER BY p.last_name, p.first_name
```

#### LOV 16: DIAGNOZES_LOV (Dynamic)

```sql
SELECT diagnosis_code || ' - ' || diagnosis_name AS d,
       diagnosis_id AS r
FROM diagnoses
WHERE is_active = 'Y'
ORDER BY diagnosis_code
```

#### LOV 17: VAISTAI_LOV (Dynamic)

```sql
SELECT medication_name || ' (' || NVL(strength, '-') || ')' AS d,
       medication_id AS r
FROM medications
WHERE is_available = 'Y'
ORDER BY medication_name
```

#### LOV 18: LAISVOS_LOVOS_LOV (Dynamic - Cascading)

> **Cascading LOV (Kaskadinis LOV) pagal Oracle APEX 22.1 dokumentaciją:**
>
> Cascading LOV reiškia, kad vieno puslapio elemento (child) reikšmių sąrašas atsinaujina kai pasikeičia kito elemento (parent) reikšmė.
>
> **Kaip veikia:**
> - Kai vartotojas pakeičia parent elemento reikšmę, APEX automatiškai:
>   1. Nusiunčia naują parent reikšmę į serverį
>   2. Vykdo child LOV SQL užklausą su nauja parent reikšme
>   3. Atnaujina child elemento reikšmių sąrašą
>   4. Nustato child reikšmę į NULL (arba default reikšmę)
>
> **Konfigūracija puslapio elemente:**
> - Child elemento **List of Values → Cascading LOV Parent Item(s):** nurodyti parent elementą (pvz., `P17_DEPARTMENT_ID`)
>
> Šaltinis: [Cascading LOV Parent Item(s)](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/)

**Šis LOV priklauso nuo pasirinkto skyriaus (Cascading LOV)**

```sql
SELECT r.room_number || ' - Lova ' || b.bed_number ||
       ' (' || DECODE(r.room_type,
           'PRIVATE', 'Vienvietė',
           'SEMI_PRIVATE', 'Dvivietė',
           'ICU', 'Intensyvi priežiūra',
           r.room_type) || ')' AS d,
       b.bed_id AS r
FROM beds b
JOIN rooms r ON b.room_id = r.room_id
WHERE b.bed_status = 'AVAILABLE'
AND r.department_id = NVL(:P17_DEPARTMENT_ID, r.department_id)
ORDER BY r.room_number, b.bed_number
```

> **SVARBU:** Kai naudojate Cascading LOV, parent elemento reikšmė automatiškai įtraukiama į SQL užklausą. Nereikia kurti atskiro Dynamic Action - APEX tai daro automatiškai kai nustatytas **Cascading LOV Parent Item(s)** atributas.

---

## 6. PACIENTŲ VALDYMO MODULIS

### 6.1 Pacientų sąrašo puslapis (Page 5)

#### Puslapio sukūrimas

1. Eikite į **App Builder** → savo aplikacija
2. Spauskite **Create Page**
3. **Page Type:** Pasirinkite **Component**
4. Pasirinkite **Interactive Report**
5. Užpildykite:
   - **Page Number:** `5`
   - **Page Name:** `Pacientų sąrašas`
   - **Page Mode:** `Normal`
6. **Next**
7. **Navigation:**
   - **Breadcrumb:** `- No breadcrumb entry -` (arba sukurkite)
   - **Navigation:** `Identify an existing navigation menu entry for this page`
   - Pasirinkite meniu punktą `Pacientų sąrašas`
8. **Next**
9. **Data Source:**
   - **Source Type:** `SQL Query`
   - **Enter SQL SELECT Statement:**

```sql
SELECT
    patient_id,
    full_name AS "Vardas, Pavardė",
    age AS "Amžius",
    gender_display AS "Lytis",
    blood_type AS "Kraujo grupė",
    phone_number AS "Telefonas",
    email AS "El. paštas",
    city AS "Miestas",
    insurance_number AS "Draudimo Nr.",
    registration_date AS "Registracijos data",
    total_appointments AS "Vizitų",
    outstanding_balance AS "Skola",
    CASE currently_admitted
        WHEN 'Y' THEN 'Taip'
        ELSE 'Ne'
    END AS "Hospitalizuotas",
    CASE is_active
        WHEN 'Y' THEN 'Aktyvus'
        ELSE 'Neaktyvus'
    END AS "Būsena"
FROM v_patients_full
```

10. **Include Form Page:** Pažymėkite **Yes** - tai sukurs ir formos puslapį
11. **Form Page Number:** `6`
12. **Form Page Name:** `Paciento duomenys`
13. **Form Page Mode:** `Modal Dialog`
14. **Primary Key Column:** `PATIENT_ID`
15. Spauskite **Create Page**

#### Filtravimo laukų pridėjimas

1. Atidarykite **Page 5** Page Designer
2. **Rendering** skydelyje po Interactive Report regionu sukurkite naują regioną arba naudokite esamą
3. Dešiniuoju spauskite ant **Body** → **Create Region**
   - **Title:** `Filtrai`
   - **Type:** `Static Content`
   - **Template:** `Blank with Attributes`
   - **Position:** `Body` (virš Interactive Report)

4. Į regioną "Filtrai" pridėkite Page Items:

**P5_SEARCH (Text Field):**
- Dešiniuoju spauskite ant "Filtrai" regiono → **Create Page Item**
- **Name:** `P5_SEARCH`
- **Type:** `Text Field`
- **Label:** `Paieška`
- **Placeholder:** `Vardas, telefonas arba draudimo nr.`
- **Submit When Enter Pressed:** `Yes`

**P5_FILTER_ACTIVE (Select List):**
- **Create Page Item**
- **Name:** `P5_FILTER_ACTIVE`
- **Type:** `Select List`
- **Label:** `Būsena`
- **List of Values → Type:** `Static Values`
- **Static Values:**
  - Display: `Visi`, Return: `` (tuščias)
  - Display: `Aktyvūs`, Return: `Y`
  - Display: `Neaktyvūs`, Return: `N`
- **Display Null Value:** `Yes`
- **Null Display Value:** `Visi`

**P5_FILTER_BLOOD_TYPE (Select List):**
- **Name:** `P5_FILTER_BLOOD_TYPE`
- **Type:** `Select List`
- **Label:** `Kraujo grupė`
- **List of Values → Type:** `Shared Component`
- **List of Values:** `KRAUJO_GRUPE_LOV`
- **Display Null Value:** `Yes`
- **Null Display Value:** `Visos`

5. Modifikuokite Interactive Report SQL užklausą (pridėkite WHERE):

```sql
SELECT
    patient_id,
    full_name AS "Vardas, Pavardė",
    age AS "Amžius",
    gender_display AS "Lytis",
    blood_type AS "Kraujo grupė",
    phone_number AS "Telefonas",
    email AS "El. paštas",
    city AS "Miestas",
    insurance_number AS "Draudimo Nr.",
    registration_date AS "Registracijos data",
    total_appointments AS "Vizitų",
    outstanding_balance AS "Skola",
    CASE currently_admitted WHEN 'Y' THEN 'Taip' ELSE 'Ne' END AS "Hospitalizuotas",
    CASE is_active WHEN 'Y' THEN 'Aktyvus' ELSE 'Neaktyvus' END AS "Būsena"
FROM v_patients_full
WHERE (:P5_FILTER_ACTIVE IS NULL OR is_active = :P5_FILTER_ACTIVE)
AND (:P5_FILTER_BLOOD_TYPE IS NULL OR blood_type = :P5_FILTER_BLOOD_TYPE)
AND (:P5_SEARCH IS NULL OR
     UPPER(full_name) LIKE '%' || UPPER(:P5_SEARCH) || '%' OR
     UPPER(phone_number) LIKE '%' || UPPER(:P5_SEARCH) || '%' OR
     UPPER(insurance_number) LIKE '%' || UPPER(:P5_SEARCH) || '%')
```

6. Nustatykite **Page Items to Submit:** `P5_SEARCH,P5_FILTER_ACTIVE,P5_FILTER_BLOOD_TYPE`
   - Interactive Report regionas → **Source** sekcija → **Page Items to Submit**

> **Pagal Oracle APEX 22.1 dokumentaciją**, **Page Items to Submit** atributas nurodo kurie puslapio elementai turi būti pateikiami į serverį kai regionas yra atnaujinamas (refresh).
>
> **Kodėl tai svarbu:**
> - SQL užklausa naudoja bind kintamuosius (pvz., `:P5_SEARCH`)
> - APEX turi žinoti kuriuos elementus įtraukti į Ajax užklausą
> - Be šio nustatymo, filtravimas neveiks nes APEX nežinos elementų reikšmių
>
> **Sintaksė:** Elementų sąrašas atskirtas kableliais, be tarpų: `P5_SEARCH,P5_FILTER_ACTIVE,P5_FILTER_BLOOD_TYPE`
>
> Šaltinis: [Using Interactive Report Filters](https://docs.oracle.com/en/database/oracle/apex/22.1/aeeug/using-interactive-report-filters.html)

#### Mygtukų pridėjimas

**Mygtukas "Ieškoti":**
- Dešiniuoju ant "Filtrai" regiono → **Create Button**
- **Button Name:** `SEARCH`
- **Label:** `Ieškoti`
- **Action:** `Submit Page`
- **Position:** `Next` (šalia paskutinio lauko)

**Mygtukas "Išvalyti":**
- **Create Button**
- **Button Name:** `CLEAR`
- **Label:** `Išvalyti`
- **Action:** `Redirect to Page in this Application`
- **Target → Page:** `5`
- **Target → Clear Cache:** `5`

**Mygtukas "Naujas pacientas":**
- **Create Button**
- **Button Name:** `CREATE`
- **Label:** `Naujas pacientas`
- **Action:** `Redirect to Page in this Application`
- **Target → Page:** `6`
- **Target → Clear Cache:** `6`
- **Position:** `Right of Interactive Report Search Bar`
- **Hot:** `Yes` (pabrėžtas mygtukas)

### 6.2 Paciento formos konfigūravimas (Page 6)

Jei forma buvo automatiškai sukurta kartu su Interactive Report, ją reikia konfigūruoti:

1. Atidarykite **Page 6** Page Designer
2. **Form Region** → **Source** → patikrinkite ar Table/View yra `PATIENTS`

#### Laukų konfigūravimas

Kiekvienam laukui nustatykite:

**P6_PATIENT_ID:**
- **Type:** `Hidden`

**P6_FIRST_NAME:**
- **Type:** `Text Field`
- **Label:** `Vardas`
- **Validation → Value Required:** `Yes`
- **Appearance → Template:** `Required`

**P6_LAST_NAME:**
- **Type:** `Text Field`
- **Label:** `Pavardė`
- **Validation → Value Required:** `Yes`
- **Appearance → Template:** `Required`

**P6_DATE_OF_BIRTH:**
- **Type:** `Date Picker`
- **Label:** `Gimimo data`
- **Validation → Value Required:** `Yes`
- **Appearance → Template:** `Required`
- **Settings → Minimum Date:** `-125y` (santykinė reikšmė: 125 metai atgal nuo šiandien)
- **Settings → Maximum Date:** `0d` (santykinė reikšmė: šiandiena)

> **Pagal Oracle APEX 22.1 dokumentaciją**, Date Picker Minimum/Maximum Date palaiko šiuos formatus:
> - **Absoliutus:** `YYYY-MM-DDTHH24:MI:SS` arba `YYYYMMDDHH24MI` (pvz., `1900-01-01T00:00:00`)
> - **Santykinis:** naudojant `y` (metai), `m` (mėnesiai), `w` (savaitės), `d` (dienos)
>   - Pavyzdžiai: `+1y+1m` (po 1 metų ir 1 mėnesio), `-1m-1w` (prieš 1 mėnesį ir 1 savaitę), `0d` (šiandien)
> - **Substitution:** `&P1_MY_DATE.` (puslapio elemento reikšmė)
>
> Šaltinis: [Oracle APEX Date Picker Documentation](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/)

**P6_GENDER:**
- **Type:** `Select List`
- **Label:** `Lytis`
- **List of Values → Type:** `Shared Component`
- **List of Values:** `LYTIS_LOV`
- **Validation → Value Required:** `Yes`
- **Display Null Value:** `Yes`
- **Null Display Value:** `- Pasirinkite -`

**P6_BLOOD_TYPE:**
- **Type:** `Select List`
- **Label:** `Kraujo grupė`
- **List of Values → Type:** `Shared Component`
- **List of Values:** `KRAUJO_GRUPE_LOV`
- **Display Null Value:** `Yes`
- **Null Display Value:** `- Pasirinkite -`

**P6_EMAIL:**
- **Type:** `Text Field`
- **Label:** `El. paštas`
- **Subtype:** `E-Mail`

**P6_PHONE_NUMBER:**
- **Type:** `Text Field`
- **Label:** `Telefonas`
- **Validation → Value Required:** `Yes`

**P6_EMERGENCY_CONTACT_NAME:**
- **Type:** `Text Field`
- **Label:** `Kontaktinis asmuo`

**P6_EMERGENCY_CONTACT_PHONE:**
- **Type:** `Text Field`
- **Label:** `Kontaktinio asmens tel.`

**P6_ADDRESS:**
- **Type:** `Text Field`
- **Label:** `Adresas`

**P6_CITY:**
- **Type:** `Text Field`
- **Label:** `Miestas`

**P6_POSTAL_CODE:**
- **Type:** `Text Field`
- **Label:** `Pašto kodas`

**P6_INSURANCE_NUMBER:**
- **Type:** `Text Field`
- **Label:** `Draudimo numeris`

**P6_IS_ACTIVE:**
- **Type:** `Switch`
- **Label:** `Aktyvus`
- **Default → Type:** `Static`
- **Default → Static Value:** `Y`

#### Validacijų pridėjimas

> **Pagal Oracle APEX 22.1 dokumentaciją**, validacijos tipas "PL/SQL Function (returning Boolean)" turi grąžinti:
> - `TRUE` - validacija sėkminga (nėra klaidos)
> - `FALSE` - validacija nesėkminga (rodoma klaidos pranešimas)
>
> **SVARBU - kad validacija veiktų:**
> 1. **Mygtukas** turi turėti: **Behavior → Execute Validations: `Yes`**
> 2. **Validacija** turi turėti: **Execution → When Button Pressed: `- Select -`** (tuščias = visiems)
> 3. **Validacija** turi turėti: **Execution → Always Execute: `Yes`** (arba `No` jei norite sąlyginio vykdymo)
>
> **Associated Item** nustačius, APEX automatiškai rodo "Go to Error" nuorodą šalia klaidos pranešimo.
>
> Šaltinis: [Understanding Validations](https://docs.oracle.com/database/121/HTMDB/bldr_validate.htm)

**Validacija: Email formatas**

1. **Processing** skydelyje (kairėje pusėje) dešiniuoju spauskite **Validating** → **Create Validation**
2. Užpildykite Property Editor:
   - **Identification → Name:** `V_EMAIL_FORMAT`
   - **Identification → Type:** `PL/SQL Function (returning Boolean)`
   - **Validation → PL/SQL Function Body:**
```sql
BEGIN
    -- Grąžiname TRUE jei el. paštas tuščias arba formatas teisingas
    -- Grąžiname FALSE jei formatas neteisingas
    IF :P6_EMAIL IS NULL THEN
        RETURN TRUE;
    ELSIF REGEXP_LIKE(:P6_EMAIL, '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$') THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
```
   - **Error → Error Message:** `Neteisingas el. pašto formatas (pvz., vardas@domenas.lt)`
   - **Error → Display Location:** `Inline with Field`
   - **Error → Associated Item:** `P6_EMAIL`
   - **Execution → Sequence:** `10`
   - **Execution → When Button Pressed:** `- Select -` (palikti tuščią - veiks visiems mygtukams)
   - **Execution → Always Execute:** `No` (validacija vykdoma tik kai mygtukas turi Execute Validations = Yes)

**Validacija: Gimimo data ne ateityje**

1. **Create Validation**
2. Užpildykite:
   - **Name:** `V_DOB_NOT_FUTURE`
   - **Type:** `PL/SQL Function (returning Boolean)`
   - **PL/SQL Function Body:**
```sql
BEGIN
    IF :P6_DATE_OF_BIRTH IS NULL THEN
        RETURN TRUE;  -- Jei tuščia, kita validacija (Value Required) pasirūpins
    ELSIF :P6_DATE_OF_BIRTH <= SYSDATE THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
```
   - **Error Message:** `Gimimo data negali būti ateityje`
   - **Error → Associated Item:** `P6_DATE_OF_BIRTH`
   - **Execution → When Button Pressed:** `- Select -`

**Validacija: Telefono formatas**

1. **Create Validation**
2. Užpildykite:
   - **Name:** `V_PHONE_FORMAT`
   - **Type:** `PL/SQL Function (returning Boolean)`
   - **PL/SQL Function Body:**
```sql
BEGIN
    IF :P6_PHONE_NUMBER IS NULL THEN
        RETURN TRUE;  -- Jei tuščia, kita validacija pasirūpins
    ELSIF REGEXP_LIKE(:P6_PHONE_NUMBER, '^\+?[0-9\s\-]{9,20}$') THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;
END;
```
   - **Error Message:** `Neteisingas telefono formatas`
   - **Error → Associated Item:** `P6_PHONE_NUMBER`
   - **Execution → When Button Pressed:** `- Select -`

#### Procesų konfigūravimas

> **Pagal Oracle APEX 22.1 dokumentaciją**, Form Region naudoja du pagrindinius procesus:
> 1. **Form - Initialization** - duomenų užkrovimas iš duomenų bazės į formos laukus
> 2. **Form - Automatic Row Processing (DML)** - INSERT, UPDATE, DELETE operacijos
>
> Šie procesai automatiškai sukuriami kai naudojate Create Page Wizard su Form tipo puslapiu.
> Šaltinis: [Understanding Page Processes](https://docs.oracle.com/en/database/oracle/apex/22.2/htmdb/understanding-page-processes.html)

Patikrinkite, kad yra šie procesai (jei ne - sukurkite):

**Process: Initialize form** (Pre-Rendering sekcijoje)
- **Identification → Name:** `Initialize form Paciento duomenys`
- **Identification → Type:** `Form - Initialization`
- **Settings → Form Region:** Pasirinkite formą (pvz., `Paciento duomenys`)
- **Execution → Sequence:** `10`
- **Execution → Point:** `Before Regions`

**Process: Process form** (Processing sekcijoje → Processes)
- **Identification → Name:** `Process form Paciento duomenys`
- **Identification → Type:** `Form - Automatic Row Processing (DML)`
- **Settings → Form Region:** Pasirinkite formą
- **Settings → Lock Row:** `Yes` (apsauga nuo lost updates)
- **Success Message → Success Message:** `Paciento duomenys sėkmingai išsaugoti.`
- **Error → Error Message:** `Klaida: nepavyko išsaugoti paciento duomenų.`

> **SVARBU:** APEX 19.1+ versijose Form Region yra naujas regionų tipas. Senasis "Automatic Row Fetch" ir "Automatic Row Processing (DML)" procesų tipas yra deprecated. Naudokite "Form - Initialization" ir "Form - Automatic Row Processing (DML)" tipus.

#### Mygtukų konfigūravimas

> **Pagal Oracle APEX 22.1 dokumentaciją**, mygtuko nustatymai:
> - **Action: Submit Page** - pateikia puslapį su REQUEST reikšme lygia mygtuko vardui
> - **Hot:** `Yes` - mygtukas rodomas pabrėžtai (primary button stilius)
> - **Database Action** - nurodo kokią DML operaciją atlikti (naudojama su Form - Automatic Row Processing)
>
> Šaltinis: [Managing Buttons](https://docs.oracle.com/database/apex-18.1/HTMDB/creating-buttons.htm)

**Mygtukas SAVE (CREATE):**
- **Identification → Button Name:** `SAVE` arba `CREATE`
- **Identification → Label:** `Išsaugoti`
- **Layout → Position:** `Create` (arba `Change` priklausomai nuo šablono)
- **Behavior → Action:** `Submit Page`
- **Behavior → Execute Validations:** `Yes`
- **Behavior → Database Action:** `SQL INSERT action`
- **Appearance → Hot:** `Yes`
- **Server-side Condition → Type:** `Item is NULL`
- **Server-side Condition → Item:** `P6_PATIENT_ID` (rodomas tik kuriant naują įrašą)

**Mygtukas SAVE (UPDATE):**
- **Identification → Button Name:** `SAVE`
- **Identification → Label:** `Išsaugoti pakeitimus`
- **Behavior → Action:** `Submit Page`
- **Behavior → Database Action:** `SQL UPDATE action`
- **Appearance → Hot:** `Yes`
- **Server-side Condition → Type:** `Item is NOT NULL`
- **Server-side Condition → Item:** `P6_PATIENT_ID` (rodomas tik redaguojant)

**Mygtukas CANCEL:**
- **Identification → Button Name:** `CANCEL`
- **Identification → Label:** `Atšaukti`
- **Behavior → Action:** `Redirect to Page in this Application`
- **Behavior → Target → Page:** `5`
- **Behavior → Execute Validations:** `No`

**Mygtukas DELETE:**
- **Identification → Button Name:** `DELETE`
- **Identification → Label:** `Ištrinti`
- **Behavior → Action:** `Submit Page`
- **Behavior → Database Action:** `SQL DELETE action`
- **Behavior → Execute Validations:** `No`
- **Appearance → Hot:** `No`
- **Appearance → Template Options:** `Danger` (raudonas mygtukas)
- **Server-side Condition → Type:** `Item is NOT NULL`
- **Server-side Condition → Item:** `P6_PATIENT_ID`
- **Advanced → Confirmation Message:** `Ar tikrai norite ištrinti šį pacientą? Šis veiksmas negrįžtamas.`

> **SVARBU:** Database Action atributas nurodo **Form - Automatic Row Processing (DML)** procesui kokią operaciją atlikti. Jei naudojate tą patį SAVE mygtuką ir INSERT ir UPDATE operacijoms, nustatykite Database Action į `- Select -` ir procesas pats nustatys operacijos tipą pagal Primary Key reikšmę.

---

## 7. GYDYTOJŲ VALDYMO MODULIS

### 7.1 Gydytojų sąrašo puslapis (Page 7)

1. **Create Page** → **Interactive Report**
2. **Page Number:** `7`, **Page Name:** `Gydytojų sąrašas`
3. **SQL Query:**

```sql
SELECT
    doctor_id,
    full_name AS "Vardas, Pavardė",
    specialization AS "Specializacija",
    department_name AS "Skyrius",
    license_number AS "Licencijos Nr.",
    years_of_experience AS "Patirtis (m.)",
    consultation_fee AS "Konsult. kaina",
    email AS "El. paštas",
    phone_number AS "Telefonas",
    CASE available_for_emergency
        WHEN 'Y' THEN 'Taip'
        ELSE 'Ne'
    END AS "Skubi pagalba",
    today_appointments AS "Šiandien vizitų"
FROM v_doctors_full
WHERE (:P7_DEPARTMENT_ID IS NULL OR department_id = :P7_DEPARTMENT_ID)
```

4. Pridėkite filtrą **P7_DEPARTMENT_ID** (Select List su `SKYRIAI_LOV`)

---

## 8. VIZITŲ MODULIS SU KALENDORIUMI

### 8.1 Vizitų sąrašo puslapis (Page 10)

1. **Create Page** → **Interactive Report**
2. **Page Number:** `10`, **Page Name:** `Vizitų sąrašas`
3. **SQL Query:**

```sql
SELECT
    appointment_id,
    appointment_date AS "Data",
    appointment_time AS "Laikas",
    patient_name AS "Pacientas",
    doctor_name AS "Gydytojas",
    specialization AS "Specializacija",
    department_name AS "Skyrius",
    DECODE(appointment_type,
        'CHECKUP', 'Patikrinimas',
        'CONSULTATION', 'Konsultacija',
        'FOLLOWUP', 'Pakartotinis',
        'EMERGENCY', 'Skubus') AS "Tipas",
    DECODE(status,
        'SCHEDULED', 'Suplanuotas',
        'CONFIRMED', 'Patvirtintas',
        'COMPLETED', 'Įvykęs',
        'CANCELLED', 'Atšauktas',
        'NO_SHOW', 'Neatvyko') AS "Būsena",
    consultation_fee AS "Kaina"
FROM v_appointments_calendar
WHERE (:P10_DATE_FROM IS NULL OR appointment_date >= :P10_DATE_FROM)
AND (:P10_DATE_TO IS NULL OR appointment_date <= :P10_DATE_TO)
AND (:P10_DOCTOR_ID IS NULL OR doctor_id = :P10_DOCTOR_ID)
AND (:P10_STATUS IS NULL OR status = :P10_STATUS)
ORDER BY appointment_date DESC, appointment_time
```

4. Pridėkite filtrus:
   - **P10_DATE_FROM** - Date Picker (Label: `Nuo datos`)
   - **P10_DATE_TO** - Date Picker (Label: `Iki datos`)
   - **P10_DOCTOR_ID** - Select List su `GYDYTOJAI_LOV`
   - **P10_STATUS** - Select List su `VIZITO_BUSENA_LOV`

### 8.2 Vizitų kalendoriaus puslapis (Page 11)

#### Kalendoriaus puslapio sukūrimas

1. **Create Page** → **Component** → **Calendar**
2. Užpildykite:
   - **Page Number:** `11`
   - **Page Name:** `Vizitų kalendorius`
   - **Page Mode:** `Normal`
3. **Next**
4. **Navigation:** Prijunkite prie meniu
5. **Next**
6. **Source:**
   - **Table/View Name:** `V_APPOINTMENTS_CALENDAR`
7. Spauskite **Create Page**

#### Kalendoriaus konfigūravimas

> **Pagal Oracle APEX 22.1 dokumentaciją**, Kalendoriaus regionas reikalauja šių stulpelių:
> - **Primary Key** - unikalus įvykio identifikatorius
> - **Display Column** - tekstas rodomas kalendoriuje
> - **Start Date Column** - įvykio pradžios data/laikas (DATE arba TIMESTAMP tipas)
> - **End Date Column** - įvykio pabaigos data/laikas (neprivaloma)

1. Atidarykite Page 11 Page Designer
2. Pasirinkite **Calendar** regioną
3. **Source → SQL Query** (pakeiskite į):

```sql
SELECT
    appointment_id,
    -- Pradžios data: sujungiame datą ir laiką į vieną DATE reikšmę
    TO_DATE(TO_CHAR(appointment_date, 'YYYY-MM-DD') || ' ' || appointment_time,
            'YYYY-MM-DD HH24:MI') AS start_date,
    -- Pabaigos data: pridedame trukmę minutėmis naudojant NUMTODSINTERVAL
    TO_DATE(TO_CHAR(appointment_date, 'YYYY-MM-DD') || ' ' || appointment_time,
            'YYYY-MM-DD HH24:MI') + NUMTODSINTERVAL(duration_minutes, 'MINUTE') AS end_date,
    -- Rodomas tekstas
    patient_name || ' - ' || doctor_name AS title,
    -- Spalvinis kodavimas (naudojamas CSS klasės)
    status_color AS css_class,
    appointment_id AS pk_value
FROM v_appointments_calendar
WHERE (:P11_DOCTOR_ID IS NULL OR doctor_id = :P11_DOCTOR_ID)
AND (:P11_DEPARTMENT_ID IS NULL OR department_id = :P11_DEPARTMENT_ID)
```

> **Pastaba:** `NUMTODSINTERVAL(duration_minutes, 'MINUTE')` yra rekomenduojamas būdas pridėti minutės intervalu Oracle SQL. Alternatyva `+ (duration_minutes / 1440)` taip pat veikia (1440 = minučių per dieną).

4. **Attributes** sekcijoje (Property Editor):
   - **Identification → Static ID:** `vizitu_kalendorius` (naudinga JavaScript/Dynamic Actions)
   - **Settings → Primary Key Column:** `APPOINTMENT_ID`
   - **Settings → Display Column:** `TITLE`
   - **Settings → Start Date Column:** `START_DATE`
   - **Settings → End Date Column:** `END_DATE`
   - **Settings → CSS Class Column:** `CSS_CLASS` (jei norite spalvinio kodavimo)

5. **Settings → Drag and Drop:** `Yes`
6. **Settings → Create Link:** (kai vartotojas spaudžia tuščią vietą kalendoriuje)
   - **Target → Page:** `12`
   - **Set Items → Name:** `P12_APPOINTMENT_DATE`
   - **Set Items → Value:** `&APEX$NEW_START_DATE.`

> **APEX$NEW_START_DATE pastaba:** Kai vartotojas spaudžia ant tuščios kalendoriaus vietos, `&APEX$NEW_START_DATE.` grąžina pasirinktos datos/laiko reikšmę formatu `YYYYMMDDHH24MISS`.

#### Drag & Drop konfigūravimas

> **SVARBU pagal Oracle APEX 22.1 oficialią dokumentaciją:**
> Kalendoriaus drag & drop funkcionalumas naudoja šiuos specialius bind kintamuosius:
> - `:APEX$PK_VALUE` - perkėlamo įvykio pirminis raktas (Primary Key)
> - `:APEX$NEW_START_DATE` - nauja pradžios data
> - `:APEX$NEW_END_DATE` - nauja pabaigos data
>
> **Datos formatas BŪTINAI turi būti `YYYYMMDDHH24MISS` (14 simbolių, įskaitant sekundes).**
> Pavyzdžiui: `20251214143000` reiškia 2025-12-14 14:30:00
>
> Šaltinis: [Managing Calendar Attributes](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/managing-calendar-attributes.html)

1. **Attributes → Settings → Edit Link:**
   - **Target → Page:** `12`
   - **Set Items → Name:** `P12_APPOINTMENT_ID`
   - **Set Items → Value:** `&APPOINTMENT_ID.`

2. **Attributes → Settings → Drag and Drop:** `Yes`

3. **Attributes → Settings → Drag and Drop → PL/SQL Code:**

> **SVARBU pagal Oracle APEX 22.1:** Jei nustatytas **End Date Column**, PL/SQL kodas **PRIVALO** naudoti `:APEX$NEW_END_DATE` bind kintamąjį. Jei jo nenaudosite, gausite klaidą:
> ```
> ORA-20001: Unable to bind "APEX$NEW_END_DATE". Use double quotes for multi byte items or verify length of item is 30 bytes or less.
> ```

**Variantas A: Su End Date Column (rekomenduojama)**

Jei norite naudoti **End Date Column: `END_DATE`**, naudokite šį PL/SQL kodą:

```sql
DECLARE
    l_start_date DATE;
    l_end_date DATE;
    l_duration_minutes NUMBER;
BEGIN
    -- Konvertuoti datos formatu YYYYMMDDHH24MISS
    l_start_date := TO_DATE(:APEX$NEW_START_DATE, 'YYYYMMDDHH24MISS');
    l_end_date := TO_DATE(:APEX$NEW_END_DATE, 'YYYYMMDDHH24MISS');

    -- Apskaičiuoti trukmę minutėmis
    l_duration_minutes := ROUND((l_end_date - l_start_date) * 24 * 60);

    -- Atnaujinti vizito duomenis
    UPDATE appointments
    SET appointment_date = TRUNC(l_start_date),
        appointment_time = TO_CHAR(l_start_date, 'HH24:MI'),
        duration_minutes = GREATEST(l_duration_minutes, 15)  -- Minimali trukmė 15 min
    WHERE appointment_id = :APEX$PK_VALUE;
END;
```

**Variantas B: Be End Date Column**

Jei **nenorite** naudoti pabaigos datos, **išvalykite End Date Column** nustatymą:
- **Attributes → Settings → End Date Column:** `- Select -` (tuščias)

Tada galite naudoti paprastesnį PL/SQL kodą:

```sql
BEGIN
    -- Atnaujinti vizito datą ir laiką kai vartotojas perkelia įvykį kalendoriuje
    -- :APEX$NEW_START_DATE formatas yra YYYYMMDDHH24MISS (pvz., 20251214143000)
    UPDATE appointments
    SET appointment_date = TRUNC(TO_DATE(:APEX$NEW_START_DATE, 'YYYYMMDDHH24MISS')),
        appointment_time = TO_CHAR(TO_DATE(:APEX$NEW_START_DATE, 'YYYYMMDDHH24MISS'), 'HH24:MI')
    WHERE appointment_id = :APEX$PK_VALUE;
END;
```

> **Dažna klaida #1:** Jei nustatytas End Date Column bet PL/SQL kodas nenaudoja `:APEX$NEW_END_DATE` - gausite `ORA-20001` klaidą!
> **Dažna klaida #2:** Nenaudokite formato `YYYYMMDDHH24MI` (be sekundžių) - tai sukels klaidą!

#### Filtravimo laukų pridėjimas

Sukurkite regioną "Filtrai" virš kalendoriaus su:

- **P11_DOCTOR_ID** (Select List su `GYDYTOJAI_LOV`)
- **P11_DEPARTMENT_ID** (Select List su `SKYRIAI_LOV`)

Nustatykite **Page Items to Submit** kalendoriaus **Source** sekcijoje.

### 8.3 Vizito forma (Page 12)

1. **Create Page** → **Form** → **Form**
2. **Page Number:** `12`
3. **Page Name:** `Vizito duomenys`
4. **Page Mode:** `Modal Dialog`
5. **Table/View:** `APPOINTMENTS`
6. **Primary Key:** `APPOINTMENT_ID`

#### Laukų konfigūravimas

**P12_APPOINTMENT_ID:** Hidden

**P12_PATIENT_ID:**
- **Type:** `Popup LOV`
- **Label:** `Pacientas`
- **List of Values:** `PACIENTAI_LOV`
- **Value Required:** `Yes`

**P12_DOCTOR_ID:**
- **Type:** `Select List`
- **Label:** `Gydytojas`
- **List of Values:** `GYDYTOJAI_LOV`
- **Value Required:** `Yes`

**P12_APPOINTMENT_DATE:**
- **Type:** `Date Picker`
- **Label:** `Data`
- **Value Required:** `Yes`

**P12_APPOINTMENT_TIME:**
- **Type:** `Text Field`
- **Label:** `Laikas (HH:MI)`
- **Value Required:** `Yes`
- **Placeholder:** `14:30`

**P12_DURATION_MINUTES:**
- **Type:** `Number Field`
- **Label:** `Trukmė (min.)`
- **Default:** `30`

**P12_APPOINTMENT_TYPE:**
- **Type:** `Select List`
- **Label:** `Vizito tipas`
- **List of Values:** `VIZITO_TIPAS_LOV`
- **Value Required:** `Yes`

**P12_STATUS:**
- **Type:** `Select List`
- **Label:** `Būsena`
- **List of Values:** `VIZITO_BUSENA_LOV`
- **Default:** `SCHEDULED`

**P12_NOTES:**
- **Type:** `Textarea`
- **Label:** `Pastabos`

#### Laiko validacija

```sql
RETURN REGEXP_LIKE(:P12_APPOINTMENT_TIME, '^([01][0-9]|2[0-3]):[0-5][0-9]$');
```
Error: `Laikas turi būti formatu HH:MI (pvz., 14:30)`

---

## 9. HOSPITALIZACIJOS MASTER-DETAIL MODULIS

> **Pagal Oracle APEX 22.1 dokumentaciją** Master-Detail formos tipai:
> - **Stacked** - Master ir Detail regionai vienas po kito
> - **Drill Down** - Master sąrašas su nuoroda į atskirą Detail puslapį
> - **Side by Side** - Kairėje pusėje master navigacija, dešinėje - master forma ir detail regionai
>
> Šaltinis: [Creating Master Detail Forms](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/managing-master-detail-forms.html)

### 9.1 Master-Detail puslapio sukūrimas (Page 15)

#### Puslapio sukūrimas per Wizard

1. **Create Page**
2. **Page Type:** `Component`
3. Pasirinkite **Master Detail**
4. Pasirinkite formatą:
   - **Side by Side** - rekomenduojama hospitalizacijos moduliui (kairėje - priėmimų sąrašas, dešinėje - detalės)
5. **Next**
6. **Page Attributes:**
   - **Page Number:** `15`
   - **Page Name:** `Paciento hospitalizacija`
   - **Page Mode:** `Normal`
7. **Next**
8. **Navigation:** Prijunkite prie meniu "Aktyvūs priėmimai"
9. **Next**
10. **Master Source:**
    - **Data Source:** `Local Database`
    - **Table/View:** `ADMISSIONS`
    - **Primary Key Column 1:** `ADMISSION_ID`
11. **Next**
12. **Detail Tables:**

> **SVARBU:** Pasirinkite **Show Only Related Tables** `No`, kad matytumėte visas lenteles.
> Detail lentelės turi turėti Foreign Key ryšį su Master lentele arba galite nurodyti ryšio stulpelį rankiniu būdu.

**Mūsų scenarijus:** ADMISSIONS lentelė turi `PATIENT_ID` ir `ADMISSION_ID`. Detail lentelės:
- **PATIENT_DIAGNOSES** - siejama per `PATIENT_ID` (paciento diagnozės)
- **PRESCRIPTIONS** - siejama per `PATIENT_ID` (paciento receptai)
- **LAB_TESTS** - siejama per `PATIENT_ID` (paciento tyrimai)
- **BILLS** - siejama per `ADMISSION_ID` (priėmimo sąskaitos) **arba** `PATIENT_ID`

**Detail lentelių pridėjimas:**
| Detail Table | Foreign Key Column | Master Relationship |
|--------------|-------------------|---------------------|
| PATIENT_DIAGNOSES | PATIENT_ID | Ryšys per ADMISSIONS.PATIENT_ID |
| PRESCRIPTIONS | PATIENT_ID | Ryšys per ADMISSIONS.PATIENT_ID |
| LAB_TESTS | PATIENT_ID | Ryšys per ADMISSIONS.PATIENT_ID |
| BILLS | ADMISSION_ID | Tiesioginis ryšys su ADMISSIONS.ADMISSION_ID |

13. Spauskite **Create Page**

> **Pastaba:** Jei nematote norimos detail lentelės, įsitikinkite kad **Show Only Related Tables** yra `No` arba patikrinkite ar lentelėje yra Foreign Key į master lentelę.

#### Master formos konfigūravimas

Atidarykite Page 15 ir konfigūruokite laukus:

**P15_ADMISSION_ID:** Hidden

**P15_PATIENT_ID:**
- **Type:** `Popup LOV`
- **Label:** `Pacientas`
- **List of Values:** `PACIENTAI_LOV`
- **Value Required:** `Yes`

**P15_DEPARTMENT_ID:** (Papildomas laukas filtrui)
- **Type:** `Select List`
- **Label:** `Skyrius`
- **List of Values:** `SKYRIAI_LOV`
- **Value Required:** `Yes`

**P15_BED_ID:**
- **Type:** `Select List`
- **Label:** `Lova`
- **List of Values → Type:** `SQL Query`
- **SQL Query:**
```sql
SELECT r.room_number || ' - Lova ' || b.bed_number AS d,
       b.bed_id AS r
FROM beds b
JOIN rooms r ON b.room_id = r.room_id
WHERE b.bed_status = 'AVAILABLE'
AND r.department_id = :P15_DEPARTMENT_ID
ORDER BY r.room_number, b.bed_number
```
- **Cascading LOV Parent Item(s):** `P15_DEPARTMENT_ID`
- **Value Required:** `Yes`

**P15_ADMITTING_DOCTOR_ID:**
- **Type:** `Select List`
- **Label:** `Gydytojas`
- **List of Values → SQL Query:**
```sql
SELECT e.first_name || ' ' || e.last_name AS d,
       d.doctor_id AS r
FROM doctors d
JOIN employees e ON d.doctor_id = e.employee_id
WHERE d.department_id = :P15_DEPARTMENT_ID
AND e.employment_status = 'ACTIVE'
ORDER BY e.last_name
```
- **Cascading LOV Parent Item(s):** `P15_DEPARTMENT_ID`

**P15_ADMISSION_DATE:**
- **Type:** `Date Picker`
- **Label:** `Priėmimo data`
- **Default:** `&APP_SYSDATE.`

**P15_DISCHARGE_DATE:**
- **Type:** `Date Picker`
- **Label:** `Išrašymo data`

**P15_ADMISSION_TYPE:**
- **Type:** `Select List`
- **Label:** `Priėmimo tipas`
- **List of Values:** `PRIEMIMO_TIPAS_LOV`

**P15_ADMISSION_REASON:**
- **Type:** `Textarea`
- **Label:** `Priėmimo priežastis`
- **Value Required:** `Yes`

**P15_STATUS:**
- **Type:** `Select List`
- **Label:** `Būsena`
- **Static Values:**
  - Priimtas / ADMITTED
  - Išrašytas / DISCHARGED
  - Perkeltas / TRANSFERRED

#### Cascading LOV Dynamic Action

1. **Dynamic Actions** skydelyje spauskite **Create Dynamic Action**
2. **Name:** `Refresh BED and DOCTOR on Department Change`
3. **Event:** `Change`
4. **Selection Type:** `Item(s)`
5. **Item(s):** `P15_DEPARTMENT_ID`

**True Action 1:**
- **Action:** `Refresh`
- **Selection Type:** `Item(s)`
- **Item(s):** `P15_BED_ID`

**True Action 2:**
- **Action:** `Refresh`
- **Selection Type:** `Item(s)`
- **Item(s):** `P15_ADMITTING_DOCTOR_ID`

---

## 10. VAISTŲ IR RECEPTŲ MODULIS

### 10.1 Vaistų katalogas (Page 20)

1. **Create Page** → **Interactive Report**
2. **Page Number:** `20`
3. **SQL Query:**

```sql
SELECT
    medication_id,
    medication_name AS "Vaisto pavadinimas",
    generic_name AS "Generinis pavadinimas",
    manufacturer AS "Gamintojas",
    category AS "Kategorija",
    DECODE(dosage_form,
        'TABLET', 'Tabletė',
        'CAPSULE', 'Kapsulė',
        'INJECTION', 'Injekcija',
        'SYRUP', 'Sirupas',
        dosage_form) AS "Forma",
    strength AS "Stiprumas",
    unit_price AS "Vnt. kaina (€)",
    stock_quantity AS "Atsargos",
    minimum_stock_level AS "Min. atsargos",
    CASE WHEN stock_quantity <= minimum_stock_level
         THEN 'MAŽAI!'
         ELSE 'OK'
    END AS "Atsargų būsena",
    DECODE(requires_prescription, 'Y', 'Taip', 'Ne') AS "Receptinis"
FROM medications
WHERE (:P20_CATEGORY IS NULL OR category = :P20_CATEGORY)
AND (:P20_LOW_STOCK = 'Y' AND stock_quantity <= minimum_stock_level
     OR :P20_LOW_STOCK IS NULL OR :P20_LOW_STOCK = 'N')
```

### 10.2 Recepto forma (Page 22)

Laukai:

- **P22_PATIENT_ID** - Popup LOV (PACIENTAI_LOV)
- **P22_DOCTOR_ID** - Select List (GYDYTOJAI_LOV)
- **P22_MEDICATION_ID** - Popup LOV (VAISTAI_LOV)
- **P22_PRESCRIPTION_DATE** - Date Picker
- **P22_DOSAGE** - Text Field (Label: `Dozė`)
- **P22_FREQUENCY** - Text Field (Label: `Dažnumas`)
- **P22_DURATION_DAYS** - Number Field (Label: `Trukmė dienomis`)
- **P22_QUANTITY** - Number Field (Label: `Kiekis`)
- **P22_INSTRUCTIONS** - Textarea (Label: `Instrukcijos`)

---

## 11. LABORATORINIŲ TYRIMŲ MODULIS

### 11.1 Tyrimų sąrašas (Page 23)

```sql
SELECT
    lab_test_id,
    test_date AS "Data",
    test_time AS "Laikas",
    patient_name AS "Pacientas",
    DECODE(test_type,
        'BLOOD', 'Kraujo tyrimas',
        'URINE', 'Šlapimo tyrimas',
        'XRAY', 'Rentgenas',
        'MRI', 'MRT',
        'CT_SCAN', 'KT',
        'ULTRASOUND', 'Echoskopija',
        'ECG', 'EKG',
        test_type) AS "Tyrimo tipas",
    doctor_name AS "Gydytojas",
    status_lt AS "Būsena",
    cost AS "Kaina (€)"
FROM v_lab_tests_full
ORDER BY test_date DESC
```

---

## 12. SĄSKAITŲ MODULIS

### 12.1 Sąskaitų sąrašas (Page 30)

```sql
SELECT
    bill_id,
    bill_date AS "Sąskaitos data",
    patient_name AS "Pacientas",
    bill_source AS "Šaltinis",
    total_amount AS "Suma (€)",
    paid_amount AS "Apmokėta (€)",
    balance AS "Likutis (€)",
    due_date AS "Mokėjimo terminas",
    payment_status_lt AS "Būsena",
    days_overdue AS "Vėluojama dienų"
FROM v_bills_detailed
WHERE (:P30_STATUS IS NULL OR payment_status = :P30_STATUS)
ORDER BY
    CASE payment_status
        WHEN 'OVERDUE' THEN 1
        WHEN 'UNPAID' THEN 2
        WHEN 'PARTIAL' THEN 3
        ELSE 4
    END
```

#### Spalvinis kodavimas

Interactive Report → Columns → **Būsena** → **Column Formatting → HTML Expression:**

```html
<span style="
    padding: 4px 8px;
    border-radius: 4px;
    background-color:
        #CASE PAYMENT_STATUS#
            WHEN 'PAID' THEN 'green'
            WHEN 'PARTIAL' THEN 'orange'
            WHEN 'UNPAID' THEN 'gray'
            WHEN 'OVERDUE' THEN 'red'
        #END#;
    color: white;">
    #PAYMENT_STATUS_LT#
</span>
```

---

## 13. SKYRIŲ IR LOVŲ VALDYMAS

### 13.1 Lovų užimtumo vaizdas (Page 27) - Cards

1. **Create Page** → **Blank Page**
2. **Page Number:** `27`
3. **Page Name:** `Lovų užimtumas`
4. **Create Region:**
   - **Type:** `Cards`
   - **Title:** `Lovų užimtumas`

5. **Source → SQL Query:**

```sql
SELECT
    bed_id,
    room_number || '-' || bed_number AS title,
    department_name || ' | ' ||
    DECODE(room_type,
        'PRIVATE', 'Vienvietė',
        'SEMI_PRIVATE', 'Dvivietė',
        'ICU', 'Intensyvi priežiūra',
        room_type) AS subtitle,
    CASE bed_status
        WHEN 'AVAILABLE' THEN 'Laisva'
        WHEN 'OCCUPIED' THEN 'Užimta: ' || NVL(patient_name, '-')
        WHEN 'MAINTENANCE' THEN 'Remontuojama'
        WHEN 'RESERVED' THEN 'Rezervuota'
    END AS body,
    CASE bed_status
        WHEN 'AVAILABLE' THEN 'a-CardView-card--success'
        WHEN 'OCCUPIED' THEN 'a-CardView-card--danger'
        WHEN 'MAINTENANCE' THEN 'a-CardView-card--warning'
        WHEN 'RESERVED' THEN 'a-CardView-card--info'
    END AS card_modifiers
FROM v_beds_occupancy
WHERE (:P27_DEPARTMENT_ID IS NULL OR department_id = :P27_DEPARTMENT_ID)
ORDER BY department_name, room_number, bed_number
```

6. **Attributes** sekcijoje (Property Editor):

> **Pagal Oracle APEX 22.1 dokumentaciją**, Cards regiono atributai:
> - **Primary Key Column** - privalomas, naudojamas identifikuoti kiekvieną kortelę
> - **Title, Subtitle, Body** - rodoma informacija kortelėje
> - **CSS Classes Column** - leidžia dinamiškai keisti kortelės stilių
>
> Šaltinis: [Editing Cards Region Attributes](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/editing-cards-region-attributes.html)

   - **Card → Primary Key Column 1:** `BED_ID`
   - **Title → Column:** `TITLE`
   - **Subtitle → Column:** `SUBTITLE`
   - **Body → Column:** `BODY`
   - **Appearance → Card CSS Classes Column:** `CARD_MODIFIERS`
   - **Appearance → Layout:** `Grid` (arba `Float` priklausomai nuo dizaino)

> **Pastaba apie CSS klases:** APEX Universal Theme palaiko šias kortelių klases:
> - `a-CardView-card--success` - žalia (laisva lova)
> - `a-CardView-card--danger` - raudona (užimta lova)
> - `a-CardView-card--warning` - oranžinė (remontuojama)
> - `a-CardView-card--info` - mėlyna (rezervuota)

---

## 14. TESTAVIMO INSTRUKCIJOS

### 14.1 Funkcionalumo testavimo scenarijai

#### Testas 1: Pacientų valdymas
| # | Veiksmas | Tikėtinas rezultatas |
|---|----------|---------------------|
| 1 | Sukurti naują pacientą | Pacientas išsaugomas, matomas sąraše |
| 2 | Įvesti blogą el. paštą | Rodoma klaida "Neteisingas el. pašto formatas" |
| 3 | Įvesti ateities gimimo datą | Rodoma klaida "Gimimo data negali būti ateityje" |
| 4 | Redaguoti esamą pacientą | Pakeitimai išsaugomi |
| 5 | Ištrinti pacientą | Pacientas ištrinamas po patvirtinimo |
| 6 | Filtruoti pagal kraujo grupę | Rodomi tik atitinkami pacientai |

#### Testas 2: Vizitų kalendorius
| # | Veiksmas | Tikėtinas rezultatas |
|---|----------|---------------------|
| 1 | Sukurti naują vizitą | Vizitas matomas kalendoriuje |
| 2 | Perkelti vizitą vilkimu | Data atnaujinama duomenų bazėje |
| 3 | Spausti ant vizito | Atidaroma redagavimo forma |
| 4 | Filtruoti pagal gydytoją | Rodomi tik to gydytojo vizitai |

#### Testas 3: Master-Detail (Hospitalizacija)
| # | Veiksmas | Tikėtinas rezultatas |
|---|----------|---------------------|
| 1 | Pasirinkti skyrių | LOV "Lova" ir "Gydytojas" atnaujinami |
| 2 | Sukurti naują priėmimą | Priėmimas išsaugomas |
| 3 | Peržiūrėti detail tabs | Matomos diagnozės, receptai, tyrimai, sąskaitos |
| 4 | Pridėti diagnozę | Diagnozė išsaugoma ir matoma sąraše |

#### Testas 4: LOV funkcionalumas
| # | Veiksmas | Tikėtinas rezultatas |
|---|----------|---------------------|
| 1 | Atidaryti statinį LOV (Lytis) | Rodomi: Vyras, Moteris, Kita |
| 2 | Atidaryti dinaminį LOV (Skyriai) | Rodomi aktyvūs skyriai iš DB |
| 3 | Kaskadinis LOV: pakeisti skyrių | Lovos ir gydytojai atnaujinami pagal skyrių |

#### Testas 5: Validacijos ir klaidos
| # | Veiksmas | Tikėtinas rezultatas |
|---|----------|---------------------|
| 1 | Palikti privalomą lauką tuščią | Rodoma klaida "Šis laukas yra privalomas" |
| 2 | Įvesti per ilgą tekstą | Rodoma klaida apie maksimalų ilgį |
| 3 | Bandyti ištrinti susietą įrašą | Rodoma FK constraint klaida |

---

## PRIEDAS: PUSLAPIŲ SĄRAŠAS

| Puslapis | Nr. | Tipas | Aprašymas |
|----------|-----|-------|-----------|
| Pagrindinis | 1 | Dashboard | Statistika, šiandienos vizitai |
| Pacientų sąrašas | 5 | Interactive Report | Filtrai, paieška |
| Paciento forma | 6 | Modal Form | CRUD operacijos |
| Gydytojų sąrašas | 7 | Interactive Report | Su skyrių filtru |
| Med. seserų sąrašas | 8 | Interactive Report | - |
| Vizitų sąrašas | 10 | Interactive Report | Datų, statuso filtrai |
| Vizitų kalendorius | 11 | Calendar | Drag & drop |
| Vizito forma | 12 | Modal Form | - |
| Hospitalizacija | 15 | Master-Detail | Side by Side |
| Priėmimų istorija | 16 | Interactive Report | - |
| Naujas priėmimas | 17 | Form Wizard | - |
| Vaistų katalogas | 20 | Interactive Report | Atsargų kontrolė |
| Receptai | 21 | Interactive Report | - |
| Recepto forma | 22 | Modal Form | - |
| Lab tyrimai | 23 | Interactive Report | - |
| Lab tyrimo forma | 24 | Modal Form | - |
| Skyriai | 25 | Interactive Report | - |
| Palatai | 26 | Interactive Report | - |
| Lovų užimtumas | 27 | Cards | Vizualus vaizdas |
| Sąskaitos | 30 | Interactive Report | Spalvinis kodavimas |
| Sąskaitos forma | 31 | Modal Form | Mokėjimo registravimas |

---

## ŠALTINIAI

### Oficiali Oracle APEX 22.1 Dokumentacija

- [Oracle APEX 22.1 - Creating Lists of Values](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/creating-lists-of-values-at-the-application-level.html) - LOV kūrimas
- [Oracle APEX 22.1 - Creating Master Detail Forms](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/managing-master-detail-forms.html) - Master-Detail formos
- [Oracle APEX 22.1 - Managing Calendar Attributes](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/managing-calendar-attributes.html) - Kalendorius ir Drag & Drop
- [Oracle APEX 22.1 - Understanding Validations](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/understanding-validations.html) - Validacijos
- [Oracle APEX 22.1 - Using Interactive Report Filters](https://docs.oracle.com/en/database/oracle/apex/22.1/aeeug/using-interactive-report-filters.html) - IR filtravimas
- [Oracle APEX 22.1 - Editing Cards Region Attributes](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/editing-cards-region-attributes.html) - Cards regionas
- [Oracle APEX 22.1 - Using Actions to Link from Cards Page](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/using-actions-to-link-from-cards-page.html) - Cards nuorodos
- [Oracle APEX 22.1 - Understanding Page Processes](https://docs.oracle.com/en/database/oracle/apex/22.2/htmdb/understanding-page-processes.html) - Form procesai
- [Oracle APEX 22.1 - Linking to Interactive Reports](https://docs.oracle.com/en/database/oracle/apex/22.1/htmdb/linking-to-interactive-reports.html) - IR nuorodos
- [Oracle APEX 22.1 - Managing Buttons](https://docs.oracle.com/database/apex-18.1/HTMDB/creating-buttons.htm) - Mygtukai

### Oracle APEX Blog ir Bendruomenė

- [Beginners Guide to List of Values in Oracle APEX](https://blogs.oracle.com/apex/beginners-guide-to-list-of-values-in-oracle-apex) - LOV pradedantiesiems
- [A Simple Guide to the New Cards Region in APEX 20.2](https://blogs.oracle.com/apex/a-simple-guide-to-the-new-cards-region-in-apex-202) - Cards regionas
- [Universal Theme](https://apex.oracle.com/pls/apex/r/apex_pm/ut/) - APEX stiliai ir šablonai

### Papildomi šaltiniai

- [Oracle APEX 22.1 Release Notes](https://apex.oracle.com/en/learn/documentation/release-notes/) - Versijos naujovės
- [Oracle APEX Community](https://forums.oracle.com/ords/apexds/domain/dev-community) - Bendruomenės forumas

---

*Dokumentas sukurtas: 2025-12-14*
*Dokumentas atnaujintas: 2025-12-14 (pataisytos klaidos pagal oficialią Oracle APEX 22.1.0 dokumentaciją)*
*Oracle APEX versija: 22.1.0*

### Atnaujinimų istorija

| Data | Pakeitimai |
|------|-----------|
| 2025-12-14 | Pirminė versija |
| 2025-12-14 | Pataisytas Calendar Drag & Drop datos formatas (YYYYMMDDHH24MISS) |
| 2025-12-14 | Pataisyta Date Picker Minimum/Maximum Date konfigūracija |
| 2025-12-14 | Pataisyta Cards Action konfigūracija su Link Builder |
| 2025-12-14 | Pataisyta Form Process konfigūracija (Form - Initialization, Form - Automatic Row Processing) |
| 2025-12-14 | Pridėta išsami Cascading LOV dokumentacija |
| 2025-12-14 | Pataisyta Master-Detail detail lentelių konfigūracija |
| 2025-12-14 | Pridėta Page Items to Submit paaiškinimas |
| 2025-12-14 | Pataisyta validacijų konfigūracija |
| 2025-12-14 | Pataisyta mygtukų (Buttons) konfigūracija su Database Action |
| 2025-12-14 | Pridėtos nuorodos į oficialią Oracle APEX 22.1 dokumentaciją |
| 2025-12-16 | Pataisytas Calendar Drag & Drop - pridėtas APEX$NEW_END_DATE klaidos sprendimas (ORA-20001) |
| 2025-12-16 | Pataisytos validacijos - pridėta BEGIN/END blokas, When Button Pressed, Always Execute nustatymai |
