CREATE DATABASE IF NOT EXISTS bloodlink;
USE bloodlink;

DROP VIEW IF EXISTS eligible_donors_view;
DROP VIEW IF EXISTS expiring_soon_view;
DROP VIEW IF EXISTS low_stock_view;

DROP TRIGGER IF EXISTS check_donor_eligibility;
DROP TRIGGER IF EXISTS update_next_eligibility;
DROP PROCEDURE IF EXISTS Issue_Blood;

DROP TABLE IF EXISTS Request;
DROP TABLE IF EXISTS Donation;
DROP TABLE IF EXISTS BloodUnit;
DROP TABLE IF EXISTS Hospital;
DROP TABLE IF EXISTS Donor;
DROP TABLE IF EXISTS BloodCompatibility;

CREATE TABLE BloodCompatibility (
    donor_group VARCHAR(5) NOT NULL,
    receiver_group VARCHAR(5) NOT NULL,
    PRIMARY KEY (donor_group, receiver_group)
);

CREATE TABLE Donor (
    donor_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    age INT NOT NULL CHECK (age >= 18),
    gender VARCHAR(10) NOT NULL,
    blood_group VARCHAR(5) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL,
    email VARCHAR(100) UNIQUE,
    last_donation_date DATE,
    next_eligible_date DATE
);

CREATE TABLE Hospital (
    hospital_id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_name VARCHAR(100) NOT NULL,
    location VARCHAR(150) NOT NULL,
    phone VARCHAR(15) UNIQUE NOT NULL
);

CREATE TABLE BloodUnit (
    unit_id INT AUTO_INCREMENT PRIMARY KEY,
    blood_group VARCHAR(5) NOT NULL,
    donation_date DATE NOT NULL,
    expiry_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Available',
    CHECK (status IN ('Available', 'Issued', 'Expired'))
);

CREATE TABLE Donation (
    donation_id INT AUTO_INCREMENT PRIMARY KEY,
    donor_id INT NOT NULL,
    unit_id INT NOT NULL UNIQUE,
    FOREIGN KEY (donor_id) REFERENCES Donor(donor_id),
    FOREIGN KEY (unit_id) REFERENCES BloodUnit(unit_id)
);

CREATE TABLE Request (
    request_id INT AUTO_INCREMENT PRIMARY KEY,
    hospital_id INT NOT NULL,
    blood_group VARCHAR(5) NOT NULL,
    quantity INT NOT NULL CHECK (quantity > 0),
    request_type VARCHAR(20) NOT NULL,
    request_date DATE NOT NULL,
    status VARCHAR(20) DEFAULT 'Pending',
    FOREIGN KEY (hospital_id) REFERENCES Hospital(hospital_id),
    CHECK (request_type IN ('Normal', 'Emergency'))
);

INSERT INTO BloodCompatibility (donor_group, receiver_group) VALUES
('O-', 'O-'), ('O-', 'O+'), ('O-', 'A-'), ('O-', 'A+'),
('O-', 'B-'), ('O-', 'B+'), ('O-', 'AB-'), ('O-', 'AB+'),
('O+', 'O+'), ('O+', 'A+'), ('O+', 'B+'), ('O+', 'AB+'),
('A-', 'A-'), ('A-', 'A+'), ('A-', 'AB-'), ('A-', 'AB+'),
('A+', 'A+'), ('A+', 'AB+'),
('B-', 'B-'), ('B-', 'B+'), ('B-', 'AB-'), ('B-', 'AB+'),
('B+', 'B+'), ('B+', 'AB+'),
('AB-', 'AB-'), ('AB-', 'AB+'),
('AB+', 'AB+');

INSERT INTO Donor (name, age, gender, blood_group, phone, email, last_donation_date, next_eligible_date) VALUES
('Rahul Sharma', 24, 'Male', 'O+', '9991110001', 'rahul@gmail.com', '2026-02-01', '2026-03-29'),
('Priya Verma', 22, 'Female', 'A+', '9991110002', 'priya@gmail.com', '2026-01-15', '2026-03-11'),
('Aman Singh', 25, 'Male', 'B+', '9991110003', 'aman@gmail.com', '2026-03-10', '2026-05-05'),
('Sneha Kapoor', 23, 'Female', 'AB+', '9991110004', 'sneha@gmail.com', NULL, NULL);

INSERT INTO Hospital (hospital_name, location, phone) VALUES
('Apollo Hospital', 'Delhi', '9876543210'),
('Fortis Hospital', 'Chandigarh', '9876543211'),
('Max Hospital', 'Mumbai', '9876543212');

INSERT INTO BloodUnit (blood_group, donation_date, expiry_date, status) VALUES
('B+', '2026-04-28', '2026-06-09', 'Available'),
('O+', '2026-04-01', '2026-05-13', 'Issued'),
('A+', '2026-04-05', '2026-05-17', 'Available'),
('B+', '2026-04-07', '2026-05-19', 'Available');

DELIMITER //

CREATE TRIGGER check_donor_eligibility
BEFORE INSERT ON Donation
FOR EACH ROW
BEGIN
    DECLARE eligible_date DATE;

    SELECT next_eligible_date
    INTO eligible_date
    FROM Donor
    WHERE donor_id = NEW.donor_id;

    IF eligible_date IS NOT NULL AND CURDATE() < eligible_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Donor is not yet eligible to donate again';
    END IF;
END //

CREATE TRIGGER update_next_eligibility
AFTER INSERT ON Donation
FOR EACH ROW
BEGIN
    DECLARE donation_dt DATE;

    SELECT donation_date
    INTO donation_dt
    FROM BloodUnit
    WHERE unit_id = NEW.unit_id;

    UPDATE Donor
    SET
        last_donation_date = donation_dt,
        next_eligible_date = DATE_ADD(donation_dt, INTERVAL 56 DAY)
    WHERE donor_id = NEW.donor_id;
END //

CREATE PROCEDURE Issue_Blood(
    IN req_blood_group VARCHAR(5)
)
BEGIN
    DECLARE selected_unit INT;

    SELECT unit_id
    INTO selected_unit
    FROM BloodUnit
    WHERE blood_group = req_blood_group
      AND status = 'Available'
    ORDER BY donation_date ASC
    LIMIT 1;

    IF selected_unit IS NOT NULL THEN
        UPDATE BloodUnit
        SET status = 'Issued'
        WHERE unit_id = selected_unit;

        SELECT CONCAT('Blood Unit Issued Successfully. Unit ID: ', selected_unit) AS Message;
    ELSE
        SELECT 'No Available Blood Unit Found' AS Message;
    END IF;
END //

DELIMITER ;

CREATE VIEW low_stock_view AS
SELECT
    blood_group,
    COUNT(*) AS available_units
FROM BloodUnit
WHERE status = 'Available'
GROUP BY blood_group
HAVING COUNT(*) < 2;

CREATE VIEW expiring_soon_view AS
SELECT
    unit_id,
    blood_group,
    expiry_date,
    status
FROM BloodUnit
WHERE expiry_date <= DATE_ADD(CURDATE(), INTERVAL 7 DAY)
AND status = 'Available';

CREATE VIEW eligible_donors_view AS
SELECT
    donor_id,
    name,
    blood_group,
    next_eligible_date
FROM Donor
WHERE next_eligible_date IS NULL
   OR next_eligible_date <= CURDATE();

SELECT 'BloodLink Database Setup Completed Successfully' AS Status;