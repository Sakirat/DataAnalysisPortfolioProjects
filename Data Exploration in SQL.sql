/*

Cleaning Exploration in SQL Queries

*/

select top 5 *
from CovidDeaths

select top 5 *
from CovidVaccinations

	

select *
from PortfolioProject..CovidDeaths
order by 3,4

select *
from PortfolioProject..CovidVaccinations
order by 3,4

--Select relevant Columns of the Dataset to be used

select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths and the likelihood of dying if virus is contracted

select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2

--looking at the total cases vs population showing percentage of population that got Covid

select location, date, population, total_cases, (total_cases/population)*100 as Covid_Percentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at Countries arranged by infection rate from higest to lowest

select location, date, population, total_cases, (total_cases/population)*100 as Covid_Percentage
from PortfolioProject..CovidDeaths
--where location like '%states%'
order by 5 desc

--Looking at the country with the highest infection rate compared to population

select location, population, Max(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as Covid_Percentage
from PortfolioProject..CovidDeaths
group by Location, Population
Order by 4 desc


--showing Countries with Highest Death Count Per Population

Select Location, Max(Cast(total_deaths as int)) as total_death_Count, Max(Population) as MaxPop
From PortfolioProject.dbo.CovidDeaths
where continent is not null
Group by Location
order by 2 desc

--Lets break things down by continent

Select location, Max(Cast(total_deaths as int)) as total_death_Count
From PortfolioProject.dbo.CovidDeaths
where continent is null
Group by location
order by 2 desc

-- showing continent with the highest death count per population

select continent,  Max(Cast(total_deaths as int)) as total_death_Count
From PortfolioProject.dbo.CovidDeaths
where continent is not null
group by continent
order by 2 desc

--GLOBAL NUMBERS

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as Death_Percentage
From PortfolioProject.dbo.CovidDeaths
where continent is not null
--group by date
order by 1,2


--Joining the two tables on common column of location and date

Select *
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date


-- Looking at Total Population vs Vaccinations

Select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


---using CTE to look at Total Population vs Vaccinations

with TotPopVac (location, continent, date, population, new_vaccinations, RollingPeopleVaccinated)
as 
(
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,3
) 
Select *, (RollingPeopleVaccinated/Population)*100 
from TotpopVac



---using Temp Table to look at Total Population vs Vaccinations

Drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Location nvarchar(255),
Continent nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated

select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--order by 1,3

Select *, (RollingPeopleVaccinated/Population)*100 
from #PercentPopulationVaccinated



---using View to look at Total Population vs Vaccinations

create view PercentPopulationVaccinated as
select dea.location, dea.continent, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int,vac.new_vaccinations)) over (partition by dea.Location order by dea.location, dea.date) as RollingPeopleVaccinated
From PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 1,3

select * 
from PercentPopulationVaccinated
