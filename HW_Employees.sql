-- first excercise (Avg paycheck of the employees order by gender and department)
show tables in employees;
use employees;
select departments.dept_name, employees.gender, avg(salaries.salary) as `Average Salary` from employees
join dept_emp on employees.emp_no=dept_emp.emp_no
join departments on departments.dept_no = dept_emp.dept_no
join salaries on salaries.emp_no=employees.emp_no
group by departments.dept_name, employees.gender
order by departments.dept_name, employees.gender;

-- second excercise
-- minimum and maximum department numbers
select min(dept_no) as 'Minimum Department Number' from employees.dept_emp;
select max(dept_no) as 'Maximum Department Number' from employees.dept_emp;

-- third excercise
-- This selects the employee number, the minimum department number for each employee from the dept_emp table, and a manager value based on the employee number using a CASE statement. 
-- The manager value is assigned based on a specific range of employee numbers. The query only considers employees with an employee number up to 10040 from the employees table.
use employees;
select employees.emp_no,
(select min(dept_no) from dept_emp
 where employees.emp_no = dept_emp.emp_no)
 as dept_no, 
case
        when employees.emp_no <= 10020 then 110022 
        when employees.emp_no between 10021 and 10040 then 110039 
end as manager
from employees
where  employees.emp_no<= 10040;

-- fourth excercise 
-- employees hired in 2000
select *
from employees
where year(hire_date) = 2000;

-- fifth excercise
-- list of Engineers and Senior Engineers
select employees.first_name, employees.last_name, titles.title from employees
join titles using(emp_no)
where titles.title = 'Engineer'
limit 20;

select employees.first_name, employees.last_name, titles.title from employees
join titles using(emp_no)
where titles.title = 'Senior Engineer'
limit 20;

-- sixth excercise
-- procedure to get back the last department
use employees;
drop procedure if exists last_dept;
delimiter $$
create procedure last_dept(in p_emp_no integer)
begin
  select dept_name as 'last department' from departments
  join dept_emp on departments.dept_no = dept_emp.dept_no
  where p_emp_no = emp_no
  and to_date =(select max(to_date) from dept_emp);
end$$
delimiter ;

call last_dept(10010);

-- seventh excercise 
--  checking for employees who have worked for more than a year and have a salary greater than 100000.

select count(*) from salaries
where timestampdiff(year, from_date, if(to_date<now(), to_date, now())) > 1 
and salaries.salary > 100000;


-- eight excercise
-- trigger to check for inserting that hire_date is not greater than today's date
delimiter $$
drop trigger if exists trg_hire_date;
create trigger trg_hire_date
before insert on employees
for each row
begin
  if new.hire_date > now() then
    set new.hire_date = date_format(now(), '%Y-%m-%d');
  end if;
end$$
delimiter ;

use employees;
insert employees values('999904', '1970-01-31', 'John', 'Johnson', 'M', '2025-01-01');
select * from employees order by emp_no desc limit 10;

-- ninth excercise
-- get highest and lowest salary
drop function if exists get_highest_salary;
delimiter $$
create function get_highest_salary(p_emp_no int) returns decimal(10,2) deterministic
begin
    declare max_salary decimal(10,2);
    select max(salary) into max_salary 
    from salaries 
    where emp_no = p_emp_no;
    return max_salary;
end$$
delimiter ;

drop function if exists get_lowest_salary;
delimiter $$
create function get_lowest_salary(p_emp_no int) returns decimal(10,2) deterministic
begin
    declare min_salary decimal(10,2);
    select min(salary) into min_salary 
    from salaries 
    where emp_no = p_emp_no;
    return min_salary;
end$$
delimiter ;

select employees.get_highest_salary(10001) as 'highest salary';
select employees.get_lowest_salary(10001) as 'lowest salary';

-- tenth excercise
-- get highest or lowest salary back based on a second input parameter
drop function if exists get_extremum_salary;
delimiter $$
create function get_extremum_salary(p_emp_no int, p_type varchar(3)) returns decimal(10,2) deterministic
begin
    declare extremum_salary decimal(10,2);
    if (p_type = 'min') then
		select min(salary) into extremum_salary from salaries where emp_no = p_emp_no;
    elseif (p_type ='max') then 
		select max(salary) into extremum_salary from salaries where emp_no = p_emp_no;
	end if;
    return extremum_salary;
end$$
delimiter ;

select employees.get_extremum_salary(10001, 'min') as 'Minimum salary';
select employees.get_extremum_salary(10001, 'max') as 'Maximum salary';