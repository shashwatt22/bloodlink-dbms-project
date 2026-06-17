-- MySQL dump 10.13  Distrib 8.0.46, for macos15 (arm64)
--
-- Host: localhost    Database: bloodlink
-- ------------------------------------------------------
-- Server version	8.0.41

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!50503 SET NAMES utf8 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `BloodCompatibility`
--

DROP TABLE IF EXISTS `BloodCompatibility`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `BloodCompatibility` (
  `donor_group` varchar(5) NOT NULL,
  `receiver_group` varchar(5) NOT NULL,
  PRIMARY KEY (`donor_group`,`receiver_group`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BloodCompatibility`
--

LOCK TABLES `BloodCompatibility` WRITE;
/*!40000 ALTER TABLE `BloodCompatibility` DISABLE KEYS */;
INSERT INTO `BloodCompatibility` VALUES ('A-','A-'),('A-','A+'),('A-','AB-'),('A-','AB+'),('A+','A+'),('A+','AB+'),('AB-','AB-'),('AB-','AB+'),('AB+','AB+'),('B-','AB-'),('B-','AB+'),('B-','B-'),('B-','B+'),('B+','AB+'),('B+','B+'),('O-','A-'),('O-','A+'),('O-','AB-'),('O-','AB+'),('O-','B-'),('O-','B+'),('O-','O-'),('O-','O+'),('O+','A+'),('O+','AB+'),('O+','B+'),('O+','O+');
/*!40000 ALTER TABLE `BloodCompatibility` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `BloodUnit`
--

DROP TABLE IF EXISTS `BloodUnit`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `BloodUnit` (
  `unit_id` int NOT NULL AUTO_INCREMENT,
  `blood_group` varchar(5) NOT NULL,
  `donation_date` date NOT NULL,
  `expiry_date` date NOT NULL,
  `status` varchar(20) DEFAULT 'Available',
  PRIMARY KEY (`unit_id`),
  CONSTRAINT `bloodunit_chk_1` CHECK ((`status` in (_utf8mb4'Available',_utf8mb4'Issued',_utf8mb4'Expired')))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `BloodUnit`
--

LOCK TABLES `BloodUnit` WRITE;
/*!40000 ALTER TABLE `BloodUnit` DISABLE KEYS */;
INSERT INTO `BloodUnit` VALUES (1,'B+','2026-04-28','2026-06-09','Available'),(2,'O+','2026-04-01','2026-05-13','Issued'),(3,'A+','2026-04-05','2026-05-17','Available'),(4,'B+','2026-04-07','2026-05-19','Available');
/*!40000 ALTER TABLE `BloodUnit` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `Donation`
--

DROP TABLE IF EXISTS `Donation`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Donation` (
  `donation_id` int NOT NULL AUTO_INCREMENT,
  `donor_id` int NOT NULL,
  `unit_id` int NOT NULL,
  PRIMARY KEY (`donation_id`),
  UNIQUE KEY `unit_id` (`unit_id`),
  KEY `donor_id` (`donor_id`),
  CONSTRAINT `donation_ibfk_1` FOREIGN KEY (`donor_id`) REFERENCES `Donor` (`donor_id`),
  CONSTRAINT `donation_ibfk_2` FOREIGN KEY (`unit_id`) REFERENCES `BloodUnit` (`unit_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Donation`
--

LOCK TABLES `Donation` WRITE;
/*!40000 ALTER TABLE `Donation` DISABLE KEYS */;
/*!40000 ALTER TABLE `Donation` ENABLE KEYS */;
UNLOCK TABLES;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `check_donor_eligibility` BEFORE INSERT ON `donation` FOR EACH ROW BEGIN
    DECLARE eligible_date DATE;

    SELECT next_eligible_date
    INTO eligible_date
    FROM Donor
    WHERE donor_id = NEW.donor_id;

    IF eligible_date IS NOT NULL AND CURDATE() < eligible_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Donor is not yet eligible to donate again';
    END IF;
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
/*!50003 CREATE*/ /*!50017 DEFINER=`root`@`localhost`*/ /*!50003 TRIGGER `update_next_eligibility` AFTER INSERT ON `donation` FOR EACH ROW BEGIN
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
END */;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Table structure for table `Donor`
--

DROP TABLE IF EXISTS `Donor`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Donor` (
  `donor_id` int NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `age` int NOT NULL,
  `gender` varchar(10) NOT NULL,
  `blood_group` varchar(5) NOT NULL,
  `phone` varchar(15) NOT NULL,
  `email` varchar(100) DEFAULT NULL,
  `last_donation_date` date DEFAULT NULL,
  `next_eligible_date` date DEFAULT NULL,
  PRIMARY KEY (`donor_id`),
  UNIQUE KEY `phone` (`phone`),
  UNIQUE KEY `email` (`email`),
  CONSTRAINT `donor_chk_1` CHECK ((`age` >= 18))
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Donor`
--

LOCK TABLES `Donor` WRITE;
/*!40000 ALTER TABLE `Donor` DISABLE KEYS */;
INSERT INTO `Donor` VALUES (1,'Rahul Sharma',24,'Male','O+','9991110001','rahul@gmail.com','2026-02-01','2026-03-29'),(2,'Priya Verma',22,'Female','A+','9991110002','priya@gmail.com','2026-01-15','2026-03-11'),(3,'Aman Singh',25,'Male','B+','9991110003','aman@gmail.com','2026-03-10','2026-05-05'),(4,'Sneha Kapoor',23,'Female','AB+','9991110004','sneha@gmail.com',NULL,NULL);
/*!40000 ALTER TABLE `Donor` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `eligible_donors_view`
--

DROP TABLE IF EXISTS `eligible_donors_view`;
/*!50001 DROP VIEW IF EXISTS `eligible_donors_view`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `eligible_donors_view` AS SELECT 
 1 AS `donor_id`,
 1 AS `name`,
 1 AS `blood_group`,
 1 AS `next_eligible_date`*/;
SET character_set_client = @saved_cs_client;

--
-- Temporary view structure for view `expiring_soon_view`
--

DROP TABLE IF EXISTS `expiring_soon_view`;
/*!50001 DROP VIEW IF EXISTS `expiring_soon_view`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `expiring_soon_view` AS SELECT 
 1 AS `unit_id`,
 1 AS `blood_group`,
 1 AS `expiry_date`,
 1 AS `status`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Hospital`
--

DROP TABLE IF EXISTS `Hospital`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Hospital` (
  `hospital_id` int NOT NULL AUTO_INCREMENT,
  `hospital_name` varchar(100) NOT NULL,
  `location` varchar(150) NOT NULL,
  `phone` varchar(15) NOT NULL,
  PRIMARY KEY (`hospital_id`),
  UNIQUE KEY `phone` (`phone`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Hospital`
--

LOCK TABLES `Hospital` WRITE;
/*!40000 ALTER TABLE `Hospital` DISABLE KEYS */;
INSERT INTO `Hospital` VALUES (1,'Apollo Hospital','Delhi','9876543210'),(2,'Fortis Hospital','Chandigarh','9876543211'),(3,'Max Hospital','Mumbai','9876543212');
/*!40000 ALTER TABLE `Hospital` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Temporary view structure for view `low_stock_view`
--

DROP TABLE IF EXISTS `low_stock_view`;
/*!50001 DROP VIEW IF EXISTS `low_stock_view`*/;
SET @saved_cs_client     = @@character_set_client;
/*!50503 SET character_set_client = utf8mb4 */;
/*!50001 CREATE VIEW `low_stock_view` AS SELECT 
 1 AS `blood_group`,
 1 AS `available_units`*/;
SET character_set_client = @saved_cs_client;

--
-- Table structure for table `Request`
--

DROP TABLE IF EXISTS `Request`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!50503 SET character_set_client = utf8mb4 */;
CREATE TABLE `Request` (
  `request_id` int NOT NULL AUTO_INCREMENT,
  `hospital_id` int NOT NULL,
  `blood_group` varchar(5) NOT NULL,
  `quantity` int NOT NULL,
  `request_type` varchar(20) NOT NULL,
  `request_date` date NOT NULL,
  `status` varchar(20) DEFAULT 'Pending',
  PRIMARY KEY (`request_id`),
  KEY `hospital_id` (`hospital_id`),
  CONSTRAINT `request_ibfk_1` FOREIGN KEY (`hospital_id`) REFERENCES `Hospital` (`hospital_id`),
  CONSTRAINT `request_chk_1` CHECK ((`quantity` > 0)),
  CONSTRAINT `request_chk_2` CHECK ((`request_type` in (_utf8mb4'Normal',_utf8mb4'Emergency')))
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `Request`
--

LOCK TABLES `Request` WRITE;
/*!40000 ALTER TABLE `Request` DISABLE KEYS */;
/*!40000 ALTER TABLE `Request` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'bloodlink'
--
/*!50003 DROP PROCEDURE IF EXISTS `Issue_Blood` */;
/*!50003 SET @saved_cs_client      = @@character_set_client */ ;
/*!50003 SET @saved_cs_results     = @@character_set_results */ ;
/*!50003 SET @saved_col_connection = @@collation_connection */ ;
/*!50003 SET character_set_client  = utf8mb4 */ ;
/*!50003 SET character_set_results = utf8mb4 */ ;
/*!50003 SET collation_connection  = utf8mb4_0900_ai_ci */ ;
/*!50003 SET @saved_sql_mode       = @@sql_mode */ ;
/*!50003 SET sql_mode              = 'ONLY_FULL_GROUP_BY,STRICT_TRANS_TABLES,NO_ZERO_IN_DATE,NO_ZERO_DATE,ERROR_FOR_DIVISION_BY_ZERO,NO_ENGINE_SUBSTITUTION' */ ;
DELIMITER ;;
CREATE DEFINER=`root`@`localhost` PROCEDURE `Issue_Blood`(
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
END ;;
DELIMITER ;
/*!50003 SET sql_mode              = @saved_sql_mode */ ;
/*!50003 SET character_set_client  = @saved_cs_client */ ;
/*!50003 SET character_set_results = @saved_cs_results */ ;
/*!50003 SET collation_connection  = @saved_col_connection */ ;

--
-- Final view structure for view `eligible_donors_view`
--

/*!50001 DROP VIEW IF EXISTS `eligible_donors_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `eligible_donors_view` AS select `donor`.`donor_id` AS `donor_id`,`donor`.`name` AS `name`,`donor`.`blood_group` AS `blood_group`,`donor`.`next_eligible_date` AS `next_eligible_date` from `donor` where ((`donor`.`next_eligible_date` is null) or (`donor`.`next_eligible_date` <= curdate())) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `expiring_soon_view`
--

/*!50001 DROP VIEW IF EXISTS `expiring_soon_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `expiring_soon_view` AS select `bloodunit`.`unit_id` AS `unit_id`,`bloodunit`.`blood_group` AS `blood_group`,`bloodunit`.`expiry_date` AS `expiry_date`,`bloodunit`.`status` AS `status` from `bloodunit` where ((`bloodunit`.`expiry_date` <= (curdate() + interval 7 day)) and (`bloodunit`.`status` = 'Available')) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;

--
-- Final view structure for view `low_stock_view`
--

/*!50001 DROP VIEW IF EXISTS `low_stock_view`*/;
/*!50001 SET @saved_cs_client          = @@character_set_client */;
/*!50001 SET @saved_cs_results         = @@character_set_results */;
/*!50001 SET @saved_col_connection     = @@collation_connection */;
/*!50001 SET character_set_client      = utf8mb4 */;
/*!50001 SET character_set_results     = utf8mb4 */;
/*!50001 SET collation_connection      = utf8mb4_0900_ai_ci */;
/*!50001 CREATE ALGORITHM=UNDEFINED */
/*!50013 DEFINER=`root`@`localhost` SQL SECURITY DEFINER */
/*!50001 VIEW `low_stock_view` AS select `bloodunit`.`blood_group` AS `blood_group`,count(0) AS `available_units` from `bloodunit` where (`bloodunit`.`status` = 'Available') group by `bloodunit`.`blood_group` having (count(0) < 2) */;
/*!50001 SET character_set_client      = @saved_cs_client */;
/*!50001 SET character_set_results     = @saved_cs_results */;
/*!50001 SET collation_connection      = @saved_col_connection */;
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-04-28 22:18:57
