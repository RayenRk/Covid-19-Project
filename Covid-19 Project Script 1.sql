--select *
--from [Covid-19 Project]..CovidDeaths
--order by 3,4

--select *
--from [Covid-19 Project]..CovidVaccinations
--order by 3,4


select location, date, total_cases, new_cases, total_deaths, population
from [Covid-19 Project]..CovidDeaths
order by 1,2


-- total cases vs total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from [Covid-19 Project]..CovidDeaths
where location like '%Tunisia%'
order by 1,2

-- total cases vs population

select location, date, total_cases, population, (total_cases/population)*100 as DeathPercentage
from [Covid-19 Project]..CovidDeaths
where location like '%Tunisia%'
order by 1,2

-- countries with highest infection rate vs population

select location, population, max(total_cases) as HighestInfectionCount, MAX(total_cases/population)*100 as PercentOfPopulationInfected
from [Covid-19 Project]..CovidDeaths
-- where location like '%Tunisia%'
group by population,location
order by PercentOFPopulationInfected desc

-- countries with the highest deathcount per population

select location, max(cast(total_deaths as int)) as TotalDeathCount
from [Covid-19 Project]..CovidDeaths
-- where location like '%Tunisia%'
where continent <> ''
group by location
order by TotalDeathCount desc

-- continents with the highest death count

select continent, max(cast(total_deaths as int)) as TotalDeathCount
from [Covid-19 Project]..CovidDeaths
-- where location is 'Tunisia'
where continent is not null
group by continent
order by TotalDeathCount desc

-- Global numbers

select date, sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Covid-19 Project]..CovidDeaths
-- where location = 'Tunisia'
where continent is not null
group by date
order by 1,2

select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, sum(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from [Covid-19 Project]..CovidDeaths
-- where location = 'Tunisia'
where continent is not null
-- group by date
order by 1,2


-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
	over (partition by dea.location order by dea.location , dea.date) as VaccinationIncremented
from [Covid-19 Project]..CovidDeaths dea
join [Covid-19 Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
 	order by 2,3


-- CTE

with Vacvspop (Continent, Location, Date, Population, New_Vaccinations, VaccinationInceremented)
as 
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(cast(vac.new_vaccinations as int))
	over (partition by dea.location order by dea.location , dea.date) as VaccinationIncremented
from [Covid-19 Project]..CovidDeaths dea
join [Covid-19 Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
 	--order by 2,3
)

Select *, (VaccinationInceremented/Population)*100 as VaccinationPercentage
from Vacvspop

-- temp table

drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
VaccinationIncremented numeric
)

insert into #PercentPopulationVaccinated
 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.Date) as VaccinationIncremented
from [Covid-19 Project]..CovidDeaths dea
join [Covid-19 Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
 	--order by 2,3

select *, (VaccinationIncremented/Population)*100
from #PercentPopulationVaccinated



-- View for visualization


Create view PercentPopulationVaccinated as 

 select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
 , sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,
 dea.Date) as VaccinationIncremented
from [Covid-19 Project]..CovidDeaths dea
join [Covid-19 Project]..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
	where dea.continent is not null
 	--order by 2,3
	
Select *
from PercentPopulationVaccinated