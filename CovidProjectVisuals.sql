Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths  as int))/SUM(New_Cases * 1.0)*100 as DeathPercentage
From CovidDeaths
--Where location like '%states%'
where continent <> '' 
--Group By date
order by 1,2;


Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%states%'
Where continent like ''
and location not in ('World', 'European Union', 'International', 'Upper middle income', 'High income', 'Lower middle income', 'Low income')
Group by location
order by TotalDeathCount DESC


Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases*1.0/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected DESC

Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases*1.0/population))*100 as PercentPopulationInfected
FROM CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc