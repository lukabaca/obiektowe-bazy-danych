create or replace package package_adminActions as
    procedure changeUserRole(userId in integer, roleId in integer);
    procedure changeKartAvailability(kartId in integer, kartAvailability in number); 
    
    userNotFoundException exception;
    roleNotFoundExceptiom exception;
    kartNotFoundException exception;
    
    
end package_adminActions;

CREATE OR REPLACE
PACKAGE BODY PACKAGE_ADMINACTIONS AS
  
  procedure changeUserRole(userId in integer, roleId in integer) AS
  
  roleRef ref t_role;
  roleNameTmp varchar2(15);
  usrEditedName varchar2(40);
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isUserFound(userId)) then
        raise userNotFoundException;
    elsif (not PACKAGE_CHECKINGRECORDEXIST.isRoleFound(roleId)) then
        raise roleNotFoundExceptiom;
    else 
        select ref(roleRefTmp) into roleRef from role roleRefTmp where roleRefTmp.id = roleId;
        update usr set role = roleRef
        where usr.id = userId;
        select role.name into roleNameTmp from role where role.id = roleId;
        select usr.name into usrEditedName from usr where usr.id = userId;
        DBMS_OUTPUT.PUT_LINE('Zmieniono role uzytkownikowi: ' || usrEditedName || ' na role: ' || roleNameTmp);
    end if;
  EXCEPTION
    when userNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono uzytkownika o podanym ID');
    when roleNotFoundExceptiom then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono roli o podanym ID');
  END changeUserRole;

  procedure changeKartAvailability(kartId in integer, kartAvailability in number) AS
  kartEditedName varchar2(30);
  
  kartAvailabiltyName varchar2(20);
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isKartFound(kartId)) then
        raise kartNotFoundException;
    else
        update kart set availability = kartAvailability where kart.id = kartId;
        select k.name into kartEditedName from kart k where k.id = kartId;
        if kartAvailability = 1 then
            kartAvailabiltyName:= 'DostÍpny';
        else
            kartAvailabiltyName:= 'NiedostÍpny';
        end if;
        --DBMS_OUTPUT.PUT_LINE('Zmienio dostepnosc dla gokartu: ' || kartEditedName || ' na dostÍpnosc: ' ||
        --kartAvailabiltyName);    
    end if;
   EXCEPTION
       when kartNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono gokartu o podanym ID');    
  END changeKartAvailability;

END PACKAGE_ADMINACTIONS;

/*-----------------------------------------------------*/
/*wyzwalaczae (triggery) */
create or replace trigger kart_availability_update
before update on kart for each row
declare 
    oldAvailability number;
    newAvailability number;
    
    oldAvailName varchar2(15);
    newAvailName varchar2(15);
    kartNameTmp varchar2(30);
begin
    kartNameTmp:= :old.name;
    oldAvailability:= :old.availability;
    newAvailability:= :new.availability;
    
    if oldAvailability = 1 then
        oldAvailName:= 'DostÍpny';
    else
        oldAvailName:= 'NiedostÍpny';
    end if;
        
    if newAvailability = 1 then
        newAvailName:= 'DostÍpny';
    else
        newAvailName:= 'NiedostÍpny';
    end if;
    DBMS_OUTPUT.PUT_LINE('Zmienio dostepnosc dla gokartu: ' || kartNameTmp || ' z: ' || oldAvailName
    || ' na: ' ||newAvailName);    
end;

/*-----------------------------------------------------*/

/*testowanie dzialania */
set serveroutput on;

/*zmiana roli uzytkownika */
DECLARE
  USERID NUMBER;
  ROLEID NUMBER;
BEGIN
  USERID := 1;
  ROLEID := 1;

  PACKAGE_ADMINACTIONS.CHANGEUSERROLE(
    USERID => USERID,
    ROLEID => ROLEID
  );
--rollback; 
END;

/*zmiana dostepnosci gokartu */
DECLARE
  KARTID NUMBER;
  KARTAVAILABILITY NUMBER;
BEGIN
  KARTID := 1;
  KARTAVAILABILITY := 0;

  PACKAGE_ADMINACTIONS.CHANGEKARTAVAILABILITY(
    KARTID => KARTID,
    KARTAVAILABILITY => KARTAVAILABILITY
  );
--rollback; 
END;

commit;