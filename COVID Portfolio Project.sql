SELECT *
FROM PortfolioProject001..CovidDeaths
WHERE location like '%state%'
ORDER BY 3,4

SELECT *
FROM PortfolioProject001..CovidVaccinations
ORDER BY 3,4

-- Select data that we are going to be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject001..CovidDeaths
ORDER BY 1,2

-- Looking at total cases vs total deaths
--Shows the liklihood of dying if you contract covid in your country
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject001..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--total cases vs population
--shows what percentage of population contracted covid
SELECT location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
FROM PortfolioProject001..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2

--looking at countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) as HighestInfectionCount, MAX((total_cases/population))*100 as PercentPopulationInfected
FROM PortfolioProject001..CovidDeaths
--WHERE location like '%states%'
GROUP BY population, location
ORDER BY 4 DESC

--showing the countries with the higest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject001..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--LET'S BREAK THINGS DOWN BY CONTINENT

--showing the countries with the higest death count per population
SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject001..CovidDeaths
WHERE continent IS NULL AND location  NOT LIKE '%income%' AND location NOT IN ('world')
GROUP BY location
ORDER BY TotalDeathCount DESC

--Global numbers
SELECT  SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject001..CovidDeaths
--WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2

--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Total_Vaccinations
, (Rolling_Total_Vaccinations/dea.population)*100
FROM PortfolioProject001..CovidDeaths dea
JOIN PortfolioProject001..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent like '%north amer%'
ORDER BY 2,3


--USE CTE
WITH PopVsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_Total_Vaccinated)
AS
(
--Looking at total population vs vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Total_Vaccinations
--, (Rolling_Total_Vaccinations/dea.population)*100
FROM PortfolioProject001..CovidDeaths dea
JOIN PortfolioProject001..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent like '%north amer%'
)
SELECT *, (Rolling_Total_Vaccinated/Population)*100
FROM PopVsVac
WHERE Location like '%united s%'
ORDER BY 2,3

--USE TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date DateTime,
Population numeric,
New_Vaccinations numeric,
Rolling_Total_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as Rolling_Total_Vaccinations
--, (Rolling_Total_Vaccinations/dea.population)*100
FROM PortfolioProject001..CovidDeaths dea
JOIN PortfolioProject001..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent like '%north amer%'

SELECT *, (Rolling_Total_Vaccinated/Population)*100
FROM #PercentPopulationVaccinated
ORDER BY 1,2,3

--CREATING VIEW to store for later visualizations
CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location
, dea.date) as Rolling_Total_Vaccinations
--, (Rolling_Total_Vaccinations/dea.population)*100
FROM PortfolioProject001..CovidDeaths dea
JOIN PortfolioProject001..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccinated
WHERE location like '%united s%' 