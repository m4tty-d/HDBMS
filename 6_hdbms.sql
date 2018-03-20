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
    IF :NEW.GENDER = 'F' AND :NEW.MARITAL_STATUS NOT IN ('hajadon', 'férjes', 'özvegy')
    THEN
      raise_application_error(-20010, 'Nem megfelelő nem és/vagy családi állapot');
    END IF;
    IF :NEW.GENDER = 'M' AND :NEW.MARITAL_STATUS NOT IN ('nőtlen', 'nős', 'özvegy')
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
CREATE TABLE naplo
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
    INSERT INTO NAPLO (user_name, time, table_name, action) VALUES
      (user, sysdate, 'CUSTOMERS', action);
  END;

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
    INSERT INTO NAPLO (user_name, time, table_name, action) VALUES
      (user, sysdate, 'PRODUCT_DESCRIPTIONS', action);
  END;

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

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(603, '/');
END;

-- 604.


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(604, '/');
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


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(606, '/');
END;

-- 607.


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(607, '/');
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


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(609, '/');
END;

-- 610.


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(610, '/');
END;

-- 611.


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(611, '/');
END;

-- 612.


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(612, '/');
END;


