create or replace package package_userActions as
    type kartRecord_type is ref cursor;
    type reservation_type is ref cursor;
    
    userNotFound exception;
    
    procedure getRecords(recordTypeCur in out kartRecord_type, recordType in integer, recordLimit in integer);
    procedure getReservations(reservationTypeCur in out reservation_type, reservationType in integer, reservationDate in date);
    
    procedure getUserReservations(userId in integer);
    
    procedure getUserLaps(userId in integer);
    procedure getKartsInReservation(reservationId in integer);
    
    procedure getKarts;
    
    
    function isReservationValid(startDate in date, endDate in date) return boolean;
    
    procedure makeReservation(userId in integer, startDate in date, endDate in date, cost in number,
    byTimeReservationType in number, description in varchar2, kartIds kartIdTab);
    
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
        open recordTypeCur for select id, deref(usr).name, deref(usr).surname, deref(kart).name, averageSpeed,
        to_char(lapDate, 'YYYY-MM-DD'), minute, second, milisecond from lap 
        where rownum <= recordLimit and
        ((select months_between(lap.lapDate, currentDate) from lap)) = 1 order by minute asc, second asc, milisecond asc;
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

    /* 1 - rezerwacje z dnia, 2 - rezerwacje z tygodnia, 3 - rezerwacje z miesiaca */
  procedure getReservations(reservationTypeCur in out reservation_type, reservationType in integer, reservationDate in date) AS
    reservationDateDay integer;
    
    reservationId reservation.id%type;
    reservationStartDate reservation.startDate%type;
    reservationEndDate reservation.endDate%type;
  BEGIN
    if reservationType = 1 then
        select extract(day from reservationDate) into reservationDateDay from dual; 
        open reservationTypeCur for select id, startDate, endDate from reservation
        where ((select extract(day from reservation.startDate) from dual) = reservationDateDay); 
        
    elsif reservationType = 2 then
        open reservationTypeCur for select id, startDate, endDate from reservation
        where reservation.startDate between reservationDate and (select reservationDate + interval '7' day from dual);
        
    elsif reservationType = 3 then
        open reservationTypeCur for select id, startDate, endDate from reservation
        where ((select extract(month from reservation.startDate) from dual) = (select extract(month from reservationDate) from dual));
    else 
        open reservationTypeCur for select id, startDate, endDate from reservation;
    end if;
    
    loop
        fetch reservationTypeCur into reservationId, reservationStartDate, reservationEndDate;
            DBMS_OUTPUT.PUT_LINE('ID rezerwacji: ' || reservationId || 'Poczatek: ' || reservationStartDate || 'Koniec: ' || reservationEndDate);
        exit when reservationTypeCur%notfound;
    end loop;
    close reservationTypeCur;
  END getReservations;
  
  
    
  procedure getUserReservations(userId in integer) AS
   cursor cur is select id, to_char(startDate, 'YYYY-MM-DD HH24:MI:SS'), to_char(endDate, 'YYYY-MM-DD HH24:MI:SS'), cost, deref(usr).name, deref(usr).surname from reservation
   where deref(usr).id = userId;
   
   reservationId integer;
   startDate varchar2(30);
   endDate varchar2(30);
   reservationCost number;
   userName varchar2(40);
   userSurname varchar2(40);
  BEGIN
    open cur;
        loop
        fetch cur into reservationId, startDate, endDate, reservationCost, userName, userSurname;
            exit when cur%notfound;
            dbms_output.put_line(reservationId || ' ' || startDate || ' ' || endDate || ' ' || reservationCost || ' ' || userName || ' ' || userSurname);
        end loop;
    close cur;
  END getUserReservations;
  

    
  procedure getUserLaps(userId in integer) AS
  cursor cur is select id, deref(usr).name, deref(usr).surname, deref(kart).name, averageSpeed,
    to_char(lapDate, 'YYYY-MM-DD'), minute, second, milisecond from lap
    where deref(usr).id = userId;
    
   lapId integer;
   userName varchar2(40);
   userSurname varchar2(40);
   kartName varchar(50);
   averageSpeed number;
   lapDate varchar2(30);
   
   lapMinute integer;
   lapSecond integer;
   lapMilisecond integer;
  BEGIN
    open cur;
        loop
        fetch cur into lapId, userName, userSurname, kartName, averageSpeed, lapDate, lapMinute, lapSecond, lapMilisecond;
            exit when cur%notfound;
            dbms_output.put_line(lapId || ' ' || userName || ' ' || userSurname || ' ' || kartName || ' ' || averageSpeed || ' ' 
            || lapDate || ' ' || lapMinute || ' ' || lapSecond || ' ' || lapMilisecond);
        end loop;
    close cur;
  END getUserLaps;

  procedure getKartsInReservation(reservationId in integer) AS
    cursor cur is select deref(reservation).startDate, deref(reservation).endDate, deref(kart).name from reservationKart
    where deref(reservation).id = reservationId;
    
    reservationStartdate date;
    reservationEnddate date;
    kartName varchar2(40);
  BEGIN
       open cur;
        loop
        fetch cur into reservationStartdate, reservationEnddate, kartName;
            exit when cur%notfound;
            dbms_output.put_line(to_char(reservationStartdate, 'YYYY-MM-DD HH24:MI:SS') || ' ' || 
            to_char(reservationEnddate, 'YYYY-MM-DD HH24:MI:SS') || ' ' || kartName);
        end loop;
    close cur;
  END getKartsInReservation;
  

  procedure getKarts AS
    cursor cur is select * from kart;
    
    kartId integer;
    kartAvailability number;
    kartPrize number;
    kartName varchar2(40);
    kartDescritpion varchar2(255);
  BEGIN
     open cur;
        loop
        fetch cur into kartId, kartAvailability, kartPrize, kartName, kartDescritpion;
            exit when cur%notfound;
            dbms_output.put_line(kartId || ' ' || kartAvailability || ' ' || kartPrize || ' ' || kartName || ' ' || kartDescritpion);
        end loop;
    close cur;
  END getKarts;

  function isReservationValid(startDate in date, endDate in date) return boolean AS
  currentDate date;
  
  startDateHour integer;
  endDateHour integer;
  startDateMinute integer;
  endDateMinute integer;
  
  reservationsReturned number;
  BEGIN
    select sysdate into currentDate from dual;
    select extract(hour from cast(startDate as timestamp)) into startDateHour from dual; 
    select extract(hour from cast(endDate as timestamp)) into endDateHour from dual;

    if startDate < currentDate then
        return false;
    elsif startDateHour < 12 or endDateHour >= 20 then
        return false;
    else
    DBMS_OUTPUT.PUT_LINE(to_char(startDate, 'YYYY-MM-DD HH24:MI:SS'));
    DBMS_OUTPUT.PUT_LINE(to_char(endDate, 'YYYY-MM-DD HH24:MI:SS'));
        select count(id) into reservationsReturned from reservation where
		((startDate >= reservation.startDate and endDate <= reservation.endDate)
		or (startDate < reservation.startDate and endDate > reservation.startDate and endDate <= reservation.endDate)
		or (endDate > reservation.endDate and startDate >= reservation.startDate and startDate < reservation.endDate)
		or (startDate < reservation.startDate and endDate > reservation.endDate));
		if reservationsReturned = 0 then
            DBMS_OUTPUT.PUT_LINE(reservationsReturned);
			return true;
		else 
         DBMS_OUTPUT.PUT_LINE(reservationsReturned);
			return false;
        end if;  
        
    end if;    
  END isReservationValid;

  procedure makeReservation(userId in integer, startDate in date, endDate in date, cost in number,
    byTimeReservationType in number, description in varchar2, kartIds kartIdTab) AS
  BEGIN
    if (isReservationValid(startDate, endDate)) then
        for i in 1 .. kartIds.count
        loop
            DBMS_OUTPUT.PUT_LINE('Index: ' || to_char(i) || ' ' || to_char(kartIds(i)));
        end loop;    
    else 
         dbms_output.put_line('Nie mozna dokonac rezerwacji w tym terminie');
    end if;
  END makeReservation;
    
END package_userActions;

/*test dzialania getRecords */

set SERVEROUTPUT ON;
declare refk package_userActions.kartRecord_type;
begin
    package_userActions.getRecords(refk, 1, 10);
end;


set SERVEROUTPUT ON;
declare refk package_userActions.reservation_type;
begin
    package_userActions.getReservations(refk, 6, '2019-01-19');
end;


set SERVEROUTPUT ON;
DECLARE
  USERID NUMBER;
BEGIN
  USERID := 1;
  PACKAGE_USERACTIONS.GETUSERRESERVATIONS(
    USERID => USERID
  );
END;

DECLARE
  USERID NUMBER;
BEGIN
  USERID := 1;
  PACKAGE_USERACTIONS.GETUSERLAPS(
    USERID => USERID
  );
--rollback; 
END;

DECLARE
  RESERVATIONID NUMBER;
BEGIN
  RESERVATIONID := 1;

  PACKAGE_USERACTIONS.GETKARTSINRESERVATION(
    RESERVATIONID => RESERVATIONID
  );
--rollback; 
END;

BEGIN
  PACKAGE_USERACTIONS.GETKARTS();
--rollback; 
END;


DECLARE
  STARTDATE DATE;
  ENDDATE DATE;
  v_Return BOOLEAN;
BEGIN
  STARTDATE := NULL;
  ENDDATE := NULL;

  v_Return := PACKAGE_USERACTIONS.ISRESERVATIONVALID(
    STARTDATE => to_date('2019-01-12 16:00:00', 'YYYY-MM-DD HH24:MI:SS'),
    ENDDATE => to_date('2019-01-12 17:00:00', 'YYYY-MM-DD HH24:MI:SS')
  );

IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;
  --:v_Return := v_Return;
--rollback; 
END;



