// ==========================================
// MOCK DATABASE & STATE (For Demonstration)
// ==========================================
const mockDB = {
    donors: [
        { donor_id: 1, name: 'Rahul Sharma', age: 24, gender: 'Male', blood_group: 'O+', phone: '9991110001', email: 'rahul@gmail.com', last_donation_date: '2026-02-01', next_eligible_date: '2026-03-29' },
        { donor_id: 2, name: 'Priya Verma', age: 22, gender: 'Female', blood_group: 'A+', phone: '9991110002', email: 'priya@gmail.com', last_donation_date: '2026-01-15', next_eligible_date: '2026-03-11' },
        { donor_id: 3, name: 'Aman Singh', age: 25, gender: 'Male', blood_group: 'B+', phone: '9991110003', email: 'aman@gmail.com', last_donation_date: '2026-03-10', next_eligible_date: '2026-05-05' },
        { donor_id: 4, name: 'Sneha Kapoor', age: 23, gender: 'Female', blood_group: 'AB+', phone: '9991110004', email: 'sneha@gmail.com', last_donation_date: null, next_eligible_date: null }
    ],
    hospitals: [
        { hospital_id: 1, hospital_name: 'Apollo Hospital', location: 'Delhi', phone: '9876543210' },
        { hospital_id: 2, hospital_name: 'Fortis Hospital', location: 'Chandigarh', phone: '9876543211' },
        { hospital_id: 3, hospital_name: 'Max Hospital', location: 'Mumbai', phone: '9876543212' }
    ],
    bloodUnits: [
        { unit_id: 1, blood_group: 'B+', donation_date: '2026-04-28', expiry_date: '2026-06-09', status: 'Available' },
        { unit_id: 2, blood_group: 'O+', donation_date: '2026-04-01', expiry_date: '2026-05-13', status: 'Issued' },
        { unit_id: 3, blood_group: 'A+', donation_date: '2026-04-05', expiry_date: '2026-05-17', status: 'Available' },
        { unit_id: 4, blood_group: 'B+', donation_date: '2026-04-07', expiry_date: '2026-05-19', status: 'Available' }
    ],
    requests: [],
    // Helpers to generate IDs
    nextDonorId: 5,
    nextUnitId: 5,
    nextRequestId: 1
};

// Set today's date as default for donation form
document.getElementById('donation-date-input').valueAsDate = new Date();

// ==========================================
// UI & ROUTING LOGIC
// ==========================================
document.addEventListener('DOMContentLoaded', () => {
    // Initial data load
    fetchDashboardStats();
    fetchRecentRequests();

    // Navigation Logic
    const navLinks = document.querySelectorAll('.nav-link');
    const viewSections = document.querySelectorAll('.view-section');
    const pageTitle = document.getElementById('page-title');

    navLinks.forEach(link => {
        link.addEventListener('click', (e) => {
            e.preventDefault();
            
            // Remove active classes
            navLinks.forEach(l => l.classList.remove('active'));
            viewSections.forEach(v => v.classList.remove('active'));
            
            // Add active class to clicked link and target section
            link.classList.add('active');
            const targetId = link.getAttribute('data-target');
            document.getElementById(targetId).classList.add('active');
            
            // Update title
            pageTitle.innerHTML = link.innerHTML;

            // Load specific data based on view
            if(targetId === 'donors-view') {
                fetchDonors();
                fetchEligibleDonors();
            } else if(targetId === 'inventory-view') {
                fetchInventory();
                fetchLowStock();
                fetchExpiringSoon();
            } else if(targetId === 'dashboard-view') {
                fetchDashboardStats();
                fetchRecentRequests();
            }
        });
    });
});

// Helper for displaying alerts
function showAlert(message, type = 'success') {
    const alertBox = document.getElementById('alertBox');
    alertBox.textContent = message;
    alertBox.className = `alert alert-${type}`;
    alertBox.style.display = 'block';
    
    setTimeout(() => {
        alertBox.style.display = 'none';
    }, 5000);
}

// Helper for status badges
function getStatusBadge(status) {
    if (status === 'Available') return `<span class="badge badge-success">${status}</span>`;
    if (status === 'Issued' || status === 'Fulfilled') return `<span class="badge badge-primary">${status}</span>`;
    if (status === 'Expired' || status === 'Emergency') return `<span class="badge badge-danger">${status}</span>`;
    if (status === 'Pending' || status === 'Normal') return `<span class="badge badge-warning">${status}</span>`;
    return `<span class="badge">${status}</span>`;
}

function formatDate(isoString) {
    if(!isoString) return 'N/A';
    const date = new Date(isoString);
    return date.toLocaleDateString('en-GB'); // DD/MM/YYYY
}

// ==========================================
// DATA FETCHING (LOCAL MOCK)
// ==========================================

function fetchDashboardStats() {
    const totalDonors = mockDB.donors.length;
    const availableUnits = mockDB.bloodUnits.filter(u => u.status === 'Available').length;
    
    const today = new Date();
    today.setHours(0,0,0,0);
    const eligibleDonors = mockDB.donors.filter(d => {
        if (!d.next_eligible_date) return true;
        const eligibleDate = new Date(d.next_eligible_date);
        return today >= eligibleDate;
    }).length;

    const emergencyRequests = mockDB.requests.filter(r => r.request_type === 'Emergency' && r.status === 'Pending').length;

    document.getElementById("stat-total-donors").innerText = totalDonors;
    document.getElementById("stat-available-units").innerText = availableUnits;
    document.getElementById("stat-eligible-donors").innerText = eligibleDonors;
    document.getElementById("stat-emergency-requests").innerText = emergencyRequests;
}

function fetchRecentRequests() {
    const tbody = document.getElementById("recent-requests-table");
    tbody.innerHTML = "";

    if (mockDB.requests.length === 0) {
        tbody.innerHTML = "<tr><td colspan='8'>No recent requests found.</td></tr>";
        return;
    }

    mockDB.requests.forEach(req => {
        let actionBtn = "";
        if (req.status === 'Pending') {
            actionBtn = `<button class="btn btn-sm btn-primary" onclick="fulfillRequest(${req.request_id})">Fulfill</button>`;
        }
        
        tbody.innerHTML += `
            <tr>
                <td>#REQ-${req.request_id}</td>
                <td><strong>${req.hospital_name}</strong></td>
                <td><span class="badge badge-danger">${req.blood_group}</span></td>
                <td>${req.quantity} Units</td>
                <td>${getStatusBadge(req.request_type)}</td>
                <td>${formatDate(req.request_date)}</td>
                <td>${getStatusBadge(req.status)}</td>
                <td>${actionBtn}</td>
            </tr>
        `;
    });
}

function fetchDonors() {
    const tbody = document.getElementById("donors-table");
    tbody.innerHTML = "";

    mockDB.donors.forEach(donor => {
        tbody.innerHTML += `
            <tr>
                <td>#${donor.donor_id}</td>
                <td><strong>${donor.name}</strong></td>
                <td>${donor.age}</td>
                <td>${donor.gender}</td>
                <td><span class="badge badge-danger">${donor.blood_group}</span></td>
                <td>${donor.phone}</td>
                <td>${donor.email || 'N/A'}</td>
            </tr>
        `;
    });
}

function fetchEligibleDonors() {
    const tbody = document.getElementById("eligible-donors-table");
    tbody.innerHTML = "";

    const today = new Date();
    today.setHours(0,0,0,0);
    const eligible = mockDB.donors.filter(d => {
        if (!d.next_eligible_date) return true;
        const eligibleDate = new Date(d.next_eligible_date);
        return today >= eligibleDate;
    });

    eligible.forEach(donor => {
        tbody.innerHTML += `
            <tr>
                <td>#${donor.donor_id}</td>
                <td><strong>${donor.name}</strong></td>
                <td><span class="badge badge-danger">${donor.blood_group}</span></td>
                <td><span class="badge badge-success">Eligible Now</span></td>
            </tr>
        `;
    });
}

function fetchInventory() {
    const tbody = document.getElementById("inventory-table");
    tbody.innerHTML = "";

    mockDB.bloodUnits.forEach(unit => {
        tbody.innerHTML += `
            <tr>
                <td>#UNIT-${unit.unit_id}</td>
                <td><span class="badge badge-danger">${unit.blood_group}</span></td>
                <td>${formatDate(unit.donation_date)}</td>
                <td>${formatDate(unit.expiry_date)}</td>
                <td>${getStatusBadge(unit.status)}</td>
            </tr>
        `;
    });
}

function fetchLowStock() {
    const tbody = document.getElementById("low-stock-table");
    tbody.innerHTML = "";

    const counts = {};
    mockDB.bloodUnits.forEach(u => {
        if (u.status === 'Available') {
            counts[u.blood_group] = (counts[u.blood_group] || 0) + 1;
        }
    });

    let hasLowStock = false;
    
    // Check all blood groups for low stock (including 0)
    const allGroups = ['A+', 'A-', 'B+', 'B-', 'O+', 'O-', 'AB+', 'AB-'];
    allGroups.forEach(bg => {
        const count = counts[bg] || 0;
        if (count < 2) {
            hasLowStock = true;
            tbody.innerHTML += `
                <tr>
                    <td><span class="badge badge-danger">${bg}</span></td>
                    <td><span class="badge badge-warning">${count} Units Remaining</span></td>
                </tr>
            `;
        }
    });

    if (!hasLowStock) {
        tbody.innerHTML = "<tr><td colspan='2'>Stock is healthy.</td></tr>";
    }
}

function fetchExpiringSoon() {
    const tbody = document.getElementById("expiring-soon-table");
    tbody.innerHTML = "";

    const today = new Date();
    const nextWeek = new Date();
    nextWeek.setDate(today.getDate() + 7);

    const expiring = mockDB.bloodUnits.filter(u => {
        if (u.status !== 'Available') return false;
        const expDate = new Date(u.expiry_date);
        return expDate <= nextWeek;
    });

    if (expiring.length === 0) {
        tbody.innerHTML = "<tr><td colspan='3'>No units expiring soon.</td></tr>";
        return;
    }

    expiring.forEach(unit => {
        tbody.innerHTML += `
            <tr>
                <td>#UNIT-${unit.unit_id}</td>
                <td><span class="badge badge-danger">${unit.blood_group}</span></td>
                <td><span class="badge badge-warning">${formatDate(unit.expiry_date)}</span></td>
            </tr>
        `;
    });
}

// ==========================================
// FORM SUBMISSIONS (LOCAL MOCK)
// ==========================================

// Register Donor
document.getElementById('form-donor').addEventListener('submit', (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());

    data.donor_id = mockDB.nextDonorId++;
    data.last_donation_date = null;
    data.next_eligible_date = null;
    
    mockDB.donors.push(data);
    showAlert('Donor Registered Successfully (Mock)', 'success');
    e.target.reset();
    fetchDashboardStats();
    if (document.getElementById('donors-view').classList.contains('active')) {
        fetchDonors();
        fetchEligibleDonors();
    }
});

// Submit Request
document.getElementById('form-request').addEventListener('submit', (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());

    // Find hospital name
    const hospital = mockDB.hospitals.find(h => h.hospital_id == data.hospital_id);
    const hospitalName = hospital ? hospital.hospital_name : `Hospital #${data.hospital_id}`;

    data.request_id = mockDB.nextRequestId++;
    data.hospital_name = hospitalName;
    const d = new Date();
    data.request_date = d.toISOString().split('T')[0];
    data.status = 'Pending';
    
    // Add to top of requests
    mockDB.requests.unshift(data);
    
    showAlert('Request Submitted Successfully (Mock)', 'success');
    e.target.reset();
    fetchDashboardStats();
    fetchRecentRequests();
});

// Record Donation
document.getElementById('form-donation').addEventListener('submit', (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());

    const donorId = parseInt(data.donor_id);
    const donor = mockDB.donors.find(d => d.donor_id === donorId);
    
    if (!donor) {
        showAlert('Donor ID not found!', 'error');
        return;
    }

    const donationDateStr = data.donation_date;
    const donationDate = new Date(donationDateStr);
    const today = new Date();
    today.setHours(0,0,0,0);
    
    if (donor.next_eligible_date) {
        const eligibleDate = new Date(donor.next_eligible_date);
        if (donationDate < eligibleDate) {
            showAlert('Donor is not yet eligible to donate again!', 'error');
            return;
        }
    }

    // Create unit
    const expiryDate = new Date(donationDate);
    expiryDate.setDate(expiryDate.getDate() + 42); // 42 days expiry for blood

    const newUnit = {
        unit_id: mockDB.nextUnitId++,
        blood_group: data.blood_group,
        donation_date: donationDateStr,
        expiry_date: expiryDate.toISOString().split('T')[0],
        status: 'Available'
    };

    mockDB.bloodUnits.push(newUnit);

    // Update donor
    const nextEligible = new Date(donationDate);
    nextEligible.setDate(nextEligible.getDate() + 56); // 56 days

    donor.last_donation_date = donationDateStr;
    donor.next_eligible_date = nextEligible.toISOString().split('T')[0];

    showAlert('Donation Recorded Successfully (Mock)', 'success');
    e.target.reset();
    document.getElementById('donation-date-input').valueAsDate = new Date();
    fetchDashboardStats();
    
    // Update active views
    if (document.getElementById('inventory-view').classList.contains('active')) {
        fetchInventory();
        fetchLowStock();
        fetchExpiringSoon();
    }
});

// Admin Issue Blood
document.getElementById('form-issue').addEventListener('submit', (e) => {
    e.preventDefault();
    const formData = new FormData(e.target);
    const data = Object.fromEntries(formData.entries());
    
    const reqBloodGroup = data.blood_group;

    // Find available unit
    // To match stored procedure: order by donation_date ASC
    const availableUnits = mockDB.bloodUnits
        .filter(u => u.blood_group === reqBloodGroup && u.status === 'Available')
        .sort((a, b) => new Date(a.donation_date) - new Date(b.donation_date));

    if (availableUnits.length > 0) {
        const availableUnit = availableUnits[0];
        availableUnit.status = 'Issued';
        showAlert(`Blood Unit Issued Successfully. Unit ID: ${availableUnit.unit_id} (Mock)`, 'success');
        fetchDashboardStats();
        if (document.getElementById('inventory-view').classList.contains('active')) {
            fetchInventory();
            fetchLowStock();
            fetchExpiringSoon();
        }
    } else {
        showAlert('No Available Blood Unit Found for this Blood Group', 'error');
    }
});

// Fulfill Request directly from table
function fulfillRequest(requestId) {
    const request = mockDB.requests.find(r => r.request_id === requestId);
    if (!request) return;

    // Check if we have available blood
    const availableUnits = mockDB.bloodUnits
        .filter(u => u.blood_group === request.blood_group && u.status === 'Available')
        .sort((a, b) => new Date(a.donation_date) - new Date(b.donation_date));
    
    if (availableUnits.length >= request.quantity) {
        // Issue units
        for (let i = 0; i < request.quantity; i++) {
            availableUnits[i].status = 'Issued';
        }
        
        request.status = 'Fulfilled';
        showAlert(`Request #${requestId} fulfilled successfully! ${request.quantity} unit(s) issued.`, 'success');
        
        fetchDashboardStats();
        fetchRecentRequests();
    } else {
        showAlert(`Not enough ${request.blood_group} blood available to fulfill this request.`, 'error');
    }
}