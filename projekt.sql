/*definicje typów obiektowych */

/* typ reprezentujacy dane kontaktowe u¿ytkownika */
create or replace type t_contact as object (
    id integer,
    telephoneNumber varchar2(20),
    email varchar2(30)
);
/
/*typ reprezentujacy role */
create or replace type t_role as object (
    id integer,
    name varchar2(20)
);
/
/*typ reprezentujacy nagranie */
create or replace type t_recording as object (
    id integer,
    recordingLink varchar2(255),
    title varchar2(30)
);
/
/*kolekcja nagrañ */
create type k_recording as table of t_recording;
/
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
/
/*typ reprezentujacy rezerwacje */
create or replace type t_reservation as object (
    id integer,
    usr REF t_user,
    startDate date,
    endDate date
);
/
/*typ reprezentujacy gokart */
create or replace type t_kart as object (
    id integer,
    availability number(1,0),
    prize number,
    name varchar2(40),
    description varchar2(300)
);
/
/*typ reprezentujacy poœredniczenie zawierajace referencje gokartu i rezerwacji */
create or replace type t_reservation_kart as object (
    reservation REF t_reservation,
    kart REF t_kart
);
/
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
/
/*typ przechowujacy tablice id gokartów */
create type kartIdTab is varray (10) of integer;
/
/*chwilowe usuwanie typów */
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
create table usr of t_user(
primary key (id)
) nested table recordings store as recording;
/
create table contact of t_contact(
    primary key (id)
);
/
create table role of t_role(
    primary key (id)
);
/
create table reservation of t_reservation(
    primary key (id)
);
/
create table reservationKart of t_reservation_kart;
/
create table kart of t_kart(
    primary key (id)
);
/
create table lap of t_lap(
    primary key (id)
);
/

/*usuwanie tabel */
drop table usr;
drop table contact;
drop table role;
drop table reservation;
drop table reservationKart;
drop table kart;
drop table lap;

/*usuwanie zawartosci tabel */
delete from role;
delete from contact;
delete from usr;
delete from reservation;
delete from lap;
delete from reservationKart;
delete from kart;

/*---------------------------------------------------*/

/*usuwanie sekwencji */
drop sequence contactIdSeq;
drop sequence userIdSeq;
drop sequence reservationIdSeq;
drop sequence kartIdSeq;
drop sequence lapIdSeq;
drop sequence recordingIdSeq;
drop sequence roleIdSeq;

/*tworzenie sekwencji do generowania id */
create sequence contactIdSeq minvalue 1 start with 1;
create sequence userIdSeq minvalue 1 start with 1;
create sequence reservationIdSeq minvalue 1 start with 1;
create sequence kartIdSeq minvalue 1 start with 1;
create sequence lapIdSeq minvalue 1 start with 1;
create sequence recordingIdSeq minvalue 1 start with 1;
create sequence roleIdSeq minvalue 1 start with 1;

/*---------------------------------------------------*/

/* inserty */

/* wstawianie rekordów do tabeli role */
insert into role values(roleIdSeq.nextval, 'ROLE_USER');
insert into role values(roleIdSeq.nextval, 'ROLE_ADMIN');

/*wstawianie rekordow do tabeli danych kontaktowych */
insert into contact values(contactIdSeq.nextval, '505-303-404', 'jan@gmail.com');
insert into contact values(contactIdSeq.nextval, '404-555-666', 'olek@gmail.com');

/*wstawianie rekordow do tabeli uzytkownik */
insert into usr select userIdSeq.nextval, 'Jan', 'Kowalski', to_date('1996-04-30', 'YYYY-MM-DD'), 
'1111', 'asd123', ref(contactRef), ref(rolRef), k_recording(t_recording(recordingIdSeq.nextval, 'youtubeaa.com', 'nag1'), 
t_recording(recordingIdSeq.nextval, 'youtubebbb.com', 'nag2')) from role rolRef, contact contactRef 
where rolRef.id = 1 and contactRef.id = 1;

insert into usr select userIdSeq.nextval, 'Olek', 'Nowak', to_date('1970-01-22', 'YYYY-MM-DD'), 
'222', 'afd456', ref(contactRef), ref(rolRef),
k_recording(t_recording(1, 'youtube.com', 'szybkie nagranie'), t_recording(2, 'youtub2e.com', 'moje nagranie')) 
from role rolRef, contact contactRef 
where rolRef.id = 2 and contactRef.id = 2;

/* wstawianie rekordow do tabeli reservation */
insert into reservation select reservationIdSeq.nextval, ref(usrRef), to_date('2019-01-01 15:00:00', 'YYYY-MM-DD HH24:MI:SS'), 
to_date('2019-01-01 15:30:00', 'YY-MM-DD HH24:MI:SS')
from usr usrRef where usrRef.id = 1;

insert into reservation select reservationIdSeq.nextval, ref(usrRef), to_date('2019-01-01 17:20:00', 'YYYY-MM-DD HH24:MI:SS'), 
to_date('2019-01-01 19:30:00', 'YY-MM-DD HH24:MI:SS')
from usr usrRef where usrRef.id = 1;

insert into reservation select reservationIdSeq.nextval, ref(usrRef), to_date('2019-02-01 17:20:00', 'YYYY-MM-DD HH24:MI:SS'), 
to_date('2019-02-01 19:30:00', 'YY-MM-DD HH24:MI:SS')
from usr usrRef where usrRef.id = 1;

insert into reservation select reservationIdSeq.nextval, ref(usrRef), to_date('2019-02-05 17:20:00', 'YYYY-MM-DD HH24:MI:SS'), 
to_date('2019-02-05 19:30:00', 'YY-MM-DD HH24:MI:SS')
from usr usrRef where usrRef.id = 1;

insert into reservation select reservationIdSeq.nextval, ref(usrRef), to_date('2019-02-22 17:20:00', 'YYYY-MM-DD HH24:MI:SS'), 
to_date('2019-02-22 19:30:00', 'YY-MM-DD HH24:MI:SS')
from usr usrRef where usrRef.id = 1;

insert into reservation select reservationIdSeq.nextval, ref(usrRef), to_date('2019-06-22 12:00:00', 'YYYY-MM-DD HH24:MI:SS'), 
to_date('2019-06-22 14:00:00', 'YY-MM-DD HH24:MI:SS')
from usr usrRef where usrRef.id = 1;

/*wstawianie rekordow do tabeli kart */
insert into kart values(kartIdSeq.nextval, 1, 25, 'gt5', 'silnik m52b20');
insert into kart values(kartIdSeq.nextval, 0, 40, 'gt6', 'silnik m52b28');
insert into kart values(kartIdSeq.nextval, 1, 25, 'gt7', 'silnik m54b25');

/*wstawianie rekordow do tabeli reservationKart */
insert into reservationKart select 
ref(reserRef), ref(kartRef) from reservation reserRef, kart kartRef
where reserRef.id = 1 and kartRef.id = 1;

insert into reservationKart select 
ref(reserRef), ref(kartRef) from reservation reserRef, kart kartRef
where reserRef.id = 1 and kartRef.id = 3;

/*wstawianie rekordów do tabeli lap */
insert into lap select lapIdSeq.nextval, ref(usrRef), ref(kartRef),
44.5, to_date('2018-01-30'), 1, 20, 55 from usr usrRef, kart kartRef
where usrRef.id = 1 and kartRef.id = 1;

insert into lap select lapIdSeq.nextval, ref(usrRef), ref(kartRef),
55, to_date('2019-02-12'), 0, 55, 24 from usr usrRef, kart kartRef
where usrRef.id = 1 and kartRef.id = 3;

insert into lap select lapIdSeq.nextval, ref(usrRef), ref(kartRef),
44.5, to_date('2019-01-28'), 1, 34, 55 from usr usrRef, kart kartRef
where usrRef.id = 1 and kartRef.id = 1;

insert into lap select lapIdSeq.nextval, ref(usrRef), ref(kartRef),
44.5, to_date('2019-05-25'), 0, 20, 55 from usr usrRef, kart kartRef
where usrRef.id = 1 and kartRef.id = 1;

insert into lap select lapIdSeq.nextval, ref(usrRef), ref(kartRef),
44.5, to_date('2019-01-12'), 2, 33, 55 from usr usrRef, kart kartRef
where usrRef.id = 1 and kartRef.id = 1;

insert into lap select lapIdSeq.nextval, ref(usrRef), ref(kartRef),
44.5, to_date('2019-01-13'), 4, 33, 55 from usr usrRef, kart kartRef
where usrRef.id = 1 and kartRef.id = 1;

insert into lap select lapIdSeq.nextval, ref(usrRef), ref(kartRef),
22, to_date('2019-01-01'), 1, 25, 55 from usr usrRef, kart kartRef
where usrRef.id = 1 and kartRef.id = 1;
/*---------------------------------------------------*/

/*selecty */

/*contact */
select * from contact;

/*role */
select * from role;

/*user */
select u.id, u.name, u.surname, u.birthdate, u.pesel, u.document_id, deref(contact).email, 
deref(contact).telephoneNumber, deref(role).name, r.recordingLink, r.title from usr u, 
table (u.recordings) r order by u.id;

select * from usr order by id;

/*reservation */
select id, to_char(startDate, 'YYYY-MM-DD HH24:MI:SS'), to_char(endDate, 'YYYY-MM-DD HH24:MI:SS'), deref(usr).name, deref(usr).surname from reservation
order by reservation.startDate desc;

/*kart */
select * from kart;

/*reservationKart */
select deref(reservation).id, deref(reservation).startDate,
deref(kart).name from reservationKart;


/*lap */
select id, deref(usr).name, deref(usr).surname, deref(kart).name, averageSpeed,
to_char(lapDate, 'YYYY-MM-DD'), minute, second, milisecond from lap
order by minute, second, milisecond;

/*---------------------------------------------------*/
commit;
