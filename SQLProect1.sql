select *
from PortofolioProject..covidDeath
WHERE continent is not null
order by 3,4

--select *
--from PortofolioProject..covidvaksinasi

select location, date, total_cases,new_cases, total_deaths, population
from PortofolioProject..covidDeath
where total_cases is NOT NULL

--1. melihat berapa persen orang yang meninggal dari total terinfeksi(cases)
select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as Deathpercent
from PortofolioProject..covidDeath
where total_cases is NOT NULL AND location Like '%Indonesia%'
order by date

--2. melihat total terinfeksi dari jumlah penduduk
select location, date,population, total_cases,  (total_cases/population)*100 as CasesPercent
from PortofolioProject..covidDeath
--where total_cases is NOT NULL AND location Like '%Indonesia%'
order by  1,2

--3, melihat negara dengan infeksi tertinggi
select location,population, MAX(total_cases) as infeksiTertinggi,  MAX((total_cases/population))*100 as Persen_infeksiTertinggi
from PortofolioProject..covidDeath
--where total_cases is NOT NULL AND location Like '%Indonesia%'
GROUP BY location,population
order by  Persen_infeksiTertinggi	DESC

--4. MELIHAT NEGARA DENGAN KEMATIAN TERTINGGI
SELECT location, MAX(total_deaths) as DeathHeight
FROM PortofolioProject..covidDeath
WHERE continent is not null
group by location
order by DeathHeight desc

--5. melihat setiap benua tentang angka kematiannya
SELECT continent, MAX(total_deaths) as DeathHeight
FROM PortofolioProject..covidDeath
WHERE continent is not null
group by continent
order by DeathHeight desc

-- bisa juga seperti ini (lebih akurat)
SELECT location, MAX(total_deaths) as DeathHeight
FROM PortofolioProject..covidDeath
WHERE continent is null
group by location
order by DeathHeight desc

-- MENGUBAH CONTOH (tipe data total_Death adalah nvarchar jadi harus kita ubah dlu ke int)
-- CONTOH MAX(cast((total_Death as int))

--Global Number
--Dimana menjumlahkan total terinfeksi dan kematian

select date, SUM(new_cases), SUM(new_deaths) AS total_Deaths, SUM(new_deaths)/SUM(new_cases)*100
from PortofolioProject..covidDeath
where continent is not NULL
group by date
order by 1

--! coviddeath join covidvaksinasi

-- melihat total population dengan vaksinasi
select dea.continent, dem.location, dem.date, date.population, vak.new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER ( partition by dem.location order by dem.location, dem.date) as rollingvaksinasion
--,(rollingvaksinasion/population)
from PortofolioProject..covidDeath dea
join PortofolioProject..covidvaksinasi vak
	on dea.location = vak.location
	and dea.date = vak.date
where dea.continent is not null
order by 2,3

-- CTe

WITH PopvsVaks (dea.continent, dem.location, dem.date, date.population, vak.new_vaccinations,rollingvaksinasion)
as
(
select dea.continent, dem.location, dem.date, date.population, vak.new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER ( partition by dem.location order by dem.location, dem.date) as rollingvaksinasion
--,(rollingvaksinasion/population)*100
from PortofolioProject..covidDeath dea
join PortofolioProject..covidvaksinasi vak
	on dea.location = vak.location
	and dea.date = vak.date
where dea.continent is not null
--order by 2,3
)

select*, (rollingvaksinasion/population)*100
from Popvsvaks


-- TEMP TABLE
DROP TABLE if exists #persenpopulasivaksin
create table #persenpopulasivaksin(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
rollingvaksinasion numeric)

insert into #persenpopulasivaksin
select dea.continent, dem.location, dem.date, date.population, vak.new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER ( partition by dem.location order by dem.location, dem.date) as rollingvaksinasion
--,(rollingvaksinasion/population)*100
from PortofolioProject..covidDeath dea
join PortofolioProject..covidvaksinasi vak
	on dea.location = vak.location
	and dea.date = vak.date
where dea.continent is not null
--order by 2,3

select*, (rollingvaksinasion/population)*100
from #persenpopulasivaksin

-- creating view for later visualisasi

create view persenpopulasivaksin as
select dea.continent, dem.location, dem.date, date.population, vak.new_vaccinations,
SUM(CONVERT(int, new_vaccinations)) OVER ( partition by dem.location order by dem.location, dem.date) as rollingvaksinasion
--,(rollingvaksinasion/population)
from PortofolioProject..covidDeath dea
join PortofolioProject..covidvaksinasi vak
	on dea.location = vak.location
	and dea.date = vak.date
where dea.continent is not null
order by 2,3
