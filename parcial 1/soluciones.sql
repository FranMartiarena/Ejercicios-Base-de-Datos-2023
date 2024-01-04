use olympics;

--Crear un campo nuevo `total_medals` en la tabla `person` que almacena la cantidad de medallas ganadas por cada persona. Por defecto, con valor 0.

ALTER TABLE person ADD total_medals int DEFAULT 0;

--Actualizar la columna  `total_medals` de cada persona con el recuento real de medallas que ganó. Por ejemplo, para Michael Fred Phelps II, luego de la actualización debería tener como valor de `total_medals` igual a 28.

UPDATE person SET total_medals =
     (SELECT count(medal_id) FROM games_competitor
      INNER JOIN competitor_event ON games_competitor.id = competitor_event.competitor_id
      INNER JOIN medal ON medal_id = medal.id
      WHERE medal_name != 'NA' AND person_id = person.id
      GROUP BY person_id);

--Devolver todos los medallistas olímpicos de Argentina, es decir, los que hayan logrado alguna medalla de oro, plata, o bronce, enumerando la cantidad por tipo de medalla.  Por ejemplo, la query debería retornar casos como el siguiente: (Juan Martín del Potro, Bronze, 1), (Juan Martín del Potro, Silver,1)

SELECT full_name, medal_name, count(medal_id) FROM person
INNER JOIN games_competitor ON person.id = games_competitor.person_id 
INNER JOIN competitor_event ON competitor_id = games_competitor.id 
INNER JOIN medal ON medal_id = medal.id 
WHERE medal_name != 'NA' 
AND person.id IN (SELECT person_id FROM person_region 
                   INNER JOIN noc_region ON person_region.region_id = noc_region.id 
                   WHERE noc='ARG') 
GROUP BY person.id, medal_name
ORDER BY full_name desc;   

--Listar el total de medallas ganadas por los deportistas argentinos en cada deporte.

SELECT sport_name, count(medal_id) FROM person 
INNER JOIN games_competitor ON person.id = games_competitor.person_id 
INNER JOIN competitor_event ON competitor_id = games_competitor.id 
INNER JOIN medal ON medal_id = medal.id 
INNER JOIN event ON event_id = event.id 
INNER JOIN sport on sport_id = sport.id 
WHERE medal_name != 'NA' 
AND person.id IN (SELECT person_id FROM person_region 
                  INNER JOIN noc_region ON person_region.region_id = noc_region.id 
                  WHERE noc='ARG')
GROUP BY sport.id;

--Listar el número total de medallas de oro, plata y bronce ganadas por cada país (país representado en la tabla `noc_region`), agruparlas los resultados por pais.

SELECT region_name, count(medal_id) FROM person 
INNER JOIN games_competitor ON person.id = games_competitor.person_id 
INNER JOIN competitor_event ON competitor_id = games_competitor.id 
INNER JOIN medal ON medal_id = medal.id 
INNER JOIN person_region on person_region.person_id = person.id 
INNER JOIN noc_region on noc_region.id = region_id 
WHERE medal_name != 'NA' 
GROUP BY noc_region.id;

--Listar el país con más y menos medallas ganadas en la historia de las olimpiadas. 

(SELECT region_name, count(medal_id) AS cantidad FROM person 
INNER JOIN games_competitor ON person.id = games_competitor.person_id 
INNER JOIN competitor_event ON competitor_id = games_competitor.id 
INNER JOIN medal ON medal_id = medal.id 
INNER JOIN person_region ON person_region.person_id = person.id 
INNER JOIN noc_region ON noc_region.id = region_id 
WHERE medal_name != 'NA' 
GROUP BY noc_region.id 
ORDER BY cantidad desc LIMIT 1)
UNION
(SELECT region_name, count(medal_id) AS cantidad FROM person 
INNER JOIN games_competitor ON person.id = games_competitor.person_id 
INNER JOIN competitor_event ON competitor_id = games_competitor.id 
INNER JOIN medal ON medal_id = medal.id 
INNER JOIN person_region ON person_region.person_id = person.id 
INNER JOIN noc_region ON noc_region.id = region_id 
WHERE medal_name != 'NA' 
GROUP BY noc_region.id 
ORDER BY cantidad ASC LIMIT 1)

--Crear dos triggers:
--Un trigger llamado `increase_number_of_medals` que incrementará en 1 el valor del campo `total_medals` de la tabla `person`.
--Un trigger llamado `decrease_number_of_medals` que decrementará en 1 el valor del campo `totals_medals` de la tabla `person`.
--El primer trigger se ejecutará luego de un `INSERT` en la tabla `competitor_event` y deberá actualizar el valor en la tabla `person` de acuerdo al valor introducido (i.e. sólo aumentará en 1 el valor de `total_medals` para la persona que ganó una medalla). Análogamente, el segundo trigger se ejecutará luego de un `DELETE` en la tabla `competitor_event` y sólo actualizará el valor en la persona correspondiente

--a

DELIMITER $$
CREATE TRIGGER increase_number_of_medals
AFTER INSERT ON competitor_event
FOR EACH ROW
BEGIN
    UPDATE person SET total_medals = (total_medals + 1) 
    WHERE person.id IN (SELECT person_id FROM games_competitor 
                        inner join competitor_event ON  competitor_event.competitor_id = games_competitor.id 
                        inner join medal ON  medal_id = medal.id 
                        where competitor_id = new.competitor_id and medal_name != 'NA');
END$$
DELIMITER

--b 

DELIMITER $$
CREATE TRIGGER decrease_number_of_medals
AFTER DELETE ON competitor_event
FOR EACH ROW
BEGIN
    update person set total_medals = (total_medals - 1) 
    where person.id in (select person_id from games_competitor 
                        where games_competitor.id = old.competitor_id);
END$$
DELIMITER

--Crear un procedimiento  `add_new_medalists` que tomará un `event_id`, y tres ids de atletas `g_id`, `s_id`, y `b_id` donde se deberá insertar tres registros en la tabla `competitor_event`  asignando a `g_id` la medalla de oro, a `s_id` la medalla de plata, y a `b_id` la medalla de bronce.

DELIMITER $$
CREATE PROCEDURE add_new_medalists(in event_id int, in g_id int, in s_id int, in b_id int)
BEGIN
	INSERT INTO competitor_event values (event_id, g_id, 1);
    INSERT INTO competitor_event values (event_id, s_id, 2);
    INSERT INTO competitor_event values (event_id, b_id, 3);
END$$
DELIMITER

--Crear el rol `organizer` y asignarle permisos de eliminación sobre la tabla `games` y permiso de actualización sobre la columna `games_name`  de la tabla `games` .

create role organizer;
grant delete ON olympics.games to organizer;
grant update (games_name) ON olympics.games  to organizer;





