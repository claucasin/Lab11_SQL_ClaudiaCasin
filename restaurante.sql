-- 1. ¿Cuál es la cantidad total que gastó cada cliente en el restaurante?
select s.customer_id,
       sum(m.price) as total_gastado
from sales s
join menu m on s.product_id = m.product_id
group by s.customer_id
order by s.customer_id;

-- 2. ¿Cuántos días ha visitado cada cliente el restaurante?
select customer_id,
       count(distinct order_date) as dias_visitados
from sales
group by customer_id
order by customer_id;

-- 3. ¿Cuál fue el primer artículo del menú comprado por cada cliente?
select s.customer_id, m.product_name 
from sales s
join menu m on s.product_id = m.product_id
WHERE s.order_date = (
    SELECT MIN(order_date) 
    FROM sales 
    WHERE customer_id = s.customer_id
)
GROUP BY s.customer_id, m.product_name
ORDER BY s.customer_id;

-- 4. ¿Cuál es el artículo más comprado en el menú y cuántas veces lo compraron todos los clientes?
select m.product_name, count(*) as veces
from menu m
join sales s on s.product_id = m.product_id
group by m.product_name
order by veces desc
limit 1;

-- 5. ¿Qué artículo fue el más popular para cada cliente?
SELECT customer_id, product_name, compras
FROM (
    SELECT s.customer_id, m.product_name, COUNT(*) AS compras,
           RANK() OVER (PARTITION BY s.customer_id ORDER BY COUNT(*) DESC) AS rnk
    FROM sales s
    JOIN menu m ON s.product_id = m.product_id
    GROUP BY s.customer_id, m.product_name
) t
WHERE rnk = 1;

-- 6. ¿Qué artículo compró primero el cliente después de convertirse en miembro?
SELECT s.customer_id, m.product_name, s.order_date
FROM sales s
JOIN members mem ON s.customer_id = mem.customer_id
JOIN menu m ON s.product_id = m.product_id
WHERE s.order_date = (
    SELECT MIN(s2.order_date)
    FROM sales s2
    WHERE s2.customer_id = s.customer_id
      AND s2.order_date >= mem.join_date
);
 
-- 7. ¿Qué artículo se compró justo antes de que el cliente se convirtiera en miembro? 
SELECT s.customer_id, m.product_name
FROM sales s
JOIN menu m ON s.product_id = m.product_id
JOIN members mb ON s.customer_id = mb.customer_id
WHERE s.order_date = (
    SELECT MAX(order_date) 
    FROM sales 
    WHERE customer_id = s.customer_id 
      AND order_date < mb.join_date
);

-- 8. ¿Cuál es el total de artículos y la cantidad gastada por cada miembro antes de convertirse en miembro? 
select mb.customer_id,
       count(*) items_antes,
       sum(m.price) gasto_antes
from members mb
join sales s using (customer_id)
join menu m using (product_id)
where s.order_date < mb.join_date
group by mb.customer_id;

-- 9. Si cada \$1 gastado equivale a 10 puntos y el sushi tiene un multiplicador de puntos 2x, ¿Cuántos puntos tendría cada cliente?
select s.customer_id,
       sum(m.price * 10 * case when m.product_name='sushi' then 2 else 1 end) as puntos
from sales s
join members mb using (customer_id)
join menu m using (product_id)
where s.order_date >= mb.join_date
group by s.customer_id;

-- 10. En la primera semana después de que un cliente se une al programa (incluida la fecha de ingreso), gana el doble de puntos en todos los artículos, no solo en sushi. ¿Cuántos puntos tienen los clientes A y B a fines de enero?
select s.customer_id,
       sum(
         case
           when s.order_date between mb.join_date and date_add(mb.join_date, interval 6 day)
             then m.price * 20
           else m.price * 10 * case when m.product_name='sushi' then 2 else 1 end
         end
       ) as puntos_hasta_enero
from sales s
join members mb using (customer_id)
join menu m using (product_id)
where s.order_date >= mb.join_date
  and s.order_date < '2021-02-01'
group by s.customer_id;