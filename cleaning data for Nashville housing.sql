-- cleaning data for Nashville Housing

select *
from [potfolio-projects].[dbo].[Nashville Housing Data for Data Cleaning]

--standarizing saleDate format


alter table [dbo].[Nashville Housing Data for Data Cleaning]
add new_sale_date date;

update [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
set new_sale_date=CONVERT(date,SaleDate)

-- testing the SaleDate update 
select new_sale_date
from [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
--finding nulls in property address
select [ParcelID],PropertyAddress
from  [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
where PropertyAddress  is null

--populate propertie addres

select t1.ParceliD
       ,t1.PropertyAddress
       ,t2.ParceliD
       ,t2.PropertyAddress
	   ,ISNULL(t2.PropertyAddress,t1.PropertyAddress) 
from 
    [potfolio-projects]..[Nashville Housing Data for Data Cleaning] as t1
join 
    [potfolio-projects]..[Nashville Housing Data for Data Cleaning] as t2
on 
   t1.ParceliD=t2.ParceliD and
   t1.UniqueID <> T2.UniqueID
where 
     t2.PropertyAddress is null
--updating the propertyaddress coloumn 

update t1
set PropertyAddress=ISNULL(t2.PropertyAddress,t1.PropertyAddress) 
from 
     [potfolio-projects]..[Nashville Housing Data for Data Cleaning] as t1
join 
     [potfolio-projects]..[Nashville Housing Data for Data Cleaning] as t2
on 
     t1.ParceliD=t2.ParceliD and
     t1.UniqueID <> T2.UniqueID


-- testing the PropertyAddress coloumn update 
select * 
from [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
where PropertyAddress is null

-- breaking out address to individual columns 

select addresss
from [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
-- using susbstring to split the addres and CHARINDEX to specify the place of the separation 
select 
  SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1) as addresss 
,SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+1,LEN(PropertyAddress)) as city
from [potfolio-projects]..[Nashville Housing Data for Data Cleaning]



alter table [Nashville Housing Data for Data Cleaning]
add property_addresss Nvarchar(255);

update [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
set property_addresss =SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress,1)-1) 

alter table [Nashville Housing Data for Data Cleaning]
add property_city Nvarchar(255);

update [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
set property_city =SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress,1)+1,LEN(PropertyAddress)) 


-- owner address modification
select PARSENAME(replace(OwnerAddress,',','.'),1) as state
,PARSENAME(replace(OwnerAddress,',','.'),2) as city
,PARSENAME(replace(OwnerAddress,',','.'),3) as addres
,OwnerAddress
from [potfolio-projects].[dbo].[Nashville Housing Data for Data Cleaning]



--owener_state
alter table [Nashville Housing Data for Data Cleaning]
add owner_state Nvarchar(255);

update [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
set owner_state = PARSENAME(replace(OwnerAddress,',','.'),1)



--owener_addres
alter table [Nashville Housing Data for Data Cleaning]
add owener_cityy Nvarchar(255);

update [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
set owener_cityy = PARSENAME(replace(OwnerAddress,',','.'),2)


--owener_city
alter table [Nashville Housing Data for Data Cleaning]
add owner_address Nvarchar(255);

update [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
set owner_address = PARSENAME(replace(OwnerAddress,',','.'),3)

--
select SoldAsVacant
from [potfolio-projects]..[Nashville Housing Data for Data Cleaning]

-- changing 1 and 0  to Yes and No in 'Soldasvacant'

select SoldAsVacant,
case when SoldAsVacant='0' then  'No'
 when SoldAsVacant= '1' THEN  'Yes' 
end as new_sold_as_vacent
from [potfolio-projects]..[Nashville Housing Data for Data Cleaning]

alter table [Nashville Housing Data for Data Cleaning] 
add new_sold_as_vacent  Nvarchar(50)

update [Nashville Housing Data for Data Cleaning] 
set new_sold_as_vacent  = case when SoldAsVacant='0' then  'No'
                    when SoldAsVacant= '1' THEN  'Yes' 
                    end

--separating duplicates duplicates 
with no_duplicate_data as (
select ROW_NUMBER() over(PARTITION BY 
[ParcelID]
,[PropertyAddress]
,[SaleDate]
,[SalePrice]
,[LegalReference]
order by 
[UniqueID]
) as num_row,*
from  [potfolio-projects]..[Nashville Housing Data for Data Cleaning]
)
--deleting dupplicates

select *
from no_duplicate_data
where num_row >1

delete
from no_duplicate_data
where num_row >1


--delete unused coloumns
select *
from  [potfolio-projects]..[Nashville Housing Data for Data Cleaning]

alter table [Nashville Housing Data for Data Cleaning]
drop column [PropertyAddress],[OwnerAddress],[TaxDistrict],city,owner_addres,owner_city,SoldAsVacant,address, addresss,SaleDate

