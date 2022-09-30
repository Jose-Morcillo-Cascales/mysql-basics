--  Sample employee database 
--  See changelog table for details
--  Copyright (C) 2007,2008, MySQL AB
--  
--  Original data created by Fusheng Wang and Carlo Zaniolo
--  http://www.cs.aau.dk/TimeCenter/software.htm
--  http://www.cs.aau.dk/TimeCenter/Data/employeeTemporalDataSet.zip
-- 
--  Current schema by Giuseppe Maxia 
--  Data conversion from XML to relational by Patrick Crews
-- 
-- This work is licensed under the 
-- Creative Commons Attribution-Share Alike 3.0 Unported License. 
-- To view a copy of this license, visit 
-- http://creativecommons.org/licenses/by-sa/3.0/ or send a letter to 
-- Creative Commons, 171 Second Street, Suite 300, San Francisco, 
-- California, 94105, USA.
-- 
--  DISCLAIMER
--  To the best of our knowledge, this data is fabricated, and
--  it does not correspond to real people. 
--  Any similarity to existing people is purely coincidental.
-- 
 
DROP DATABASE IF EXISTS employees;
CREATE DATABASE IF NOT EXISTS employees;
USE employees;
 
SELECT 'CREATING DATABASE STRUCTURE' as 'INFO';
 
DROP TABLE IF EXISTS dept_emp,
                     dept_manager,
                     titles,
                     salaries, 
                     employees, 
                     departments;
 
/*!50503 set default_storage_engine = InnoDB */;
/*!50503 select CONCAT('storage engine: ', @@default_storage_engine) as INFO */;
 
CREATE TABLE employees (
    emp_no      INT             NOT NULL,
    birth_date  DATE            NOT NULL,
    first_name  VARCHAR(14)     NOT NULL,
    last_name   VARCHAR(16)     NOT NULL,
    gender      ENUM ('M','F')  NOT NULL,    
    hire_date   DATE            NOT NULL,
    PRIMARY KEY (emp_no)
);
 
CREATE TABLE departments (
    dept_no     CHAR(4)         NOT NULL,
    dept_name   VARCHAR(40)     NOT NULL,
    PRIMARY KEY (dept_no),
    UNIQUE  KEY (dept_name)
);
 
CREATE TABLE dept_manager (
   emp_no       INT             NOT NULL,
   dept_no      CHAR(4)         NOT NULL,
   from_date    DATE            NOT NULL,
   to_date      DATE            NOT NULL,
   FOREIGN KEY (emp_no)  REFERENCES employees (emp_no)    ON DELETE CASCADE,
   FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
   PRIMARY KEY (emp_no,dept_no)
); 
 
CREATE TABLE dept_emp (
    emp_no      INT             NOT NULL,
    dept_no     CHAR(4)         NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    FOREIGN KEY (emp_no)  REFERENCES employees   (emp_no)  ON DELETE CASCADE,
    FOREIGN KEY (dept_no) REFERENCES departments (dept_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no,dept_no)
);
 
CREATE TABLE titles (
    emp_no      INT             NOT NULL,
    title       VARCHAR(50)     NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE,
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no,title, from_date)
) 
; 
 
CREATE TABLE salaries (
    emp_no      INT             NOT NULL,
    salary      INT             NOT NULL,
    from_date   DATE            NOT NULL,
    to_date     DATE            NOT NULL,
    FOREIGN KEY (emp_no) REFERENCES employees (emp_no) ON DELETE CASCADE,
    PRIMARY KEY (emp_no, from_date)
) 
; 
 
CREATE OR REPLACE VIEW dept_emp_latest_date AS
    SELECT emp_no, MAX(from_date) AS from_date, MAX(to_date) AS to_date
    FROM dept_emp
    GROUP BY emp_no;
 
# shows only the current department for each employee
CREATE OR REPLACE VIEW current_dept_emp AS
    SELECT l.emp_no, dept_no, l.from_date, l.to_date
    FROM dept_emp d
        INNER JOIN dept_emp_latest_date l
        ON d.emp_no=l.emp_no AND d.from_date=l.from_date AND l.to_date = d.to_date;
 
-- Add auto_increment to emp_no from employees
SET FOREIGN_KEY_CHECKS = 0; 
ALTER TABLE employees MODIFY COLUMN emp_no INT AUTO_INCREMENT;
SET FOREIGN_KEY_CHECKS = 1;
INSERT INTO employees (birth_date, first_name,last_name, gender, hire_date)
 values
( '1996/11/20','Juan', 'Torres','M', '2010/10/20'),
( '1996/11/21','Juan', 'Fernandez','M', '2010/10/20'),
( '1996/11/18','Juan', 'Gutierrez','M', '2010/10/20'),
( '1996/11/21','Maria', 'Fernandez','F', '2010/10/20'),
( '1996/11/20','Paula', 'Balaguer','F', '2013/01/20'),
( '1986/10/21','Mario', 'Bros','M', '2018/06/04'),
( '1996/11/22','Sofia', 'Ferrer','F', '2015/07/04'),
( '1996/11/16','Alejandro', 'Pineda','F', '2020/09/16'),
( '1985/11/07','Juana', 'Cascales','F', '2016/03/31'),
( '1994/10/19','Maria Jose', 'Sanchez','F', '2019/02/28'),
('1976/01/12','Peter', 'Pan','M', '2013/09/09'),
( '1996/10/17','Ricardo', 'Valero','M', '2015/01/06'),
( '1988/10/24','Luis', 'Civill','M', '2018/05/09'),
( '1991/11/23','Sofia', 'Gavana','F', '2019/07/20'),
( '1996/04/11','Alejandro', 'Garcia','M', '2020/09/10');
 
SELECT * FROM employees;
 
INSERT INTO departments (dept_no, dept_name)
 values
( 'MRKT','marketing'),
('CONT','contabilidad'),
('DEV','desarrollo web'),
('RRHH','recursos humanos');
 
SELECT * FROM dept_manager;
 
INSERT INTO  dept_manager (dept_no, emp_no,from_date,to_date)
 values
( 'MRKT',1,'2010/10/20','2022/10/20'),
( 'MRKT',2,'2010/10/20','2022/10/20'),
( 'CONT',3,'2010/10/20','2022/10/20'),
( 'DEV',4,'2010/10/20','2022/10/20'),
( 'RRHH',5,'2010/10/20','2022/10/20');
 
SELECT * FROM dept_manager;
 
INSERT INTO  dept_emp (dept_no, emp_no,from_date,to_date)
 values
( 'MRKT',6,'2018-06-04','2022/10/20'),
( 'MRKT',7,'2015-07-04','2022/10/20'),
( 'CONT',8,'2020-09-16','2022/10/20'),
( 'DEV',9,'2016-03-31','2022/10/20'),
( 'RRHH',10,'2019-02-28','2022/10/20'),
( 'MRKT',11,'2013-09-09','2022/10/20'),
( 'MRKT',12,'2015-01-06','2022/10/20'),
( 'CONT',13,'2018-05-09','2022/10/20'),
( 'DEV',14,'2019-07-20','2022/10/20'),
( 'RRHH',15,'2020-09-10','2022/10/20');
 
INSERT INTO  dept_emp (dept_no, emp_no,from_date,to_date)
 values
( 'DEV',6,'2018-06-04','2022/10/20'),
( 'RRHH',7,'2015-07-04','2022/10/20'),
( 'MRKT',8,'2020-09-16','2022/10/20'),
( 'CONT',9,'2016-03-31','2022/10/20'),
( 'CONT',10,'2019-02-28','2022/10/20'),
( 'DEV',11,'2013-09-09','2022/10/20'),
( 'CONT',12,'2015-01-06','2022/10/20'),
( 'MRKT',13,'2018-05-09','2022/10/20'),
( 'MRKT',14,'2019-07-20','2022/10/20'),
( 'DEV',15,'2020-09-10','2022/10/20');
 
 
SELECT * FROM dept_emp;
 
INSERT INTO  titles (emp_no, title,from_date,to_date)
 values
( 1,'carrera marketing','2000-06-04','2009/10/20'),
( 2,'carrera marketing','2001-07-04','2008/08/20'),
( 3,'carrera contabilidad','2002-09-16','2007/10/07'),
( 4,'carrera informatica','2003-03-31','2008/10/20'),
( 5,'curso RRHH','2009-02-28','2010/10/20'),
( 6,'carrera marketing','2006-09-09','2012/10/20'),
( 7,'carrera marketing','2012-01-06','2014/10/20'),
( 8,'carrera contabilidad','2009-05-09','2012/10/20'),
( 9,'carrera informatica','2009-07-20','2015/10/20'),
( 10,'carrera contabilidad','2010-09-10','2020/10/20'),
( 11,'carrera marketing','2016-06-04','2020/10/20'),
( 12,'carrera marketing','2018-07-04','2020/10/20'),
( 13,'carrera marketing','2015-09-16','2020/10/20'),
( 14,'carrera informatica','2014-03-31','2020/10/20'),
( 15,'curso RRHH','2003-02-28','2004/10/20');
 
SELECT * FROM titles;
 
INSERT INTO  salaries (emp_no, salary,from_date,to_date)
 values
( 1,15000,'2010-10-20','2014/10/20'),
( 1,45000,'2014/10/20','2022-10-20'),
( 2,15000,'2010-10-20','2014/10/20'),
( 2,45000,'2014/10/20','2022-10-20'),
( 3,15000,'2010-10-20','2014/10/20'),
( 3,45000,'2014/10/20','2022-10-20'),
( 4,15000,'2010-10-20','2014/10/20'),
( 4,45000,'2014/10/20','2022-10-20'),
( 5,15000,'2010-10-20','2014/10/20'),
( 5,45000,'2014/10/20','2022-10-20'),
( 6,20000,'2018-06-04','2022-10-20'),
( 7,25000,'2015-07-04','2022-10-20'),
( 8,20000,'2020-09-16','2022/10/20'),
( 9,30000,'2016-03-31','2022-10-20'),
( 10,25000,'2019-02-28','2022-10-20'),
(11,25000,'2013-09-09','2022-10-20'),
( 12,15000,'2015-01-06','2022-10-20'),
( 13,35000,'2018-05-09','2022-10-20'),
( 14,15000,'2019-07-20','2022-10-20'),
( 15,35000,'2020-09-10','2022-10-20');
 
SELECT * FROM salaries;
 
UPDATE departments SET dept_name='humanos recursos ' WHERE  dept_no='RRHH';
UPDATE departments SET dept_name='Contabilidad Financiera ' WHERE  dept_no='CONT';
UPDATE departments SET dept_name='informatica ' WHERE  dept_no='DEV';
UPDATE departments SET dept_name='marqueting ' WHERE  dept_no='MRKT';
 
SET SQL_SAFE_UPDATES = 0;
UPDATE employees SET first_name='Estefania' WHERE first_name  LIKE '%a' AND last_name LIKE 'F%' AND birth_date='1996-11-21';
SET SQL_SAFE_UPDATES = 1;

SELECT e.*,s.salary FROM employees e left join salaries s on e.emp_no=s.emp_no WHERE salary > 20000;
SELECT e.*,s.salary FROM employees e left join salaries s on e.emp_no=s.emp_no WHERE salary < 10000;
SELECT e.*,s.salary FROM employees e left join salaries s on e.emp_no=s.emp_no WHERE salary  < 50000 AND salary > 14000;
SELECT  COUNT(*) as 'Total employees'  FROM employees;

SELECT d.dept_name ,COUNT(d.dept_name) 
FROM dept_emp e left join departments d on e.dept_no=d.dept_no
GROUP BY dept_name HAVING COUNT(*)>1;

SELECT title FROM titles WHERE to_date LIKE '2020%'; 

SELECT first_name FROM employees WHERE first_name=CONCAT(UPPER(LEFT(first_name,1)),LCASE(SUBSTRING(first_name,2)));

SELECT e.first_name, e.last_name, dt.dept_name FROM  dept_emp d   
 join employees e on e.emp_no=d.emp_no 
 join departments dt on dt.dept_no=d.dept_no;
 
select e.first_name, e.last_name, count(d_m.emp_no) as no_times
from dept_manager d_m
left join employees e
on d_m.emp_no = e.emp_no
group by e.emp_no;


SELECT distinct(first_name) FROM employees;

    SET SQL_SAFE_UPDATES = 0; 
	DELETE employees
	FROM employees
	JOIN salaries
	ON employees.emp_no = salaries.emp_no
	WHERE salaries.salary > 20000;
    SET SQL_SAFE_UPDATES = 1;
    
     SET SQL_SAFE_UPDATES = 0; 
    DELETE depts FROM departments AS depts 
    JOIN(
    SELECT dept_no,COUNT(emp_no) AS num_emp
    FROM dept_emp
    GROUP BY dept_no
    ORDER BY num_emp DESC
    LIMIT 1)
   AS d ON depts.dep_no=d.dept_no
   Where depts.dept_no = d.dept_no;
    SET SQL_SAFE_UPDATES = 1;
