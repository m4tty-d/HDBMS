-- 101.
SELECT
  CUST_FIRST_NAME || ' ' || CUST_LAST_NAME AS Name,
  to_char(DATE_OF_BIRTH, 'YYYY.MM.DD.')             AS "Date of birth"
FROM OE.CUSTOMERS
ORDER BY DATE_OF_BIRTH DESC, Name;

-- PL/SQL block
BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(101, '
      SELECT CUST_FIRST_NAME || '' '' || CUST_LAST_NAME AS Name, to_char(DATE_OF_BIRTH, ''YYYY.MM.DD.'') as "Date of birth"
      FROM OE.CUSTOMERS
      ORDER BY DATE_OF_BIRTH desc, Name;/');
END;


-- 102.
SELECT
  c.CUSTOMER_ID                                AS "ID",
  c.CUST_FIRST_NAME || ' ' || c.CUST_LAST_NAME AS Name,
  to_char(max(o.order_date), 'YYYY.MM.DD.')             AS "Date"
FROM OE.CUSTOMERS c
  LEFT JOIN OE.ORDERS o
    ON c.CUSTOMER_ID = o.CUSTOMER_ID
GROUP BY c.customer_id, c.CUST_FIRST_NAME || ' ' || c.CUST_LAST_NAME
ORDER BY "Date";

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(102, '
SELECT c.CUSTOMER_ID, c.CUST_FIRST_NAME || '' '' || c.CUST_LAST_NAME as Name, to_char(max(o.order_date), ''YYYY.MM.DD.'')
FROM OE.CUSTOMERS c
LEFT JOIN OE.ORDERS o
  ON c.CUSTOMER_ID=o.CUSTOMER_ID
GROUP BY c.customer_id, c.CUST_FIRST_NAME || '' '' || c.CUST_LAST_NAME
ORDER BY max(o.order_date);/');
END;


-- 103.
SELECT
  pi.product_name,
  i.quantity_on_hand
FROM oe.WAREHOUSES w
  JOIN oe.INVENTORIES i
    ON w.warehouse_id = i.warehouse_id
  JOIN oe.PRODUCT_INFORMATION pi
    ON i.product_id = pi.product_id
WHERE w.warehouse_name = 'Bombay'
ORDER BY i.quantity_on_hand DESC;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(103, '
  SELECT pi.product_name, i.quantity_on_hand
  FROM oe.WAREHOUSES w
  JOIN oe.INVENTORIES i
    ON w.warehouse_id=i.warehouse_id
  JOIN oe.PRODUCT_INFORMATION pi
    ON i.product_id=pi.product_id
  WHERE w.warehouse_name=''Bombay''
  ORDER BY i.quantity_on_hand desc;/');
END;


-- 104.
CREATE TABLE ORDERS
  AS (SELECT *
      FROM oe.orders);

UPDATE ORDERS o
SET o.ORDER_TOTAL = o.ORDER_TOTAL * 0.9
WHERE o.CUSTOMER_ID IN (
  SELECT c.CUSTOMER_ID
  FROM oe.CUSTOMERS c
  WHERE months_between(o.order_date, c.date_of_birth) / 12 < 20
);

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(104, 'UPDATE ORDERS o
SET o.ORDER_TOTAL = o.ORDER_TOTAL * 0.9
WHERE o.ORDER_ID IN (
  SELECT c.CUSTOMER_ID
  FROM oe.CUSTOMERS c
  WHERE months_between(o.order_date, c.date_of_birth) / 12 < 20
);/');
END;


-- 105.
SELECT
  o.ORDER_ID,
  to_char(o.ORDER_DATE, 'YYYY.MM.DD. HH24:MM:SS')       AS "Order Date",
  c.CUST_FIRST_NAME || ' ' || c.CUST_LAST_NAME AS "Customer Name"
FROM oe.ORDERS o
  JOIN oe.ORDER_ITEMS i
    ON o.ORDER_ID = i.ORDER_ID
  JOIN oe.CUSTOMERS c
    ON c.CUSTOMER_ID = o.CUSTOMER_ID
GROUP BY o.ORDER_ID, o.ORDER_DATE, c.CUST_FIRST_NAME || ' ' || c.CUST_LAST_NAME
HAVING count(*) > 5;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(105, 'SELECT o.ORDER_ID, to_char(o.ORDER_DATE, ''YYYY.MM.DD. HH24:MM:SS'') as "Order Date", c.CUST_FIRST_NAME || '' '' || c.CUST_LAST_NAME as "Customer Name"
                                  FROM oe.ORDERS o
                                JOIN oe.ORDER_ITEMS i
                                    ON o.ORDER_ID = i.ORDER_ID
                                JOIN oe.CUSTOMERS c
                                    on c.CUSTOMER_ID = o.CUSTOMER_ID
                                GROUP BY o.ORDER_ID, o.ORDER_DATE, c.CUST_FIRST_NAME || '' '' || c.CUST_LAST_NAME
                                HAVING count(*) > 5;/');
END;


-- 106.
SELECT
  p.PRODUCT_ID,
  p.PRODUCT_NAME,
  p.PRODUCT_DESCRIPTION
FROM oe.PRODUCT_INFORMATION p
  LEFT JOIN oe.ORDER_ITEMS oi
    ON p.PRODUCT_ID = oi.PRODUCT_ID
WHERE oi.ORDER_ID IS NULL
ORDER BY oi.PRODUCT_ID;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(106, 'SELECT
  p.PRODUCT_ID,
  p.PRODUCT_NAME,
  p.PRODUCT_DESCRIPTION
FROM oe.PRODUCT_INFORMATION p
  LEFT JOIN oe.ORDER_ITEMS oi
    ON p.PRODUCT_ID = oi.PRODUCT_ID
WHERE oi.ORDER_ID IS NULL
ORDER BY oi.PRODUCT_ID;/');
END;


-- 107.
CREATE OR REPLACE VIEW INCOME_AND_SPENDING_VIEW AS
  SELECT
    c.INCOME_LEVEL                 AS INCOME_LEVEL,
    to_char(o.ORDER_DATE, 'MONTH') AS ORDER_MONTH,
    sum(ORDER_TOTAL)               AS ORDER_TOTAL
  FROM oe.CUSTOMERS c
    JOIN oe.ORDERS o
      ON c.CUSTOMER_ID = o.CUSTOMER_ID
  GROUP BY c.INCOME_LEVEL, to_char(o.ORDER_DATE, 'MONTH')
  ORDER BY INCOME_LEVEL, to_char(o.ORDER_DATE, 'MONTH');

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(107, 'CREATE OR REPLACE VIEW INCOME_AND_SPENDING AS
  SELECT c.INCOME_LEVEL AS INCOME_LEVEL, to_char(o.ORDER_DATE, ''MONTH'') AS ORDER_MONTH, sum(ORDER_TOTAL) AS ORDER_TOTAL
  FROM oe.CUSTOMERS c
  JOIN oe.ORDERS o
    ON c.CUSTOMER_ID = o.CUSTOMER_ID
  GROUP BY c.INCOME_LEVEL, to_char(o.ORDER_DATE, ''MONTH'')
  ORDER BY INCOME_LEVEL, to_char(o.ORDER_DATE, ''MONTH'');/');
END;


-- 108.
INSERT INTO ORDERS (ORDER_ID,
                    ORDER_DATE,
                    ORDER_MODE,
                    CUSTOMER_ID,
                    ORDER_STATUS,
                    ORDER_TOTAL,
                    SALES_REP_ID,
                    PROMOTION_ID)
VALUES (3000, TO_DATE('2018/02/09 17:36:25', 'YYYY/MM/DD HH24:MI:SS'), 'direct', 100, 0, 999999, 153, NULL);

SELECT *
FROM ORDERS
WHERE CUSTOMER_ID = 100;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(108, 'INSERT INTO ORDERS (ORDER_ID,
                    ORDER_DATE,
                    ORDER_MODE,
                    CUSTOMER_ID,
                    ORDER_STATUS,
                    ORDER_TOTAL,
                    SALES_REP_ID,
                    PROMOTION_ID)
VALUES (3000, TO_DATE(''2018/02/09 17:36:25'', ''YYYY/MM/DD HH24:MI:SS''), ''direct'', 100, 0, 999999, 153, NULL);/');
END;


-- 109.
CREATE TABLE raktar_reszlegek (
  azonosito        NUMBER(3),
  raktar_azonosito NUMBER(4),
  alapitas_datuma  DATE,
  reszleg_neve     VARCHAR2(50),
  PRIMARY KEY (azonosito, raktar_azonosito),
  FOREIGN KEY (raktar_azonosito) REFERENCES WAREHOUSES (WAREHOUSE_ID)
);

CREATE TABLE WAREHOUSES
  AS (SELECT *
      FROM oe.WAREHOUSES);

SELECT *
FROM WAREHOUSES;

ALTER TABLE WAREHOUSES
  ADD PRIMARY KEY (WAREHOUSE_ID);

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(109, 'CREATE TABLE raktar_reszlegek (
  azonosito        NUMBER(3),
  raktar_azonosito NUMBER(4),
  alapitas_datuma  DATE,
  reszleg_neve     VARCHAR2(50),
  PRIMARY KEY (azonosito, raktar_azonosito),
  FOREIGN KEY (raktar_azonosito) REFERENCES WAREHOUSES(WAREHOUSE_ID)
);/');
END;


-- 110.
SELECT *
FROM oe.PRODUCT_INFORMATION
WHERE (lower(PRODUCT_DESCRIPTION) LIKE '%motherboard%' OR lower(PRODUCT_DESCRIPTION) LIKE '%card%')
      AND (LIST_PRICE BETWEEN 50 AND 100 OR LIST_PRICE IS NULL);

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(110, 'SELECT *
  FROM oe.PRODUCT_INFORMATION
WHERE (lower(PRODUCT_DESCRIPTION) LIKE ''%motherboard%'' OR lower(PRODUCT_DESCRIPTION) LIKE ''%card%'')
AND (LIST_PRICE BETWEEN 50 AND 100  or LIST_PRICE is NULL );/');
END;

----------------------------------------
SELECT count(*) AS "Accepted solutions"
FROM HDBMS18.MEGOLDASAIM
WHERE JO = 'i';

SELECT
  FELADAT_AZON,
  MEGJEGYZES
FROM HDBMS18.MEGOLDASAIM
WHERE JO = 'h';

-------------------------------------------------------------------

BEGIN
  DBMS_OUTPUT.PUT_LINE('Hello World!');
END;

DECLARE
  v_Nagyobb NUMBER;
  x         NUMBER := 7;
  y         NUMBER := 6;
BEGIN
  v_Nagyobb := x;
  IF x < y
  THEN v_Nagyobb := y;
  END IF;
END;


DECLARE
  v_Nagyobb NUMBER;
  x         NUMBER := 5;
  y         NUMBER := 6;
BEGIN
  IF x < y
  THEN v_Nagyobb := y;
  ELSE v_Nagyobb := x;
  END IF;
END;


DECLARE
  v_Nagyobb NUMBER;
  x         NUMBER := 5;
  y         NUMBER := 7;
BEGIN
  IF x < y
  THEN
    DBMS_OUTPUT.PUT_LINE('x kisebb, mint y');
    v_Nagyobb := y;
  ELSIF x > y
    THEN
      DBMS_OUTPUT.PUT_LINE('x nagyobb, mint y');
      v_Nagyobb := x;
  ELSE
    DBMS_OUTPUT.PUT_LINE('x és y egyenlők');
    v_Nagyobb := x;
  END IF;
END;


DECLARE
  v_Osszeg NUMBER(10) := 0;
BEGIN
  FOR i IN 1..100 LOOP
    v_Osszeg := v_Osszeg + i;
  END LOOP;
END;


DECLARE
  v_Osszeg NUMBER(10) := 0;
BEGIN
  FOR i IN REVERSE 1..100 LOOP
    v_Osszeg := v_Osszeg + i;
  END LOOP;
END;


DECLARE
  v_Osszeg PLS_INTEGER;
  i        PLS_INTEGER;
BEGIN
  i := 1;
  v_Osszeg := 0;
  LOOP
    v_Osszeg := v_Osszeg + i;
    EXIT WHEN v_Osszeg >= 100; -- elértük a célt
    i := i + 1;
  END LOOP;
END;


DECLARE
  v_Osszeg PLS_INTEGER := 0;
BEGIN
  <<kulso>>
  FOR i IN 1..100 LOOP
    FOR j IN 1..i LOOP
      v_Osszeg := v_Osszeg + i;
      EXIT kulso
      WHEN v_Osszeg > 100;
    END LOOP;
  END LOOP;
END;
