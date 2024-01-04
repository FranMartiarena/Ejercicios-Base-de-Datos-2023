use world;

select city.Name, country.Name, country.Region, country.GovernmentForm, city.Population from city, country where (city.CountryCode = country.Code) order by city.Population desc limit 10;

select country.Name as country, city.Name as capital, country.population from country left join city on country.Capital = city.ID or country.Capital = NULL order by country.population asc limit 10;

select countrylanguage.Language, country.Name as pais, country.Continent as continente from countrylanguage, country where countrylanguage.CountryCode = country.Code and countrylanguage.IsOfficial = 'T';

select country.Name as pais, city.Name as ciudad, country.SurfaceArea as superficie from country left join city on country.Capital = city.ID or country.Capital = NULL order by country.SurfaceArea desc limit 20;

select city.Name as ciudad, countrylanguage.Language, countrylanguage.Percentage from city inner join countrylanguage on city.CountryCode = countrylanguage.CountryCode where countrylanguage.IsOfficial = 'T' order by city.Population;

(select name, population from country where population >= 100 order by population desc limit 10) union (select name, population from country where population >= 100 order by population asc limit 10);

(select name from country inner join countrylanguage on country.Code = countrylanguage.CountryCode where countrylanguage.IsOfficial ='T' and countrylanguage.Language = 'French') intersect (select name from country inner join countrylanguage on country.Code = countrylanguage.CountryCode where countrylanguage.IsOfficial ='T' and countrylanguage.Language = 'English');

(select name from country inner join countrylanguage on country.Code = countrylanguage.CountryCode where countrylanguage.Language = 'English') except (select name from country inner join countrylanguage on country.Code = countrylanguage.CountryCode where countrylanguage.Language = 'Spanish');

SELECT city.Name, country.Name FROM city left JOIN country ON city.CountryCode = country.Code AND country.Name = 'Argentina';
SELECT city.Name, country.Name FROM city left JOIN country ON city.CountryCode = country.Code where country.Name = 'Argentina';
#Parte 2
#Si, devuelven lo mismo. Si ponemos and estamos aplicando el join en ambas condiciones. por otro lado con where estamos primero haciendo el join y despues filtrando con el where.
#Si hacemos left join, la primera (and) devuelve todas las ciudades(tabla de la izq) y aquellos paises de la condicion. En cambio con un where primero trae todas las ciudades y sus paises, y despues filtra por los que tienen pais argentina.
