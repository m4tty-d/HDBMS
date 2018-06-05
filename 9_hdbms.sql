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

-- 901.
DECLARE
  TYPE job_titles IS TABLE OF HR.JOBS.JOB_TITLE%TYPE;
  TYPE min_salary IS TABLE OF HR.JOBS.MIN_SALARY%TYPE;
  TYPE max_salary IS TABLE OF HR.JOBS.MAX_SALARY%TYPE;

  v_jobs       job_titles := job_titles();
  v_min_salary min_salary := min_salary();
  v_max_salary max_salary := max_salary();

BEGIN
  SELECT
    JOB_TITLE,
    MIN_SALARY,
    MAX_SALARY
  BULK COLLECT INTO v_jobs, v_min_salary, v_max_salary
  FROM HR.JOBS;

  FOR i IN 1..v_jobs.COUNT
  LOOP
    IF v_min_salary(i) > (v_max_salary(i) / 2)
    THEN
      v_jobs.DELETE(i);
    END IF;
  END LOOP;

  FORALL i IN INDICES OF v_jobs
  UPDATE EMPLOYEES
  SET SALARY = v_max_salary(i) * 1.1
  WHERE JOB_ID IN (SELECT JOBS.JOB_ID
                   FROM HR.JOBS
                   WHERE JOB_TITLE = v_jobs(i));
  COMMIT;
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(901, 'DECLARE
  TYPE job_titles IS TABLE OF HR.JOBS.JOB_TITLE%TYPE;
  TYPE min_salary IS TABLE OF HR.JOBS.MIN_SALARY%TYPE;
  TYPE max_salary IS TABLE OF HR.JOBS.MAX_SALARY%TYPE;

  v_jobs       job_titles := job_titles();
  v_min_salary min_salary := min_salary();
  v_max_salary max_salary := max_salary();

BEGIN
  SELECT
    JOB_TITLE,
    MIN_SALARY,
    MAX_SALARY
  BULK COLLECT INTO v_jobs, v_min_salary, v_max_salary
  FROM HR.JOBS;

  FOR i IN 1..v_jobs.COUNT
  LOOP
    IF v_min_salary(i) > (v_max_salary(i) / 2)
    THEN
      v_jobs.DELETE(i);
    END IF;
  END LOOP;

  FORALL i IN INDICES OF v_jobs
  UPDATE EMPLOYEES
  SET SALARY = v_max_salary(i) * 1.1
  WHERE JOB_ID IN (SELECT JOBS.JOB_ID
                   FROM HR.JOBS
                   WHERE JOB_TITLE = v_jobs(i));
  COMMIT;
END;/');
END;

-- 902.
CREATE OR REPLACE PACKAGE manage_employees AS
  PROCEDURE employees_below(salary IN HR.EMPLOYEES.SALARY%TYPE);

  TYPE emp_varr IS VARRAY (10) OF VARCHAR2(55);
  employees_varray emp_varr;

END manage_employees;


CREATE OR REPLACE PACKAGE BODY manage_employees AS

  CURSOR c1(fizu IN HR.EMPLOYEES.SALARY%TYPE) IS
    SELECT FIRST_NAME || ' ' || LAST_NAME as name
    FROM HR.EMPLOYEES
    WHERE SALARY < fizu;

  PROCEDURE employees_below(salary IN HR.EMPLOYEES.SALARY%TYPE) IS

    BEGIN
      IF (NOT c1%ISOPEN)
      THEN
        OPEN c1(salary);
      END IF;

      FETCH c1 BULK COLLECT INTO employees_varray LIMIT 10;

      IF (c1%NOTFOUND)
      THEN
        CLOSE c1;
        OPEN c1(salary);
      END IF;
    END employees_below;

END manage_employees;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(902, 'CREATE OR REPLACE PACKAGE manage_employees AS
  PROCEDURE employees_below(salary IN HR.EMPLOYEES.SALARY%TYPE);

  TYPE emp_varr IS VARRAY (10) OF VARCHAR2(55);
  employees_varray emp_varr;

END manage_employees;
/

CREATE OR REPLACE PACKAGE BODY manage_employees AS

  CURSOR c1(fizu IN HR.EMPLOYEES.SALARY%TYPE) IS
    SELECT FIRST_NAME || '' '' || LAST_NAME as name
    FROM HR.EMPLOYEES
    WHERE SALARY < fizu;

  PROCEDURE employees_below(salary IN HR.EMPLOYEES.SALARY%TYPE) IS

    BEGIN
      IF (NOT c1%ISOPEN)
      THEN
        OPEN c1(salary);
      END IF;

      FETCH c1 BULK COLLECT INTO employees_varray LIMIT 10;

      IF (c1%NOTFOUND)
      THEN
        CLOSE c1;
        OPEN c1(salary);
      END IF;
    END employees_below;

END manage_employees;/');
END;

-- 903.
BEGIN
  BEGIN
    MANAGE_EMPLOYEES.EMPLOYEES_BELOW(300000);

    FOR elem IN 1..MANAGE_EMPLOYEES.employees_varray.count LOOP
      DOPL(elem || ': ' || MANAGE_EMPLOYEES.employees_varray(elem));
    END LOOP;
  END;
  BEGIN
    MANAGE_EMPLOYEES.EMPLOYEES_BELOW(300000);

    FOR elem IN 1..MANAGE_EMPLOYEES.employees_varray.count LOOP
      DOPL(elem || ': ' || MANAGE_EMPLOYEES.employees_varray(elem));
    END LOOP;
  END;
  BEGIN
    MANAGE_EMPLOYEES.EMPLOYEES_BELOW(300000);

    FOR elem IN 1..MANAGE_EMPLOYEES.employees_varray.count LOOP
      DOPL(elem || ': ' || MANAGE_EMPLOYEES.employees_varray(elem));
    END LOOP;
  END;
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(903, 'BEGIN
  BEGIN
    MANAGE_EMPLOYEES.EMPLOYEES_BELOW(300000);

    FOR elem IN 1..MANAGE_EMPLOYEES.employees_varray.count LOOP
      DOPL(elem || '': '' || MANAGE_EMPLOYEES.employees_varray(elem));
    END LOOP;
  END;
  BEGIN
    MANAGE_EMPLOYEES.EMPLOYEES_BELOW(300000);

    FOR elem IN 1..MANAGE_EMPLOYEES.employees_varray.count LOOP
      DOPL(elem || '': '' || MANAGE_EMPLOYEES.employees_varray(elem));
    END LOOP;
  END;
  BEGIN
    MANAGE_EMPLOYEES.EMPLOYEES_BELOW(300000);

    FOR elem IN 1..MANAGE_EMPLOYEES.employees_varray.count LOOP
      DOPL(elem || '': '' || MANAGE_EMPLOYEES.employees_varray(elem));
    END LOOP;
  END;
END;/');
END;

-- 904.
CREATE OR REPLACE PACKAGE manage_employees AS
  PRAGMA SERIALLY_REUSABLE;

  PROCEDURE employees_below(salary IN HR.EMPLOYEES.SALARY%TYPE);

  TYPE emp_varr IS VARRAY (10) OF VARCHAR2(55);
  employees_varray emp_varr;

END manage_employees;


CREATE OR REPLACE PACKAGE BODY manage_employees AS
  PRAGMA SERIALLY_REUSABLE;

  CURSOR c1(fizu IN HR.EMPLOYEES.SALARY%TYPE) IS
    SELECT FIRST_NAME || ' ' || LAST_NAME as name
    FROM HR.EMPLOYEES
    WHERE SALARY < fizu;

  PROCEDURE employees_below(salary IN HR.EMPLOYEES.SALARY%TYPE) IS

    BEGIN
      IF (NOT c1%ISOPEN)
      THEN
        OPEN c1(salary);
      END IF;

      FETCH c1 BULK COLLECT INTO employees_varray LIMIT 10;

      IF (c1%NOTFOUND)
      THEN
        CLOSE c1;
        OPEN c1(salary);
      END IF;
    END employees_below;

END manage_employees;


BEGIN
  MANAGE_EMPLOYEES.EMPLOYEES_BELOW(300000);

  FOR elem IN 1..MANAGE_EMPLOYEES.employees_varray.count LOOP
    DOPL(elem || ': ' || MANAGE_EMPLOYEES.employees_varray(elem));
  END LOOP;
END;


BEGIN
  HDBMS18.MEGOLDAS_FELTOLT(904, 'CREATE OR REPLACE PACKAGE manage_employees AS
  PRAGMA SERIALLY_REUSABLE;

  PROCEDURE employees_below(salary IN HR.EMPLOYEES.SALARY%TYPE);

  TYPE emp_varr IS VARRAY (10) OF VARCHAR2(55);
  employees_varray emp_varr;

END manage_employees;
/

CREATE OR REPLACE PACKAGE BODY manage_employees AS
  PRAGMA SERIALLY_REUSABLE;

  CURSOR c1(fizu IN HR.EMPLOYEES.SALARY%TYPE) IS
    SELECT FIRST_NAME || '' '' || LAST_NAME as name
    FROM HR.EMPLOYEES
    WHERE SALARY < fizu;

  PROCEDURE employees_below(salary IN HR.EMPLOYEES.SALARY%TYPE) IS

    BEGIN
      IF (NOT c1%ISOPEN)
      THEN
        OPEN c1(salary);
      END IF;

      FETCH c1 BULK COLLECT INTO employees_varray LIMIT 10;

      IF (c1%NOTFOUND)
      THEN
        CLOSE c1;
        OPEN c1(salary);
      END IF;
    END employees_below;

END manage_employees;
/

BEGIN
  MANAGE_EMPLOYEES.EMPLOYEES_BELOW(300000);

  FOR elem IN 1..MANAGE_EMPLOYEES.employees_varray.count LOOP
    DOPL(elem || '': '' || MANAGE_EMPLOYEES.employees_varray(elem));
  END LOOP;
END;/');
END;