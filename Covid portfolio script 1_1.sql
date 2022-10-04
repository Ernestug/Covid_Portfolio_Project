/*
Covid 19 Data Exploration
SQL skills applied in doing this project
*/
SELECT *
FROM PortfolioProject ..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 3, 4


-- To select data we will use for this project

SELECT Location, Date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Checking at Total Cases Vs Total Deaths
-- Possibility of dying if you contract Covid in any of the country

SELECT Location, Date, total_cases, total_deaths, (total_deaths / total_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE Location like '%state%'
ORDER BY 1, 2

--Acessing the total Cases vs Population
--Indicate what percentage of the population got Covid


SELECT Location, Date, Population, total_cases, (total_cases / population)* 100 AS PercentagePopulation Infected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%state%'
ORDER BY 1, 2

--Examining countries with highest Infection Rate Compared to Population

SELECT Location, Population, MAX(total_cases) AS HighestInfectionCount,MAX((total_cases / population))* 100 AS PercentagePopulationInfected
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%state%'
GROUP BY Location, Population
ORDER BY PercentagePopulationInfected DESC


--Showing Countries with the Highest Death Count per Population

SELECT Location,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%state%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC


-- To break into Continent


SELECT location,  MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE Location like '%state%'
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC


-- Global Numbers

SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as int)) AS  total_deaths, SUM(cast (new_deaths as int)) /SUM(new_cases)* 100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE Location LIKE '%state%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1, 2

--Acessing Total Population Vs vaccination


SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location,dea.date)
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


-- Using CTE to perform calculation on Partition By in the earlier query

With PopvsVac (Continent, Location, date, Population, new_vaccinations,  RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac



-- Using Tem Table to perform claculation on Partition By in earlier query
CREATE Table #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric 
)
INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
	 AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated


--Creating view to store data for later visualization

CREATE View PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(cast(vac.new_vaccinations as int)) OVER (Partition By dea.location Order By dea.location,dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
     ON dea.location = vac.location
     AND dea.date = vac.date
WHERE dea.continent IS NOT NULL



