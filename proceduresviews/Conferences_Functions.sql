Use [CONFERENCES]

IF OBJECT_ID('getConferenceID') IS NOT NULL
DROP FUNCTION getConferenceID
GO

IF OBJECT_ID('getConfereneStartDate') IS NOT NULL
DROP FUNCTION getConferenceStartDate
GO

IF OBJECT_ID('getConferenceEndDate') IS NOT NULL
DROP FUNCTION getConferenceEndDate
GO

IF OBJECT_ID('getConferenceDayID') IS NOT NULL
DROP FUNCTION getConferenceDayID
GO

IF OBJECT_ID('getConferenceDayFreeSeats') IS NOT NULL
DROP FUNCTION getConferenceDayFreeSeats
GO

IF OBJECT_ID('getWorkshopFreeSeats') IS NOT NULL
DROP FUNCTION getWorkshopFreeSeats
GO

IF OBJECT_ID('getConferenceDayID_ConferenceID') IS NOT NULL
DROP FUNCTION getConferenceDayID_ConferenceID
GO

IF OBJECT_ID('getConferenceDayPrice') IS NOT NULL
DROP FUNCTION getConferenceDayPrice
GO

IF OBJECT_ID('getRealPrice') IS NOT NULL
DROP FUNCTION getRealPrice
GO

IF OBJECT_ID('getLatestPayment') IS NOT NULL
DROP FUNCTION getLatestPayment
GO

IF OBJECT_ID('getLatestConferenceDayReservation') IS NOT NULL
DROP FUNCTION getLatestConferenceDayReservation
GO

IF OBJECT_ID('getLatestClient') IS NOT NULL
DROP FUNCTION getLatestClient
GO

IF OBJECT_ID('getLatestConferenceDayReservation') IS NOT NULL
DROP FUNCTION getLatestConferenceDayReservation
GO

IF OBJECT_ID('checkIfClientIsInDataBase') IS NOT NULL
DROP FUNCTION checkIfClientIsInDataBase
GO

IF OBJECT_ID('getConferenceDayReservationID') IS NOT NULL
DROP FUNCTION getConferenceDayReservationID
GO

IF OBJECT_ID('checkIfCompanyNameAndNIPMatches') IS NOT NULL
DROP FUNCTION checkIfCompanyNameAndNIPMatches
GO

IF OBJECT_ID('getWorkshopId') IS NOT NULL
DROP FUNCTION getWorkshopID
GO

IF OBJECT_ID('checkIfClientIsRegisteredOnConferenceDay') IS NOT NULL
DROP FUNCTION checkIfClientIsRegisteredOnConferenceDay
GO

IF OBJECT_ID('getLatestWorkshopReservation') IS NOT NULL
DROP FUNCTION getLatestWorkshopReservation
GO

IF OBJECT_ID('checkIfClientIsConferenceDayParticipant') IS NOT NULL
DROP FUNCTION checkIfClientIsConferenceDayParticipant
GO

IF OBJECT_ID('checkIfWorkshopIsAlreadyinDB') IS NOT NULL
DROP FUNCTION checkIfWorkshopIsAlreadyinDB
GO

-- given name of conference returns its id
CREATE FUNCTION
	getConferenceID (@Conference_Name nvarchar(100))
	RETURNS int
	AS
		BEGIN
		RETURN
		( SELECT Conference_ID from Conference where Conference_Name = @Conference_Name )
		END
GO

-- given name of conference return its startdate
CREATE FUNCTION
	getConferenceStartDate(@Conference_Name nvarchar(100))
	RETURNS date
	AS
		BEGIN
		RETURN
		( SELECT StartDate from Conference where Conference_Name = @Conference_Name)
		END
GO

-- given name of conference return its enddate
CREATE FUNCTION
	getConferenceEndDate(@Conference_Name nvarchar(100))
	RETURNS date
	AS
		BEGIN
		RETURN
		( SELECT EndDate from Conference where Conference_Name = @Conference_Name)
		END
GO

-- given name and date returns conferencedayid of conference with given name and date
CREATE FUNCTION
	getConferenceDayID(@Conference_Name nvarchar(100), @ConferenceDay_Date date)
	RETURNS int
	AS
		BEGIN
		RETURN
		( SELECT Conference_Day_ID from Conference_Day
		 JOIN Conference ON Conference.Conference_ID = Conference_Day.Conference_ID 
		 WHERE (Conference.Conference_Name = @Conference_Name AND @ConferenceDay_Date=Conference_Day.Date))
	END
GO

-- given conference_day_id, returns free seats on specific conference day
CREATE FUNCTION 
	getConferenceDayFreeSeats(@Conference_Day_ID int)
	RETURNS int
	AS
		BEGIN
		DECLARE @TotalPlaces AS int
		SET @TotalPlaces = (
			SELECT TotalPlaces
			FROM Conference_Day
			WHERE Conference_Day_ID = @Conference_Day_ID
		)
		DECLARE @OccupiedPlaces AS int
		SET @OccupiedPlaces = (
			SELECT SUM(Reservation_Participants)
			FROM Conference_Day_Reservation
			WHERE (Conference_Day_ID = @Conference_Day_ID AND Reservation_Status != 'C')
		)
		IF @OccupiedPlaces IS NULL
		BEGIN
			SET @OccupiedPlaces = 0
		END
		RETURN (@TotalPlaces - @OccupiedPlaces)
	END
GO

--given workshop_id, returns free seats on specific workshop
CREATE FUNCTION
	getWorkshopFreeSeats(@Workshop_ID int)
	RETURNS int
	AS
		BEGIN
		DECLARE @TotalPlaces AS int
		SET @TotalPlaces = (
			SELECT TotalPlaces
			FROM Workshop
			WHERE Workshop_ID = @Workshop_ID
		)
		DECLARE @OccupiedPlaces AS int
		SET @OccupiedPlaces = (
			SELECT SUM(Reservation_Participant)
			FROM Workshop_Reservation
			WHERE (@Workshop_ID = Workshop_ID AND Reservation_Status != 'C')
		)
		IF @OccupiedPlaces IS NULL
		BEGIN
			SET @OccupiedPlaces = 0
		END
		RETURN (@TotalPlaces - @OccupiedPlaces)
		END
GO

-- given Conference_Day_ID returns its Conference_ID 
CREATE FUNCTION
	getConferenceDayID_ConferenceID(@Conference_Day_ID int)
	RETURNS int
	AS
		BEGIN
		DECLARE @Conference_ID AS int
		SET @Conference_ID = (
			SELECT Conference_ID
			from Conference_Day
			WHERE Conference_Day_ID = @Conference_Day_ID
		)
		RETURN @Conference_ID
		END
GO

CREATE FUNCTION
	getConferenceDayPrice(@Conference_Day_ID int)
	RETURNS int
	AS
		BEGIN
		DECLARE @ConferenceDay_Price AS INT
		SET @ConferenceDay_Price = (
		SELECT Conference_Day.Price
		FROM Conference_Day
		WHERE Conference_Day.Conference_Day_ID = @Conference_Day_ID)
	RETURN @ConferenceDay_Price
	END
GO

-- given Conference_Day_ID and optionally StudentDiscount returns how much one must paid according to price rate
CREATE FUNCTION
	getRealPrice(@Conference_Day_ID int, @Student_IDCard int, @ReservationDate date)
	RETURNS int
	AS
		BEGIN
		DECLARE @Discount_Percent_Today As int
		SET @Discount_Percent_Today = (
			SELECT MAX(Discout_Percent)
			from Conference_Price_Rate
			WHERE (DiscountDay > @ReservationDate)
		)
		IF(@Discount_Percent_Today IS NULL)
			SET @Discount_Percent_Today=0

		DECLARE @Conference_ID AS INT
		SET @Conference_ID = dbo.getConferenceDayID_ConferenceID(@Conference_Day_ID)
		DECLARE @Student_Discount AS INT
		SET @Student_Discount = (
			SELECT Conference.Student_Discount
			from Conference_Day
			JOIN Conference on Conference_Day.Conference_ID = Conference.Conference_ID
			WHERE(Conference_Day.Conference_Day_ID = @Conference_Day_ID)
		)
		DECLARE @TotalDiscount as INT
		IF (@Student_IDCard IS NOT NULL)
		BEGIN
			IF(@Student_Discount + @Discount_Percent_Today > 90)
			BEGIN
				SET @TotalDiscount = 90
			END
			IF(@Student_Discount + @Discount_Percent_Today < 90)
			BEGIN
				SET @TotalDiscount = (@Student_Discount + @Discount_Percent_Today)
			END
		END
		IF (@Student_IDCard IS NULL)
		BEGIN
			SET @TotalDiscount = @Discount_Percent_Today
		END
		RETURN @TotalDiscount
		END
	GO

CREATE FUNCTION
	getLatestPayment()
	RETURNS int
	AS
		BEGIN
		DECLARE @LastPaymentID AS INT
		SET @LastPaymentID = (
			SELECT TOP 1 Payment_ID FROM Payment ORDER BY Payment_ID DESC 
		)
	RETURN @LastPaymentID
	END
GO

CREATE FUNCTION
	getLatestClient()
	RETURNS int
	AS
		BEGIN
		DECLARE @LastClientID AS INT
		SET @LastClientID = (
			SELECT TOP 1 Client_ID FROM Client ORDER BY Client_ID DESC
		)
		RETURN COALESCE (@LastClientID, 0)
	END
GO

CREATE FUNCTION
	getLatestConferenceDayReservation()
	RETURNS int
	AS
		BEGIN
		DECLARE @LatestConferenceDayReservation AS INT
		SET @LatestConferenceDayReservation = (
			SELECT TOP 1 Conference_Day_Reservation_ID from Conference_Day_Reservation ORDER BY Conference_Day_Reservation_ID DESC)
		RETURN @LatestConferenceDayReservation
	END
GO

-- returns clientID if client is in database, otherwise returns 0
CREATE FUNCTION
	checkIfClientIsInDataBase(@NIP nvarchar(20), @Pesel nvarchar(20))
	RETURNS INT
	AS
		BEGIN
		
		DECLARE @isClient AS INT
		SET @isClient =
		(SELECT Client_ID from Client where (PESEL = @Pesel or NIP = @NIP))

		DECLARE @idToReturn AS INT
		IF (@IsClient IS NULL)
			BEGIN 
			Set @idToReturn = 0
			END
		IF (@isClient IS NOT NULL)
			BEGIN
			SET @idToReturn = @isClient
			END
		RETURN @idToReturn
		END
GO

-- returns ConferenceDayReservation given Conference_Day and CompanyName
CREATE FUNCTION
	getConferenceDayReservationID(@Conference_Day_ID int, @NIP nvarchar(20))
	RETURNS INT
	AS
		BEGIN

		DECLARE @ConferenceDayReservationID AS INT
		SET @ConferenceDayReservationID = 
		( SELECT Conference_Day_Reservation_ID From Conference_Day_Reservation JOIN Client on Client.Client_ID = Conference_Day_Reservation.Client_ID WHERE( Client.NIP = @NIP AND Conference_Day_ID = @Conference_Day_ID))

		RETURN @ConferenceDayReservationID
		END
GO

CREATE FUNCTION	
	getClientID(@NIP nvarchar(20))
	RETURNS INT
	AS
		BEGIN
		DECLARE @ClientID AS INT
		SET @ClientID = 
		( SELECT Client_ID from Client where Client.NIP = @NIP)
		RETURN @ClientID
		END
GO

CREATE FUNCTION
	checkIfCompanyNameAndNIPMatches(@NIP varchar(20), @CompanyName nvarchar(100))
	RETURNS INT
	AS
		BEGIN
		DECLARE @Result AS INT
		DECLARE @foundCompanyName AS nvarchar(100)
		SET @foundCompanyName = 
		( SELECT Client.CompanyName from Client where Client.NIP = @NIP)
		IF  (@foundCompanyName IS NULL)
			BEGIN
			SET @Result = 0
			END
		IF (@foundCompanyName = @CompanyName)
			BEGIN
			SET @Result = 1
			END
		RETURN @Result
	END
GO	

CREATE FUNCTION
	getWorkshopID(@ConferenceName nvarchar(100), @WorkshopName nvarchar(50), @Date date, @StartHour time, @EndHour time)
	RETURNS INT
	AS
		BEGIN
		DECLARE @conferenceDayID AS INT
		SET @conferenceDayID = dbo.getConferenceDayID(@ConferenceName, @Date)
		IF(@conferenceDayID IS NULL)
			BEGIN
			RETURN 0
			END
		IF(@conferenceDayID IS NOT NULL)
			BEGIN
				DECLARE @workshopID AS INT
				SET @workshopID = ( SELECT Workshop_ID From Workshop where 
				Workshop.Conference_Day_ID = @conferenceDayID AND Workshop.Workshop_Name = @WorkshopName AND @StartHour = StartHour AND @EndHour = EndHour)
				IF(@workshopID IS NULL)
					BEGIN
						RETURN 0
					END
			END
	RETURN @workshopID
		END
GO

CREATE FUNCTION
	checkIfClientIsRegisteredOnConferenceDay(@Conference_Day_ID int, @Client_ID int)
	RETURNS INT
	AS
		BEGIN
		DECLARE @isClientRegistered AS INT
		SET @isClientRegistered = ( SELECT Conference_Day_Reservation_ID from Conference_Day_Reservation
									WHERE (Conference_Day_Reservation.Conference_Day_ID = @Conference_Day_ID AND
									Conference_Day_Reservation.Client_ID = @Client_ID))
		IF (@isClientRegistered IS NULL)
			BEGIN
			RETURN 0
			END
		
		RETURN @isClientRegistered
		END
GO

CREATE FUNCTION
	getWorkshopPrice(@Conference_ID int, @Workshop_ID int, @Student_ID int)
	RETURNS INT
	AS
		BEGIN
		DECLARE @AmountToPay AS INT
		IF(@Student_ID IS NULL)
			BEGIN
			SET @AmountToPay = ( SELECT Price from Workshop where Workshop_ID = @Workshop_ID)
			END
		IF(@Student_ID IS NOT NULL)
			BEGIN
			DECLARE @StudentDiscount AS INT
			SET @StudentDiscount = ( SELECT Student_Discount from Conference WHERE @Conference_ID = Conference.Conference_ID)
			DECLARE @BasicPrice AS INT
			SET @BasicPrice = ( SELECT Price from Workshop where Workshop_ID = @Workshop_ID)
			SET @AmountToPay = @BasicPrice - @BasicPrice * @StudentDiscount / 100
			END

			RETURN @AmountToPay
	END
GO

CREATE FUNCTION
	getLatestWorkshopReservation()
	RETURNS INT
	AS
		BEGIN
		DECLARE @LastWorkshopReservation AS INT
		SET @LastWorkshopReservation = (
			SELECT TOP 1 Workshop_Reservation_ID FROM Workshop_Reservation ORDER BY Workshop_Reservation_ID DESC
		)
		RETURN @LastWorkshopReservation
	END
GO
			
CREATE FUNCTION
	checkIfClientIsConferenceDayParticipant(@ConferenceDay_ID int, @Conference_Day_Reservation_ID int, @Client_ID int)
	RETURNS INT
	AS
		BEGIN
		DECLARE @checkIfIsParticiapnt AS INT
		SET @checkIfIsParticiapnt =
		( SELECT Conference_Day_Participant_ID from Conference_Day_Participant where (@ConferenceDay_ID = Conference_Day_ID AND Conference_Day_Reservation_ID =
		@Conference_Day_Reservation_ID and @Client_ID = Client_ID))
		IF (@checkIfIsParticiapnt IS NULL)
			BEGIN
			RETURN 0
			END
		RETURN @checkIfIsParticiapnt
		END
GO

CREATE FUNCTION
	getLatestConferenceDayParticipant()
	RETURNS INT
	AS
		BEGIN
		DECLARE @latestParticipantID AS INT
		SET @latestParticipantID = ( SELECT TOP 1 Conference_Day_Participant_ID from Conference_Day_Participant ORDER BY Conference_Day_Participant_ID DESC)
		RETURN @latestParticipantID
		END
GO

CREATE FUNCTION
	checkIfWorkshopIsAlreadyinDB(@Conference_Day_ID int, @Workshop_Name nvarchar(50), @StartHour time, @EndHour time)
	RETURNS INT
	BEGIN
		DECLARE @WorkshopID AS INT
		SET @WorkshopID = (SELECT Workshop_ID From Workshop Where (@Conference_Day_ID = Workshop.Conference_Day_ID AND  @Workshop_Name = Workshop.Workshop_Name
		AND @StartHour = Workshop.StartHour AND @EndHour = Workshop.EndHour))
		IF (@WorkshopID IS NULL)
			BEGIN
			RETURN 0
			END
		RETURN @WorkshopID
	END
GO