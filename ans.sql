-- Using postgis
-- Using postgreSql
-- Using pgAdmin
-- on user: s310958
-- on database: s310958
-- on host: db.pwr.edu.pl
-- on port: 5432

-- load postgis
CREATE EXTENSION postgis;
SELECT postgis_full_version();

-- generate enum SL_KlasaCieku with fields: 'rzeka', 'kanal', 'struga'
CREATE TYPE SL_KlasaCieku AS ENUM ('rzeka', 'kanal', 'struga');

-- generate enum SL_KlasaZbiornika with fields: 'jezioro', 'staw', 'morze'
CREATE TYPE SL_KlasaZbiornika AS ENUM ('jezioro', 'staw', 'morze');

-- generate table Rzeka with fields [rzeka_id integer, nazwa varchar(255), kod_MPHP varchar(255)] and feature type SegmentCieku with fields: [segment_cieku_id integer, geom GM_LineString, klasa_cieku SL_KlasaCieku, szerokosc integer, dlugosc integer] and relation Rzeka 0..* - 1..* SegmentCieku using foreign keys
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
ALTER TABLE SegmentCieku ADD COLUMN rzeka_id integer;
ALTER TABLE SegmentCieku ADD CONSTRAINT SegmentCieku_rzeka_id_fkey FOREIGN KEY (rzeka_id) REFERENCES Rzeka(rzeka_id);


-- generate feature type ZbiornikWodny with fields [zbiornik_wodny_id integer, geom GM_Polygon, nazwa varchar(255), klasa_zbiornika SL_KlasaZbiornika, powierzchnia integer] and relation ZbiornikWodny 0..1 wpływa_do 0..* SegmentCieku and relation SegmentCieku 0..* wypływa_z 0..1 ZbiornikWodny using foreign keys
CREATE TABLE ZbiornikWodny (
    zbiornik_wodny_id serial PRIMARY KEY,
    nazwa varchar(255),
    klasa_zbiornika SL_KlasaZbiornika,
    powierzchnia integer
);

ALTER TABLE ZbiornikWodny ADD COLUMN geom geometry(POLYGON, 2180);
ALTER TABLE ZbiornikWodny ADD CONSTRAINT ZbiornikWodny_geom_check CHECK (ST_IsValid(geom));
ALTER TABLE ZbiornikWodny ADD COLUMN segment_cieku_id integer;
ALTER TABLE ZbiornikWodny ADD CONSTRAINT ZbiornikWodny_segment_cieku_id_fkey FOREIGN KEY (segment_cieku_id) REFERENCES SegmentCieku(segment_cieku_id);

-- generate feature type ZarzadGospodarkiWodnej with fields [zarzad_gospodarki_wodnej_id integer, geom GM_Polygon, nazwa varchar(255), powierzchnia integer] and relation ZarzadGospodarkiWodnej 1 - 1..* ZbiornikWodny and relation ZarzadGospodarkiWodnej 1 - 1..* SegmentCieku without junction table only using foreign keys
CREATE TABLE ZarzadGospodarkiWodnej (
    zarzad_gospodarki_wodnej_id serial PRIMARY KEY,
    nazwa varchar(255),
    powierzchnia integer
);

ALTER TABLE ZarzadGospodarkiWodnej ADD COLUMN geom geometry(POLYGON, 2180);
ALTER TABLE ZarzadGospodarkiWodnej ADD CONSTRAINT ZarzadGospodarkiWodnej_geom_check CHECK (ST_IsValid(geom));
ALTER TABLE ZarzadGospodarkiWodnej ADD COLUMN segment_cieku_id integer;
ALTER TABLE ZarzadGospodarkiWodnej ADD CONSTRAINT ZarzadGospodarkiWodnej_segment_cieku_id_fkey FOREIGN KEY (segment_cieku_id) REFERENCES SegmentCieku(segment_cieku_id);
ALTER TABLE ZarzadGospodarkiWodnej ADD COLUMN zbiornik_wodny_id integer;
ALTER TABLE ZarzadGospodarkiWodnej ADD CONSTRAINT ZarzadGospodarkiWodnej_zbiornik_wodny_id_fkey FOREIGN KEY (zbiornik_wodny_id) REFERENCES ZbiornikWodny(zbiornik_wodny_id);

