
-- Question A.1: List all patients currently admitted to the hospital (i.e., those who are currently receiving inpatient services). List only patient identification number and name.
SELECT Patient_ID, firstname, Lastname
FROM inpatients
JOIN admitted_Patients USING (Patient_ID)
WHERE discharge_Time IS NULL;

-- Question A.2: List all patients who have received outpatient services within a given date range. List only patient identification number and name.
SELECT Patient_ID, firstname, Lastname, admit_time FROM outpatients
JOIN admitted_Patients USING (patient_ID)
WHERE admit_Time between '2019-03-02' AND '2019-06-01';

--  Question A.3: For a given patient (either patient identification number or name), list all treatments that were administered. Group treatments by admissions. 
-- 				List admissions in descending chronological order, and list treatments in ascending chronological order within each admission.
SELECT Inpatients.Patient_ID, Inpatients.firstname, Inpatients.Lastname , treatment_ID, treatment_name,  time_stamp AS treatment_time_stamp, admit_Time, discharge_time
FROM Inpatients
JOIN ATI_ternary USING (Patient_ID)
JOIN treatment USING (treatment_ID)
JOIN admitted_Patients USING (Patient_ID)
JOIN Hospital_Treatment_List USING (Hospital_Treatment_List_ID)
WHERE Inpatients.Patient_ID = 'IP001' AND (time_stamp BETWEEN admit_Time AND discharge_time)
-- group by admit_time  Note: having group by with no aggregatation function will return the first record of each group and should not be used here since we want all treatments within each addmision period
ORDER BY admit_Time DESC, time_stamp ASC;


--  Question B.1: List the treatments performed at the hospital (to both inpatients and outpatients), in descending order of occurrences. 
-- 				  List treatment identification number, name, and total number of occurrences of each treatment.
SELECT treatment_ID, admin_id, time_stamp AS treatment_time_stamp, treatment_name, COUNT(treatment_name)
FROM Treatment
JOIN Hospital_Treatment_List USING (Hospital_Treatment_List_ID)
GROUP BY treatment_name
ORDER BY time_stamp;

--  Question B.2: For a given treatment occurrence, list all the hospital employees that were involved. Also include the patient name and the doctor who ordered the treatment.
SELECT Ad.lastname AS 'Employee Last NAME', Treatment_ID,  doctor.lastname AS 'Doctor Last Name', InPatients.lastname AS 'Patient Last Name'
FROM Treatment
JOIN ATI_ternary USING (treatment_ID)
JOIN Doctor USING (emp_ID)
JOIN InPatients USING (patient_ID)
JOIN doctor Ad ON ad.admin_ID = Treatment.admin_ID
WHERE Treatment_ID = 'TR002'
UNION
SELECT Ad2.lastname AS 'Employee Last NAME', Treatment_ID,  doctor.lastname AS 'Doctor Last Name', InPatients.lastname AS 'Patient Last Name'
FROM Treatment
JOIN ATI_ternary USING (treatment_ID)
JOIN Doctor USING (emp_ID)
JOIN InPatients USING (patient_ID)
JOIN Technician Ad2 ON ad2.admin_ID = Treatment.admin_ID
WHERE Treatment_ID = 'TR002'
UNION
SELECT Ad3.lastname AS 'Employee Last NAME', Treatment_ID,  doctor.lastname AS 'Doctor Last Name', InPatients.lastname AS 'Patient Last Name'
FROM Treatment
JOIN ATI_ternary USING (treatment_ID)
JOIN Doctor USING (emp_ID)
JOIN InPatients USING (patient_ID)
JOIN nurse Ad3 ON ad3.admin_ID = Treatment.admin_ID
WHERE Treatment_ID = 'TR002'
UNION
SELECT Ad.lastname AS 'Employee Last NAME', Treatment_ID,  doctor.lastname AS 'Doctor Last Name', outPatients.lastname AS 'Patient Last Name'
FROM Treatment
JOIN ATI_ternary USING (treatment_ID)
JOIN Doctor USING (emp_ID)
JOIN outPatients USING (patient_ID)
JOIN doctor Ad ON ad.admin_ID = Treatment.admin_ID
WHERE Treatment_ID = 'TR002'
UNION
SELECT Ad2.lastname AS 'Employee Last NAME', Treatment_ID,  doctor.lastname AS 'Doctor Last Name', outPatients.lastname AS 'Patient Last Name'
FROM Treatment
JOIN ATI_ternary USING (treatment_ID)
JOIN Doctor USING (emp_ID)
JOIN outPatients USING (patient_ID)
JOIN Technician Ad2 ON ad2.admin_ID = Treatment.admin_ID
WHERE Treatment_ID = 'TR002'
UNION
SELECT Ad3.lastname AS 'Employee Last NAME', Treatment_ID,  doctor.lastname AS 'Doctor Last Name', outPatients.lastname AS 'Patient Last Name'
FROM Treatment
JOIN ATI_ternary USING (treatment_ID)
JOIN Doctor USING (emp_ID)
JOIN outPatients USING (patient_ID)
JOIN nurse Ad3 ON ad3.admin_ID = Treatment.admin_ID
WHERE Treatment_ID = 'TR002';


-- Question C.1: For a given doctor, list all treatments that they ordered in descending order of occurrence. 
-- 				 For each treatment, list the total number of occurrences for the given doctor.
SELECT emp_ID, treatment_name, time_stamp, COUNT(treatment_name) AS 'total occurance'
FROM ATI_ternary
JOIN Treatment USING (treatment_ID)
JOIN Hospital_Treatment_List USING (Hospital_Treatment_List_ID)
WHERE emp_ID = ('DrA02')
GROUP BY treatment_name
UNION
SELECT emp_ID, treatment_name, time_stamp, COUNT(treatment_name) AS 'total occurance'
FROM DTO_ternary
JOIN Treatment USING (treatment_ID)
JOIN Hospital_Treatment_List USING (Hospital_Treatment_List_ID)
WHERE emp_ID = ('DrA02')
GROUP BY treatment_name
ORDER BY time_stamp DESC, 'total occurance' ASC;

-- Question C.2: List employees who have been involved in the treatment of every admitted patient. (Answer: No one involved in all)
SELECT *
FROM
(SELECT treatment_ID, ATI_ternary.emp_ID, adm.admin_ID, adm.lastname AS "Employee Name"
	FROM ATI_ternary
	JOIN Treatment USING (treatment_ID)
	JOIN doctor adm ON adm.admin_ID =  Treatment.admin_ID
	UNION
	SELECT treatment_ID, ATI_ternary.emp_ID, adm1.admin_ID, adm1.lastname AS "Employee Name"
	FROM ATI_ternary
	JOIN Treatment USING (treatment_ID)
	JOIN nurse adm1 ON adm1.admin_ID =  Treatment.admin_ID
	UNION
	SELECT treatment_ID, ATI_ternary.emp_ID, adm2.admin_ID, adm2.lastname AS "Employee Name"
	FROM ATI_ternary
	JOIN Treatment USING (treatment_ID)
	JOIN Technician adm2 ON adm2.admin_ID =  Treatment.admin_ID) AS sd
GROUP BY admin_ID
HAVING count(admin_ID) = (SELECT count(patient_ID) FROM patients);

-- Question C.3: List the primary doctors of patients with a high admission rate (at least 4 admissions within a one-year time frame).
SELECT DISTINCT emp_ID, Doctor.lastname, count(emp_ID) AS 'Total Admissions'
FROM ATI_ternary
JOIN Doctor USING (emp_ID)
GROUP BY emp_ID
HAVING count(emp_ID) >= 4
UNION
SELECT emp_ID, Doctor.lastname, count(emp_ID) AS 'Total Admissions'
FROM DTO_ternary
JOIN Doctor USING (emp_ID)
GROUP BY emp_ID
HAVING count(emp_ID) >= 4
ORDER BY ('Total Admissions');


