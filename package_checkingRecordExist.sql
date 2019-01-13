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