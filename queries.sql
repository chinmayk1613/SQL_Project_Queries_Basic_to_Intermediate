-- Q1.1 Select all the data from covidVaccination table
Select *
From project.covidVaccination
Where continent is not null 
order by 3,4


-- Q1.2. Select all the data from covidDeaths table

Select *
From project.covidDeaths
Where continent is not null 
order by 1,2



-- Q2. Shows likelihood of dying if you contract covid in your country

Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From project.covidDeaths
Where location like '%states%'
and continent is not null 
order by 1,2


-- Q3. Shows what percentage of population infected with Covid

Select location, date, population, total_cases,  (total_cases/population)*100 as PercentpopulationInfected
From project.covidDeaths
order by 1,2


-- Q4. Countries with Highest Infection Rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentpopulationInfected
From project.covidDeaths
Group by location, population
order by PercentpopulationInfected desc


-- Q5. Countries with Highest Death Count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From project.covidDeaths
Where continent is not null 
Group by location
order by TotalDeathCount desc



--Q6.  Showing contintents with the highest death count per population

Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From project.covidDeaths
Where continent is not null 
Group by continent
order by TotalDeathCount desc



-- Q7. Show Death percentage by continent and country

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From project.covidDeaths
where continent is not null 
order by 1,2




-- Q8. Shows Percentage of population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From project.covidDeaths dea
Join project.covidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Q8. Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, location, Date, population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From project.covidDeaths dea
Join project.covidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
)
Select *, (PeopleVaccinated/population)*100
From PopvsVac



-- Q9. Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentpopulationVaccinated
Create Table #PercentpopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentpopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From project.covidDeaths dea
Join project.covidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
Select *, (PeopleVaccinated/population)*100
From #PercentpopulationVaccinated




-- Q10. Creating of the view for further uses
Create View PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location, dea.Date) as PeopleVaccinated
From project.covidDeaths dea
Join project.covidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
