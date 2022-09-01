
select *
from PortfolioProject..CovidDeaths
order by 3,4;

-- Select data that we are going to be using

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths

select location, date, total_cases, total_deaths, (cast(total_deaths as int)/total_cases)*100 as 'death_percantage'
from PortfolioProject..CovidDeaths
where location='Egypt'
order by 1,2;

-- Infection Rate

select location, date, total_cases, total_deaths, (total_cases/population)*100 as 'infection_rate'
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2;

-- Looking at countries with highest infection rate compared to population

select location, population, max(total_cases) as 'highest_infection_count', max((total_cases/population))*100 as 'infection_rate'
from PortfolioProject..CovidDeaths
group by location, population
order by infection_rate desc;

-- Showing countries with highest death count per population

select location, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is not null
group by location
order by total_death_count desc;

-- Highest death to total cases rate

select location, max(total_cases) as highest_total_cases, max(cast(total_deaths as int)) as highest_total_deaths, (max(cast(total_deaths as int))/max(total_cases))*100 as 'death_percantage'
from PortfolioProject..CovidDeaths
-- where location like '%states%'
group by location
order by death_percantage desc;

-- Total deaths by continent

select location, max(cast(total_deaths as int)) as total_death_count
from PortfolioProject..CovidDeaths
where continent is null
group by location
order by total_death_count desc;

-- Global Numbers

select date, sum(new_cases) as total_world_cases, sum(cast(new_deaths as int)) as total_world_deaths,
(sum(cast(new_deaths as int))/sum(new_cases))*100 as death_percantage
from PortfolioProject..CovidDeaths
where continent is not null
group by date
order by 1;

-- Covid vaccinations

select *
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
order by dea.location, dea.date;

-- Total population vs vaccinations

select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Use CTE

with popvsvac (continent, location, date, population, new_vaccinations, rolling_people_vaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location like '%states%'
)
select *, (rolling_people_vaccinated/population)*100 as vaccinated_people_percentage
from popvsvac

-- TEMP Table

drop table if exists #popvsvac
create table #popvsvac (
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rolling_people_vaccinated numeric
)

insert into #popvsvac
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
and dea.location like '%states%'

select *, (rolling_people_vaccinated/population)*100 as vaccinated_people_percentage
from #popvsvac

-- Creating a view

create view popvsvac2 as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location, dea.date)
as rolling_people_vaccinated
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--and dea.location like '%states%'

select * from popvsvac2;