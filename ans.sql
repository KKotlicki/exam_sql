CREATE EXTENSION postgis;
SELECT postgis_full_version();

-- Zadanie 1
CREATE TYPE SL_KlasaCieku AS ENUM ('rzeka', 'kanal', 'struga');

CREATE TYPE SL_KlasaZbiornika AS ENUM ('jezioro', 'staw', 'morze');

CREATE TABLE Rzeka (
    rzeka_id serial PRIMARY KEY,
    nazwa varchar(255),
    kod_MPHP varchar(255)
);

CREATE TABLE SegmentCieku (
    segment_cieku_id serial PRIMARY KEY,
    klasa_cieku SL_KlasaCieku,
    szerokosc integer,
    dlugosc integer
);

ALTER TABLE SegmentCieku ADD COLUMN geom geometry(LINESTRING, 2180);
ALTER TABLE SegmentCieku ADD CONSTRAINT SegmentCieku_geom_check CHECK (ST_IsValid(geom));

CREATE TABLE Rzeka_SegmentCieku (
    rzeka_id integer REFERENCES Rzeka(rzeka_id),
    segment_cieku_id integer REFERENCES SegmentCieku(segment_cieku_id)
);

CREATE TABLE ZbiornikWodny (
    zbiornik_wodny_id serial PRIMARY KEY,
    nazwa varchar(255),
    klasa_zbiornika SL_KlasaZbiornika,
    powierzchnia integer
);

ALTER TABLE ZbiornikWodny ADD COLUMN geom geometry(POLYGON, 2180);
ALTER TABLE ZbiornikWodny ADD CONSTRAINT ZbiornikWodny_geom_check CHECK (ST_IsValid(geom));

CREATE TABLE ZbiornikWodny_SegmentCieku (
    zbiornik_wodny_id integer REFERENCES ZbiornikWodny(zbiornik_wodny_id),
    segment_cieku_id integer REFERENCES SegmentCieku(segment_cieku_id)
);

CREATE TABLE ZarzadGospodarkiWodnej (
    zarzad_gospodarki_wodnej_id serial PRIMARY KEY,
    nazwa varchar(255),
    powierzchnia integer
);

ALTER TABLE ZarzadGospodarkiWodnej ADD COLUMN geom geometry(POLYGON, 2180);
ALTER TABLE ZarzadGospodarkiWodnej ADD CONSTRAINT ZarzadGospodarkiWodnej_geom_check CHECK (ST_IsValid(geom));

ALTER TABLE ZbiornikWodny ADD COLUMN zarzad_gospodarki_wodnej_id integer REFERENCES ZarzadGospodarkiWodnej(zarzad_gospodarki_wodnej_id);
ALTER TABLE SegmentCieku ADD COLUMN zarzad_gospodarki_wodnej_id integer REFERENCES ZarzadGospodarkiWodnej(zarzad_gospodarki_wodnej_id);

-- Zadanie 2
-- Napisz w języku SQL zapytanie, które wyświetli liczbę cieków znajdujących się w strefie 100 m od zbiornika o nazwie "Z1".
SELECT COUNT(*) FROM SegmentCieku WHERE ST_DWithin(geom, (SELECT geom FROM ZbiornikWodny WHERE nazwa = 'Z1'), 100);

-- Zadanie 3
-- Napisz w języku SQL zapytanie, które wyświetli nazwy zbiorników znajdujących się na terenie największego Zarządu Gospodarki Wodnej. Skorzystaj z funkcji ST_Area.
SELECT nazwa FROM ZbiornikWodny WHERE zarzad_gospodarki_wodnej_id = (SELECT zarzad_gospodarki_wodnej_id FROM ZarzadGospodarkiWodnej ORDER BY ST_Area(geom) DESC LIMIT 1);

-- Zadanie 4
-- Napisz w języku SQL zapytanie, które wyświetli listę o postaci: nazwa morza, liczba segmentów cieków wpływających do tego morza.
SELECT nazwa, COUNT(*) FROM ZbiornikWodny JOIN ZbiornikWodny_SegmentCieku ON ZbiornikWodny.zbiornik_wodny_id = ZbiornikWodny_SegmentCieku.zbiornik_wodny_id JOIN SegmentCieku ON ZbiornikWodny_SegmentCieku.segment_cieku_id = SegmentCieku.segment_cieku_id WHERE klasa_zbiornika = 'morze' GROUP BY nazwa;
