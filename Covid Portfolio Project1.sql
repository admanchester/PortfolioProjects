/*
Covid 19 Data Exploration

Skills used: Joins, CTE's, Temp Tables, Windows Functions, Aggregate Functions, Creating Views, Converting Data Types

*/

--Data I'll Be Working With
Select *
FROM PortfolioProject1..CovidVaccinations
order by 3, 4


Select *
FROM PortfolioProject1..CovidDeaths
Where continent is NOT NULL
order by 1, 2

--Selcting The Data That I'm Using

Select Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject1..CovidDeaths
order by 1,2 ASC

--Total Cases vs. Total Deaths
--Shows likelihood of death if contracted covid in your country

Select Location, date, total_cases, total_deaths, (CONVERT(decimal,total_deaths) / NULLIF(CONVERT(decimal, total_cases), 0))* 100 AS Deathpercentage
FROM PortfolioProject1..CovidDeaths
Where continent is NOT NULL
order by 1,2 ASC

--Total Cases vs Population
--Shows the percentage of the population that contracted Covid
Select Location, date, population, total_cases, ((CONVERT(bigint, total_cases))/ population)*100 as CasePercentage
FROM PortfolioProject1..CovidDeaths
Where continent is NOT NULL
order by 1,2 ASC


--Countries With The Highest Infection Rates Compared To Population, DESCENDING ORDER

Select location, population, MAX(total_cases) as HighestCaseCount, (MAX(total_cases/ population))*100 as InfectionRates
FROM PortfolioProject1..CovidDeaths
--WHERE location like '%states%' AND not null
GROUP BY location, population
order by 4 DESC

--Breaking Things Down by Continent (Highest Death Count Per Continent)

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
Where continent is NOT NULL
GROUP BY continent
order by TotalDeathCount DESC


-- Countries With The Highest Death Count/ Population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1..CovidDeaths
Where continent is NOT NULL
GROUP BY location
order by TotalDeathCount DESC


--Global Numbers

Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_Deaths, SUM(cast(new_deaths as int))/ SUM(new_cases) *100 as GlobalDeathPercentages
FROM PortfolioProject1..CovidDeaths
Where continent is NOT NULL
--GROUP BY date
HAVING SUM(new_cases)>0 and SUM(cast(new_deaths as int))>0
order by 1 ASC

--Joined Tables

Select *
FROM PortfolioProject1..CovidDeaths as DEA
JOIN PortfolioProject1..CovidVaccinations as VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date

--Total Vaccinations vs Population

Select DEA.continent, DEA.location, DEA.date, DEA.population, vac.new_vaccinations,
SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Dea.population)*100 as VaccinationRate
FROM PortfolioProject1..CovidDeaths as DEA
JOIN PortfolioProject1..CovidVaccinations as VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
WHERE dea.continent is NOT NULL
Order by 1,2,3


--Use of CTE to get Vaccination Rate

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
AS
(Select DEA.continent, DEA.location, DEA.date, DEA.population, vac.new_vaccinations,
SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Dea.population)*100 as VaccinationRate
FROM PortfolioProject1..CovidDeaths as DEA
JOIN PortfolioProject1..CovidVaccinations as VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
WHERE dea.continent is NOT NULL
)

Select *, (RollingPeopleVaccinated/population)*100 as VaccinationRate
FROM PopvsVac
ORDER BY 1,2,3

--Use of Temp Table to get Vaccination Rate

DROP TABLE IF EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccination numeric,
RollingPeopleVaccinated numeric)


Insert Into #PercentPopulationVaccinated 
Select DEA.continent, DEA.location, DEA.date, DEA.population, vac.new_vaccinations,
SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Dea.population)*100 as VaccinationRate
FROM PortfolioProject1..CovidDeaths as DEA
JOIN PortfolioProject1..CovidVaccinations as VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
WHERE dea.continent is NOT NULL


Select *, (RollingPeopleVaccinated/population)*100 as VaccinationRate
FROM #PercentPopulationVaccinated
ORDER BY 1,2,3

--Creating View To Store For Later Visualisation In Tableu

Create View PercentPopulationVaccinated as
Select DEA.continent, DEA.location, DEA.date, DEA.population, vac.new_vaccinations,
SUM(CONVERT(decimal, vac.new_vaccinations)) OVER (PARTITION BY DEA.location order by DEA.location, DEA.date) as RollingPeopleVaccinated
--(RollingPeopleVaccinated/Dea.population)*100 as VaccinationRate
FROM PortfolioProject1..CovidDeaths as DEA
JOIN PortfolioProject1..CovidVaccinations as VAC
	ON DEA.location=VAC.location
	AND DEA.date=VAC.date
WHERE dea.continent is NOT NULL