
-- Phần phân tích này tập trung đánh giá tình hình diễn biến của COVID-19 tại các quốc gia thông qua các chỉ số như số ca nhiễm, số ca tử vong, tỷ lệ nhiễm trên dân số và tỷ lệ tiêm chủng.
-- Dữ liệu được xử lý và phân tích bằng SQL để tổng hợp các chỉ số.

-- Kết quả cho thấy trong năm 2021 các quốc gia có tỷ lệ người dân bị covid cao nhất là Andorra có tỷ lệ ca nhiễm tích lũy trên dân số cao nhất trong nhóm được liệt kê, khoảng 17.13%, tiếp theo là Montenegro (15.51%), Czechia (15.23%) và San Marino (14.93%).
-- Các quốc gia có tỷ lệ cao trong nhóm này chủ yếu là các quốc gia châu Âu, cho thấy mức độ lây nhiễm COVID-19 tính trên quy mô dân số tương đối cao tại khu vực này. United States có tỷ lệ khoảng 9.77%, thấp hơn đáng kể so với Andorra nhưng vẫn thuộc nhóm có tỷ lệ nhiễm cao.
-- Tại thời điểm, Tỷ lệ dân số được tiêm ít nhất 1 lần tại các nước này là Andorra (6,21%), Montenegro (8,87%), Czechia (29,36%) và San Marino (50,62%)


Select *
From [dbo].[CovidDeaths]
-- Tổng số ca nhiễm COVID và Tổng số người chết do COVID
Select Location, Date, total_cases, total_deaths, (total_deaths/CAST(total_cases AS DECIMAL(18,2)))*100  as DeathPercent
From [dbo].[CovidDeaths]
Order by 1,2;

-- Tỷ lệ phần trăm dân số Hoa Kỳ đã mắc COVID 
Select location, date, total_cases, population, (total_cases/cast (population as decimal (18,2)))
From [dbo].[CovidDeaths]
Where location like '%states%'
Order by 1,2; 

-- Tỷ lệ phần trăm dân số đã mắc COVID trong giai đoạn khảo sát theo từng quốc gia 
Select location,date, total_cases, population, (total_cases/cast (population as decimal (18,2))) as Infected_Percentage 
From [dbo].[CovidDeaths]
Order by 1,2; 

-- Tỷ lệ lây nhiễm cao nhất so với quy mô dân số theo từng quốc gia 
Select location, max (total_cases/cast (population as decimal (18,2))) as Infected_Percentage 
From [dbo].[CovidDeaths]
Where continent is not null 
Group by location
Order by 2 DESC;

-- Tỷ lệ lây nhiễm cao nhất so với quy mô dân số theo từng quốc gia theo thời gian
WITH RankedData AS (
    SELECT
        location,
        date,
        total_cases,
        population,
        total_cases / CAST(population AS DECIMAL(18,2)) AS Infected_Percentage,
        ROW_NUMBER() OVER (
            PARTITION BY location
            ORDER BY total_cases / CAST(population AS DECIMAL(18,2)) DESC
        ) AS rn
    FROM [dbo].[CovidDeaths]
    WHERE continent IS NOT NULL)
 SELECT
    location,
    date,
    Infected_Percentage
FROM RankedData
WHERE rn = 1
ORDER BY Infected_Percentage;

-- Tỷ lệ phần trăm dân số đã tiêm ít nhất một liều vắc-xin COVID
With People_vaccinated as (
Select d.continent, d.location, d.date, d.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by d.Location Order by d.location, d.Date) as PeopleVaccinated
From [dbo].[CovidDeaths] as d
Join [dbo].[CovidVaccination ] as vac
	On d.location = vac.location
	and d.date = vac.date
where d.continent is not null)
Select *, (PeopleVaccinated/population) as Percentage_vaccinated_atleastone
From People_vaccinated 
Order by Percentage_vaccinated_atleastone DESC;

-- Creating View to store data for later visualizations
Create View PercentPopulationVaccinated as
Select d.continent, d.location, d.date, d.population, vac.new_vaccinations
, SUM(vac.new_vaccinations) OVER (Partition by d.Location Order by d.location, d.Date) as PeopleVaccinated
From [dbo].[CovidDeaths] as d
Join [dbo].[CovidVaccination ] as vac
	On d.location = vac.location
	and d.date = vac.date
where d.continent is not null;



