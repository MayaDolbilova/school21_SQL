CREATE VIEW v_price_with_discount AS
SELECT person.name AS name, menu.pizza_name AS pizza_name, menu.price AS price, ROUND((price - price * 0.1),0) AS discount_price
FROM person_order po JOIN menu ON po.menu_id = menu.id JOIN person ON po.person_id = person.id
ORDER BY name, pizza_name;