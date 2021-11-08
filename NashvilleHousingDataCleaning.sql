Select *
From PortfolioProject..NashvilleHousing

-- Standardize Date Format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)



-- Populate Property Address data

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.propertyaddress, b.PropertyAddress)
From PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



-- Breaking out address into individual Columns

Select PropertyAddress
From PortfolioProject..NashvilleHousing

Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as Address

From PortfolioProject..NashvilleHousing

USE PortfolioProject

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)


ALTER TABLE NashvilleHousing
Add PropertySplitCity Date;

ALTER TABLE NashvilleHousing 
ALTER COLUMN PropertySplitCity nvarchar(255) 

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))


--

Select OwnerAddress
From PortfolioProject..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 2)
,PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
From PortfolioProject..NashvilleHousing





ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)



Select * 
From PortfolioProject..NashvilleHousing







-- Y and N to Yes and No in "Sold as Vacant" field



Select Distinct(SoldasVacant), Count(SoldAsVacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2






Select SoldAsvacant, 
CASE when Soldasvacant = 'Y' THEN 'Yes'
	 When SoldasVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 end
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE when Soldasvacant = 'Y' THEN 'Yes'
	 When SoldasVacant = 'N' THEN 'No'
	 Else SoldAsVacant
	 end
From PortfolioProject..NashvilleHousing






--Remove Duplicates
WITH RowNumCTE AS(
Select*,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY UniqueID
					) row_num

From PortfolioProject..NashvilleHousing
--order by ParcelID
)
Delete
From RowNumCTE
Where row_num > 1
--order by PropertyAddress
