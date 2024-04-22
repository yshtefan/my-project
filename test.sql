with t (sname, city, region) as   (
     select x.sname, x.city, x.region
from
(select m.name  || ' ['||n.address||']' as sname, --Название и адрес магазина
        (select pl.name from places pl where pl.answer = n.idplace) as city, -- Город, в котором находится магазин
        (select rr.name from regions rr where rr.region = n.region) as region --Регион
   from stores m, store_address n 
  where m.id = n.idstore
    and exists (select 1
                  from store_network mc
                 where mc.id = m.idnetwork
                   and sysdate between mc.date_from and mc.date_to) --Смотрим, чтобы выводились магазины только действующих сетей
 )x
 )
--Выводим название каждого региона перед списком магазинов и городов
select  case  when grouping_id(region, sname, city) = 3 then chr(10)||chr(13)||'   '||
                                                                            region||chr(10)||chr(13) else sname  end sname, city
from t
group by grouping sets(t.region,(t.region,t.sname,t.city))
order by   case when t.region like '%Москва%' then 1 end, --сортируем
                               case   when t.region like '%Санкт-Петербург%' then 2 end,
                                 t.region, grouping_id(t.sname, t.city, t.region) desc, t.city, t.sname;
