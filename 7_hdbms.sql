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


--701.
DECLARE
  TYPE PRODUCT_INFO_TYP IS RECORD
  (p_name OE.PRODUCTS.PRODUCT_NAME%TYPE,
    quantity OE.INVENTORIES.QUANTITY_ON_HAND%TYPE );
  CURSOR c1 IS
    SELECT
      p.PRODUCT_NAME,
      i.QUANTITY_ON_HAND
    FROM OE.PRODUCTS p
      JOIN OE.INVENTORIES i
        ON p.PRODUCT_ID = i.PRODUCT_ID
    WHERE WAREHOUSE_ID = 8;
  p_info PRODUCT_INFO_TYP;
BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO p_info;
    EXIT WHEN c1%NOTFOUND;

    DOPL(p_info.p_name || ' ' || p_info.quantity);

  END LOOP;
  CLOSE c1;
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(701, 'DECLARE
  TYPE PRODUCT_INFO_TYP IS RECORD
  (p_name OE.PRODUCTS.PRODUCT_NAME%TYPE,
   quantity OE.INVENTORIES.QUANTITY_ON_HAND%TYPE);

  CURSOR c1 IS
    SELECT
      p.PRODUCT_NAME,
      i.QUANTITY_ON_HAND
    FROM OE.PRODUCTS p
      JOIN OE.INVENTORIES i
        ON p.PRODUCT_ID = i.PRODUCT_ID
    WHERE WAREHOUSE_ID = 8;

  p_info PRODUCT_INFO_TYP;

BEGIN
  OPEN c1;
  LOOP
    FETCH c1 INTO p_info;
    EXIT WHEN c1%NOTFOUND;

    DOPL(p_info.p_name || '' '' || p_info.quantity);

  END LOOP;
  CLOSE c1;
END;/');
END;

--702.
CREATE TABLE PRODUCT_INFORMATION
  AS
    SELECT *
    FROM OE.PRODUCT_INFORMATION;

CREATE OR REPLACE PROCEDURE update_exclusive_products(warehouse_id IN OE.WAREHOUSES.WAREHOUSE_ID%TYPE) IS
  CURSOR c1 IS
    SELECT *
    FROM INVENTORIES
    WHERE WAREHOUSE_ID = warehouse_id
    FOR UPDATE;
  CURSOR c2 IS
    SELECT *
    FROM INVENTORIES
    WHERE WAREHOUSE_ID != warehouse_id;
  v_c1              INVENTORIES%ROWTYPE;
  exclusive_product BOOLEAN := TRUE;
  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 INTO v_c1;
      EXIT WHEN c1%NOTFOUND;

      FOR v_c2 IN c2
      LOOP
        IF v_c2.PRODUCT_ID = v_c1.PRODUCT_ID
        THEN
          exclusive_product := FALSE;
        END IF;
      END LOOP;

      IF exclusive_product
      THEN
        UPDATE PRODUCT_INFORMATION
        SET LIST_PRICE = LIST_PRICE * 1.1
        WHERE PRODUCT_ID = v_c1.PRODUCT_ID;
      END IF;
    END LOOP;
    CLOSE c1;
  END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(702, 'CREATE OR REPLACE PROCEDURE update_exclusive_products(warehouse_id IN OE.WAREHOUSES.WAREHOUSE_ID%TYPE) IS
  CURSOR c1 IS
    SELECT *
    FROM INVENTORIES
    WHERE WAREHOUSE_ID = warehouse_id
    FOR UPDATE;
  CURSOR c2 IS
    SELECT *
    FROM INVENTORIES
    WHERE WAREHOUSE_ID != warehouse_id;
  v_c1              INVENTORIES%ROWTYPE;
  exclusive_product BOOLEAN := TRUE;
  BEGIN
    OPEN c1;
    LOOP
      FETCH c1 INTO v_c1;
      EXIT WHEN c1%NOTFOUND;

      FOR v_c2 IN c2
      LOOP
        IF v_c2.PRODUCT_ID = v_c1.PRODUCT_ID
        THEN
          exclusive_product := FALSE;
        END IF;
      END LOOP;

      IF exclusive_product
      THEN
        UPDATE PRODUCT_INFORMATION
        SET LIST_PRICE = LIST_PRICE * 1.1
        WHERE PRODUCT_ID = v_c1.PRODUCT_ID;
      END IF;
    END LOOP;
    CLOSE c1;
  END;/');
END;

--703.
BEGIN
  update_exclusive_products(8);
  COMMIT;
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(703, 'BEGIN
  update_exclusive_products(8);
  COMMIT;
END;/');
END;

--704.
DROP TABLE KONYVEK;
DROP TABLE PELDANY;

CREATE TABLE KONYVEK
(
  ISBN       VARCHAR2(13) PRIMARY KEY,
  cim        VARCHAR2(75),
  kiado      VARCHAR2(50),
  kiadas_eve DATE
);

CREATE TABLE PELDANY
(
  raktari_szam VARCHAR2(50) PRIMARY KEY,
  ISBN         VARCHAR2(13),
  FOREIGN KEY (ISBN) REFERENCES KONYVEK
);

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(704, 'CREATE TABLE KONYVEK
(
  ISBN       VARCHAR2(13) PRIMARY KEY,
  cim        VARCHAR2(75),
  kiado      VARCHAR2(50),
  kiadas_eve DATE
);
/

CREATE TABLE PELDANY
(
  raktari_szam VARCHAR2(50) PRIMARY KEY,
  ISBN         VARCHAR2(13),
  FOREIGN KEY (ISBN) REFERENCES KONYVEK
);
/');
END;


--705.
CREATE OR REPLACE PACKAGE book_manager AS
    nincs_ilyen_konyv EXCEPTION;
    nem_megfelelo_konyv EXCEPTION;
    letezo_raktari_szam EXCEPTION;

  TYPE book_type IS RECORD (
    raktari_szam VARCHAR2(50),
    cim VARCHAR2(75),
    kiado VARCHAR2(50),
    kiadas_eve DATE );

  PROCEDURE beszur_konyv(
    ISBN         VARCHAR2,
    cim          VARCHAR2,
    kiado        VARCHAR2,
    kiadas_eve   DATE,
    raktari_szam VARCHAR2);

  FUNCTION torol_konyv(raktari_szam_in VARCHAR2)
    RETURN NUMBER;

  PROCEDURE listaz(ISBN_in VARCHAR2, konyv OUT book_type);

END book_manager;
/

CREATE OR REPLACE PACKAGE BODY BOOK_MANAGER AS

  PROCEDURE beszur_konyv(
    ISBN         VARCHAR2,
    cim          VARCHAR2,
    kiado        VARCHAR2,
    kiadas_eve   DATE,
    raktari_szam VARCHAR2)
  IS
    v_c1 KONYVEK%ROWTYPE;
    BEGIN
      BEGIN
        INSERT INTO KONYVEK
        (ISBN,
         cim,
         kiado,
         kiadas_eve)
        VALUES
          (ISBN, cim, kiado, kiadas_eve);
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX
        THEN
          SELECT *
          INTO v_c1
          FROM KONYVEK
          WHERE ISBN = ISBN;

          IF (v_c1.cim = cim AND v_c1.kiado = kiado AND v_c1.kiadas_eve = kiadas_eve)
          THEN
            DOPL('örülünk');
          ELSE
            raise BOOK_MANAGER.nem_megfelelo_konyv;
          END IF;
      END;

      BEGIN
        INSERT INTO PELDANY
        (ISBN, RAKTARI_SZAM)
        VALUES
          (ISBN, raktari_szam);
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX
        THEN
          RAISE BOOK_MANAGER.letezo_raktari_szam;
      END;
    END beszur_konyv;

  FUNCTION torol_konyv(raktari_szam_in VARCHAR2)
    RETURN NUMBER IS
    remaining_copies NUMBER;
    BEGIN
      DELETE FROM PELDANY
      WHERE RAKTARI_SZAM = raktari_szam_in;

      SELECT count(*)
      INTO remaining_copies
      FROM PELDANY
      WHERE raktari_szam = raktari_szam_in;

      RETURN remaining_copies;
    END torol_konyv;

  PROCEDURE listaz(ISBN_in VARCHAR2, konyv OUT book_type) IS
    CURSOR c1 (ISBN_in IN VARCHAR2) IS
      SELECT
        raktari_szam,
        cim,
        kiado,
        kiadas_eve
      FROM PELDANY
        JOIN KONYVEK K on PELDANY.ISBN = K.ISBN
      WHERE K.ISBN = ISBN_in;

    BEGIN
      IF (NOT c1%ISOPEN)
      THEN
        OPEN c1(ISBN_in);
      END IF;

      FETCH c1 INTO konyv;
      IF (c1%NOTFOUND)
      THEN
        konyv := null;
      end if;

      EXCEPTION
      WHEN INVALID_CURSOR
      THEN
        raise BOOK_MANAGER.nincs_ilyen_konyv;
    END listaz;

END BOOK_MANAGER;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(705, 'CREATE OR REPLACE PACKAGE book_manager AS
    nincs_ilyen_konyv EXCEPTION;
    nem_megfelelo_konyv EXCEPTION;
    letezo_raktari_szam EXCEPTION;

  TYPE book_type IS RECORD (
    raktari_szam VARCHAR2(50),
    cim VARCHAR2(75),
    kiado VARCHAR2(50),
    kiadas_eve DATE );

  PROCEDURE beszur_konyv(
    ISBN         VARCHAR2,
    cim          VARCHAR2,
    kiado        VARCHAR2,
    kiadas_eve   DATE,
    raktari_szam VARCHAR2);

  FUNCTION torol_konyv(raktari_szam_in VARCHAR2)
    RETURN NUMBER;

  PROCEDURE listaz(ISBN_in VARCHAR2, konyv OUT book_type);

END book_manager;
/

CREATE OR REPLACE PACKAGE BODY BOOK_MANAGER AS

  PROCEDURE beszur_konyv(
    ISBN         VARCHAR2,
    cim          VARCHAR2,
    kiado        VARCHAR2,
    kiadas_eve   DATE,
    raktari_szam VARCHAR2)
  IS
    v_c1 KONYVEK%ROWTYPE;
    BEGIN
      BEGIN
        INSERT INTO KONYVEK
        (ISBN,
         cim,
         kiado,
         kiadas_eve)
        VALUES
          (ISBN, cim, kiado, kiadas_eve);
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX
        THEN
          SELECT *
          INTO v_c1
          FROM KONYVEK
          WHERE ISBN = ISBN;

          IF (v_c1.cim = cim AND v_c1.kiado = kiado AND v_c1.kiadas_eve = kiadas_eve)
          THEN
            DOPL(''örülünk'');
          ELSE
            raise BOOK_MANAGER.nem_megfelelo_konyv;
          END IF;
      END;

      BEGIN
        INSERT INTO PELDANY
        (ISBN, RAKTARI_SZAM)
        VALUES
          (ISBN, raktari_szam);
        EXCEPTION
        WHEN DUP_VAL_ON_INDEX
        THEN
          RAISE BOOK_MANAGER.letezo_raktari_szam;
      END;
    END beszur_konyv;

  FUNCTION torol_konyv(raktari_szam_in VARCHAR2)
    RETURN NUMBER IS
    remaining_copies NUMBER;
    BEGIN
      DELETE FROM PELDANY
      WHERE RAKTARI_SZAM = raktari_szam_in;

      SELECT count(*)
      INTO remaining_copies
      FROM PELDANY
      WHERE raktari_szam = raktari_szam_in;

      RETURN remaining_copies;
    END torol_konyv;

  PROCEDURE listaz(ISBN_in VARCHAR2, konyv OUT book_type) IS
    CURSOR c1 (ISBN_in IN VARCHAR2) IS
      SELECT
        raktari_szam,
        cim,
        kiado,
        kiadas_eve
      FROM PELDANY
        JOIN KONYVEK K on PELDANY.ISBN = K.ISBN
      WHERE K.ISBN = ISBN_in;

    BEGIN
      IF (NOT c1%ISOPEN)
      THEN
        OPEN c1(ISBN_in);
      END IF;

      FETCH c1 INTO konyv;
      IF (c1%NOTFOUND)
      THEN
        konyv := null;
      end if;

      EXCEPTION
      WHEN INVALID_CURSOR
      THEN
        raise BOOK_MANAGER.nincs_ilyen_konyv;
    END listaz;

END BOOK_MANAGER;/');
END;

--706.

BEGIN
  BEGIN
    BOOK_MANAGER.BESZUR_KONYV('1234567891012', 'Book#1', 'Publisher#1', to_date('2016', 'YYYY'), '123123');
  END;
  BEGIN
    BOOK_MANAGER.BESZUR_KONYV('1234567891012', 'Book#1', 'Publisher#1', to_date('2016', 'YYYY'), '123123');
    -- Minden oke.
  END;

  BEGIN
    BOOK_MANAGER.BESZUR_KONYV('1234567891012', 'Book#2', 'Publisher#2', to_date('2015', 'YYYY'), '123124');
    EXCEPTION WHEN BOOK_MANAGER.nem_megfelelo_konyv
    THEN
      DOPL('Nem megfelelo konyv');
  END;

  BEGIN
    BOOK_MANAGER.BESZUR_KONYV('1235343536253', 'Book#3', 'Publisher#3', to_date('2010', 'YYYY'), '123123');
    EXCEPTION
    WHEN BOOK_MANAGER.letezo_raktari_szam
    THEN
      DOPL('Letezo raktari szam');
  END;
END;
/

BEGIN
  DOPL(BOOK_MANAGER.TOROL_KONYV(123123));
END;
/

DECLARE
  konyv BOOK_MANAGER.book_type;
BEGIN
  BOOK_MANAGER.LISTAZ('1234567891012', konyv);
  DOPL(konyv.cim || ' ' || konyv.kiadas_eve);
END;

BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(706, 'BEGIN
  BEGIN
    BOOK_MANAGER.BESZUR_KONYV(''1234567891012'', ''Book#1'', ''Publisher#1'', to_date(''2016'', ''YYYY''), ''123123'');
  END;
  BEGIN
    BOOK_MANAGER.BESZUR_KONYV(''1234567891012'', ''Book#1'', ''Publisher#1'', to_date(''2016'', ''YYYY''), ''123123'');
    -- Minden oke.
  END;

  BEGIN
    BOOK_MANAGER.BESZUR_KONYV(''1234567891012'', ''Book#2'', ''Publisher#2'', to_date(''2015'', ''YYYY''), ''123124'');
    EXCEPTION WHEN BOOK_MANAGER.nem_megfelelo_konyv
    THEN
      DOPL(''Nem megfelelo konyv'');
  END;

  BEGIN
    BOOK_MANAGER.BESZUR_KONYV(''1235343536253'', ''Book#3'', ''Publisher#3'', to_date(''2010'', ''YYYY''), ''123123'');
    EXCEPTION
    WHEN BOOK_MANAGER.letezo_raktari_szam
    THEN
      DOPL(''Letezo raktari szam'');
  END;
END;
/

BEGIN
  DOPL(BOOK_MANAGER.TOROL_KONYV(123123));
END;
/

DECLARE
  konyv BOOK_MANAGER.book_type;
BEGIN
  BOOK_MANAGER.LISTAZ(''1234567891012'', konyv);
  DOPL(konyv.cim || '' '' || konyv.kiadas_eve);
END;/');
END;
