
execute Add_Conference_Day 'Debiut', '01/12/2016', 50,150
execute Add_Conference_Day 'Debiut', '02/12/2016', 100,200
execute Add_Conference_Day 'Debiut', '03/12/2016', 70,250
execute Add_Conference_Day 'Debiut', '05/12/2016', 50,100

exec Add_Workshop 'Debiut', '03/12/2016', 'Warsztacik Trzeciego', '05:30', '06:00', 50, 100

select * from Workshop
select * from Conference_Day

select * from Client
exec Add_Conference_Day_Individual_Reservation 
select * from Conference_Day
select * from Conference
select * from Conference_Day_Reservation
exec Add_Conference_Day_Individual_Reservation Conference_Name, Date, FirstName, LastName, City, Country, Street, HouseNuber, Student_IDCARD, NIP, PhoneNumber, PESEl, PaymentType, Reservation
exec Add_Workshop_IndividualClient_Reservation WorkshopName, ConferenceName, DateOfWorshkop, StartHour, EndHour,  FirstName, LastName, Street, HouseNumber, City, Country, STUDENTIDCARD, PhoneNunmber, Pesel, PayemtnType, Reservation_Date 

exec Add_Conference_Day_Individual_Reservation 'Debiut', '03/12/2016', 'Waldek', 'Wrona', 'W�adys�awowo', 'Polska', 'Kurnikowa', '6', NULL, NULL, '1234', '123456', 'CASH', '10/10/2016'

exec Add_Workshop_IndividualClient_Reservation 'Warsztacik Trzeciego',  'Debiut', '03/12/2016', '05:30', '06:00', 'Waldek', 'Wrona', 'Kurnikowa', '6', 'W�adys�awowo', 'Polska', NULL, '12345', '1234', 'CASH', '10/10/2015'
exec Add_Conference_Day_Individual_Reservation 'Debiut', '03/12/2016', 'Grzegorz' , 'Borkowski', 'Senatorska', '34', 'Szczekociny', 'Polska', '276329', NULL, '533553068', '95120810079', 'CASH', '2016/11/15'


select * from Client

execute Add_Conference_Price_Rate 'Debiut', '03/12/2016', '10/11/2016', 20

execute Add_Conference_Price_Rate 'Debiut', '03/12/2016', '/11/2016', 10
exec Add_Conference_Day_Individual_Reservation 'Debiut', '03/12/2016', 'Grzegorz' , 'Borkowski', 'Senatorska', '34', 'Szczekociny', 'Polska', '276329', NULL, '533553068', '95120810079', 'CASH', '2016/11/15'exec Add_Conference_Day_Individual_Reservation 'Debiut', '03/12/2016', 'Zygmunt' , 'Wiadro', 'Wa�brzych', 'Polska',  'Czarnowiejksa', '8/2', 126531, 11115, 23456 , 'CASH', '01/10/2016'
select YEAR('2016/01/22')
select * from Conference

select * from Conference_Day

select * from Conference_Price_Rate

select * from Conference_Day_Reservation

Select * from Conference_Day_Participant
select * from Client

select * from Conference
select * from Conference_Day

delete from Client
delete from Conference_Day where Conference_ID = 2
select * from Workshop
delete from Workshop where Conference_Day_ID IN (4,6)
delete from Conference_Day_Reservation
delete from Conference_Day_Participant
select * from Client

exec Add_Conference_Day_Individual_Reservation 'Debiut', '03/12/2016', 'Anna' , 'Anio�', 'SenatorskaA', '34A', 'SzczekocinyA', 'Polska', '276313', NULL, '533553069', '96120810079', 'CASH', '2016/11/15'
exec Add_Conference_Day_Company_Reservation NULL, 'Debiut', '03/12/2016', 'FirmaGrzenia', 'Zabrze', 'Polska', 'Pastowa', '6', '1224565', '1234567', 'CASH', 3, '10/05/2016'
exec Add_Conference_Day_Individual_Reservation 'Debiut', '03/12/2016', 'Grzegorz' , 'Borkowski', 'Senatorska', '34', 'Szczekociny', 'Polska', '276329', NULL, '533553068', '95120810079', 'CASH', '2016/11/15'

exec Add_Individual_Client 'Grzegorz', 'Borkowski', 'Senatorska', '34', 'Szczekociny', 'Polska', 276329, '533553068', '95120810079'
exec Add_Individual_Client 'Anna', 'Anio�', 'Senatorska', '34', 'Szczekociny', 'Polska', 27688329, '533553068', '968120810079'

select dbo.getLatestClient()

      
                                                                                                                                                                                                                                                                                                                                                                                                                                          