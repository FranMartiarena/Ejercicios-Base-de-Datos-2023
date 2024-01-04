use classicmodels;

--Devuelva la oficina con mayor número de empleados.
select officeCode, count(officeCode) as cant from employees group by officeCode order by cant desc limit 1;

--¿Cuál es el promedio de órdenes hechas por oficina?, 
select avg(cantidad) from (select count(orderNumber) as cantidad from orders inner join customers on orders.customerNumber = customers.customerNumber inner join employees on customers.salesRepEmployeeNumber = employees.employeeNumber group by officeCode) as ordenes;

--¿Qué oficina vendió la mayor cantidad de productos?
select officeCode, max(cantidad) from (select officeCode, count(orderNumber) as cantidad from orders inner join customers on orders.customerNumber = customers.customerNumber inner join employees on customers.salesRepEmployeeNumber = employees.employeeNumber group by officeCode) as ordenes;

--Devolver el valor promedio, máximo y mínimo de pagos que se hacen por mes.
select avg(cantidad) from (select monthname(paymentDate) as mes, count(checkNumber) as cantidad from payments group by mes) as cantpagos; 

with cantpagos as (select monthname(paymentDate) as mes, count(checkNumber) as cantidad from payments group by mes) 
select * from cantpagos where cantidad = (select max(cantidad) from cantpagos);

with cantpagos as (select monthname(paymentDate) as mes, count(checkNumber) as cantidad from payments group by mes) 
select * from cantpagos where cantidad = (select min(cantidad) from cantpagos);

--ó
select monthname(paymentDate) as mes, avg(amount) from payments group by mes;
 
with pagos as (select monthname(paymentDate) as mes, sum(amount) as cant from payments group by mes) select * from pagos where cant = (select max(cant) from pagos); 

with pagos as (select monthname(paymentDate) as mes, sum(amount) as cant from payments group by mes) select * from pagos where cant = (select min(cant) from pagos); 

--Crear un procedimiento "Update Credit" en donde se modifique el límite de crédito de un cliente con un valor pasado por parámetro.
DELIMITER $$
create procedure UpdateCredit (in amount int)
begin
    update customer set creditLimit=amount where customerNumber = 1;
end$$
DELIMITER

--Cree una vista "Premium Customers" que devuelva el top 10 de clientes que más dinero han gastado en la plataforma. La vista deberá devolver el nombre del cliente, la ciudad y el total gastado por ese cliente en la plataforma.
create view PremiumCustomer as (select customerName, city, sum(amount) as cant from payments inner join customers on payments.customerNumber = customers.customerNumber group by payments.customerNumber order by cant desc limit 10)

--Cree una función "employee of the month" que tome un mes y un año y devuelve el empleado (nombre y apellido) cuyos clientes hayan efectuado la mayor cantidad de órdenes en ese mes.

DELIMITER $$
create function employee_of_the_month(in month int, in year int)
returns varchar(255)
begin
    declare ans varchar(255);
    set ans = (select concat(firstName, " ", lastname) as nombre from employees inner join customers on salesRepEmployeeNumber = employeeNumber inner join orders on orders.customerNumber = customers.customerNumber where month(orderDate) = month and year(orderDate)=year group by employeeNumber order by count(orderNumber) desc limit 1);
    return ans;
end$$
DELIMITER

--Crear una nueva tabla "Product Refillment". Deberá tener una relación varios a uno con "products" y los campos: `refillmentID`, `productCode`, `orderDate`, `quantity`.

create table if not exists ProductRefillment( refillmentID int not null  auto_increment,
                                              productCode varchar(255),
                                              orderDate date,
	                                          quantity int,
                                              primary key refillmentID,
                                              foreign key productCode references products(productCode));

--Definir un trigger "Restock Product" que esté pendiente de los cambios efectuados en `orderdetails` y cada vez que se agregue una nueva orden revise la cantidad de productos pedidos (`quantityOrdered`) y compare con la cantidad en stock (`quantityInStock`) y si es menor a 10 genere un pedido en la tabla "Product Refillment" por 10 nuevos productos.

DELIMITER $$
CREATE TRIGGER RestockProduct
AFTER INSERT ON orderdetails
FOR EACH ROW
BEGIN
    DECLARE product_stock INT;
    DECLARE product_code VARCHAR(15);

    SELECT productCode, quantityInStock INTO product_code, product_stock
    FROM products
    WHERE productCode = NEW.productCode;

    IF product_stock - (NEW.quantityOrdered) < 10 THEN
        INSERT INTO product_refillment (productCode, orderDate, quantity)
        VALUES (product_code, NOW(), 10);
    END IF;
END$$
DELIMITER  

--Crear un rol "Empleado" en la BD que establezca accesos de lectura a todas las tablas y accesos de creación de vistas.

create role Empleado;
grant select on classicmodels.* to Empleado;
grant create view on classicmodels.* to Empleado;

--Encontrar, para cada cliente de aquellas ciudades que comienzan por 'N', la menor y la mayor diferencia en días entre las fechas de sus pagos. No mostrar el id del cliente, sino su nombre y el de su contacto.

select customerName, contactFirstName, datediff(max(p1.paymentDate), min(p1.paymentDate)) as maxdiff, min(datediff(p2.paymentDate, p1.paymentDate)) as mindiff from customers inner join payments p1 on p1.customerNumber = customers.customerNumber inner join payments p2 on p2.customerNumber = customers.customerNumber where city like 'N%' and p1.paymentDate<p2.paymentDate group by customers.customerNumber;
