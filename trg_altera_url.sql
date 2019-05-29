CREATE TRIGGER `zabbix`.`trg_altera_url`
BEFORE UPDATE ON `triggers`
FOR EACH ROW
BEGIN

DECLARE P int;

SELECT distinct new.priority INTO P
	FROM triggers t,
	functions f,
	items i,
	hosts h,
	hosts_groups hg,
	hstgrp g
where
	f.triggerid = t.triggerid
	and i.itemid = f.itemid
	and i.hostid = h.hostid
	and hg.hostid = h.hostid
	and g.groupid = hg.groupid
	and g.groupid in (61,85)
    and (t.triggerid = new.triggerid
    or new.triggerid = t.templateid);
    
    if (old.priority <> new.priority) then
	if P = 1 then
		set NEW.url = '{$URL_INFORMATION}';
        elseif P = 2 then
		set NEW.url = '{$URL_WARNING}';
	elseif P = 3 then
		set NEW.url = '{$URL_AVERAGE}';
	elseif P = 4 then
		set NEW.url = '{$URL_HIGH}';
	elseif P = 5 then
		set NEW.url = '{$URL_DISASTER}';
	end if;
    end if;

END
