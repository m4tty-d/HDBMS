-- 1.
CREATE OR REPLACE FUNCTION Oldest_customer_after(datum DATE)
  RETURN OE.CUSTOMERS.CUSTOMER_ID%TYPE IS
  c_id OE.CUSTOMERS.CUSTOMER_ID%TYPE := NULL;
  more_than_one_customer EXCEPTION;
  PRAGMA EXCEPTION_INIT (more_than_one_customer, -1422);
  BEGIN
    SELECT CUSTOMER_ID
    INTO c_id
    FROM OE.CUSTOMERS
    WHERE DATE_OF_BIRTH = (SELECT MIN(DATE_OF_BIRTH)
                           FROM OE.CUSTOMERS
                           WHERE DATE_OF_BIRTH > datum);
    RETURN c_id;
    EXCEPTION WHEN more_than_one_customer
    THEN
      raise_application_error(-20001, 'Több ilyen ügyfél van');
  END;

BEGIN
  DOPL(OLDEST_CUSTOMER_AFTER(to_date('2042-11-15', 'YYYY-MM-DD')));
END;

SELECT *
FROM OE.CUSTOMERS
WHERE DATE_OF_BIRTH = to_date('2042-11-16', 'YYYY-MM-DD');


SELECT
  DATE_OF_BIRTH,
  count(*)
FROM OE.CUSTOMERS
GROUP BY DATE_OF_BIRTH
HAVING count(*) > 1;

-- 2.
CREATE OR REPLACE PROCEDURE order_info(o_id      IN  OE.ORDERS.ORDER_ID%TYPE,
                                       cust_name OUT VARCHAR2,
                                       cust_id   OUT OE.CUSTOMERS.CUSTOMER_ID%TYPE) IS
  CURSOR c IS
    SELECT
      pi.PRODUCT_NAME       AS P_NAME,
      UNIT_PRICE,
      QUANTITY,
      UNIT_PRICE * QUANTITY AS PRICE
    FROM OE.ORDER_ITEMS oi
      JOIN OE.PRODUCT_INFORMATION pi
      USING (PRODUCT_ID)
    WHERE oi.ORDER_ID = o_id
    ORDER BY oi.LINE_ITEM_ID;
  BEGIN
    SELECT
      CUST_FIRST_NAME || ' ' || CUSTOMERS.CUST_LAST_NAME,
      CUSTOMER_ID
    INTO cust_name, cust_id
    FROM OE.CUSTOMERS
    WHERE CUSTOMER_ID = (SELECT CUSTOMER_ID
                         FROM OE.ORDERS
                         WHERE ORDER_ID = o_id);
    FOR ord IN c
    LOOP
      DOPL(ord.P_NAME || ' ' || ord.QUANTITY || ' ' || ord.UNIT_PRICE || ' ' || ord.PRICE);
    END LOOP;
  END;

DECLARE
  cust_name VARCHAR2(50);
  cust_id   OE.CUSTOMERS.CUSTOMER_ID%TYPE;
BEGIN
  ORDER_INFO(o_id => 2458, cust_name =>  cust_name, cust_id =>  cust_id);

  DOPL(cust_name || ' ' || cust_id);
END;


-- 3.
DECLARE
  c_id OE.CUSTOMERS.CUSTOMER_ID%TYPE;
BEGIN
  c_id := Oldest_customer_after('asd');
  DOPL(c_id);
  DOPL('valami');
  EXCEPTION
  WHEN OTHERS
  THEN
    DOPL(SQLERRM || ' ' || sqlcode);
END;


SELECT *
FROM SZERELO.SZ_AUTO;

SELECT *
FROM SZERELO.SZ_TULAJDONOS;