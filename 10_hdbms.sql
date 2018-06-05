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

DECLARE
  jo   NUMBER(2);
  ossz NUMBER(2);
BEGIN
  SELECT count(*)
  INTO jo
  FROM HDBMS18.MEGOLDASAIM
  WHERE jo = 'i';

  SELECT count(*)
  INTO ossz
  FROM HDBMS18.FELADATAIM;

  DOPL(ROUND((jo / ossz) * 100) || '%');
END;


-- 1001.
CREATE TYPE firstNames IS TABLE OF VARCHAR2(30);

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(1001, 'CREATE TYPE firstNames IS TABLE OF VARCHAR2(30);/');
END;

-- 1002.
CREATE OR REPLACE PROCEDURE countNames(tableOfNames IN firstNames) IS
  TYPE mapOfNames IS TABLE OF NUMBER
  INDEX BY VARCHAR2 (30);

  names       mapOfNames;
  sortedNames firstNames;
  i           PLS_INTEGER;
  ii          VARCHAR2(30);
  BEGIN
--     Sort input
--     Asszocativ tomb automatikusan rendezi magat
--     SELECT CAST(MULTISET (SELECT *
--                           FROM TABLE (tableOfNames)
--                           ORDER BY 1) AS firstNames)
--     INTO sortedNames
--     FROM dual;

    i := tableOfNames.first;

    WHILE i IS NOT NULL
    LOOP
      IF names.EXISTS(tableOfNames(i))
      THEN
        names(tableOfNames(i)) := names(tableOfNames(i)) + 1;
      ELSE
        names(tableOfNames(i)) := 1;
      END IF;
      i := tableOfNames.next(i);
    END LOOP;


    ii := names.FIRST;

    WHILE ii IS NOT NULL
    LOOP
      DOPL(ii || ' ' || names(ii));
      ii := names.NEXT(ii);
    END LOOP;
  END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(1002, 'CREATE OR REPLACE PROCEDURE countNames(tableOfNames IN firstNames) IS
  TYPE mapOfNames IS TABLE OF NUMBER
  INDEX BY VARCHAR2 (30);

  names       mapOfNames;
  sortedNames firstNames;
  i           PLS_INTEGER;
  ii          VARCHAR2(30);
  BEGIN
    -- Sort input
    SELECT CAST(MULTISET (SELECT *
                          FROM TABLE (tableOfNames)
                          ORDER BY 1) AS firstNames)
    INTO sortedNames
    FROM dual;

    i := sortedNames.first;

    WHILE i IS NOT NULL
    LOOP
      IF names.EXISTS(sortedNames(i))
      THEN
        names(sortedNames(i)) := names(sortedNames(i)) + 1;
      ELSE
        names(sortedNames(i)) := 1;
      END IF;
      i := sortedNames.next(i);
    END LOOP;


    ii := names.FIRST;

    WHILE ii IS NOT NULL
    LOOP
      DOPL(ii || '' '' || names(ii));
      ii := names.NEXT(ii);
    END LOOP;
  END;/');
END;

-- 1003.
DECLARE
  tableOfFirstNames firstNames;
BEGIN
  SELECT CUST_FIRST_NAME
  BULK COLLECT INTO tableOfFirstNames
  FROM OE.CUSTOMERS;

  countNames(tableOfFirstNames);
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(1003, 'DECLARE
  tableOfFirstNames firstNames;
BEGIN
  SELECT CUST_FIRST_NAME
  BULK COLLECT INTO tableOfFirstNames
  FROM OE.CUSTOMERS;

  countNames(tableOfFirstNames);
END;/');
END;

-- 1004.
--CREATE TYPE productInfo_typ IS OBJECT (pr_name VARCHAR2(50),
--                                       pr_desc VARCHAR2(2000));
--CREATE TYPE pInfo_table IS TABLE OF productInfo_typ;

CREATE OR REPLACE FUNCTION itemsInWarehouse(wh_name OE.WAREHOUSES.WAREHOUSE_NAME%TYPE)
  RETURN pInfo_table
IS
  products pInfo_table;
  BEGIN
    SELECT productInfo_typ(PRODUCT_NAME,
                           PRODUCT_DESCRIPTION)
    BULK COLLECT INTO products
    FROM OE.PRODUCT_INFORMATION pi
      JOIN OE.INVENTORIES i
        ON pi.PRODUCT_ID = i.PRODUCT_ID
    WHERE WAREHOUSE_ID = (SELECT WAREHOUSE_ID
                          FROM OE.WAREHOUSES
                          WHERE WAREHOUSE_NAME = wh_name);
    RETURN products;
  END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(1004, '--CREATE TYPE productInfo_typ IS OBJECT (pr_name VARCHAR2(50),
--                                       pr_desc VARCHAR2(2000));
--CREATE TYPE pInfo_table IS TABLE OF productInfo_typ;

CREATE OR REPLACE FUNCTION itemsInWarehouse(wh_name OE.WAREHOUSES.WAREHOUSE_NAME%TYPE)
  RETURN pInfo_table
IS
  products pInfo_table;
  BEGIN
    SELECT productInfo_typ(PRODUCT_NAME,
                           PRODUCT_DESCRIPTION)
    BULK COLLECT INTO products
    FROM OE.PRODUCT_INFORMATION pi
      JOIN OE.INVENTORIES i
        ON pi.PRODUCT_ID = i.PRODUCT_ID
    WHERE WAREHOUSE_ID = (SELECT WAREHOUSE_ID
                          FROM OE.WAREHOUSES
                          WHERE WAREHOUSE_NAME = wh_name);
    RETURN products;
  END;/');
END;

-- 1005.
DECLARE
  products pInfo_table;
  i        pls_integer;
BEGIN
  products := itemsInWarehouse('Toronto');
  i := products.FIRST;

  WHILE i IS NOT NULL
  LOOP
    DOPL(products(i).pr_name || ' ' || products(i).pr_desc);
    i := products.NEXT(i);
  END LOOP;
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(1005, 'DECLARE
  products pInfo_table;
  i        pls_integer;
BEGIN
  products := itemsInWarehouse(''Toronto'');
  i := products.FIRST;

  WHILE i IS NOT NULL
  LOOP
    DOPL(products(i).pr_name || '' '' ||  products(i).pr_desc);
    i := products.NEXT(i);
  END LOOP;
END;/');
END;

-- 1006.
CREATE OR REPLACE PACKAGE phoneNumberManager AS
  PROCEDURE newPhoneNumber(customerID NUMBER, phoneNumber VARCHAR2);
  PROCEDURE deletePhoneNumber(customerID NUMBER, phoneNumber VARCHAR2);
  PROCEDURE replacePhoneNumber(customerID NUMBER, old VARCHAR2, new VARCHAR2);
  PROCEDURE insertIntoCustomers(customerID  NUMBER, cust_first_name VARCHAR2, cust_last_name VARCHAR2,
                                phoneNumber VARCHAR2);
END phoneNumberManager;

CREATE OR REPLACE PACKAGE BODY phoneNumberManager AS
  PROCEDURE newPhoneNumber(customerID NUMBER, phoneNumber VARCHAR2) IS
    p_numbers OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    BEGIN
      SELECT PHONE_NUMBERS
      INTO p_numbers
      FROM CUSTOMERS
      WHERE CUSTOMER_ID = customerID;

      p_numbers.EXTEND;
      p_numbers(p_numbers.COUNT) := phoneNumber;

      UPDATE CUSTOMERS
      SET PHONE_NUMBERS = p_numbers
      WHERE CUSTOMER_ID = customerID;
    END newPhoneNumber;

  PROCEDURE deletePhoneNumber(customerID NUMBER, phoneNumber VARCHAR2) IS
    p_numbers   OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    new_numbers OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    ii          pls_integer := 1;
    BEGIN
      SELECT PHONE_NUMBERS
      INTO p_numbers
      FROM CUSTOMERS
      WHERE CUSTOMER_ID = customerID;

      new_numbers.EXTEND(p_numbers.COUNT - 1);

      FOR i in 1..p_numbers.count
      LOOP
        IF p_numbers(i) = phoneNumber
        THEN
          NULL;
        ELSE
          new_numbers(ii) := p_numbers(i);
          ii := ii + 1;
        END IF;
      END LOOP;

      UPDATE CUSTOMERS
      SET PHONE_NUMBERS = new_numbers
      WHERE CUSTOMER_ID = customerID;
    END deletePhoneNumber;

  PROCEDURE replacePhoneNumber(customerID NUMBER, old VARCHAR2, new VARCHAR2) IS
    p_numbers OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    BEGIN
      SELECT PHONE_NUMBERS
      INTO p_numbers
      FROM CUSTOMERS
      WHERE CUSTOMER_ID = customerID;

      FOR i in 1..p_numbers.count
      LOOP
        IF p_numbers(i) = old
        THEN
          p_numbers(i) := new;
          EXIT;
        end if;
      END LOOP;

      UPDATE CUSTOMERS
      SET PHONE_NUMBERS = p_numbers
      WHERE CUSTOMER_ID = customerID;
    END replacePhoneNumber;

  PROCEDURE insertIntoCustomers(customerID  NUMBER, cust_first_name VARCHAR2, cust_last_name VARCHAR2,
                                phoneNumber VARCHAR2) IS
    p_numbers OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    BEGIN
      p_numbers.EXTEND(1);
      p_numbers(1) := phoneNumber;
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
      VALUES
        (customerID, cust_first_name, cust_last_name, NULL, p_numbers, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL,
         NULL, NULL);
    END insertIntoCustomers;

END phoneNumberManager;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(1006, 'CREATE OR REPLACE PACKAGE phoneNumberManager AS
  PROCEDURE newPhoneNumber(customerID NUMBER, phoneNumber VARCHAR2);
  PROCEDURE deletePhoneNumber(customerID NUMBER, phoneNumber VARCHAR2);
  PROCEDURE replacePhoneNumber(customerID NUMBER, old VARCHAR2, new VARCHAR2);
  PROCEDURE insertIntoCustomers(customerID  NUMBER, cust_first_name VARCHAR2, cust_last_name VARCHAR2,
                                phoneNumber VARCHAR2);
END phoneNumberManager;
/
CREATE OR REPLACE PACKAGE BODY phoneNumberManager AS
  PROCEDURE newPhoneNumber(customerID NUMBER, phoneNumber VARCHAR2) IS
    p_numbers OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    BEGIN
      SELECT PHONE_NUMBERS
      INTO p_numbers
      FROM CUSTOMERS
      WHERE CUSTOMER_ID = customerID;

      p_numbers.EXTEND;
      p_numbers(p_numbers.COUNT) := phoneNumber;

      UPDATE CUSTOMERS
      SET PHONE_NUMBERS = p_numbers
      WHERE CUSTOMER_ID = customerID;
    END newPhoneNumber;

  PROCEDURE deletePhoneNumber(customerID NUMBER, phoneNumber VARCHAR2) IS
    p_numbers   OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    new_numbers OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    ii          pls_integer := 1;
    BEGIN
      SELECT PHONE_NUMBERS
      INTO p_numbers
      FROM CUSTOMERS
      WHERE CUSTOMER_ID = customerID;

      new_numbers.EXTEND(p_numbers.COUNT - 1);

      FOR i in 1..p_numbers.count
      LOOP
        IF p_numbers(i) = phoneNumber
        THEN
          NULL;
        ELSE
          new_numbers(ii) := p_numbers(i);
          ii := ii + 1;
        END IF;
      END LOOP;

      UPDATE CUSTOMERS
      SET PHONE_NUMBERS = new_numbers
      WHERE CUSTOMER_ID = customerID;
    END deletePhoneNumber;

  PROCEDURE replacePhoneNumber(customerID NUMBER, old VARCHAR2, new VARCHAR2) IS
    p_numbers OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    BEGIN
      SELECT PHONE_NUMBERS
      INTO p_numbers
      FROM CUSTOMERS
      WHERE CUSTOMER_ID = customerID;

      FOR i in 1..p_numbers.count
      LOOP
        IF p_numbers(i) = old
        THEN
          p_numbers(i) := new;
          EXIT;
        end if;
      END LOOP;

      UPDATE CUSTOMERS
      SET PHONE_NUMBERS = p_numbers
      WHERE CUSTOMER_ID = customerID;
    END replacePhoneNumber;

  PROCEDURE insertIntoCustomers(customerID  NUMBER, cust_first_name VARCHAR2, cust_last_name VARCHAR2,
                                phoneNumber VARCHAR2) IS
    p_numbers OE.PHONE_LIST_TYP := OE.PHONE_LIST_TYP();
    BEGIN
      p_numbers.EXTEND(1);
      p_numbers(1) := phoneNumber;
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
      VALUES
        (customerID, cust_first_name, cust_last_name, NULL, p_numbers, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL);
    END insertIntoCustomers;

END phoneNumberManager;/');
END;

-- 1007.
BEGIN
  phoneNumberManager.newPhoneNumber(107, '362012312312');
  phoneNumberManager.replacePhoneNumber(107, '362012312312', '363032132132');
  phoneNumberManager.deletePhoneNumber(107, '363032132132');
  phoneNumberManager.insertIntoCustomers(11118, 'Alma', 'korte', '362012312312');
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(1007, 'BEGIN
  phoneNumberManager.newPhoneNumber(108, ''362012312312'');
  phoneNumberManager.replacePhoneNumber(108, ''362012312312'', ''363032132132'');
  phoneNumberManager.deletePhoneNumber(108, ''363032132132'');
  phoneNumberManager.insertIntoCustomers(11120, ''Alma'', ''korte'', ''362012312312'');
END;/');
END;


create or replace package kilenc2 as
  procedure kurzornyitas(p_salary hr.employees.salary%type);
  TYPE tombrekordok is RECORD ( fname hr.employees.first_name%type, lname hr.employees.last_name%type, eid hr.employees.employee_id%type );
  type tomb_tipus is varray (10) of tombrekordok;
  tomb tomb_tipus;
end kilenc2;

/

create or replace package body kilenc2 as
  cursor kurzor(p_salary hr.employees.salary%type) is
    select
      first_name,
      last_name,
      employee_id
    from hr.employees
    where salary < p_salary;

  procedure kurzornyitas(p_salary hr.employees.salary%type) is
    begin
      if not kurzor%isopen
      then
        open kurzor(p_salary);
      end if;
      for i in 1..10
      loop
        if kurzor%notfound
        then
          close kurzor;
          open kurzor;
        end if;
        fetch kurzor
        bulk collect into tomb;
      end loop;
    end;
end kilenc2;