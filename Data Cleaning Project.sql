-- Data Cleaning

Select *
From layoffs;

-- Step 1 : Remove Duplicates
-- Step 2 : Standardize the data
-- Step 3 : Look for null and blank data
-- Step 4 : Remove any column or row (if needed) 


# Create staging table
Create table layoffs_staging
Like layoffs;

Select *
From layoffs_staging;

Insert layoffs_staging
Select *
From layoffs;

# Removes Duplicates
Select *,
Row_Number() Over (Partition by company, industry, total_laid_off, percentage_laid_off
, `date`) AS Row_num
From layoffs_staging;

# If row_num is greater than 2 usually indicates a dupe

With duplicates_cte AS
(
Select *,
Row_Number() Over (Partition by company,location, industry, percentage_laid_off
, `date`, stage, country, funds_raised_millions) AS Row_num
From layoffs_staging
)
Select *
From duplicates_cte
Where Row_num > 1;

# Further checking with the dupes
Select *
From layoffs_staging
Where company = 'Oda';   	-- 3 diff dataset for Oda are found hence there is no dupe, thus is better to include all dataset 
							-- Also delete function is an update function and cannot be execute in CTE
                            
# Create another staging table for dupes removal
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

Select *
From layoffs_staging2;

Insert into layoffs_staging2
Select *,
Row_Number() Over (Partition by company,location, industry, percentage_laid_off
, `date`, stage, country, funds_raised_millions) AS Row_num
From layoffs_staging;

Select *
From layoffs_staging2
Where row_num > 1;

Delete
From layoffs_staging2
Where row_num > 1;

Select *
From layoffs_staging2;

-- Dupes removal completed


-- Data Standardization
 Select company, trim(company)
 From layoffs_staging2;
 
 update layoffs_staging2
 Set company = trim(company);

Select distinct industry
From layoffs_staging2
order by 1;

Select *
From layoffs_staging2
Where industry like 'Crypto%';

Update layoffs_staging2
Set industry = 'Crypto'
Where industry like 'Crypto%';

Select distinct location
From layoffs_staging2
order by 1;

Select distinct country
From layoffs_staging2
order by 1;

Select *
From layoffs_staging2
Where country like 'United State%'
Order by 1;

Select distinct country, trim(trailing '.'from country)		#Trailing = coming out at the end
From layoffs_staging2
Order by 1;

update layoffs_staging2
set country = trim(trailing '.'from country)
where country like 'United State%';	

# Date formatting  
Select `date`,
str_to_date(`date`, '%m/%d/%Y')		# m,d,y = 2 num long value   Y = 4 num long value for year
From layoffs_staging2;

update layoffs_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

Select `date`
From layoffs_staging2;

# Data type changing 
Alter table layoffs_staging2
modify column `date` Date;

Select *
From layoffs_staging2;


-- Null and blank inspection and modification

Select *
From layoffs_staging2
Where total_laid_off IS Null
And percentage_laid_off IS Null;

Select *
From layoffs_staging2
Where industry Is null
or industry = '';

# Look for populatable data
Select *
From layoffs_staging2
Where company = 'Airbnb';

Select t1.industry, t2.industry
From layoffs_staging2 t1
Join layoffs_staging2 t2
	On t1.company = t2.company
Where (t1.industry is null or t1.industry = '')
And t2.industry is not null;

# Set the blank data to null might help update the table easier

Update layoffs_staging2 t1
Join layoffs_staging2 t2
	ON t1.company = t2.company
Set t1.industry = t2.industry
Where (t1.industry is null or t1.industry = '')
And t2.industry is not null;

Update layoffs_staging2
Set industry = null
Where industry = '';

Update layoffs_staging2 t1
Join layoffs_staging2 t2
	ON t1.company = t2.company
Set t1.industry = t2.industry
Where t1.industry is null 
And t2.industry is not null;

Select *
From layoffs_staging2;

# Row column deletion (For null and probably useless column)
Select *
From layoffs_staging2
Where total_laid_off IS Null
And percentage_laid_off IS Null;

Delete
From layoffs_staging2
Where total_laid_off IS Null
And percentage_laid_off IS Null;

Select *
From layoffs_staging2;

# Delete row_num column
Alter table layoffs_staging2
Drop column row_num;

-- End of data cleaning