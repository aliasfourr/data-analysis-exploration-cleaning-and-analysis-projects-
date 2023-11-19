
select *
from [potfolio-projects].[dbo].[covid-death-1]
order by location,date 

-- select the data needed for the analysis

select d.location,d.date,total_cases,new_cases,total_deaths,population
from [potfolio-projects].[dbo].[covid-death-1] as d
order by 1,2

-- total covid cases related to total covid death
select location,date,total_cases ,total_deaths , (cast(total_deaths as float)/cast(total_cases as float))*100 as death_percentage
from [potfolio-projects].[dbo].[covid-death-1] as d
where location='Egypt'
order by 1,2

-- total cases vs population
select location,date,total_cases ,population , (cast(total_cases as float)/cast(population as float))*100 as infection_percentage
from [potfolio-projects].[dbo].[covid-death-1] as d
--where location like '%ypt%'
order by 2 desc

-- country with the highest infection rate
select location,max(total_cases) as max_infection ,population , max((cast(total_cases as float)/cast(population as float)))*100 as infection_percentage
from [potfolio-projects].[dbo].[covid-death-1] as d
--where location like '%ypt%'
group by location,population,total_cases
order by infection_percentage desc

-- higest death numbers (counrty)
select location,cast(max(total_deaths) as int) as max_deaths 
from [potfolio-projects].[dbo].[covid-death-1] as d
where  continent is not null 
group by location,population
order by max_deaths  desc

-- higest death percentage (counrty)
select location,cast(max(total_deaths) as int) as max_deaths 
,population , max((cast(total_deaths as float)/cast(population as float)))*100 as death_percentage
from [potfolio-projects].[dbo].[covid-death-1] as d
where  continent is not null 
group by location,population
order by death_percentage  desc

-- continent data

--higest infection rate by (continent)
select continent,max(cast(total_cases asint)) as max_infection ,population , max((cast(total_cases as float)/cast(population as float)))*100 as infection_percentage
from [potfolio-projects].[dbo].[covid-death-1] as d
where continent is not null
group by continent,population,total_cases
order by infection_percentage desc


-- higest death numbers (continent)
select continent,cast(max(total_deaths) as int) as max_deaths 
from [potfolio-projects].[dbo].[covid-death-1] as d
where  continent is not null 
group by continent
order by max_deaths  desc

-- the whole world too
select location,cast(max(total_deaths) as int) as max_deaths 
from [potfolio-projects].[dbo].[covid-death-1] as d
where  continent is  null 
group by location
order by max_deaths  desc


-- higest death percentage (continent)
select location,max(cast((total_deaths) as int)) as max_deaths 
,population , max((cast(total_deaths as float)/cast(population as float)))*100 as death_percentage
from [potfolio-projects].[dbo].[covid-death-1] as d
where  continent is  null 
group by population,location
order by death_percentage  desc


--globel covide numbers
select date,
sum(new_cases) as total_cases,sum(new_deaths) as total_deaths,(cast(nullif(sum(new_deaths),0) as float)/cast(nullif(sum(new_cases),0) as float))*100 death_ratio_by_date
--,total_deaths , (cast(total_deaths as float)/cast(total_cases as float))*100 as death_percentage
from [potfolio-projects].[dbo].[covid-death-1] as d
where continent is not null 
group by date
order by 1,2



--vacinations
with popvsvac ( date,continent,location,population,new_vaccinations,country_total_vacinations) 
as 
( 

select 
       d.date,d.continent,d.location,v.population,v.new_vaccinations,
       sum(cast(v.new_vaccinations as float)) over(partition by d.location order by d.location , d.date ) as country_total_vacinations 
from [potfolio-projects]..[covid-vancine-projects] as v
join  [potfolio-projects]..[covid-death-1] as d
      on v.date=d.date and v.location=d.location
where d.continent is not null and new_vaccinations is not null  
)
select * , (country_total_vacinations/population)*100 as percent_of_total_population_vacinated
from popvsvac

-- using temp table 


drop table if exists  #percentoffpopulatonvacinated 
create table #percentoffpopulatonvacinated (
date datetime
,continent nvarchar(255)
,location nvarchar(255)
,population bigint
,new_vaccinations numeric
,country_total_vacinations numeric)

insert into #percentoffpopulatonvacinated 

select 
       d.date,d.continent,d.location,v.population,v.new_vaccinations,
       sum(cast(v.new_vaccinations as float)) over(partition by d.location order by d.location , d.date ) as country_total_vacinations 
from [potfolio-projects]..[covid-vancine-projects] as v
join  [potfolio-projects]..[covid-death-1] as d
      on v.date=d.date and v.location=d.location
where d.continent is not null and new_vaccinations is not null  
order by 3,1

select * , (country_total_vacinations/population)*100 as percent_of_total_population_vacinated
from #percentoffpopulatonvacinated 


--creating viewss
drop view population_and_vaciations 
create view population_and_vaciations as
select 
       d.date,d.continent,d.location,v.population,v.new_vaccinations,
       sum(cast(v.new_vaccinations as float)) over(partition by d.location order by d.location , d.date ) as country_total_vacinations 
from [potfolio-projects]..[covid-vancine-projects] as v
join  [potfolio-projects]..[covid-death-1] as d
      on v.date=d.date and v.location=d.location
where d.continent is not null and new_vaccinations is not null  

select *,(country_total_vacinations/population)*100 as percent_of_total_population_vacinated
from population_and_vaciations