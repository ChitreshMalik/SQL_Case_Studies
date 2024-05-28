create  database Campusx;
use campusx;
select * from salaries;

-- Q1 1.	You're a Compensation analyst employed by a multinational corporation.
-- Your Assignment is to Pinpoint Countries who give work fully remotely, for the title 'managers’ Paying salaries Exceeding $90,000 USD


-- from the above problem first we hav to filter companies who give work remotely and have manager in job title
-- 2nd we will group by them by company_loaction and then filter on the basis of avg salary
select *from salaries;
select distinct(job_title) from salaries
where job_title like "%Manager%"


-- Ans1

select company_location from 
(select company_location,round(avg(salary_in_usd),2) as average from salaries
where remote_ratio=100 and job_title like "%Manager%"
group by company_location
having average>90000)t


-- 2.	AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms.
-- you're tasked WITH Identifying top 5 Country Having greatest count of large (company size) number of companies.

select Company_location ,count(company_location) as cnt from salaries
where company_size="L"
group by company_location
order by cnt desc
limit 5;


-- 3.3.	Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
-- Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.
select * from salaries

-- no. of employees who are working as remote
set @total =(select count(*) from salaries where remote_ratio=100)
select @total

-- no. of employees who are woking remote and salary greater than 100,000
set @filtered=(select count(*) from salaries where remote_ratio=100 and salary_in_usd>100000 )
select @filtered


--  percentage of employees who have salary greater than 100000 and do remote work
set @per=(select round((@filtered/@total)*100,2)   )
-- Per_of people who met the criteria
select @per

-- 4.	Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average 
-- salaries exceed the average salary for that job title IN market for entry level, helping your agency guide candidates towards lucrative opportunities.
select*from salaries

select a.company_location,a.job_title,a.avg_salary,b.avg_market
from 
(select company_location , job_title,round(avg(salary_in_usd),2) as avg_salary from salaries
 where experience_level="EN"
group by company_location ,job_title) as a
inner join 
(select  job_title,round(avg(salary_in_usd),2) as avg_market from salaries
 where experience_level="EN"
group by job_title) as b
on a.job_title=b.job_title
where a.avg_salary>b.avg_market
;

-- Ans with window func 
select * from
(select company_location,job_title, round(avg(salary_in_usd) over (partition by company_location,job_title),2) as avg_by_loc,
round(avg(salary_in_usd) over (partition by job_title),2) as avg_market
from salaries)t
where avg_by_loc>avg_market




-- 5.	You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries.
-- Your job is to Find out for each job title which. Country pays the maximum average salary. This helps you to place your candidates IN those countries.

select * from salaries

-- from this query you can find for particular job_title who is paying maximum sallary and where to send our candidates where they can get maximumx pay for their work

select Company_location,job_title,average from(
select *,dense_rank() over (partition by job_title order by average desc) as rnk
from(
select company_location,job_title,avg(salary_in_usd) as average from salaries
group by company_location,job_title
)t)a where rnk=1

/* 6.	AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available
 for 3 years Only(present year and past two years) providing Insights into Locations experiencing Sustained salary growth.  */


 select  * from salaries
 select current_date()
 
-- these are the countries where yoy growth increased in last 3 years 
select company_location,
MAX(case when work_year= 2022 then average end) as avg_2022,
MAX(case when work_year= 2023 then average end) as avg_2023,
MAX(case when work_year= 2024 then average end) as avg_2024 from
 (
 with derived_table as (-- from this cte what we get the data where Company_location have last 3 year 
 -- data b/c we are finding yoy for 3 years if data is not available then we can count that location
 select * from salaries
 where company_location in (
 select company_location from(
 select company_location, count(distinct work_year) as cnt from salaries
 where work_year >=(year(current_date())-2)
 group by company_location 
 having cnt=3)a) and work_year>=(year(current_date())-2)
 )
 select company_location,work_year,avg(salary_in_usd) as average from derived_table
 group by company_location,work_year
 order by company_location,work_year 
 )t
 GROUP BY cOMPANY_location
 having avg_2023>avg_2022 and avg_2024>avg_2023
 


-- Picture yourself AS a workforce strategist employed by a global HR tech startup. 
-- Your Mission is to Determine the percentage of fully remote work for each experience level IN 2021 and compare 
-- it WITH the corresponding figures for 2024, Highlighting any significant Increases or decreases IN remote work Adoption over the years.

