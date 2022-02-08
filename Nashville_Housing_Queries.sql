/*
Cleaning Data in SQL Queries

*/

-- Add a column to display sale date without time
Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

------------------------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


Select *
From PortfolioProject.dbo.NashvilleHousing
order by ParcelID

-- View rows where ParcelID is the same, the UniqueID is different and the porperty address is null
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Copy the property address to the rows missing it from rows with identical ParcelID
-- The property address is identical in rows with the same ParcelID
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From PortfolioProject.dbo.NashvilleHousing a
JOIN PortfolioProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-----------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)

-- Verify that we can access the city and address substrings
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) as City
From PortfolioProject.dbo.NashvilleHousing

-- Add columns for separated city and address
ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

----------------------------------------------

-- Similar to what was done above except by parsing and also creating a state column
Select *
From PortfolioProject.dbo.NashvilleHousing


Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing

Select PARSENAME(REPLACE(OwnerAddress, ',', '.'),3),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),2),
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
From PortfolioProject..NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)


Select *
From PortfolioProject.dbo.NashvilleHousing


------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as Vacant" field

-- Check to see how many different values in column
Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

-- Verify that using cases to change values makes them consistent
Select SoldAsVacant, 
	CASE When SoldASVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
From PortfolioProject..NashvilleHousing

-- Alter table and use cases to change values to make them consistent
Update NashvilleHousing
SET SoldAsVacant = 
	CASE When SoldASVacant = 'Y' THEN 'Yes'
	When SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END


----------------------------------------------------------

--Remove Duplicates

-- Use a CTE to identify duplicate rows and remove them
WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID, PropertyAddress,SalePrice, SaleDate, LegalReference ORDER BY UniqueID) row_num
From PortfolioProject..NashvilleHousing
)

--Select *
--From RowNumCTE
--Where row_num > 1
--Order by PropertyAddress

Delete
From RowNumCTE
Where row_num > 1



--------------------------------------------------------------------------

-- Delete Unused Columns
-- Remove from the table the OwnerAddress, TaxDistrict, PropertyAddress, and outdated SaleDate columns
Select *
From PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

