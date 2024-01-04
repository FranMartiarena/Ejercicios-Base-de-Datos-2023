use sakila;

--Cree una tabla de `directors` con las columnas: Nombre, Apellido, Número de Películas.

create table if not exists director (
    Nombre varchar(255),
    Apellido varchar(255),
    NumPeliculas int,
    id int UNSIGNED NOT NULL AUTO_INCREMENT,
    primary key (id)    
);

--El top 5 de actrices y actores de la tabla `actors` que tienen la mayor experiencia (i.e. el mayor número de películas filmadas) son también directores de las películas en las que participaron. Basados en esta información, inserten, utilizando una subquery los valores correspondientes en la tabla `directors`.

insert into director(Nombre, Apellido, NumPeliculas) select first_name, last_name, count(film_id) as amount from actor inner join film_actor on actor.actor_id = film_actor.actor_id group by actor.actor_id order by amount desc limit 5;

--Agregue una columna `premium_customer` que tendrá un valor 'T' o 'F' de acuerdo a si el cliente es "premium" o no. Por defecto ningún cliente será premium.

alter table customer add premium_customer char default 'F';

--Modifique la tabla customer. Marque con 'T' en la columna `premium_customer` de los 10 clientes con mayor dinero gastado en la plataforma.

update customer inner join (select customer_id from payment group by customer_id order by sum(amount) desc limit 10) as pcus on customer.customer_id = pcus.customer_id set premium_customer = 'T';

--Listar, ordenados por cantidad de películas (de mayor a menor), los distintos ratings de las películas existentes (Hint: rating se refiere en este caso a la clasificación según edad: G, PG, R, etc).

select rating from film group by rating order by count(rating) desc;

--¿Cuáles fueron la primera y última fecha donde hubo pagos?

(select payment_date from payment order by payment_date desc limit 1) union (select payment_date from payment order by payment_date asc limit 1);

--Calcule, por cada mes, el promedio de pagos (Hint: vea la manera de extraer el nombre del mes de una fecha).

select monthname(payment_date) as mes, avg(amount) from payment group by mes; 

--Listar los 10 distritos que tuvieron mayor cantidad de alquileres (con la cantidad total de alquileres).

select district, count(rental_id) as rentas from rental inner join ( select customer_id, district from  customer inner join address on customer.address_id = address.address_id) as cus on rental.customer_id = cus.customer_id group by district order by rentas desc limit 10; 

--Modifique la table `inventory_id` agregando una columna `stock` que sea un número entero y representa la cantidad de copias de una misma película que tiene determinada tienda. El número por defecto debería ser 5 copias.

alter table inventory add stock int default 5;

--Cree un trigger `update_stock` que, cada vez que se agregue un nuevo registro a la tabla rental, haga un update en la tabla `inventory` restando una copia al stock de la película rentada (Hint: revisar que el rental no tiene información directa sobre la tienda, sino sobre el cliente, que está asociado a una tienda en particular).

create trigger update_stock after insert on rental for each row update inventory set inventory.stock = inventory.stock-1 where inventory.inventory_id = rental.inventory_id;

--Cree una tabla `fines` que tenga dos campos: `rental_id` y `amount`. El primero es una clave foránea a la tabla rental y el segundo es un valor numérico con dos decimales.

create table if not exists fines (
    rental_id int unsigned not null,
    amount int,
    foreign key (rental_id) references rental(rental_id)
);

--Cree un procedimiento `check_date_and_fine` que revise la tabla `rental` y cree un registro en la tabla `fines` por cada `rental` cuya devolución (return_date) haya tardado más de 3 días (comparación con rental_date). El valor de la multa será el número de días de retraso multiplicado por 1.5.

create procedure check_date_and_fine()
    begin
        insert into fine select rental_id, datediff(return_date, rental_date)*1.5 from rental where datediff(return_date, rental_date) > 3;
    end

--Crear un rol `employee` que tenga acceso de inserción, eliminación y actualización a la tabla `rental`.
create role employee;
grant insert, delete, update on rental to employee;

--Revocar el acceso de eliminación a `employee` y crear un rol `administrator` que tenga todos los privilegios sobre la BD `sakila`.
revoke delete on rental from employee;
create role administrator;
grant all privileges on sakila to administrator;


