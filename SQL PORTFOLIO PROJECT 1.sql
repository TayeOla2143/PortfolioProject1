select * 
from dbo.CovidDeaths$

order by 3,4

select * 
from dbo.CovidVaccinations$
order by 3,4

-- Retrieving information we will using 

 select location,date, total_cases,new_cases,total_deaths,population
from dbo.CovidDeaths$
order by 1,2

-- looking at total_cases vs total_death 


 select location,date, total_cases,new_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
from dbo.CovidDeaths$
where location like '%state%'
order by 1,2



-- Looking at total cases vs population 
-- Retrieving total number that got Covid 

select location,date,population, total_cases,new_cases,(total_cases/population)*100 as population_infested 
from dbo.CovidDeaths$
where location like '%state%'
order by 1,2

-- Retrieving the countries with highest infection rate 
select location,population,MAX(total_cases) as highest_infection_count,MAX((total_cases/population))*100 as population_infested 
from dbo.CovidDeaths$
--where location like '%state%'
Group by location,population 
order by population_infested desc 

-- Retrieving the countries with highest number of Death per population

select location, MAX(cast(total_deaths as int)) as total_death_counts
from dbo.CovidDeaths$
--where location like '%state%'
where continent is not null
Group by location
order by total_death_counts desc
 -- let break it down to continents 

 select location, MAX(cast(total_deaths as int)) as total_death_counts
from dbo.CovidDeaths$
--where location like '%state%'
where continent is  null
Group by location
order by total_death_counts desc

--Global Number cases and Casualities 

select date, SUM(new_cases) as total_cases_global,SUM(cast(new_deaths as int)) as total_death_global ,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage_global
from dbo.CovidDeaths$
where continent is not null
--where location like '%state%'
Group by date 
order by 1,2 

--Global total cases VS Global death
select SUM(new_cases) as total_cases_global,SUM(cast(new_deaths as int)) as total_death_global ,
SUM(cast(new_deaths as int))/SUM(new_cases)*100 as death_percentage_global
from dbo.CovidDeaths$
where continent is not null
--where location like '%state%'
--Group by date 
order by 1,2 

-- Retrieving total population vs vaccination 

select distinct dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
from dbo.CovidDeaths$ dea 
join dbo.CovidVaccinations$ vac
on  dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null
order by 2,3

--Retrieving total population vs vaccination rolling over

select distinct dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location,dea.date) AS Rolling_over_vac_count
from dbo.CovidDeaths$ dea 
join dbo.CovidVaccinations$ vac
on  dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null
order by 2,3



--USE CTU

WITH pop_vs_vac(contient,location,date,population,Rolling_over_vac_count,new_vaccinations)
AS(
select distinct dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location,dea.date) AS Rolling_over_vac_count
from dbo.CovidDeaths$ dea 
join dbo.CovidVaccinations$ vac
on  dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null
)
select*,(Rolling_over_vac_count/population)*100 as percentage_rolling_over_per_pop from pop_vs_vac


--Temp Table 


drop table if exists #percentage_population_vaccinating

Create table #percentage_population_vaccinating
(
continent nvarchar(225),
location  nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_over_vac_count numeric
)
insert into #percentage_population_vaccinating
select distinct dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location,dea.date) AS Rolling_over_vac_count
from dbo.CovidDeaths$ dea 
join dbo.CovidVaccinations$ vac
on  dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null

select*,(Rolling_over_vac_count/population)*100 from #percentage_population_vaccinating

--Creating a view of visualization later in tableau and PowerBI

CREATE VIEW  percentage_population_vaccinating  AS 
select distinct dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location,dea.date) AS Rolling_over_vac_count
from dbo.CovidDeaths$ dea 
join dbo.CovidVaccinations$ vac
on  dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null






-- finding the % of rolling_over_vac_cout vs poopulation 

WITH pop_vs_vac(contient,location,date,population,Rolling_over_vac_count,new_vaccinations)
AS(
select distinct dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location
ORDER BY dea.location,dea.date) AS Rolling_over_vac_count
from dbo.CovidDeaths$ dea 
join dbo.CovidVaccinations$ vac
on  dea.date = vac.date 
and dea.location = vac.location
where dea.continent is not null
)
select *,(new_vaccinations/population)*100 from pop_vs_vac
