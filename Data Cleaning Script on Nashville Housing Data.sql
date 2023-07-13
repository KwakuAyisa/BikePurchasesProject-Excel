select* from nashvillehousing
where PropertyAddress is null;

select* from nashvillehousing
order by parcelID;

select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ifnull(a.PropertyAddress, b.PropertyAddress)
from nashvillehousing a
join nashvillehousing b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
where a.PropertyAddress is null
;

commit;

#Performed a self join on the dataset to fix the null values in the property address column. Matched property addresses by using the ParcelID to match the same properties. 

update nashvillehousing a
join nashvillehousing b 
on a.ParcelID = b.ParcelID
and a.UniqueID <> b.UniqueID
set a.propertyaddress = ifnull(a.PropertyAddress, b.PropertyAddress)
where a.propertyaddress is null;


#Breaking up PropertyAddress into two columns ie address and city

select substring(propertyaddress, 1, locate(',', propertyaddress) -1) as Address,
substring(propertyaddress, locate(',', propertyaddress) +1, length(propertyaddress)) as City from nashvillehousing;

Alter table nashvillehousing
add PropertySplitAddress varchar(255);

Update nashvillehousing
Set PropertySplitAddress = substring(propertyaddress, 1, locate(',', propertyaddress) -1);

Alter table nashvillehousing
add PropertySplitCity varchar(255);

Update nashvillehousing
Set PropertySplitCity = substring(propertyaddress, locate(',', propertyaddress) +1, length(propertyaddress));

select * from nashvillehousing;


#Breaking up PropertyAddress into two columns ie address, city and state

select owneraddress from nashvillehousing;

select substring_index(owneraddress,',', 1),
 substring_index(substring_index(owneraddress,',', -2),',', 1),
 substring_index(owneraddress,',', -1)
from nashvillehousing;

Alter table nashvillehousing
add OwnerSplitAddress varchar(255);

Alter table nashvillehousing
add OwnerSplitCity varchar(255);

Alter table nashvillehousing
add OwnerSplitState varchar(255);

Update nashvillehousing
Set OwnerSplitAddress = substring_index(owneraddress,',', 1);

Update nashvillehousing
Set OwnerSplitCity = substring_index(substring_index(owneraddress,',', -2),',', 1);

Update nashvillehousing
Set OwnerSplitState = substring_index(owneraddress,',', -1);

select * from nashvillehousing; 

#Change Y and N to Yes and No in "Sold as Vacant" field

select distinct(soldasvacant), count(soldasvacant)
from nashvillehousing
group by soldasvacant
order by count(soldasvacant);

select soldasvacant,
case 
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
Else soldasvacant
end
from nashvillehousing
;

update nashvillehousing
set soldasvacant = case 
when soldasvacant = 'Y' then 'Yes'
when soldasvacant = 'N' then 'No'
Else soldasvacant
end;

#Remove duplicates

With RowNumCTE as(
Select *,
row_number() over (
partition by parcelID,
			Propertyaddress,
            saleprice,
            saledate,
            legalreference
            order by UniqueID) as Row_Num
 from nashvillehousing)
 select Row_num 
 from RowNumCTE
 where Row_Num > 1
 order by PropertyAddress;
 
delete from nashvillehousing
where
UniqueID in ( 
Select uniqueID
from(
select UniqueID,
row_number() over (
partition by parcelID,
			Propertyaddress,
            saleprice,
            saledate,
            legalreference
            order by UniqueID) as Row_Num
 from nashvillehousing) R
 where row_num > 1);
 
 
 
#Delete unused rows
select * from nashvillehousing;

Alter table nashvillehousing
drop column owneraddress;

Alter table nashvillehousing
drop column taxdistrict;

Alter table nashvillehousing
drop column propertyaddress;