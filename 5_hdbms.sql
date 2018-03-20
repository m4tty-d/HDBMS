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

-- 501.
DECLARE
  num_of_order NUMBER;
  FUNCTION orders_of_customer(c_fname OE.CUSTOMERS.CUST_FIRST_NAME%TYPE, c_lname OE.CUSTOMERS.CUST_LAST_NAME%TYPE)
    RETURN NUMBER IS
    c_id          OE.CUSTOMERS.CUSTOMER_ID%TYPE;
    num_of_orders NUMBER(5);
    BEGIN
      SELECT c.CUSTOMER_ID
      INTO c_id
      FROM oe.CUSTOMERS c
      WHERE c.CUST_FIRST_NAME = c_fname AND c.CUST_LAST_NAME = c_lname;

      SELECT COUNT(*)
      INTO num_of_orders
      FROM OE.ORDERS o
      WHERE o.CUSTOMER_ID = c_id;

      RETURN num_of_orders;
    END;
BEGIN
  --num_of_order := orders_of_customer('Constantin', 'Welles');
  --num_of_order := orders_of_customer('Charlie', 'Sutherland');
  num_of_order := orders_of_customer('Levente', 'Vig');
  DOPL(num_of_order);
  EXCEPTION
  WHEN OTHERS
  THEN
    DOPL(SQLERRM() || ' ' || SQLCODE());
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(501, 'DECLARE
  num_of_order NUMBER;
  FUNCTION orders_of_customer(c_fname OE.CUSTOMERS.CUST_FIRST_NAME%TYPE, c_lname OE.CUSTOMERS.CUST_LAST_NAME%TYPE)
    RETURN NUMBER IS
    c_id          OE.CUSTOMERS.CUSTOMER_ID%TYPE;
    num_of_orders NUMBER(5);
    BEGIN
      SELECT c.CUSTOMER_ID
      INTO c_id
      FROM oe.CUSTOMERS c
      WHERE c.CUST_FIRST_NAME = c_fname AND c.CUST_LAST_NAME = c_lname;

      SELECT COUNT(*)
      INTO num_of_orders
      FROM OE.ORDERS o
      WHERE o.CUSTOMER_ID = c_id;

      RETURN num_of_orders;
    END;
BEGIN
  --num_of_order := orders_of_customer(''Constantin'', ''Welles'');
  --num_of_order := orders_of_customer(''Charlie'', ''Sutherland'');
  num_of_order := orders_of_customer(''Levente'', ''Vig'');
  DOPL(num_of_order);
  EXCEPTION
  WHEN OTHERS
  THEN
    DOPL(SQLERRM() || '' '' || SQLCODE());
END;/');
END;

-- 502.
DECLARE
  last_order_date    VARCHAR2(40);
  rows_on_last_order NUMBER;
  FUNCTION date_formatter(datum DATE DEFAULT SYSDATE, format VARCHAR2 DEFAULT 'HH24:MM:SS')
    RETURN VARCHAR2 IS
    BEGIN
      RETURN to_char(datum, format);
    END;
  PROCEDURE get_last_order(c_fname         IN  OE.CUSTOMERS.CUST_FIRST_NAME%TYPE,
                           c_lname         IN  OE.CUSTOMERS.CUST_LAST_NAME%TYPE,
                           last_order_date OUT VARCHAR2, rows_on_last_order OUT NUMBER) IS
    c_id       OE.CUSTOMERS.CUSTOMER_ID%TYPE;
    o_id       OE.ORDERS.ORDER_ID%TYPE;
    order_date OE.ORDERS.ORDER_DATE%TYPE;
    BEGIN
      SELECT c.CUSTOMER_ID
      INTO c_id
      FROM oe.CUSTOMERS c
      WHERE c.CUST_FIRST_NAME = c_fname AND c.CUST_LAST_NAME = c_lname;

      SELECT
        ORDER_ID,
        ORDER_DATE
      INTO o_id, order_date
      FROM OE.ORDERS
      WHERE ORDER_DATE = (SELECT MAX(ORDER_DATE)
                          FROM OE.ORDERS
                          WHERE CUSTOMER_ID = c_id);

      last_order_date := date_formatter(order_date);

      SELECT count(*)
      INTO rows_on_last_order
      FROM oe.ORDER_ITEMS
      WHERE ORDER_ID = o_id;
    END;
BEGIN
  --get_last_order('Constantin', 'Welles', last_order_date, rows_on_last_order);
  get_last_order('Manisha',
                 rows_on_last_order =>  rows_on_last_order,
                 c_lname => 'Taylor',
                 last_order_date => last_order_date);
  /*
  get_last_order(
      "last_order_date" =>  last_order_date,
      "rows_on_last_order" =>  rows_on_last_order,
      "c_lname" =>  'Hannah',
      "c_fname" =>  'Matthias');
  */
  DOPL('Last order date: ' || last_order_date || ' | Rows on last order ' || rows_on_last_order);

  DOPL(date_formatter());

  EXCEPTION
  WHEN OTHERS
  THEN
    DOPL(sqlerrm() || ' ' || sqlcode());
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(502, 'DECLARE
  last_order_date    VARCHAR2(40);
  rows_on_last_order NUMBER;
  FUNCTION date_formatter(datum DATE DEFAULT SYSDATE, format VARCHAR2 DEFAULT ''HH24:MM:SS'')
    RETURN VARCHAR2 IS
    BEGIN
      RETURN to_char(datum, format);
    END;
  PROCEDURE get_last_order(c_fname         IN  OE.CUSTOMERS.CUST_FIRST_NAME%TYPE,
                           c_lname         IN  OE.CUSTOMERS.CUST_LAST_NAME%TYPE,
                           last_order_date OUT VARCHAR2, rows_on_last_order OUT NUMBER) IS
    c_id       OE.CUSTOMERS.CUSTOMER_ID%TYPE;
    o_id       OE.ORDERS.ORDER_ID%TYPE;
    order_date OE.ORDERS.ORDER_DATE%TYPE;
    BEGIN
      SELECT c.CUSTOMER_ID
      INTO c_id
      FROM oe.CUSTOMERS c
      WHERE c.CUST_FIRST_NAME = c_fname AND c.CUST_LAST_NAME = c_lname;

      SELECT
        ORDER_ID,
        ORDER_DATE
      INTO o_id, order_date
      FROM OE.ORDERS
      WHERE ORDER_DATE = (SELECT MAX(ORDER_DATE)
                          FROM OE.ORDERS
                          WHERE CUSTOMER_ID = c_id);

      last_order_date := date_formatter(order_date);

      SELECT count(*)
      INTO rows_on_last_order
      FROM oe.ORDER_ITEMS
      WHERE ORDER_ID = o_id;
    END;
BEGIN
  --get_last_order(''Constantin'', ''Welles'', last_order_date, rows_on_last_order);
  get_last_order(''Manisha'',
                 rows_on_last_order =>  rows_on_last_order,
                 c_lname => ''Taylor'',
                 last_order_date => last_order_date);
  /*
  get_last_order(
      "last_order_date" =>  last_order_date,
      "rows_on_last_order" =>  rows_on_last_order,
      "c_lname" =>  ''Hannah'',
      "c_fname" =>  ''Matthias'');
  */
  DOPL(''Last order date: '' || last_order_date || '' | Rows on last order '' || rows_on_last_order);

  DOPL(date_formatter());

  EXCEPTION
  WHEN OTHERS
  THEN
    DOPL(sqlerrm() || '' '' || sqlcode());
END;/');
END;

-- 503.
CREATE OR REPLACE PROCEDURE customer_info(c_fname    OE.CUSTOMERS.CUST_FIRST_NAME%TYPE,
                                          c_lname    OE.CUSTOMERS.CUST_LAST_NAME%TYPE,
                                          dob    OUT OE.CUSTOMERS.DATE_OF_BIRTH%TYPE,
                                          gender OUT OE.CUSTOMERS.GENDER%TYPE) IS
  BEGIN
    SELECT
      c.DATE_OF_BIRTH,
      c.GENDER
    INTO dob, gender
    FROM oe.CUSTOMERS c
    WHERE c.CUST_FIRST_NAME = c_fname AND c.CUST_LAST_NAME = c_lname;
  END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(503, 'CREATE OR REPLACE PROCEDURE customer_info(c_fname    OE.CUSTOMERS.CUST_FIRST_NAME%TYPE,
                                          c_lname    OE.CUSTOMERS.CUST_LAST_NAME%TYPE,
                                          dob    OUT OE.CUSTOMERS.DATE_OF_BIRTH%TYPE,
                                          gender OUT OE.CUSTOMERS.GENDER%TYPE) IS
  BEGIN
    SELECT
     c.DATE_OF_BIRTH,
      c.GENDER
    INTO dob, gender
    FROM oe.CUSTOMERS c
    WHERE c.CUST_FIRST_NAME = c_fname AND c.CUST_LAST_NAME = c_lname;
  END;/');
END;

-- 504.
DECLARE
  date_of_birth OE.CUSTOMERS.DATE_OF_BIRTH%TYPE;
  gender        OE.CUSTOMERS.GENDER%TYPE;
BEGIN
  --customer_info('Constantin', 'Welles',date_of_birth, gender);
  customer_info('Constantinnnn', 'Welles', date_of_birth, gender);
  DOPL(date_of_birth || ' ' || gender);
  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    DOPL(SQLERRM() || ' ' || SQLCODE());
  WHEN TOO_MANY_ROWS
  THEN
    DOPL(SQLERRM() || ' ' || SQLCODE());
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(504, 'DECLARE
  date_of_birth OE.CUSTOMERS.DATE_OF_BIRTH%TYPE;
  gender        OE.CUSTOMERS.GENDER%TYPE;
BEGIN
  --customer_info(''Constantin'', ''Welles'',date_of_birth, gender);
  customer_info(''Constantinnnn'', ''Welles'', date_of_birth, gender);
  DOPL(date_of_birth || '' '' || gender);
  EXCEPTION
  WHEN NO_DATA_FOUND
  THEN
    DOPL(SQLERRM() || '' '' || SQLCODE());
  WHEN TOO_MANY_ROWS
  THEN
    DOPL(SQLERRM() || '' '' || SQLCODE());
END;/');
END;

-- 505.
CREATE TABLE CUSTOMERS AS
  SELECT *
  FROM OE.CUSTOMERS;

ALTER TABLE CUSTOMERS
  ADD CONSTRAINT customers_pk PRIMARY KEY (CUSTOMER_ID);

DROP TABLE csaladtagok;

CREATE TABLE csaladtagok (
  cust_id            NUMBER(6),
  family_member_name VARCHAR2(50),
  CONSTRAINT csaladtagok_pk PRIMARY KEY (cust_id, family_member_name),
  CONSTRAINT csaladtagok_fk FOREIGN KEY (cust_id) REFERENCES CUSTOMERS (CUSTOMER_ID)
);


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(505, 'CREATE TABLE csaladtagok (
  cust_id            NUMBER(6),
  family_member_name VARCHAR2(50),
  CONSTRAINT csaladtagok_pk PRIMARY KEY (cust_id, family_member_name),
  CONSTRAINT csaladtagok_fk FOREIGN KEY (cust_id) REFERENCES CUSTOMERS(CUSTOMER_ID)
);/');
END;

-- 506.
CREATE OR REPLACE FUNCTION insert_family_member(ID CSALADTAGOK.CUST_ID%TYPE, NAME CSALADTAGOK.FAMILY_MEMBER_NAME%TYPE)
  RETURN CSALADTAGOK%ROWTYPE IS
  family_member CSALADTAGOK%ROWTYPE;
  customer      CUSTOMERS%ROWTYPE;
  BEGIN
    SELECT *
    INTO customer
    FROM CUSTOMERS
    WHERE CUSTOMER_ID = id;

    INSERT INTO CSALADTAGOK (CUST_ID, FAMILY_MEMBER_NAME)
    VALUES
      (id, name)
    RETURNING id, name INTO family_member;

    EXCEPTION
    WHEN DUP_VAL_ON_INDEX
    THEN
      DOPL(customer.CUST_FIRST_NAME || ' ' || customer.CUST_LAST_NAME || ' already has ' || name ||
           ' named family member.');
      RETURN family_member;
  END;

DECLARE
  family_member CSALADTAGOK%ROWTYPE;
BEGIN
  --family_member := INSERT_FAMILY_MEMBER(101, 'John Wick');
  family_member := INSERT_FAMILY_MEMBER(101, 'John Wick');
  DOPL(family_member.cust_id || ' ' || family_member.family_member_name);
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(506, 'CREATE OR REPLACE FUNCTION insert_family_member(id CSALADTAGOK.CUST_ID%TYPE, name CSALADTAGOK.FAMILY_MEMBER_NAME%TYPE)
  RETURN CSALADTAGOK%ROWTYPE IS
  family_member CSALADTAGOK%ROWTYPE;
  customer      CUSTOMERS%ROWTYPE;
  BEGIN
    SELECT *
    INTO customer
    FROM CUSTOMERS
    WHERE CUSTOMER_ID = id;

    INSERT INTO CSALADTAGOK (CUST_ID, FAMILY_MEMBER_NAME)
    VALUES
      (id, name)
    RETURNING id, name INTO family_member;

    EXCEPTION
    WHEN DUP_VAL_ON_INDEX
    THEN
      DOPL(customer.CUST_FIRST_NAME || '' '' || customer.CUST_LAST_NAME || '' already has '' || name ||
           '' named family member.'');
    RETURN family_member;
  END;/');
END;

SELECT *
FROM HDBMS18.FELADATAIM
WHERE AZON = 501;

-- 507.
CREATE OR REPLACE PROCEDURE new_family_member(cf_name IN CUSTOMERS.CUST_FIRST_NAME%TYPE,
                                              cl_name IN CUSTOMERS.CUST_LAST_NAME%TYPE,
                                              fm_name IN CSALADTAGOK.FAMILY_MEMBER_NAME%TYPE) IS
  ID         CUSTOMERS.CUSTOMER_ID%TYPE;
  fam_member CSALADTAGOK%ROWTYPE;
  BEGIN
    SELECT CUSTOMER_ID
    INTO id
    FROM CUSTOMERS
    WHERE CUST_FIRST_NAME = cf_name AND CUST_LAST_NAME = cl_name;
    fam_member := insert_family_member(id, fm_name);
    DOPL(fam_member.cust_id || ' ' || fam_member.family_member_name);
  END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(507, 'CREATE OR REPLACE PROCEDURE new_family_member(cf_name IN CUSTOMERS.CUST_FIRST_NAME%TYPE,
                                              cl_name IN CUSTOMERS.CUST_LAST_NAME%TYPE,
                                              fm_name IN CSALADTAGOK.FAMILY_MEMBER_NAME%TYPE) IS
  id CUSTOMERS.CUSTOMER_ID%TYPE;
  fam_member CSALADTAGOK%ROWTYPE;
  BEGIN
    SELECT CUSTOMER_ID INTO id
    FROM CUSTOMERS
      WHERE CUST_FIRST_NAME = cf_name AND CUST_LAST_NAME = cl_name;
  fam_member := insert_family_member(id, fm_name);
  DOPL(fam_member.cust_id || '' '' || fam_member.family_member_name);
  END;/');
END;

-- 508.
BEGIN
  DECLARE
      null_name EXCEPTION;
    PRAGMA EXCEPTION_INIT (null_name, -1400);
  BEGIN
    new_family_member('Manisha', 'Taylor', NULL);
    EXCEPTION
    WHEN null_name
    THEN
      DOPL('Please enter a family member name.');
  END;
  BEGIN
    new_family_member('Belaaaaa', 'Kovacs', 'John Appleseed');
    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      DOPL('Customer not found, please enter an existing customer name.');
  END;
  BEGIN
    new_family_member('Constantin', 'Welles', 'Levente VIg');
    EXCEPTION
    WHEN TOO_MANY_ROWS
    THEN
      DOPL('More customers with the same name.');
  END;
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
  SELECT
    1000,
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
    INCOME_LEVEL
  FROM CUSTOMERS
  WHERE CUSTOMER_ID = 101;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(508, 'BEGIN
  DECLARE
      null_name EXCEPTION;
    PRAGMA EXCEPTION_INIT (null_name, -1400);
  BEGIN
    new_family_member(''Manisha'', ''Taylor'', NULL);
    EXCEPTION
    WHEN null_name
    THEN
      DOPL(''Please enter a family member name.'');
  END;
  BEGIN
    new_family_member(''Belaaaaa'', ''Kovacs'', ''John Appleseed'');
    EXCEPTION
    WHEN NO_DATA_FOUND
    THEN
      DOPL(''Customer not found, please enter an existing customer name.'');
  END;
  BEGIN
    new_family_member(''Constantin'', ''Welles'', ''Levente VIg'');
    EXCEPTION
    WHEN TOO_MANY_ROWS
    THEN
      DOPL(''More customers with the same name.'');
  END;
END;/');
END;

-- 509.
CREATE OR REPLACE PROCEDURE new_family_member(cf_name IN CUSTOMERS.CUST_FIRST_NAME%TYPE,
                                              cl_name IN CUSTOMERS.CUST_LAST_NAME%TYPE,
                                              fm_name IN CSALADTAGOK.FAMILY_MEMBER_NAME%TYPE) IS
  ID         CUSTOMERS.CUSTOMER_ID%TYPE;
  fam_member CSALADTAGOK%ROWTYPE;
    null_name EXCEPTION;
  PRAGMA EXCEPTION_INIT (null_name, -1400);
  BEGIN
    SELECT CUSTOMER_ID
    INTO id
    FROM CUSTOMERS
    WHERE CUST_FIRST_NAME = cf_name AND CUST_LAST_NAME = cl_name;
    fam_member := insert_family_member(id, fm_name);
    DOPL(fam_member.cust_id || ' ' || fam_member.family_member_name);
    EXCEPTION
    WHEN null_name
    THEN
      DOPL('Please enter a family member name.');
    WHEN NO_DATA_FOUND
    THEN
      DOPL('Customer not found, please enter an existing customer name.');
    WHEN TOO_MANY_ROWS
    THEN
      DOPL('More customers with the same name.');
  END;

BEGIN
  --new_family_member('Manisha', 'Taylor', NULL);
  --new_family_member('Belaaaaa', 'Kovacs', 'John Appleseed');
  new_family_member('Constantin', 'Welles', 'Levente VIg');
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(509, 'CREATE OR REPLACE PROCEDURE new_family_member(cf_name IN CUSTOMERS.CUST_FIRST_NAME%TYPE,
                                              cl_name IN CUSTOMERS.CUST_LAST_NAME%TYPE,
                                              fm_name IN CSALADTAGOK.FAMILY_MEMBER_NAME%TYPE) IS
  id         CUSTOMERS.CUSTOMER_ID%TYPE;
  fam_member CSALADTAGOK%ROWTYPE;
  null_name  EXCEPTION;
  PRAGMA EXCEPTION_INIT (null_name, -1400);
  BEGIN
    SELECT CUSTOMER_ID
    INTO id
    FROM CUSTOMERS
    WHERE CUST_FIRST_NAME = cf_name AND CUST_LAST_NAME = cl_name;
    fam_member := insert_family_member(id, fm_name);
    DOPL(fam_member.cust_id || '' '' || fam_member.family_member_name);
    EXCEPTION
    WHEN null_name
    THEN
      DOPL(''Please enter a family member name.'');
    WHEN NO_DATA_FOUND
    THEN
      DOPL(''Customer not found, please enter an existing customer name.'');
    WHEN TOO_MANY_ROWS
    THEN
      DOPL(''More customers with the same name.'');
  END;/');
END;


SELECT *
FROM nls_database_parameters;
