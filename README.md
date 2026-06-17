# BloodLink DBMS

A Blood Bank Management System developed using MySQL, Node.js, Express.js, HTML, CSS and JavaScript.

## Features
- Donor Management
- Blood Inventory Tracking
- Hospital Request Handling
- SQL Views
- Triggers
- Stored Procedures
- Blood Compatibility Management


---

## TECH STACK USED

Database:

* MySQL

Backend:

* Node.js
* Express.js

Frontend:

* HTML
* CSS
* JavaScript

---

## MAIN FEATURES

* Donor Management
* Blood Inventory Tracking
* Blood Compatibility Management
* Eligible Donor Detection
* Blood Issue System
* Hospital Request Handling
* SQL Triggers
* Stored Procedures
* SQL Views
* Constraints and Relationships

---

## DATABASE FEATURES

1. Trigger: Donor Eligibility Check
   Prevents a donor from donating again before completing the required recovery period.

2. Trigger: Auto Update Eligibility
   Automatically updates last donation date and next eligible donation date.

3. Stored Procedure: Issue_Blood()
   Automatically issues blood and updates blood unit status.

4. Views:

* Low_Stock_View
* Expiring_Soon_View
* Eligible_Donors_View

---

## HOW TO RUN THE PROJECT

Step 1:
Open MySQL Workbench

Step 2:
Import the database file:

database/bloodlink.sql

using:
Server → Data Import

Step 3:
Open terminal inside backend folder

Step 4:
Install dependencies using:

npm install

Step 5:
Open:

backend/db.js

and update MySQL credentials according to your local system:

Example:

user: "root"
password: "your_mysql_password"

Step 6:
Start backend server using:

node server.js

Step 7:
Backend will run on:

http://127.0.0.1:3001

Step 8:
Open:

frontend/index.html

in browser

Step 9:
Navigate the dashboard using the sidebar to:

* View dynamic Dashboard Statistics
* Load Donors & Eligible Donors View
* Load Full Inventory & Low Stock Alerts
* Submit Hospital Requests & Admin Issue Forms

to interact with live project data and execute SQL views and procedures.

---

## IMPORTANT NOTE

Please update MySQL username and password inside:

backend/db.js

before running the project.

Do not use the submitted placeholder password directly.

---

## PROJECT STRUCTURE

BloodLink/
│
├── backend/
│   ├── db.js
│   ├── server.js
│   └── package.json
│
├── frontend/
│   ├── index.html
│   ├── style.css
│   └── script.js
│
├── database/
│   └── bloodlink.sql
│
└── README.txt

---

## SUBMITTED FOR

DBMS Course Project
BloodLink – Blood Bank Management System
