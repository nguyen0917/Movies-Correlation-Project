/*
Cleaning Data in SQL Queries
*/

select * 
from NashvilleHousing.nashville2;

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format
SELECT  STR_TO_DATE(SaleDate, '%m/%d/%Y')
from NashvilleHousing.nashville2;


Update NashvilleHousing.nashville2
SET SaleDate = STR_TO_DATE(SaleDate, '%m/%d/%Y');

--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From NashvilleHousing.nashville2
order by ParcelID;

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, IFNULL(a.PropertyAddress,b.PropertyAddress)
From NashvilleHousing.nashville2 AS a
JOIN NashvilleHousing.nashville2 AS b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID 
where b.PropertyAddress = ''; 

Update NashvilleHousing.nashville2 AS a
JOIN NashvilleHousing.nashville2 AS b
	on a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID 
SET b.PropertyAddress = IFNULL(a.PropertyAddress,b.PropertyAddress)
where b.PropertyAddress = ''; 
    
-------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


Select PropertyAddress 
From NashvilleHousing.nashville2;

-- splitting up the address into address and city
SELECT
SUBSTRING_INDEX(PropertyAddress, ',', 1) as Address,
SUBSTRING_INDEX(PropertyAddress, ',', -1) as City
From NashvilleHousing.nashville2;

-- create column for address
ALTER TABLE NashvilleHousing.nashville2
Add PropertySplitAddress varchar(255);

-- update the table with address 
Update NashvilleHousing.nashville2
SET PropertySplitAddress = SUBSTRING_INDEX(PropertyAddress, ',', 1);

-- create column for city
ALTER TABLE NashvilleHousing.nashville2
Add PropertySplitCity varchar(255);

-- update the table with city 
Update NashvilleHousing.nashville2
SET PropertySplitCity = SUBSTRING_INDEX(PropertyAddress, ',', -1);

-- look at OwnerAddress
Select OwnerAddress
From NashvilleHousing.nashville2;

-- Separate OwnerAddress into 3 different columns 
-- Address, City, and State
SELECT
SUBSTRING_INDEX(OwnerAddress, ',', 1) as Address,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) as City,
SUBSTRING_INDEX(OwnerAddress, ',', -1) as State
From NashvilleHousing.nashville2;

-- create column for owner street address
ALTER TABLE NashvilleHousing.nashville2
Add OwnerSplitAddress varchar(255);

-- update the table with owner street address
Update NashvilleHousing.nashville2
SET OwnerSplitAddress = SUBSTRING_INDEX(OwnerAddress, ',', 1);

-- create column for owner city
ALTER TABLE NashvilleHousing.nashville2
Add OwnerSplitCity varchar(255);

-- update the table with owner city 
Update NashvilleHousing.nashville2
SET OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', -2), ',', 1) ;

-- create column for owner state
ALTER TABLE NashvilleHousing.nashville2
Add OwnerSplitState varchar(255);

-- update the table with owner state
Update NashvilleHousing.nashville2
SET OwnerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);


--------------------------------------------------------------------------------------------------------------------------
-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Count the values of SoldASVacant column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing.nashville2
Group by SoldAsVacant
order by 2;

-- CASE statement to change 'Y' and 'N' to 'Yes' and 'No'
Select SoldAsVacant
, CASE When SoldAsVacant = 'N' THEN 'No'
	   When SoldAsVacant = 'Y' THEN 'Yes'
	   ELSE SoldAsVacant
	   END
From NashvilleHousing.nashville2;

-- Update the table using CASE statement to change 'Y' and 'N' to 'Yes' and 'No'
Update NashvilleHousing.nashville2
SET SoldAsVacant = CASE When SoldAsVacant = 'N' THEN 'No'
						When SoldAsVacant = 'Y' THEN 'Yes'
						ELSE SoldAsVacant
END;

-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Finds duplicate rows by using CTE

WITH RowNumCTE AS(
	Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID) 
                 row_num

From NashvilleHousing.nashville2)

Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress;
    
---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns

ALTER TABLE NashvilleHousing.nashville2
DROP COLUMN OwnerAddress, 
DROP COLUMN PropertyAddress;

    