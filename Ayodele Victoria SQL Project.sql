Select *
From Covid_Deaths
order by 3,4

-- Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From Covid_Deaths
order by 1, 2

-- Looking at Total Cases vs Total Deaths
-- Likelihood of dying when infected by country

Select location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 As DeathPercentage
From Covid_Deaths
Where location like '%Nigeria%'
order by total_deaths

-- Looking at Total cases by Population
-- Shows what percentage of population has been infected

Select location, date, total_cases, population, (total_cases/population) * 100 As InfectedPercentage
From Covid_Deaths
Where location like '%Nigeria%'
order by 1,2

-- Looking at countries with the highest infection rate compared to population

Select location, max(total_cases) as HighestInfectionCount, population, Max(total_cases/population) * 100 As HighestInfectedPercentage
From Covid_Deaths
-- Where location like '%Nigeria%'
Group by location, population
order by HighestInfectedPercentage desc

-- Looking at countries with the highest death count compared to population

Select location, max(total_deaths) as TotalDeathCount
From Covid_Deaths
-- Where location like '%Nigeria%'
Where continent is not null
Group by location
order by TotalDeathCount desc



-- Lets break it up by continent

Select location, max(total_deaths) as TotalDeathCount
From Covid_Deaths
-- Where location like '%Nigeria%'
Where continent is null
Group by location
order by TotalDeathCount desc

-- Lets break it up by continent

Select continent, max(total_deaths) as TotalDeathCount
From Covid_Deaths
-- Where location like '%Nigeria%'
Where continent is not null
Group by continent
order by TotalDeathCount desc

-- Showing Continents with highest death count per population

Select continent, max(total_deaths) as TotalDeathCount
From Covid_Deaths
-- Where location like '%Nigeria%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date, Sum(new_cases) as Sum_New_Cases, Sum(new_deaths) as Sum_New_Deaths, Sum(new_deaths) / Sum(new_cases) * 100 As DeathPercentage
From Covid_Deaths
-- Where location like '%Nigeria%'
where continent is not null
group by date
order by DeathPercentage desc


-- Covid_Deaths and Covid_Vaccination

Select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinations
From Covid_Vaccinations vac
Join Covid_Deaths dea
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
order by RollingPeopleVaccinations


-- Use CTE

With PopvsVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinations)
as
(
Select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinations
From Covid_Vaccinations vac
Join Covid_Deaths dea
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by RollingPeopleVaccinations
)

Select *, (RollingPeopleVaccinations/Convert(float, population))*100
From PopvsVac


-- Temp Table

Drop Table if Exist #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert Into #PercentPopulationVaccinated
Select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From Covid_Vaccinations vac
Join Covid_Deaths dea
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by RollingPeopleVaccinated

Select *, (RollingPeopleVaccinated/Convert(float, population))*100
From #PercentPopulationVaccinated


-- Creating View to store data for later visualization

Create View PercentPopulationVaccinated as
Select dea. continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Convert(int, vac.new_vaccinations)) Over (Partition by dea.location order by dea.location,
dea.date) as RollingPeopleVaccinated
From Covid_Vaccinations vac
Join Covid_Deaths dea
    On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
-- order by 2,3

Select * 
From PercentPopulationVaccinated