-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases,total_deaths, population
From Covid.CovidDeaths
order by 1,2;

--Looking at Total Cases vs Total Deaths
--Show likelyhood of dying if you contract covid in the United States
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Covid.CovidDeaths
Where location like '%States%' and continent is not null
order by 1,2;

--Show likelyhood of dying if you contract covid in Vietnam
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Death_Percentage
From Covid.CovidDeaths
Where location = "Vietnam" and continent is not null
order by 1,2;


-- Looking at Total Cases vs Population
-- Show what percentage of population got Covid
Select Location, date, population,total_cases, (total_cases/population)*100 as Death_Percentage
From Covid.CovidDeaths
order by 1,2;

-- Countries with Highest Infection Rate compared to Population
Select Location, population, MAX(total_cases) as Highest_Infection_Count,  Max((total_cases/population))*100 as Percent_Population_Infected
From Covid.CovidDeaths
Group by Location, Population
order by Percent_Population_Infected desc;


-- Countries with Highest Death Count per Population
Select Location, MAX(Total_deaths) as Total_Death_Count
From Covid.CovidDeaths
Where continent is not null
Group by Location
order by Total_Death_Count desc;

-- BREAKING THINGS DOWN BY CONTINENT
-- Showing contintents with the highest death count per population
Select continent, MAX(Total_deaths) as Total_Death_Count
From Covid.CovidDeaths
Where continent is not null
Group by continent
order by Total_Death_Count desc;

-- GLOBAL NUMBERS
Select SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/SUM(New_Cases)*100 as Death_Percentage
From Covid.CovidDeaths
where continent is not null
order by 1,2;

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.date) as Rolling_People_Vaccinated
From Covid.CovidDeaths AS dea
Join Covid.CovidVaccinations AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3;

-- Using CTE to perform Calculation on Partition By to find the percent of rolling vaccinated people
With PopvsVac as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid.CovidDeaths AS dea
Join Covid.CovidVaccinations AS vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100 as percent_rolling_vaccinated
From PopvsVac;

-- Using Temp Table to perform Calculation on Partition By to find the percent of rolling vaccinated people
Create Temp Table `PercentPopulationVaccinated`
(
Continent string,
Location string,
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
);

Insert into `PercentPopulationVaccinated`
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
From Covid.CovidDeaths dea
Join Covid.CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date;

Select *, (RollingPeopleVaccinated/Population)*100
From `PercentPopulationVaccinated`;
