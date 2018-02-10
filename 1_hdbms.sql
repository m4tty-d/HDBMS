-- 101.
SELECT
  CUST_FIRST_NAME || ' ' || CUST_LAST_NAME AS Name,
  to_char(DATE_OF_BIRTH, 'DS')             AS "Date of birth"
FROM OE.CUSTOMERS
ORDER BY DATE_OF_BIRTH DESC, Name;

-- PL/SQL block
BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(101, '
      SELECT CUST_FIRST_NAME || '' '' || CUST_LAST_NAME AS Name, to_char(DATE_OF_BIRTH, ''DS'') as "Date of birth"
      FROM OE.CUSTOMERS
      ORDER BY DATE_OF_BIRTH desc, Name;/');
END;


-- 102.
SELECT
  c.CUSTOMER_ID                                AS "ID",
  c.CUST_FIRST_NAME || ' ' || c.CUST_LAST_NAME AS Name,
  to_char(max(o.order_date), 'DS')             AS "Date"
FROM OE.CUSTOMERS c
  LEFT JOIN OE.ORDERS o
    ON c.CUSTOMER_ID = o.CUSTOMER_ID
GROUP BY c.customer_id, c.CUST_FIRST_NAME || ' ' || c.CUST_LAST_NAME
ORDER BY "Date";

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(102, '
SELECT c.CUSTOMER_ID, c.CUST_FIRST_NAME || '' '' || c.CUST_LAST_NAME as Name, to_char(max(o.order_date), ''DS'')
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
WHERE o.ORDER_ID IN (
  SELECT o.ORDER_ID
  FROM oe.CUSTOMERS c
    JOIN ORDERS o
      ON c.customer_id = o.customer_id
  WHERE months_between(o.order_date, c.date_of_birth) / 12 < 20
);

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(104, 'UPDATE ORDERS o
    SET o.ORDER_TOTAL = o.ORDER_TOTAL * 0.9
WHERE o.ORDER_ID IN (
    SELECT o.ORDER_ID
    FROM oe.CUSTOMERS c
    JOIN ORDERS o
      ON c.customer_id=o.customer_id
    WHERE months_between(o.order_date, c.date_of_birth)/12 < 20
);/');
END;


-- 105.
SELECT
  o.ORDER_ID,
  to_char(o.ORDER_DATE, 'DS HH24:MM:SS')       AS "Order Date",
  c.CUST_FIRST_NAME || ' ' || c.CUST_LAST_NAME AS "Customer Name"
FROM oe.ORDERS o
  JOIN oe.ORDER_ITEMS i
    ON o.ORDER_ID = i.ORDER_ID
  JOIN oe.CUSTOMERS c
    ON c.CUSTOMER_ID = o.CUSTOMER_ID
GROUP BY o.ORDER_ID, o.ORDER_DATE, c.CUST_FIRST_NAME || ' ' || c.CUST_LAST_NAME
HAVING count(*) > 5;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(105, 'SELECT o.ORDER_ID, to_char(o.ORDER_DATE, ''DS HH24:MM:SS'') as "Order Date", c.CUST_FIRST_NAME || '' '' || c.CUST_LAST_NAME as "Customer Name"
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
INSERT INTO ORDERS
VALUES (3000, TO_DATE('2018/02/09 17:36:25', 'YYYY/MM/DD HH24:MI:SS'), 'direct', 100, 0, 999999, 153, NULL);

SELECT *
FROM ORDERS
WHERE CUSTOMER_ID = 100;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(108, 'INSERT INTO ORDERS
VALUES (3000, TO_DATE(''2018/02/09 17:36:25'', ''YYYY/MM/DD HH24:MI:SS''), ''direct'', 100, 0, 999999, 153, NULL );/');
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
