SELECT * 
FROM dbo.NashvilleHousing;

-- Standarize Date Format

SELECT SaleDateConverted, CONVERT(Date, SaleDate)
FROM dbo.NashvilleHousing;

UPDATE dbo.NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE dbo.NashvilleHousing
ADD SaleDateConverted Date;


UPDATE dbo.NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

-- Populate Property Address Data

SELECT * 
FROM dbo.NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM dbo.NashvilleHousing a
JOIN dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress IS NULL


-- Breaking out Address into Individual Columns ( Address, City, State)

SELECT PropertyAddress 
FROM dbo.NashvilleHousing

SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitAddress NVARCHAR(255);


UPDATE dbo.NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE dbo.NashvilleHousing
ADD PropertySplitCity NVARCHAR(255);


UPDATE dbo.NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))


SELECT * 
FROM dbo.NashvilleHousing


SELECT OwnerAddress
FROM dbo.NashvilleHousing
WHERE OwnerAddress IS NOT NULL

SELECT
PARSENAME(REPLACE(OwnerAddress,',', '.'),3) AS Address,
PARSENAME(REPLACE(OwnerAddress,',', '.'),2) AS City,
PARSENAME(REPLACE(OwnerAddress,',', '.'),1) AS State
FROM dbo.NashvilleHousing
WHERE OwnerAddress IS NOT NULL

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitAddress NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitCity NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

ALTER TABLE dbo.NashvilleHousing
ADD OwnerSplitState NVARCHAR(255);

UPDATE dbo.NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

SELECT * 
FROM dbo.NashvilleHousing
WHERE OwnerAddress IS NOT NULL;

--- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT SoldAsVacant, CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						  WHEN SoldAsVacant = 'N' THEN 'NO'
						  ELSE SoldAsVacant
					END
FROM dbo.NashvilleHousing

UPDATE dbo.NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'YES'
						  WHEN SoldAsVacant = 'N' THEN 'NO'
						  ELSE SoldAsVacant
					END

SELECT DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM dbo.NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2


-- REMOVE DUPLICATES ( PRETENDING THERE IS NO UNIQUEID)

WITH RowNumCTE AS(
SELECT *, 
ROW_NUMBER() OVER (
PARTITION BY ParcelID,
			 PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
ORDER BY UniqueID) row_num
FROM dbo.NashvilleHousing
)

SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress;


-- DELETE UNUSED COLUMNS

SELECT * 
FROM dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
