create or replace package package_adminActions as
    procedure changeUserRole(userId in integer, roleId in integer);
    procedure changeKartAvailability(kartId in integer, availability in number); 
end package_adminActions;

CREATE OR REPLACE
PACKAGE BODY PACKAGE_ADMINACTIONS AS
  
  procedure changeUserRole(userId in integer, roleId in integer) AS
  
  userNotFoundException exception;
  roleNotFoundExceptiom exception;
  
  roleRef ref t_role;
  roleNameTmp varchar2(15);
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isUserFound(userId)) then
        raise userNotFoundException;
    elsif (not PACKAGE_CHECKINGRECORDEXIST.isRoleFound(roleId)) then
        raise roleNotFoundExceptiom;
    else 
        select ref(roleRefTmp) into roleRef from role roleRefTmp where roleRefTmp.id = roleId;
        update usr set role = roleRef;
        select role.name into roleNameTmp from role where role.id = roleId;
        DBMS_OUTPUT.PUT_LINE('Zmieniono role na role: ' || roleNameTmp);
    end if;
  EXCEPTION
    when userNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono uzytkownika o podanym ID');
    when roleNotFoundExceptiom then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono roli o podanym ID');
  END changeUserRole;

  procedure changeKartAvailability(kartId in integer, availability in number) AS
  BEGIN
    -- TODO: Implementation required for procedure PACKAGE_ADMINACTIONS.changeKartAvailability
    NULL;
  END changeKartAvailability;

END PACKAGE_ADMINACTIONS;

set serveroutput on;

/*testowanie dzialania */

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
