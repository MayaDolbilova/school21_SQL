SELECT menu.id AS menu_id
FROM menu
WHERE menu.id NOT IN (SELECT po.menu_id FROM person_order po)
ORDER BY menu_id;