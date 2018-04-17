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

-- 601.
CREATE OR REPLACE TRIGGER tr_customer_changed
  BEFORE UPDATE OF GENDER OR UPDATE OF MARITAL_STATUS OR INSERT
  ON CUSTOMERS
  FOR EACH ROW
  BEGIN
    IF (:NEW.GENDER = 'F' OR :NEW.MARITAL_STATUS NOT IN ('hajadon', 'férjes', 'özvegy'))
       OR (:NEW.GENDER='F' AND :OLD.MARITAL_STATUS NOT IN ('hajadon', 'férjes', 'özvegy'))
    THEN
      raise_application_error(-20010, 'Nem megfelelő nem és/vagy családi állapot');
    END IF;
    IF (:NEW.GENDER = 'M' OR :NEW.MARITAL_STATUS NOT IN ('nőtlen', 'nős', 'özvegy'))
      OR (:NEW.GENDER = 'M' AND :OLD.MARITAL_STATUS NOT IN ('nőtlen', 'nős', 'özvegy'))
    THEN
      raise_application_error(-20010, 'Nem megfelelő nem és/vagy családi állapot');
    END IF;
  END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(601, 'CREATE OR REPLACE TRIGGER tr_customer_changed
  BEFORE UPDATE OF GENDER OR UPDATE OF MARITAL_STATUS OR INSERT
  ON CUSTOMERS
  FOR EACH ROW
  BEGIN
    IF :NEW.GENDER = ''F'' AND :NEW.MARITAL_STATUS NOT IN (''hajadon'', ''férjes'', ''özvegy'')
    THEN
      raise_application_error(-20010, ''Nem megfelelő nem és/vagy családi állapot'');
    END IF;
    IF :NEW.GENDER = ''M'' AND :NEW.MARITAL_STATUS NOT IN (''nőtlen'', ''nős'', ''özvegy'')
    THEN
      raise_application_error(-20010, ''Nem megfelelő nem és/vagy családi állapot'');
    END IF;
  END;/');
END;


-- 602.
DECLARE
    marital_status_error EXCEPTION;
    PRAGMA EXCEPTION_INIT (marital_status_error, -20010);
BEGIN
  BEGIN
    INSERT INTO CUSTOMERS (CUSTOMER_ID,
                           CUST_FIRST_NAME,
                           CUST_LAST_NAME,
                           CUST_ADDRESS,
                           PHONE_NUMBERS,
                           NLS_LANGUAGE,
                           NLS_TERRITORY,
                           CREDIT_LIMIT,
                           CUST_EMAIL,
                           ACCOUNT_MGR_ID,
                           CUST_GEO_LOCATION,
                           DATE_OF_BIRTH,
                           MARITAL_STATUS,
                           GENDER,
                           INCOME_LEVEL)
    VALUES (9999, 'Montgomery', 'Montgomery', NULL, NULL, 'us', 'AMERICA',
                  100.00, 'montgomery@montgomery.com', 145, NULL, NULL, 'married', 'M',
            'B: 30,000 - 49,999');
    EXCEPTION
    WHEN marital_status_error
    THEN DOPL('Nem megfelelő nem és/vagy családi állapot');
  END;
  BEGIN
    UPDATE CUSTOMERS
    SET MARITAL_STATUS = 'single'
    WHERE CUSTOMER_ID = 101;
    EXCEPTION
    WHEN marital_status_error
    THEN DOPL('Nem megfelelő nem és/vagy családi állapot');
  END;
  BEGIN
    UPDATE CUSTOMERS
    SET GENDER = 'M'
    WHERE CUSTOMER_ID = 101;
    EXCEPTION
    WHEN marital_status_error
    THEN DOPL('Nem megfelelő nem és/vagy családi állapot!!!!!!!!!!!');
  END;
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(602, 'DECLARE
    marital_status_error EXCEPTION;
  PRAGMA EXCEPTION_INIT (marital_status_error, -20010);
BEGIN
  BEGIN
    INSERT INTO CUSTOMERS (CUSTOMER_ID,
                           CUST_FIRST_NAME,
                           CUST_LAST_NAME,
                           CUST_ADDRESS,
                           PHONE_NUMBERS,
                           NLS_LANGUAGE,
                           NLS_TERRITORY,
                           CREDIT_LIMIT,
                           CUST_EMAIL,
                           ACCOUNT_MGR_ID,
                           CUST_GEO_LOCATION,
                           DATE_OF_BIRTH,
                           MARITAL_STATUS,
                           GENDER,
                           INCOME_LEVEL)
    VALUES (9999, ''Montgomery'', ''Montgomery'', NULL, NULL, ''us'', ''AMERICA'',
                  100.00, ''montgomery@montgomery.com'', 145, NULL, NULL, ''married'', ''M'',
            ''B: 30,000 - 49,999'');
    EXCEPTION
    WHEN marital_status_error
    THEN DOPL(''Nem megfelelő nem és/vagy családi állapot'');
  END;
  BEGIN
    UPDATE CUSTOMERS
    SET MARITAL_STATUS = ''single''
    WHERE CUSTOMER_ID = 101;
    EXCEPTION
    WHEN marital_status_error
    THEN DOPL(''Nem megfelelő nem és/vagy családi állapot'');
  END;
END;/');
END;

-- 603.
CREATE TABLE uj_naplo
(
  user_name  VARCHAR2(30),
  time       DATE,
  table_name VARCHAR2(30),
  action     VARCHAR2(7)
);

CREATE TABLE PRODUCT_DESCRIPTIONS AS
  SELECT *
  FROM OE.PRODUCT_DESCRIPTIONS;


CREATE OR REPLACE TRIGGER tr_customer_update
  AFTER INSERT OR DELETE
  ON CUSTOMERS
  FOR EACH ROW
  DECLARE
    action CHAR(6);
  BEGIN
    CASE
      WHEN INSERTING
      THEN
        action := 'INSERT';
      WHEN DELETING
      THEN
        action := 'DELETE';
    END CASE;
    INSERT INTO UJ_NAPLO (user_name, time, table_name, action) VALUES
      (user, sysdate, 'CUSTOMERS', action);
  END;
/

CREATE OR REPLACE TRIGGER tr_product_update
  AFTER INSERT OR DELETE
  ON PRODUCT_DESCRIPTIONS
  FOR EACH ROW
  DECLARE
    action CHAR(6);
  BEGIN
    CASE
      WHEN INSERTING
      THEN
        action := 'INSERT';
      WHEN DELETING
      THEN
        action := 'DELETE';
    END CASE;
    INSERT INTO UJ_NAPLO (user_name, time, table_name, action) VALUES
      (user, sysdate, 'PRODUCT_DESCRIPTIONS', action);
  END;
/

INSERT INTO CUSTOMERS (CUSTOMER_ID,
                       CUST_FIRST_NAME,
                       CUST_LAST_NAME,
                       CUST_ADDRESS,
                       PHONE_NUMBERS,
                       NLS_LANGUAGE,
                       NLS_TERRITORY,
                       CREDIT_LIMIT,
                       CUST_EMAIL,
                       ACCOUNT_MGR_ID,
                       CUST_GEO_LOCATION,
                       DATE_OF_BIRTH,
                       MARITAL_STATUS,
                       GENDER,
                       INCOME_LEVEL)
VALUES (101010, 'Montgomery', 'Montgomery', NULL, NULL, 'us', 'AMERICA',
                100.00, 'montgomery@montgomery.com', 145, NULL, NULL, 'özvegy', 'M',
        'B: 30,000 - 49,999');

DELETE FROM CUSTOMERS
WHERE CUSTOMER_ID = 1000;

DELETE FROM PRODUCT_DESCRIPTIONS
WHERE PRODUCT_ID = 1799;

INSERT INTO PRODUCT_DESCRIPTIONS
(PRODUCT_ID,
 LANGUAGE_ID,
 TRANSLATED_NAME,
 TRANSLATED_DESCRIPTION)
VALUES
  (9999,
   'US',
   'LCD Monitor 11/PM',
   'Monitor');

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(603, 'CREATE OR REPLACE TRIGGER tr_customer_update
  AFTER INSERT OR DELETE
  ON CUSTOMERS
  FOR EACH ROW
  DECLARE
    action CHAR(6);
  BEGIN
    CASE
      WHEN INSERTING
      THEN
        action := ''INSERT'';
      WHEN DELETING
      THEN
        action := ''DELETE'';
    END CASE;
    INSERT INTO UJ_NAPLO (user_name, time, table_name, action) VALUES
      (user, sysdate, ''CUSTOMERS'', action);
  END;
/

CREATE OR REPLACE TRIGGER tr_product_update
  AFTER INSERT OR DELETE
  ON PRODUCT_DESCRIPTIONS
  FOR EACH ROW
  DECLARE
    action CHAR(6);
  BEGIN
    CASE
      WHEN INSERTING
      THEN
        action := ''INSERT'';
      WHEN DELETING
      THEN
        action := ''DELETE'';
    END CASE;
    INSERT INTO UJ_NAPLO (user_name, time, table_name, action) VALUES
      (user, sysdate, ''PRODUCT_DESCRIPTIONS'', action);
  END;
/');
END;

-- 604.
INSERT INTO CUSTOMERS (CUSTOMER_ID,
                       CUST_FIRST_NAME,
                       CUST_LAST_NAME,
                       CUST_ADDRESS,
                       PHONE_NUMBERS,
                       NLS_LANGUAGE,
                       NLS_TERRITORY,
                       CREDIT_LIMIT,
                       CUST_EMAIL,
                       ACCOUNT_MGR_ID,
                       CUST_GEO_LOCATION,
                       DATE_OF_BIRTH,
                       MARITAL_STATUS,
                       GENDER,
                       INCOME_LEVEL)
VALUES (101010, 'Montgomery', 'Montgomery', NULL, NULL, 'us', 'AMERICA',
                100.00, 'montgomery@montgomery.com', 145, NULL, NULL, 'özvegy', 'M',
        'B: 30,000 - 49,999');








/

DELETE FROM CUSTOMERS
WHERE CUSTOMER_ID = 1000;








/

DELETE FROM PRODUCT_DESCRIPTIONS
WHERE PRODUCT_ID = 1799;








/

INSERT INTO PRODUCT_DESCRIPTIONS
(PRODUCT_ID,
 LANGUAGE_ID,
 TRANSLATED_NAME,
 TRANSLATED_DESCRIPTION)
VALUES
  (9999,
   'US',
   'LCD Monitor 11/PM',
   'Monitor');

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(604, 'INSERT INTO CUSTOMERS (CUSTOMER_ID,
                       CUST_FIRST_NAME,
                       CUST_LAST_NAME,
                       CUST_ADDRESS,
                       PHONE_NUMBERS,
                       NLS_LANGUAGE,
                       NLS_TERRITORY,
                       CREDIT_LIMIT,
                       CUST_EMAIL,
                       ACCOUNT_MGR_ID,
                       CUST_GEO_LOCATION,
                       DATE_OF_BIRTH,
                       MARITAL_STATUS,
                       GENDER,
                       INCOME_LEVEL)
VALUES (1010, ''Montgomery'', ''Montgomery'', NULL, NULL, ''us'', ''AMERICA'',
                100.00, ''montgomery@montgomery.com'', 145, NULL, NULL, ''özvegy'', ''M'',
        ''B: 30,000 - 49,999'');
/

DELETE FROM CUSTOMERS
WHERE CUSTOMER_ID = 1000;
/

DELETE FROM PRODUCT_DESCRIPTIONS
WHERE PRODUCT_ID = 1799;
/

INSERT INTO PRODUCT_DESCRIPTIONS
(PRODUCT_ID,
 LANGUAGE_ID,
 TRANSLATED_NAME,
 TRANSLATED_DESCRIPTION)
VALUES
  (9999,
  ''US'',
  ''LCD Monitor 11/PM'',
  ''Monitor'');/');
END;

-- 605.
CREATE TABLE hallgatok
(
  name        VARCHAR2(40),
  neptun_code CHAR(6) PRIMARY KEY
);
DROP TABLE hallgatok;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(605, 'CREATE TABLE hallgatok
(
  name        VARCHAR2(40),
  neptun_code CHAR(6) PRIMARY KEY
);/');
END;

-- 606.

CREATE OR REPLACE TRIGGER tr_hallgato_delete_before
  BEFORE DELETE
  ON HALLGATOK
  BEGIN
    DOPL('trigger: delete utasítás előtt.');
  END;
  /

CREATE OR REPLACE TRIGGER tr_hallgato_delete_before_row
  BEFORE DELETE
  ON HALLGATOK
  FOR EACH ROW
  BEGIN
    DOPL('trigger: delete utasítás előtt FOR EACH ROW.');
  END;
  /

CREATE OR REPLACE TRIGGER tr_hallgato_delete_after
  AFTER DELETE
  ON HALLGATOK
  BEGIN
    DOPL('trigger: delete utasítás után.');
  END;
  /

CREATE OR REPLACE TRIGGER tr_hallgato_delete_after_row
  AFTER DELETE
  ON HALLGATOK
  FOR EACH ROW
  BEGIN
    DOPL('trigger: delete utasítás után FOR EACH ROW.');
  END;
  /


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(606, 'CREATE OR REPLACE TRIGGER tr_hallgato_delete_before
  BEFORE DELETE
  ON HALLGATOK
  BEGIN
    DOPL(''trigger: delete utasítás előtt.'');
  END;
  /

CREATE OR REPLACE TRIGGER tr_hallgato_delete_before_row
  BEFORE DELETE
  ON HALLGATOK
  FOR EACH ROW
  BEGIN
    DOPL(''trigger: delete utasítás előtt FOR EACH ROW.'');
  END;
  /

CREATE OR REPLACE TRIGGER tr_hallgato_delete_after
  AFTER DELETE
  ON HALLGATOK
  BEGIN
    DOPL(''trigger: delete utasítás után.'');
  END;
  /

CREATE OR REPLACE TRIGGER tr_hallgato_delete_after_row
  AFTER DELETE
  ON HALLGATOK
  FOR EACH ROW
  BEGIN
    DOPL(''trigger: delete utasítás után FOR EACH ROW.'');
  END;
  /');
END;

-- 607.
INSERT ALL
INTO HALLGATOK (NAME, neptun_code) VALUES ('Vig Levente', 'GFZ5JS')
INTO HALLGATOK (NAME, neptun_code) VALUES ('Gurmai István', '123ABC')
INTO HALLGATOK (NAME, neptun_code) VALUES ('Berki Ádám', 'ASD321')
INTO HALLGATOK (NAME, neptun_code) VALUES ('Czibere Mirabella', 'HGF765')
INTO HALLGATOK (NAME, neptun_code) VALUES ('Valaki Valaki', 'LKJ987')
INTO HALLGATOK (NAME, neptun_code) VALUES ('Alma Korte', 'MNB987')
  SELECT 1
  FROM DUAL;


BEGIN
  DELETE FROM HALLGATOK;

  DELETE FROM HALLGATOK;
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(607, 'BEGIN
  DELETE FROM HALLGATOK;

  DELETE FROM HALLGATOK;
END;/');
END;

-- 608.
DROP TABLE NAPLO;

CREATE TABLE NAPLO
(
  idopont     DATE,
  muvelet     VARCHAR2(20),
  felhasznalo VARCHAR2(30),
  tablanev    VARCHAR2(20)
);


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(608, 'CREATE TABLE NAPLO
(
  idopont     DATE,
  muvelet     VARCHAR2(20),
  felhasznalo VARCHAR2(30),
  tablanev    VARCHAR2(20)
);/');
END;

-- 609.
CREATE OR REPLACE TRIGGER tr_no_edit_naplo
  BEFORE UPDATE OR DELETE
  ON NAPLO
  BEGIN
    raise_application_error(-20003, 'Érvénytelen művelet');
  END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(609, 'CREATE OR REPLACE TRIGGER tr_no_edit_naplo
  BEFORE UPDATE OR DELETE
  ON NAPLO
  BEGIN
    raise_application_error(-20003, ''Érvénytelen művelet'');
  END;/');
END;

-- 610.
DECLARE
    ervenytelen_muvelet EXCEPTION;
  PRAGMA EXCEPTION_INIT (ervenytelen_muvelet, -20003);
BEGIN
  INSERT INTO NAPLO
  (IDOPONT,
   HIBA_KOD,
   HIBA_UZENET)
  VALUES
    (sysdate, 1234, 'Baj van!');
  COMMIT;
  DELETE FROM NAPLO
  WHERE HIBA_KOD = 1234;
  EXCEPTION
  WHEN ervenytelen_muvelet
  THEN
    DOPL(SQLERRM);
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(610, 'DECLARE
  ervenytelen_muvelet EXCEPTION;
  PRAGMA EXCEPTION_INIT(ervenytelen_muvelet, -20003);
BEGIN
  INSERT INTO NAPLO
  (IDOPONT,
   HIBA_KOD,
   HIBA_UZENET)
  VALUES
    (sysdate, 1234, ''Baj van!'');
  COMMIT;
  DELETE FROM NAPLO
  WHERE HIBA_KOD = 1234;
  EXCEPTION
  WHEN ervenytelen_muvelet
  THEN
    DOPL(SQLERRM);
END;/');
END;

-- 611.
CREATE TABLE PRODUCTS AS
  SELECT *
  FROM OE.PRODUCTS;

CREATE OR REPLACE TRIGGER tr_dml_product
  AFTER UPDATE OR DELETE OR INSERT
  ON PRODUCTS
  DECLARE
    action VARCHAR2(10);
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

    INSERT INTO UJ_NAPLO
    (USER_NAME, TIME, TABLE_NAME, ACTION)
    VALUES (user, sysdate, 'PRODUCTS', action);
  END;
/

CREATE OR REPLACE TRIGGER tr_dml_customer
  AFTER UPDATE OR DELETE OR INSERT
  ON CUSTOMERS
  DECLARE
    action VARCHAR2(10);
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

    INSERT INTO UJ_NAPLO
    (USER_NAME, TIME, TABLE_NAME, ACTION)
    VALUES (user, sysdate, 'CUSTOMERS', action);
  END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(611, 'CREATE OR REPLACE TRIGGER tr_dml_product
  AFTER UPDATE OR DELETE OR INSERT
  ON PRODUCTS
  DECLARE
    action VARCHAR2(10);
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

    INSERT INTO UJ_NAPLO
    (USER_NAME, TIME, TABLE_NAME, ACTION)
    VALUES (user, sysdate, ''PRODUCTS'', action);
  END;
/

CREATE OR REPLACE TRIGGER tr_dml_customer
  AFTER UPDATE OR DELETE OR INSERT
  ON CUSTOMERS
  DECLARE
    action VARCHAR2(10);
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

    INSERT INTO UJ_NAPLO
    (USER_NAME, TIME, TABLE_NAME, ACTION)
    VALUES (user, sysdate, ''CUSTOMERS'', action);
  END;/');
END;

-- 612.
INSERT INTO PRODUCTS
(PRODUCT_ID,
 LANGUAGE_ID,
 PRODUCT_NAME,
 CATEGORY_ID,
 PRODUCT_DESCRIPTION,
 WEIGHT_CLASS,
 WARRANTY_PERIOD,
 SUPPLIER_ID,
 PRODUCT_STATUS,
 LIST_PRICE,
 MIN_PRICE,
 CATALOG_URL)
VALUES
  (9999,
    'US',
    'Gaming laptop',
    12,
    'Laptop for gaming',
    3,
    NULL,
    103067,
    'orderable',
    100000,
    90000,
   'http://www.www.supp-102067.com/cat/hw/p1726.html');
/

UPDATE PRODUCTS
SET LIST_PRICE = LIST_PRICE * 1.2
WHERE PRODUCT_ID = 9999;
/

DELETE FROM PRODUCTS
WHERE PRODUCT_ID = 9999;
/

INSERT INTO CUSTOMERS
(CUSTOMER_ID,
 CUST_FIRST_NAME,
 CUST_LAST_NAME,
 CUST_ADDRESS,
 PHONE_NUMBERS,
 NLS_LANGUAGE,
 NLS_TERRITORY,
 CREDIT_LIMIT,
 CUST_EMAIL,
 ACCOUNT_MGR_ID,
 CUST_GEO_LOCATION,
 DATE_OF_BIRTH,
 MARITAL_STATUS,
 GENDER,
 INCOME_LEVEL)
VALUES
  ( 9999,
    'Alma',
    'Körte',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL);
/

UPDATE CUSTOMERS
SET NLS_LANGUAGE = 'us'
  WHERE CUSTOMER_ID = 9999;
/

DELETE FROM CUSTOMERS
WHERE CUSTOMER_ID = 9999;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(612, 'INSERT INTO PRODUCTS
(PRODUCT_ID,
 LANGUAGE_ID,
 PRODUCT_NAME,
 CATEGORY_ID,
 PRODUCT_DESCRIPTION,
 WEIGHT_CLASS,
 WARRANTY_PERIOD,
 SUPPLIER_ID,
 PRODUCT_STATUS,
 LIST_PRICE,
 MIN_PRICE,
 CATALOG_URL)
VALUES
  (9999,
    ''US'',
    ''Gaming laptop'',
    12,
    ''Laptop for gaming'',
    3,
    NULL,
    103067,
    ''orderable'',
    100000,
    90000,
   ''http://www.www.supp-102067.com/cat/hw/p1726.html'');
/

UPDATE PRODUCTS
SET LIST_PRICE = LIST_PRICE * 1.2
WHERE PRODUCT_ID = 9999;
/

DELETE FROM PRODUCTS
WHERE PRODUCT_ID = 9999;
/

INSERT INTO CUSTOMERS
(CUSTOMER_ID,
 CUST_FIRST_NAME,
 CUST_LAST_NAME,
 CUST_ADDRESS,
 PHONE_NUMBERS,
 NLS_LANGUAGE,
 NLS_TERRITORY,
 CREDIT_LIMIT,
 CUST_EMAIL,
 ACCOUNT_MGR_ID,
 CUST_GEO_LOCATION,
 DATE_OF_BIRTH,
 MARITAL_STATUS,
 GENDER,
 INCOME_LEVEL)
VALUES
  ( 9999,
    ''Alma'',
    ''Körte'',
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL,
    NULL);
/

UPDATE CUSTOMERS
SET NLS_LANGUAGE = ''us''
  WHERE CUSTOMER_ID = 9999;
/

DELETE FROM CUSTOMERS
WHERE CUSTOMER_ID = 9999;/');
END;


