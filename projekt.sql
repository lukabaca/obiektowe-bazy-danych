/* typ reprezentujacy dane kontaktowe */
create or replace type t_contact as object (
    id integer,
    telephoneNumber varchar2(20),
    email varchar2(30)
);

/*typ reprezentujacy role */
create or replace type t_role as object (
    id integer,
    name varchar2(20)
);

/*typ reprezentujacy nagranie */
create or replace type t_recording as object (
    id integer,
    recordingLink varchar2(255),
    title varchar2(30)
);

/*kolekcja typow t_recording */
create type k_recording as table of t_recording;

/* typ reprezentujacy uzytkownika */
create or replace type t_user as object (
    id integer,
    name varchar2(30),
    surname varchar2(30),
    birthDate date,
    pesel varchar2(11),
    document_id varchar2(9),
    contact ref t_contact,
    role ref t_role,
    recordings k_recording
);

/*typ reprezentujacy rezerwacje */
create or replace type t_reservation as object (
    id integer,
    usr REF t_user,
    startDate date,
    endDate date,
    cost number(10,2)
);

/*typ reprezentujacy gokart */
create or replace type t_kart as object (
    id integer,
    availability number(1,0),
    prize number,
    name varchar2(40),
    description varchar2(300)
);

/*typ reprezentujacy poœredniczenie zawierajace referencje gokartu i rezerwacji */
create or replace type t_reservation_kart as object (
    reservation REF t_reservation,
    kart REF t_kart
);

/*typ reprezentujacy okrazenie */
create or replace type t_lap as object (
    id integer,
    usr REF t_user,
    kart REF t_kart,
    averageSpeed number,
    lapDate date,
    minute integer,
    second integer,
    milisecond integer
);

/*typ przechowujacy tablice id gokartów */
create type kartIdTab is varray (10) of integer;

/*chwilowe usuwanie */
drop type t_contact force;
drop type t_role force;
drop type t_recording force;
drop type k_recording force;
drop type t_user force;
drop type t_reservation force;
drop type t_reservation_kart force;
drop type t_kart force;
drop type t_lap force;
drop type kartIdTab force;

/*---------------------------------------------------*/

/*tworzenie tabel na podstawie typów obiektowych */
create table usr of t_user
nested table recordings store as recording;
create table contact of t_contact;
create table role of t_role;
create table reservation of t_reservation;
create table reservationKart of t_reservation_kart;
create table kart of t_kart;
create table lap of t_lap;

drop table usr;
drop table contact;
drop table role;
drop table reservation;
drop table reservationKart;
drop table kart;
drop table lap;

delete from role;
delete from contact;
delete from usr;

/*---------------------------------------------------*/

/*tworzenie sekwencji do generowania id */
drop sequence userId;
drop sequence reservationId;
drop sequence kartId;
drop sequence kartTechnicalDataId;
drop sequence lapId;
drop sequence recordingId;

create sequence userId minvalue 1 start with 1;
create sequence reservationId minvalue 1 start with 1;
create sequence kartId minvalue 1 start with 1;
create sequence kartTechnicalDataId minvalue 1 start with 1;
create sequence lapId minvalue 1 start with 1;
create sequence recordingId minvalue 1 start with 1;

/*---------------------------------------------------*/

/* inserty */

/* wstawianie rekordów do tabeli role */
insert into role values(1, 'ROLE_USER');
insert into role values(2, 'ROLE_ADMIN');

/*wstawianie rekordow do tabeli danych kontaktowych */
insert into contact values(1, 'jan@gmail.com', '505-303-404');
insert into contact values(2, 'olek@gmail.com', '404-555-666');

/*wstawianie rekordow do tabeli uzytkownik */
insert into usr select userId.nextval, 'Jan', 'Kowalski', to_date('1996-04-30', 'YYYY-MM-DD'), 
'1111', 'asd123', ref(contactRef), ref(rolRef), k_recording(t_recording(1, 'youtube.com', 'szybkie nagranie')) from role rolRef, contact contactRef 
where rolRef.id = 1 and contactRef.id = 1;

insert into usr select userId.nextval, 'Olek', 'Nowak', to_date('1970-01-22', 'YYYY-MM-DD'), 
'222', 'afd456', ref(contactRef), ref(rolRef),
k_recording(t_recording(1, 'youtube.com', 'szybkie nagranie'), t_recording(2, 'youtub2e.com', 'moje nagranie')) 
from role rolRef, contact contactRef 
where rolRef.id = 2 and contactRef.id = 2;

/* wstawianie rekordow do tabeli reservation */
insert into reservation select reservationId.nextval, ref(usrRef), to_date('2019-01-01 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 
to_date('2019-01-01 15:30:00', 'YY-MM-DD HH24:MI:SS'), 25
from usr usrRef where usrRef.id = 1;

insert into reservation select reservationId.nextval, ref(usrRef), to_date('2019-01-01 17:20:00', 'YYYY-MM-DD HH24:MI:SS'), 
to_date('2019-01-01 19:30:00', 'YY-MM-DD HH24:MI:SS'), 35
from usr usrRef where usrRef.id = 1;

/*wstawianie rekordow do tabeli kart */
insert into kart values(kartId.nextval, 1, 25, 'gt5', 'silnik m52b20');
insert into kart values(kartId.nextval, 0, 40, 'gt6', 'silnik m52b28');
insert into kart values(kartId.nextval, 1, 25, 'gt7', 'silnik m54b25');

/*wstawianie rekordow do tabeli reservationKart */
insert into reservationKart select 
ref(reserRef), ref(kartRef) from reservation reserRef, kart kartRef
where reserRef.id = 1 and kartRef.id = 1;

insert into reservationKart select 
ref(reserRef), ref(kartRef) from reservation reserRef, kart kartRef
where reserRef.id = 1 and kartRef.id = 3;

/*wstawianie rekordów do tabeli lap */
insert into lap select lapId.nextval, ref(usrRef), ref(kartRef),
44.5, to_date('2019-01-30'), 1, 20, 55 from usr usrRef, kart kartRef
where usrRef.id = 1 and kartRef.id = 1;

insert into lap select lapId.nextval, ref(usrRef), ref(kartRef),
55, to_date('2019-01-12'), 0, 55, 24 from usr usrRef, kart kartRef
where usrRef.id = 1 and kartRef.id = 3;

/*---------------------------------------------------*/

/*selecty */

/*contact */
select * from contact;

/*role */
select * from role;

/*user */
select u.id, u.name, u.surname, u.birthdate, u.pesel, u.document_id, deref(contact).email, 
deref(contact).telephoneNumber, deref(role).name, r.recordingLink, r.title from usr u, 
table (u.recordings) r;

/*reservation */
select id, to_char(startDate, 'YYYY-MM-DD HH24:MI:SS'), to_char(endDate, 'YYYY-MM-DD HH24:MI:SS'), cost, deref(usr).name, deref(usr).surname from reservation;

/*kart */
select * from kart;

/*reservationKart */
select deref(reservation).id, deref(reservation).startDate,
deref(kart).name from reservationKart;

/*lap */
select id, deref(usr).name, deref(usr).surname, deref(kart).name, averageSpeed,
to_char(lapDate, 'YYYY-MM-DD'), minute, second, milisecond from lap;

/*---------------------------------------------------*/

/*tworzenie pakietów */

set SERVEROUTPUT ON;

create or replace package package_CheckingRecordExist as

    FUNCTION isContactFound RETURN BOOLEAN;
    FUNCTION isUserFound RETURN BOOLEAN;
    FUNCTION isRoleFound RETURN BOOLEAN;
    FUNCTION isReservationFound RETURN BOOLEAN;
    FUNCTION isKartFound RETURN BOOLEAN;
    FUNCTION isLapFound RETURN BOOLEAN;
    
end package_CheckingRecordExist;

CREATE OR REPLACE
PACKAGE BODY PACKAGE_CHECKINGRECORDEXIST AS

  FUNCTION isContactFound RETURN BOOLEAN AS
  numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from contact ;
    if numberOfRecordsFound > 0 then
        return true;
    else
        return false;
    end if;
  END isContactFound;


  FUNCTION isUserFound RETURN BOOLEAN AS
  numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from usr ;
    if numberOfRecordsFound > 0 then
        return true;
    else
        return false;
    end if;
  END isUserFound;

  FUNCTION isRoleFound RETURN BOOLEAN AS
  numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from role ;
    if numberOfRecordsFound > 0 then
        return true;
    else
        return false;
    end if;
  END isRoleFound;

  FUNCTION isReservationFound RETURN BOOLEAN AS
   numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from reservation ;
    if numberOfRecordsFound > 0 then
        return true;
    else
        return false;
    end if;
  END isReservationFound;

  FUNCTION isKartFound RETURN BOOLEAN AS
  numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from kart ;
    if numberOfRecordsFound > 0 then
        return true;
    else
        return false;
    end if;
  END isKartFound;

  FUNCTION isLapFound RETURN BOOLEAN AS
   numberOfRecordsFound number;
  BEGIN
    select count(id) into numberOfRecordsFound from lap ;
    if numberOfRecordsFound > 0 then
        return true;
    else
        return false;
    end if;
  END isLapFound;
  
END PACKAGE_CHECKINGRECORDEXIST;

commit;
/*---------------------------------------------------*/

create or replace package package_addRecord as
    PROCEDURE addContact(contactId in integer, telephoneNumber in varchar2, email in varchar2);
    PROCEDURE addRole(roleId in integer, name in varchar2);
    PROCEDURE addUser(userId in integer, name in varchar2, surname in varchar2, birthDate in date, pesel in varchar2,
    document_id in varchar2, contactId in integer, roleId in integer, recordingCollection in k_recording);
    PROCEDURE addReservation(reservationId in integer, userId in integer, startDate in date, endDate in date, 
    cost in number, byTimeReservationType in number, description in varchar2);
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
  
   PROCEDURE addReservation(reservationId in integer, userId in integer, startDate in date, endDate in date, 
    cost in number, byTimeReservationType in number, description in varchar2) AS
  BEGIN
    insert into reservation select reservationId, ref(usrRef), startDate, endDate, 
    cost, byTimeReservationType, description
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
create or replace package package_userActions as
    type kartRecord_type is ref cursor;
    type reservation_type is ref cursor;
    
    userNotFound exception;
    
    procedure getRecords(recordTypeCur in out kartRecord_type, recordType in integer);
    procedure getReservations(reservationTypeCur in out reservation_type, reservationType in integer);
    /*
    procedure getUserReservations(userId in integer);
    procedure getUserLaps(userId in integer);
    procedure getKartsInReservation(reservationId in integer);
    
    procedure getKarts;
    
    function isReservationValid(startDate in date, endDate in date) return boolean;
    procedure makeReservation(userId in integer, startDate in date, endDate in date, cost in number,
    byTimeReservationType in number, description in varchar2, kartIds kartIdTab);
    */
end package_userActions;


set SERVEROUTPUT ON;


select * from lap  where rownum > 0 order by minute asc, second asc, milisecond asc;
select sysdate from dual;

select abs(to_date('2019-01-12') - to_date('2019-01-15')) from dual;

select months_between(lap.lapDate, (select sysdate from dual)) from lap;