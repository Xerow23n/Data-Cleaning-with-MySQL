Select *
From layoffs_staging2;

Select max(total_laid_off), max(percentage_laid_off)
From layoffs_staging2;

Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by total_laid_off DESC;

Select *
From layoffs_staging2
Where percentage_laid_off = 1
Order by funds_raised_millions DESC;

Select company, sum(total_laid_off)
From layoffs_staging2
group by company
order by 2 DESC; 		# 2 here means sorting two unique columns;

Select min(`date`), max(`date`)
From layoffs_staging2;

Select industry, sum(total_laid_off)
From layoffs_staging2
group by industry
order by 2 DESC;

Select country, sum(total_laid_off)
From layoffs_staging2
group by country
order by 2 DESC;

Select Year(`date`), sum(total_laid_off)
From layoffs_staging2
group by Year(`date`)
order by 1 DESC;

Select stage, sum(total_laid_off)
From layoffs_staging2
group by stage
order by 2 DESC;			# Post-IPO = Post initial public offering (comapnies like Amazon and Google etc)


Select company, avg(percentage_laid_off)
From layoffs_staging2
group by company
order by 2 DESC;


-- Rolling total
# Select by month (not good for rolling total since it is not year-specific) 
Select substring(`date`,6,2) AS `Month`, sum(total_laid_off)
From layoffs_staging2
group by `Month`;

Select substring(`date`,1,7) AS `Month`, sum(total_laid_off)
From layoffs_staging2
where substring(`date`,1,7) IS not null
group by `Month`
order by 1 ASC;

With Rolling_Total AS
(
Select substring(`date`,1,7) AS `Month`, sum(total_laid_off) AS Total_Off
From layoffs_staging2
where substring(`date`,1,7) IS not null
group by `Month`
order by 1 ASC
)
Select `Month`, Total_Off, sum(Total_Off) Over(Order by `Month`) AS Rolling_total
From Rolling_Total;


# Ranking the year of most layoffs by company and year
Select country, sum(total_laid_off)
From layoffs_staging2
group by country
order by 2 DESC;

select company, Year(`date`), sum(total_laid_off)
From layoffs_staging2
group by company, Year(`date`)
Order by 3 DESC;

With Company_Year (Company, Years, Total_Laid_Off) AS
(
select company, Year(`date`), sum(total_laid_off)
From layoffs_staging2
group by company, Year(`date`)
), Company_Year_Rank AS
(Select *, 
Dense_rank () Over(Partition by Years order by Total_Laid_Off DESC) AS Ranking
From Company_Year
Where Years is not null
)
Select *
From Company_Year_Rank
Where Ranking <= 5;