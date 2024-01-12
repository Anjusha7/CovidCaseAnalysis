-- Some Data Exploration on Covid data  

-- checking out first data table 
select *
from Portfolio..CovidDeaths
order by 3, 4

--checking out second data table 
select *
from Portfolio..CovidVaccinations
order by 3, 4

select location, date, total_cases, new_cases, total_deaths, population
from Portfolio..CovidDeaths
order by 1, 2

--total cases vs total deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as deathPercentage
from Portfolio..CovidDeaths
--where location like '%india%'
order by 1, 2

--looking at total cases vs poplation (gives more info about what percentage of population got Covid
select location, date, population, total_cases, (total_cases/population)*100 as Covidpercentage
from Portfolio..CovidDeaths
--where location like '%india%'
order by 1, 2


--looking at countries with highest infection rate compared to population
select location, population, max(total_cases) as highestInfectedCount, max((total_cases/population))*100 as PercentagePopulationInfected
from Portfolio..CovidDeaths
group by location, population
order by PercentagePopulationInfected desc

--highest death count per population, drill down by continent
select continent, max(cast(total_deaths as int)) as Totaldeathcount
from Portfolio..CovidDeaths
where continent is not null
group by continent
order by Totaldeathcount desc

--looking at global numbers
select sum(new_cases) as totalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/  sum(new_cases)* 100 as deathpercentage
from Portfolio..CovidDeaths
where continent is not null
--group by date
order by 1,2 


select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVacinationCount
from Portfolio..CovidDeaths as dea
join  Portfolio..CovidVaccinations as vac
	on dea.location = vac.location and 
	dea.date = vac.date
where dea.continent is not null
order by 1,2,3


-- USE CTE
with popuVSvacc (continent,location,date, population, new_vaccinations,RollingVacinationCount)
as
(
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVacinationCount
from Portfolio..CovidDeaths as dea
join  Portfolio..CovidVaccinations as vac
	on dea.location = vac.location and 
	dea.date = vac.date
where dea.continent is not null
)

select*, (RollingVacinationCount/population) * 100 as RollingPercentPoulationVaccinated
from popuVSvacc


--Create the same as a temp table 

drop table if exists #PercentPeopleVaccinated -- so when modifications are made to the table, will not have to delete it multiple times 
Create Table #PercentPeopleVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingVacinationCount numeric
)

insert into #PercentPeopleVaccinated
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVacinationCount
from Portfolio..CovidDeaths as dea
join  Portfolio..CovidVaccinations as vac
	on dea.location = vac.location and 
	dea.date = vac.date

select *, (RollingVacinationCount/population) * 100 as RollingPercentPoulationVaccinated
from #PercentPeopleVaccinated


-- Create view to store data that can be later used for visualisations in tableau(for this project)

create view PercentPeopleVaccinated as 
select dea.continent,dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date) as RollingVacinationCount
from Portfolio..CovidDeaths as dea
join  Portfolio..CovidVaccinations as vac
	on dea.location = vac.location and 
	dea.date = vac.date
where dea.continent is not null


create view TotalDeathByContinent as 
select continent, max(cast(total_deaths as int)) as Totaldeathcount
from Portfolio..CovidDeaths
where continent is not null
group by continent
