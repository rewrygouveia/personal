CREATE TRIGGER `zabbix`.`trg_altera_url_na_insercao_da_trigger`
AFTER INSERT ON `functions`
FOR EACH ROW
BEGIN

UPDATE triggers t,
    items i,
    hosts h,
    hosts_groups hg,
    hstgrp g 
SET 
    t.url = (CASE t.priority
        WHEN 1 THEN '{$URL_INFORMATION}'
        WHEN 2 THEN '{$URL_WARNING}'
        WHEN 3 THEN '{$URL_AVERAGE}'
        WHEN 4 THEN '{$URL_HIGH}'
        WHEN 5 THEN '{$URL_DISASTER}'
        ELSE 'N/A'
    END)
WHERE
    t.triggerid = new.triggerid
        AND i.itemid = new.itemid
        AND i.hostid = h.hostid
        AND hg.hostid = h.hostid
        AND g.groupid = hg.groupid
        AND g.groupid IN (61,85)
        AND (t.triggerid = new.triggerid
        OR t.templateid = new.triggerid);

END
