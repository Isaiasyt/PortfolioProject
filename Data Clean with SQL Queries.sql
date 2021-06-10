/*
Data cleaning practice with SQL queries - following video by Alex the Analyst
Using the Nashville housing dataset. Video is here: https://youtu.be/8rO7ztF4NtU 
I found following along with Alex to be a great way to refresh on skills and stimulating. 
I basically reproduced Alex's scripts; sometimes I paused the video and researched some of the concepts.
*/

select * from NashvilleHousing


-- Standardize Date Format

select SaleDate,CONVERT(Date,SaleDate) 
from NashvilleHousing

update NashvilleHousing
set SaleDate = CONVERT(Date,SaleDate)

alter table NashvilleHousing
add SaleDateConverted Date;

update NashvilleHousing
set SaleDateConverted = CONVERT(Date,SaleDate)

select SaleDateConverted,CONVERT(Date,SaleDate) 
from NashvilleHousing


-- Populate Property Address data
select PropertyAddress 
from NashvilleHousing
where PropertyAddress is null


select *
from NashvilleHousing
where PropertyAddress is null
Order by ParcelID

-- self-join
select N1.ParcelID,N1.PropertyAddress,N2.ParcelID,N2.PropertyAddress,
isnull(N1.PropertyAddress,N2.PropertyAddress) 
from NashvilleHousing N1
join NashvilleHousing N2
	on N1.ParcelID = N2.ParcelID
	and N1.UniqueID <> N2.UniqueID
where N1.PropertyAddress is null 


update N1 
set PropertyAddress = isnull(N1.PropertyAddress,N2.PropertyAddress) 
from NashvilleHousing N1
join NashvilleHousing N2
	on N1.ParcelID = N2.ParcelID
	and N1.UniqueID <> N2.UniqueID
where N1.PropertyAddress is null


-- Breaking out Address into Individual Columns (Address, City, State)
-- check the delimitor 
select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--Order by ParcelID

select
substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address,
charindex(',',PropertyAddress)
from NashvilleHousing

select
substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1) as Address
, substring(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress)) as Address
from NashvilleHousing

alter table NashvilleHousing
add SplitAddress Nvarchar(255);

update NashvilleHousing
set SplitAddress = substring(PropertyAddress, 1, charindex(',',PropertyAddress)-1)

alter table NashvilleHousing
add SplitCity Nvarchar(255);

update NashvilleHousing
set SplitCity = substring(PropertyAddress, charindex(',',PropertyAddress) +1, len(PropertyAddress))

select *
from NashvilleHousing


select OwnerAddress
from NashvilleHousing


select 
parsename(OwnerAddress,1)
from NashvilleHousing

select 
parsename(replace(OwnerAddress,',',','),1)
,parsename(replace(OwnerAddress,',',','),2)
,parsename(replace(OwnerAddress,',',','),3)
from NashvilleHousing


select 
parsename(replace(OwnerAddress,',',','), 3)
,parsename(replace(OwnerAddress,',',','), 2)
,parsename(replace(OwnerAddress,',',','), 1)
from NashvilleHousing

-- the above did not work the first time. Tried by copying Alex's script
Select OwnerAddress
From NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From NashvilleHousing

-- Change Y and N to Yes and No in "Sold as Vacant" field

select SoldAsVacant
from NashvilleHousing
where SoldAsVacant = 'Yes' or SoldAsVacant = 'No'


select distinct(SoldAsVacant),count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2


select SoldAsVacant
, case when SoldAsVacant = 'Y' then 'Yes'
	   when SoldAsVacant = 'N' then 'No'
	   else SoldAsVacant
	   end
from NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END



-- Remove Duplicates **RowNumCTE is new to me but looks really cool to practice

WITH RowNumCTE AS(
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

From NashvilleHousing
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From NashvilleHousing


-- Delete Unused Columns



Select *
From NashvilleHousing


ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate




