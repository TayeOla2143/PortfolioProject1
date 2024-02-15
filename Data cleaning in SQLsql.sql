select * 
from dbo.[nashvilla_housing ]

----FORMATING SALEDATE 
select sale_date_converted
from dbo.[nashvilla_housing ]

select sale_date_converted,convert(date,SaleDate)
from dbo.[nashvilla_housing ]

update dbo.[nashvilla_housing ]
set SaleDate = convert(date,SaleDate)

alter table nashvilla_housing
add sale_date_converted date


update dbo.[nashvilla_housing ]
set sale_date_converted = convert(date,SaleDate)

----- populating property address 

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from dbo.[nashvilla_housing ] a
join  dbo.[nashvilla_housing ] b 
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

update a

set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from dbo.[nashvilla_housing ] a
join  dbo.[nashvilla_housing ] b 
on a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

----- Breaking out Address into individual columns(address,city and state)

select PropertyAddress 
from dbo.[nashvilla_housing ]
order by ParcelID

select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,

SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))as Address 

from dbo.[nashvilla_housing ]

alter table nashvilla_housing
add property_split_Address nvarchar(225)


update dbo.[nashvilla_housing ]
set property_split_Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

alter table nashvilla_housing
add property_split_City nvarchar(225)


update dbo.[nashvilla_housing ]
set property_split_City  = SUBSTRING(PropertyAddress ,CHARINDEX(',',PropertyAddress)+1,len(PropertyAddress))

select OwnerAddress
from dbo.[nashvilla_housing ]


select 
PARSENAME (REPLACE(OwnerAddress,',','.') ,3),
PARSENAME (REPLACE(OwnerAddress,',','.') ,2),
PARSENAME (REPLACE(OwnerAddress,',','.') ,1)

from  dbo.[nashvilla_housing ]

alter table nashvilla_housing
add Owner_split_Address nvarchar(225)


update dbo.[nashvilla_housing ]
set Owner_split_Address = PARSENAME (REPLACE(OwnerAddress,',','.') ,3)

alter table nashvilla_housing
add Owner_split_City nvarchar(225)


update dbo.[nashvilla_housing ]
set Owner_split_City = PARSENAME (REPLACE(OwnerAddress,',','.') ,2)


alter table nashvilla_housing
add Owner_split_State nvarchar(225)


update dbo.[nashvilla_housing ]
set Owner_split_State = PARSENAME (REPLACE(OwnerAddress,',','.') ,1)


select * 
from dbo.[nashvilla_housing ]

-----Chage N and Y as No amd Yes in 'sold as vacant'


select distinct(SoldAsVacant),count(SoldAsVacant)

from dbo.[nashvilla_housing ]
group by SoldAsVacant
order by 2


select SoldAsVacant,
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END
from dbo.[nashvilla_housing ]


update dbo.[nashvilla_housing ]
set  SoldAsVacant = 
CASE When SoldAsVacant = 'Y' THEN 'Yes'
     When SoldAsVacant = 'N' THEN 'No'
	 ELSE SoldAsVacant
	 END


	 -----Removing Duplicate

WITH Cte_Row_num AS (
	 select *,
	       ROW_NUMBER() over(
		   PARTITION BY ParcelID,
		                PropertyAddress,
						SaleDate,
						LegalReference
						order by UniqueID) row_value

from dbo.[nashvilla_housing ]
)
delete  FROM Cte_Row_num 
where  row_value >1 
--order by PropertyAddress


---Delete unsed columns 

select * 
from dbo.[nashvilla_housing ]
 
 ALTER TABLE dbo.[nashvilla_housing ]
 DROP COLUMN OwnerAddress,TaxDistrict,PropertyAddress

 
 ALTER TABLE dbo.[nashvilla_housing ]
 DROP COLUMN SaleDate