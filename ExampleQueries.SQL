
--Task 2.1
SELECT 
	course_layout.course_code AS "Course Code",
	course_instance.id AS "Course Instance ID",
	course_layout.hp AS "HP",
	course_instance.study_year AS "Year",
	course_instance.study_period AS "Period",
	course_instance.num_students AS "# Students",
	COALESCE(SUM(planned_activity.planned_hours * teaching_activity.factor) FILTER (WHERE planned_activity.activity_name = 'Lecture'), 0) AS "Lecture Hours",
	COALESCE(SUM(planned_activity.planned_hours * teaching_activity.factor) FILTER (WHERE planned_activity.activity_name = 'Seminar'), 0) AS "Seminar Hours",
	COALESCE(SUM(planned_activity.planned_hours * teaching_activity.factor) FILTER (WHERE planned_activity.activity_name = 'Lab'), 0) AS "Lab Hours",
	COALESCE(SUM(planned_activity.planned_hours * teaching_activity.factor) FILTER (WHERE planned_activity.activity_name = 'Tutorial'), 0) AS "Tutorial Hours",
	COALESCE(SUM(planned_activity.planned_hours * teaching_activity.factor) FILTER (WHERE planned_activity.activity_name = 'Other'), 0) AS "Other Hours",
	COALESCE(SUM(planned_activity.planned_hours * teaching_activity.factor) FILTER (WHERE planned_activity.activity_name = 'Project Supervision'), 0) AS "Project Hours",
  	(28 + course_instance.num_students * 0.2 + 2*course_layout.hp) AS "Admin",
  	(32 + course_instance.num_students*0.725) AS "Exam",
	(COALESCE(SUM(planned_activity.planned_hours * teaching_activity.factor),0) + (28 + course_instance.num_students * 0.2 + 2*course_layout.hp) + (32 + course_instance.num_students*0.725)) AS "Total Hours"
	
	
FROM course_layout
INNER JOIN course_instance ON course_instance.course_code = course_layout.course_code
INNER JOIN planned_activity ON course_instance.id = planned_activity.instance_id
INNER JOIN teaching_activity ON planned_activity.activity_name = teaching_activity.activity_name
WHERE course_instance.study_year = 2025

GROUP BY 
	course_layout.course_code,
	course_instance.id,
	course_layout.hp,
	course_instance.study_year,
	course_instance.study_period,
	course_instance.num_students	

--Task 2.2

--Gets number of employees in a column tc.numb with a column inst to be able to use a INNER JOIN to get different results for each course instance.

WITH tc as (
	SELECT 
		COUNT(DISTINCT pe.employee_id) AS numb,
		ci.id as inst
	FROM course_instance ci 
	INNER JOIN planned_activity pa ON ci.id = pa.instance_id
	INNER JOIN plan_employee pe ON pa.id = pe.plan_id

	GROUP BY ci.id
)

--Selects the desired information from course instance id = 7 and uses the employee amount calculated above.
SELECT 
	cl.course_code AS "Course Code",
	ci.id AS "Course Instance ID",
	cl.hp AS "HP",
	ci.study_year AS "Year",
	CONCAT(pn.first_name, ' ', pn.last_name) AS "Teacher",
	jt.job_title AS "Role",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Lecture' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Lecture Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Seminar' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Seminar Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Lab' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Lab Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Tutorial' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Tutorial Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Project Supervision' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Project Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Other' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Other Hours",
	CEILING((28 + ci.num_students * 0.2 + 2*cl.hp)/ tc.numb) AS "Admin hours",
	CEILING((32 + ci.num_students*0.725)/ tc.numb) AS "Exam hours",
	CEILING(SUM(pe.alloc_hours*ta.factor)+((32 + ci.num_students*0.725)/ tc.numb) + ((28 + ci.num_students * 0.2 + 2*cl.hp)/tc.numb)) AS "Total Hours"
	
FROM course_layout cl
INNER JOIN course_instance ci ON ci.course_code = cl.course_code
INNER JOIN planned_activity pa ON ci.id = pa.instance_id
INNER JOIN teaching_activity ta ON pa.activity_name = ta.activity_name
INNER JOIN plan_employee pe ON pa.id = pe.plan_id
INNER JOIN employee e ON pe.employee_id = e.id
INNER JOIN person pn ON e.person_number = pn.person_number
INNER JOIN job_title jt ON e.job_title_id = jt.id
INNER JOIN tc on tc.inst = ci.id
WHERE ci.id = 7

GROUP BY 
	cl.course_code,
	ci.id,
	cl.hp,
	ci.study_year,
	pn.first_name,
	pn.last_name,
	jt.job_title,
	tc.numb

-- Task 2.3
WITH tc as (
	SELECT 
		COUNT(DISTINCT pe.employee_id) AS numb,
		ci.id as inst
	FROM course_instance ci 
	INNER JOIN planned_activity pa ON ci.id = pa.instance_id
	INNER JOIN plan_employee pe ON pa.id = pe.plan_id

	GROUP BY ci.id
)

SELECT 
	cl.course_code AS "Course Code",
	ci.id AS "Course Instance ID",
	cl.hp AS "HP",
	ci.study_year AS "Year",
	ci.study_period AS "Period",
	CONCAT(pn.first_name, ' ', pn.last_name) AS "Teacher",
	jt.job_title AS "Role",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Lecture' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Lecture Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Seminar' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Seminar Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Lab' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Lab Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Tutorial' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Tutorial Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Project Supervision' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Project Hours",
	CEILING(SUM(CASE WHEN pa.activity_name = 'Other' THEN pe.alloc_hours*ta.factor ELSE 0 END)) AS "Other Hours",
	CEILING((28 + ci.num_students * 0.2 + 2*cl.hp)/ tc.numb) AS "Admin hours",
	CEILING((32 + ci.num_students*0.725)/ tc.numb) AS "Exam hours",
	CEILING(SUM(pe.alloc_hours*ta.factor)+((32 + ci.num_students*0.725)/ tc.numb) + ((28 + ci.num_students * 0.2 + 2*cl.hp)/ tc.numb)) AS "Total Hours"
	
	
FROM course_layout cl
INNER JOIN course_instance ci ON ci.course_code = cl.course_code
INNER JOIN planned_activity pa ON ci.id = pa.instance_id
INNER JOIN teaching_activity ta ON pa.activity_name = ta.activity_name
INNER JOIN plan_employee pe ON pa.id = pe.plan_id
INNER JOIN employee e ON pe.employee_id = e.id
INNER JOIN person pn ON e.person_number = pn.person_number
INNER JOIN job_title jt ON e.job_title_id = jt.id
INNER JOIN tc ON tc.inst = ci.id
WHERE ci.study_year = 2025 AND e.id = 4

GROUP BY 
	cl.course_code,
	ci.id,
	cl.hp,
	ci.study_year,
	ci.study_period,
	ci.num_students,
	pn.first_name,
	pn.last_name,
	jt.job_title,
	tc.numb
