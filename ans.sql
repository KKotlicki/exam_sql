-- Using postgis

-- generate enum sl_rodzaj with fields: 'tramwajowy', 'multimodalny', 'autobusowy'
CREATE TYPE sl_rodzaj AS ENUM ('tramwajowy', 'multimodalny', 'autobusowy');

-- generate enum sl_kategoria with fields: 'zwykla', 'przyspieszona', 'ekspresowa'
CREATE TYPE sl_kategoria AS ENUM ('zwykla', 'przyspieszona', 'ekspresowa');

-- generate table ulica with fields [ulica_id integer, geom GM_LineString, nazwa varchar(255), przepustowosc integer] and table przystanek with fields: [przystanek_id integer, geom GM_Point, nazwa varchar(255), rodzaj sl_rodzaj] and relation ulica on update cascade 1 - 0..* przystanek
CREATE TABLE ulica (
    ulica_id serial PRIMARY KEY,
    geom GM_LineString,
    nazwa varchar(255),
    przepustowosc integer
);

CREATE TABLE przystanek (
    przystanek_id serial PRIMARY KEY,
    geom GM_Point,
    nazwa varchar(255),
    rodzaj sl_rodzaj
);

ALTER TABLE ulica ADD CONSTRAINT ulica_geom_check CHECK (ST_IsValid(geom));
ALTER TABLE przystanek ADD CONSTRAINT przystanek_geom_check CHECK (ST_IsValid(geom));

CREATE TABLE ulica_przystanek (
    ulica_id integer REFERENCES ulica (ulica_id) ON UPDATE CASCADE,
    przystanek_id integer REFERENCES przystanek (przystanek_id) ON UPDATE CASCADE
);

-- generate table linia with fields [linia_id integer, geom GM_LineString, nazwa varchar(255), kategoria sl_kategoria, dlugosc integer] and relation linia 0..* - 2..* przystanek
CREATE TABLE linia (
    linia_id serial PRIMARY KEY,
    geom GM_LineString,
    nazwa varchar(255),
    kategoria sl_kategoria,
    dlugosc integer
);

ALTER TABLE linia ADD CONSTRAINT linia_geom_check CHECK (ST_IsValid(geom));

CREATE TABLE linia_przystanek (
    linia_id integer REFERENCES linia (linia_id) ON UPDATE CASCADE,
    przystanek_id integer REFERENCES przystanek (przystanek_id) ON UPDATE CASCADE
);

-- generate table zespol with fields [zespol_id integer, nazwa varchar(255), liczba_pracownikow integer] and relation zespol 1 - 0..* linia
CREATE TABLE zespol (
    zespol_id serial PRIMARY KEY,
    nazwa varchar(255),
    liczba_pracownikow integer
);

CREATE TABLE zespol_linia (
    zespol_id integer REFERENCES zespol (zespol_id) ON UPDATE CASCADE,
    linia_id integer REFERENCES linia (linia_id) ON UPDATE CASCADE
);

-- Napisz w języku SQL zapytanie, które wyświetli liczbę przystanków leżących na trasie linii o nazwie „17”
SELECT COUNT(*) FROM linia_przystanek lp
JOIN linia l ON lp.linia_id = l.linia_id
WHERE l.nazwa = '17';

-- Napisz w języku SQL zapytanie, które pokaże nazwy ulic znajdujących się w odległości do 100 m od przystanków obsługujących najwięcej linii.
SELECT u.nazwa FROM ulica u
JOIN ulica_przystanek up ON u.ulica_id = up.ulica_id
JOIN przystanek p ON up.przystanek_id = p.przystanek_id
JOIN linia_przystanek lp ON p.przystanek_id = lp.przystanek_id
GROUP BY u.nazwa
HAVING COUNT(lp.linia_id) = (SELECT MAX(count) FROM (SELECT COUNT(lp.linia_id) AS count FROM ulica_przystanek up
JOIN przystanek p ON up.przystanek_id = p.przystanek_id
JOIN linia_przystanek lp ON p.przystanek_id = lp.przystanek_id
GROUP BY up.przystanek_id) AS max_count);



