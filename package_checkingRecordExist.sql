create or replace package package_CheckingRecordExist as

    FUNCTION isContactFound(contactId in integer) RETURN BOOLEAN;
    FUNCTION isUserFound(userId in integer) RETURN BOOLEAN;
    FUNCTION isRoleFound(roleId in integer)  RETURN BOOLEAN;
    FUNCTION isReservationFound(reservationId in integer) RETURN BOOLEAN;
    FUNCTION isKartFound(kartId in integer) RETURN BOOLEAN;
    FUNCTION isLapFound(lapId in integer) RETURN BOOLEAN;
    
end package_CheckingRecordExist;

CREATE OR REPLACE
PACKAGE BODY PACKAGE_CHECKINGRECORDEXIST AS

  FUNCTION isContactFound(contactId in integer) RETURN BOOLEAN as
  numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from contact where contact.id = contactId;
    if numberOfRecordsFound = 1 then
        return true;
    else
        return false;
    end if;
  END isContactFound;


 FUNCTION isUserFound(userId in integer) RETURN BOOLEAN as
  numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from usr where usr.id = userId;
    if numberOfRecordsFound = 1 then
        return true;
    else
        return false;
    end if;
  END isUserFound;

  FUNCTION isRoleFound(roleId in integer)  RETURN BOOLEAN as
  numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from role where role.id = roleId;
    if numberOfRecordsFound = 1 then
        return true;
    else
        return false;
    end if;
  END isRoleFound;

  FUNCTION isReservationFound(reservationId in integer) RETURN BOOLEAN as
   numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from reservation where reservation.id = reservationId;
    if numberOfRecordsFound = 1 then
        return true;
    else
        return false;
    end if;
  END isReservationFound;

  FUNCTION isKartFound(kartId in integer) RETURN BOOLEAN as
  numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from kart where kart.id = kartId;
    if numberOfRecordsFound = 1 then
        return true;
    else
        return false;
    end if;
  END isKartFound;

   FUNCTION isLapFound(lapId in integer) RETURN BOOLEAN as
   numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from lap where lap.id = lapId;
    if numberOfRecordsFound = 1 then
        return true;
    else
        return false;
    end if;
  END isLapFound;
  
END PACKAGE_CHECKINGRECORDEXIST;

/*---------------------------------------------------*/
/*testowanie dzialania */
set SERVEROUTPUT ON;

/*sprawdzenie czy istnieje kontakt o podanym ID */
DECLARE
  CONTACTID NUMBER;
  v_Return BOOLEAN;
BEGIN
  CONTACTID := 1;

  v_Return := PACKAGE_CHECKINGRECORDEXIST.ISCONTACTFOUND(
    CONTACTID => CONTACTID
  );
  
IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;
  --:v_Return := v_Return;
--rollback; 
END;

/*sprawdzenie czy istnieje rola o podanym ID */
DECLARE
  ROLEID NUMBER;
  v_Return BOOLEAN;
BEGIN
  ROLEID := 2;

  v_Return := PACKAGE_CHECKINGRECORDEXIST.ISROLEFOUND(
    ROLEID => ROLEID
  );

IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;

  --:v_Return := v_Return;
--rollback; 
END;

/*sprawdzenie czy istnieje uzytkownik o podanym ID */
DECLARE
  USERID NUMBER;
  v_Return BOOLEAN;
BEGIN
  USERID := 3;

  v_Return := PACKAGE_CHECKINGRECORDEXIST.ISUSERFOUND(
    USERID => USERID
  );
IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;

  --v_Return := v_Return;
--rollback; 
END;

/*sprawdzenie czy istnieje gokart o podanym ID */
DECLARE
  KARTID NUMBER;
  v_Return BOOLEAN;
BEGIN
  KARTID := 1;

  v_Return := PACKAGE_CHECKINGRECORDEXIST.ISKARTFOUND(
    KARTID => KARTID
  );
  
IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;
  --:v_Return := v_Return;
--rollback; 
END;

/*sprawdzenie czy istnieje okrazenie o podanym ID */
DECLARE
  LAPID NUMBER;
  v_Return BOOLEAN;
BEGIN
  LAPID := 1;

  v_Return := PACKAGE_CHECKINGRECORDEXIST.ISLAPFOUND(
    LAPID => LAPID
  );
  
IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;
  --:v_Return := v_Return;
--rollback; 
END;

/*sprawdzenie czy istnieje rezerwacje o podanym ID */
DECLARE
  RESERVATIONID NUMBER;
  v_Return BOOLEAN;
BEGIN
  RESERVATIONID := 1;

  v_Return := PACKAGE_CHECKINGRECORDEXIST.ISRESERVATIONFOUND(
    RESERVATIONID => RESERVATIONID
  );
 
IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;
  --:v_Return := v_Return;
--rollback; 
END;

