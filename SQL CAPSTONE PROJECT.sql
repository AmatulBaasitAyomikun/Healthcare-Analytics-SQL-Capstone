---*** CREATING DATABASE TABLES ***---


CREATE TABLE Patients (
	pt_id INT PRIMARY KEY,
	name VARCHAR(50),
	age INT,
	sex VARCHAR(2),
	occupation VARCHAR(50),
	marital_stautus VARCHAR(15)
);

alter table patients
add column level_of_education varchar(50)

CREATE TABLE Doctors(
	doctor_id VARCHAR(10) PRIMARY KEY,
	doctor VARCHAR(20),
	gender VARCHAR(2),
	email VARCHAR(25),
	specialization VARCHAR(25)
);


CREATE TABLE Admission_details(
	admission_id INT PRIMARY KEY,
	pt_id INT REFERENCES Patients(pt_id),
	admission_duration INT,
	doctor_id VARCHAR(10) REFERENCES Doctors(doctor_id),
	dama VARCHAR(5),
	reason_for_dama VARCHAR(100),
	dead VARCHAR(5),
	cause_of_death VARCHAR(100),
	ckd VARCHAR(5),
	cause_ckd VARCHAR(100),
	dialysis VARCHAR(5),
	no_of_sessions INT,
	stroke VARCHAR(5),
	dm VARCHAR(5),
	cancer VARCHAR(5),
	type_of_cancer VARCHAR(100),
	pud VARCHAR(5)
);


CREATE TABLE risk_factor(
	pt_id INT REFERENCES Patients(pt_id),
	alcohol_hx VARCHAR(5),
	tobacco_hx VARCHAR(5),
	nsaid_use VARCHAR(5)
);

ALTER TABLE admission_details 
DROP CONSTRAINT admission_details_pt_id_fkey;

SELECT * FROM patients;
SELECT * FROM doctors;
SELECT * FROM admission_details;
SELECT * FROM risk_factor;



					---*** PATIENT'S DEMOGRAPHIC ANALYSIS ***---
					
--- 1. Age group distribution of all patients? ---

WITH age_groups AS (
  	SELECT 
        CASE
            WHEN age < 18 THEN 'Adolescent'
            WHEN age BETWEEN 18 AND 35 THEN 'Young Adult'
            WHEN age BETWEEN 36 AND 55 THEN 'Middle Aged'
            WHEN age BETWEEN 56 AND 70 THEN 'Senior'
            WHEN age >= 71 THEN 'Elderly'
            ELSE 'Unknown'
        END AS age_group,
        COUNT(*) AS no_of_patients
	FROM patients
	GROUP BY age_group
)
SELECT 
    age_group,
    no_of_patients,
    ROUND(no_of_patients * 100.0 / 
        (SELECT COUNT(*) FROM patients), 1) AS age_distribution
FROM age_groups
ORDER BY no_of_patients DESC;


--- 2. Mortality rate per each age group? ---

WITH age_groups AS (
  	SELECT 
        CASE
            WHEN age < 18 THEN 'Adolescent'
            WHEN age BETWEEN 18 AND 35 THEN 'Young Adult'
            WHEN age BETWEEN 36 AND 55 THEN 'Middle Aged'
            WHEN age BETWEEN 56 AND 70 THEN 'Senior'
            WHEN age >= 71 THEN 'Elderly'
            ELSE 'Unknown'
        END AS age_group,
        COUNT(*) AS no_of_patients,
		COUNT(*) FILTER (WHERE a.dead = 'Yes') AS total_death
	FROM patients p
	JOIN admission_details a
		ON p.pt_id = a.pt_id
	GROUP BY age_group
)

SELECT age_group,
	no_of_patients,
	total_death,
	ROUND(total_death * 100.0/no_of_patients,1) AS mortality_rate
FROM age_groups
ORDER BY mortality_rate	DESC;
	

--- 3. Mortality Rate by Sex ---

SELECT 
    p.sex,
    COUNT(*) AS no_of_patients,                                      
    COUNT(*) FILTER (WHERE a.dead = 'Yes') AS total_deaths,          
    ROUND(COUNT(*) FILTER (WHERE a.dead = 'Yes') * 100.0
        / COUNT(*), 1) AS mortality_rate                                                   
FROM patients p
JOIN admission_details a
    ON p.pt_id = a.pt_id
GROUP BY p.sex
ORDER BY mortality_rate DESC;
	

--- 4. Sex with higher prevalence for each chronic illness? ---

SELECT 
    p.sex,
    'CKD' AS chronic_illness,
    COUNT(*) FILTER (WHERE a.ckd = 'Yes') AS total_patients,
    ROUND(COUNT(*) FILTER (WHERE a.ckd = 'Yes') * 100.0
        / COUNT(*), 1 ) AS prevalence_rate                                                
FROM patients p
JOIN admission_details a ON p.pt_id = a.pt_id
GROUP BY p.sex

UNION ALL
SELECT 
    p.sex,
    'Stroke' AS chronic_illness,
    COUNT(*) FILTER (WHERE a.stroke = 'Yes') AS total_patients,
    ROUND(COUNT(*) FILTER (WHERE a.stroke = 'Yes') * 100.0
        / COUNT(*), 1) AS prevalence_rate
FROM patients p
JOIN admission_details a ON p.pt_id = a.pt_id
GROUP BY p.sex

UNION ALL

SELECT 
    p.sex,
    'Diabetes Mellitus'  AS chronic_illness,
    COUNT(*) FILTER (WHERE a.dm = 'Yes') AS total_patients,
    ROUND(COUNT(*) FILTER (WHERE a.dm = 'Yes') * 100.0
        / COUNT(*), 1 ) AS prevalence_rate                                             
FROM patients p
JOIN admission_details a ON p.pt_id = a.pt_id
GROUP BY p.sex

UNION ALL

SELECT 
    p.sex,
    'Cancer' AS chronic_illness,
    COUNT(*) FILTER (WHERE a.cancer = 'Yes') AS total_patients,
    ROUND(COUNT(*) FILTER (WHERE a.cancer = 'Yes') * 100.0
        / COUNT(*), 1) AS prevalence_rate
FROM patients p
JOIN admission_details a ON p.pt_id = a.pt_id
GROUP BY p.sex

UNION ALL

SELECT 
    p.sex,
    'Pud' AS chronic_illness,
    COUNT(*) FILTER (WHERE a.pud = 'Yes') AS total_patients,
    ROUND(COUNT(*) FILTER (WHERE a.pud = 'Yes') * 100.0
        / COUNT(*), 1)  AS prevalence_rate                                                
FROM patients p
JOIN admission_details a ON p.pt_id = a.pt_id
GROUP BY p.sex

ORDER BY chronic_illness, sex;


									---*** DAMA ANALYSIS ***---

--- 5. Total patients discharged against medical advice, and the percentage of total admissions it represents?---

WITH DAMA_patients AS(
SELECT COUNT(admission_id) AS no_of_patients,
		(SELECT COUNT(admission_id) AS total_admission FROM admission_details)
FROM admission_details
WHERE dama = 'Yes'
)

SELECT no_of_patients,
		total_admission,
		ROUND(no_of_patients / total_admission :: DECIMAL * 100,1) AS percent_of_DAMA_patients
FROM DAMA_patients;


--- 6. The most common reasons patients left against medical advice, and how many times each reason appears? ---

SELECT reason_for_dama,
		COUNT(pt_id) as no_of_patients				
FROM admission_details
WHERE dama = 'Yes'
GROUP BY reason_for_dama
ORDER BY no_of_patients	DESC; 


--- 7. How does DAMA vary by sex — how many male vs female patients left against medical advice? ---

SELECT p.sex,
		COUNT(a.pt_id) as no_of_patients
FROM admission_details a
JOIN patients p
	ON a.pt_id = p.pt_id
WHERE dama = 'Yes'
GROUP BY sex
ORDER BY no_of_patients	DESC; 


--- 8. How does DAMA vary by age group? ---

SELECT CASE
		WHEN age < 18 THEN 'Adolescent'
		WHEN age BETWEEN 18 AND 35 THEN 'Young adult'
		WHEN age BETWEEN 36 AND 55 THEN 'Middle Aged'
		WHEN age BETWEEN 56 AND 70 THEN 'Senior'
		WHEN age >= 71 THEN 'Elderly'
		ELSE 'unknown'
		END AS Age_group,
		COUNT(p.pt_id) as no_of_patients
FROM admission_details a
JOIN patients p
	ON a.pt_id = p.pt_id
WHERE a.dama = 'Yes'
GROUP BY Age_group
ORDER BY no_of_patients	DESC;	


--- 9. Top 5 specializations with the highest number of DAMA patients? ---

SELECT d.specialization,
		COUNT(a.admission_id) as no_of_dama
FROM doctors d
JOIN admission_details a
	ON a.doctor_id = d.doctor_id
WHERE a.dama = 'Yes'
GROUP BY d.specialization
ORDER BY no_of_dama DESC
LIMIT 5;


SELECT 
    d.specialization,
    COUNT(*) AS total_patients,
    COUNT(*) FILTER (WHERE a.dama = 'Yes') AS total_dama,
    ROUND(COUNT(*) FILTER (WHERE a.dama = 'Yes') * 100.0 / COUNT(*), 1) AS dama_rate
FROM doctors d
INNER JOIN admission_details a ON d.doctor_id = a.doctor_id
GROUP BY d.specialization
ORDER BY dama_rate DESC;


							----*** CHRONIC ILLNESS ANALYSIS ***----
							
--- 10. What are the total counts and percentages of patients with each chronic condition? ---

WITH illness_table AS(
SELECT 'ckd' AS CONDITION,
	COUNT(*) FILTER( WHERE ckd = 'Yes') AS total_patients 
FROM admission_details

UNION ALL

SELECT 'stroke' AS CONDITION,
	COUNT(*) FILTER ( WHERE stroke = 'Yes') AS total_patients 
FROM admission_details

UNION ALL

SELECT 'dm' AS CONDITION,
	COUNT(*) FILTER( WHERE dm = 'Yes') AS total_patients 
FROM admission_details

UNION ALL

SELECT 'cancer' AS CONDITION,
	COUNT(*) FILTER ( WHERE cancer = 'Yes') AS total_patients 
FROM admission_details

UNION ALL

SELECT 'pud' AS CONDITION,
	COUNT(*) FILTER ( WHERE pud = 'Yes') AS total_patients 
FROM admission_details
)
	
SELECT condition,
		total_patients,
		(SELECT COUNT(admission_id) AS total_admission FROM admission_details),
		ROUND(total_patients/
		(SELECT COUNT(admission_id) AS total_admission FROM admission_details) :: DECIMAL * 100.0, 1) AS percent_illness_per_admission
FROM illness_table
ORDER BY percent_illness_per_admission DESC;		


--- 11. Top 5 common causes of CKD in patients? ---

SELECT COUNT(pt_id) no_of_patients,
		cause_ckd
FROM admission_details
WHERE ckd = 'Yes'
GROUP BY cause_ckd
ORDER BY no_of_patients DESC
LIMIT 5;


--- 12. What percentage of CKD patients required dialysis, and the average number of dialysis sessions? ---

WITH dialysis_table AS (
    SELECT admission_id,
           no_of_sessions,
           dialysis
    FROM admission_details
    WHERE ckd = 'Yes'  
)
SELECT 
    COUNT(*) AS total_ckd_patients,                                    
    COUNT(*) FILTER (WHERE dialysis = 'Yes') AS dialysis_patients,       
    ROUND(COUNT(*) FILTER (WHERE dialysis = 'Yes') * 100.0
        / COUNT(*), 1) AS percentage_dialysis,                                               
    ROUND(AVG(no_of_sessions) FILTER (WHERE dialysis = 'Yes'), 1) AS avg_num_of_sessions         
FROM dialysis_table;  
		

--- 13. What is the mortality rate among patients with each chronic illness? ---

SELECT 
    'Cancer' AS chronic_illness,
    COUNT(*) FILTER (WHERE cancer = 'Yes') AS total_patients,
    COUNT(*) FILTER (WHERE cancer = 'Yes' AND dead = 'Yes') AS total_deaths,
    ROUND(COUNT(*) FILTER (WHERE cancer = 'Yes' AND dead = 'Yes') * 100.0 
        / NULLIF(COUNT(*) FILTER (WHERE cancer = 'Yes'), 0), 1) AS mortality_rate
FROM admission_details
UNION ALL
SELECT 
    'Diabetes Mellitus',
    COUNT(*) FILTER (WHERE dm = 'Yes'),
    COUNT(*) FILTER (WHERE dm = 'Yes' AND dead = 'Yes'),
    ROUND(COUNT(*) FILTER (WHERE dm = 'Yes' AND dead = 'Yes') * 100.0 
        / NULLIF(COUNT(*) FILTER (WHERE dm = 'Yes'), 0), 1)
FROM admission_details
UNION ALL
SELECT 
    'CKD',
    COUNT(*) FILTER (WHERE ckd = 'Yes'),
    COUNT(*) FILTER (WHERE ckd = 'Yes' AND dead = 'Yes'),
    ROUND(COUNT(*) FILTER (WHERE ckd = 'Yes' AND dead = 'Yes') * 100.0 
        / NULLIF(COUNT(*) FILTER (WHERE ckd = 'Yes'), 0), 1)
FROM admission_details
UNION ALL
SELECT 
    'Stroke',
    COUNT(*) FILTER (WHERE stroke = 'Yes'),
    COUNT(*) FILTER (WHERE stroke = 'Yes' AND dead = 'Yes'),
    ROUND(COUNT(*) FILTER (WHERE stroke = 'Yes' AND dead = 'Yes') * 100.0 
        / NULLIF(COUNT(*) FILTER (WHERE stroke = 'Yes'), 0), 1)
FROM admission_details
UNION ALL
SELECT 
    'Peptic Ulcer Disease',
    COUNT(*) FILTER (WHERE pud = 'Yes'),
    COUNT(*) FILTER (WHERE pud = 'Yes' AND dead = 'Yes'),
    ROUND(COUNT(*) FILTER (WHERE pud = 'Yes' AND dead = 'Yes') * 100.0 
        / NULLIF(COUNT(*) FILTER (WHERE pud = 'Yes'), 0), 1)
FROM admission_details
ORDER BY mortality_rate DESC;


										---*** LIFESTYLE ANALYSIS ***---
										
--- 14. Among patients with a history of NSAID use, how many developed Peptic Ulcer Disease (PUD)? ---

SELECT r.nsaid_use,
		COUNT(*) AS total_patients,
		COUNT(*) FILTER (WHERE a.pud = 'Yes') AS pud_patients,
		ROUND(COUNT(*) FILTER (WHERE a.pud = 'Yes') * 100.0/ COUNT(*),1) AS percent_of_pud_patients		
FROM admission_details a
JOIN risk_factor r
	ON a.pt_id = r.pt_id
GROUP BY nsaid_use
ORDER BY percent_of_pud_patients;


--- 15. Does alcohol history affect mortality rate? ---

SELECT r.alcohol_hx,
		COUNT(*) AS total_patients,
		COUNT(*) FILTER(WHERE a.dead = 'Yes') as total_death,
		ROUND(COUNT(*) FILTER(WHERE dead = 'Yes') * 100.0 / COUNT(*),1) AS mortality_rate
FROM admission_details a
JOIN risk_factor r
	ON a.pt_id = r.pt_id
GROUP BY alcohol_hx
ORDER BY mortality_rate DESC;


--- 16. Does tobacco history affect mortality rate? ---

SELECT r.tobacco_hx,
		COUNT(*) AS total_patients,
		COUNT(*) FILTER(WHERE a.dead = 'Yes') as total_death,
		ROUND(COUNT(*) FILTER(WHERE dead = 'Yes') * 100.0 / COUNT(*),1) AS mortality_rate
FROM admission_details a
JOIN risk_factor r
	ON a.pt_id = r.pt_id
GROUP BY tobacco_hx
ORDER BY mortality_rate DESC;



						--- DOCTOR'S PERFORMANCE ANALYSIS ---
						
--- 17. How many patients has each doctor treated, ranked from highest to lowest workload? ---

SELECT doctor,
		specialization,
	COUNT(pt_id) AS no_of_patients_treated
FROM doctors d
JOIN admission_details a
	ON d.doctor_id = a.doctor_id
GROUP BY doctor, specialization
ORDER BY no_of_patients_treated DESC;

SELECT 
    d.doctor,
    d.specialization,
    COUNT(*) AS total_patients,
    ROUND(COUNT(*) FILTER (WHERE a.dead = 'Yes') * 100.0 / COUNT(*), 1) AS mortality_rate,
    ROUND(COUNT(*) FILTER (WHERE a.dama = 'Yes') * 100.0 / COUNT(*), 1) AS dama_rate,
    ROUND(AVG(a.admission_duration), 1) AS avg_admission_duration
FROM doctors d
INNER JOIN admission_details a ON d.doctor_id = a.doctor_id
GROUP BY d.doctor, d.specialization
ORDER BY total_patients DESC;


--- 18. Which doctors have the highest DAMA rates (the percentage of their patients who left against medical advice)? ---

SELECT DISTINCT
    doctor,
    specialization,
    COUNT(*) OVER (PARTITION BY doctor, specialization) AS total_admission,
    SUM(CASE WHEN a.dama = 'Yes' THEN 1 ELSE 0 END) 
        OVER (PARTITION BY doctor, specialization) AS total_dama_patients,
   ROUND(SUM(CASE WHEN a.dama = 'Yes' THEN 1 ELSE 0 END) 
            OVER (PARTITION BY doctor, specialization) * 100.0/
        COUNT(*) OVER (PARTITION BY doctor, specialization),1) AS percent_DAMA_rate
FROM doctors d
JOIN admission_details a
    ON d.doctor_id = a.doctor_id
ORDER BY percent_DAMA_rate DESC
LIMIT 10;


--- 19. Which doctors have the highest mortality rate among their patients? ---

SELECT DISTINCT
    doctor,
    specialization,
    COUNT(*) OVER (PARTITION BY doctor, specialization) AS total_admission,
    SUM(CASE WHEN a.dead = 'Yes' THEN 1 ELSE 0 END) OVER (PARTITION BY doctor, specialization) AS total_dead_patients,
   ROUND(SUM(CASE WHEN a.dead = 'Yes' THEN 1 ELSE 0 END) OVER (PARTITION BY doctor, specialization) * 100.0/
       					 COUNT(*) OVER (PARTITION BY doctor, specialization),1) AS mortality_rate
FROM doctors d
JOIN admission_details a
    ON d.doctor_id = a.doctor_id
ORDER BY mortality_rate DESC
LIMIT 10;


--- 20. Which specializations have the highest average admission duration (length of stay)? ---

SELECT specialization,
       ROUND(AVG(admission_duration), 1) AS avg_admission_duration
FROM doctors d
JOIN admission_details a
    ON d.doctor_id = a.doctor_id
GROUP BY specialization
ORDER BY avg_admission_duration DESC;











					