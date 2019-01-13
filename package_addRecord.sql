create or replace package package_addRecord as

    contactNotFoundException exception;
    roleNotFoundException exception;
    userNotFoundException exception;
    reservationNotFoundException exception;
    kartNotFoundException exception;

    PROCEDURE addContact(contactId in integer, telephoneNumber in varchar2, email in varchar2);
    PROCEDURE addRole(roleId in integer, name in varchar2);
    PROCEDURE addUser(userId in integer, name in varchar2, surname in varchar2, birthDate in date, pesel in varchar2,
    document_id in varchar2, contactId in integer, roleId in integer, recordingCollection in k_recording);
    PROCEDURE addReservation(reservationId in integer, userId in integer, startDate in date, endDate in date);
    PROCEDURE addKart(kartId in integer, availability number, prize in number, name in varchar2, descripiton in varchar2);
    PROCEDURE addReservationKart(reservationId in integer, kartId in integer);
    PROCEDURE addLap(lapId in integer, userId in integer, kartId in integer, averageSpeed in number, lapDate in date,
    lapMinute in integer, lapSecond in integer, lapMilisecond in integer);

end package_addRecord;

CREATE OR REPLACE
PACKAGE BODY PACKAGE_ADDRECORD AS

PROCEDURE addContact(contactId in integer, telephoneNumber in varchar2, email in varchar2) AS
  BEGIN
    insert into contact values(contactId, telephoneNumber, email);
    DBMS_OUTPUT.PUT_LINE('Dodano dane kontakowe: ' || contactId || ' ' || telephoneNumber || ' ' || email);
  END addContact;

  PROCEDURE addRole(roleId in integer, name in varchar2) AS
  BEGIN
    insert into role values(roleId, name);
    DBMS_OUTPUT.PUT_LINE('Dodano role: ' || roleId || ' ' || name);
  END addRole;

 PROCEDURE addUser(userId in integer, name in varchar2, surname in varchar2, birthDate in date, pesel in varchar2,
    document_id in varchar2, contactId in integer, roleId in integer, recordingCollection in k_recording) AS
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isContactFound(contactId)) then
        raise contactNotFoundException;
    elsif (not PACKAGE_CHECKINGRECORDEXIST.isRoleFound(roleId)) then
        raise roleNotFoundException;
    else
        insert into usr select userId, name, surname, birthDate, 
        pesel, document_id, ref(contactRef), ref(rolRef), recordingCollection from role rolRef, contact contactRef 
        where rolRef.id = roleId and contactRef.id = contactId;
        DBMS_OUTPUT.PUT_LINE('Poprawnie dodano uzytkownika');
    end if;
    EXCEPTION
    when contactNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono danych kontakowych o podanym ID');
    when roleNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono roli o podanym ID');
  END addUser;
  
   PROCEDURE addReservation(reservationId in integer, userId in integer, startDate in date, endDate in date) AS
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isUserFound(userId)) then
        raise userNotFoundException;
    else    
        insert into reservation select reservationId, ref(usrRef), startDate, endDate
        from usr usrRef where usrRef.id = userId;
        DBMS_OUTPUT.PUT_LINE('Poprawnie dodano rezerwacje');
    end if;
    EXCEPTION
    when userNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono uzytkownika o podanym ID');
  END addReservation;

  PROCEDURE addKart(kartId in integer, availability number, prize in number, name in varchar2, descripiton in varchar2) AS
  availabilityName varchar2(15);
  BEGIN
   if availability = 0 then
    availabilityName:= 'NiedostÍpny';
   else 
    availabilityName:= 'DostÍpny';
   end if;
   insert into kart values(kartId, availability, prize, name, descripiton);
   DBMS_OUTPUT.PUT_LINE('Dodano gokart: ' || kartId || ' ' || availabilityName || ' ' || prize || ' ' || name || ' ' || descripiton );
  END addKart;


  PROCEDURE addReservationKart(reservationId in integer, kartId in integer) AS
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isReservationFound(reservationId)) then
        raise reservationNotFoundException;
    elsif (not PACKAGE_CHECKINGRECORDEXIST.isKartFound(kartId)) then
        raise kartNotFoundException;
    else
        insert into reservationKart select 
        ref(reserRef), ref(kartRef) from reservation reserRef, kart kartRef
        where reserRef.id = reservationId and kartRef.id = kartId;
        DBMS_OUTPUT.PUT_LINE('Dodano poprawnie rekordy');
    end if;
    EXCEPTION
    when reservationNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono rezerwacji o podanym ID');
    when kartNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono gokartu o podanym ID');    
  END addReservationKart;


  PROCEDURE addLap(lapId in integer, userId in integer, kartId in integer, averageSpeed in number, lapDate in date,
    lapMinute in integer, lapSecond in integer, lapMilisecond in integer) AS
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isUserFound(userId)) then
        raise userNotFoundException;
    elsif (not PACKAGE_CHECKINGRECORDEXIST.isKartFound(kartId)) then
        raise kartNotFoundException;    
    else    
        insert into lap select lapId, ref(usrRef), ref(kartRef),
        averageSpeed, lapDate, lapMinute, lapSecond, lapMilisecond from usr usrRef, kart kartRef
        where usrRef.id = userId and kartRef.id = kartId;
        DBMS_OUTPUT.PUT_LINE('Poprawnie dodano okrazenie');
    end if;    
    EXCEPTION
    when userNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono uzytkownika o podanym ID');
    when kartNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono gokartu o podanym ID');   
  END addLap;
  
END PACKAGE_ADDRECORD;

/*---------------------------------------------------*/
/*testowanie dzialania */
set SERVEROUTPUT ON;

/*dodawanie danych kontaktowych */

DECLARE
  CONTACTID NUMBER;
  TELEPHONENUMBER VARCHAR2(200);
  EMAIL VARCHAR2(200);
BEGIN
  CONTACTID := contactIdSeq.nextval;
  TELEPHONENUMBER := '505-606-707';
  EMAIL := 'b@gmail.com';

  PACKAGE_ADDRECORD.ADDCONTACT(
    CONTACTID => CONTACTID,
    TELEPHONENUMBER => TELEPHONENUMBER,
    EMAIL => EMAIL
  );
--rollback; 
END;


/*dodawanie gokartu */

DECLARE
  KARTID NUMBER;
  AVAILABILITY NUMBER;
  PRIZE NUMBER;
  NAME VARCHAR2(200);
  DESCRIPITON VARCHAR2(200);
BEGIN
  KARTID := kartIdSeq.nextval;
  AVAILABILITY := 1;
  PRIZE := 20;
  NAME := 'gt20';
  DESCRIPITON := NULL;

  PACKAGE_ADDRECORD.ADDKART(
    KARTID => KARTID,
    AVAILABILITY => AVAILABILITY,
    PRIZE => PRIZE,
    NAME => NAME,
    DESCRIPITON => DESCRIPITON
  );
--rollback; 
END;

/* dodawanie roli */
DECLARE
  ROLEID NUMBER;
  NAME VARCHAR2(200);
BEGIN
  ROLEID := roleIdSeq.nextval;
  NAME := 'ROLE_TEST';

  PACKAGE_ADDRECORD.ADDROLE(
    ROLEID => ROLEID,
    NAME => NAME
  );
--rollback; 
END;

/*dodawanie uzytkownika */
DECLARE
  USERID NUMBER;
  NAME VARCHAR2(200);
  SURNAME VARCHAR2(200);
  BIRTHDATE DATE;
  PESEL VARCHAR2(200);
  DOCUMENT_ID VARCHAR2(200);
  CONTACTID NUMBER;
  ROLEID NUMBER;
  RECORDINGCOLLECTION LUKA.K_RECORDING;
BEGIN
  USERID := userIdSeq.nextval;
  NAME := 'Jan';
  SURNAME := 'Kowalski';
  BIRTHDATE := to_date('1970-01-22', 'YYYY-MM-DD');
  PESEL := '70053045678';
  DOCUMENT_ID := 'asd123456';
  CONTACTID := 3;
  ROLEID := 1;
  -- Modify the code to initialize the variable
  RECORDINGCOLLECTION := NULL;

  PACKAGE_ADDRECORD.ADDUSER(
    USERID => USERID,
    NAME => NAME,
    SURNAME => SURNAME,
    BIRTHDATE => BIRTHDATE,
    PESEL => PESEL,
    DOCUMENT_ID => DOCUMENT_ID,
    CONTACTID => CONTACTID,
    ROLEID => ROLEID,
    RECORDINGCOLLECTION => RECORDINGCOLLECTION
  );
--rollback; 
END;


/*dodawanie rezerwacji */
DECLARE
  RESERVATIONID NUMBER;
  USERID NUMBER;
  STARTDATE DATE;
  ENDDATE DATE;
BEGIN
  RESERVATIONID := reservationIdSeq.nextval;
  USERID := 1;
  STARTDATE := to_date('2019-02-01 17:20:00', 'YYYY-MM-DD HH24:MI:SS');
  ENDDATE := to_date('2019-02-01 18:20:00', 'YYYY-MM-DD HH24:MI:SS');

  PACKAGE_ADDRECORD.ADDRESERVATION(
    RESERVATIONID => RESERVATIONID,
    USERID => USERID,
    STARTDATE => STARTDATE,
    ENDDATE => ENDDATE
  );
--rollback; 
END;

/*dodawanie rezerwacji i gokartu do tabeli posredniczacej */
DECLARE
  RESERVATIONID NUMBER;
  KARTID NUMBER;
BEGIN
  RESERVATIONID := 5;
  KARTID := 1;

  PACKAGE_ADDRECORD.ADDRESERVATIONKART(
    RESERVATIONID => RESERVATIONID,
    KARTID => KARTID
  );
--rollback; 
END;

/*dodawanie okrazenia */

DECLARE
  LAPID NUMBER;
  USERID NUMBER;
  KARTID NUMBER;
  AVERAGESPEED NUMBER;
  LAPDATE DATE;
  LAPMINUTE NUMBER;
  LAPSECOND NUMBER;
  LAPMILISECOND NUMBER;
BEGIN
  LAPID := lapIdSeq.nextval;
  USERID := 1;
  KARTID := 1;
  AVERAGESPEED := 55;
  LAPDATE := to_date('2019-01-01 15:00:00', 'YYYY-MM-DD HH24:MI:SS');
  LAPMINUTE := 0;
  LAPSECOND := 55;
  LAPMILISECOND := 65;

  PACKAGE_ADDRECORD.ADDLAP(
    LAPID => LAPID,
    USERID => USERID,
    KARTID => KARTID,
    AVERAGESPEED => AVERAGESPEED,
    LAPDATE => LAPDATE,
    LAPMINUTE => LAPMINUTE,
    LAPSECOND => LAPSECOND,
    LAPMILISECOND => LAPMILISECOND
  );
--rollback; 
END;
