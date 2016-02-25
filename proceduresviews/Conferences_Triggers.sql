IF OBJECT_ID('CheckForTwoTheSameConferenceDays') IS NOT NULL
	DROP TRIGGER CheckForTwoTheSameConferenceDays
GO

IF OBJECT_ID('CheckIfWorkshopStartHourBeforeEndHour') IS NOT NULL
	DROP TRIGGER CheckIfWorkshopStartHourBeforeEndHour
GO

IF OBJECT_ID('WorkshopPlacesLessThanConferenceDayPlaces') IS NOT NULL
	DROP TRIGGER WorkshopPlacesLessThanConferenceDayPlaces
GO

IF OBJECT_ID('PriceRateAfterConferenceDay') IS NOT NULL
	DROP TRIGGER PriceRateAfterConferenceDay
GO

IF OBJECT_ID('CheckForTwoTheSamePriceRates') IS NOT NULL
	DROP TRIGGER CheckForTwoTheSamePriceRates
GO

IF OBJECT_ID('ConferencesNoLongerThanWeek') IS NOT NULL
	DROP TRIGGER ConferencesNoLongerThanWeek
GO


CREATE TRIGGER CheckForTwoTheSameConferenceDays
ON Conference_Day
AFTER INSERT, UPDATE
AS BEGIN
SET NOCOUNT ON;
	DECLARE @Date date = (SELECT Date FROM inserted)
	DECLARE @ConferenceId int = (SELECT Conference_ID FROM inserted)

	IF ((SELECT COUNT(conference_day_id)
	FROM Conference_Day
	WHERE (Date = @Date) AND (Conference_ID = @ConferenceId) ) > 1)
	BEGIN
	DECLARE @message varchar(100) = 'Day '+CAST(@Date as varchar(20))+' has
	already been added for this conference'
	PRINT @message
	RAISERROR('Conference can not contain two the same conference day', 16,1)
	ROLLBACK TRANSACTION
	END
END
GO

CREATE TRIGGER CheckIfWorkshopStartHourBeforeEndHour
ON Workshop
AFTER INSERT, UPDATE
AS BEGIN
		SET NOCOUNT ON;
		DECLARE @StartHour time = (SELECT StartHour from inserted)
		DECLARE @EndHour time = (SELECT EndHour from inserted)

		IF((SELECT DATEDIFF(minute, @StartHour, @EndHour))<15)
			BEGIN
			RAISERROR ('Workshop has to last at last 15 minutes.', 16, 1)
		ROLLBACK TRANSACTION
		END
END
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

CREATE TRIGGER PriceRateAfterConferenceDay
ON Conference_Price_Rate
AFTER INSERT, UPDATE
AS BEGIN
	SET NOCOUNT ON;
	Declare @PriceRateDate date = (Select DiscountDay from inserted)
	Declare @ConferenceDay date = (Select Conference_Day.Date from inserted
	JOIN Conference_Day ON inserted.Conference_Day_ID = Conference_Day.Conference_Day_ID)

	IF(DATEDIFF(day, @PriceRateDate, @ConferenceDay)>0)
		BEGIN
		RAISERROR('Pricerate is later than conference day', 16, 1)
		ROLLBACK TRANSACTION
		END
END
GO


CREATE TRIGGER CheckForTwoTheSamePriceRates
ON Conference_Price_Rate
AFTER INSERT, UPDATE
AS BEGIN
SET NOCOUNT ON;
	DECLARE @Date date = (SELECT DiscountDay FROM inserted)
	DECLARE @ConferenceDayID int = (SELECT Conference_Day_ID FROM inserted)

	IF ((SELECT COUNT(Conference_Day_ID)
	FROM Conference_Price_Rate
	WHERE (DiscountDay = @Date) AND (@ConferenceDayID = @ConferenceDayID) ) > 1)
	BEGIN
	RAISERROR('Conference Day can not contain two the same price rates', 16,1)
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
