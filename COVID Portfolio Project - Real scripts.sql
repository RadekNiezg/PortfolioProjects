SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract COVID in your country

SELECT location, date, total_cases, total_deaths, ROUND((total_deaths/total_cases)*100, 2) AS DeathPercentage
FROM dbo.coviddeaths
WHERE location LIKE '%Kingdom%' AND continent IS NOT NULL
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population got COVID

SELECT location, date, total_cases, population, ROUND((total_cases/population)*100, 3) AS InfectionRate
FROM dbo.coviddeaths
ORDER BY 1,2;

-- Looking at countries with highest infection rate vs population
-- Shows countires with the highest infection rate

SELECT location, MAX(total_cases) AS HighestInfectionCount, population, ROUND(MAX((total_cases/population))*100, 3) AS InfectionRate
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY population, location
ORDER BY InfectionRate desc;

-- Looking at deaths vs population
-- Shows countires with the highest death count per population

SELECT location, MAX(cast(total_deaths AS INT)) AS HighestDeathNumber
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY HighestDeathNumber desc;

-- LET'S BREAK THIGHS DOWN BY CONTINENT

SELECT continent, MAX(cast(total_deaths AS INT)) AS HighestDeathNumber
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathNumber desc;

-- Showing continents with the highest death count per population

SELECT continent, MAX(cast(total_deaths AS INT)) AS HighestDeathCount
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY HighestDeathCount desc;

-- Breaking global numbers

SELECT SUM(new_cases) AS Total_cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS DeathPercentage
FROM dbo.coviddeaths
WHERE continent IS NOT NULL
ORDER BY 1,2;

-- Joininig two tables together - vaccinations and deaths

SELECT * 
FROM dbo.coviddeaths
JOIN dbo.covidvaccinations
ON dbo.coviddeaths.location = dbo.covidvaccinations.location
AND dbo.coviddeaths.date = dbo.covidvaccinations.date;

-- Looking at total population vs vaccination

WITH PopVsVac (continent, location, date, population, new_vaccinations, Rolling_people_vaccinated)
AS
(
SELECT dbo.coviddeaths.continent, dbo.coviddeaths.location, dbo.coviddeaths.date , dbo.coviddeaths.population, dbo.covidvaccinations.new_vaccinations,
SUM(CONVERT(INT, dbo.covidvaccinations.new_vaccinations)) OVER (PARTITION BY dbo.coviddeaths.location ORDER BY dbo.coviddeaths.location, dbo.coviddeaths.date) 
AS Rolling_people_vaccinated
FROM dbo.coviddeaths
JOIN dbo.covidvaccinations
	ON dbo.coviddeaths.location = dbo.covidvaccinations.location
	AND dbo.coviddeaths.date = dbo.covidvaccinations.date
WHERE dbo.coviddeaths.continent IS NOT NULL
)

-- USE CTE

SELECT *, ROUND((Rolling_people_vaccinated/population)*100, 3)
FROM PopVsVac;

-- TEMP TABLE

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rolling_people_vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dbo.coviddeaths.continent, dbo.coviddeaths.location, dbo.coviddeaths.date , dbo.coviddeaths.population, dbo.covidvaccinations.new_vaccinations,
SUM(CAST(dbo.covidvaccinations.new_vaccinations AS INT)) OVER (PARTITION BY dbo.coviddeaths.location ORDER BY dbo.coviddeaths.location, dbo.coviddeaths.date) 
AS Rolling_people_vaccinated
FROM dbo.coviddeaths
JOIN dbo.covidvaccinations
	ON dbo.coviddeaths.location = dbo.covidvaccinations.location
	AND dbo.coviddeaths.date = dbo.covidvaccinations.date

SELECT *, (Rolling_people_vaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dbo.coviddeaths.continent, dbo.coviddeaths.location, dbo.coviddeaths.date , dbo.coviddeaths.population, dbo.covidvaccinations.new_vaccinations,
SUM(CAST(dbo.covidvaccinations.new_vaccinations AS INT)) OVER (PARTITION BY dbo.coviddeaths.location ORDER BY dbo.coviddeaths.location, dbo.coviddeaths.date) 
AS Rolling_people_vaccinated
FROM dbo.coviddeaths
JOIN dbo.covidvaccinations
	ON dbo.coviddeaths.location = dbo.covidvaccinations.location
	AND dbo.coviddeaths.date = dbo.covidvaccinations.date
WHERE dbo.coviddeaths.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated