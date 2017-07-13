--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- NAME: JINKAL ARVIND JAVIA																		SUID: 425325424
-- PROJECT 2
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--/////////////////////////////////      		DESIGN MODIFICAION				/////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- I made following changes to my design based on feedback:
--		Added billing address field for Credit Card
--		Converted Customer AcitivtyStatus to BIT field from Lookup Table
--		Converted Trip CompletionStatus to BIT field from Lookup Table
--		Added Lookup Table for Color Field (Car) and State Field (Driver's License)
--		Correctly broke down Car detils
--		Handled record of payments for Driver which I missed in my Project 1

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- REFERENCES
--Project 1 Instructor Solution

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////               TABLE CREATION               ///////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--SCHEMA
CREATE SCHEMA p2;

--TABLE Address
CREATE TABLE p2.Address(
			AddressID		INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Street1			VARCHAR(30)		NOT NULL,
			Street2			VARCHAR(30),
			City			VARCHAR(30)		NOT NULL,
			State			VARCHAR(30)		NOT NULL,
			Zip				VARCHAR(15)		NOT NULL	CHECK(Zip NOT LIKE '%[^0-9]%')
);

--TABLE Customers
CREATE TABLE p2.Customers(
            CustomerID      INTEGER         PRIMARY KEY		IDENTITY(1,1),
			FirstName		VARCHAR(50)		NOT NULL,
			LastName		VARCHAR(50)		NOT NULL,
			EmailAddress	VARCHAR(50)     NOT NULL		CHECK (EmailAddress LIKE '%___@___%.__%'),
			AddressID		INTEGER		    NOT NULL		REFERENCES p2.Address(AddressID),
			IsActive	    BIT             NOT NULL
);

--TABLE Credentials
CREATE TABLE p2.Credentials(
			CustomerID		INTEGER			NOT NULL		REFERENCES p2.Customers(CustomerID),
			UserName		VARCHAR(50)		NOT NULL,
			Password		VARCHAR(50)		NOT NULL		CHECK(Password LIKE '%[0-9]%' AND Password LIKE '%[A-Z]%' AND Password LIKE '%[a-z]%' AND LEN(Password) > 6),
			PRIMARY KEY(CustomerID)
);

--TABLE PhoneType
CREATE TABLE p2.PhoneType(
			PhoneTypeID		INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Text		    VARCHAR(15)		NOT NULL
);

--TABLE PhoneInfo
CREATE TABLE p2.PhoneInfo(
			PhoneInfoID		INTEGER			PRIMARY KEY		IDENTITY(1,1),
			PhoneType		INTEGER 		NOT NULL		REFERENCES p2.PhoneType(PhoneTypeID),
			PhoneNumber		VARCHAR(15)		NOT NULL		CHECK(PhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
			CustomerID      INTEGER			NOT NULL		REFERENCES p2.Customers(CustomerID),
);

--TABLE DriverStatus
CREATE TABLE p2.DriverStatus(
			DriverStatusID	INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Text		    VARCHAR(30)		NOT NULL
);

--TABLE Drivers
CREATE TABLE p2.Drivers(
			DriverID		INTEGER			PRIMARY KEY		IDENTITY(1,1),
			FirstName		VARCHAR(50)		NOT NULL,
			LastName		VARCHAR(50)		NOT NULL,
			DateOfBirth		DATETIME		NOT NULL,
			AddressID		INTEGER		    NOT NULL		REFERENCES p2.Address(AddressID),
			DriverStatus	INTEGER			NOT NULL		REFERENCES p2.DriverStatus(DriverStatusID),
			StartDate		DATETIME		NOT NULL,
			SSN				VARCHAR(15)		NOT NULL		CHECK(SSN LIKE '[0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9][0-9]'),
			CONSTRAINT ValidateStartDate CHECK (DATEDIFF(YEAR, DateOfBirth, StartDate) >= 16)
);

--TABLE Trips
CREATE TABLE p2.Trips(
			TripID			INTEGER			PRIMARY KEY		IDENTITY(1,1),
			CustomerID      INTEGER			NOT NULL		REFERENCES p2.Customers(CustomerID),
			DriverID        INTEGER			NOT NULL		REFERENCES p2.Drivers(DriverID),
			DateBooked		DATETIME		NOT NULL,
			IsComplete		BIT				NOT NULL
);

--TABLE RatedBy
CREATE TABLE p2.RatedBy(
			RatedByID		INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Text		    VARCHAR(10)		NOT NULL
);

--TABLE Ratings
CREATE TABLE p2.Ratings(
            RatingID        INTEGER         PRIMARY KEY		IDENTITY(1,1),
			TripID          INTEGER			NOT NULL		REFERENCES p2.Trips(TripID),
			DriverID        INTEGER			NOT NULL		REFERENCES p2.Drivers(DriverID),
			CustomerID      INTEGER			NOT NULL		REFERENCES p2.Customers(CustomerID),
			ReviewDate		DATETIME		NOT NULL,
			ReviewText		VARCHAR(100),
			Score			INTEGER			NOT NULL		CHECK (Score >= 0 AND Score <= 5),
			RatedBy			INTEGER			NOT NULL		REFERENCES p2.RatedBy(RatedByID)
);

--TABLE StoredCreditCardsInfo
CREATE TABLE p2.StoredCreditCardsInfo(
			StoredCreditCardsInfoID		INTEGER         PRIMARY KEY		IDENTITY(1,1),
			CardHolderName				VARCHAR(50)		NOT NULL,
			CreditCardNumber			VARCHAR(20)		NOT NULL		CHECK(CreditCardNumber LIKE '[0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9] [0-9][0-9][0-9][0-9]'),
			ExpiryDate					DATETIME		NOT NULL,
			CustomerID					INTEGER			NOT NULL		REFERENCES p2.Customers(CustomerID),
			BillingAddressID			INTEGER		    NOT NULL		REFERENCES p2.Address(AddressID)
);

--TABLE TripPaymentInfo
CREATE TABLE p2.TripPaymentInfo(
			TripID		    INTEGER			NOT NULL		REFERENCES p2.Trips(TripID),
			CreditCardInfo  INTEGER         NOT NULL        REFERENCES p2.StoredCreditCardsInfo(StoredCreditCardsInfoID),
			AmountPaid		DECIMAL(5,2)	NOT NULL        CHECK(AmountPaid >= 0.00),
			Tip				DECIMAL(5,2)    NOT NULL        CHECK(Tip >= 0.00),
			PRIMARY KEY(TripID)
);

--TABLE PassengersAndBagsInfo
CREATE TABLE p2.PassengersAndBagsInfo(
			TripID		        INTEGER			NOT NULL		REFERENCES p2.Trips(TripID),
			NumberOfPassengers  INTEGER			NOT NULL		CHECK(NumberOfPassengers >= 0),
			NumberOfBags		INTEGER			NOT NULL		CHECK(NumberOfBags >= 0),
			PRIMARY KEY(TripID)
);

--TABLE Notes
CREATE TABLE p2.Notes(
			TripID		        INTEGER			NOT NULL		REFERENCES p2.Trips(TripID),
			CustomerNotes       VARCHAR(100),
			DriverNotes		    VARCHAR(100),
			PRIMARY KEY(TripID)
);

--TABLE TimeAndLocation
CREATE TABLE p2.TimeAndLocation(
			TripID		        INTEGER			NOT NULL		REFERENCES p2.Trips(TripID),
			PickupTime			DATETIME,
			DropOffTime			DATETIME,
			PickupLocation		INTEGER		    NOT NULL		REFERENCES p2.Address(AddressID),
			DropOffLocation		INTEGER		    NOT NULL		REFERENCES p2.Address(AddressID),
			PRIMARY KEY(TripID)
);

--TABLE BankInfo
CREATE TABLE p2.BankInfo(
			BankInfoID		INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Name		    VARCHAR(30)		NOT NULL
);

--TABLE AccountType
CREATE TABLE p2.AccountType(
			AccountTypeID		INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Text		        VARCHAR(20)		NOT NULL
);

--TABLE BankAccountInfo
CREATE TABLE p2.BankAccountInfo(
			BankAccountInfoID	INTEGER         PRIMARY KEY		IDENTITY(1,1),
			DriverID			INTEGER			NOT NULL		REFERENCES p2.Drivers(DriverID),
			Bank				INTEGER			NOT NULL		REFERENCES p2.BankInfo(BankInfoID),
			AccountNumber		VARCHAR(15)		NOT NULL		CHECK (AccountNumber NOT LIKE '%[^0-9]%'),
			RoutingNumber		VARCHAR(15)		NOT NULL		CHECK (RoutingNumber NOT LIKE '%[^0-9]%'),
			AccountTypeID		INTEGER			NOT NULL		REFERENCES p2.AccountType(AccountTypeID),
);

--TABLE Payments
CREATE TABLE p2.Payments(
			PaymentID			INTEGER         PRIMARY KEY		IDENTITY(1,1),
			DateWhenMade		DATETIME		NOT NULL,
			BankAccountInfoID	INTEGER			NOT NULL		REFERENCES p2.BankAccountInfo(BankAccountInfoID)
);

--TABLE TripPayments
CREATE TABLE p2.TripPayments(
			TripID		    INTEGER			NOT NULL		REFERENCES p2.Trips(TripID),
			PaymentID       INTEGER         NOT NULL        REFERENCES p2.Payments(PaymentID),
			Amount		    DECIMAL(5,2)	NOT NULL		CHECK(Amount >= 0.00),
			PRIMARY KEY(TripID, PaymentID)
);

--TABLE State
CREATE TABLE p2.State(
			StateID		        INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Text		        VARCHAR(30)		NOT NULL
);

--TABLE DriverLicenseInfo
CREATE TABLE p2.DriverLicenseInfo(
			DriverID			INTEGER			NOT NULL		REFERENCES p2.Drivers(DriverID),
			LicenseNumber		VARCHAR(20)		NOT NULL,
			State				INTEGER			NOT NULL		REFERENCES p2.State(StateID),
			IssueDate			DATETIME		NOT NULL,
			ExpiryDate			DATETIME		NOT NULL,
			PRIMARY KEY(DriverID),
			CONSTRAINT ValidateIssueExpiryDate CHECK (DATEDIFF(DAY, IssueDate, ExpiryDate) > 0)
);

--TABLE InsuranceCompany
CREATE TABLE p2.InsuranceCompany(
			InsuranceCompanyID		INTEGER			PRIMARY KEY		IDENTITY(1,1),
			CompanyName				VARCHAR(50)		NOT NULL,
			PhoneNumber				VARCHAR(15)     NOT NULL		CHECK(PhoneNumber LIKE '[0-9][0-9][0-9]-[0-9][0-9][0-9]-[0-9][0-9][0-9][0-9]'),
			ContactFirstName		VARCHAR(50),
			ContactLastName         VARCHAR(50)
);

--TABLE InsuranceInfo
CREATE TABLE p2.InsuranceInfo(
			DriverID			INTEGER			NOT NULL		REFERENCES p2.Drivers(DriverID),
			CompanyID           INTEGER			NOT NULL		REFERENCES p2.InsuranceCompany(InsuranceCompanyID),
			PolicyNumber		VARCHAR(25)		NOT NULL,
			IssueDate			DATETIME		NOT NULL,
			ExpiryDate			DATETIME		NOT NULL,
			PRIMARY KEY(DriverID),
			CONSTRAINT ValidateInsuranceDates CHECK (DATEDIFF(DAY, IssueDate, ExpiryDate) > 0)
);

--TABLE CarMake
CREATE TABLE p2.CarMake(
			CarMakeID		    INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Text		        VARCHAR(30)		NOT NULL
);

--TABLE CarClass
CREATE TABLE p2.CarClass(
			CarClassID		    INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Text		        VARCHAR(30)		NOT NULL
);

--TABLE CarCapacity
CREATE TABLE p2.CarCapacity(
			CarCapacityID		    INTEGER			PRIMARY KEY		IDENTITY(1,1),
			PassengerCapacity		INTEGER			NOT NULL		CHECK(PassengerCapacity >= 0),
			LuggageCapacity			INTEGER			NOT NULL		CHECK(LuggageCapacity >= 0)
);

--TABLE CarModel
CREATE TABLE p2.CarModel(
			CarModelID			INTEGER			PRIMARY KEY		IDENTITY(1,1),
			CarModelName		VARCHAR(30)		NOT NULL,
			CarMake				INTEGER			NOT NULL		REFERENCES p2.CarMake(CarMakeID),
			CarClass			INTEGER			NOT NULL		REFERENCES p2.CarClass(CarClassID),
			CarCapacity			INTEGER			NOT NULL		REFERENCES p2.CarCapacity(CarCapacityID)
);

--TABLE CarModelYear
CREATE TABLE p2.CarModelYear(
			CarModelYearID		INTEGER			PRIMARY KEY		IDENTITY(1,1),
			CarYear				DATETIME        NOT NULL,
			CarModelID			INTEGER			NOT NULL		REFERENCES p2.CarModel(CarModelID)
);

--TABLE Color
CREATE TABLE p2.Color(
			ColorID		        INTEGER			PRIMARY KEY		IDENTITY(1,1),
			Text		        VARCHAR(30)		NOT NULL
);

--TABLE CarInfo
CREATE TABLE p2.CarInfo(
			DriverID			INTEGER			NOT NULL		REFERENCES p2.Drivers(DriverID),
			CarModelYearID		INTEGER			NOT NULL		REFERENCES p2.CarModelYear(CarModelYearID),
			Color				INTEGER			NOT NULL		REFERENCES p2.Color(ColorID),
			PRIMARY KEY(DriverID)
);

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- REFERENCES
--http://stackoverflow.com/questions/9375767/constraint-check-for-10-digit-character-use-for-postal-code
--https://social.msdn.microsoft.com/Forums/sqlserver/en-US/4754314a-a076-449c-ac62-e9d0c12ba717/beginner-question-check-constraint-for-email-address?forum=databasedesign

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////////////                 DATA LOAD                 ////////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

INSERT INTO p2.PhoneType(Text) 
	VALUES	('Home'),
			('Cell'),
			('Business');

INSERT INTO p2.DriverStatus(Text)
	VALUES	('Inactive'),
			('Off work'),
			('Working  available'),
			('Working  with a customer');

INSERT INTO p2.Color(Text)
	VALUES	('Red'),
			('Black'),
			('White'),
			('Ivory'),
			('Blue'),
			('Grey'),
			('Yellow');

INSERT INTO p2.AccountType(Text)
	VALUES	('Checking'),
			('Savings');

INSERT INTO p2.RatedBy(Text)
	VALUES	('Customer'),
			('Driver');

INSERT INTO p2.BankInfo(Name)
	VALUES	('JPMorganChase'),
			('Keybank'),
			('BankOfAmerica'),
			('Citibank'),
			('WellsFargo'),
			('MorganStanley');

INSERT INTO p2.State(Text)
	VALUES	('Alabama'),
			('Alaska'),
			('Arizona'),
			('Arkansas'),
			('California'),
			('Colorado'),
			('Connecticut'),
			('Delaware'),
			('District of Columbia'),
			('Florida'),
			('Georgia'),
			('Hawaii'),
			('Idaho'),
			('Illinois'),
			('Indiana'),
			('Iowa'),
			('Kansas'),
			('Kentucky'),
			('Louisiana'),
			('Maine'),
			('Maryland'),
			('Massachusetts'),
			('Michigan'),
			('Minnesota'),
			('Mississippi'),
			('Missouri'),
			('Montana'),
			('Nebraska'),
			('Nevada'),
			('New Hampshire'),
			('New Jersey'),
			('New Mexico'),
			('New York'),
			('North Carolina'),
			('North Dakota'),
			('Ohio'),
			('Oklahoma'),
			('Oregon'),
			('Pennsylvania'),
			('Puerto Rico'),
			('Rhode Island'),
			('South Carolina'),
			('South Dakota'),
			('Tennessee'),
			('Texas'),
			('Utah'),
			('Vermont'),
			('Virginia'),
			('Washington'),
			('West Virginia'),
			('Wisconsin'),
			('Wyoming');
			
INSERT INTO p2.CarClass(Text)
	VALUES	('Regular'),
			('Luxury'),
			('SUV');

INSERT INTO p2.CarMake(Text)
	VALUES	('Infiniti'),
			('Subaru'),
			('Lexus'),
			('GMC'),
			('Toyota'),
			('BMW'),
			('Honda'),
			('Lincoln');

INSERT INTO p2.CarCapacity(PassengerCapacity, LuggageCapacity)
	VALUES	(5,2),
			(5,3),
			(6,4),
			(7,4),
			(8,5);

INSERT INTO p2.CarModel(CarModelName, CarMake, CarClass, CarCapacity)
	VALUES	('CRV',7,3,3),
			('X1',6,2,2),
			('Accord',7,1,2),
			('Corolla',5,1,1),
			('QX80',1,3,5);

INSERT INTO p2.CarModelYear(CarYear,CarModelID)
	VALUES	('2016-04-01 00:00:00',2),
			('2017-04-01 00:00:00',3),
			('2015-04-01 00:00:00',1),
			('2014-04-01 00:00:00',4),
			('2015-04-01 00:00:00',5),
			('2016-04-01 00:00:00',3);

INSERT INTO p2.Address(Street1, Street2, City, State, Zip)
	VALUES	('7021 Monroe Ave', NULL, 'Hammond', 'IN', '46324'),
			('9709 Lake Chrise Ln', NULL, 'Port Richey', 'FL', '34668'),
			('47 Revolutionary Rd', NULL, 'Ossining', 'NY', '10562'),
			('139 Bell St', NULL, 'Chagrin Falls', 'OH', '44022'),
			('730 Whitson Rd', NULL, 'Talladega', 'AL', '35160'),
			('425 5th Ave', NULL, 'New York', 'NY', '10016'),
			('44 Applewood Ln', NULL, 'Glastonbury', 'CT', '06033'),
			('839 Nowita Pl', NULL, 'Venice', 'CA', '90291'),
			('600 W South Slope Rd', NULL, 'Emmett', 'ID', '83617'),
			('720 Northern Blvd', NULL, 'Greenvale', 'NY', '11548'),
			('561 Montgomery St', NULL, 'Jersey City', 'NJ', '07302'),
			('42 Aldie St', NULL, 'Allston', 'MA', '02134');
			
INSERT INTO p2.CarInfo(DriverID, CarModelYearID, Color)
	VALUES	(1,1,3),
			(2,2,4),
			(3,3,1),
			(4,4,2),
			(5,5,5);

INSERT INTO p2.InsuranceCompany(CompanyName, PhoneNumber, ContactFirstName, ContactLastName)
	VALUES	('Geico','333-088-6209','David','Brown'),
			('Allstate','989-535-8249',NULL,NULL),
			('StateFarm','862-234-7710',NULL,NULL),
			('Esurance','725-881-1256','John','Joseph'),
			('Arbella','471-891-7634','Dan','Humphry');

INSERT INTO p2.InsuranceInfo(DriverID, CompanyID, PolicyNumber, IssueDate, ExpiryDate)
	VALUES	(1,1,'2009999999','2014-04-01 00:00:00','2018-04-01 00:00:00'),
			(2,3,'3992789900','2015-04-01 00:00:00','2017-12-01 00:00:00'),
			(3,1,'4117330210','2016-04-01 00:00:00','2020-04-01 00:00:00'),
			(4,2,'8991111000','2015-04-01 00:00:00','2019-04-01 00:00:00'),
			(5,5,'5618883311','2016-04-01 00:00:00','2020-04-01 00:00:00');

INSERT INTO p2.DriverLicenseInfo(DriverID, LicenseNumber, State, IssueDate, ExpiryDate)
	VALUES	(1,'F255-921-50-094',1,'2014-04-01 00:00:00','2018-04-01 00:00:00'),
			(2,'W205-9215-0121-03',20,'2015-05-01 00:00:00','2017-12-01 00:00:00'),
			(3,'L025-0212-0178-02',5,'2016-04-01 00:00:00','2020-09-01 00:00:00'),
			(4,'A015-6315-1111-09',1,'2015-03-01 00:00:00','2019-06-01 00:00:00'),
			(5,'N055-9015-0101-06',12,'2016-01-01 00:00:00','2020-04-01 00:00:00');

INSERT INTO p2.Drivers(FirstName, LastName, DateOfBirth, AddressID, DriverStatus, StartDate, SSN)
	VALUES	('Monica', 'Geller', '1981-04-01 00:00:00', 1, 1, '2014-05-01 00:00:00', '528-52-9474'),
			('Ross', 'Geller', '1983-08-07 00:00:00', 2, 2, '2015-12-01 00:00:00', '213-14-1456'),
			('Rachel', 'Green', '1978-02-01 00:00:00', 3, 3, '2016-08-01 00:00:00','216-59-3366'),
			('Chandler', 'Bing', '1972-04-21 00:00:00', 4,1, '2015-01-01 00:00:00', '406-12-0117'),
			('Joey', 'Tribiani', '1991-09-11 00:00:00', 5, 3, '2017-04-01 00:00:00', '618-12-0918');

INSERT INTO p2.Customers(FirstName, LastName, EmailAddress, AddressID, IsActive)
	VALUES	('Ted', 'Mosby', 'ted@gmail.com', 1, 1),
			('Robin', 'Scherbatsky', 'rs23@gmail.com', 2, 0),
			('Barney', 'Stinson', 'barney10@hotmail.com', 3, 1),
			('Lily', 'Aldrin', 'lil@gmail.com', 4, 1),
			('Marshall', 'Eriksen', 'marshall99@hotmail.com', 5, 1),
			('Marvin', 'Eriksen', 'eriksen11@gmail.com', 6, 1);

INSERT INTO p2.Credentials(CustomerID, UserName, Password)
	VALUES  (1,'tmos', '4nEcqJDq'),
			(2, 'rob', 'PnS2ztKG'),
			(3, 'bar', 'pdVbV6na'),
			(4, 'lil', 'AuRrZ4y3'),
			(5, 'erik', 'fRF8uLfu'),
			(6, 'marv', 'JR0dMJuN');

INSERT INTO p2.PhoneInfo(PhoneType, PhoneNumber, CustomerID)
	VALUES	(1, '202-555-0175', 1),
			(2, '518-535-0190', 2),
			(3, '512-055-0142', 3),
			(2, '202-445-0115', 4),
			(1, '803-575-0164', 5),
			(2, '317-750-0155', 6);

INSERT INTO p2.BankAccountInfo(DriverID, Bank, AccountNumber, RoutingNumber, AccountTypeID)
	VALUES	(1, 2, '6338816162', '125000024', 1),
			(2, 1, '4946937265', '021272655', 2),
			(3, 1, '6311783281', '044000804', 1),
			(4, 3, '6130153048', '321175261', 1),
			(5, 4, '9787918560', '122000496', 1);

INSERT INTO p2.Payments(DateWhenMade, BankAccountInfoID)
	VALUES	('2017-04-01 00:00:00',1),
			('2017-01-12 00:00:00',2),
			('2017-02-25 00:00:00',3),
			('2016-11-05 00:00:00',4),
			('2017-03-10 00:00:00',5),
			('2016-12-01 00:00:00',1);

INSERT INTO p2.TripPayments(TripID, PaymentID, Amount)
	VALUES	(1, 1, 200.00),
			(2, 2, 120.00),
			(3, 3, 80.00),
			(4, 4, 500.00),
			(5, 5, 60.00),
			(6, 6, 72.00);
			
INSERT INTO p2.Trips(CustomerID, DriverID, DateBooked, IsComplete)
	VALUES	(1, 1, '2017-04-01 00:00:00', 1),
			(2, 2, '2017-01-10 00:00:00', 1),
			(3, 3, '2017-02-26 00:00:00', 1),
			(4, 4, '2017-03-22 00:00:00', 1),
			(5, 5, '2016-12-11 00:00:00', 1),
			(6, 4, '2016-12-25 00:00:00', 1),
			(2, 1, '2017-04-26 00:00:00', 0),
			(1, 3, '2017-04-27 00:00:00', 0),
			(4, 1, '2017-04-28 00:00:00', 0);

INSERT INTO p2.Notes(TripID, CustomerNotes, DriverNotes)
	VALUES	(1, 'Please use the rear entrance gate.', 'Sure.'),
			(2, NULL, NULL),
			(3, 'I will wait at Gate 11.', 'Okay, will park there.'),
			(4, NULL, NULL),
			(5, NULL, 'Due to lack of parking space at main campus, I am waiting at eastern entrance'),
			(6, NULL, NULL),
			(7, NULL, NULL),
			(8, NULL, NULL),
			(9, NULL, NULL);

INSERT INTO p2.PassengersAndBagsInfo(TripID, NumberOfPassengers, NumberOfBags)
	VALUES	(1, 2, 0),
			(2, 3, 2),
			(3, 2, 1),
			(4, 4, 2),
			(5, 4, 1),
			(6, 3, 1),
			(7, 2, 1),
			(8, 1, 2),
			(9, 1, 1);

INSERT INTO p2.Ratings(TripID, DriverID, CustomerID, ReviewDate, ReviewText, Score, RatedBy)
	VALUES	(1, 1, 1, '2017-04-01 00:00:00', 'Friendly Ride', 4, 1),
			(1, 1, 1, '2017-04-01 00:00:00', 'Nice people', 4, 2),
			(2, 2, 2, '2017-01-10 00:00:00', 'Okay experience', 3, 1),
			(2, 2, 2, '2017-01-10 00:00:00', 'Nice', 4, 2),
			(3, 3, 3, '2017-02-26 00:00:00', NULL, 4, 1),
			(3, 3, 3, '2017-02-26 00:00:00', 'Awesome', 5, 2),
			(4, 4, 4, '2017-03-22 00:00:00', NULL, 5, 1),
			(4, 4, 4, '2017-03-22 00:00:00', NULL, 5, 2),
			(5, 5, 5, '2016-12-11 00:00:00', NULL, 3, 1),
			(5, 5, 5, '2016-12-11 00:00:00', NULL, 2, 2),
			(6, 4, 6, '2016-12-25 00:00:00', 'Horrible', 1, 1),
			(6, 4, 6, '2016-12-25 00:00:00', NULL, 3, 2),
			(7, 1, 2, '2017-04-26 00:00:00', NULL, 4, 1),
			(7, 1, 2, '2017-04-26 00:00:00', 'Amazing', 5, 2),
			(8, 3, 1, '2017-04-27 00:00:00', 'Awful experience', 1, 1),
			(8, 3, 1, '2017-04-27 00:00:00', 'Not co-operative', 2, 2),
			(9, 1, 4, '2017-04-28 00:00:00', 'Recommended driver', 5, 1),
			(9, 1, 4, '2017-04-28 00:00:00', 'Great guys', 5, 2);

INSERT INTO p2.TimeAndLocation(TripID, PickupTime, DropOffTime, PickupLocation, DropOffLocation)
	VALUES	(1, '2017-04-01 01:12:00', '2017-04-01 03:10:00', 1, 2),
			(2, '2017-01-10 11:00:00', '2017-01-10 12:01:00', 2, 3),
			(3, '2017-02-26 04:30:00', '2017-02-26 07:40:00', 3, 4),
			(4, '2017-03-22 20:00:00', '2017-03-22 22:45:00', 5, 4),
			(5, '2016-12-11 06:00:00', '2016-12-11 06:30:00', 1, 5),
			(6, '2016-12-25 08:00:00', '2016-12-25 10:20:00', 8, 1),
			(7, '2017-04-26 3:00:00', NULL, 9, 4),
			(8, '2017-04-27 9:00:00', NULL, 10, 11),
			(9, '2017-04-28 11:20:00', NULL, 7, 2);

INSERT INTO p2.StoredCreditCardsInfo(CardHolderName, CreditCardNumber, ExpiryDate, CustomerID, BillingAddressID)
	VALUES	('Ted Mosby', '4485 2381 4386 0908', '2019-12-01 01:12:00', 1, 1),
			('Robin Scherbatsky', '4539 8938 7819 5916', '2020-04-01 01:12:00', 2, 2),
			('Barney Stinson', '4716 1772 2688 7134', '2022-03-01 01:12:00', 3, 3),
			('Lily Aldrin', '5185 8025 0294 6952', '2020-02-01 01:12:00', 4, 4),
			('Marshall Eriksen', '3463 6714 0590 7150', '2018-08-01 01:12:00', 5, 5),
			('Marvin Eriksen', '4916 4013 2109 7193', '2019-03-01 01:12:00', 6, 6),
			('Ted Mosby', '5473 0189 2376 2677', '2023-02-01 01:12:00', 1, 1);

INSERT INTO p2.TripPaymentInfo(TripID, CreditCardInfo, AmountPaid, Tip)
	VALUES	(1, 1, 350.00, 27.90),
			(2, 2, 178.00, 39.60),
			(3, 3, 110.00, 19.00),
			(4, 4, 720.00, 52.20),
			(5, 5, 095.00, 13.40),
			(6, 6, 100.00, 15.00),
			(7, 2, 000.00, 0.00),
			(8, 7, 000.00, 0.00),
			(9, 4, 000.00, 0.00);

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- REFERENCES
--https://gist.github.com/JeremyMorgan/5833666
--https://www.usatoday.com/story/money/cars/2016/09/17/americas-best-and-worst-car-brands/89343252/
--https://www.nationalgeneral.com/Account/policypopup.asp
--http://www.4autoinsurancequote.com/uncategorized/best-auto-insurance-companies/
--http://www.theonegenerator.com/ssngenerator
--http://www.fakeaddressgenerator.com/US_Real_Random_Address/index
--https://www.random.org/passwords/
--https://fakenumber.org/us/
--https://www.fatwallet.com/forums/finance/700350
--http://www.randomprofile.com/usa-random-names
--http://credit-card-generator.2-ee.com/q_fake-account-number-generator.htm

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--///////////////////////////////                     VIEWS                   ///////////////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

-- VIEW 1: Provides details for all cars associated with the company
CREATE VIEW p2.CarDetails (Class, Make, Model, Year, Color, PassengerCapacity, LuggageCapacity) 
	AS
	SELECT  cl.Text, ma.Text, mo.CarModelName, YEAR(y.CarYear), c.Text, cp.PassengerCapacity, cp.LuggageCapacity
			FROM p2.CarModel mo
			INNER JOIN p2.CarClass cl
					ON mo.CarClass = cl.CarClassID
			INNER JOIN p2.CarMake ma
					ON mo.CarMake = ma.CarMakeID
			INNER JOIN p2.CarCapacity cp
					ON mo.CarCapacity = cp.CarCapacityID
			INNER JOIN p2.CarModelYear y
					ON mo.CarModelID = y.CarModelID
			INNER JOIN p2.CarInfo ci
					ON ci.CarModelYearID = y.CarModelYearID
			INNER JOIN p2.Color c
					ON c.ColorID = ci.Color	
			GROUP BY cl.Text, ma.Text, mo.CarModelName, YEAR(y.CarYear), c.Text, cp.PassengerCapacity, cp.LuggageCapacity;	

--VIEW 2: Provides rating history for all drivers associated with the company
CREATE VIEW p2.DriverRatingHistory (DriverName, ReviewScore, ReviewText, ReviewDate, Reviewer)
	AS
	SELECT d.FirstName + ', ' + d.LastName AS Name, r.Score, r.ReviewText, CAST(r.ReviewDate AS DATE), c.FirstName + ', ' + c.LastName AS Reviewer
		   FROM p2.Ratings r
		   INNER JOIN p2.Drivers d
				   ON r.DriverID = d.DriverID
		   INNER JOIN p2.Customers c
		           ON c.CustomerID = r.CustomerID
		   INNER JOIN p2.RatedBy rb
		           ON rb.RatedByID = r.RatedBy
		   WHERE rb.Text = 'Customer'
		   GROUP BY d.FirstName + ', ' + d.LastName, r.Score, r.ReviewText, r.ReviewDate, c.FirstName + ', ' + c.LastName;

--VIEW 3: Provides contact details(Name, Email, Phone, Physical address) for all customers 
CREATE VIEW p2.CustomerContactDetails (CustomerName, EmailAddress, PhoneNumber, PhoneType, Street, City, State, Zip)
	AS
	SELECT	c.FirstName + ', ' + c.LastName AS Name, c.EmailAddress, p.PhoneNumber, pt.Text, a.Street1, a.City, a.State, a.Zip
			FROM p2.Customers c
			INNER JOIN p2.Address a
					ON c.AddressID = a.AddressID
			INNER JOIN p2.PhoneInfo p
					ON c.CustomerID = p.CustomerID
			INNER JOIN p2.PhoneType pt
					ON pt.PhoneTypeID = p.PhoneType
			GROUP BY c.FirstName + ', ' + c.LastName, c.EmailAddress, p.PhoneNumber, pt.Text, a.Street1, a.City, a.State, a.Zip;

--VIEW 4: Provides Customer's travel history along with travel cost and travel time
CREATE VIEW p2.CustomerTravelHistory (CustomerName, PickupLocation, DropOffLocation, TravelDate, TravelStatus, TravelTimeInMinutes, TravelCost, Tip)
	AS
	SELECT  c.FirstName + ', ' + c.LastName AS Name, pick.Street1 + ', ' + pick.City + ', ' + pick.State + ' - ' + pick.Zip,
		    dropOff.Street1 + ', ' + dropOff.City + ', ' + dropOff.State + ' - ' + dropOff.Zip, CAST(t.DateBooked AS DATE), 
			IIF(t.IsComplete=1, 'Completed','Ongoing'), DATEDIFF(MINUTE, tl.PickupTime, tl.DropOffTime), p.AmountPaid, p.Tip

			FROM p2.Trips t
			INNER JOIN p2.Customers c
					ON t.CustomerID = c.CustomerID
			INNER JOIN p2.TimeAndLocation tl
					ON tl.TripID = t.TripID
			INNER JOIN p2.TripPaymentInfo p
					ON p.TripID = t.TripID
			INNER JOIN p2.Address pick
					ON pick.AddressID = tl.PickupLocation
			INNER JOIN p2.Address dropOff	
					ON dropOff.AddressID = tl.DropOffLocation
			GROUP BY  c.FirstName + ', ' + c.LastName, pick.Street1 + ', ' + pick.City + ', ' + pick.State + ' - ' + pick.Zip,
					  dropOff.Street1 + ', ' + dropOff.City + ', ' + dropOff.State + ' - ' + dropOff.Zip, CAST(t.DateBooked AS DATE), 
					  t.IsComplete,DATEDIFF(MINUTE, tl.PickupTime, tl.DropOffTime) , p.AmountPaid, p.Tip;

--VIEW 5: Provides Driver's trip and payment history details
CREATE VIEW p2.DriverTripAndPaymentHistory (DriverName, PickupLocation, DropOffLocation, TripDate, Bank, AccountType, PaymentDate, Amount)
	AS
	SELECT  d.FirstName + ', ' + d.LastName, pick.Street1 + ', ' + pick.City + ', ' + pick.State + ' - ' + pick.Zip,
			dropOff.Street1 + ', ' + dropOff.City + ', ' + dropOff.State + ' - ' + dropOff.Zip, CAST(t.DateBooked AS DATE), 
			bi.Name, at.Text, CAST(p.DateWhenMade AS DATE), tp.Amount

			FROM p2.Drivers d
			INNER JOIN p2.BankAccountInfo b
					ON d.DriverID = b.DriverID
			INNER JOIN p2.Payments p
					ON p.BankAccountInfoID = b.BankAccountInfoID
			INNER JOIN p2.TripPayments tp
					ON tp.PaymentID = p.PaymentID
			INNER JOIN p2.BankInfo bi
					ON bi.BankInfoID = b.Bank
			INNER JOIN p2.AccountType at
					ON at.AccountTypeID = b.AccountTypeID
			INNER JOIN p2.Trips t
					ON t.TripID = tp.TripID
			INNER JOIN p2.TimeAndLocation tl
					ON tl.TripID = t.TripID
			INNER JOIN p2.Address pick
					ON tl.PickupLocation = pick.AddressID
			INNER JOIN p2.Address dropOff
					ON tl.DropOffLocation = dropOff.AddressID
			GROUP BY d.FirstName + ', ' + d.LastName, pick.Street1 + ', ' + pick.City + ', ' + pick.State + ' - ' + pick.Zip,
					 dropOff.Street1 + ', ' + dropOff.City + ', ' + dropOff.State + ' - ' + dropOff.Zip, CAST(t.DateBooked AS DATE), 
					 bi.Name, at.Text, CAST(p.DateWhenMade AS DATE), tp.Amount;

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
--////////////////////////                FUNCTIONS AND STORED PROCEDURES              //////////////////////////////
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

--OBJECT 1
--FUNCTION: Provides list of cars currently avialable which satisfy customer's passenger and luggage requirements
CREATE FUNCTION p2.CarsAvailabilityBasedOnCustomerRequirements (@NumberOfPassengers AS INTEGER,
																@NumberOfBags AS INTEGER)
RETURNS INTEGER
AS
	BEGIN
		DECLARE @result AS INTEGER
		SELECT  @result = COUNT(*)
				FROM p2.Drivers d
				INNER JOIN p2.DriverStatus ds
						ON d.DriverStatus = ds.DriverStatusID
				INNER JOIN p2.CarInfo ci
						ON ci.DriverID = d.DriverID
				INNER JOIN p2.CarModelYear cmy
						ON cmy.CarModelYearID = ci.CarModelYearID
				INNER JOIN p2.CarModel cm
						ON cm.CarModelID = cmy.CarModelID
				INNER JOIN p2.CarCapacity cc
						ON cc.CarCapacityID = cm.CarCapacity
				WHERE ds.Text = 'Working  available' 
				  AND cc.PassengerCapacity >= @NumberOfPassengers
				  AND cc.LuggageCapacity >= @NumberOfBags
		RETURN @result
	END;

--OBJECT 2
--STORED PROCEDURE: Books Trip for the customer. Checks customer credentials, looks if any cars which satisfy customer needs (i.e. number of passengers and bags) are available.
--					If so, checks for credit card validity and books the trip. Changes corresponding Driver's status and updates corresponding trip realted parameters.
CREATE PROCEDURE p2.BookTrip(@CustomerID AS INTEGER, 
							 @UserName AS VARCHAR(50), 
							 @Password AS VARCHAR(50), 
							 @NumberOfPassengers AS INTEGER, 
							 @NumberOfBags AS INTEGER, 
							 @CreditCardNumber AS VARCHAR(20), 
							 @ExpiryDate AS DATETIME,
							 @PickupLocation AS INTEGER,
							 @DropOffLocation AS INTEGER)
AS
	BEGIN
		DECLARE @CarsAvailable AS INTEGER
		-- Verify Login Credentials
		IF (SELECT  COUNT(*) 
				FROM p2.Customers c
				INNER JOIN p2.Credentials crd
						ON c.CustomerID = crd.CustomerID
				WHERE c.CustomerID = @CustomerID
				  AND crd.UserName = @UserName
				  AND crd.Password = @Password) = 0
			PRINT 'Login Failed! Incorrect Username or Password.'
		-- Find available cars satisfying customer requirements
		ELSE IF (SELECT COUNT(*)
						FROM p2.Drivers d
						INNER JOIN p2.DriverStatus ds
								ON d.DriverStatus = ds.DriverStatusID
						INNER JOIN p2.CarInfo ci
								ON ci.DriverID = d.DriverID
						INNER JOIN p2.CarModelYear cmy
								ON cmy.CarModelYearID = ci.CarModelYearID
						INNER JOIN p2.CarModel cm
								ON cm.CarModelID = cmy.CarModelID
						INNER JOIN p2.CarCapacity cc
								ON cc.CarCapacityID = cm.CarCapacity
						WHERE ds.Text = 'Working  available'
							AND cc.PassengerCapacity >= @NumberOfPassengers
							AND cc.LuggageCapacity >= @NumberOfBags) = 0
			PRINT 'Sorry! Currently, We have no cars available satisfying your requirements.'
		ELSE
			BEGIN
				DECLARE @date AS DATETIME
				DECLARE @DriverID AS INTEGER
				DECLARE @TripID AS INTEGER
				DECLARE @CreditCard AS INTEGER
				-- Credit card information provided matches Stored credit card information
				IF (SELECT  COUNT(*)
							FROM p2.StoredCreditCardsInfo cc
							WHERE cc.CustomerID = @CustomerID
							  AND cc.CreditCardNumber = @CreditCardNumber
							  AND cc.ExpiryDate = @ExpiryDate) = 1 
				BEGIN
					-- Expiry Date associated with Credit Card is valid
					IF ((SELECT YEAR(@ExpiryDate)) > (SELECT YEAR(GETDATE())))
					 OR (SELECT YEAR(@ExpiryDate)) = (SELECT YEAR(GETDATE())) AND (SELECT MONTH(@ExpiryDate)) > (SELECT MONTH(GETDATE()))
					BEGIN
						-- Book Trip
						SELECT @date = GETDATE()

						SELECT TOP 1 @DriverID = d.DriverID
								FROM p2.Drivers d
								INNER JOIN p2.DriverStatus ds
										ON d.DriverStatus = ds.DriverStatusID
								INNER JOIN p2.CarInfo ci
										ON ci.DriverID = d.DriverID
								INNER JOIN p2.CarModelYear cmy
										ON cmy.CarModelYearID = ci.CarModelYearID
								INNER JOIN p2.CarModel cm
										ON cm.CarModelID = cmy.CarModelID
								INNER JOIN p2.CarCapacity cc
										ON cc.CarCapacityID = cm.CarCapacity
								WHERE ds.Text = 'Working  available'
								  AND cc.PassengerCapacity >= @NumberOfPassengers
								  AND cc.LuggageCapacity >= @NumberOfBags

						INSERT INTO p2.Trips (CustomerID, DriverID, DateBooked, IsComplete)
							VALUES	(@CustomerID, @DriverID, @date, 0)

						UPDATE  p2.Drivers
								SET DriverStatus = 4
								WHERE DriverID = @DriverID

						SELECT @TripID = TripID
							   FROM p2.Trips
							   WHERE CustomerID = @CustomerID
							     AND DriverID = @DriverID
								 AND DateBooked = @date

						SELECT  @CreditCard = StoredCreditCardsInfoID 
								FROM p2.StoredCreditCardsInfo c
								WHERE CreditCardNumber = @CreditCardNumber
								  AND ExpiryDate = @ExpiryDate
								  AND CustomerID = @CustomerID
						
						INSERT INTO p2.TimeAndLocation (TripID, PickupTime, DropOffTime, PickupLocation, DropOffLocation)
							VALUES (@TripID, NULL, NULL, @PickupLocation, @DropOffLocation)

						INSERT INTO p2.PassengersAndBagsInfo (TripID, NumberOfPassengers, NumberOfBags)
							VALUES (@TripID, @NumberOfPassengers, @NumberOfBags)

						INSERT INTO p2.TripPaymentInfo (TripID, CreditCardInfo, AmountPaid, Tip)
							VALUES (@TripID, @CreditCard, 0.00, 0.00)

						PRINT 'Trip is successfully booked!'
						PRINT 'Credit Card used for payment: ' + @CreditCardNumber 

					END
					-- Expiry Date associated with Credit Card is invalid
					ELSE 
						PRINT 'Credit Card has expired! Please try again with vaild Credit Card'
    			END
				-- Credit card information provided does NOT match Stored credit card information
				ELSE 
				BEGIN
					-- Expiry Date associated with Credit Card is valid
					IF ((SELECT YEAR(@ExpiryDate)) > (SELECT YEAR(GETDATE())))
					 OR (SELECT YEAR(@ExpiryDate)) = (SELECT YEAR(GETDATE())) AND (SELECT MONTH(@ExpiryDate)) > (SELECT MONTH(GETDATE()))
					BEGIN
						DECLARE @name AS VARCHAR(50)
						DECLARE @address AS INTEGER

						SELECT  @name = CardHolderName, @address = BillingAddressID
								FROM p2.StoredCreditCardsInfo
								WHERE CustomerID = @CustomerID

						-- Add NEW Credit Card added to Customer account
						INSERT INTO p2.StoredCreditCardsInfo (CardHolderName, CreditCardNumber, ExpiryDate, CustomerID, BillingAddressID)
							VALUES (@name, @CreditCardNumber, @ExpiryDate, @CustomerID, @address)
						PRINT 'New Credit Card has been added to the account!'

						-- Book Trip
						SELECT @date = GETDATE()

						SELECT TOP 1 @DriverID = d.DriverID
								FROM p2.Drivers d
								INNER JOIN p2.DriverStatus ds
										ON d.DriverStatus = ds.DriverStatusID
								INNER JOIN p2.CarInfo ci
										ON ci.DriverID = d.DriverID
								INNER JOIN p2.CarModelYear cmy
										ON cmy.CarModelYearID = ci.CarModelYearID
								INNER JOIN p2.CarModel cm
										ON cm.CarModelID = cmy.CarModelID
								INNER JOIN p2.CarCapacity cc
										ON cc.CarCapacityID = cm.CarCapacity
								WHERE ds.Text = 'Working  available'
								  AND cc.PassengerCapacity >= @NumberOfPassengers
								  AND cc.LuggageCapacity >= @NumberOfBags	

						INSERT INTO p2.Trips (CustomerID, DriverID, DateBooked, IsComplete)
							VALUES	(@CustomerID, @DriverID, @date, 0)

						UPDATE  p2.Drivers
								SET DriverStatus = 4
								WHERE DriverID = @DriverID

						SELECT @TripID = TripID
							   FROM p2.Trips
							   WHERE CustomerID = @CustomerID
							     AND DriverID = @DriverID
								 AND DateBooked = @date

						SELECT  @CreditCard = StoredCreditCardsInfoID
								FROM p2.StoredCreditCardsInfo 
								WHERE CreditCardNumber = @CreditCardNumber
								  AND ExpiryDate = @ExpiryDate
								  AND CustomerID = @CustomerID

						INSERT INTO p2.TimeAndLocation (TripID, PickupTime, DropOffTime, PickupLocation, DropOffLocation)
							VALUES (@TripID, NULL, NULL, @PickupLocation, @DropOffLocation)

						INSERT INTO p2.PassengersAndBagsInfo (TripID, NumberOfPassengers, NumberOfBags)
							VALUES (@TripID, @NumberOfPassengers, @NumberOfBags)

						INSERT INTO p2.TripPaymentInfo (TripID, CreditCardInfo, AmountPaid, Tip)
							VALUES (@TripID, @CreditCard, 0.00, 0.00)

						PRINT 'Trip is successfully booked!'
						PRINT 'Credit Card used for payment: ' + @CreditCardNumber

					END
					-- Expiry Date associated with Credit Card is invalid
					ELSE 
						PRINT 'Please provide Credit Card with valid Expiry Date to book the trip.'
				END
			END
		END;

--OBJECT 3
--STORED PROCEDURE: Provides total number of trips taken by a particular customer along with corresponding median cost using Cursor
CREATE PROCEDURE p2.TotalTripsAndMedianCost (@CustomerID AS INTEGER)
AS
	BEGIN
		-- Checks if CustomerID is valid
		IF (SELECT	COUNT(*) 
					FROM p2.Customers 
					WHERE CustomerID = @CustomerID) > 0
		BEGIN
			-- Computes total nuumber of Trip
			DECLARE @count AS INTEGER
			DECLARE @fetchNext AS INTEGER
			DECLARE cursorTotalTrips CURSOR FOR
									SELECT  TripID
											FROM p2.Trips
											WHERE CustomerID = @CustomerID
			SELECT @count = 0
			OPEN cursorTotalTrips
			FETCH NEXT FROM cursorTotalTrips INTO @fetchNext
			WHILE @@FETCH_STATUS = 0
			BEGIN
				SELECT @count = (@count + 1)
				FETCH NEXT FROM cursorTotalTrips INTO @fetchNext
			END
			CLOSE cursorTotalTrips
			DEALLOCATE cursorTotalTrips

			-- Computes median trip cost
			DECLARE @medianTripCost AS DECIMAL(5,2)
			DECLARE @totalRecords AS INTEGER
			DECLARE @midRecords AS INTEGER
			DECLARE @mid1 AS DECIMAL(5,2)
			DECLARE @mid2 AS DECIMAL(5,2)
			DECLARE cursorMedianCost SCROLL CURSOR FOR
									 SELECT  tp.AmountPaid
											 FROM p2.Trips t
											 INNER JOIN p2.TripPaymentInfo tp
													 ON t.TripID = tp.TripID
											 WHERE t.CustomerID = @CustomerID
											 ORDER BY tp.AmountPaid				
			SELECT  @totalRecords = COUNT(*)
					FROM p2.Trips t
					INNER JOIN p2.TripPaymentInfo tp
							ON t.TripID = tp.TripID
					WHERE t.CustomerID = @CustomerID
			SELECT @midRecords = (@totalRecords/2)				   
			OPEN cursorMedianCost
			BEGIN
				IF (@totalRecords%2 = 1)
					BEGIN
						IF @totalRecords = 1
							FETCH ABSOLUTE @totalRecords FROM cursorMedianCost INTO @medianTripCost
						ELSE
							FETCH ABSOLUTE @midRecords FROM cursorMedianCost INTO @medianTripCost
					END
				ELSE
					BEGIN
						FETCH ABSOLUTE @midRecords FROM cursorMedianCost INTO @mid1
						FETCH NEXT FROM cursorMedianCost INTO @mid2
						SET @medianTripCost = (@mid1 + @mid2)/2.00
					END
			END
			CLOSE cursorMedianCost
			DEALLOCATE cursorMedianCost

			DECLARE @name AS VARCHAR(100)
			SELECT @name = FirstName + ', ' + LastName
				   FROM p2.Customers
				   WHERE CustomerID = @CustomerID 

			PRINT @name + ' took ' + CAST(@count AS VARCHAR(10)) + ' trips in total with median cost of ' + CAST(@medianTripCost AS VARCHAR(10)) + '$.'
		END
		ELSE
			PRINT 'Error! CustomerID provided is invalid.'
	END;

-- OBJECT 4
-- STORED PROCEDURE: Makes payment to the provided bank account details for a particular trip. TripID, accounting and routing numbers are verified.
--                   If amount already exists for that trip, it is updated to new value and If not, new values are added.
CREATE PROCEDURE p2.MakePayment (@TripID AS INTEGER,
								 @Amount AS DECIMAL(5,2),
								 @AccountNumber AS VARCHAR(15),
								 @RoutingNumber AS VARCHAR(15))
AS
	BEGIN
		IF (SELECT COUNT(*) FROM p2.Trips WHERE TripID = @TripID) = 0
			PRINT 'Error! Invalid TripID. Payment failed.'
		ELSE 
			BEGIN
				DECLARE @driver AS INTEGER
				SELECT @driver = DriverID
					   FROM p2.Trips
					   WHERE TripID = @TripID

				IF (SELECT	COUNT(*) 
							FROM p2.Drivers d
							INNER JOIN p2.BankAccountInfo b
							        ON d.DriverID = b.DriverID
							WHERE d.DriverID = @driver
							AND b.AccountNumber = @AccountNumber
							AND b.RoutingNumber = @RoutingNumber) = 0
				BEGIN
					PRINT 'Error! Invalid Account number or Routing number. Payment failed.'
				END
				ELSE
				BEGIN
					IF (SELECT COUNT(*)
							   FROM p2.TripPayments
							   WHERE TripID = @TripID) = 0
					BEGIN
						DECLARE @date AS DATETIME
						DECLARE @bankAccount AS INTEGER
						DECLARE @Payment AS INTEGER

						SELECT @date = GETDATE()
						SELECT	@bankAccount = b.BankAccountInfoID 
								FROM p2.Drivers d
								INNER JOIN p2.BankAccountInfo b
										ON d.DriverID = b.DriverID
								WHERE d.DriverID = @driver
								AND b.AccountNumber = @AccountNumber
								AND b.RoutingNumber = @RoutingNumber

						INSERT INTO p2.Payments (DateWhenMade, BankAccountInfoID)
							VALUES (@date,@bankAccount)

						SELECT  @Payment = PaymentID
								FROM Payments
								WHERE BankAccountInfoID = @bankAccount
								  AND DateWhenMade = @date

						INSERT INTO p2.TripPayments (TripID, PaymentID, Amount)
							VALUES (@TripID, @Payment, @Amount)

						PRINT 'Payment Successful!'
					END
					ELSE
					BEGIN
						DECLARE @Old AS DECIMAL(5,2)
						SELECT @Old = Amount
							   FROM p2.TripPayments
							   WHERE TripID = @TripID

						UPDATE p2.TripPayments
						   SET Amount = @Amount
						 WHERE TripID = @TripID

						 PRINT 'Payment Successful!'
						 PRINT 'Payment for TripID: ' + CAST(@TripID AS VARCHAR(10)) + ' has been updated from previous amount ' + CAST(@Old AS VARCHAR(10)) + 
							   '$ to new amount ' + CAST(@Amount AS VARCHAR(10)) + '$.'
					END
				END
			END
	END;

-- OBJECT 5:
-- FUNCTION: Returns number of days for insurance expiry for valid DriverID. Returns -1 for invalid DriverID
CREATE FUNCTION p2.NumberOfDaysForInsuranceExpiry (@DriverID AS INTEGER)
RETURNS INTEGER
AS
	BEGIN
		IF (SELECT  COUNT(*)
					FROM p2.Drivers
					WHERE DriverID = @DriverID) = 0
			RETURN -1
		ELSE
		BEGIN
			DECLARE @result AS INTEGER
			DECLARE @currentDate AS DATETIME
			SELECT @currentDate = GETDATE()

			DECLARE @expiryDate AS DATETIME
			SELECT  @expiryDate = ExpiryDate
					FROM p2.InsuranceInfo
					WHERE DriverID = @DriverID
		
			SELECT @result = DATEDIFF(DAY, @currentDate, @expiryDate)	
		END
		RETURN @result
	END;

--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
-- REFERENCES
--http://www.dba-sql-server.com/sql_server_tips/t_super_sql_444_calculating_median_sp.htm
--///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
