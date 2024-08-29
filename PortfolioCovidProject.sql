select *
from CovidDeaths$ 

select *
from CovidVaccinations

select location, date, total_cases, new_cases, total_deaths, population
from CovidDeaths$ 
order by 1,2

-- Looking at total cases VS total deaths

select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
from CovidDeaths$ 
where location like '%states%'
order by 1,2

-- Looking at total cases VS population

select location, date, population, total_cases, (total_cases/population)*100 as Death_Percentage
from CovidDeaths$ 
order by 1,2

-- Looking at countries with highest infection rate compared to population

select location, population, MAX(total_cases) as highest_infectioncount, MAX((total_cases/population))*100 as PopulationInfectedPercent
from CovidDeaths$ 
group by location, population
order by PopulationInfectedPercent DESC

-- Showing countries with highest death count per population

select location, MAX(cast (total_deaths as int)) as total_deathscount
from CovidDeaths$
where continent is not null
group by location
order by total_deathscount DESC

-- Showing continents with highest death count per population

select continent, MAX(cast (total_deaths as int)) as total_deathscount
from CovidDeaths$
where continent is not null
group by continent
order by total_deathscount DESC
 
 -- Global Numbers

select date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage 
from CovidDeaths$
where continent is not null
group by date
order by 1,2

select sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathpercentage 
from CovidDeaths$
where continent is not null
order by 1,2


-- looking at total population VS vaccinations

-- USE CTE

With PopVSVac (continet, location, date, population, new_vaccinations, rollingpeoplevaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null
)

select *, (rollingpeoplevaccinated/population)*100
from PopVSVac

-- creating view for later visualizations

Create view PercentPopulationVaccinated as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(int, vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
from CovidDeaths$ dea
join CovidVaccinations vac
   on dea.location = vac.location
   and dea.date = vac.date
where dea.continent is not null