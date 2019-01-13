create or replace package package_addRecord as

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
  END addContact;

  PROCEDURE addRole(roleId in integer, name in varchar2) AS
  BEGIN
    insert into role values(roleId, name);
  END addRole;

 PROCEDURE addUser(userId in integer, name in varchar2, surname in varchar2, birthDate in date, pesel in varchar2,
    document_id in varchar2, contactId in integer, roleId in integer, recordingCollection in k_recording) AS
  BEGIN
    insert into usr select userId, name, surname, birthDate, 
    pesel, document_id, ref(contactRef), ref(rolRef), recordingCollection from role rolRef, contact contactRef 
    where rolRef.id = roleId and contactRef.id = contactId;
  END addUser;
  
   PROCEDURE addReservation(reservationId in integer, userId in integer, startDate in date, endDate in date) AS
  BEGIN
    insert into reservation select reservationId, ref(usrRef), startDate, endDate
    from usr usrRef where usrRef.id = userId;
  END addReservation;

  PROCEDURE addKart(kartId in integer, availability number, prize in number, name in varchar2, descripiton in varchar2) AS
  BEGIN
   insert into kart values(kartId, availability, prize, name, descripiton);
  END addKart;


  PROCEDURE addReservationKart(reservationId in integer, kartId in integer) AS
  BEGIN
    insert into reservationKart select 
    ref(reserRef), ref(kartRef) from reservation reserRef, kart kartRef
    where reserRef.id = reservationId and kartRef.id = kartId;
  END addReservationKart;


  PROCEDURE addLap(lapId in integer, userId in integer, kartId in integer, averageSpeed in number, lapDate in date,
    lapMinute in integer, lapSecond in integer, lapMilisecond in integer) AS
  BEGIN
    insert into lap select lapId, ref(usrRef), ref(kartRef),
    averageSpeed, lapDate, lapMinute, lapSecond, lapMilisecond from usr usrRef, kart kartRef
    where usrRef.id = userId and kartRef.id = kartId;
  END addLap;
  
END PACKAGE_ADDRECORD;

/*---------------------------------------------------*/
/*testowanie dzialania */
set SERVEROUTPUT ON;