/* 

Cleaning Data In SQL Queries

*/

Select * 
From NashvilleHousing

-- Standerdize Date Format

Select SaleDate, Convert(Date, SaleDate)
From NashvilleHousing

Update NashvilleHousing
Set SaleDate = Convert(Date, SaleDate) 

ALter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing 
Set SaleDateConverted = Convert(Date, SaleDate)

Select SaleDate, SaleDateConverted
From NashvilleHousing


-- Populate Property Address Data

Select *
From NashvilleHousing
Where PropertyAddress is Null

Select *
From NashvilleHousing
order by ParcelID

--ParcelID and Property Address are Same Across Rows

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is Null

Update a
Set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From NashvilleHousing a
Join NashvilleHousing b
    on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is Null

-- Breakig up Address into Independent Columns(Address, City, State)

Select PropertyAddress
From NashvilleHousing

-- Only column seperated by comma as a delimiter
-- CHARINDEX is used to search cell for word, number or symbol

Select 
Substring(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress) -1) as Address,
Substring(PropertyAddress, CHARINDEX(',' ,PropertyAddress) +1,LEN(PropertyAddress)) as Address
From NashvilleHousing

ALter Table NashvilleHousing
Add PropertySplitAddress NVarChar(255);

Update NashvilleHousing 
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',' ,PropertyAddress) -1)

ALter Table NashvilleHousing
Add PropertySplitCity NVarChar(255);

Update NashvilleHousing 
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',' ,PropertyAddress) +1,LEN(PropertyAddress))

-- Owner Address

Select OwnerAddress
From NashvilleHousing

-- ParseName does things backwards

Select 
ParseName(Replace(OwnerAddress, ',', '.'), 3),
ParseName(Replace(OwnerAddress, ',', '.'), 2),
ParseName(Replace(OwnerAddress, ',', '.'), 1)
From NashvilleHousing

ALter Table NashvilleHousing
Add OwnerSplitAddress NVarChar(255);

Update NashvilleHousing 
Set OwnerSplitAddress = ParseName(Replace(OwnerAddress, ',', '.'), 3)

ALter Table NashvilleHousing
Add OwnerSplitCity NVarChar(255);

Update NashvilleHousing 
Set OwnerSplitCity = ParseName(Replace(OwnerAddress, ',', '.'), 2)

ALter Table NashvilleHousing
Add OwnerSplitState NVarChar(255);

Update NashvilleHousing 
Set OwnerSplitState = ParseName(Replace(OwnerAddress, ',', '.'), 1)

-- Change Y and N to 'Yes' and 'No' in 'Sold and Vacant'

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From NashvilleHousing
Group by SoldAsVacant
order by 2

ALter Table NashvilleHousing
Alter Column SoldAsVacant Nvarchar(50);

Select SoldAsVacant
,  Case When SoldAsVacant = 1 then 'Yes'
        When SoldAsVacant = 0 then 'No'
		Else SoldAsVacant
		End
From NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 1 then 'Yes'
        When SoldAsVacant = 0 then 'No'
		Else SoldAsVacant
		End

-- Remove Duplicates

With RowNumCte AS (
Select *,
    Row_Number() Over (
	Partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by
				   UniqueID
				   )row_num
From NashvilleHousing
)

Delete
From RowNumCte
where row_num > 1



-- Delete Unused Columns

Select * 
From NashvilleHousing

Alter Table NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table NashvilleHousing
Drop Column SaleDate

