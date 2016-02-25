Use [CONFERENCES]

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
		IF @FreeSeats > 0
		BEGIN
			BEGIN TRANSACTION
				exec Add_Payment @TotalPrice, @PaymentType
				PRINT 'Po payment'

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
						PRINT 'przed 1. add individual client'
						exec Add_Individual_Client @FirstName, @LastName, @Street, @HouseNumber, @City, @Country, @Student_IDCard, @PhoneNumber, @PESEL
						PRINT 'po 1. add individual client'
						IF @@ERROR <> 0
						BEGIN
							RAISERROR('error', 16, 1)
							ROLLBACK TRANSACTION
						END

						DECLARE @LatestClientID AS INT
						SET @LatestClientID = dbo.getLatestClient()
						
						INSERT INTO dbo.Conference_Day_Reservation
						(Conference_Day_ID, Client_ID, Payment_ID, Reservation_Participants, Reservation_Date, Reservation_Status)
						VALUES (@Conference_Day_ID, @LatestClientID, @LatestPaymentID, 1, @ReservationDate, 'R')
						
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
				COMMIT TRANSACTION
		END

		IF @FreeSeats = 0
		BEGIN
			PRINT 'NO FREE SEATS FOR THIS CONFERENCE DAY'
		END
		
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
	SET @WorkshopDate = ( SELECT Conference_Day.Date from Conference_Day where @Conference_Day_ID = @Conference_Day_ID)

	DECLARE @Reservation_Date as date
	SET @Reservation_Date = DATEADD(day, -@DaysBefore, @WorkshopDate)

	DECLARE @TotalAmountToPay AS INT
	SET @TotalAmountToPay = dbo.getWorkshopPrice(@Conference_ID, @WorkshopID, @Student_IDCard)
	INSERT INTO Payment (Amount, PaymentType) VALUES (@TotalAmountToPay, @PaymentType)
					IF @@ERROR <>0 
					BEGIN
					PRINT 'An error occured during inserting into payment table'
					RAISERROR('error', 16, 1)
					ROLLBACK TRANSACTION
					END

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
		PRINT 'Client is not registered on the conference daay'
		INSERT INTO Conference_Day_Reservation(Conference_Day_ID, Client_ID, Payment_ID, Reservation_Participants, Reservation_Date, Reservation_Status)
		VALUES (@Conference_Day_ID, @Client_ID, @LatestPaymentID, 1, @Reservation_Date, 'R')
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
		VALUES(@Conference_Day_ID, @Conference_Day_Reservation_ID, @Client_ID, @FirstName, @LastName)
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
	INSERT INTO Workshop_Reservation(Workshop_ID, Client_ID, Payment_ID, Conference_Day_Reservation_ID)
		VALUES (@WorkshopID, @Client_ID, @LatestPaymentID, @Conference_Day_Reservation_ID)

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

