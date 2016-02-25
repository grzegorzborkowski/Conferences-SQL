CREATE CLUSTERED INDEX ClientIndex ON Client (Client_ID)

CREATE CLUSTERED INDEX ConferenceIndex on Conference (Conference_ID)

CREATE CLUSTERED INDEX ConfereceDayIndex on Conference_Day (Conference_Day_ID)

CREATE CLUSTERED INDEX ConferenceDayParticipantIndex on Conference_Day_Participant (Conference_Day_Participant_ID)

CREATE CLUSTERED INDEX ConferenceDayReservationIndex on Conference_Day_Reservation (Conference_Day_Reservation_ID)

CREATE CLUSTERED INDEX ConferencePriceRateIndex on Conference_Price_Rate (Conference_Price_Rate_ID)

CREATE CLUSTERED INDEX PaymentIndex on Payment (Payment_ID)

CREATE CLUSTERED INDEX WorkshopIndex on Workshop (Workshop_ID)

CREATE CLUSTERED INDEX WorkshopReservationIndex on Worshkop_Reservation (Workshop_Reservation_ID)

CREATE CLUSTERED INDEX WorkshopParticipantIndex on Workshop_Participant (Workshop_Participant_ID)
