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