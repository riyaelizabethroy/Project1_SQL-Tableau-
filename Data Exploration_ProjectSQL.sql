Select * From PortfolioProject..CovidDeaths
Order by 3,4

--Select * From PortfolioProject..CovidDeaths
--where continent is not null
--Order by 3,4

--Select * From PortfolioProject..CovidVaccinations
--Order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Order by 1,2

----Total cases vs Total Deaths
--Shows Likelihood of dying if you contract covid in your country

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where location like '%states%'
Order by 1,2

--Total cases vs Total Population
Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--where location like '%states%'
Order by 1,2

--Countries with Highest Infection Rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by 1,2

Select location, population, MAX(total_cases) as HighestInfectionCount, Max(total_cases/population)*100 as 
PercentPopulationInfected
From PortfolioProject..CovidDeaths
Group by location, population
Order by PercentPopulationInfected desc

--showing countries with highest death count per population
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by location
Order by TotalDeathCount desc

--showing continents with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
where continent is not null
Group by continent 
Order by TotalDeathCount desc

--Global
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
Group by date
Order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, 
SUM(CAST(new_deaths as int))/SUM(new_cases)*100 DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
Order by 1,2

Select * From PortfolioProject..CovidVaccinations

--JOIN
Select * 
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date

	--Total Population vs Vaccination
Select dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Peoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
order by 2,3;

--Use CTE
With PopvsVac (Continent, Location, Date, Population, new_vaccinations, Peoplevaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Peoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date
where dea.continent is not null
--order by 2,3
)
Select * , (Peoplevaccinated/Population)*100
From PopvsVac ;

--Temp Table
--Drop Table if exists ##percentpopulationvaccinated
Create Table #percentpopulationvaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Peoplevaccinated numeric
)

Insert into #percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Peoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date
--where dea.continent is not null
--order by 2,3

Select * , (Peoplevaccinated/Population)*100
From #percentpopulationvaccinated

--Create view to store data for later visualization

Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Peoplevaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
    On dea.location = vac.location
	and dea.date =vac.date
--where dea.continent is not null
--order by 2,3