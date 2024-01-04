use world;

#ej2
CREATE TABLE IF NOT EXISTS country( 
    Code char(3) not null UNIQUE,
    Name varchar(255),
    Continent varchar(255),
    Region varchar(255),
    SurfaceArea float,
    IndepYear int,
    Population int,
    LifeExpectancy float,
    GNP float,
    GNPOld float,
    LocalName varchar(255),
    GovernmentForm varchar(255),    
    HeadOfState varchar(255),
    Capital int,
    Code2 char(2),
    PRIMARY KEY (Code),
);

CREATE TABLE IF NOT EXISTS city ( 
    ID int not null UNIQUE,
    Name varchar(255),
    CountryCode char(3),
    District varchar(255),
    Population int,
    PRIMARY KEY (ID),
    FOREIGN KEY (CountryCode) REFERENCES country(Code)
    
);

CREATE TABLE IF NOT EXISTS countrylanguage(
    CountryCode char(3),
    Language varchar(255),
    IsOfficial char(1),
    Percentage float,
    PRIMARY KEY (CountryCode, Language),
    FOREIGN KEY (CountryCode) REFERENCES country(Code)
);

#ej4

CREATE TABLE IF NOT EXISTS Continent(
    Name varchar(255) not null UNIQUE,
    Area float,
    Mass float,
    MostPopCity int UNIQUE,
    PRIMARY KEY (Name),
    FOREIGN KEY (MostPopCity) REFERENCES city(ID)
);

#ej5

INSERT INTO city VALUES (4080, 'McMurdo Station', 'USA', 'Ross Island', 200);

INSERT INTO Continent VALUES ('Africa', 30370000, 20.4, 608);
INSERT INTO Continent VALUES ('Antarctica', 14000000, 9.2, 4080);
INSERT INTO Continent VALUES ('Asia', 44579000, 29.5, 1024);
INSERT INTO Continent VALUES ('Europe', 10180000, 6.8, 3357);
INSERT INTO Continent VALUES ('North America', 24709000, 16.5, 2515);
INSERT INTO Continent VALUES ('Oceania', 8600000, 5.9, 130);
INSERT INTO Continent VALUES ('South America', 17840000, 12.0, 206);

#ej6

ALTER TABLE country ADD FOREIGN KEY (Continent) REFERENCES Continent(Name);

#consultas
select Name, Region from country order by Name;
select Name, Population from city order by Population desc limit 10;
select Name, Region, SurfaceArea, GovermentForm from country order by SurfaceArea asc limit 10;
select Name from country where IndepYear is NULL;
select Language, Percentage from countrylanguage where IsOfficial = 'T';
#extras
update countrylanguage set percentage = 100.0 where CountryCode='AIA' and Language='English' ;
select * from city where District='Córdoba' and CountryCode = 'ARG';
delete from city where District='Córdoba' and CountryCode != 'ARG';
select * from country where HeadOfState like 'John %';
select * from country where population between 35000000 and 45000000 order by population desc;
select Name, count(Name) from city group by Name, CountryCode, District having count(Name)>1;
#La query de arriba nos devuelve las ciudades que tienen mismo nombre, codigo y distrito, pero diferente poblacion. La unica ciudad redundante es Jinzhou.








