-- 1.
CREATE TABLE logtabla (
  muvelet VARCHAR2(20),
  datum   DATE,
  szint   VARCHAR2(20),
  azon    VARCHAR2(50)
);

-- 2.
CREATE TABLE auto AS
  (SELECT
     a.azon,
     a.rendszam,
     a.szin,
     a.elso_vasarlasi_ar,
     at.marka
   FROM szerelo.sz_auto a
     JOIN szerelo.sz_autotipus at
       ON a.tipus_azon = at.azon);

ALTER TABLE AUTO
  ADD PRIMARY KEY (AZON);

-- 3.
CREATE OR REPLACE TRIGGER tr_auto_dml
  AFTER INSERT OR UPDATE OR DELETE
  ON
    AUTO
  DECLARE
    action CHAR(6);
  BEGIN
    CASE
      WHEN INSERTING
      THEN
        action := 'INSERT';
      WHEN UPDATING
      THEN
        action := 'UPDATE';
      WHEN DELETING
      THEN
        action := 'DELETE';
    END CASE;
    INSERT INTO logtabla (muvelet, datum, szint, azon) VALUES
      (action, sysdate, 'utasitas', NULL);
  END;

CREATE OR REPLACE TRIGGER tr_auto_dml_row
  AFTER INSERT OR UPDATE OR DELETE
  ON
    AUTO
  FOR EACH ROW
  DECLARE
    action CHAR(6);
  BEGIN
    CASE
      WHEN INSERTING
      THEN
        action := 'INSERT';
      WHEN UPDATING
      THEN
        action := 'UPDATE';
      WHEN DELETING
      THEN
        action := 'DELETE';
    END CASE;
    INSERT INTO logtabla (muvelet, datum, szint, azon) VALUES
      (action, sysdate, 'sor', :NEW.azon);
  END;

-- 4.
CREATE OR REPLACE PACKAGE car_manager AS
  CURSOR c1 IS
    SELECT
      a.szin,
      at.marka,
      count(*)
    from szerelo.sz_auto a
      join szerelo.sz_autotipus at
        on a.tipus_azon = at.azon
    GROUP BY a.szin, at.marka
    ORDER BY at.marka, a.szin;

  PROCEDURE feltolt_kollekcio(p_marka IN VARCHAR2);
  PROCEDURE torol_kollekcio(p_szin IN VARCHAR2);
  PROCEDURE listaz;
  PROCEDURE tabla_torol;
  PROCEDURE ar_novel(p_szazalek IN NUMBER);

END car_manager;

CREATE OR REPLACE PACKAGE BODY car_manager AS
  TYPE auto_sorok IS TABLE OF AUTO%ROWTYPE;
  v_autok auto_sorok;

  PROCEDURE feltolt_kollekcio(p_marka IN VARCHAR2) IS
    BEGIN
      SELECT
        a.azon,
        a.rendszam,
        a.szin,
        a.elso_vasarlasi_ar,
        at.marka
      BULK COLLECT INTO v_autok
      from szerelo.sz_auto a
        join szerelo.sz_autotipus at
          on a.tipus_azon = at.azon
      WHERE at.marka = p_marka;
    END;

  PROCEDURE torol_kollekcio(p_szin IN VARCHAR2) IS
    i NUMBER;
    BEGIN
      i := v_autok.FIRST;
      WHILE i IS NOT NULL
      LOOP
        IF v_autok(i).szin = p_szin
        THEN
          v_autok.DELETE(i);
        END IF;
        i := v_autok.NEXT(i);
      END LOOP;
    END;

  PROCEDURE listaz IS
    i NUMBER;
    BEGIN
      i := v_autok.FIRST;
      WHILE i IS NOT NULL
      LOOP
        DOPL(v_autok(i).azon || ' ' || v_autok(i).rendszam || ' ' || v_autok(i).szin || ' ' || v_autok(i).marka);
        i := v_autok.NEXT(i);
      END LOOP;
    END;

  PROCEDURE tabla_torol IS
    i NUMBER;
    BEGIN
      i := v_autok.FIRST;
      WHILE i IS NOT NULL
      LOOP
        DELETE FROM AUTO
        WHERE azon = v_autok(i).azon;
        i := v_autok.NEXT(i);
      END LOOP;
    END;

  PROCEDURE ar_novel(p_szazalek IN NUMBER) IS
    i NUMBER;
    BEGIN
      i := v_autok.FIRST;
      WHILE i IS NOT NULL
      LOOP
        UPDATE AUTO
        SET ELSO_VASARLASI_AR = ELSO_VASARLASI_AR * (1 + p_szazalek / 100);
      WHERE azon = v_autok( i ).azon;
        i := v_autok.NEXT(i);
      END LOOP;
    END;
END;

-- 5.
DECLARE
  PROCEDURE kurzor_kiir IS
    TYPE car_count IS RECORD (szin VARCHAR2(20), marka VARCHAR(20), darab NUMBER(10));
    v_car_count car_count;
    BEGIN
      OPEN car_manager.c1;

      LOOP
        FETCH car_manager.c1 INTO v_car_count;
        EXIT WHEN car_manager.c1%NOTFOUND;
        DOPL(v_car_count.szin || ' ' || v_car_count.marka || ' ' || v_car_count.darab);
      END LOOP;
      CLOSE car_manager.c1;
    END;
BEGIN
  car_manager.feltolt_kollekcio('Fiat');
  car_manager.feltolt_kollekcio('Opel');

  car_manager.torol_kollekcio('fehér');
  car_manager.torol_kollekcio('szürke');

  car_manager.ar_novel(10);
  car_manager.listaz();

  kurzor_kiir();
  car_manager.tabla_torol();
  kurzor_kiir();
END;

BEGIN
  car_manager.feltolt_kollekcio('Audi');
  car_manager.torol_kollekcio('fekete');
  car_manager.ar_novel(10);
  car_manager.listaz();
END;