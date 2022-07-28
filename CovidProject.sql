-- Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

SELECT *
From CovidDeaths
order by 3,4

-- Remove Null VALUES 

SELECT *
From CovidDeaths
Where continent is not NULL 
order by 3,4

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths * 1.0/total_cases)*100
from CovidDeaths
Where continent is not NULL 
order by 1,2;


-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID i your country

SELECT location, date, total_cases, new_cases, total_deaths, (total_deaths * 1.0/total_cases)*100 as DeathPercentage
from CovidDeaths
Where location LIKE  '%states'
Where continent is not NULL 

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT location, date, total_cases, population , (total_cases * 1.0/population)*100 as PopulationInfected
from CovidDeaths
Where location LIKE  '%states'
Where continent is not NULL 
Order by location asc


SELECT location, date, total_cases, population , (total_cases * 1.0/population)*100 as PopulationInfected
from CovidDeaths
--Where location LIKE  '%states'
Where continent is not NULL 
order by 1, 2

-- Looking at Countries with Highest Infection Rate compared to population

SELECT location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases * 1.0/population))*100 as PercentPopulationInfected
from CovidDeaths
--Where location LIKE  '%states'
Where continent is not NULL 
GROUP BY location, population 
order by PercentPopulationInfected desc

-- Showing Countires with the highest death count per population

SELECT location, MAX(total_deaths) as TotalDeathCount 
from CovidDeaths
--Where location LIKE  '%states'
Where continent is not NULL 
Group by location 
order by TotalDeathCount desc

-- Break things down by contient



-- Showing the continents with the highest death count per population


SELECT continent, MAX(total_deaths) as TotalDeathCount 
from CovidDeaths
--Where location LIKE  '%states'
Where continent <> '' 
Group by continent 
order by TotalDeathCount desc

-- Global numbers

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths  as int))/SUM(New_Cases * 1.0)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent <> '' 
--Group By date
order by 1,2;

-- Looking at Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one COVID vaccine

Select cd.continent, cd.location, cd.date, cd.population , cv.new_vaccinations, SUM(CAST(cv.new_vaccinations as bigint)) Over (PARTITION by cd.location order by cd.location, cd.[date]) as RollingPeopleVaccinated 
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location 
	and cd.date = cv.date 
Where cd.continent <> ''
order by 2, 3

-- Using CTE (common table expression) to perform Calculation on Partition By in previous query

With PopvsVac (continent, location, date, population, New_Vaccinations, RollingPeopleVaccinated)
AS 
(
Select cd.continent, cd.location, cd.date, cd.population , cv.new_vaccinations, SUM(CAST(cv.new_vaccinations as bigint)) Over (PARTITION by cd.location order by cd.location, cd.[date]) as RollingPeopleVaccinated 
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location 
	and cd.date = cv.date 
Where cd.continent <> ''
--order by 2, 3
)
Select *, (RollingPeopleVaccinated*1.0 / population) *100
From PopvsVac
Where location LIKE  '%states'


-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent varchar(50),
Location varchar(50),
Date varchar(50),
Population bigint,
New_vaccinations varchar(50),
RollingPeopleVaccinated bigint
)

Insert into #PercentPopulationVaccinated
Select cd.continent, cd.location, cd.date, cd.population , cv.new_vaccinations, SUM(CAST(cv.new_vaccinations as bigint)) Over (PARTITION by cd.location order by cd.location, cd.[date]) as RollingPeopleVaccinated 
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location 
	and cd.date = cv.date 
Where cd.continent <> ''
--order by 2, 3

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualizations

Create VIEW PercentPopulationVaccinated 
AS 
Select cd.continent, cd.location, cd.date, cd.population , cv.new_vaccinations, SUM(CAST(cv.new_vaccinations as bigint)) Over (PARTITION by cd.location order by cd.location, cd.[date]) as RollingPeopleVaccinated 
From CovidDeaths cd 
Join CovidVaccinations cv 
	On cd.location = cv.location 
	and cd.date = cv.date 
Where cd.continent <> ''

Create View GlobalNumbers
As
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths  as int))/SUM(New_Cases * 1.0)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent <> '' 
--Group By date
--order by 1,2;

