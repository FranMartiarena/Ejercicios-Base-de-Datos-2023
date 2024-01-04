use world;

-- Listar el nombre de la ciudad y el nombre del país de todas las ciudades que pertenezcan a países
-- con una población menor a 10000 habitantes.
select ci.Name, co.Name from city as ci inner join (select * from country where Population < 10000) as co on ci.CountryCode = co.Code;

-- Listar todas aquellas ciudades cuya población sea mayor que la población promedio entre todas las ciudades.
with Promedio as (select avg(Population) as p from city) select Name, Population, p from city, Promedio where Population > Promedio.p;

-- Listar todas aquellas ciudades no asiáticas cuya población sea igual o mayor a la población total
-- de algún país de Asia.
with Asian as (select * from country where Continent = 'Asia') select Name from city where population >= any(select Population from Asian) and CountryCode not in (select code from Asian);

-- Listar aquellos países junto a sus idiomas no oficiales, que superen en porcentaje de hablantes
-- a cada uno de los idiomas oficiales del país.
-- EN la query de abajo use all ya que si la subquery es vacia(no hay lenguajes oficiales) entonces la comparacion devuelve True(?.
-- Si lo hiciera con Max, se sabe que max devuelve NULL si la tabla es vacia, por lo tanto la comparacion devuelve false.
select Name, Language, Percentage from country as co, countrylanguage as cl where co.Code = cl.countryCode and IsOfficial='F' and Percentage>all(select Percentage from countrylanguage as cl2 where co.Code = cl2.countryCode and cl2.IsOfficial='T');

-- Listar (sin duplicados) aquellas regiones que tengan países con una superficie menor a 1000 km2 
-- y exista (en el país) al menos una ciudad con más de 100000 habitantes. (Hint: Esto puede resolverse con o sin una subquery, intenten encontrar ambas respuestas).

select distinct Region from country where SurfaceArea<1000 and Code in (select CountryCode from city where Population>100000);

-- Listar el nombre de cada país con la cantidad de habitantes de su ciudad más poblada. 
select Name, (select Max(Population) from city where CountryCode = Code) as ciudadMasPoblada from country;
select Max(Population), CountryCode from city group by CountryCode; 
-- Listar aquellos países y sus lenguajes no oficiales cuyo porcentaje de hablantes sea mayor al promedio
-- de hablantes de los lenguajes oficiales
select Name, Language from country as co, countrylanguage as cl where IsOfficial='F' and co.Code = cl.CountryCode and Percentage > (select avg(cl2.Percentage) from countrylanguage as cl2 where IsOfficial='T');

-- Listar la cantidad de habitantes por continente ordenado en forma descendente.
select Continent, sum(Population) as population from country group by Continent order by population desc; 

-- Listar el promedio de esperanza de vida (LifeExpectancy) por continente con una esperanza
-- de vida entre 40 y 70 años.
select Continent, avg(LifeExpectancy) as esp from country group by Continent having esp between 40 and 70;

-- Listar la cantidad máxima, mínima, promedio y suma de habitantes por continente.
select Continent, max(Population), min(Population), avg(Population), sum(Population) from country group by Continent;

/*Si en la consulta 6 se quisiera devolver, además de las columnas ya solicitadas, el nombre de la ciudad más poblada. ¿Podría lograrse con agrupaciones? ¿y con una subquery escalar?

*/






