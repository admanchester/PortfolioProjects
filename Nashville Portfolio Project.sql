/*

Data Cleaning Portfolio Project

Skills used: Standardizingg columns, Populating, Separating Columns for Optimization, Removing Duplicates

*/

-- Dataset I'll be using

Select *
FROM PortfolioProject1..NashvilleClean

--Standardizing Sale Date

Select SaleDate, CONVERT( date,saledate)
FROM PortfolioProject1..NashvilleClean


Alter Table NashvilleClean
Alter Column SaleDate date

--Populate Property Address Data

Select ParcelID, PropertyAddress
FROM PortfolioProject1..NashvilleClean

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleClean a
JOIN PortfolioProject1..NashvilleClean b
	on a.ParcelID= b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a 
SET PropertyAddress= ISNULL( a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject1..NashvilleClean a
JOIN PortfolioProject1..NashvilleClean b
	on a.ParcelID= b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress is NULL

-- Separating Address Column into Address, City, State

Select
SUBSTRING( PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)-1) as Address,
SUBSTRING( PropertyAddress, CHARINDEX( ',', PropertyAddress) +1, LEN(PropertyAddress)) as City
FROM PortfolioProject1..NashvilleClean

Alter Table NashvilleClean
Add PropertySplitAddress nvarchar(255);

UPDATE NashvilleClean
Set PropertySplitAddress = SUBSTRING( PropertyAddress, 1, CHARINDEX( ',', PropertyAddress)-1)


Alter Table NashvilleClean
Add PropertySplitCity nvarchar(255);

UPDATE NashvilleClean
Set PropertySplitCity = SUBSTRING( PropertyAddress, CHARINDEX( ',', PropertyAddress) +1, LEN(PropertyAddress))


Select 
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
FROM PortfolioProject1..NashvilleClean


Alter Table NashvilleClean
Add OwnerSplitAddress nvarchar(255);

UPDATE NashvilleClean
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


Alter Table NashvilleClean
Add OwnerSplitCity nvarchar(255);

UPDATE NashvilleClean
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


Alter Table NashvilleClean
Add OwnerSplitState nvarchar(255);

UPDATE NashvilleClean
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

--Changing Y and N to Yes and No in 'Sold As Vacant' Column

Select DISTINCT(SoldAsVacant), Count(SoldAsVacant)
FROM PortfolioProject1..NashvilleClean
GROUP BY(SoldAsVacant)
ORDER BY 2

Select SoldAsVacant,
	CASE When SoldAsVacant= 'Y' THEN 'Yes'
		 When SoldAsVacant= 'N' THEN 'No'
		 ELSE SoldAsVacant
	END
FROM PortfolioProject1..NashvilleClean

UPDATE NashvilleClean
SET SoldAsVacant= CASE When SoldAsVacant= 'Y' THEN 'Yes'
		 When SoldAsVacant= 'N' THEN 'No'
		 ELSE SoldAsVacant
	END

--Remove Duplicates

With RowNumCTE AS (
Select *,
	ROW_NUMBER () OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SaleDate,
				 SalePrice,
				 LegalReference
				 Order By UniqueID
				 ) row_num
FROM PortfolioProject1..NashvilleClean
)

Select * 
From RowNumCTE
Where row_num>1

--Deleting Unused Columns

Select *
FROM PortfolioProject1..NashvilleClean

ALTER TABLE PortfolioProject1..NashvilleClean
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict

ALTER TABLE PortfolioProject1..NashvilleClean
DROP COLUMN SaleDate