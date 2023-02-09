
--Breast Cancer Dataset
/* https://archive.ics.uci.edu/ml/datasets/Breast+Cancer */

-- Attributes:
/*
1. Class: The recurrence status of the patient (no-recurrence-events, recurrence-events) --> Dependent Variable
2. Age: patient’s age (in years) at the time of diagnosis, reported as 20-29, 30-39, 40-49, 50-59, 60-69, and 70-79.
3. Menopause: Whether the patient is pre- or post-menopausal at time of diagnosis
4. TumorSize: The greatest diameter (in mm) of the excised tumor, reported as 0-4,5-9, 10-14, 15-19, 20-24, 25-29, 30-34, 35-39, 40-44,45-49, 50- 54, and 55-59)
5. InvNodes: The number (range 0 - 39) of axillary lymph nodes that contain metastatic breast cancer visible on histological examination
6. NodeCaps: The penetration (yes or no) of the tumor in the lymph node capsule.
7. Degree of malignancy: The histological grade of the tumor, where grade 1: looks most like normal breast cells and is usually slowgrowing; grade 2: looks less like normal cells and is growing faster and grade 3: looks different to normal breast cells and is usually fast-growing
8. Breast: The breast (left or right) affected with cancer.
9. Breast quadrant: The specific location of the breast affected with cancer, reported as left-upper, left-lower, right-upper, right-lower and central
10. Irradiation: The radiation therapy history of the patient (yes or no)
*/

/*-------------------------*/

-- 1. Exploring Data

SELECT * FROM dbo.BreastCancer
/* Data contains 286 rows */

/*-------------------------*/

--2. Check Unique Values

SELECT DISTINCT NodeCaps FROM dbo.BreastCancer
SELECT DISTINCT BreastQuad FROM dbo.BreastCancer
/* Both NodeCaps and BreastQuad columns show null values as '?' */

/*-------------------------*/

--3. Check Null Values

SELECT * FROM dbo.BreastCancer
WHERE NodeCaps IN ('?')
/* 8 rows contain null values for NodeCaps documented as '?' */

SELECT * FROM dbo.BreastCancer
WHERE BreastQuad IN ('?')
/* 1 row contains null values for BreastQuad documented as '?' */

/*-------------------------*/

-- 4. Puting the cleaned data in a Common Table Expression

WITH Cleaned AS(
				SELECT * 
				FROM dbo.BreastCancer
				WHERE NodeCaps NOT IN ('?') and BreastQuad NOT IN ('?')
				),
	 Duplicate_check AS(
						SELECT * , ROW_NUMBER() OVER (PARTITION BY Class, Age, Menopause, TumorSize, InvNodes, NodeCaps, DegMalig, Breast, BreastQuad, Irradiat ORDER BY Class) AS Duplicate_read
						FROM Cleaned
						)

/*-------------------------*/

-- 5. Check Duplicates

SELECT * 
FROM Duplicate_check
 
/*After cleaning, only 263 rows out of 286 remained ( 8 (Null) + 1 (Null) + 14 (Duplicates))
As long as no unique key for each row (ie. no ID), we won't drop the duplicates as there is a chance that they aren't duplicates.*/

/*-------------------------*/

-- 6. Add cleaned data to a temporary table (Clean_BreastCancer)

WITH Cleaned AS(
				SELECT * 
				FROM dbo.BreastCancer
				WHERE NodeCaps IN ('yes','no') and BreastQuad NOT IN ('?')
				)
SELECT *
INTO #Clean_BreastCancer
FROM Cleaned


SELECT * FROM #Clean_BreastCancer
/* 277 rows*/

/*-------------------------*/

-- 7. How is recurrency rate differ by age

SELECT Age, COUNT(Class) As Recurrency
FROM #Clean_BreastCancer
WHERE Class = 'recurrence-events'
GROUP BY Age

SELECT Age, COUNT(Class) As NoRecurrency
FROM #Clean_BreastCancer
WHERE Class = 'no-recurrence-events'
GROUP BY Age

/*-------------------------*/

-- 8. How Previous tratement with radiation affect recurrency

SELECT Class, COUNT(Irradiat) As Irradiant
FROM #Clean_BreastCancer
WHERE Irradiat = 'yes'
GROUP BY Class

SELECT Class, COUNT(Irradiat) As NoIrradiant
FROM #Clean_BreastCancer
WHERE Irradiat = 'no'
GROUP BY Class

/*-------------------------*/

-- 9. How is recurrency rate differ by breast quadrant

SELECT BreastQuad, COUNT(Class) As Recurrency
FROM #Clean_BreastCancer
WHERE Class = 'recurrence-events'
GROUP BY BreastQuad
ORDER BY Recurrency DESC

SELECT BreastQuad, COUNT(Class) As NoRecurrency
FROM #Clean_BreastCancer
WHERE Class = 'no-recurrence-events'
GROUP BY BreastQuad
ORDER BY NoRecurrency DESC
