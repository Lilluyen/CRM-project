UPDATE Customer_Segments
SET criteria_logic = 
CASE segment_id

WHEN 1 THEN
'Customers with a loyalty tier of PLATINUM or DIAMOND. '

WHEN 2 THEN
'GOLD customers'

WHEN 3 THEN
'Status is New and created within the last 3 months.'

WHEN 4 THEN
'Status is "Crunched" or more than 6 months have passed since the last purchase (or never made a purchase).'

WHEN 5 THEN
'Return rate greater or equal 40%'

END
WHERE segment_id IN (1,2,3,4,5);