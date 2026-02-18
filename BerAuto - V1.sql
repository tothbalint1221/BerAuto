-- Ha megcsinálod a Scaffolding-ot(DbContext generálsáa) akkor az enum-okat kézzel kell!!!
--drop database BerAutoDb
 -----DB  
CREATE DATABASE BerAutoDb;
GO

USE BerAutoDb;
GO

-- USERS
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    Email NVARCHAR(150) NULL,
    PasswordHash NVARCHAR(300) NULL,
    Address NVARCHAR(250) NULL,
    PhoneNumber NVARCHAR(50) NULL,
    Role NVARCHAR(20) NOT NULL,           -- User / Clerk / Admin
    IsRegistered BIT NOT NULL DEFAULT 1   -- vendég = 0 //(vendég = false)
);

-- Role validáció
ALTER TABLE Users
ADD CONSTRAINT CK_Users_Role CHECK (Role IN ('User','Clerk','Admin'));

-- Email unique (csak ha nem NULL) -> vendégeknél NULL lehet
CREATE UNIQUE INDEX UX_Users_Email_NotNull ON Users(Email) WHERE Email IS NOT NULL;

-- CARS
CREATE TABLE Cars (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    Brand NVARCHAR(100) NOT NULL,
    Model NVARCHAR(100) NOT NULL,
    Category NVARCHAR(20) NOT NULL,     -- Economy / SUV / Luxury //enum c#-ban majd
    DailyPrice DECIMAL(10,2) NOT NULL,
    Mileage INT NOT NULL,
    IsAvailable BIT NOT NULL DEFAULT 1  -- adminisztratív elérhetõség (pl. szerviz)
);

ALTER TABLE Cars
ADD CONSTRAINT CK_Cars_Category CHECK (Category IN ('Economy','SUV','Luxury'));

-- RENTALS - kölcsönzés
CREATE TABLE Rentals (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    CarId INT NOT NULL,
    StartDate DATETIME NOT NULL,
    EndDate DATETIME NOT NULL,
    TotalCost DECIMAL(10,2) NULL,       -- lehet számolt, ezért NULL engedett ,max 10 szam és 2 tizedesre kerekítettem(10,2)
    Status NVARCHAR(20) NOT NULL,       -- Requested / Approved / Active / Closed / Rejected //enum
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL,

    CONSTRAINT FK_Rentals_Users FOREIGN KEY (UserId) REFERENCES Users(Id),
    CONSTRAINT FK_Rentals_Cars  FOREIGN KEY (CarId)  REFERENCES Cars(Id)
);

ALTER TABLE Rentals
ADD CONSTRAINT CK_Rentals_Status CHECK (Status IN ('Requested','Approved','Active','Closed','Rejected'));

ALTER TABLE Rentals
ADD CONSTRAINT CK_Rentals_Dates CHECK (EndDate > StartDate); --Ez vicces hiba lennexdd

-- INVOICES
CREATE TABLE Invoices (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    RentalId INT NOT NULL UNIQUE,       -- 1:1 Rental-hez
    IssueDate DATETIME NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    IsPaid BIT NOT NULL DEFAULT 0,
    CreatedAt DATETIME NOT NULL DEFAULT GETDATE(),
    UpdatedAt DATETIME NULL,

    CONSTRAINT FK_Invoices_Rentals FOREIGN KEY (RentalId) REFERENCES Rentals(Id)
);

-- Indexek
CREATE INDEX IX_Rentals_UserId ON Rentals(UserId);
CREATE INDEX IX_Rentals_CarId ON Rentals(CarId);
CREATE INDEX IX_Invoices_RentalId ON Invoices(RentalId);

-- adatok:

-- Felhasználói adatok:
INSERT INTO Users (Name, Email, PasswordHash, Address, PhoneNumber, Role, IsRegistered)
VALUES
('Admin Aladár', 'admin@berauto.hu', 'HASH_ADMIN', 'Veszprém, Fõ utca 1.', '+36 30 111 1111', 'Admin', 1),
('Ügyintézõ Eszter', 'clerk@berauto.hu', 'HASH_CLERK', 'Veszprém, Kossuth u. 2.', '+36 30 222 2222', 'Clerk', 1),
('Tóth Bálint', 'balint@email.hu', 'HASH_USER1', 'Veszprém, Egyetem u. 3.', '+36 30 333 3333', 'User', 1),
('Vendég Béla', NULL, NULL, NULL, '+36 30 444 4444', 'User', 0),
('Pum Pál', 'pum.pal@email.hu', 'HASH_PUM', 'Székesfehérvár, Gumi utca 8.', '+36 30 555 0001', 'User', 1),
('Bérelõ Béla', 'berelo.bela@auto.hu', 'HASH_BELA', 'Gyõr, Kuplung köz 4.', '+36 30 555 0002', 'User', 1),
('Gyors Gábor', 'gyors.gabor@speed.hu', 'HASH_GABOR', 'Budapest, Drift tér 9.', '+36 30 555 0003', 'User', 1),
('Fék Ferenc', 'fek.ferenc@lassu.hu', 'HASH_FEK', 'Pécs, Féktáv utca 12.', '+36 30 555 0004', 'User', 1),
('Olaj Olga', 'olga@motor.hu', 'HASH_OLGA', 'Debrecen, Kenõanyag köz 6.', '+36 30 555 0005', 'User', 1),
('Kuplung Kálmán', 'kuplung@valto.hu', 'HASH_KALMAN', 'Miskolc, Sebesség utca 2.', '+36 30 555 0006', 'User', 1),
('Parkoló Piroska', NULL, NULL, 'Ismeretlen cím', '+36 30 555 0007', 'User', 0);

-- kOcsi adatok
INSERT INTO Cars (Brand, Model, Category, DailyPrice, Mileage, IsAvailable)
VALUES
('Toyota', 'Corolla', 'Economy', 12000, 50500, 1),
('BMW', 'X5', 'SUV', 25000, 30500, 1),
('Mercedes', 'S-Class', 'Luxury', 40000, 20500, 0),
('Suzuki', 'Swift', 'Economy', 9500, 65432, 1),
('Toyota', 'Yaris', 'Economy', 10000, 45210, 1),
('BMW', 'X3', 'SUV', 23000, 38700, 1),
('Audi', 'Q7', 'SUV', 29000, 50200, 1),
('Mercedes', 'C-Class', 'Luxury', 35000, 29800, 1);

--Bérlési adatok
-- Approved, Requested, Active (dátumok validak)
INSERT INTO Rentals (UserId, CarId, StartDate, EndDate, TotalCost, Status)
VALUES
(3, 1, '2026-02-20', '2026-02-23', 36000, 'Approved'),
(4, 2, '2026-02-21', '2026-02-22', 25000, 'Requested'),
(3, 2, '2026-02-10', '2026-02-12', 50000, 'Active'),
(5, 4, '2026-03-01', '2026-03-04', 3*9500, 'Approved'),
(6, 5, '2026-03-05', '2026-03-07', 2*10000, 'Requested'),
(7, 6, '2026-02-15', '2026-02-18', 3*23000, 'Closed'),
(8, 7, '2026-02-20', '2026-02-22', 2*29000, 'Active');

--Számla adatok
INSERT INTO Invoices (RentalId, IssueDate, Amount, IsPaid)
VALUES
(1, GETDATE(), 36000, 0),
(4, GETDATE(), 28500, 0),
(6, GETDATE(), 69000, 1);


---- Ellenõrzés
--SELECT * FROM Users;
--SELECT * FROM Cars;
--SELECT * FROM Rentals;
--SELECT * FROM Invoices;

--SELECT
--    r.Id AS RentalId,
--    u.Name AS UserName,
--    u.IsRegistered,
--    u.Email,
--    c.Brand,
--    c.Model,
--    r.StartDate,
--    r.EndDate,
--    r.Status,
--    r.TotalCost
--FROM Rentals r
--JOIN Users u ON u.Id = r.UserId
--JOIN Cars  c ON c.Id = r.CarId
--ORDER BY r.Id;