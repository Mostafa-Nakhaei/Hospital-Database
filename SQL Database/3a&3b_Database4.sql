DROP DATABASE IF EXISTS `final_Project`;
CREATE DATABASE `final_Project`; 
USE `final_Project`;

CREATE TABLE Patients(
	patient_ID char(5),
	PRIMARY KEY (patient_ID)
);

CREATE TABLE InPatients(
	patient_ID char(5),
	firstname varchar(20),
	lastname varchar(20),
	insurance varchar(20), 
	emergency_contact varchar(20) NOT NULL, -- a patient must 
    emergency_cell VARCHAR(12) NOT NULL,
	PRIMARY KEY (patient_ID),
	FOREIGN KEY (patient_ID) REFERENCES patients(patient_ID)
);

CREATE TABLE OutPatients( 
	patient_ID char(5),
	firstname varchar(20),
	lastname varchar(20),
	insurance varchar(20), 
	emergency_contact varchar(20),
    emergency_cell VARCHAR(12),
	PRIMARY KEY (patient_ID),
	FOREIGN KEY (patient_ID) REFERENCES patients(patient_ID)
);

CREATE TABLE Administrator(
	emp_ID char(5),
	lastname varchar(20), 
	firstname varchar(20),
	dob date,
	PRIMARY KEY (emp_ID)
);

CREATE TABLE admitted_Patients( -- a particular patient can come in different time period, thus the primary key should be the combination of patient_ID and admit time
	patient_ID char(5),
	admit_Time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	discharge_Time DATETIME DEFAULT NULL, 			-- discharge time is NULL for outpatient
    emp_ID char(5),
    type char(1), 								-- "I" for inpatient, "O" for Outpatient
	PRIMARY KEY (patient_ID, admit_Time), 		-- this gives a unique identifier
	FOREIGN KEY (patient_ID) REFERENCES patients(patient_ID),
	FOREIGN KEY (emp_ID) REFERENCES Administrator(emp_ID) -- who dicharged the inpatient
);

CREATE TABLE technician_nurse_doctor ( -- those who can adminstar treatment
	ADMIN_id char(5),
	PRIMARY KEY (ADMIN_id)
);

CREATE TABLE Hospital_Treatment_List(
	Hospital_Treatment_List_ID char(5),
    treatment_name varchar(20),
	Treatment_medication varchar(20),
	Treatment_procedure varchar(20),
	PRIMARY KEY (Hospital_Treatment_List_ID)
);

CREATE TABLE Treatment(
	treatment_ID char(5),
    Hospital_Treatment_List_ID char(5),
	ADMIN_id char(5) NOT NULL, -- every treatment should be administered by eaither Dr, Nurse, or Technican
    time_stamp DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
	PRIMARY KEY (treatment_ID),
    FOREIGN KEY (ADMIN_id) REFERENCES technician_nurse_doctor(ADMIN_id),
    FOREIGN KEY (Hospital_Treatment_List_ID) REFERENCES Hospital_Treatment_List(Hospital_Treatment_List_ID)
);

CREATE TABLE Doctor(
	emp_ID char(5),
	lastname varchar(20), 
	firstname varchar(20),
	dob date,
	ADMIN_id char(5) REFERENCES technician_nurse_doctor(ADMIN_id),
	PRIMARY KEY (emp_ID)
);

CREATE TABLE AdmitDoctor(
	emp_ID char(5),
	PRIMARY KEY (emp_ID),
	FOREIGN KEY (emp_ID) REFERENCES Doctor(emp_ID)
);

CREATE TABLE Nurse(
	emp_ID char(5),
	lastname varchar(20), 
	firstname varchar(20),
	dob date,
    ADMIN_id char(5) REFERENCES technician_nurse_doctor(ADMIN_id),
	PRIMARY KEY (emp_ID)
);

CREATE TABLE Technician (
	emp_ID char(5),
	lastname varchar(20), 
	firstname varchar(20),
	dob date,
    ADMIN_id char(5) REFERENCES technician_nurse_doctor(ADMIN_id),
	PRIMARY KEY (emp_ID)
);

CREATE TABLE DTO_ternary( -- ternary relationship, out patients and doctor, treatments should be enforced
	treatment_ID char(5),
	emp_ID char(5) NOT NULL, -- a patient must have a doctor
    patient_ID char(5),
	PRIMARY KEY (treatment_ID, emp_ID, patient_ID),
	FOREIGN KEY (emp_ID) REFERENCES Doctor(emp_ID),
	FOREIGN KEY (patient_ID) REFERENCES outPatients(patient_ID),
    FOREIGN KEY (treatment_ID) REFERENCES treatment(treatment_ID)
);

CREATE TABLE ATI_ternary( -- ternary relationship, inpatients and doctor, treatments should be enforced
	treatment_ID char(5),
	emp_ID char(5) NOT NULL,
    patient_ID char(5),
	PRIMARY KEY (treatment_ID, emp_ID, patient_ID),
	FOREIGN KEY (emp_ID) REFERENCES AdmitDoctor(emp_ID),
	FOREIGN KEY (patient_ID) REFERENCES inpatients(patient_ID),
    FOREIGN KEY (treatment_ID) REFERENCES treatment(treatment_ID)
);

INSERT INTO Patients VALUES
('IP001'),
('IP002'),
('IP003'),
('IP004'),
('IP005'),
('IP006'),
('OP001'),
('OP002'),
('OP003'),
('OP004'),
('OP005'),
('OP006');

DELETE FROM InPatients
where patient_id in ('IP001', 'IP002', 'IP003', 'IP004', 'IP005');
INSERT INTO InPatients VALUES
('IP001', 'Jessica', 'Kataif', 'State_form', 'Eric Katiaf','334-663-2455' ),
('IP002', 'Miranda', 'Cuddy', 'Geico', 'Jessica Cuddy', '334-673-2255'),
('IP003', 'Grey', 'Jordan', 'Progressive', 'Kevin Jordan','334-698-2335'),
('IP004', 'James', 'Brown', 'SP Insurance', 'Lebron Brown', '334-763-2488'),
('IP005', 'George', 'White', 'SP Insurance', 'Betty White', '334-683-2555'),
('IP006', 'George', 'Jordan', 'Geico', 'Betty Jordan', '334-673-2785');

DELETE FROM outPatients
WHERE patient_id IN ('OP001', 'OP002', 'OP003', 'OP004', 'OP005', 'OP006');
INSERT INTO OutPatients VALUES
('OP001', 'Ian', 'Gallager', 'State_form', 'Lisa Gallager', '334-663-2885'),
('OP002', 'Micheal', 'Jordan', 'Geico', 'Jessica Jordan', '334-673-2495'),
('OP003', 'Frank', 'Anderson', 'Progressive', 'Robert Katiaf', '334-693-6455'),
('OP004', 'Larry', 'Brown', 'SP Insurance', 'Allison Anderson', '334-636-5455'),
('OP005', 'Megan', 'Pace', 'SP Insurance', 'Meredith Pace','334-655-6775'),
('OP006', 'Micheal', 'Anderson', 'Geico', 'Jessica Anderson', '334-678-8995');

INSERT INTO Administrator VALUES
('ADM01', 'Chase', 'Robert', '1984/05/04'),
('ADM02', 'Foreman', 'Eric', '1999/08/01');

INSERT INTO admitted_Patients VALUES
('IP001', '2019-03-03 00:00:00', '2019-03-09 00:00:00', 'ADM01', 'I'), -- 'AD001' is the discharge administrator, default is NULL for outpatient
('IP001', '2019-06-03 00:00:00', '2019-07-09 00:00:00', 'ADM02', 'I'), -- patient "IP001" is admited twice in two different period
('IP002', '2019-04-03 00:00:00', '2019-04-05 00:00:00', 'ADM01', 'I'),
('IP003', '2019-05-03 00:00:00', '2019-05-04 00:00:00', 'ADM02', 'I'),
('IP004', '2019-06-03 00:00:00', '2019-06-06 00:00:00', 'ADM02', 'I'),
('IP005', default, default, NULL, 'I'), -- default for admision is current time and for discharge is NULL
('IP006', default, default, NULL, 'I'), 
('OP001', '2019-03-03 00:00:00', Null, NULL, 'O'), -- there is no discharge date for outpatients (they don't stay so discharge date is the same as admit date),
('OP002', '2019-04-03 00:00:00', Null, NULL, 'O'),
('OP003', '2019-05-03 00:00:00', Null, NULL, 'O'),
('OP004', '2019-06-03 00:00:00', Null, NULL, 'O'),
('OP005', '2019-06-03 00:00:00', Null, NULL, 'O'),
('OP006', '2019-06-03 00:00:00', Null, NULL, 'O');

INSERT INTO technician_nurse_doctor VALUES
('AD001'), 
('AD002'),
('AD003'), 
('AD004'),
('AD005'),
('AD006'),
('AD007'),
('AD008'),
('AD009'),
('AD010'), 
('AD011'),
('AD012'),
('AD013'),
('AD014'),
('AD015'),
('AD016'),
('AD017'),
('AD018');

DELETE FROM Treatment
WHERE treatment_ID IN ('TR001', 'TR002', 'TR003', 'TR004', 'TR005', 'TR006',  'TR007', 'TR008', 'TR009', 'TR010', 'TR011',
						'TR012', 'TR013', 'TR014', 'TR015', 'TR016', 'TR017', 'TR018', 'TR019');


INSERT INTO Hospital_Treatment_List VALUES
('HTL01', 'Abortion','Medication_1' ,'Procedure_1'),
('HTL02', 'MRI','Medication_1' ,'Procedure_1'),
('HTL03', 'Pregnancy Test','Medication_1' ,'Procedure_1'),
('HTL04', 'Transplant','Medication_1' ,'Procedure_1'),
('HTL05', 'Chemotheropy','Medication_1' ,'Procedure_1'),
('HTL06', 'Heart Miopothy','Medication_1' ,'Procedure_1'),
('HTL07', 'Physical Therapy','Medication_1' ,'Procedure_1'),
('HTL08', 'Blood Test','Medication_1' ,'Procedure_1')
;

INSERT INTO Treatment VALUES
('TR001',  'HTL01', 'AD001', '2019-03-02'),
('TR002', 'HTL01', 'AD001',  '2019-03-03'),
('TR003', 'HTL02', 'AD005',  '2019-03-05'),
('TR004',  'HTL08', 'AD001', '2019-03-08'),
('TR005',  'HTL05', 'AD001', '2019-06-05'),
('TR006',  'HTL03', 'AD003', '2019-06-06'),
('TR007',  'HTL06', 'AD002', '2019-07-03'),
('TR008',  'HTL03', 'AD001', '2019-07-04'),
('TR009',  'HTL03', 'AD001','2019-09-02'),
('TR010',  'HTL04', 'AD015', '2020-06-08'),
('TR011',  'HTL08', 'AD009', '2020-08-02'),
('TR012',  'HTL01', 'AD001', '2020-03-07'),
('TR013',  'HTL08', 'AD001', '2020-03-02'),
('TR014',  'HTL06', 'AD001', '2019-08-02'),
('TR015', 'HTL02', 'AD001', '2019-08-02'),
('TR016', 'HTL06', 'AD001', '2019-05-02'),
('TR017', 'HTL07', 'AD005', '2019-04-03'),
('TR018',  'HTL08', 'AD002', '2019-08-02'),
('TR019', 'HTL01', 'AD003', '2019-08-02');

INSERT INTO Doctor VALUES
('Dr001', 'Bird', 'Jalali', '1987/04/04', 'AD001'),
('Dr002', 'Schrute', 'Larry', '1954/02/03', 'AD002'),
('Dr003', 'Wilson', 'Meredith', '1963/08/03', 'AD003'),
('Dr004', 'Bailey', 'Miranda', '1990/02/03', 'AD004'),
('Dr005', 'Bird', 'Derek', '1987/03/04', 'AD005'),
('DrA01', 'Jackson', 'Lebron', '1987/03/04', 'AD006'),
('DrA02', 'Jordan', 'Allison', '1988/06/04', 'AD007');

INSERT INTO AdmitDoctor VALUES
('DrA01'),
('DrA02');

INSERT INTO Nurse VALUES
('NU001', 'Schrute', 'Dwight', '1984/05/04', 'AD010'),
('NU002', 'James', 'Jackson', '1979/09/01', 'AD011'),
('NU003', 'Michael', 'Love', '1979/07/08', 'AD012'),
('NU004', 'Sean', 'Larry', '1979/09/01', 'AD013');

INSERT INTO Technician VALUES
('TC001', 'David', 'Alonso', '1984/05/04', 'AD014'),
('TC002', 'Ian', 'Jackson', '1988/04/01', 'AD015'),
('TC003', 'Tigger', 'Lepin', '1989/03/07', 'AD016'),
('TC004', 'Philip', 'White', '1973/09/01', 'AD017');

INSERT INTO DTO_ternary VALUES
('TR010', 'Dr001', 'OP001'),
('TR011', 'Dr002', 'OP002'),
('TR013', 'Dr003', 'OP003'),
('TR015', 'Dr004', 'OP004'),
('TR016', 'DrA02', 'OP005'),
('TR017', 'DrA02', 'OP006'),
('TR001', 'DrA02', 'OP006');

INSERT INTO ATI_ternary VALUES
('TR002', 'DrA02', 'IP001'), -- patient 1: recieves multiple treatment in hospital
('TR003', 'DrA01', 'IP001'),
('TR004', 'DrA02', 'IP001'),
('TR005', 'DrA02', 'IP001'),
('TR006', 'DrA02', 'IP001'),
('TR007', 'DrA02', 'IP002'),
('TR008', 'DrA01', 'IP003'),
('TR009', 'DrA01', 'IP004'),
('TR012', 'DrA01', 'IP005'),
('TR018', 'DrA02', 'IP006');




