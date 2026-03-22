SELECT * 
FROM covid_project.coviddeaths
WHERE continent <> ''
ORDER BY 3,4;

-- SELECT * FROM covid_project.covidvaccinations;
-- Select data that we are going to use
SELECT continent, location, date, total_cases, new_cases, total_deaths, population
FROM covid_project.coviddeaths
WHERE continent <> ''
order by 1,2;

-- Looing at Total cases vs Total deaths
-- Shows likelihood of dying if you contract covid in country
SELECT location, date, total_cases, new_cases, total_deaths , (total_deaths/total_cases)*100 AS Rate_of_death_per_cases
FROM covid_project.coviddeaths
WHERE location like '%Viet%' 
and continent <> ''
ORDER BY 1,2;

-- Looing at Total cases vs Population
-- Shows what percentages of population got covid
SELECT location, date, total_cases, new_cases, population, (total_cases/population)*100 AS Rate_of_covid
FROM covid_project.coviddeaths
WHERE location like '%Viet%' 
and continent <> ''
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate compared to population	
SELECT location, population,MAX(total_cases) as highest_infection_count, MAX(total_cases/population)*100 AS Rate_of_covid
FROM covid_project.coviddeaths
-- WHERE location like '%Viet%' 
GROUP BY location,population
ORDER BY Rate_of_covid desc;

-- Showing  Countries with Highest Death Count per population
SELECT location, MAX(CAST(total_deaths AS UNSIGNED) ) as highest_death_count
FROM covid_project.coviddeaths
WHERE continent <> ''
GROUP BY location
ORDER BY highest_death_count desc;

-- Showing Continents with Highest Death Count per population
SELECT continent, MAX(CAST(total_deaths AS UNSIGNED) ) as highest_death_count
FROM covid_project.coviddeaths
WHERE continent <> ''
GROUP BY continent
ORDER BY highest_death_count desc;

-- Globale numbers
SELECT  date, SUM(new_cases) as total_newcases, SUM(new_deaths) as total_newdeaths ,
SUM(new_deaths)/SUM(new_cases)*100 AS Rate_of_death_per_newcases
FROM covid_project.coviddeaths
WHERE continent <> ''
GROUP BY date
ORDER BY 1,2;


-- Percent population vaccinated per day using CTE 	
with PopvsVac as(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as UNSIGNED)) Over (partition by dea.location order by dea.date) as Rolling_people_vaccinated
from covid_project.coviddeaths dea
join covid_project.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> '' )
select *, (Rolling_people_vaccinated/population)*100 as rate_of_vaccination
from PopvsVac
order by 2,3;

-- Percent population vaccinated per day using Temp table
DROP TABLE IF EXISTS Percentpopulationvaccinated;
CREATE TEMPORARY TABLE Percentpopulationvaccinated
(
continent varchar(255),
location varchar(255),
date Date,
population BIGINT,
new_vaccinations BIGINT,
Rolling_people_vaccinated BIGINT
);
Insert into Percentpopulationvaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as UNSIGNED)) Over (partition by dea.location order by dea.date) as Rolling_people_vaccinated
from covid_project.coviddeaths dea
join covid_project.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> '' ;
select *, (Rolling_people_vaccinated/population)*100 as rate_of_vaccination
from Percentpopulationvaccinated;

-- Creating view to store data
Create View Percentpopulationvaccinated2 as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(CAST(vac.new_vaccinations as UNSIGNED)) Over (partition by dea.location order by dea.date) as Rolling_people_vaccinated
from covid_project.coviddeaths dea
join covid_project.covidvaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent <> '' ;

Select  * 
from Percentpopulationvaccinated2
 