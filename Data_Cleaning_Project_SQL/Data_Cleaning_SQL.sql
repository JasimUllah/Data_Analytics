-- Data cleaning in SQL

select *
from PortfolioProject.dbo.NashvilleHousing



-- Standardizing Data Format

select saleDateConverted, convert(Date, SaleDate)
from PortfolioProject.dbo.NashvilleHousing

update NashvilleHousing
set SaleDate = convert(date, SaleDate)

alter table NashvilleHousing
add saleDateConverted Date;

update NashvilleHousing
set saleDateConverted = convert(Date, SaleDate)

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------



-- Populating the data of Property Address

select *
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
order by ParcelID

select A.ParcelID, A.PropertyAddress, B.ParcelID, B.PropertyAddress, isnull(A.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing A
join PortfolioProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

update A
set PropertyAddress =  isnull(A.PropertyAddress, b.PropertyAddress)
from PortfolioProject.dbo.NashvilleHousing A
join PortfolioProject.dbo.NashvilleHousing B
	on A.ParcelID = B.ParcelID
	and A.[UniqueID ] <> B.[UniqueID ]
where A.PropertyAddress is null

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------




-- Breaking Address into Single Columns

select PropertyAddress
from PortfolioProject.dbo.NashvilleHousing
--where PropertyAddress is null
--order by ParcelID


-- Here we want to look at only the character before appearing comma(,)
-- CHARINDEX(',', PropertyAddress) is specifying the position that at which position the ',' appears
select
substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address,
substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress)) as Address
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add PropertSplitAddress nvarchar(255);

update NashvilleHousing
set PropertSplitAddress = substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)


alter table NashvilleHousing
add PropertSplitCity nvarchar(255);

update NashvilleHousing
set PropertSplitCity = substring(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, len(PropertyAddress))



select OwnerAddress
from PortfolioProject.dbo.NashvilleHousing

		-- Splitting the complete owner address into single addresses
select
PARSENAME(replace(OwnerAddress, ',', '.'), 3),
PARSENAME(replace(OwnerAddress, ',', '.'), 2),
PARSENAME(replace(OwnerAddress, ',', '.'), 1)
from PortfolioProject.dbo.NashvilleHousing


alter table NashvilleHousing
add OwnerSplitAddress nvarchar(255);

update NashvilleHousing
set OwnerSplitAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3)


alter table NashvilleHousing
add OwnerSplitCity nvarchar(255);

update NashvilleHousing
set OwnerSplitCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2)


alter table NashvilleHousing
add OwnerSplitState nvarchar(255);

update NashvilleHousing
set OwnerSplitState = PARSENAME(replace(OwnerAddress, ',', '.'), 1)


select *
from PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------





-- changing Y and N to "Yes and No" in SolidAsVacant columns

select distinct(SoldAsVacant), count(SoldAsVacant)
from PortfolioProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N'then 'No'
		 else SoldAsVacant
		 end
from PortfolioProject.dbo.NashvilleHousing


update NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		 when SoldAsVacant = 'N'then 'No'
		 else SoldAsVacant
		 end

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------



-- Removing Duplicates
-- Usimg CTE's and some window functions
-- partition should be done on thing that are unique to each row

with RowNumCTE as(
select *,
	ROW_NUMBER() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				 UniqueID
	) row_num
from PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by PropertyAddress

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------




-- Deleting unused columns

alter table PortfolioProject.dbo.NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress

alter table PortfolioProject.dbo.NashvilleHousing
drop column SaleDate



select *
from PortfolioProject.dbo.NashvilleHousing

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------