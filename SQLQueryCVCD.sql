
--select * from PortfolioP..CovidVacctinations
--order by 3,4
--select data that we are going to be using

select * from PortfolioP..CovidDeaths
order by 1,2;

-- total cases VS total deaths
--  total deaths percentage by country

SELECT location, date, total_cases,total_deaths, (CONVERT(float, total_deaths) / CONVERT(float, total_cases))*100 AS "Death Percentage"
FROM PortfolioP..CovidDeaths
where location like '%Kingdom%'
order by 1,2;

--total cases VS population
SELECT location, date, population,total_cases, ( CONVERT(float, total_cases)/population)*100 AS "Cases Percentage"
FROM PortfolioP..CovidDeaths
where location like '%Georgia%'
order by 1,2;

--Looking at Countries with highest infection rate compared to population
SELECT location,  population,MAX(total_cases) AS "Highest Infection Count", MAX(( CONVERT(float, total_cases)/population)*100) AS "Cases Percentage"
FROM PortfolioP..CovidDeaths
GROUP BY location, population
order by "Cases Percentage" DESC



--Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths as int)) AS "Total deaths Count"
FROM PortfolioP..CovidDeaths
where continent is not null
GROUP BY continent
order by "Total deaths Count" DESC

--GLOBAL NUMBERS
SELECT  SUM(CAST(new_cases AS INT)) AS "Total cases", SUM(CAST(new_deaths AS INT)) "Total deaths", SUM(CONVERT(float, new_deaths )) / SUM(CONVERT(float, new_cases ))* 100  AS "Death Percentage"
FROM
    PortfolioP..CovidDeaths
	WHERE continent is not null

	order by 1,2

	--Total population VS vacctination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date ) AS RollingPeopleVaccinated
from PortfolioP..CovidDeaths dea
join PortfolioP..CovidVacctinations vac
on dea.location =vac.location
and dea.date = vac.date
where  dea.continent is not null
order by 2,3

--USE CTE
WITH PopvsVac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)

as (

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date ) AS RollingPeopleVaccinated
from PortfolioP..CovidDeaths dea
join PortfolioP..CovidVacctinations vac
on dea.location =vac.location
and dea.date = vac.date
where  dea.continent is not null )

select * , (RollingPeopleVaccinated/population)*100
from PopvsVac

--TEMP TABLE
Drop table if exists #PercentPopulationVvaccinated
create table #PercentPopulationVvaccinated

(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
insert into #PercentPopulationVvaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date ) AS RollingPeopleVaccinated
from PortfolioP..CovidDeaths dea
join PortfolioP..CovidVacctinations vac
on dea.location =vac.location
and dea.date = vac.date
--where  dea.continent is not null )

select * , (RollingPeopleVaccinated/population)*100
from #PercentPopulationVvaccinated


--creating view to store data for later visualizations

create view PercentPopulationVvaccinated
as 
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(float,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location,dea.date ) AS RollingPeopleVaccinated
from PortfolioP..CovidDeaths dea
join PortfolioP..CovidVacctinations vac
on dea.location =vac.location
and dea.date = vac.date
where  dea.continent is not null 

select * from PercentPopulationVvaccinated