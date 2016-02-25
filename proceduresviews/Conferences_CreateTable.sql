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
