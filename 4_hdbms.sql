CREATE OR REPLACE PROCEDURE Feladatok() IS
  c1 CURSOR;
  BEGIN
    SELECT
      f.AZON,
      m.JO,
      f.HATARIDO,
      f.FELADAT
    FROM HDBMS18.FELADATAIM f
      LEFT JOIN HDBMS18.MEGOLDASAIM m
        ON f.AZON = m.FELADAT_AZON
    WHERE m.JO = '?' OR m.JO = 'n' OR m.JO IS NULL
    ORDER BY f.HATARIDO, f.AZON;
  END;

-- 401.
DECLARE
  SUBTYPE ALTIPUS IS BINARY_INTEGER RANGE 10..99;
  a1 ALTIPUS;
  a2 ALTIPUS;
BEGIN
  a1 := 99;
  --a2 := 1;
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(401, 'DECLARE
  SUBTYPE ALTIPUS IS BINARY_INTEGER RANGE 10..99;
  a1 ALTIPUS;
  a2 ALTIPUS;
BEGIN
  a1 := 99;
  --a2 := 1;
END;/');
END;



-- 402.
DECLARE
  CURSOR c1 IS
    SELECT c.CUSTOMER_ID
    FROM oe.CUSTOMERS c
    WHERE lower(c.CUST_LAST_NAME) LIKE 't%' OR lower(c.CUST_FIRST_NAME) LIKE 't%';

  CURSOR c2 IS
    SELECT pi.PRODUCT_ID
    FROM oe.PRODUCT_INFORMATION pi
    WHERE pi.LIST_PRICE < 500;

  FUNCTION
    USER_PRODUCTS(u_id IN OE.ORDERS.customer_id%TYPE, p_id IN oe.ORDER_ITEMS.product_id%TYPE)
    RETURN NUMBER IS
    darab NUMBER(5);
    BEGIN
      SELECT sum(QUANTITY)
      INTO darab
      FROM oe.ORDERS o
        JOIN OE.ORDER_ITEMS oi
          ON o.ORDER_ID = oi.ORDER_ID
      WHERE o.CUSTOMER_ID = u_id AND oi.PRODUCT_ID = p_id;
      RETURN darab;
    END USER_PRODUCTS;
BEGIN
  FOR up IN c1 LOOP
    FOR up1 IN c2 LOOP
      DOPL('Customer ID: ' || up.CUSTOMER_ID || ' Product ID: ' || up1.PRODUCT_ID || ' Quantity: ' ||
           USER_PRODUCTS(up.CUSTOMER_ID, up1.PRODUCT_ID));
    END LOOP;
  END LOOP;
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(402, 'DECLARE
  CURSOR c1 IS
    SELECT c.CUSTOMER_ID
    FROM oe.CUSTOMERS c
    WHERE lower(c.CUST_LAST_NAME) LIKE ''t%'' OR lower(c.CUST_FIRST_NAME) LIKE ''t%'';

  CURSOR c2 IS
    SELECT pi.PRODUCT_ID
    FROM oe.PRODUCT_INFORMATION pi
    WHERE pi.LIST_PRICE < 500;

  FUNCTION
    USER_PRODUCTS(u_id IN OE.ORDERS.customer_id%TYPE, p_id IN oe.ORDER_ITEMS.product_id%TYPE)
    RETURN NUMBER IS
    darab NUMBER(5);
    BEGIN
      SELECT sum(QUANTITY)
      INTO darab
      FROM oe.ORDERS o
        JOIN OE.ORDER_ITEMS oi
          ON o.ORDER_ID = oi.ORDER_ID
      WHERE o.CUSTOMER_ID = u_id AND oi.PRODUCT_ID = p_id;
      RETURN darab;
    END USER_PRODUCTS;
BEGIN
  FOR up IN c1 LOOP
    FOR up1 IN c2 LOOP
      DOPL(''Customer ID: '' || up.CUSTOMER_ID || '' Product ID: '' || up1.PRODUCT_ID || '' Quantity: '' ||
           USER_PRODUCTS(up.CUSTOMER_ID, up1.PRODUCT_ID));
    END LOOP;
  END LOOP;
END;/');
END;

-- 403.
DECLARE
  n           NUMBER := 90;
  TYPE PAIR IS RECORD (first NUMBER, second NUMBER);
  PI CONSTANT NUMBER := 3.14159265359;
  FUNCTION sincos(n IN BINARY_DOUBLE)
    RETURN PAIR IS
    eredmeny   PAIR;
    nInDegrees NUMBER;
    BEGIN
      nInDegrees := n * (PI / 180);
      eredmeny.first := round(sin(nInDegrees), 3);
      eredmeny.second := round(cos(nInDegrees), 3);
      RETURN eredmeny;
    END sincos;
BEGIN
  FOR i IN 0..360 LOOP
    IF MOD(i, 15) = 0
    THEN
      DOPL(i || ' ' || sincos(i).first || ' ' || sincos(i).second);
    END IF;
  END LOOP;
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(403, 'DECLARE
  n           NUMBER := 90;
  TYPE PAIR IS RECORD (first NUMBER, second NUMBER);
  PI CONSTANT NUMBER := 3.14159265359;
  FUNCTION sincos(n IN BINARY_DOUBLE)
    RETURN PAIR IS
    eredmeny   PAIR;
    nInDegrees NUMBER;
    BEGIN
      nInDegrees := n * (PI / 180);
      eredmeny.first := round(sin(nInDegrees), 3);
      eredmeny.second := round(cos(nInDegrees), 3);
      RETURN eredmeny;
    END sincos;
BEGIN
  FOR i IN 0..360 LOOP
    IF MOD(i, 15) = 0
    THEN
      DOPL(i || '' '' || sincos(i).first || '' '' || sincos(i).second);
    END IF;
  END LOOP;
END;/');
END;

-- 404.
CREATE TABLE EMPLOYEES AS
  SELECT *
  FROM HR.EMPLOYEES;

CREATE OR REPLACE PROCEDURE UPDATE_SALARY(emp_id   IN  EMPLOYEES.EMPLOYEE_ID%TYPE, boost_Salary IN NUMBER,
                                          emp_name OUT VARCHAR2, emp_salary OUT NUMBER) IS
  percent NUMBER := 1 + (boost_Salary / 100);
  BEGIN
    UPDATE EMPLOYEES e
    SET e.SALARY = e.SALARY * percent
    WHERE e.EMPLOYEE_ID = emp_id
    RETURNING e.LAST_NAME || ' ' || e.FIRST_NAME, e.SALARY INTO emp_name, emp_salary;
  END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(404, 'CREATE OR REPLACE PROCEDURE UPDATE_SALARY(emp_id   IN  EMPLOYEES.EMPLOYEE_ID%TYPE, boost_Salary IN NUMBER,
                                          emp_name OUT VARCHAR2, emp_salary OUT NUMBER) IS
  percent NUMBER := 1 + (boost_Salary / 100);
  BEGIN
    UPDATE EMPLOYEES e
    SET e.SALARY = e.SALARY * percent
    WHERE e.EMPLOYEE_ID = emp_id
    RETURNING e.LAST_NAME || '' '' || e.FIRST_NAME, e.SALARY INTO emp_name, emp_salary;
  END;/');
END;

-- 405.
DECLARE
  name   VARCHAR2(45);
  salary NUMBER(8, 2);
  id     NUMBER(6);
BEGIN
  SELECT EMPLOYEE_ID
  INTO ID
  FROM EMPLOYEES
  WHERE FIRST_NAME = 'Steven' AND LAST_NAME = 'King';

  UPDATE_SALARY(id, 50, name, salary);
  DOPL(name || ' ' || salary);

  SELECT EMPLOYEE_ID
  INTO ID
  FROM EMPLOYEES
  WHERE FIRST_NAME = 'Neena' AND LAST_NAME = 'Kochhar';
  UPDATE_SALARY(id, -50, name, salary);
  DOPL(name || ' ' || salary);
END;

CALL UPDATE_SALARY(100, 20);

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(405, 'DECLARE
  name   VARCHAR2(45);
  salary NUMBER(8, 2);
  id     NUMBER(6);
BEGIN
  SELECT EMPLOYEE_ID
  INTO ID
  FROM EMPLOYEES
  WHERE FIRST_NAME = ''Steven'' AND LAST_NAME = ''King'';

  UPDATE_SALARY(id, 50, name, salary);
  DOPL(name || '' '' || salary);

  SELECT EMPLOYEE_ID
  INTO ID
  FROM EMPLOYEES
  WHERE FIRST_NAME = ''Neena'' AND LAST_NAME = ''Kochhar'';
  UPDATE_SALARY(id, -50, name, salary);
  DOPL(name || '' '' || salary);
END;/');
END;

-- 406.
CREATE OR REPLACE FUNCTION Births_in_month(MONTH IN NUMBER)
  RETURN NUMBER IS
    honap_szam_kivetel EXCEPTION;
  eredmeny NUMBER(3);
  BEGIN
    IF month < 1 OR month > 12
    THEN
      RAISE honap_szam_kivetel;
    END IF;
    SELECT count(*)
    INTO eredmeny
    FROM OE.CUSTOMERS c
    WHERE to_number(to_char(c.DATE_OF_BIRTH, 'MM')) = month;
    RETURN eredmeny;
    EXCEPTION
    WHEN honap_szam_kivetel
    THEN
      DOPL('A(z) ' || month || ' nem egy létező hónap száma. Adj meg 1-12 közötti értéket!');
  END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(406, 'CREATE OR REPLACE FUNCTION Births_in_month(month IN NUMBER)
  RETURN NUMBER IS
    honap_szam_kivetel EXCEPTION;
    eredmeny NUMBER(3);
  BEGIN
    IF month < 1 OR month > 12
    THEN
      RAISE honap_szam_kivetel;
    END IF;
    SELECT count(*)
    INTO eredmeny
    FROM OE.CUSTOMERS c
    WHERE to_number(to_char(c.DATE_OF_BIRTH, ''MM'')) = month;
    RETURN eredmeny;
    EXCEPTION
    WHEN honap_szam_kivetel
    THEN
      DOPL(''A(z) '' || month || '' nem egy létező hónap száma. Adj meg 1-12 közötti értéket!'');
  END;/');
END;

-- 407.
SELECT BIRTHS_IN_MONTH(2)
FROM dual;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(407, 'SELECT BIRTHS_IN_MONTH(12) FROM dual;/');
END;

-- 408.
BEGIN
  DOPL(BIRTHS_IN_MONTH(12));
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(408, 'BEGIN
  DOPL(BIRTHS_IN_MONTH(12));
END;/');
END;

-----------------------------

SELECT *
FROM DICT
WHERE TABLE_NAME LIKE 'V$%';

SELECT *
FROM V$XS_SESSION_ROLES;
