/* pakiet dla akcji dokonywanych przez uzytkownika toru */
create or replace package package_userActions as
    type kartRecord_type is ref cursor;
    type reservation_type is ref cursor;
    
    /*wyjatki */
    /*nie znaleziono uzytkownika */
    userNotFoundException exception;
    /*nie znaleziono rezerwacji */
    reservationNotFoundException exception;
    /*nie znaleziono gokartu */
    kartNotFoundException exception;
    /*niepoprawna liczba pojazdow (gdy liczba pojazdow < 0 lub > 5 */
    wrongNumberOfRidesException exception;
    /*gdy nastepuje proba usuniecia nie swojej rezerwacji */
    cancelReservationException exception;
    
    /*pobranie rekordów toru */
    procedure getRecords(recordTypeCur in out kartRecord_type, recordType in integer, recordLimit in integer);
    /*pobieranie rezerwacjie w sytemie */
    procedure getReservations(reservationTypeCur in out reservation_type, reservationType in integer, reservationDate in date);
    /*pobranie rezerwacji danego uzytkownika */
    procedure getUserReservations(userId in integer);
    /*pobranie okrazen danego uzytkownika */
    procedure getUserLaps(userId in integer);
    /*pobranie listy gokartow z danej rezerwacji */
    procedure getKartsInReservation(reservationId in integer);
    /*pobranie listy dostepnych gokartow */
    procedure getKarts;
    
    /*sprawdzanie kolizji rezerwacji */
    function isReservationValid(resStartDate in date, resEndDate in date) return boolean;
    /*sprawdzanie czy podane ID gokartow sa zgodne z wystepujacymi dostepnie gokartami w ofercie */
    function checkKartIds(kartIds kartIdTab) return boolean; 
    /*dokonywanie rezerwacji */
    procedure makeReservation(userId in integer, startDate in date, numberOfRides in integer, kartIds kartIdTab);
    /*anulowanie danej rezerwacji */
    procedure cancelReservation(reservationId in integer, userId in integer);
end package_userActions;

CREATE OR REPLACE
PACKAGE BODY package_userActions AS
    /* recordType przyjmuje nastepujace wartosci: 1 - rekordy wszech czasów, 2 - rekordy obecne i z zeszlego miesiaca, 3 - rekordy z tygodnia wstecz od podanej daty 
    recordLimit okresla ile wynikow maksymalnie chcemy otrzymac*/
  procedure getRecords(recordTypeCur in out kartRecord_type, recordType in integer, recordLimit in integer) as
    currentDate date;

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
        open recordTypeCur for select id, deref(usr).name, minute, second, milisecond from lap 
        where rownum <= recordLimit and
        ((select months_between(lap.lapDate, currentDate) from lap)) = 1 order by minute asc, second asc, milisecond asc;
        
    elsif recordType = 3 then
        select sysdate into currentDate from dual;
        open recordTypeCur for select id, deref(usr).name, minute, second, milisecond from lap 
        where rownum <= recordLimit and
        ( ((select abs(currentDate - lap.lapDate) from lap)) >= 0 and ((select abs(currentDate - lap.lapDate) from lap)) <= 7 ) order by minute asc, second asc, milisecond asc;
        
    else
       open recordTypeCur for select id, deref(usr).name, minute, second, milisecond from lap 
       where rownum <= recordLimit order by minute asc, second asc, milisecond asc;
    end if;
    
    loop
        fetch recordTypeCur into lapIdRes, userName, lapMinute, lapSecond, lapMilisecond;
            exit when recordTypeCur%notfound;
            DBMS_OUTPUT.PUT_LINE('ID okrazena: ' || lapIdRes || 'Uzytkownik: ' || userName || 'Czas: ' || lapMinute || ':' || lapSecond || ':' || lapMilisecond);
    end loop;
    close recordTypeCur;
  END getRecords;

    /* reservationType przyjmuje nastepujace wartosci: 1 - rezerwacje z dnia, 2 - rezerwacje do 1 tygodnia do przodu od podanej daty, 3 - rezerwacje z miesiaca */
  procedure getReservations(reservationTypeCur in out reservation_type, reservationType in integer, reservationDate in date) AS
    reservationDateDay integer;
    reservationDateMonth integer;
    reservationDateYear integer;
    
    reservationId reservation.id%type;
    reservationStartDate reservation.startDate%type;
    reservationEndDate reservation.endDate%type;
  BEGIN
    if reservationType = 1 then
        select extract(day from reservationDate) into reservationDateDay from dual; 
        select extract(month from reservationDate) into reservationDateMonth from dual; 
        select extract(year from reservationDate) into reservationDateYear from dual; 
        
        open reservationTypeCur for select id, startDate, endDate from reservation
        where ( 
            (select extract(day from reservation.startDate) from dual) = reservationDateDay 
            and (select extract(month from reservation.startDate) from dual) = reservationDateMonth 
            and (select extract(year from reservation.startDate) from dual) = reservationDateYear 
        ); 
        
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
            exit when reservationTypeCur%notfound;
            DBMS_OUTPUT.PUT_LINE('ID rezerwacji: ' || reservationId || 'Poczatek: ' || to_char(reservationStartDate, 'YYYY-MM-DD HH24:MI:SS') 
            || 'Koniec: ' || to_char(reservationEndDate, 'YYYY-MM-DD HH24:MI:SS'));
    end loop;
    close reservationTypeCur;
  END getReservations;
  
  
    
  procedure getUserReservations(userId in integer) AS
   cursor cur is select id, to_char(startDate, 'YYYY-MM-DD HH24:MI:SS'), to_char(endDate, 'YYYY-MM-DD HH24:MI:SS'), deref(usr).name, deref(usr).surname from reservation
   where deref(usr).id = userId;
   
   reservationId integer;
   startDate varchar2(30);
   endDate varchar2(30);
   userName varchar2(40);
   userSurname varchar2(40);
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isUserFound(userId)) then
        raise userNotFoundException;
    else    
        open cur;
            loop
            fetch cur into reservationId, startDate, endDate, userName, userSurname;
                exit when cur%notfound;
                dbms_output.put_line(reservationId || ' ' || startDate || ' ' || endDate || ' ' || ' ' || userName || ' ' || userSurname);
            end loop;
        close cur;
    end if;
    EXCEPTION
    when userNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono uzytkownika o podanym ID');    
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
  if (not PACKAGE_CHECKINGRECORDEXIST.isUserFound(userId)) then
        raise userNotFoundException;
  else    
    open cur;
        loop
        fetch cur into lapId, userName, userSurname, kartName, averageSpeed, lapDate, lapMinute, lapSecond, lapMilisecond;
            exit when cur%notfound;
            dbms_output.put_line(lapId || ' ' || userName || ' ' || userSurname || ' ' || kartName || ' ' || averageSpeed || ' ' 
            || lapDate || ' ' || lapMinute || ' ' || lapSecond || ' ' || lapMilisecond);
        end loop;
    close cur;
 end if;
 EXCEPTION
    when userNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono uzytkownika o podanym ID');  
  END getUserLaps;

  procedure getKartsInReservation(reservationId in integer) AS
    cursor cur is select deref(reservation).startDate, deref(reservation).endDate, deref(kart).name from reservationKart
    where deref(reservation).id = reservationId;
    
    reservationStartdate date;
    reservationEnddate date;
    kartName varchar2(40);
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isReservationFound(reservationId)) then
        raise reservationNotFoundException;
    else    
       open cur;
        loop
        fetch cur into reservationStartdate, reservationEnddate, kartName;
            exit when cur%notfound;
            dbms_output.put_line(to_char(reservationStartdate, 'YYYY-MM-DD HH24:MI:SS') || ' ' || 
            to_char(reservationEnddate, 'YYYY-MM-DD HH24:MI:SS') || ' ' || kartName);
        end loop;
    close cur;
    end if;
    EXCEPTION
    when reservationNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono rezerwacji o podanym ID');   
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
            if kartAvailability = 1 then
                dbms_output.put_line(kartId || ' '  || kartPrize || ' ' || kartName || ' ' || kartDescritpion);
            end if;    
        end loop;
    close cur;
  END getKarts;

  function isReservationValid(resStartDate in date, resEndDate in date) return boolean AS
      currentDate date;
      
      startDateHour integer;
      endDateHour integer;
      startDateMinute integer;
      endDateMinute integer;
      
      reservationsReturned number;
  BEGIN
    select sysdate into currentDate from dual;
    select extract(hour from cast(resStartDate as timestamp)) into startDateHour from dual; 
    select extract(hour from cast(resEndDate as timestamp)) into endDateHour from dual;
    
    /*jesli poczatkowa data rezerwacjie jest wczesniejsza niz obecny czas,
    unikanie dokonywania rezerwacji wstecz */
    if resStartDate < currentDate then
        return false;
    /*sprwadzenie czy godziny rezerwacji sa zawarte w godzinach czynnosci toru */    
    elsif startDateHour < 12 or endDateHour >= 20 then
        return false;
    else
        select count(id) into reservationsReturned from reservation where
		(( (resStartDate >= reservation.startDate) and (resEndDate <= reservation.endDate) )
		or ( (resStartDate < reservation.startDate) and (resEndDate > reservation.startDate) and (resEndDate <= reservation.endDate) )
		or ( (resEndDate > reservation.endDate) and (resStartDate >= reservation.startDate) and (resStartDate < reservation.endDate) )
		or ( (resStartDate < reservation.startDate) and (resEndDate > reservation.endDate)) );
		if reservationsReturned = 0 then
			return true;
		else 
			return false;
        end if;  
        
    end if;    
  END isReservationValid;
  
  function checkKartIds(kartIds kartIdTab) return boolean as
    isValid boolean;
    
    kartAvailability number;
  begin
    isValid:= true;
    if kartIds.count > 0 then
        for i in 1 .. kartIds.count
        loop
            if (not PACKAGE_CHECKINGRECORDEXIST.isKartFound(kartIds(i))) then
                isValid:= false;
                exit;
            else 
                select kart.availability into kartAvailability from kart where kart.id = kartIds(i);
                if kartAvailability = 0 then
                    isValid:= false;
                    exit;
                end if;
            end if;
        end loop;
    else 
        isValid:= false;
    end if;
    
    return isValid;
  end checkKartIds;

  procedure makeReservation(userId in integer, startDate in date, numberOfRides in integer, kartIds kartIdTab) AS
   reservationTmpId integer;
   endDate date;
   startDateTmp number;
  BEGIN
    if (not PACKAGE_CHECKINGRECORDEXIST.isUserFound(userId)) then
        raise userNotFoundException;
    elsif (not PACKAGE_USERACTIONS.checkKartIds(kartIds)) then
        raise kartNotFoundException;
    end if;
    if numberOfRides <= 0 or numberOfRides > 5 then
        raise wrongNumberOfRidesException;
    end if;
    /*koncowa data rezerwacjie jest obliczana na podstawie poczatkowej daty + ilosc przejadzwo * czas przejazdow */
    select startDate + NUMTODSINTERVAL(numberOfRides * 10, 'minute') into endDate  from dual;
    /*sprawdzanie kolizji rezerwacji */
    if (isReservationValid(startDate, endDate)) then
        reservationTmpId:= reservationIdSeq.nextval; 
        PACKAGE_ADDRECORD.addReservation(reservationTmpId, userId, startDate, endDate);
        for i in 1 .. kartIds.count
        loop
            PACKAGE_ADDRECORD.ADDRESERVATIONKART(reservationTmpId, kartIds(i));
        end loop;
        DBMS_OUTPUT.PUT_LINE('Dokonano rezerwacji w terminie: ' || to_char(startDate, 'YYYY-MM-DD HH24:MI:SS') || '-' 
        || to_char(endDate, 'YYYY-MM-DD HH24:MI:SS'));
    else 
         dbms_output.put_line('Nie mozna dokonac rezerwacji w tym terminie');
    end if;
  EXCEPTION
    when userNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono uzytkownika o podanym ID');
    when kartNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Pojazd o takim id nie istnieje lub jest obecnie niedostepny');
    when wrongNumberOfRidesException then    
        DBMS_OUTPUT.PUT_LINE('Podano niepoprawna liczbe przejazdow, musi sie ona zawierca miedzy 1 a 5');
  END makeReservation;
  
  procedure cancelReservation(reservationId in integer, userId in integer) as
  usersIdForReservation integer;
  begin
     if (not PACKAGE_CHECKINGRECORDEXIST.isUserFound(userId)) then
        raise userNotFoundException;
    elsif (not PACKAGE_CHECKINGRECORDEXIST.isReservationFound(reservationId)) then
        raise reservationNotFoundException;
    end if;
    select deref(usr).id into usersIdForReservation from reservation where reservation.id = reservationId;
    /*sprawdzenie czy podana rezerwacji nalezy do uzytkownika, ktory chce ja anulowac */
    if usersIdForReservation != userId then
        raise cancelReservationException;
    end if;
    
    delete from reservationKart where deref(reservation).id = reservationId;
    delete from reservation where reservation.id = reservationId;
    DBMS_OUTPUT.PUT_LINE('Anulowano rezerwacje');
    EXCEPTION
    when userNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono uzytkownika o podanym ID');
    when reservationNotFoundException then
        DBMS_OUTPUT.PUT_LINE('Nie znaleziono rezerwacji o podanym ID');
    when cancelReservationException then
        DBMS_OUTPUT.PUT_LINE('Nie mozna anulowac nie swojej rezerwacji');    
  end cancelReservation;
    
END package_userActions;

/*-----------------------------------------------------*/

/*test dzialania getRecords */
set serveroutput on;

/* pobieranie listy dostepnych gokartow */
BEGIN
  PACKAGE_USERACTIONS.GETKARTS();
--rollback; 
END;

/*pobieranie pojazdow z danej rezerwacji */
DECLARE
  RESERVATIONID NUMBER;
BEGIN
  RESERVATIONID := 1;

  PACKAGE_USERACTIONS.GETKARTSINRESERVATION(
    RESERVATIONID => RESERVATIONID
  );
--rollback; 
END;

/*pobieranie okrazen uzytkownika */
DECLARE
  USERID NUMBER;
BEGIN
  USERID := NULL;

  PACKAGE_USERACTIONS.GETUSERLAPS(
    USERID => USERID
  );
--rollback; 
END;

/*pobieranie rezerwacji uzytkownika */
DECLARE
  USERID NUMBER;
BEGIN
  USERID := 1;

  PACKAGE_USERACTIONS.GETUSERRESERVATIONS(
    USERID => USERID
  );
--rollback; 
END;

/* pobieranie rekordow toru */
DECLARE
  RECORDTYPECUR LUKA.PACKAGE_USERACTIONS.kartRecord_type;
  RECORDTYPE NUMBER;
  RECORDLIMIT NUMBER;
BEGIN
  RECORDTYPECUR := RECORDTYPECUR;
  RECORDTYPE := 1;
  RECORDLIMIT := 10;

  PACKAGE_USERACTIONS.GETRECORDS(
    RECORDTYPECUR => RECORDTYPECUR,
    RECORDTYPE => RECORDTYPE,
    RECORDLIMIT => RECORDLIMIT
  );
 
--DBMS_OUTPUT.PUT_LINE('RECORDTYPECUR = ' || RECORDTYPECUR);
  --:RECORDTYPECUR := RECORDTYPECUR; --<-- Cursor
--rollback; 
END;

/*pobieranie rezerwacji dla podanej daty*/

/*dla konkretnego dnia */
DECLARE
  RESERVATIONTYPECUR LUKA.PACKAGE_USERACTIONS.reservation_type;
  RESERVATIONTYPE NUMBER;
  RESERVATIONDATE DATE;
BEGIN
  RESERVATIONTYPECUR := RESERVATIONTYPECUR;
  RESERVATIONTYPE := 1;
  RESERVATIONDATE := to_date('2019-01-01 17:20:00', 'YYYY-MM-DD HH24:MI:SS');

  PACKAGE_USERACTIONS.GETRESERVATIONS(
    RESERVATIONTYPECUR => RESERVATIONTYPECUR,
    RESERVATIONTYPE => RESERVATIONTYPE,
    RESERVATIONDATE => RESERVATIONDATE
  );
END;

/*dla tygodnia do przodu od podanej daty*/
DECLARE
  RESERVATIONTYPECUR LUKA.PACKAGE_USERACTIONS.reservation_type;
  RESERVATIONTYPE NUMBER;
  RESERVATIONDATE DATE;
BEGIN
  RESERVATIONTYPECUR := RESERVATIONTYPECUR;
  RESERVATIONTYPE := 2;
  RESERVATIONDATE := to_date('2019-02-01 17:20:00', 'YYYY-MM-DD HH24:MI:SS');

  PACKAGE_USERACTIONS.GETRESERVATIONS(
    RESERVATIONTYPECUR => RESERVATIONTYPECUR,
    RESERVATIONTYPE => RESERVATIONTYPE,
    RESERVATIONDATE => RESERVATIONDATE
  );
END;

/*dla miesiaca z podanej daty */
DECLARE
  RESERVATIONTYPECUR LUKA.PACKAGE_USERACTIONS.reservation_type;
  RESERVATIONTYPE NUMBER;
  RESERVATIONDATE DATE;
BEGIN
  RESERVATIONTYPECUR := RESERVATIONTYPECUR;
  RESERVATIONTYPE := 3;
  RESERVATIONDATE := to_date('2019-02-01 17:20:00', 'YYYY-MM-DD HH24:MI:SS');

  PACKAGE_USERACTIONS.GETRESERVATIONS(
    RESERVATIONTYPECUR => RESERVATIONTYPECUR,
    RESERVATIONTYPE => RESERVATIONTYPE,
    RESERVATIONDATE => RESERVATIONDATE
  );
END;

/*sprawdzanie kolizji rezerwacji 
dla rezerwacjie 2019-06-22 12:00 - 14:00*/

/* 1 */
DECLARE
  RESSTARTDATE DATE;
  RESENDDATE DATE;
  v_Return BOOLEAN;
BEGIN
  RESSTARTDATE := to_date('2019-06-22 11:00:00', 'YYYY-MM-DD HH24:MI:SS');
  RESENDDATE := to_date('2019-06-22 13:20:00', 'YYYY-MM-DD HH24:MI:SS');

  v_Return := PACKAGE_USERACTIONS.ISRESERVATIONVALID(
    RESSTARTDATE => RESSTARTDATE,
    RESENDDATE => RESENDDATE
  );

IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;
  --:v_Return := v_Return;
--rollback; 
END;

/* 2 */
DECLARE
  RESSTARTDATE DATE;
  RESENDDATE DATE;
  v_Return BOOLEAN;
BEGIN
  RESSTARTDATE := to_date('2019-06-22 12:30:00', 'YYYY-MM-DD HH24:MI:SS');
  RESENDDATE := to_date('2019-06-22 18:20:00', 'YYYY-MM-DD HH24:MI:SS');

  v_Return := PACKAGE_USERACTIONS.ISRESERVATIONVALID(
    RESSTARTDATE => RESSTARTDATE,
    RESENDDATE => RESENDDATE
  );

IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;
  --:v_Return := v_Return;
--rollback; 
END;

/* 3 */
DECLARE
  RESSTARTDATE DATE;
  RESENDDATE DATE;
  v_Return BOOLEAN;
BEGIN
  RESSTARTDATE := to_date('2019-06-22 12:30:00', 'YYYY-MM-DD HH24:MI:SS');
  RESENDDATE := to_date('2019-06-22 13:20:00', 'YYYY-MM-DD HH24:MI:SS');

  v_Return := PACKAGE_USERACTIONS.ISRESERVATIONVALID(
    RESSTARTDATE => RESSTARTDATE,
    RESENDDATE => RESENDDATE
  );

IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;
  --:v_Return := v_Return;
--rollback; 
END;

/* 4 */
DECLARE
  RESSTARTDATE DATE;
  RESENDDATE DATE;
  v_Return BOOLEAN;
BEGIN
  RESSTARTDATE := to_date('2019-06-22 11:30:00', 'YYYY-MM-DD HH24:MI:SS');
  RESENDDATE := to_date('2019-06-22 18:20:00', 'YYYY-MM-DD HH24:MI:SS');

  v_Return := PACKAGE_USERACTIONS.ISRESERVATIONVALID(
    RESSTARTDATE => RESSTARTDATE,
    RESENDDATE => RESENDDATE
  );

IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;
  --:v_Return := v_Return;
--rollback; 
END;

/*---------------------------------------------*/

DECLARE
  KARTIDS LUKA.KARTIDTAB;
  v_Return BOOLEAN;
BEGIN
  KARTIDS := kartIdTab(1, 3);

  v_Return := PACKAGE_USERACTIONS.checkKartIds(
   KARTIDS => KARTIDS
  );
  
IF (v_Return) THEN 
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'TRUE');
  ELSE
    DBMS_OUTPUT.PUT_LINE('v_Return = ' || 'FALSE');
  END IF;

  --:v_Return := v_Return;
--rollback; 
END;

DECLARE
  USERID NUMBER;
  STARTDATE DATE;
  NUMBEROFRIDES NUMBER;
  KARTIDS LUKA.KARTIDTAB;
BEGIN
  USERID := 1;
  STARTDATE := to_date('2019-09-22 12:30:00', 'YYYY-MM-DD HH24:MI:SS');
  NUMBEROFRIDES := 4;
  -- Modify the code to initialize the variable
  KARTIDS := kartIdTab(1, 3);

  PACKAGE_USERACTIONS.MAKERESERVATION(
    USERID => USERID,
    STARTDATE => STARTDATE,
    NUMBEROFRIDES => NUMBEROFRIDES,
    KARTIDS => KARTIDS
  );
--rollback; 
END;

DECLARE
  USERID NUMBER;
  STARTDATE DATE;
  NUMBEROFRIDES NUMBER;
  KARTIDS LUKA.KARTIDTAB;
BEGIN
  USERID := 3;
  STARTDATE := to_date('2019-09-22 14:30:00', 'YYYY-MM-DD HH24:MI:SS');
  NUMBEROFRIDES := 2;
  -- Modify the code to initialize the variable
  KARTIDS := kartIdTab(1, 3);

  PACKAGE_USERACTIONS.MAKERESERVATION(
    USERID => USERID,
    STARTDATE => STARTDATE,
    NUMBEROFRIDES => NUMBEROFRIDES,
    KARTIDS => KARTIDS
  );
END;

/*anulowanie rezerwacji */

DECLARE
  USERID INTEGER;
  RESERVATIONID INTEGER;
BEGIN
  USERID := 3;
  RESERVATIONID := 13;

  PACKAGE_USERACTIONS.CANCELRESERVATION(
    USERID => USERID,
    RESERVATIONID => RESERVATIONID
  );
END;


commit;

