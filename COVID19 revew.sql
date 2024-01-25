CREATE DATABASE portfolio_projects
USE Portfolio_Projects
GO

select * 
from portfolio_projects..[covid19-death-data]
ORDER BY 3,4

select * 
from portfolio_projects..[covid19_vacination_data]
ORDER BY 3,4

----select data that we going to be useing


select continent,location,date, total_cases_per_million ,new_cases,total_deaths,population
from portfolio_projects..[covid19-death-data]
order by 2,3
--- let see about ethiopia
select continent,location,date, total_cases_per_million,total_deaths,population
from portfolio_projects..[covid19-death-data]
where location LIKE 'Ethiopia%'
order by 3,4 DESC
--- looking at Total case vs Total Deaths
select location,date, total_cases_per_million ,total_deaths,(CONVERT(float,total_deaths) / NULLIF(CONVERT(float,total_cases_per_million),0))* 100 as DeathPercentage
from portfolio_projects..[covid19-death-data] AS Dea
where location ='Ethiopia'
order by 1,2

---  Total Deaths Vs Total case
select location,date, total_cases_per_million ,total_deaths,(CONVERT(float,total_cases_per_million) / NULLIF(CONVERT(float,total_deaths),0))* 100 as DeathPercentage
from DataAnalysis_portfolio_projects..[covid19-death-data]
where location ='Ethiopia'
order by 1,2

--- Countries to highst Infection Reat compared to Populations
select  Location ,Max(total_cases_per_million) Highst_Cases ,population,(CONVERT(float,Max(total_cases_per_million)) / NULLIF(CONVERT(float,population),0))* 100 as CasePercentage
from portfolio_projects..[covid19-death-data]
--where location ='Ethiopia'
GROUP BY total_cases_per_million ,population,Location
order by CasePercentage desc

--Countries Death reat Highst to Low
select  Location ,Max(cast(total_deaths as int)) as  Max_deaths 
from portfolio_projects..[covid19-death-data]
GROUP BY Location
order by Max_deaths desc

---Countries List Death reat per population
select  Location ,Max(total_deaths) as  Max_deaths ,population, (Max(CONVERT(float,total_deaths))/(CONVERT(float,population))*100) as Deaths_per_Population
from portfolio_projects..[covid19-death-data]
where location is not null
GROUP BY Location,population
order by Deaths_per_Population desc

-----------Continets------------


select  continent ,Max(cast(total_deaths as int)) as  Max_deaths 
from portfolio_projects..[covid19-death-data]
GROUP BY continent
order by Max_deaths desc

------Comparetion Total new_cases and new_deaths------
select  date,sum(cast(new_cases as int)) as Total_New_cases, sum(cast(new_deaths as int)) as Total_new_deaths
from  portfolio_projects..[covid19-death-data]
--where continent is not null
GROUP BY date
order by Total_New_cases desc
----------- comparetions of ICU Patient and Total Cases

SELECT date,
       SUM(CAST(total_cases_per_million AS FLOAT)) AS Total_cases_per_million,
       SUM(CAST(icu_patients_per_million AS FLOAT)) AS Total_icu_patients_per_million,
       (SUM(CAST(icu_patients_per_million AS FLOAT)) / SUM(CAST(total_cases_per_million AS FLOAT)) * 100) AS ICU_patients_per_Cases
FROM  portfolio_projects..[covid19-death-data]
--WHERE continent IS NOT NULL
GROUP BY date
HAVING SUM(CAST(total_cases_per_million AS FLOAT))>0
ORDER BY Total_cases_per_million DESC;


select * from covid19_vacination_data

------Comparetion Total new_cases VS Vaccinated------
select date,location,sum(cast(total_cases as float)) as Total_cases, sum(cast(people_vaccinated as float)) as People_vaccinated
from  portfolio_projects..[covid19_vacination_data]
--where continent is not null
GROUP BY total_cases
HAVING SUM(CAST(total_cases AS FLOAT))>0
order by location desc

---------OUT OF TOTAL POPULATION TO FIND NEW VACINATION PEOPLE FROM TOTAL NEW CASE-------

select Dea.continent, Dea.location,Dea.date,Dea.new_cases,vac.new_vaccinations
from [covid19-death-data] AS Dea
INNER JOIN [covid19_vacination_data] AS Vac
ON Dea.continent = Vac.continent
AND Dea.date = Vac.date
ORDER BY 3,4
-------- DEATHS FROM ICU_PATIENT BY FR0M 100%-----------
select Dea.location,Dea.date,Dea.icu_patients,vac.total_deaths,SUM(cast(vac.total_deaths as int))/NULLIF(SUM(cast(Dea.icu_patients as int)),0)*100 as DeathsFromicu_patient
from [covid19-death-data] AS Dea
INNER JOIN [covid19_vacination_data] AS Vac
ON Dea.location = Vac.location
AND Dea.date = Vac.date
WHERE Dea.icu_patients IS NOT NULL
GROUP BY Dea.location,Dea.date,Dea.icu_patients,vac.total_deaths
ORDER BY DeathsFromicu_patient DESC

--------------------AQUERY WITH THREE CTEs -------------
WITH COVID19_CASES (location,Highest_Cases,population)
AS
(
SELECT Location ,Max(total_cases_per_million) AS Highst_Cases ,population
FROM portfolio_projects..[covid19-death-data]
GROUP BY total_cases_per_million ,population,Location
),
------SELECT location,Highest_CasesFROM COVID19_CASES 
OVID19_VACINATION (continent, location, date,population, people_fully_vaccinated)
AS
(
SELECT continent, location, date,population, people_fully_vaccinated
FROM portfolio_projects..[covid19_vacination_data] 
),
VACINATION ( Location,Highest_Cases,date,people_fully_vaccinated,population) 
AS(
SELECT C.Location, C.Highest_Cases, O.date,O.population, O.people_fully_vaccinated
FROM COVID19_CASES C
INNER JOIN OVID19_VACINATION O
ON C.location = O.location
)
SELECT * 
FROM 
VACINATION;

------------------------RANK() --------------------------

select  Location ,date,SUM(CAST(total_cases as numeric)) AS Total_cases,RANK() OVER(ORDER BY Total_cases DESC) Rank_by_Cases
from DataAnalysis_portfolio_projects..[covid19_vacination_data]
where location is not null and date BETWEEN '2023-01-01' AND '2023-12-30'
GROUP BY Location,date,total_cases
order by 3 desc ;

SELECT Location, date, (SUM(TRY_CONVERT(INT, total_cases ))) AS Total_cases, RANK() OVER(ORDER BY Total_cases DESC) AS Rank_by_Cases 
FROM DataAnalysis_portfolio_projects..[covid19_vacination_data] 
GROUP BY Location, date ,total_cases
ORDER BY Total_cases DESC;

------- SQL CASE-----------

SELECT date,location,total_cases, CASE
   WHEN total_cases <= 10000 then 'It is noremal'
   WHEN total_cases <= 100000 then 'It is avreg'
   when total_cases > 100000 then 'It is higher'
   else 'Total cases under 10000'
END AS total_cases
FROM DataAnalysis_portfolio_projects..[covid19_vacination_data] as cov
where total_cases is not null 
GROUP BY total_cases,date,location;

---------------TEMP TABLE-------------------


CREATE TABLE #PercentPopulationVaccinated
(
Contenent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinations numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT Vac.continent, Vac.location, Vac.date , Vac.population,Vac.new_vaccinations,SUM(convert(numeric, Vac.new_vaccinations)) over (partition by date,Location Order by Vac.Location) as RollingPeopleVaccinations

from portfolio_projects..[covid19_vacination_data] as Vac
