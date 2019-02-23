select slotname,days,begintime,endtime from (events natural join weeklyeventtime on events.id = %s) natural join slotdetails
order by case when days = 'Mon' then 1 when days='Tue' then 2 when days='Wed' then 3 when days='Thu' then 4 when days = 'Fri' then 5 when days='Sat' then 6 when days = 'Sun' then 7,begintime

select ondate,begintime,endtime from (events natural join onetimeeventtime on events.id = %s) order by ondate,begintime

select * from events where events.alias ilike concat('%',%s,'%') and events.name ilike concat('%',%s,'%')
select * from events where events.alias = %s
