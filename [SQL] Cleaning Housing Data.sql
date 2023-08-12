/*
Cleaning of Nashville Housing Dataset

Skills Used: Joins, CTE, Windows Functions, Aggregate Functions, Updating Tables, Converting Data Types

*/

SELECT *
FROM PortfolioProject2..NashvilleHouse

-- Standardising the Date Format


SELECT SaleDate, CONVERT(date, SaleDate)
FROM PortfolioProject2..NashvilleHouse

UPDATE NashvilleHouse
SET SaleDate = CONVERT(date, SaleDate)

-- Second method for correct Date Format


ALTER TABLE NashvilleHouse
ADD SaleDate2 date

UPDATE NashvilleHouse
SET SaleDate2 = CONVERT(date, SaleDate)


-- Populate Property Address Data


SELECT *
FROM PortfolioProject2..NashvilleHouse
--WHERE PropertyAddress is null
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHouse a
JOIN PortfolioProject2..NashvilleHouse b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null

 
UPDATE a
 SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
 FROM PortfolioProject2..NashvilleHouse a
JOIN PortfolioProject2..NashvilleHouse b
 ON a.ParcelID = b.ParcelID
 AND a.[UniqueID ] <> b.[UniqueID ]
 WHERE a.PropertyAddress is null


 -- Seperating Address into seperate columns (Address, City, State)


 SELECT PropertyAddress
FROM PortfolioProject2..NashvilleHouse


SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as City
FROM PortfolioProject2..NashvilleHouse


ALTER TABLE PortfolioProject2..NashvilleHouse
ADD PropertySplitAddress NVARCHAR(255)

UPDATE PortfolioProject2..NashvilleHouse
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


ALTER TABLE PortfolioProject2..NashvilleHouse
ADD PropertySplitCity NVARCHAR(255)

UPDATE PortfolioProject2..NashvilleHouse
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))


SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject2..NashvilleHouse


ALTER TABLE PortfolioProject2..NashvilleHouse
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE PortfolioProject2..NashvilleHouse
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE PortfolioProject2..NashvilleHouse
ADD OwnerSplitCity NVARCHAR(255)

UPDATE PortfolioProject2..NashvilleHouse
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE PortfolioProject2..NashvilleHouse
ADD OwnerSplitState NVARCHAR(255)

UPDATE PortfolioProject2..NashvilleHouse
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


-- Changing Y and N to Yes and No respectively in 'Sold as Vacant' field


SELECT DISTINCT(SoldAsVacant)
FROM PortfolioProject2..NashvilleHouse


SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
FROM PortfolioProject2..NashvilleHouse


UPDATE PortfolioProject2..NashvilleHouse
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
       WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END


-- Remove duplicates


WITH RowNumCTE AS (
SELECT *,
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
             PropertyAddress,
			 SaleDate,
			 SalePrice,
			 LegalReference
			 ORDER BY UniqueID) row_num

FROM PortfolioProject2..NashvilleHouse
)
DELETE
FROM RowNumCTE
WHERE row_num > 1


-- Deleting Unused Columns


ALTER TABLE PortfolioProject2..NashvilleHouse
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate
