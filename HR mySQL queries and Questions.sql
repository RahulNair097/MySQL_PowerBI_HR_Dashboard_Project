-- create database name project :
create database Projects;

use Projects;

-- Check is the import data is correctly place in table or not :
select * from hr;

-- Now starting cleaning the data
Alter table hr change column ï»¿id emp_id varchar(20) Null;  -- change the column names.
select * from hr;

describe hr;

select birthdate from hr;

set sql_safe_updates =0; -- Like the previous UPDATE command, run the following UPDATE command 
						 -- without WHERE clause to check the update operation works or not after disabling the safe update mode.

show variables like " sql_safe_update"; 

update hr 
set birthdate = case 
	when birthdate like '%/%' then date_format(str_to_date(birthdate,'%m/%d/%Y'), '%Y-%m-%d')
	when birthdate like '%-%' then date_format(str_to_date(birthdate,'%m-%d-%Y'), '%Y-%m-%d')
	else null
end;

select birthdate from hr;

alter table hr modify column birthdate Date;

describe hr ;

update hr 
set hire_date = case 
	when hire_date like '%/%' then date_format(str_to_date(hire_date,'%m/%d/%Y'), '%Y-%m-%d')
	when hire_date like '%-%' then date_format(str_to_date(hire_date,'%m-%d-%Y'), '%Y-%m-%d')
	else null
end;

select hire_date from hr;
alter table hr modify column hire_date date;

desc hr;

select termdate from hr;

update hr
set termdate = date(str_to_date(termdate,'%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate != '';

select termdate from hr;

alter table hr modify column termdate date;

desc hr;


alter table hr add column age int;

select  * from hr;

update hr set age = timestampdiff(YEAR,birthdate,curdate());   -- to add age of perticular emp. in columns name age.

select birthdate, age from hr;

select 
min(age) as youngest,
max(age) as oldest 
from hr;

select count(*) from hr where age <18;

-- -------------------------------------------------------------------------------------------------
-- Questions :

-- 1. What is the gender breakdown of employees in the company?
select gender, count(*) as count from hr where age >=18 and termdate = '' group by gender;

-- 2. What is  the race.ethnicity breakdown of employees in the company?
select race, count(*) as count from hr where age >=18 and termdate = '' group by race order by count(*) desc;

-- 3. What is the age distribution of employees in the company?
select min(age) as youngest, max(age) as oldest from hr where age >=18 and termdate = '';
-- to get the age group :
select 
	case 
		when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
		when age>=55 and age<=64 then '55-64'
        else '65+'
	end as age_group,
    count(*) as count
from hr
where age >=18 and termdate = '' group by age_group order by age_group;

-- how gender is distirbuted among the age-group :
select 
	case 
		when age>=18 and age<=24 then '18-24'
        when age>=25 and age<=34 then '25-34'
        when age>=35 and age<=44 then '35-44'
        when age>=45 and age<=54 then '45-54'
		when age>=55 and age<=64 then '55-64'
        else '65+'
	end as age_group, gender,
    count(*) as count
from hr
where age >=18 and termdate = '' group by age_group, gender order by age_group, gender;

-- 4. How many employees work at headquarters versus remote loaction ?
select location, count(*) as count from hr where age >=18 and termdate = '' group by 1;

-- 5. What is the average length of employment for employees who have been terminated?
select avg(datediff(termdate,hire_date))/365 as avg_len_emp from hr where age >=18 and termdate <> '' and termdate <= curdate();

-- 6. How does the gender distribution vary across departments and job title?
select  department, gender, count(*) as count
from hr where age >=18 and termdate <> ''  group by 1,2 order by 1;

-- 7. What is the distribution of job titles across the country?
select jobtitle, count(*) as count from hr where age >=18 and termdate <> ''  group by 1 order by 1 desc;

-- 8. which department has the highest turnover rate?
select department,
	total_count, 
    termination_count,
    termination_count/total_count as termination_rate
from (
		select department, 
			count(*) as total_count,
			sum(case when termdate <> '' and  termdate <= curdate() then 1 else 0 end) as termination_count
		from hr where age >=18 group by department) as subquery
order by 4 desc;
        
-- 9. What is the distribution of employees across locations by city and state?
select location_state, count(*) as count from hr where age >=18 and termdate <> '' group by 1 order by 2 desc;

-- 10.  How has the company's employees count changed over time based on hire and term date?
select year, hires, terminations, hires-terminations as net_change, round((hires-terminations)/hires*100,2) as net_chg_per
from (
		select year(hire_date) as year, count(*) as hires, 
			sum(case when termdate <> '' and termdate <=curdate() then 1 else 0 end) as terminations
		from hr where age >=18 group by year) as subquery
order by year asc;

-- 11. What is the  tenure distribution for each department?
select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr where age >= 18 and termdate <= curdate() and termdate <> ''
group by department order by 1;




    