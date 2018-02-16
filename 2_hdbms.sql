-- 201.
BEGIN
  DBMS_OUTPUT.PUT_LINE('Szép az élet');
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(201, 'BEGIN
  DBMS_OUTPUT.PUT_LINE(''Szép az élet'');
END;/');
END;



-- 202.
BEGIN
  DBMS_OUTPUT.PUT_LINE('A mai dátum: ' || to_char(sysdate, 'YYYY.MM.DD. HH24:MM:SS') || ', A userneved: ' || user);
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(202, 'BEGIN
  DBMS_OUTPUT.PUT_LINE(''A mai dátum: '' || to_char(sysdate, ''YYYY.MM.DD. HH24:MM:SS'') || '', A userneved: '' || user);
END;/');
END;


-- 203.
DECLARE
  x NUMBER := 1;
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE(x ** 2);
    x := x + 1;
    EXIT WHEN X > 10;
  END LOOP;
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(203, 'DECLARE
  x NUMBER := 1;
BEGIN
  LOOP
    DBMS_OUTPUT.PUT_LINE(x ** 2);
    x := x + 1;
    EXIT WHEN X > 10;
  END LOOP;
END;/');
END;


-- 204.
DECLARE
  x NUMBER(5) := 9;
BEGIN
  IF MOD(x, 6) = 0
  THEN
    DBMS_OUTPUT.PUT_LINE(x || ' osztható 6-al');
  ELSIF MOD(x, 2) = 0
    THEN
      DBMS_OUTPUT.PUT_LINE(x || ' osztható 2-vel');
  ELSIF MOD(x, 3) = 0
    THEN
      DBMS_OUTPUT.PUT_LINE(x || ' osztható 3-al');
  END IF;
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(204, 'DECLARE
  x NUMBER(5) := 9;
BEGIN
  IF MOD(x, 6) = 0
  THEN
    DBMS_OUTPUT.PUT_LINE(x || '' osztható 6-al'');
  ELSIF MOD(x, 2) = 0
    THEN
      DBMS_OUTPUT.PUT_LINE(x || '' osztható 2-vel'');
  ELSIF MOD(x, 3) = 0
    THEN
      DBMS_OUTPUT.PUT_LINE(x || '' osztható 3-al'');
  END IF;
END;/');
END;


-- 205.
DECLARE
  x    NUMBER := 39;
  y    NUMBER := 91;
  x_og NUMBER := x;
  y_og NUMBER := y;
  temp NUMBER(10);
BEGIN
  WHILE y != 0 LOOP
    temp := x;
    x := y;
    y := mod(temp, y);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(x || ' a legnagyobb közös osztó');
  DBMS_OUTPUT.PUT_LINE((x_og * y_og) / x || ' a legkisebb közös többszörös');
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(205, 'DECLARE
  x    NUMBER := 39;
  y    NUMBER := 91;
  x_og NUMBER := x;
  y_og NUMBER := y;
  temp NUMBER(10);
BEGIN
  WHILE y != 0 LOOP
    temp := x;
    x := y;
    y := mod(temp, y);
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(x || '' a legnagyobb közös osztó'');
  DBMS_OUTPUT.PUT_LINE((x_og * y_og) / x || '' a legkisebb közös többszörös'');
END;/');
END;

