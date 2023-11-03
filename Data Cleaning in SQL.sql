
/*

Nashville Housing Data Cleaning in SQL Queries

*/

select *
from PortfolioProject..NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

select saleDate, convert(date, SaleDate) as New_SaleDate
from PortfolioProject..NashvilleHousing


update PortfolioProject..NashvilleHousing
SET SaleDate = convert(date, SaleDate)


-- If it doesn't Update properly

ALTER TABLE PortfolioProject..NashvilleHousing
Add SaleDateConverted date;

update PortfolioProject..NashvilleHousing
SET SaleDateConverted = convert(date, SaleDate)




 --------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data


select *
from PortfolioProject..NashvilleHousing
where PropertyAddress is null
order by ParcelID

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, isnull( a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
ON a.parcelID = b.parcelID
AND a.uniqueID <> b.uniqueID
WHERE a.propertyAddress is null

update a
SET PropertyAddress = isnull( a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
join PortfolioProject..NashvilleHousing b
ON a.parcelID = b.parcelID
AND a.uniqueID <> b.uniqueID
WHERE a.propertyAddress is null



--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Columns (Address, City, State)


select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


select 
substring(Propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1) as address,
substring(Propertyaddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) as address

from PortfolioProject..NashvilleHousing


ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertyAddressSplit Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET PropertyAddressSplit = substring(Propertyaddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE PortfolioProject..NashvilleHousing
Add PropertyCitySplit Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET PropertyCitySplit = substring(Propertyaddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

select owneraddress
from PortfolioProject..NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress, ',', '.'), 3),
PARSENAME(Replace(OwnerAddress, ',', '.'), 2),
PARSENAME(Replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerAddressSplitAddress Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET  OwnerAddressSplitAddress = PARSENAME(Replace(OwnerAddress, ',', '.'), 3)

ALTER TABLE PortfolioProject..NashvilleHousing
Add  OwnerAddressSplitCity Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET OwnerAddressSplitCity = PARSENAME(Replace(OwnerAddress, ',', '.'), 2)

ALTER TABLE PortfolioProject..NashvilleHousing
Add OwnerAddressSplitState Nvarchar(255);

update PortfolioProject..NashvilleHousing
SET OwnerAddressSplitState = PARSENAME(Replace(OwnerAddress, ',', '.'), 1)

--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasVacant), Count(soldasVacant)
from PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant,
CASE
	WHEN SoldasVacant = 'Y' THEN 'Yes'
	when SoldasVacant = 'N' THEN 'No'
	Else SoldAsVacant
END
from PortfolioProject..NashvilleHousing


update PortfolioProject..NashvilleHousing
SET
SoldAsVacant =
CASE
	WHEN SoldasVacant = 'Y' THEN 'Yes'
	when SoldasVacant = 'N' THEN 'No'
	Else SoldAsVacant
END


-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates
---using CTEs and Windows Functions      --- you can use Row Number, Rank, Order Rank

with RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)

Select *
From RowNumCTE
WHERE row_num > 1


with RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

from PortfolioProject..NashvilleHousing
--order by ParcelID
)

Delete 
From RowNumCTE
WHERE row_num > 1

---Use Select * to check the duplicate entries and then use Delete to take them out



---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns


Select *
from PortfolioProject..NashvilleHousing

Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column Saledate



