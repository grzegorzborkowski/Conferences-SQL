-- create database
	 USE master;
	 GO
	 ALTER DATABASE CONFERENCES SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
	 GO

     IF DB_ID('CONFERENCES') is NOT NULL
          DROP DATABASE CONFERENCES;
          GO
     CREATE DATABASE CONFERENCES
          GO
     USE CONFERENCES
          GO
     
     
-- tables
     -- drop tables 

     -- drop table with 'conference' as a prefix
     IF OBJECT_ID('Conference', 'U') IS NOT NULL
          DROP TABLE Conference;
     IF OBJECT_ID('Conference_Price_Rate', 'U') IS NOT NULL
          DROP TABLE Conference_Price_Rate;
     IF OBJECT_ID('Conference_Day', 'U') IS NOT NULL
          DROP TABLE Conference_Day;
     IF OBJECT_ID('Conference_Day_Participant', 'U') IS NOT NULL
          DROP TABLE Conference_Day_Participant;
     IF OBJECT_ID('Conference_Day_Reservation', 'U') IS NOT NULL
          DROP TABLE Conference_Day_Reservation;

     -- drop table with 'workshop' as a prefix
     IF OBJECT_ID('Workshop', 'U') IS NOT NULL
          DROP TABLE Workshop;
     IF OBJECT_ID('Workshop_Participant', 'U') IS NOT NULL
          DROP TABLE Workshop_Participant;
     IF OBJECT_ID('Workshop_Reservation', 'U') IS NOT NULL
          DROP TABLE Workshop_Reservation;

     -- drop other tables
     IF OBJECT_ID('Payment', 'U') IS NOT NULL
          DROP TABLE Payment;
     IF OBJECT_ID('Client', 'U') IS NOT NULL
          DROP TABLE Client;
     
          
     -- create tables
     
     CREATE TABLE Conference(
          Conference_ID int IDENTITY(1,1) NOT NULL,
          Conference_Name nvarchar(100) UNIQUE NOT NULL,
          StartDate date NOT NULL,
          EndDate date NOT NULL,
          Street nvarchar(100) NOT NULL,
          HouseNumber varchar(7) NOT NULL,
          City nvarchar(100) NOT NULL,
          Country nvarchar(100) NOT NULL,
          Student_Discount tinyint NOT NULL,
          
		  CONSTRAINT PK_Conference PRIMARY KEY CLUSTERED (Conference_ID),
          CONSTRAINT HouseNumber_NotNegative CHECK (HouseNumber > 0),
          CONSTRAINT EndDate_After_StartDate CHECK (EndDate > StartDate),
		  CONSTRAINT Student_Discount_Between0And100 CHECK (Student_Discount BETWEEN 0 and 100)
     )

	   CREATE TABLE Conference_Day(
          Conference_Day_ID int IDENTITY(1,1) NOT NULL,
        
          Conference_ID int FOREIGN KEY REFERENCES Conference(Conference_ID) NOT NULL,
          Date date NOT NULL,
          TotalPlaces int NOT NULL,
          Price money NOT NULL,
          
		  CONSTRAINT PK_ConferenceDay PRIMARY KEY CLUSTERED (Conference_Day_ID),
          CONSTRAINT TotalPlaces_NotNegative CHECK (TotalPlaces > 0)
     )
     
     CREATE TABLE Conference_Price_Rate(
          Conference_Price_Rate_ID int IDENTITY(1,1) NOT NULL,
		  Conference_Day_ID int FOREIGN KEY REFERENCES Conference_Day(Conference_Day_ID) NOT NULL,
          -- discountday is last day when discount is available.
          DiscountDay date NOT NULL,
          Discout_Percent tinyint NOT NULL,
          
		  CONSTRAINT PK_ConferencePriceRate PRIMARY KEY CLUSTERED (Conference_Price_Rate_ID),
          CONSTRAINT Discount_Percent_Between0And100 CHECK (Discout_Percent BETWEEN 0 AND 100)
     )
     
     CREATE TABLE Client(
          Client_ID int IDENTITY (1,1) NOT NULL,
          IsCompany bit NOT NULL,
          CompanyName nvarchar(100),
          FirstName nvarchar(100),
          LastName nvarchar(100),
          Street nvarchar(100) NOT NULL,
          HouseNumber varchar(7) NOT NULL,
          City nvarchar(100) NOT NULL,
          Country nvarchar(100) NOT NULL,
          Student_IDCard int,
          NIP nvarchar(20),
		  PhoneNumber varchar(12) NOT NULL,
          PESEL nvarchar(20),

		  CONSTRAINT PK_Client PRIMARY KEY CLUSTERED (Client_ID)
     )
     
     CREATE TABLE Payment(
          Payment_ID int IDENTITY(1,1) NOT NULL,
          Amount money NOT NULL,
          PaymentType varchar(10) NOT NULL,
     
		CONSTRAINT PK_Payment PRIMARY KEY CLUSTERED (Payment_ID)
	 )
     
     CREATE TABLE Workshop(
          Workshop_ID int IDENTITY (1,1) NOT NULL,
          Conference_Day_ID int FOREIGN KEY REFERENCES Conference_Day(Conference_Day_ID) NOT NULL,
		  Workshop_Name nvarchar(50) NOT NULL,
          StartHour time NOT NULL,
          EndHour time NOT NULL,
          Price money NOT NULL,
          TotalPlaces int NOT NULL,
          

		  CONSTRAINT PK_Workshop PRIMARY KEY CLUSTERED (Workshop_ID),
          CONSTRAINT WorkshopTotalPlaces_NotNegative CHECK (TotalPlaces > 0)
     )
     
     CREATE TABLE Conference_Day_Reservation(
          Conference_Day_Reservation_ID int IDENTITY (1,1) NOT NULL,

          Conference_Day_ID int FOREIGN KEY REFERENCES Conference_Day(Conference_Day_ID) NOT NULL,
          Client_ID int FOREIGN KEY REFERENCES Client(Client_ID) NOT NULL,
          Payment_ID int FOREIGN KEY REFERENCES Payment(Payment_ID) NOT NULL,
          Reservation_Participants int NOT NULL DEFAULT 1,
          Reservation_Date date NOT NULL,
          Reservation_Status nvarchar(5) NOT NULL,
		
			CONSTRAINT PK_ConferenceDayReservation PRIMARY KEY CLUSTERED (Conference_Day_Reservation_ID),
          CONSTRAINT ConferenceDAyReservation_ReservationParticipants_NotNegative CHECK (Reservation_Participants > 0)
     )
      
     CREATE TABLE Conference_Day_Participant(
          Conference_Day_Participant_ID int IDENTITY (1,1) NOT NULL,
          Conference_Day_ID int FOREIGN KEY REFERENCES Conference_Day(Conference_Day_ID) NOT NULL,
          Conference_Day_Reservation_ID int FOREIGN KEY REFERENCES Conference_Day_Reservation(Conference_Day_Reservation_ID) NOT NULL,
          Client_ID int FOREIGN KEY REFERENCES Client(Client_ID) NOT NULL,
          FirstName nvarchar(100),
          LastName nvarchar(100),

		  CONSTRAINT PK_ConferenceDayParticipant PRIMARY KEY CLUSTERED (Conference_Day_Participant_ID)
     )
     
     CREATE TABLE Workshop_Reservation(
          Workshop_Reservation_ID int IDENTITY (1,1) NOT NULL,
          Workshop_ID int FOREIGN KEY REFERENCES Workshop(Workshop_ID) NOT NULL,
          Client_ID int FOREIGN KEY REFERENCES Client(Client_ID) NOT NULL,
          Payment_ID int FOREIGN KEY REFERENCES Payment(Payment_ID) NOT NULL,
          Conference_Day_Reservation_ID int FOREIGN KEY REFERENCES Conference_Day_Reservation(Conference_Day_Reservation_ID) NOT NULL,
          Reservation_Date date NOT NULL,
          Reservation_Status nvarchar(5) NOT NULL,
		  Reservation_Participant int NOT NULL DEFAULT 1,

		  CONSTRAINT PK_WorkshpReservation PRIMARY KEY CLUSTERED (Workshop_Reservation_ID)
     )
     
     CREATE TABLE Workshop_Participant(
          Workshop_Participant_ID int IDENTITY (1,1) NOT NULL,
          Workshop_Reservation_ID int FOREIGN KEY REFERENCES Workshop_Reservation(Workshop_Reservation_ID) NOT NULL,
          Conference_Day_Participant_ID int FOREIGN KEY REFERENCES Conference_Day_Participant(Conference_Day_Participant_ID) NOT NULL,
		  FirstName nvarchar(100),
		  LastName nvarchar(100)

		  CONSTRAINT PK_WorkshopParticipant PRIMARY KEY CLUSTERED (Workshop_Participant_ID)
     )


IF OBJECT_ID('Add_Conference') IS NOT NULL
	DROP PROCEDURE Add_Conference
GO

IF OBJECT_ID('Add_Conference_Price_Rate') IS NOT NULL
	DROP PROCEDURE Add_Conference_Price_Rate
GO

IF OBJECT_ID('Add_Conference_Day') IS NOT NULL
	DROP PROCEDURE Add_Conference_Day
GO

IF OBJECT_ID('Add_Individual_Client') IS NOT NULL
	DROP PROCEDURE Add_Individual_Client
GO


IF OBJECT_ID('Add_Student_Client') IS NOT NULL
	DROP PROCEDURE Add_Student_Client
GO

IF OBJECT_ID('Add_Company_Client') IS NOT NULL
	DROP PROCEDURE Add_Company_Client
GO

IF OBJECT_ID('Add_Conference_Day') IS NOT NULL
	DROP PROCEDURE Add_Conference_Day
GO

IF OBJECT_ID('Add_Conference_Day_Conference_ID') IS NOT NULL
	DROP PROCEDURE Add_Conference_Day_Conference_ID
GO

IF OBJECT_ID('Add_Conference_Price_Date_Given_ConferenceDayID') IS NOT NULL
	DROP PROCEDURE Add_Conference_Price_Date_Given_ConferenceDayID
GO

IF OBJECT_ID('Add_Payment') IS NOT NULL
	DROP PROCEDURE Add_Payment
GO

IF OBJECT_ID('Add_Conference_Price_Rate') IS NOT NULL
	DROP PROCEDURE Add_Conference_Price_Rate
GO

IF OBJECT_ID('Add_Conference_Day_Individual_Reservation') IS NOT NULL
	DROP PROCEDURE Add_Conference_Day_Individual_Reservation
GO

IF OBJECT_ID('Add_Conference_Day_Company_Reservation') IS NOT NULL
	DROP PROCEDURE Add_Conference_Day_Company_Reservation
GO

IF OBJECT_ID('Add_Conference_Day_Participant_ToCompanyReservation') IS NOT NULL
	DROP PROCEDURE Add_Conference_Day_Participant_ToCompanyReservation
GO

IF OBJECT_ID('Add_Workshop_IndividualClient_Reservation') IS NOT NULL
	DROP PROCEDURE Add_Workshop_IndividualClient_Reservation
GO

IF OBJECT_ID('Add_Workshop') IS NOT NULL
	DROP PROCEDURE Add_Workshop
GO

IF OBJECT_ID('Cancel_All_Unpaid_Conference_Day_Reservation') IS NOT NULL
	DROP PROCEDURE Cancel_All_Unpaid_Conference_Day_Reservation
GO

IF OBJECT_ID('Cancel__All_Unpaid_Workshop_Reservation') IS NOT NULL
	DROP PROCEDURE Cancel_All_Unpaid_Workshop_Reservation
GO

CREATE PROCEDURE Cancel_All_Unpaid_Conference_Day_Reservation
	AS
	BEGIN
	SET NOCOUNT ON;
	UPDATE Conference_Day_Reservation SET Reservation_Status = 'C' WHERE ((DATEDIFF(day, Conference_Day_Reservation.Reservation_Date,  GETDATE())>7) AND Conference_Day_Reservation.Reservation_Status = 'R')

	UPDATE Workshop_Reservation SET Reservation_Status = 'C' WHERE (Workshop_Reservation_ID IN (SELECT Workshop_Reservation_ID
	FROM Workshop_Reservation JOIN Conference_Day_Reservation ON Conference_Day_Reservation.Conference_Day_Reservation_ID = Workshop_Reservation.Conference_Day_Reservation_ID
	WHERE (DATEDIFF(day, Conference_Day_Reservation.Reservation_Date, GETDATE())>7 AND Conference_Day_Reservation.Reservation_Status = 'C')))
	END
GO

CREATE PROCEDURE Cancel_All_Unpaid_Workshop_Reservation
	AS
	BEGIN
	SET NOCOUNT ON;
	UPDATE Workshop_Reservation SET Reservation_Status = 'C' WHERE ((DATEDIFF(day, Workshop_Reservation.Reservation_Date, GETDATE())>7) AND Workshop_Reservation.Reservation_Status = 'R')
	END
GO

CREATE PROCEDURE Add_Conference
	@Conference_Name nvarchar(100),
	@StartDate date,
	@EndDate date,
	@Street nvarchar(100),
	@HouseNumber varchar(7),
	@City nvarchar(100),
	@Country nvarchar(100),
	@Student_Discount tinyint
	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.Conference
		(Conference_Name, StartDate, EndDate, Street, HouseNumber, City, Country, Student_Discount)
		VALUES (@Conference_Name, @StartDate, @EndDate, @Street, @HouseNumber, @City, @Country, @Student_Discount)
	END
GO

CREATE PROCEDURE Add_Conference_Price_Rate
	@ConferenceName nvarchar(100),
	@DayOfConference date,
	@DiscountDay date,
	@Discount_Percent tinyint
	AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @Conference_Day_ID AS int
		 SET @Conference_Day_ID = dbo.getConferenceDayID(@ConferenceName, @DayOfConference)
		INSERT INTO dbo.Conference_Price_Rate
		(Conference_Day_ID, DiscountDay, Discout_Percent)
		VALUES (@Conference_Day_ID, @DiscountDay, @Discount_Percent)
	END
GO

CREATE PROCEDURE Add_Individual_Client
	@FirstName nvarchar(100),
	@LastName nvarchar(100),
	@Street nvarchar(100),
	@HouseNumber varchar(7),
	@City nvarchar(100),
	@Country nvarchar(100),
	@Student_IDCard int,
	@PhoneNumber varchar(12),
	@PESEL nvarchar(20)

	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.Client
			(IsCompany, CompanyName, FirstName, LastName, Street, HouseNumber, City, Country, Student_IDCard, NIP, PhoneNumber, PESEL)
			VALUES (0, NULL, @FirstName, @LastName, @Street, @HouseNumber, @City, @Country, @Student_IDCard, NULL, @PhoneNumber, @PESEL)
	END
GO	

CREATE PROCEDURE Add_Individual_Client_WithID
	@ClientID int,
	@FirstName nvarchar(100),
	@LastName nvarchar(100),
	@Street nvarchar(100),
	@HouseNumber varchar(7),
	@City nvarchar(100),
	@Country nvarchar(100),
	@Student_IDCard int,
	@PhoneNumber varchar(12),
	@PESEL nvarchar(20)

	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.Client
			(Client_ID,IsCompany, CompanyName, FirstName, LastName, Street, HouseNumber, City, Country, Student_IDCard, NIP, PhoneNumber, PESEL)
			VALUES (@ClientID, 0, NULL, @FirstName, @LastName, @Street, @HouseNumber, @City, @Country, @Student_IDCard, NULL, @PhoneNumber, @PESEL)
	END
GO	

CREATE PROCEDURE Add_Company_Client
	@CompanyName nvarchar(100),
	@Street nvarchar(100),
	@HouseNumber varchar(7),
	@City nvarchar(100),
	@Country nvarchar(100),
	@PhoneNumber varchar(12),
	@NIP nvarchar(20)

	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.Client
		(IsCompany, CompanyName, FirstName, LastName, Street, HouseNumber, City, Country, Student_IDCard, PhoneNumber, NIP, PESEL)
		VALUES (1, @CompanyName, NULL, NULL, @Street, @HouseNumber, @City, @Country, NULL, @PhoneNumber, @NIP, NULL)
	END
GO

CREATE PROCEDURE Add_Conference_Day
	@ConferenceName nvarchar(100),
	@date date, @totalPlaces int,
	@price money

	AS
		DECLARE @ConferenceStartDate AS date SET @ConferenceStartDate = dbo.getConferenceStartDate(@ConferenceName)
		DECLARE @ConferenceEndDate AS date SET @ConferenceEndDate = dbo.getConferenceEndDate(@ConferenceName)
		IF (@date >= @ConferenceStartDate AND @ConferenceEndDate >= @date)
			BEGIN
				SET NOCOUNT ON;
				DECLARE @ConferenceID AS int SET @ConferenceID = dbo.getConferenceID(@ConferenceName)
				INSERT INTO dbo.Conference_Day(Conference_ID, Date, TotalPlaces, Price)
				VALUES (@ConferenceID, @date, @totalPlaces, @price)
			END
		ELSE
				PRINT 'Given date is not between Conference StartDate and EndDate'
GO

CREATE PROCEDURE Add_Conference_Day_Conference_ID
	@ConferenceID int,
	@totalPlaces int,
	@price money

	AS BEGIN
		DECLARE @ConferenceStartDate AS date SET @ConferenceStartDate = ( SELECT Conference.StartDate from Conference
		where Conference.Conference_ID = @ConferenceID)
		DECLARE @ConferenceEndDate AS date SET @ConferenceEndDate = (SELECT Conference.EndDate from Conference
		where Conference.Conference_ID = @ConferenceID)
		INSERT INTO dbo.Conference_Day(Conference_ID, Date, TotalPlaces, Price)
		VALUES (@ConferenceID, @ConferenceStartDate, @totalPlaces, @price),
		(@ConferenceID, @ConferenceEndDate, @totalPlaces, @price)

		END
GO

CREATE PROCEDURE Add_Conference_Price_Date_Given_ConferenceDayID
	@ConferenceDayID int,
	@howManyDaysAgo int,
	@Discount_Percent int

	AS BEGIN
		DECLARE @ConferenceDayDate as date
		SET @ConferenceDayDate = ( Select Date from Conference_Day where @ConferenceDayID = Conference_Day_ID)
		DECLARE @CalculatedDiscountDay as date
		SET @CalculatedDiscountDay = DATEADD(day, -@howManyDaysAgo, @ConferenceDayDate)
		INSERT INTO dbo.Conference_Price_Rate(Conference_Day_ID, DiscountDay, Discout_Percent)
		VALUES (@ConferenceDayID, @CalculatedDiscountDay, @Discount_Percent)
	END
GO
		
CREATE PROCEDURE Add_Payment
	@Amount money,
	@PaymentType varchar(10)

	AS
	BEGIN
		SET NOCOUNT ON;
		INSERT INTO dbo.Payment
		(Amount, PaymentType)
		VALUES (@Amount, @PaymentType)
	END
GO

CREATE PROCEDURE Add_Conference_Day_Individual_Reservation
	@Conference_Day_ID int,
	@FirstName nvarchar(100),
	@LastName nvarchar(100),
	@City nvarchar(100),
	@Country nvarchar(100),
	@Street nvarchar(100),
	@HouseNumber varchar(7),
	@Student_IDCard int,
	@PhoneNumber varchar(12),
	@PESEL nvarchar(20),
	@PaymentType varchar(10),
	@DaysBefore int
	

	AS
	BEGIN
		SET NOCOUNT ON;
		DECLARE @ConferenceDayDate as date
		SET @ConferenceDayDate = ( SELECT Date From Conference_Day where @Conference_Day_ID = Conference_Day_ID)
		 
		
		DECLARE @ReservationDate as date

		SET @ReservationDate = DATEADD(day, -@DaysBefore, @ConferenceDayDate)

		DECLARE @FreeSeats AS int
		SET @FreeSeats = dbo.getConferenceDayFreeSeats(@Conference_Day_ID)
		DECLARE @TotalDiscount AS INT
		SET @TotalDiscount = dbo.getRealPrice(@Conference_Day_ID, @Student_IDCard, @ReservationDate)
		DECLARE @Conference_Day_BasicPrice AS INT
		SET @Conference_Day_BasicPrice = dbo.getConferenceDayPrice(@Conference_Day_ID)
		DECLARE @TotalPrice AS INT
		IF(@TotalDiscount>0)
		BEGIN
			SET @TotalPrice = @Conference_Day_BasicPrice - (@Conference_Day_BasicPrice * @TotalDiscount / 100)
		END
		IF(@TotalDiscount=0)
		BEGIN
			SET @TotalPrice = @Conference_Day_BasicPrice
		END
		PRINT @TotalPrice
		BEGIN TRANSACTION
		IF @FreeSeats > 0
		BEGIN
			
				exec Add_Payment @TotalPrice, @PaymentType

				IF @@ERROR <> 0
				BEGIN
					RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
				END

				DECLARE @LatestPaymentID AS INT
				SET @LatestPaymentID = dbo.getLatestPayment()

				DECLARE @IsClientINDB AS INT
				SET @IsClientINDB = dbo.checkIfClientIsInDataBase(NULL, @PESEL)
				IF (@IsClientINDB = 0)
					BEGIN
				
						exec Add_Individual_Client @FirstName, @LastName, @Street, @HouseNumber, @City, @Country, @Student_IDCard, @PhoneNumber, @PESEL
				
						IF @@ERROR <> 0
						BEGIN
							RAISERROR('error', 16, 1)
							ROLLBACK TRANSACTION
						END

						DECLARE @LatestClientID AS INT
						SET @LatestClientID = dbo.getLatestClient()
						SET @IsClientINDB = @LatestClientID
						
					END
				IF(@IsClientINDB > 0)
					BEGIN
						INSERT INTO dbo.Conference_Day_Reservation
						(Conference_Day_ID, Client_ID, Payment_ID, Reservation_Participants, Reservation_Date, Reservation_Status)
						VALUES (@Conference_Day_ID, @IsClientINDB, @LatestPaymentID, 1, @ReservationDate, 'R')
						
						IF @@ERROR <> 0
						BEGIN
							RAISERROR('error', 16, 1)
							ROLLBACK TRANSACTION
						END
					END

				DECLARE @LatestConferenceDayReservation AS INT
				SET @LatestConferenceDayReservation = dbo.getLatestConferenceDayReservation()
				INSERT INTO dbo.Conference_Day_Participant
				(Conference_Day_ID, Conference_Day_Reservation_ID, Client_ID, FirstName, LastName)
				VALUES (@Conference_Day_ID, @LatestConferenceDayReservation, @IsClientINDB, @FirstName, @LastName)
				IF @@ERROR <> 0
				BEGIN
					RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
				END
		END

		IF @FreeSeats = 0
		BEGIN
			PRINT 'NO FREE SEATS FOR THIS CONFERENCE DAY'
			RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
		END
		COMMIT TRANSACTION
END
GO

-- if RegisterStudents is NULL then Company registers non-students participants
-- if RegisterStudents is NOT NULL then Company registers students particpants
CREATE PROCEDURE Add_Conference_Day_Company_Reservation
	@RegisterStudents int,
	@Conference_Name nvarchar(100),
	@Date date,
	@CompanyName nvarchar(100),
	@City nvarchar(100),
	@Country nvarchar(100),
	@Street nvarchar(100),
	@HouseNumber varchar(7),
	@NIP nvarchar(20),
	@PhoneNumber varchar(12),
	@PaymentType varchar(10),
	@Reservation_Participants int,
	@ReservationDate date

	AS
	BEGIN
	SET NOCOUNT ON;
	DECLARE @Conference_Day_ID AS INT
	SET @Conference_Day_ID = dbo.getConferenceDayID(@Conference_Name, @Date)
	DECLARE @FreeSeats AS INT
	SET @FreeSeats = dbo.getConferenceDayFreeSeats(@Conference_Day_ID)
	DECLARE @TotalDiscount AS INT
	SET @TotalDiscount = dbo.getRealPrice(@Conference_Day_ID, @RegisterStudents, @ReservationDate)
	DECLARE @ConferenceDayBasicPrice AS INT
	SET @ConferenceDayBasicPrice = dbo.getConferenceDayPrice(@Conference_Day_ID)
	DECLARE @TotalPrice AS INT
	IF (@TotalDiscount>0)
		BEGIN
		SET @TotalPrice = @ConferenceDayBasicPrice - (@ConferenceDayBasicPrice * @TotalDiscount / 100 )
		END
	IF (@TotalDiscount = 0)
		BEGIN
		SET @TotalPrice = @ConferenceDayBasicPrice
		END
	IF (@FreeSeats - @Reservation_Participants >= 0)
		BEGIN
		BEGIN TRANSACTION
		DECLARE @TotalAmountOfMoney AS INT
		SET @TotalAmountOfMoney = @Reservation_Participants * @TotalPrice
		exec Add_Payment @TotalAmountOfMoney, @PaymentType

		IF @@ERROR <> 0
				BEGIN
					RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
				END

		DECLARE @LatestPaymentID AS INT
		SET @LatestPaymentID = dbo.getLatestPayment()

		DECLARE @IsClientinDB AS INT
		SET @IsClientinDB = dbo.checkIfClientIsInDataBase(@NIP, NULL)
		IF (@IsClientINDB = 0)
			BEGIN

			exec Add_Company_Client @CompanyName, @Street, @HouseNumber, @City, @Country, @PhoneNumber, @NIP
			IF @@ERROR <> 0
						BEGIN
							RAISERROR('error', 16, 1)
							ROLLBACK TRANSACTION
						END

			DECLARE @LatestClientID AS INT
			SET @LatestClientID = dbo.getLatestClient()
						
			INSERT INTO dbo.Conference_Day_Reservation
			(Conference_Day_ID, Client_ID, Payment_ID, Reservation_Participants, Reservation_Date, Reservation_Status)
			VALUES (@Conference_Day_ID, @LatestClientID, @LatestPaymentID, @Reservation_Participants, @ReservationDate, 'R')

		END
		IF (@IsClientinDB > 0)
			BEGIN
			DECLARE @isCompanyOnGivenNIP AS INT
			SET @isCompanyOnGivenNIP = dbo.checkIfCompanyNameAndNIPMatches(@NIP, @CompanyName)
			IF (@isCompanyOnGivenNIP <> 1)
				BEGIN
				PRINT 'Company on GIVEN NIP does not match given CompanyName'
				RAISERROR('error', 16, 1)
							ROLLBACK TRANSACTION
				END


			INSERT INTO dbo.Conference_Day_Reservation
						(Conference_Day_ID, Client_ID, Payment_ID, Reservation_Participants, Reservation_Date, Reservation_Status)
						VALUES (@Conference_Day_ID, @IsClientINDB, @LatestPaymentID, @Reservation_Participants, @ReservationDate, 'R')
						
						IF @@ERROR <> 0
						BEGIN
							RAISERROR('error', 16, 1)
							ROLLBACK TRANSACTION
						END
			END
		

		COMMIT TRANSACTION
		END
		IF (@FreeSeats - @Reservation_Participants < 0)
			PRINT 'Not enough free seats for this conference_day'
			END
GO

CREATE PROCEDURE Add_Conference_Day_Participant_ToCompanyReservation
	@Conference_Name nvarchar(100),
	@NIP nvarchar(20),
	@Date date,
	@FirstName nvarchar(100),
	@LastName nvarchar(100)
	AS
	BEGIN

	BEGIN TRANSACTION

	DECLARE @Conference_Day_ID AS INT
		SET @Conference_Day_ID = dbo.getConferenceDayID(@Conference_Name, @Date)

		PRINT @Conference_Day_ID
	
	DECLARE @ConferenceDayReservation_ID AS INT
		SET @ConferenceDayReservation_ID = dbo.getConferenceDayReservationID(@Conference_Day_ID, @NIP)
	
	IF(@ConferenceDayReservation_ID IS NULL)
	BEGIN
		PRINT 'NO SUCH Conference Day Reservation'
		ROLLBACK TRANSACTION
	END
	
	DECLARE @Client_ID AS INT
		SET @Client_ID = dbo.getClientID(@NIP)

	IF (@Client_ID IS NULL)
	BEGIN
		PRINT 'NO SUCH CLIENT REGISTERED ON THIS CONFERENCE DAY'
		ROLLBACK TRANSACTION
	END
	
	INSERT INTO dbo.Conference_Day_Participant(Conference_Day_ID, Conference_Day_Reservation_ID, Client_ID, FirstName, LastName)
	VALUES (@Conference_Day_ID, @ConferenceDayReservation_ID, @Client_ID, @FirstName, @LastName)

	IF @@ERROR <> 0
	BEGIN
		RAISERROR('error', 16, 1)
		ROLLBACK TRANSACTION
	END

	COMMIT TRANSACTION

	END
GO

CREATE PROCEDURE Add_Workshop_IndividualClient_Reservation
	@WorkshopID int,
	@FirstName nvarchar(100),
	@LastName nvarchar(100),
	@Street nvarchar(100),
	@HouseNumber varchar(7),
	@City nvarchar(100),
	@Country nvarchar(100),
	@Student_IDCard int,
	@PhoneNumber nvarchar(12),
	@Pesel nvarchar(20),
	@PaymentType varchar(10),
	@DaysBefore int
	
	AS
	BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION

	-- get conferenceDay__ID
	DECLARE @Conference_Day_ID AS INT
	SET @Conference_Day_ID = (SELECT Conference_Day_ID from Workshop where @WorkshopID = Workshop_ID)

	DECLARE @Conference_ID AS INT
	SET @Conference_ID = ( SELECT Conference_Day.Conference_ID from Conference_Day where Conference_Day.Conference_Day_ID = @Conference_Day_ID)

	DECLARE @WorkshopDate as date
	SET @WorkshopDate = ( SELECT TOP 1 Conference_Day.Date from Workshop JOIN Conference_Day ON @Conference_Day_ID = @Conference_Day_ID WHERE Workshop_ID = @WorkshopID)

	DECLARE @Reservation_Date as date
	SET @Reservation_Date = DATEADD(day, -@DaysBefore, @WorkshopDate)

	DECLARE @TotalAmountToPay AS INT
	SET @TotalAmountToPay = dbo.getWorkshopPrice(@Conference_ID, @WorkshopID, @Student_IDCard)
	INSERT INTO Payment (Amount, PaymentType) VALUES (@TotalAmountToPay, @PaymentType)

	DECLARE @LatestPaymentID as INT
	SET @LatestPaymentID = dbo.getLatestPayment()

	-- get the client id if exists
	DECLARE @Client_ID AS INT
	SET @Client_ID = dbo.checkIfClientIsInDataBase(NULL, @Pesel)
	IF(@Client_ID IS NULL)
		BEGIN
		RAISERROR('error', 16, 1)
		Print 'An error occured in checkIfClientIsinDataBase function'
		ROLLBACK TRANSACTION
		END
		-- that client is not yet in database. He must be added.
	IF (@Client_ID = 0)
		BEGIN
		INSERT INTO Client
		(IsCompany, CompanyName, FirstName, LastName, Street, HouseNumber, City, Country, Student_IDCard, NIP, PhoneNumber, PESEL)
		VALUES (0, NULL, @FirstName, @LastName, @Street, @HouseNumber, @City, @Country, @Student_IDCard, NULL, @PhoneNumber, @Pesel)
		DECLARE @ClientToInsert AS INT
		SET @ClientTOInsert = dbo.getLatestClient()
		

		IF @@ERROR <> 0
				BEGIN
					PRINT 'Couldnt add Client into Client table'
					RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
				END

	
	-- check if client on given Client_ID is registered on Conference_Day when the workshop takes place
	DECLARE @Conference_Day_Reservation_ID AS INT
	SET @Conference_Day_Reservation_ID = dbo.checkIfClientIsRegisteredOnConferenceDay(@Conference_Day_ID, @Client_ID)

	IF (@Conference_Day_Reservation_ID IS NULL)
					BEGIN
					PRINT 'An error in checkIfClientIsRegisteredOnConferenceDay function'
					RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
					END
	IF(@Conference_Day_Reservation_ID = 0)
		BEGIN
		INSERT INTO Conference_Day_Reservation(Conference_Day_ID, Client_ID, Payment_ID, Reservation_Participants, Reservation_Date, Reservation_Status)
		VALUES (@Conference_Day_ID, @ClientTOInsert, @LatestPaymentID, 1, @Reservation_Date, 'R')
		END

	SET @Conference_Day_Reservation_ID = dbo.getLatestConferenceDayReservation()

	-- chceck if client is already in cofenrence_Day_participant tabel, if not insert him into it

	DECLARE @Conference_Day_Participant_ID AS INT
	SET @Conference_Day_Participant_ID = dbo.checkIfClientIsConferenceDayParticipant(@Conference_Day_ID, @Conference_Day_Reservation_ID, @Client_ID)
	IF (@Conference_Day_Participant_ID IS NULL)
		BEGIN
		PRINT 'An error in checkIfClientIsConferenceDayParticipant function'
		RAISERROR('error', 16, 1)
		ROLLBACK TRANSACTION
		END
	IF(@Conference_Day_Participant_ID = 0)
		BEGIN
		INSERT INTO Conference_Day_Participant(Conference_Day_ID, Conference_Day_Reservation_ID, Client_ID, FirstName, LastName)
		VALUES(@Conference_Day_ID, @Conference_Day_Reservation_ID, @ClientTOInsert, @FirstName, @LastName)
					IF @@ERROR <>0 
					BEGIN
					PRINT 'An error occured during inserting into conference_Day_participant table'
					RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
					END
		
		SET @Conference_Day_Participant_ID = dbo.getLatestConferenceDayParticipant()
		IF (@Conference_Day_Participant_ID IS NULL OR @Conference_Day_Participant_ID=0)
		BEGIN
		PRINT 'An error in getLatestConferenceDayParticipant function'
		RAISERROR('error', 16, 1)
		ROLLBACK TRANSACTION
		END
	
	END
	
	
	-- inserto workshop_reservation
	INSERT INTO Workshop_Reservation(Workshop_ID, Client_ID, Payment_ID, Conference_Day_Reservation_ID, Reservation_Date, Reservation_Status, Reservation_Participant)
		VALUES (@WorkshopID, @ClientTOInsert, @LatestPaymentID, @Conference_Day_Reservation_ID, @Reservation_Date, 'R', 1)

	IF @@ERROR <>0 
					BEGIN
					PRINT 'An error occured during inserting into workshop_reservation'
					RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
					END

	DECLARE @LatestWorkshopReservation AS INT
	SET @LatestWorkshopReservation = dbo.getLatestWorkshopReservation()

	INSERT INTO Workshop_Participant(Workshop_Reservation_ID, Conference_Day_Participant_ID, FirstName, LastName)
		VALUES (@LatestWorkshopReservation, @Conference_Day_Participant_ID, @FirstName, @LastName)
		IF @@ERROR <>0 
					BEGIN
					PRINT 'An error occured during inserting into Workshop_Participant'
					RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
					END	
		

			COMMIT TRANSACTION
			END
	END
GO

CREATE PROCEDURE Add_Workshop
	@Conference_Day_ID int,
	@Workshop_Name nvarchar(50),
	@StartHour time,
	@EndHour time,
	@Price money,
	@TotalPlaces int

	AS
	BEGIN
	SET NOCOUNT ON;
	BEGIN TRANSACTION
	

	DECLARE @workshopID AS INT
	SET @workshopID = dbo.checkIfWorkshopIsAlreadyinDB(@Conference_Day_ID, @Workshop_Name, @StartHour, @EndHour)
	IF (@workshopID IS NULL)
		BEGIN
			RAISERROR('error', 16, 1)
			Print 'There is an error in checkIfWorkshopIsAlreadyinDB'
			ROLLBACK TRANSACTION
			END

	IF(@workshopID > 0)
		BEGIN
		RAISERROR('error', 16, 1)
			Print 'There is already such a workshop in DB'
			ROLLBACK TRANSACTION
			END
		END

	IF(@workshopID = 0)
		BEGIN
	INSERT INTO Workshop(Conference_Day_ID, Workshop_Name, StartHour, EndHour, Price, TotalPlaces)
	VALUES (@Conference_Day_ID, @Workshop_Name, @StartHour, @EndHour, @Price, @TotalPlaces)

	IF (@@ERROR <> 0)
			BEGIN
			RAISERROR('error', 16, 1)
			Print 'There is no such a conference day on given date in database'
			ROLLBACK TRANSACTION
			END
	

	COMMIT TRANSACTION

		END

GO

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

			IF(@AmountToPay IS NULL)
				SET @AmountToPay = 0

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

IF OBJECT_ID('WorkshopPlacesLessThanConferenceDayPlaces') IS NOT NULL
	DROP TRIGGER WorkshopPlacesLessThanConferenceDayPlaces
GO

IF OBJECT_ID('CheckForTwoTheSamePriceRates') IS NOT NULL
	DROP TRIGGER CheckForTwoTheSamePriceRates
GO

IF OBJECT_ID('ConferencesNoLongerThanWeek') IS NOT NULL
	DROP TRIGGER ConferencesNoLongerThanWeek
GO

CREATE TRIGGER WorkshopPlacesLessThanConferenceDayPlaces
ON WORKSHOP
AFTER INSERT, UPDATE
AS BEGIN
	SET NOCOUNT ON;
	Declare @WorkshopTotalPlaces int = (Select TotalPlaces from inserted)
	DECLARE @ConferenceDayTotalPlaces int = (Select Conference_Day.TotalPlaces from inserted
	JOIN Conference_Day ON inserted.Conference_Day_ID = Conference_Day.Conference_Day_ID)

	IF(@WorkshopTotalPlaces > @ConferenceDayTotalPlaces)
		BEGIN
		RAISERROR ('Workshop has more places than related to it conference day', 16, 1)
		ROLLBACK TRANSACTION
		END
END
GO

CREATE TRIGGER ConferencesNoLongerThanWeek
On Conference
AFTER INSERT, UPDATE
AS BEGIN
SET NOCOUNT ON;
	DECLARE @StartDate date = (SELECT StartDate from inserted)
	DECLARE @EndDate date = (SELECT EndDate from inserted)

	IF(DATEDIFF(day, @StartDate, @EndDate)>7)
		BEGIN
		RAISERROR('Conference can last longer than a week', 16, 1)
		ROLLBACK TRANSACTION
		END

END
GO

USE CONFERENCES
--  views

IF OBJECT_ID('Upcoming_Conferences') IS NOT NULL
	DROP VIEW Upcoming_Conferences
GO

IF OBJECT_ID('Upcoming_Workshops') IS NOT NULL
	DROP VIEW Upcoming_Workshops
GO

IF OBJECT_ID('Upcoming_Conferences_CompanyClients') IS NOT NULL
	DROP VIEW Upcoming_Conferences_Clients
GO

IF OBJECT_ID('Upcoming_Conferences_IndividualClients') IS NOT NULL
	DROP VIEW Upcoming_Conferences_IndividualClients
GO

IF OBJECT_ID('Upcoming_Conferences_Participants') IS NOT NULL
	DROP VIEW Upcoming_Conferences_Participants
GO

IF OBJECT_ID('Upcoming_Workshops_CompanyClients') IS NOT NULL
	DROP VIEW Upcoming_Workshops_CompanyClients
GO

IF OBJECT_ID('Upcoming_Workshops_IndividualClients') IS NOT NULL
	DROP VIEW Upcoming_Workshops_IndividualClients
GO

IF OBJECT_ID('Upcoming_Workshops_Participants') IS NOT NULL
	DROP VIEW Upcoming_Workshops_Participants
GO

IF OBJECT_ID('NotPaid_ConferenceDayReservations') IS NOT NULL
	DROP VIEW NotPaid_ConferenceDayReservations
GO

IF OBJECT_ID('NotPaid_WorkshopReservations') IS NOT NULL
	DROP VIEW NotPaid_WorkshopReservations
GO

IF OBJECT_ID('Client_Activity') IS NOT NULL
	DROP VIEW Client_Activity
GO

-- all conferences which will take place in the future
CREATE VIEW Upcoming_Conferences
	AS
	SELECT Conference_Name, MIN(StartDate) as StartDate, MAX(EndDate) as EndDate, Street, HouseNumber, City, Country, Student_Discount 
	FROM Conference
	JOIN Conference_Day ON Conference.Conference_ID = Conference_Day.Conference_ID
	GROUP BY Conference_Name, City, Street, HouseNumber, Country, Student_Discount
	HAVING Min(StartDate) > GETDATE()
GO

-- all workshops which will take place in the future

CREATE VIEW Upcoming_Workshops
	AS
	SELECT Conference.Conference_Name, Workshop_Name, StartHour, EndHour, Workshop.Price, Workshop.TotalPlaces, Workshop.TotalPlaces -
	(	SELECT SUM(Workshop_Reservation.Reservation_Participant) 
		FROM Workshop_Reservation  
		WHERE Workshop_Reservation.Workshop_ID = Workshop.Workshop_ID
		AND Workshop_Reservation.Reservation_Status != 'C') as FreePlaces
	FROM Workshop
	JOIN Conference_Day ON Workshop.Conference_Day_ID = Conference_Day.Conference_Day_ID
	JOIN Conference ON Conference.Conference_ID = Conference_Day.Conference_ID
	WHERE Conference_Day.Date > GETDATE()
GO

-- all upcoming conferences company clients
CREATE VIEW Upcoming_Conferences_CompanyClients
	AS
	SELECT Conference.Conference_Name, SUM(Conference_Day_Reservation.Reservation_Participants) as TotalPlaces, Client.CompanyName
	FROM Conference
	JOIN Conference_Day ON Conference.Conference_ID = Conference_Day.Conference_Day_ID
	JOIN Conference_Day_Reservation ON Conference_Day_Reservation.Conference_Day_ID = Conference_Day.Conference_Day_ID
	JOIN Client ON Client.Client_ID = Conference_Day_Reservation.Client_ID
	WHERE (Conference_Day.Date > GETDATE() and Client.IsCompany = 1)
	AND Conference_Day_Reservation.Reservation_Status != 'C'
	GROUP BY Conference.Conference_Name, Client.CompanyName
GO

-- all upcoming conferences individual clients
CREATE VIEW Upcoming_Conferences_IndividualClients
	AS
	SELECT Conference.Conference_Name, Client.FirstName, Client.LastName
	FROM Conference
	JOIN Conference_Day ON Conference.Conference_ID = Conference_Day.Conference_Day_ID
	JOIN Conference_Day_Reservation ON Conference_Day_Reservation.Conference_Day_ID = Conference_Day.Conference_Day_ID
	JOIN Client ON Client.Client_ID = Conference_Day_Reservation.Client_ID
	WHERE (Conference_Day.Date > GETDATE() and Client.IsCompany = 0 AND Client.FirstName IS NOT NULL and Client.LastName IS NOT NULL
	AND Conference_Day_Reservation.Reservation_Status != 'C')
	GROUP BY Conference.Conference_Name, .Client.FirstName, .Client.LastName
GO

-- all upcoming conferences participants
CREATE VIEW Upcoming_Conferences_Participants
	AS
	SELECT DISTINCT Conference_Day_Participant.Conference_Day_Participant_ID AS 'ParticipantID', Conference.Conference_Name AS 'Conference_Name', Conference_Day_Participant.FirstName, 
	Conference_Day_Participant.LastName, Client.Client_ID AS 'Registered by'
	FROM Conference
	JOIN Conference_Day ON Conference.Conference_ID = Conference_Day.Conference_Day_ID
	JOIN Conference_Day_Participant ON Conference_Day.Conference_Day_ID = Conference_Day_Participant.Conference_Day_Participant_ID
	JOIN Client ON Conference_Day_Participant.Client_ID = Client.Client_ID
	JOIN Conference_Day_Reservation ON Conference_Day_Reservation.Conference_Day_ID = Conference_Day.Conference_Day_ID
	WHERE (Conference_Day.Date > GETDATE() AND Conference_Day_Reservation.Reservation_Status != 'C')
	GROUP BY  Conference.Conference_Name, Conference_Day_Participant.LastName, Conference_Day_Participant.FirstName, Client.Client_ID, Conference_Day_Participant.Conference_Day_Participant_ID
GO

-- all upcoming workshop company clients
CREATE VIEW Upcoming_Workshop_CompanyClients
	AS
	SELECT Workshop.Workshop_Name, Conference.Conference_Name, SUM(Workshop_Reservation.Reservation_Participant) as TotalPlaces, Client.CompanyName
	FROM Workshop
	JOIN Workshop_Reservation ON Workshop_Reservation.Workshop_ID = Workshop.Workshop_ID
	JOIN Client ON Client.Client_ID = Workshop_Reservation.Client_ID
	JOIN Conference_Day ON Workshop.Conference_Day_ID = Conference_Day.Conference_Day_ID
	JOIN Conference ON Conference.Conference_ID = Conference_Day.Conference_ID
	WHERE (Conference_Day.Date > GETDATE() AND Workshop_Reservation.Reservation_Status != 'C' AND Client.IsCompany = 1)
	GROUP BY Workshop.Workshop_Name, Conference.Conference_Name, Client.CompanyName
GO

-- all upcoming workshop individual clients
CREATE VIEW Upcoming_Workshop_IndividualClients
	AS
	SELECT Workshop.Workshop_Name, Conference.Conference_Name, SUM(Workshop_Reservation.Reservation_Participant) as TotalPlaces, Client.FirstName, Client.LastName
	FROM Workshop
	JOIN Workshop_Reservation ON Workshop_Reservation.Workshop_ID = Workshop.Workshop_ID
	JOIN Client ON Client.Client_ID = Workshop_Reservation.Client_ID
	JOIN Conference_Day ON Workshop.Conference_Day_ID = Conference_Day.Conference_Day_ID
	JOIN Conference ON Conference.Conference_ID = Conference_Day.Conference_ID
	WHERE (Conference_Day.Date > GETDATE() AND Workshop_Reservation.Reservation_Status != 'C' AND Client.IsCompany = 0 AND Client.FirstName IS NOT NULL and Client.LastName IS NOT NULL)
	GROUP BY Workshop.Workshop_Name, Conference.Conference_Name, Client.LastName, Client.FirstName
GO

-- all upcoming workshop participants
CREATE VIEW Upcoming_Workshop_Participants
	AS
	SELECT Workshop.Workshop_Name, Conference_Day_Participant.FirstName, Conference_Day_Participant.LastName
	FROM Workshop
	JOIN Workshop_Reservation ON Workshop_Reservation.Workshop_ID = Workshop.Workshop_ID
	JOIN Workshop_Participant ON Workshop_Participant.Workshop_Reservation_ID = Workshop_Reservation.Workshop_Reservation_ID
	JOIN Conference_Day_Participant ON Conference_Day_Participant.Conference_Day_Participant_ID = Workshop_Participant.Conference_Day_Participant_ID
	JOIN Conference_Day ON Conference_Day.Conference_Day_ID = Conference_Day_Participant.Conference_Day_ID
	WHERE (Conference_Day.Date > GETDATE() and Workshop_Reservation.Reservation_Status != 'C')
	GROUP BY Workshop.Workshop_Name, Conference_Day_Participant.LastName, Conference_Day_Participant.FirstName
GO

-- all not paid confernece_day reservations
CREATE VIEW NotPaid_ConferenceDayReservations
	AS
	SELECT Conference.Conference_Name,  Conference_Day_Reservation.Conference_Day_Reservation_ID, Client.Client_ID, Client.PhoneNumber 
	FROM Conference_Day_Reservation
	JOIN Conference_Day ON Conference_Day.Conference_Day_ID = Conference_Day_Reservation.Conference_Day_ID
	JOIN Conference ON Conference_Day.Conference_ID = Conference.Conference_ID
	JOIN Client ON Client.Client_ID = Conference_Day_Reservation.Client_ID
	WHERE (Conference_Day_Reservation.Reservation_Status = 'R' and Conference_Day.Date > GETDATE())
	GROUP BY Conference.Conference_Name, Conference_Day_Reservation.Conference_Day_Reservation_ID, Client.Client_ID, Client.PhoneNumber
GO

-- all not paid workshop reservations
CREATE VIEW NotPaid_WorkshopReservations
	AS
	SELECT  Conference.Conference_Name, Workshop.Workshop_Name, Workshop_Reservation.Workshop_Reservation_ID, Client.Client_ID, Client.PhoneNumber
	FROM Workshop_Reservation
	JOIN Conference_Day_Reservation ON Workshop_Reservation.Conference_Day_Reservation_ID = Conference_Day_Reservation.Conference_Day_Reservation_ID
	JOIN Conference_Day ON Conference_Day_Reservation.Conference_Day_Reservation_ID = Conference_Day.Conference_Day_ID
	JOIN Conference ON Conference_Day.Conference_ID = Conference.Conference_ID
	JOIN Client ON Client.Client_ID = Workshop_Reservation.Client_ID
	JOIN Workshop on Workshop.Workshop_ID = Workshop_Reservation.Workshop_ID
	WHERE (Workshop_Reservation.Reservation_Status = 'R' and Conference_Day.Date > GETDATE())
	GROUP BY Conference.Conference_Name, Workshop.Workshop_Name, Workshop_Reservation.Workshop_Reservation_ID, Client.Client_ID, Client.PhoneNumber
GO

-- client activity
CREATE VIEW Client_Activity
	AS
	SELECT SUM(Conference_Day_Reservation.Reservation_Participants) as Conferences_Paricipants,
	SUM(Workshop_Reservation.Reservation_Participant) as Workshop_Participants,
	Client.IsCompany, Client.CompanyName, Client.FirstName, Client.LastName, Client.Country
	FROM Client
	JOIN Conference_Day_Reservation ON Client.Client_ID = Conference_Day_Reservation.Client_ID
	JOIN Workshop_Reservation ON Client.Client_ID = Workshop_Reservation.Client_ID
	WHERE (Workshop_Reservation.Reservation_Status != 'C' AND Conference_Day_Reservation.Reservation_Status != 'C')
	GROUP BY Client.CompanyName, Client.IsCompany, Client.LastName, Client.FirstName, Client.Country
GO

