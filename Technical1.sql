--TECHINCAL 1

--PART 1
--#1
--To find the number of airports from the countries table for a supplied country_name. 
--Based on this number, display a customized message as follows:
DECLARE
    v_country_name  countries.country_name%TYPE := 'United States of America';
    v_airports      countries.airports%TYPE;
BEGIN
    SELECT
        airports
    INTO v_airports
    FROM
        countries
    WHERE
        country_name = v_country_name;

    CASE
        WHEN v_airports BETWEEN 0 AND 100 THEN
            dbms_output.put_line('There are 100 or fewer airports ' || v_country_name);
        WHEN v_airports BETWEEN 101 AND 1000 THEN
            dbms_output.put_line('There are between 101 and 1,000 airpots ' || v_country_name);
        WHEN v_airports BETWEEN 1001 AND 10000 THEN
            dbms_output.put_line('There are between 1,001 and 10,000 airpots ' || v_country_name);
        WHEN v_airports > 10000 THEN
            dbms_output.put_line('There are more than 10,000 airpots ' || v_country_name);
        ELSE
            dbms_output.put_line('The Number of airports is not available for this country ' || v_country_name);
    END CASE;

END;



----PART 1
--#2
--Using any of the PL/SQL looping statement, write a PL/SQL block to display the country_id and country_name values 
--from the WF_COUNTRIES table for country_id whose values range from 51
--through 55. Test your variable to see when it reaches 55. 
--EXIT the loop after you have displayed the 5 countries.
DECLARE
    v_id    countries.country_id%TYPE := 51;
    v_name  countries.country_name%TYPE;
BEGIN
    WHILE v_id <= 55 LOOP
        SELECT
            country_id,
            country_name
        INTO
            v_id,
            v_name
        FROM
            countries
        WHERE
            country_id = v_id;

        dbms_output.put_line(v_id
                             || ' '
                             || v_name);
        v_id := v_id + 1;
    END LOOP;
END;





--PART 2
--Create a PL/SQL block that fetches and displays the six employees with the highest salary.
--For each of these employees, display the first name, last name, job id, and salary.
--Order your output so that the employee with the highest salary is displayed first. 
--Use %ROWTYPE and the explicit cursor attribute %ROWCOUNT.
DECLARE
    CURSOR emp_cursor IS
    SELECT
        first_name,
        last_name,
        job_id,
        salary
    FROM
        employees
    ORDER BY
        salary DESC;

    v_emp_record emp_cursor%rowtype;
BEGIN
    OPEN emp_cursor;
    LOOP
        FETCH emp_cursor INTO v_emp_record;
        EXIT WHEN emp_cursor%rowcount > 6;
        dbms_output.put_line('First Name: '
                             || v_emp_record.first_name
                             || chr(10)
                             || 'Last Name: '
                             || v_emp_record.last_name
                             || chr(10)
                             || 'Job ID: '
                             || v_emp_record.job_id
                             || chr(10)
                             || 'Salary: '
                             || v_emp_record.salary
                             || chr(10));

    END LOOP;

    CLOSE emp_cursor;
END;





--PART 3 EXPLICIT CURSOR
--Write a PL/SQL block to read through rows in the countries table for all countries in region 5 (South America region).
--Country name must be entered by the user. 
--For each selected country, display the country_name,national_holiday_date, and national_holiday_name.
-- Use a record structure (user defined) to hold all the columns selected from the countries table.
DECLARE
    CURSOR countries_cursor (
        p_country_name VARCHAR2
    ) IS
    SELECT
        country_name,
        national_holiday_date,
        national_holiday_name
    FROM
        countries
    WHERE
            region_id = 5
        AND country_name = p_country_name;

    TYPE countries_rec IS RECORD (   --user defined record
        country_name  countries.country_name%TYPE,
        nh_date       countries.national_holiday_date%TYPE,
        nh_name       countries.national_holiday_name%TYPE
    );
    v_countries_rec countries_rec;
    no_match EXCEPTION;
BEGIN
    OPEN countries_cursor('&p_country_name'); --prompts user for input
    LOOP
        FETCH countries_cursor INTO v_countries_rec;
        
        --checks if input has match
        IF ( countries_cursor%rowcount = 0 ) THEN
            RAISE no_match;
        END IF;
        EXIT WHEN countries_cursor%notfound;
        dbms_output.put_line('Country: '
                             || v_countries_rec.country_name
                             || chr(10)
                             || 'National holiday date:  '
                             || v_countries_rec.nh_date
                             || chr(10)
                             || 'National holiday name:  '
                             || v_countries_rec.nh_name);

    END LOOP;

    CLOSE countries_cursor;
EXCEPTION
    WHEN no_match THEN
        dbms_output.put_line('Country not found in Region 5');
END;





--part 4
--A
--Add an exception handler to the following code to trap the following predefined Oracle Server 
--errors: NO_DATA_FOUND, TOO_MANY_ROWS, and DUP_VAL_ON_INDEX. 
DECLARE
    v_language_id    languages.language_id%TYPE;
    v_language_name  languages.language_name%TYPE;
BEGIN
    SELECT
        language_id,
        language_name
    INTO
        v_language_id,
        v_language_name
    FROM
        languages
    WHERE
        lower(language_name) LIKE '%a'; -- for example 'ab%'
    INSERT INTO languages (
        language_id,
        language_name
    ) VALUES (
        80,
        NULL
    );

EXCEPTION
    WHEN no_data_found THEN
        dbms_output.put_line('No Data Found');
    WHEN too_many_rows THEN
        dbms_output.put_line('Many Rows, Error was handled');
    WHEN dup_val_on_index THEN
        dbms_output.put_line('Dup Val on index, Error was handled');
END;




--B.
/*ORA-01400 cannot insert NULL into ("EDDZ99"."LANGUAGES"."LANGUAGE_NAME") 
ORA-06512 at line 7
01400. 0000 - "Cannot insert NULL into(%s)"
Cause: An attempt was made to insert NULL into previously listed objects
These objects cannot accept NULL Values

The language table does not accept null value as its language_name so it returns an undefined error */




--C.
--Now (keeping the substring as “al”), add a non_predefined exception handler to trap then
--encountered oracle exception code. Rerun the code and explain the result.
DECLARE
    v_language_id    languages.language_id%TYPE;
    v_language_name  languages.language_name%TYPE;
    cannot_insert_null EXCEPTION;
    PRAGMA exception_init ( cannot_insert_null, -01400 );
BEGIN
    SELECT
        language_id,
        language_name
    INTO
        v_language_id,
        v_language_name
    FROM
        languages
    WHERE
        lower(language_name) LIKE 'al%'; -- for example 'ab%' 
    INSERT INTO languages (
        language_id,
        language_name
    ) VALUES (
        80,
        NULL
    );

EXCEPTION
    WHEN too_many_rows THEN
        dbms_output.put_line('Too many rows');
    WHEN dup_val_on_index THEN
        dbms_output.put_line('Duplicate value');
    WHEN no_data_found THEN
        dbms_output.put_line('No data found');
    WHEN cannot_insert_null THEN
        dbms_output.put_line('Failed to insert.');
END;

--It now outputs "failed to insert" in dbms output because we now trapped the undefined exception