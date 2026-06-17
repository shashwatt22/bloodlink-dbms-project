const express = require("express");
const cors = require("cors");
const db = require("./db");

const app = express();

app.use(cors());
app.use(express.json());
app.use(express.urlencoded({ extended: true }));

// =====================================
// GET ROUTES (DATA RETRIEVAL)
// =====================================

// Get All Donors
app.get("/api/donors", (req, res) => {
    const sql = "SELECT * FROM Donor ORDER BY donor_id DESC";
    db.query(sql, (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(result);
    });
});

// Get Blood Inventory
app.get("/api/inventory", (req, res) => {
    const sql = "SELECT * FROM BloodUnit ORDER BY expiry_date ASC";
    db.query(sql, (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(result);
    });
});

// Get Eligible Donors View
app.get("/api/eligible-donors", (req, res) => {
    const sql = "SELECT * FROM eligible_donors_view";
    db.query(sql, (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(result);
    });
});

// Get Low Stock View
app.get("/api/low-stock", (req, res) => {
    const sql = "SELECT * FROM low_stock_view";
    db.query(sql, (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(result);
    });
});

// Get Expiring Soon View
app.get("/api/expiring-soon", (req, res) => {
    const sql = "SELECT * FROM expiring_soon_view";
    db.query(sql, (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(result);
    });
});

// Get Dashboard Statistics
app.get("/api/stats", (req, res) => {
    const queries = {
        totalDonors: "SELECT COUNT(*) AS count FROM Donor",
        availableUnits: "SELECT COUNT(*) AS count FROM BloodUnit WHERE status = 'Available'",
        eligibleDonors: "SELECT COUNT(*) AS count FROM eligible_donors_view",
        emergencyRequests: "SELECT COUNT(*) AS count FROM Request WHERE request_type = 'Emergency'",
        totalHospitals: "SELECT COUNT(*) AS count FROM Hospital"
    };

    let stats = {};
    let completed = 0;
    const keys = Object.keys(queries);

    keys.forEach(key => {
        db.query(queries[key], (err, result) => {
            if (err) return res.status(500).json({ error: err.message });
            stats[key] = result[0].count;
            completed++;
            if (completed === keys.length) {
                res.json(stats);
            }
        });
    });
});

// Get Recent Requests
app.get("/api/recent-requests", (req, res) => {
    const sql = `
        SELECT r.request_id, h.hospital_name, r.blood_group, r.quantity, r.request_type, r.request_date, r.status
        FROM Request r
        JOIN Hospital h ON r.hospital_id = h.hospital_id
        ORDER BY r.request_date DESC LIMIT 10
    `;
    db.query(sql, (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json(result);
    });
});

// =====================================
// POST ROUTES (DATA INSERTION & PROCEDURES)
// =====================================

// Register New Donor
app.post("/api/donors", (req, res) => {
    const { name, age, gender, blood_group, phone, email } = req.body;
    const sql = "INSERT INTO Donor (name, age, gender, blood_group, phone, email) VALUES (?, ?, ?, ?, ?, ?)";
    db.query(sql, [name, age, gender, blood_group, phone, email], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: "Donor registered successfully!", id: result.insertId });
    });
});

// Submit Hospital Request
app.post("/api/requests", (req, res) => {
    const { hospital_id, blood_group, quantity, request_type } = req.body;
    const sql = "INSERT INTO Request (hospital_id, blood_group, quantity, request_type, request_date) VALUES (?, ?, ?, ?, CURDATE())";
    db.query(sql, [hospital_id, blood_group, quantity, request_type], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        res.json({ message: "Blood request submitted successfully!" });
    });
});

// Record Blood Donation
app.post("/api/donations", (req, res) => {
    const { donor_id, blood_group, donation_date } = req.body;
    
    // First, check if donor exists and eligibility is met
    // (The MySQL trigger will handle eligibility checking and throw an error if not eligible)
    
    // Insert into BloodUnit
    const insertUnitSql = "INSERT INTO BloodUnit (blood_group, donation_date, expiry_date, status) VALUES (?, ?, DATE_ADD(?, INTERVAL 42 DAY), 'Available')";
    
    db.query(insertUnitSql, [blood_group, donation_date, donation_date], (err, unitResult) => {
        if (err) {
            // Trigger or constraint failed
            return res.status(400).json({ error: err.message });
        }
        
        const unit_id = unitResult.insertId;
        
        // Insert into Donation mapping table
        const insertDonationSql = "INSERT INTO Donation (donor_id, unit_id) VALUES (?, ?)";
        db.query(insertDonationSql, [donor_id, unit_id], (err, donationResult) => {
            if (err) return res.status(400).json({ error: err.message });
            res.json({ message: "Donation recorded and blood unit created successfully!" });
        });
    });
});

// Issue Blood via Stored Procedure
app.post("/api/issue-blood", (req, res) => {
    const { blood_group } = req.body;
    const sql = "CALL Issue_Blood(?)";
    
    db.query(sql, [blood_group], (err, result) => {
        if (err) return res.status(500).json({ error: err.message });
        // Stored procedure returns a message in the first result set
        res.json({ message: result[0][0].Message });
    });
});

app.listen(3001, "127.0.0.1", () => {
    console.log("Server running on port 3001");
});