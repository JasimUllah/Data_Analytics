select * from CovidDeaths
order by 3,4

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2



-- Total Cases VS Total Deaths
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeatPercentage
from PortfolioProject..CovidDeaths
where location like '%states%'
order by 1,2



-- Totala Cases VS the Population
select location, date, population, total_cases, (total_cases/population)*100 as DeatPercentage
from PortfolioProject..CovidDeaths
where location like '%Pakistan%'
order by 1,2


-- Countries with highest infection compared to population
select location, population, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PopulationInfectedPercentage
from PortfolioProject..CovidDeaths
--where location like '%Pakistan%'
group by location, population
order by PopulationInfectedPercentage desc


-- Countries with the highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Pakistan%'
where continent is not null
group by location
order by TotalDeathCount desc


-- By Continent with the highest death count per poplation
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
--where location like '%Pakistan%'
where continent is not null
group by continent
order by TotalDeathCount desc


-- Global Numbers
select sum(new_cases) as TotalCases, sum(cast(new_deaths as int)) as TotalDeaths, 
	sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths
where continent is not null
--group by date
order by 1,2


-- Total population vs vaccination
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , 
	dea.date) as TotalPeopleVaccinated
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3




-- Useing CTE
with PopVsVacc(Continent, location, date, population, new_vaccinations, TotalPeopleVaccinated)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(cast(vac.new_vaccinations as int)) over (partition by dea.location order by dea.location , 
	dea.date) as TotalPeopleVaccinated --(TotalPeopleVaccinated/population)*100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccination as vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (TotalPeopleVaccinated/Population)*100
from PopVsVacc



-- Temp Table
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
TotalPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (TotalPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated




-- Creating view to store data for later visulizations
create view PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (TotalPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select *
from PercentPopulationVaccinated