-- 301.
DECLARE TYPE EMBER IS RECORD (
  azonosito NUMBER(5),
  nev VARCHAR2(50),
  szul_hely VARCHAR2(50)
  NOT NULL := 'Debrecen');
  Levi EMBER;
BEGIN
  Levi.azonosito := 10000;
  Levi.nev := 'Vig Levente';
  Levi.szul_hely := 'Debrecen';

  DBMS_OUTPUT.PUT_LINE(Levi.azonosito);
  DBMS_OUTPUT.PUT_LINE(Levi.nev);
  DBMS_OUTPUT.PUT_LINE(Levi.szul_hely);
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(301, 'DECLARE TYPE EMBER IS RECORD (
  azonosito NUMBER(5),
  nev VARCHAR2(50),
  szul_hely VARCHAR2(50)
  NOT NULL := ''Debrecen'');
  Levi EMBER;
BEGIN
  Levi.azonosito := 10000;
  Levi.nev := ''Vig Levente'';
  Levi.szul_hely := ''Debrecen'';

  DBMS_OUTPUT.PUT_LINE(Levi.azonosito);
  DBMS_OUTPUT.PUT_LINE(Levi.nev);
  DBMS_OUTPUT.PUT_LINE(Levi.szul_hely);
END;/');
END;

-- 302.
DECLARE
  legidosebb oe.CUSTOMERS%ROWTYPE;
BEGIN
  SELECT *
  INTO legidosebb
  FROM oe.CUSTOMERS
  WHERE DATE_OF_BIRTH = (SELECT MIN(DATE_OF_BIRTH)
                         FROM oe.CUSTOMERS);
  DBMS_OUTPUT.PUT_LINE(legidosebb.CUST_FIRST_NAME || ' ' || legidosebb.CUST_LAST_NAME);
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(302, 'DECLARE
  legidosebb oe.CUSTOMERS%ROWTYPE;
BEGIN
  SELECT *
  INTO legidosebb
  FROM oe.CUSTOMERS
  WHERE DATE_OF_BIRTH = (SELECT MIN(DATE_OF_BIRTH)
                         FROM oe.CUSTOMERS);
  DBMS_OUTPUT.PUT_LINE(legidosebb.CUST_FIRST_NAME || '' '' || legidosebb.CUST_LAST_NAME);
END;/');
END;

-- 303.
DECLARE customer oe.CUSTOMERS%ROWTYPE;
BEGIN
  SELECT *
  INTO customer
  FROM oe.CUSTOMERS c
  WHERE CUSTOMER_ID = (SELECT CUSTOMER_ID
                       FROM oe.ORDERS
                       GROUP BY CUSTOMER_ID
                       HAVING count(*) = 2);
  DBMS_OUTPUT.PUT_LINE('Azonosító: ' || customer.CUSTOMER_ID);
  DBMS_OUTPUT.PUT_LINE('Név: ' || customer.CUST_FIRST_NAME || ' ' || customer.CUST_LAST_NAME);
  DBMS_OUTPUT.PUT_LINE('Születési dátum ' || to_char(customer.DATE_OF_BIRTH, 'YYYY.MM.DD'));
END;

SELECT *
FROM ORDERS
ORDER BY CUSTOMER_ID;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(303, 'DECLARE customer oe.CUSTOMERS%ROWTYPE;
BEGIN
  SELECT *
  INTO customer
  FROM oe.CUSTOMERS c
  WHERE CUSTOMER_ID = (SELECT CUSTOMER_ID
                       FROM oe.ORDERS
                       GROUP BY CUSTOMER_ID
                       HAVING count(*) = 2);
  DBMS_OUTPUT.PUT_LINE(''Azonosító: '' || customer.CUSTOMER_ID);
  DBMS_OUTPUT.PUT_LINE(''Név: '' || customer.CUST_FIRST_NAME || '' '' || customer.CUST_LAST_NAME);
  DBMS_OUTPUT.PUT_LINE(''Születési dátum '' || to_char(customer.DATE_OF_BIRTH, ''YYYY.MM.DD''));
END;/');
END;


-- 304.
SELECT *
FROM INVENTORIES i
WHERE WAREHOUSE_ID = (SELECT WAREHOUSE_ID
                      FROM oe.WAREHOUSES w
                      WHERE w.WAREHOUSE_NAME = 'Beijing');

CREATE TABLE INVENTORIES AS (
  SELECT *
  FROM oe.INVENTORIES
);


BEGIN
  UPDATE INVENTORIES i
  SET i.QUANTITY_ON_HAND = i.QUANTITY_ON_HAND - 10
  WHERE i.WAREHOUSE_ID = (SELECT WAREHOUSE_ID
                          FROM oe.WAREHOUSES w
                          WHERE w.WAREHOUSE_NAME = 'Beijing');

  DELETE FROM INVENTORIES
  WHERE QUANTITY_ON_HAND < 10;
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(304, 'BEGIN
  DELETE FROM INVENTORIES
  WHERE QUANTITY_ON_HAND <= 10;

  UPDATE INVENTORIES i
  SET i.QUANTITY_ON_HAND = i.QUANTITY_ON_HAND - 10
  WHERE i.WAREHOUSE_ID = (SELECT WAREHOUSE_ID
                          FROM oe.WAREHOUSES w
                          WHERE w.WAREHOUSE_NAME = ''Beijing'');
END;/');
END;


-- 305.
SELECT
  c.CUSTOMER_ID,
  oi.QUANTITY
FROM oe.CUSTOMERS c
  JOIN oe.ORDERS o
    ON c.CUSTOMER_ID = o.CUSTOMER_ID
  JOIN oe.ORDER_ITEMS oi
    ON o.ORDER_ID = oi.ORDER_ID;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(305, '/');
END;
