SELECT
  f.AZON,
  m.JO,
  m.MEGJEGYZES,
  f.FELADAT
FROM HDBMS18.FELADATAIM f
  LEFT JOIN HDBMS18.MEGOLDASAIM m
    ON f.AZON = m.FELADAT_AZON
WHERE m.JO = '?' OR m.JO = 'n' OR m.JO IS NULL
ORDER BY f.HATARIDO, f.AZON;

-- 801.
CREATE OR REPLACE PROCEDURE cursor_ref_info(c_ref IN OUT SYS_REFCURSOR, szam OUT NUMBER, szoveg OUT VARCHAR2) IS
  TYPE t_typ IS RECORD (szam NUMBER, szoveg VARCHAR2(50));
  val t_typ;
  BEGIN
    IF (NOT c_ref%ISOPEN)
    THEN
      raise_application_error(-20001, 'Nincs nyitva a kurzováltozó');
    ELSE
      --OPEN c_ref;

      FETCH c_ref into val;

      szam := val.szam;
      szoveg := val.szoveg;

      IF (c_ref%NOTFOUND)
      THEN
        raise_application_error(-20002, 'nincs több sor');
      END IF;
    END IF;
  END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(801, 'CREATE OR REPLACE PROCEDURE cursor_ref_info(c_ref IN OUT SYS_REFCURSOR, szam OUT NUMBER, szoveg OUT VARCHAR2) IS
  TYPE t_typ IS RECORD (szam NUMBER, szoveg VARCHAR2(50));
  val t_typ;
  BEGIN
    IF (NOT c_ref%ISOPEN)
    THEN
      raise_application_error(-20001, ''Nincs nyitva a kurzováltozó'');
    ELSE
      --OPEN c_ref;

      FETCH c_ref into val;

      szam := val.szam;
      szoveg := val.szoveg;

      IF (c_ref%NOTFOUND)
      THEN
        raise_application_error(-20002, ''nincs több sor'');
      END IF;
    END IF;
  END;/');
END;

-- 802.
DECLARE
  TYPE t_typ IS RECORD (szam NUMBER, szoveg VARCHAR2(50));
  TYPE c_eros IS REF CURSOR RETURN t_typ;

  v_eros c_eros;
  v_t    t_typ;

    nincs_tobb_sor_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT (nincs_tobb_sor_exception, -20002);

BEGIN
  BEGIN
    OPEN v_eros FOR SELECT
                      DEPARTMENT_ID,
                      DEPARTMENT_NAME
                    from hr.DEPARTMENTS;
    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || ' ' || v_t.szoveg);

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || ' ' || v_t.szoveg);

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || ' ' || v_t.szoveg);
    EXCEPTION WHEN nincs_tobb_sor_exception
    THEN
      DOPL('Nincs tobb sor.');
  END;

  BEGIN
    OPEN v_eros FOR SELECT
                      EMPLOYEE_ID,
                      FIRST_NAME || LAST_NAME
                    FROM hr.EMPLOYEES;

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || ' ' || v_t.szoveg);

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || ' ' || v_t.szoveg);

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || ' ' || v_t.szoveg);
  END;
  EXCEPTION WHEN nincs_tobb_sor_exception
  THEN
    DOPL('Nincs tobb sor.');

END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(802, 'DECLARE
  TYPE t_typ IS RECORD (szam NUMBER, szoveg VARCHAR2(50));
  TYPE c_eros IS REF CURSOR RETURN t_typ;

  v_eros c_eros;
  v_t    t_typ;

  nincs_tobb_sor_exception EXCEPTION;
  PRAGMA EXCEPTION_INIT(nincs_tobb_sor_exception, -20002);

BEGIN
  BEGIN
    OPEN v_eros FOR SELECT
                      DEPARTMENT_ID,
                      DEPARTMENT_NAME
                    from hr.DEPARTMENTS;
    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || '' '' || v_t.szoveg);

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || '' '' || v_t.szoveg);

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || '' '' || v_t.szoveg);
    EXCEPTION WHEN nincs_tobb_sor_exception
    THEN
      DOPL(''Nincs tobb sor.'');
  END;

  BEGIN
    OPEN v_eros FOR SELECT
                      EMPLOYEE_ID,
                      FIRST_NAME || LAST_NAME
                    FROM hr.EMPLOYEES;

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || '' '' || v_t.szoveg);

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || '' '' || v_t.szoveg);

    cursor_ref_info(v_eros, v_t.szam, v_t.szoveg);
    DOPL(v_t.szam || '' '' || v_t.szoveg);
  END;
  EXCEPTION WHEN nincs_tobb_sor_exception
  THEN
    DOPL(''Nincs tobb sor.'');

END;/');
END;

-- 803.
CREATE TABLE gyumolcsok (
  nev   VARCHAR2(30),
  darab NUMBER
);

CREATE TABLE GYUMOLCSOK_NAPLO (
  tabla_neve  VARCHAR2(50),
  user_neve   VARCHAR2(50),
  idopont     DATE,
  muvelet     VARCHAR2(6),
  sorok_szama NUMBER
);

CREATE OR REPLACE TRIGGER tr_gyumolcs
  AFTER INSERT OR UPDATE OR DELETE
  ON GYUMOLCSOK
  DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    action      VARCHAR2(6);
    num_of_rows NUMBER;
  BEGIN
    CASE
      WHEN INSERTING
      THEN
        action := 'INSERT';
      WHEN DELETING
      THEN
        action := 'DELETE';
      WHEN UPDATING
      THEN
        action := 'UPDATE';
    END CASE;

    num_of_rows := SQL%ROWCOUNT;

    INSERT INTO GYUMOLCSOK_NAPLO (tabla_neve, user_neve, idopont, muvelet, sorok_szama)
    VALUES
      ('GYUMOLCSOK', user, sysdate, action, num_of_rows);
    COMMIT;
  END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(803, 'CREATE TABLE gyumolcsok (
  nev   VARCHAR2(30),
  darab NUMBER
);
/

CREATE TABLE GYUMOLCSOK_NAPLO (
  tabla_neve  VARCHAR2(50),
  user_neve   VARCHAR2(50),
  idopont     DATE,
  muvelet     VARCHAR2(6),
  sorok_szama NUMBER
);
/

CREATE OR REPLACE TRIGGER tr_gyumolcs
  AFTER INSERT OR UPDATE OR DELETE
  ON GYUMOLCSOK
  DECLARE
    PRAGMA AUTONOMOUS_TRANSACTION;
    action      VARCHAR2(6);
    num_of_rows NUMBER;
  BEGIN
    CASE
      WHEN INSERTING
      THEN
        action := ''INSERT'';
      WHEN DELETING
      THEN
        action := ''DELETE'';
      WHEN UPDATING
      THEN
        action := ''UPDATE'';
    END CASE;

    num_of_rows := SQL%ROWCOUNT;

    INSERT INTO GYUMOLCSOK_NAPLO (tabla_neve, user_neve, idopont, muvelet, sorok_szama)
    VALUES
      (''GYUMOLCSOK'', user, sysdate, action, num_of_rows);
    COMMIT;
  END;/');
END;

-- 804.
BEGIN
  INSERT INTO gyumolcsok (nev, darab) VALUES ('alma', 2);
  INSERT INTO gyumolcsok (nev, darab) VALUES ('korte', 55);

  UPDATE gyumolcsok
  SET darab = 42
  WHERE nev = 'alma';

  DELETE FROM gyumolcsok
  where nev = 'korte';

  ROLLBACK;

  FOR c IN (SELECT *
            FROM GYUMOLCSOK_NAPLO) LOOP
    DOPL(c.idopont || ' ' || c.muvelet || ' ' || c.sorok_szama || ' ' || c.user_neve);
  END LOOP;
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(804, 'BEGIN
  INSERT INTO gyumolcsok (nev, darab) VALUES (''alma'', 2);
  INSERT INTO gyumolcsok (nev, darab) VALUES (''korte'', 55);

  UPDATE gyumolcsok
  SET darab = 42
  WHERE nev = ''alma'';

  DELETE FROM gyumolcsok
  where nev = ''korte'';

  ROLLBACK;

  FOR c IN (SELECT *
            FROM GYUMOLCSOK_NAPLO) LOOP
    DOPL(c.idopont || '' '' || c.muvelet || '' '' || c.sorok_szama || '' '' || c.user_neve);
  END LOOP;
END;/');
END;

-- 805.
DECLARE
  TYPE betuStat IS TABLE OF NUMBER
  INDEX BY VARCHAR2 (1);

  v_betuStat betuStat;

  szohossz   NUMBER;
  betu       VARCHAR2(1);
  i          varchar2(50);
BEGIN
  FOR c IN (SELECT nev
            FROM gyumolcsok) LOOP
    DOPL(c.nev);
    szohossz := length(c.nev);
    FOR i IN 1..szohossz
    LOOP
      betu := substr(c.nev, i, 1);

      IF v_betuStat.EXISTS(betu)
      THEN
        v_betuStat(betu) := (v_betuStat(betu) + 1);
      ELSE
        v_betuStat(betu) := 1;
      END IF;
    END LOOP;
  END LOOP;

  i := v_betuStat.FIRST;

  WHILE i IS NOT NULL
  LOOP
    DOPL(i || ' ' || v_betuStat(i));
    i := v_betuStat.NEXT(i);
  END LOOP;
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(805, 'DECLARE
  TYPE betuStat IS TABLE OF NUMBER
  INDEX BY VARCHAR2 (1);

  v_betuStat betuStat;

  szohossz   NUMBER;
  betu       VARCHAR2(1);
  i          varchar2(50);
BEGIN
  FOR c IN (SELECT nev
            FROM gyumolcsok) LOOP
    DOPL(c.nev);
    szohossz := length(c.nev);
    FOR i IN 1..szohossz
    LOOP
      betu := substr(c.nev, i, 1);

      IF v_betuStat.EXISTS(betu)
      THEN
        v_betuStat(betu) := (v_betuStat(betu) + 1);
      ELSE
        v_betuStat(betu) := 1;
      END IF;
    END LOOP;
  END LOOP;

  i := v_betuStat.FIRST;

  WHILE i IS NOT NULL
  LOOP
    DOPL(i || '' '' || v_betuStat(i));
    i := v_betuStat.NEXT(i);
  END LOOP;
END;/');
END;

-- 806.
CREATE OR REPLACE PACKAGE table_manager AS
  PROCEDURE felvesz(id IN PLS_INTEGER, ertek IN VARCHAR2);
  PROCEDURE torol(id IN PLS_INTEGER);
  PROCEDURE tobbet_torol(id1 IN PLS_INTEGER, id2 IN PLS_INTEGER);

  PROCEDURE kiir;

  FUNCTION elemszam
    RETURN NUMBER;
  FUNCTION getErtek(id IN PLS_INTEGER)
    RETURN VARCHAR2;

  PROCEDURE modosit(id IN PLS_INTEGER, ertek IN VARCHAR2);

END table_manager;


CREATE OR REPLACE PACKAGE BODY TABLE_MANAGER AS

  TYPE tabla IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
  v_tabla tabla;

  PROCEDURE felvesz(id IN PLS_INTEGER, ertek IN VARCHAR2) IS
    BEGIN
      v_tabla(id) := ertek;
    END felvesz;

  PROCEDURE torol(id IN PLS_INTEGER) IS
    BEGIN
      v_tabla.DELETE(id);
    END torol;

  PROCEDURE tobbet_torol(id1 IN PLS_INTEGER, id2 IN PLS_INTEGER) IS
    BEGIN
      v_tabla.DELETE(id1, id2);
    END tobbet_torol;

  PROCEDURE kiir IS
    i varchar2(50);
    BEGIN
      i := v_tabla.FIRST;
      WHILE i IS NOT NULL
      LOOP
        DOPL(v_tabla(i));
        i := v_tabla.NEXT(i);
      END LOOP;
    END kiir;

  FUNCTION elemszam
    RETURN NUMBER IS
    BEGIN
      RETURN v_tabla.COUNT;
    END elemszam;

  FUNCTION getErtek(id IN PLS_INTEGER)
    RETURN VARCHAR2 IS
    BEGIN
      IF v_tabla.EXISTS(id)
      THEN
        RETURN v_tabla(id);
      ELSE
        RETURN NULL;
      END IF;
    END getErtek;

  PROCEDURE modosit(id IN PLS_INTEGER, ertek IN VARCHAR2) IS
    BEGIN
      v_tabla(id) := ertek;
    END modosit;

END TABLE_MANAGER;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(806, 'CREATE OR REPLACE PACKAGE table_manager AS
  PROCEDURE felvesz(id IN PLS_INTEGER, ertek IN VARCHAR2);
  PROCEDURE torol(id IN PLS_INTEGER);
  PROCEDURE tobbet_torol(id1 IN PLS_INTEGER, id2 IN PLS_INTEGER);

  PROCEDURE kiir;

  FUNCTION elemszam
    RETURN NUMBER;
  FUNCTION getErtek(id IN PLS_INTEGER)
    RETURN VARCHAR2;

  PROCEDURE modosit(id IN PLS_INTEGER, ertek IN VARCHAR2);

END table_manager;
/

CREATE OR REPLACE PACKAGE BODY TABLE_MANAGER AS

  TYPE tabla IS TABLE OF VARCHAR2(50) INDEX BY PLS_INTEGER;
  v_tabla tabla;

  PROCEDURE felvesz(id IN PLS_INTEGER, ertek IN VARCHAR2) IS
    BEGIN
      v_tabla(id) := ertek;
    END felvesz;

  PROCEDURE torol(id IN PLS_INTEGER) IS
    BEGIN
      v_tabla.DELETE(id);
    END torol;

  PROCEDURE tobbet_torol(id1 IN PLS_INTEGER, id2 IN PLS_INTEGER) IS
    BEGIN
      v_tabla.DELETE(id1, id2);
    END tobbet_torol;

  PROCEDURE kiir IS
    i varchar2(50);
    BEGIN
      i := v_tabla.FIRST;
      WHILE i IS NOT NULL
      LOOP
        DOPL(v_tabla(i));
        i := v_tabla.NEXT(i);
      END LOOP;
    END kiir;

  FUNCTION elemszam
    RETURN NUMBER IS
    BEGIN
      RETURN v_tabla.COUNT;
    END elemszam;

  FUNCTION getErtek(id IN PLS_INTEGER)
    RETURN VARCHAR2 IS
    BEGIN
      IF v_tabla.EXISTS(id)
      THEN
        RETURN v_tabla(id);
      ELSE
        RETURN NULL;
      END IF;
    END getErtek;

  PROCEDURE modosit(id IN PLS_INTEGER, ertek IN VARCHAR2) IS
    BEGIN
      v_tabla(id) := ertek;
    END modosit;

END TABLE_MANAGER;/');
END;

-- 807.
BEGIN
  TABLE_MANAGER.FELVESZ(1, 'alma');
  TABLE_MANAGER.FELVESZ(2, 'korte');
  TABLE_MANAGER.FELVESZ(3, 'szilva');

  DOPL(TABLE_MANAGER.ELEMSZAM());
  TABLE_MANAGER.KIIR();

  TABLE_MANAGER.MODOSIT(2, 'kiwi');
  TABLE_MANAGER.MODOSIT(4, 'eper');

  DOPL(TABLE_MANAGER.getErtek(2));

  TABLE_MANAGER.torol(1);

  DOPL(TABLE_MANAGER.ELEMSZAM());
  TABLE_MANAGER.KIIR();

  TABLE_MANAGER.TOBBET_TOROL(2, 3);

  DOPL(TABLE_MANAGER.ELEMSZAM());
  TABLE_MANAGER.KIIR();
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(807, 'BEGIN
  TABLE_MANAGER.FELVESZ(1, ''alma'');
  TABLE_MANAGER.FELVESZ(2, ''korte'');
  TABLE_MANAGER.FELVESZ(3, ''szilva'');

  DOPL(TABLE_MANAGER.ELEMSZAM());
  TABLE_MANAGER.KIIR();

  TABLE_MANAGER.MODOSIT(2, ''kiwi'');
  TABLE_MANAGER.MODOSIT(4, ''eper'');

  DOPL(TABLE_MANAGER.getErtek(2));

  TABLE_MANAGER.torol(1);

  DOPL(TABLE_MANAGER.ELEMSZAM());
  TABLE_MANAGER.KIIR();

  TABLE_MANAGER.TOBBET_TOROL(2, 3);

  DOPL(TABLE_MANAGER.ELEMSZAM());
  TABLE_MANAGER.KIIR();
END;/');
END;
