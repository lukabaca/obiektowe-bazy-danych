create or replace package package_userActions as
    type kartRecord_type is ref cursor;
    --type reservation_type is ref cursor;
    
    userNotFound exception;
    
    procedure getRecords(recordTypeCur in out kartRecord_type, recordType in integer, recordLimit in integer);
   -- procedure getReservations(reservationTypeCur in out reservation_type, reservationType in integer);
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

CREATE OR REPLACE
PACKAGE BODY package_userActions AS
    /* 1 - rekordy wszech czasów, 2 - rekordy obecne i z zeszlego miesiaca, 3 - rekordy z tygodnia wstecz od podanej daty */
  procedure getRecords(recordTypeCur in out kartRecord_type, recordType in integer, recordLimit in integer) as
  currentDate date;
  monthsBetweenDates integer;
  daysBetweenDates integer;
  
  lapIdRes lap.id%type;
  userName varchar2(40);
  lapMinute lap.minute%type;
  lapSecond lap.second%type;
  lapMiliSecond lap.milisecond%type;
  BEGIN
    if recordType = 1 then
        open recordTypeCur for select id, deref(usr).name, minute, second, milisecond from lap 
        where rownum <= recordLimit order by minute asc, second asc, milisecond asc;
    elsif recordType = 2 then
        select sysdate into currentDate from dual;
        select months_between(lap.lapDate, currentDate) into monthsBetweenDates from lap;
        open recordTypeCur for select id, deref(usr).name, deref(usr).surname, deref(kart).name, averageSpeed,
        to_char(lapDate, 'YYYY-MM-DD'), minute, second, milisecond from lap 
        where rownum <= recordLimit and
        monthsBetweenDates = 1 order by minute asc, second asc, milisecond asc;
    elsif recordType = 3 then
        select sysdate into currentDate from dual;
        select abs(currentDate - lap.lapDate) into daysBetweenDates from lap;
        open recordTypeCur for select id, deref(usr).name, deref(usr).surname, deref(kart).name, averageSpeed,
        to_char(lapDate, 'YYYY-MM-DD'), minute, second, milisecond from lap 
        where rownum <= recordLimit and
        (daysBetweenDates >= 0 and daysBetweenDates <= 7) order by minute asc, second asc, milisecond asc;
    else
        open recordTypeCur for select id, deref(usr).name, deref(usr).surname, deref(kart).name, averageSpeed,
        to_char(lapDate, 'YYYY-MM-DD'), minute, second, milisecond from lap 
        where rownum <= recordLimit order by minute asc, second asc, milisecond asc;
    end if;
    
    loop
        fetch recordTypeCur into lapIdRes, userName, lapMinute, lapSecond, lapMilisecond;
            DBMS_OUTPUT.PUT_LINE('ID okrazena: ' || lapIdRes || 'Uzytkownik: ' || lapIdRes || 'Czas: ' || lapMinute || ':' || lapSecond || ':' || lapMilisecond);
        exit when recordTypeCur%notfound;
    end loop;
    close recordTypeCur;
  END getRecords;

/*
  procedure getReservations(reservationTypeCur in out reservation_type, reservationType in integer) AS
  BEGIN
    -- TODO: Implementation required for procedure PACKAGE_USERACTIONS.getReservations
    NULL;
  END getReservations;
  

  procedure getUserReservations(userId in integer) AS
  BEGIN
    -- TODO: Implementation required for procedure PACKAGE_USERACTIONS.getUserReservations
    NULL;
  END getUserReservations;

  procedure getUserLaps(userId in integer) AS
  BEGIN
    -- TODO: Implementation required for procedure PACKAGE_USERACTIONS.getUserLaps
    NULL;
  END getUserLaps;

  procedure getKartsInReservation(reservationId in integer) AS
  BEGIN
    -- TODO: Implementation required for procedure PACKAGE_USERACTIONS.getKartsInReservation
    NULL;
  END getKartsInReservation;

  procedure getKarts AS
  BEGIN
    -- TODO: Implementation required for procedure PACKAGE_USERACTIONS.getKarts
    NULL;
  END getKarts;

  function isReservationValid(startDate in date, endDate in date) return boolean AS
  BEGIN
    -- TODO: Implementation required for function PACKAGE_USERACTIONS.isReservationValid
    RETURN NULL;
  END isReservationValid;

  procedure makeReservation(userId in integer, startDate in date, endDate in date, cost in number,
    byTimeReservationType in number, description in varchar2, kartIds kartIdTab) AS
  BEGIN
    -- TODO: Implementation required for procedure PACKAGE_USERACTIONS.makeReservation
    NULL;
  END makeReservation;
    */
END package_userActions;

/*test dzialania getRecords */
set SERVEROUTPUT ON;
declare refk package_userActions.kartRecord_type;
begin
    package_userActions.getRecords(refk, 1, 10);
end;

