CREATE DATABASE MISTP;
USE MISTP;

CREATE TABLE Society (
    SocietyID INT AUTO_INCREMENT PRIMARY KEY,
    Name NVARCHAR(255) NOT NULL,
    Address NVARCHAR(255) NOT NULL
);

-- Property Table
CREATE TABLE Property (
    PropertyID INT AUTO_INCREMENT PRIMARY KEY,
    SocietyID INT NOT NULL,
    PropertyType ENUM('Residential', 'Commercial') NOT NULL,
    Size INT NOT NULL,
    RentAmount DECIMAL(10, 2) NOT NULL,
    Status ENUM('Available', 'Rented') NOT NULL,
    FOREIGN KEY (SocietyID) REFERENCES Society(SocietyID)
);

-- Tenant Table
CREATE TABLE Tenant (
    TenantID INT AUTO_INCREMENT PRIMARY KEY,
    FullName NVARCHAR(255) NOT NULL,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PhoneNumber NVARCHAR(15) NOT NULL UNIQUE
);

-- RentPayment Table
CREATE TABLE RentPayment (
    PaymentID INT AUTO_INCREMENT PRIMARY KEY,
    PropertyID INT NOT NULL,
    TenantID INT NOT NULL,
    PaymentDate DATE NOT NULL,
    AmountPaid DECIMAL(10, 2) NOT NULL,
    LateFee DECIMAL(10, 2) DEFAULT 0,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (TenantID) REFERENCES Tenant(TenantID)
);

-- MaintenanceRequest Table
CREATE TABLE MaintenanceRequest (
    RequestID INT AUTO_INCREMENT PRIMARY KEY,
    PropertyID INT NOT NULL,
    TenantID INT NOT NULL,
    RequestDate DATE NOT NULL,
    Description NVARCHAR(255) NOT NULL,
    Status ENUM('Pending', 'In Progress', 'Resolved') NOT NULL,
    FOREIGN KEY (PropertyID) REFERENCES Property(PropertyID),
    FOREIGN KEY (TenantID) REFERENCES Tenant(TenantID)
);

-- AgencyStaff Table
CREATE TABLE AgencyStaff (
    StaffID INT AUTO_INCREMENT PRIMARY KEY,
    FullName NVARCHAR(255) NOT NULL,
    Role ENUM('Admin', 'Manager', 'Staff') NOT NULL,
    ContactNumber NVARCHAR(15) NOT NULL
);

SELECT * FROM Society;
SELECT * FROM Property;
SELECT * FROM Tenant;
SELECT * FROM RentPayment;
SELECT * FROM MaintenanceRequest;
SELECT * FROM AgencyStaff;

-- Index for faster lookup by TenantID in RentPayment
CREATE INDEX idx_tenantid_rentpayment ON RentPayment(TenantID);
-- Index for faster lookup by PropertyID in MaintenanceRequest
CREATE INDEX idx_propertyid_maintenance ON MaintenanceRequest(PropertyID);


-- View for Properties Rented
CREATE VIEW RentedProperties AS
SELECT
    p.PropertyID,
    s.Name AS SocietyName,
    p.PropertyType,
    p.RentAmount,
    t.FullName AS TenantName
FROM
    Property p
JOIN
    Society s ON p.SocietyID = s.SocietyID
JOIN
    RentPayment rp ON p.PropertyID = rp.PropertyID
JOIN
    Tenant t ON rp.TenantID = t.TenantID
WHERE
    p.Status = 'Rented';
    
-- Logging Table
CREATE TABLE RentPaymentLog (
    LogID INT AUTO_INCREMENT PRIMARY KEY,
    PaymentID INT,
    OldAmount DECIMAL(10,2),
    NewAmount DECIMAL(10,2),
    ChangeDate TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Define the Trigger
DELIMITER $$

CREATE TRIGGER LogRentPaymentUpdate
AFTER UPDATE ON RentPayment
FOR EACH ROW
BEGIN
    INSERT INTO RentPaymentLog (PaymentID, OldAmount, NewAmount)
    VALUES (OLD.PaymentID, OLD.AmountPaid, NEW.AmountPaid);
END $$

DELIMITER ;

EXPLAIN SELECT * FROM RentPayment WHERE TenantID = 1;
SELECT * FROM RentedProperties;
UPDATE RentPayment SET AmountPaid = 2000 WHERE PaymentID = 1;
SELECT * FROM RentPaymentLog;
CALL TotalRentBySociety(1);

-- Stored Procedure to calculate total rent collected for a Society
DELIMITER //
CREATE PROCEDURE TotalRentBySociety(IN SocietyIDInput INT)
BEGIN
    SELECT
        s.Name AS SocietyName,
        SUM(rp.AmountPaid) AS TotalRentCollected
    FROM
        Society s
    JOIN
        Property p ON s.SocietyID = p.SocietyID
    JOIN
        RentPayment rp ON p.PropertyID = rp.PropertyID
    WHERE
        s.SocietyID = SocietyIDInput
    GROUP BY
        s.Name;
END //
DELIMITER ;

-- Create Users with Roles
CREATE USER 'read_only_user'@'%' IDENTIFIED BY 'password123';
CREATE USER 'data_entry_user'@'%' IDENTIFIED BY 'password123';

-- Assign Permissions
GRANT SELECT ON MISTP.* TO 'read_only_user'@'%';
GRANT INSERT, UPDATE, DELETE ON MISTP.* TO 'data_entry_user'@'%';

-- Apply Privileges

FLUSH PRIVILEGES;


-- Insert Data for Society
INSERT INTO Society (Name, Address)
VALUES
('Riverdale Apartments', '321 Maple Drive, Smallville'),
('Willow Creek Homes', '654 Cedar Lane, Star City'),
('Evergreen Villas', '111 Birch Boulevard, Central City'),
('Pine Valley Estates', '222 Redwood Road, Coast City'),
('Silver Oaks', '333 Aspen Avenue, Blüdhaven'),
('Crescent Hill Society', '444 Laurel Lane, Midway City'),
('Golden Meadows', '555 Walnut Street, Keystone City'),
('Sunset Grove', '123 Sunset Drive, Hill Valley'),
('Oceanview Residence', '456 Beach Road, Seaside City'),
('Mountain Ridge', '789 Highland Lane, Rocky Mountains'),
('Lakeside Village', '101 Lakeview Road, Clearwater'),
('Maplewood Apartments', '202 Maple Street, Autumn Town'),
('Hillcrest Enclave', '303 Hillside Avenue, Green Valley'),
('Birchwood Court', '404 Birchwood Drive, Red River'),
('Bluebell Manor', '505 Bluebell Way, Silver Creek');

SELECT * FROM Society;

-- Insert Data for Property
INSERT INTO Property (SocietyID, PropertyType, Size, RentAmount, Status)
VALUES
(1, 'Residential', 1200, 3500.00, 'Available'),
(2, 'Commercial', 1500, 5000.00, 'Rented'),
(3, 'Residential', 1300, 4000.00, 'Available'),
(4, 'Commercial', 1100, 3000.00, 'Rented'),
(5, 'Residential', 1400, 4200.00, 'Available'),
(6, 'Residential', 1200, 3600.00, 'Rented'),
(7, 'Commercial', 1500, 5500.00, 'Available'),
(8, 'Residential', 1300, 3700.00, 'Rented'),
(9, 'Residential', 1100, 3000.00, 'Available'),
(10, 'Commercial', 1200, 5000.00, 'Rented'),
(11, 'Residential', 1400, 4500.00, 'Available'),
(12, 'Commercial', 1300, 4700.00, 'Rented'),
(13, 'Residential', 1600, 5500.00, 'Available'),
(14, 'Residential', 1100, 2900.00, 'Available'),
(15, 'Commercial', 1500, 5100.00, 'Rented');

SELECT * FROM Property;

-- Insert Data for Tenant
INSERT INTO Tenant (FullName, Email, PhoneNumber)
VALUES
/* ('Alice Johnson', 'alice.johnson@example.com', '123-456-7890'),
('Bob Smith', 'bob.smith@example.com', '987-654-3210'),
('Charlie Brown', 'charlie.brown@example.com', '555-666-7777'),
('Diana Prince', 'diana.prince@example.com', '444-333-2222'),
('Edward Cullen', 'edward.cullen@example.com', '111-222-3333'),
('Fiona Adams', 'fiona.adams@example.com', '888-999-0000'),
('George Taylor', 'george.taylor@example.com', '777-888-9999'),
('Hannah Lee', 'hannah.lee@example.com', '666-777-8888'),
('Isaac Newton', 'isaac.newton@example.com', '555-444-3333'),
('Julia Roberts', 'julia.roberts@example.com', '444-555-6666'),
('Kevin Hart', 'kevin.hart@example.com', '333-444-5555'),
('Laura Hill', 'laura.hill@example.com', '222-333-4444'),
('Michael Jordan', 'michael.jordan@example.com', '999-888-7777'),
('Nancy Green', 'nancy.green@example.com', '111-000-9999'),
('Olivia White', 'olivia.white@example.com', '555-123-4567') */

('Peter Parker', 'peter.parker@example.com', '101-202-3030'),
('Clark Kent', 'clark.kent@example.com', '202-303-4040'),
('Bruce Wayne', 'bruce.wayne@example.com', '303-404-5050'),
('Tony Stark', 'tony.stark@example.com', '404-505-6060'),
('Natasha Romanoff', 'natasha.romanoff@example.com', '505-606-7070'),
('Steve Rogers', 'steve.rogers@example.com', '606-707-8080'),
('Wanda Maximoff', 'wanda.maximoff@example.com', '707-808-9090'),
('Thor Odinson', 'thor.odinson@example.com', '808-909-1010'),
('Barry Allen', 'barry.allen@example.com', '909-101-2020'),
('Selina Kyle', 'selina.kyle@example.com', '212-313-4141'),
('Lois Lane', 'lois.lane@example.com', '313-414-5151'),
('Hal Jordan', 'hal.jordan@example.com', '414-515-6161'),
('Arthur Curry', 'arthur.curry@example.com', '515-616-7171'),
('Victor Stone', 'victor.stone@example.com', '616-717-8181'),
('Jean Grey', 'jean.grey@example.com', '717-818-9191'),
('Scott Summers', 'scott.summers@example.com', '818-919-1010'),
('Logan Howlett', 'logan.howlett@example.com', '919-101-1111'),
('Charles Xavier', 'charles.xavier@example.com', '101-111-1212'),
('Bruce Banner', 'bruce.banner@example.com', '121-212-3131'),
('Pepper Potts', 'pepper.potts@example.com', '313-414-5152'),
('Peter Quill', 'peter.quill@example.com', '515-616-7172'),
('Gamora Zen', 'gamora.zen@example.com', '717-818-9192'),
('Stephen Strange', 'stephen.strange@example.com', '919-101-2121'),
('T Challa', 'tchalla@example.com', '212-313-4142'),
('Shuri Wakanda', 'shuri.wakanda@example.com', '414-515-6163'),
('Nick Fury', 'nick.fury@example.com', '616-717-8183'),
('Carol Danvers', 'carol.danvers@example.com', '818-919-1013');


SELECT * FROM Tenant;

-- Insert Data for RentPayment
INSERT INTO RentPayment (PropertyID, TenantID, PaymentDate, AmountPaid, LateFee)
VALUES
/* (2, 1, '2024-12-01', 3000.00, 0),
(4, 2, '2024-12-02', 1400.00, 50.00),
(6, 3, '2024-12-03', 3500.00, 0),
(8, 4, '2024-12-04', 1300.00, 0),
(10, 5, '2024-12-05', 1600.00, 100.00),
(1, 6, '2024-12-06', 1500.00, 0),
(3, 7, '2024-12-07', 1800.00, 0),
(5, 8, '2024-12-08', 1200.00, 50.00),
(7, 9, '2024-12-09', 1550.00, 0),
(9, 10, '2024-12-10', 1350.00, 0),
(11, 11, '2024-12-11', 3600.00, 50.00),
(12, 12, '2024-12-12', 1200.00, 0),
(13, 13, '2024-12-13', 1550.00, 25.00),
(14, 14, '2024-12-14', 2900.00, 0),
(15, 15, '2024-12-15', 5100.00, 10.00);*/
(2, 14, '2024-12-14', 1400.00, 0),
(4, 15, '2024-12-15', 3500.00, 0),
(6, 16, '2024-12-16', 1800.00, 50.00),
(8, 17, '2024-12-17', 2000.00, 0),
(10, 18, '2024-12-18', 1450.00, 25.00),
(1, 19, '2024-12-19', 1700.00, 0),
(3, 20, '2024-12-20', 1600.00, 0),
(5, 21, '2024-12-21', 1350.00, 50.00),
(7, 22, '2024-12-22', 1550.00, 0),
(9, 23, '2024-12-23', 1250.00, 0),
(11, 24, '2024-12-24', 1300.00, 100.00),
(12, 25, '2024-12-25', 1500.00, 0),
(13, 26, '2024-12-26', 1750.00, 0),
(2, 27, '2024-12-27', 1400.00, 50.00),
(4, 28, '2024-12-28', 1650.00, 0),
(6, 29, '2024-12-29', 2000.00, 0),
(8, 30, '2024-12-30', 2100.00, 0),
(10, 31, '2024-12-31', 1800.00, 75.00),
(1, 32, '2025-01-01', 1550.00, 0),
(3, 33, '2025-01-02', 1900.00, 25.00),
(5, 34, '2025-01-03', 2100.00, 0),
(7, 35, '2025-01-04', 1950.00, 0),
(9, 36, '2025-01-05', 1600.00, 50.00),
(11, 37, '2025-01-06', 2000.00, 0),
(12, 38, '2025-01-07', 2200.00, 0),
(13, 39, '2025-01-08', 2400.00, 0),
(2, 40, '2025-01-09', 2300.00, 25.00);

SELECT * FROM RentPayment;

-- Insert Data for MaintenanceRequest
INSERT INTO MaintenanceRequest (PropertyID, TenantID, RequestDate, Description, Status)
VALUES
(2, 1, '2024-11-28', 'Leaking faucet in kitchen', 'Resolved'),
(4, 2, '2024-12-01', 'Broken window in living room', 'In Progress'),
(6, 3, '2024-12-02', 'Heating system not working', 'Pending'),
(8, 4, '2024-12-03', 'Air conditioning malfunction', 'Resolved'),
(10, 5, '2024-12-04', 'Broken door lock', 'Pending'),
(1, 6, '2024-12-05', 'Clogged sink', 'In Progress'),
(3, 7, '2024-12-06', 'Faulty electrical wiring', 'Pending'),
(5, 8, '2024-12-07', 'Pest control issue', 'Resolved'),
(7, 9, '2024-12-08', 'Water heater not working', 'Resolved'),
(9, 10, '2024-12-09', 'Cracked tiles in bathroom', 'Pending'),
(11, 11, '2024-12-10', 'Broken kitchen cabinet', 'Resolved'),
(12, 12, '2024-12-11', 'Toilet flush not working', 'In Progress'),
(13, 13, '2024-12-12', 'Ceiling leak in bedroom', 'Pending'),
(14, 14, '2024-12-13', 'Faulty plumbing in bathroom', 'In Progress'),
(15, 15, '2024-12-14', 'Broken refrigerator door', 'Resolved');

SELECT * FROM MaintenanceRequest;

-- Insert Data for AgencyStaff
INSERT INTO AgencyStaff (FullName, Role, ContactNumber)
VALUES
('John Doe', 'Admin', '222-333-4444'),
('Jane Smith', 'Manager', '555-444-3333'),
('Emily Davis', 'Staff', '666-555-4444'),
('Robert Johnson', 'Staff', '777-666-5555'),
('Samantha Carter', 'Manager', '888-777-6666'),
('William Moore', 'Admin', '999-888-7777'),
('Olivia Brown', 'Staff', '111-999-8888'),
('James White', 'Manager', '222-111-9999'),
('Sophia Clark', 'Staff', '333-222-1111'),
('Benjamin Adams', 'Admin', '444-333-2222'),
('Isabelle Green', 'Staff', '555-444-2222'),
('Daniel Harris', 'Manager', '666-555-3333'),
('Lucas King', 'Staff', '777-666-4444'),
('Maria Lewis', 'Admin', '888-777-5555'),
('Zoe Mitchell', 'Manager', '999-888-6666');

SELECT * FROM AgencyStaff;
