/*1*/
CREATE TABLE users(
	id  INT(11) UNSIGNED  PRIMARY KEY AUTO_INCREMENT,
 	username VARCHAR(30) NOT NULL UNIQUE,
 	`password` VARCHAR(50) NOT NULL,
 	name VARCHAR(50),
 	gender VARCHAR(1),
	birthdate DATETIME,
	age  INT(11) UNSIGNED ,
 	email VARCHAR(50) NOT NULL
);

CREATE TABLE departments(
	id  INT(11) UNSIGNED  PRIMARY KEY AUTO_INCREMENT,
 	name VARCHAR(50) NOT NULL
);

CREATE TABLE employees(
	id  INT(11) UNSIGNED   PRIMARY KEY AUTO_INCREMENT,
 	first_name VARCHAR(25),
 	last_name VARCHAR(25),
	gender VARCHAR(1),
 	birthdate DATETIME,
 	age INT(11) UNSIGNED,
 	department_id  INT(11) UNSIGNED   NOT NULL,
 	CONSTRAINT fk_employees_departments 
	FOREIGN KEY(department_id) REFERENCES departments(id)
);

CREATE TABLE categories(
	id  INT(11) UNSIGNED  PRIMARY KEY AUTO_INCREMENT,
 	name VARCHAR(50) NOT NULL,
   department_id  INT(11) UNSIGNED ,
 	CONSTRAINT fk_categories_departments 
	FOREIGN KEY(department_id) REFERENCES departments(id)
);

CREATE TABLE `status`(
	id  INT(11) UNSIGNED  PRIMARY KEY AUTO_INCREMENT,
 	label VARCHAR(30) NOT NULL
);

CREATE TABLE reports(
	id  INT(11) UNSIGNED  PRIMARY KEY AUTO_INCREMENT,
 	category_id  INT(11) UNSIGNED  NOT NULL,
 	status_id  INT(11) UNSIGNED  NOT NULL,
 	open_date DATETIME NOT NULL,
 	close_date DATETIME,
 	description VARCHAR(200),
 	user_id  INT(11) UNSIGNED  NOT NULL,
 	employee_id  INT(11) UNSIGNED,
 	CONSTRAINT fk_reports_categories FOREIGN KEY(category_id) REFERENCES categories(id),
 	CONSTRAINT fk_reports_employees FOREIGN KEY(employee_id) REFERENCES employees(id),
 	CONSTRAINT fk_reports_status FOREIGN KEY(status_id) REFERENCES `status`(id),
 	CONSTRAINT fk_reports_users FOREIGN KEY(user_id) REFERENCES users(id)
);

/*2*/
INSERT INTO employees(first_name,last_name,gender,birthdate,department_id)
VALUES ('Marlo','O\'Malley', 'M', '1958-09-21',1),
('Niki','Stanaghan', 'F',	'1969-11-26',4),
('Ayrton','Senna', 'M',	'1960-03-21',9),
('Ronnie','Peterson', 'M',	'1944-02-14',9),
('Giovanna','Amati', 'F',	'1959-07-20',5);

INSERT INTO reports(category_id,status_id,open_date,close_date,description,user_id,employee_id)
VALUES (1,1,'2017-04-13', NULL,	'Stuck Road on Str.133',6,2),
(6,3,'2015-09-05', '2015-12-06',	'Charity trail running',3,5),
(14,2,'2015-09-07', NULL,	'Falling bricks on Str.58',5,2),
(4,3,'2017-07-03', '2017-07-06',	'Cut off streetlight on Str.11',1,1);

/*3*/
update reports
set status_id = 2
where status_id = 1 and category_id = 4;

/*4*/
delete from reports
where status_id = 4;

/*5*/
select username, age from Users
order by age asc, username desc;

/*6*/
select description, open_date from Reports as r 
where r.Employee_Id is null order by open_date, description;

/*7*/
select first_name, last_name, description, DATE_FORMAT(open_date, "%Y-%m-%d") AS `open_date` from employees as e 
	join reports as r on r.Employee_Id = e.Id
order by e.Id, open_date;

/*8*/
select c.name, count(c.id) as `reports_number` from categories as c 
	inner join reports as r on r.Category_Id = c.Id
	group by c.name
	order by reports_number asc,c.name;
	
/*9*/
select c.name, count(e.Id) as `employees_number` from categories as c
	inner join departments as d on d.Id = c.Department_id
	inner join employees as e on d.Id = e.Department_Id
	group by c.name
	order by c.name;
	
/*10*/
select distinct c.name from categories as c 
	inner join reports as r on r.Category_Id = c.Id
	inner join users as u on r.User_Id = u.id
where DAY(r.Open_Date) = day(u.birthdate) and month(r.Open_Date) = month(u.birthdate)
order by c.Name;

/*11*/
select concat(e.first_name, ' ', e.last_name) as `full_name`, count(r.User_Id) as `users_count` from employees as e 
	left join reports as r on r.Employee_Id = e.id
	group by full_name
	order by users_count desc,full_name;
	
/*12*/
select r.open_date, r.description, u.email from reports as r
	inner join users as u on r.User_Id = u.Id
	inner join categories as c on c.id = r.category_id
	inner join departments d on d.id = c.Department_id 
where r.close_date is null 
and char_length(r.Description) > 20 
and r.Description like '%str%' > 0
and c.department_id in (1,4,5)
order by r.Open_Date, u.email; 

/*13*/
SELECT DISTINCT u.Username FROM Users u
JOIN Reports r on r.User_Id = u.id
JOIN Categories c ON c.id = r.Category_Id
WHERE (CAST(c.id as char(50)) = LEFT(u.username, 1)) OR
       (CAST(c.id as char(50)) = RIGHT(u.username, 1))
ORDER BY u.Username;

/*14*/
SELECT fn, CONCAT(cnt_closed, '/', cnt_open) FROM (
		SELECT
		   CONCAT(e.first_name, ' ', e.last_name) as fn,
		   COUNT(
			   CASE 
			      WHEN YEAR(close_date) = 2016 THEN 'closed'
			      WHEN YEAR(open_date) < 2016 AND YEAR(close_date) = 2016 THEN 'closed'
			   END) cnt_closed,
		   COUNT(
				   CASE 
				      WHEN YEAR(open_date) = 2016 THEN 'open'
		   END) AS cnt_open
		   FROM reports r
		   JOIN employees e
		   ON r.employee_id = e.id   
		   GROUP BY fn
		   HAVING cnt_open > 0 OR cnt_closed > 0) w
   order by w.fn

/*15*/
SELECT d.Name AS Department_name,
       CASE
           WHEN SUM(TIMESTAMPDIFF(DAY, R.Open_date, R.Close_date)) IS NULL
             THEN 'no info'
		 ELSE floor(CAST(AVG(TIMESTAMPDIFF(DAY, R.Open_date, R.Close_date)) AS char(100)))
       END AS `Myaverage`
FROM Departments AS D
     JOIN Categories AS C ON C.Department_Id = D.Id
     LEFT JOIN Reports AS R ON R.Category_Id= C.Id
GROUP BY D.Name
order by d.name;

/*16*/
SELECT d.name, c.name,
FORMAT((SELECT COUNT(*) FROM reports rc WHERE rc.category_id = c.id) / (SELECT COUNT(*) 
    FROM reports rd 
    WHERE rd.category_id IN 
        (SELECT cd.id FROM categories cd 
            JOIN departments dd ON cd.department_id=dd.id WHERE dd.id = d.id))
            * 100, 0) p
 FROM 
departments d
JOIN categories c
ON d.id = c.department_id
JOIN reports r ON r.category_id = c.id
WHERE r.user_id IS NOT NULL
GROUP BY d.name, c.name
ORDER BY d.name, c.name, p

/*17*/
CREATE FUNCTION udf_get_reports_count(employee_id INT, status_id INT)
RETURNS INT
BEGIN
	DECLARE reports_count INT;
	SET reports_count := 
		(SELECT COUNT(r.id) FROM reports AS r 
		WHERE r.Employee_Id = employee_id 
		and r.Status_Id = status_id);
	RETURN reports_count;
END

/*18*/
CREATE PROCEDURE usp_assign_employee_to_report(employee_id INT, report_id INT) 
BEGIN
	DECLARE employee_department_id int;
	DECLARE report_category_id int;
	DECLARE category_department_id int;
	
	set employee_department_id := (SELECT department_id FROM employees AS e WHERE e.id = employee_id);
	set report_category_id := (SELECT category_id FROM reports AS r WHERE r.id = report_id);
	set category_department_id := (SELECT department_id FROM categories as c WHERE c.id = report_category_id);
	
	START TRANSACTION;
		IF(employee_department_id != category_department_id) THEN
			SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Employee doesn\'t belong to the appropriate department!';
			ROLLBACK;
		ELSE
			UPDATE reports AS r
			SET r.employee_id = employee_id
			WHERE r.id = report_id;
		END IF;
	COMMIT;
END

/*19*/
create trigger t_update_close_date
BEFORE UPDATE ON reports 
FOR EACH ROW
BEGIN
	if(old.close_date is null and new.close_date is not null) then
		set new.status_id = 3;
	end if;
end

/*20*/
SELECT c.name,
    COUNT(r.id),
    CASE 
        WHEN (SELECT COUNT(*) FROM reports rr WHERE rr.status_id = (SELECT id FROM status WHERE label = 'waiting') AND rr.category_id = c.id) >
        (SELECT COUNT(*) FROM reports rr WHERE rr.status_id = (SELECT id FROM status WHERE label = 'in progress')  AND rr.category_id = c.id)
        THEN 'waiting'
        WHEN (SELECT COUNT(*) FROM reports rr WHERE rr.status_id = (SELECT id FROM status WHERE label = 'waiting')  AND rr.category_id = c.id) <
        (SELECT COUNT(*) FROM reports rr WHERE rr.status_id = (SELECT id FROM status WHERE label = 'in progress')  AND rr.category_id = c.id)
        THEN 'in progress'
        ELSE 'equal'
    END as main_status
FROM categories c
JOIN reports r
ON r.category_id = c.id
JOIN status s
ON r.status_id = s.id
WHERE s.label IN ('waiting', 'in progress')
GROUP BY c.name
