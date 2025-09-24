-- EJERCICIO 1
-- 1. Contacto de oficina 
select officeCode, phone
from offices
order by officeCode;

-- Detectives de email 
select employeeNumber, firstName, lastName, email
from employees
where email like '%.es';

-- Estado de confusión
select customerName, state
from customers
where state is null or state = '';

-- Grandes gastadores > $20,000
select customerNumber, amount
from payments
where amount > 20000
order by amount desc;

-- Grandes gastadores de 2005: pagos > $20,000 en 2005
select customerNumber, paymentDate, amount
from payments
where amount > 20000
  and year(paymentDate) = 2005
order by amount desc;

-- Detalles distintos
select distinct productCode
from orderdetails
order by productCode;

-- Estadísticas globales de compradores
SELECT c.country, COUNT(o.orderNumber) AS total_pedidos
FROM customers c
JOIN orders o ON c.customerNumber = o.customerNumber
GROUP BY c.country
ORDER BY total_pedidos DESC;

-- EJERCICIO 2
-- Descripción de línea de producto más larga 
SELECT productLine, LENGTH(textDescription) AS longitud
FROM productlines
ORDER BY longitud DESC
LIMIT 1;

-- Recuento de clientes de oficina
select o.officeCode, o.city,
       count(distinct c.customerNumber) as clientes
from offices o
left join employees e on e.officeCode = o.officeCode
left join customers c on c.salesRepEmployeeNumber = e.employeeNumber
group by o.officeCode, o.city
order by o.officeCode;

-- Día de mayores ventas de automóviles
select dayname(o.orderDate) as dia,
       sum(od.quantityOrdered) as unidades
from orders o
join orderdetails od on od.orderNumber = o.orderNumber
join products p on p.productCode = od.productCode
join productlines pl on pl.productLine = p.productLine
where pl.productLine like '%car%'
group by dayname(o.orderDate)
order by unidades desc
limit 1;

-- Corrección de datos territoriales faltantes
select officeCode, city,
       case
         when territory is null or territory = '' or territory = 'NA' then 'USA'
         else territory
       end as territory_fix
from offices;

-- Estadísticas de empleados de la familia Patterson
SELECT YEAR(o.orderDate) AS anio, MONTH(o.orderDate) AS mes,
       AVG(od.quantityOrdered * od.priceEach) AS promedio_carrito,
       SUM(od.quantityOrdered) AS total_items
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
JOIN customers c ON o.customerNumber = c.customerNumber
JOIN employees e ON c.salesRepEmployeeNumber = e.employeeNumber
WHERE e.lastName = 'Patterson'
  AND YEAR(o.orderDate) IN (2004, 2005)
GROUP BY anio, mes
ORDER BY anio, mes;

-- EJERCICIO 3
-- patterson
select
  year(o.orderDate)  as anio,
  month(o.orderDate) as mes,
  round(avg(t.total_pedido), 2) as monto_promedio_carrito,
  sum(t.items)                  as total_articulos
from orders o
join (
  select od.orderNumber,
         sum(od.quantityOrdered * od.priceEach) as total_pedido,
         sum(od.quantityOrdered)                as items
  from orderdetails od
  group by od.orderNumber
) t on t.orderNumber = o.orderNumber
join customers c  using (customerNumber)
join employees e  on e.employeeNumber = c.salesRepEmployeeNumber
where year(o.orderDate) in (2004, 2005)
  and e.lastName like 'patterson%'
group by year(o.orderDate), month(o.orderDate)
order by anio, mes;

-- viaje a la oficina
select distinct o.officeCode, o.city
from offices o
where o.officeCode in (
  select e.officeCode
  from employees e
  where e.employeeNumber in (
    select c.salesRepEmployeeNumber
    from customers c
    where c.state is null or c.state = ''
  )
);