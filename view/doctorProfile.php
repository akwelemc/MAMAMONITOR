<?php
  $uid = $_GET['uid'] ?? '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Profile Page | MamaMonitor</title>
  <link rel="stylesheet" href="../css/selectpatient.css" />
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-database-compat.js"></script>
  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background-color: #fff;
      margin: 0;
      padding: 0;
    }

    .header__content {
      text-align: center;
      padding: 2rem;
    }

    .header__content h1 {
      font-size: 48px;
      margin: 0;
    }

    .header__content p {
      font-size: 16px;
      color: #333;
    }

    .profile-container {
      max-width: 600px;
      margin: 2rem auto;
      padding: 1.5rem;
      background: #ffffff;
      border-radius: 12px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
      text-align: center;
    }

    .profile-pic {
      width: 120px;
      height: 120px;
      border-radius: 50%;
      object-fit: cover;
      border: 4px solid #ff3e95;
      margin-bottom: 1.5rem;
    }

    .profile-details {
      text-align: left;
      margin: 0 auto;
      max-width: 400px;
    }

    .profile-field {
      font-size: 16px;
      margin-bottom: 10px;
    }

    .field-label {
      font-weight: bold;
      color: #ff3e95;
    }

    .edit-btn {
      margin-top: 1.5rem;
      display: inline-block;
      padding: 10px 20px;
      background-color: #ff3e95;
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      cursor: pointer;
      text-decoration: none;
    }

    .edit-btn:hover {
      background-color: #e53787;
    }
  </style>
</head>

<body>
  <header class="header">
    <nav>
      <div class="nav__logo">
        <a href="#"><img src="../images/pregnantwoman1.jpg" alt="logo" class="logo-color" style="max-width: 60px;" /></a>
      </div>
      <ul class="nav__links">
        <li><a href="../view/doctorDashboard.php">Dashboard</a></li>
        <li><a href="../view/selectPatient.php">Select Patient</a></li>
        <li><a href="../register/login.php">Logout</a></li>
      </ul>
    </nav>
    <div class="header__content">
      <h1>Profile Page</h1>
      <p>Here is your account profile and settings information.</p>
    </div>
  </header>

  <section class="profile-container">
    <img id="profile-pic" class="profile-pic" src="../images/blank_profile.png" alt="Doctor Profile Picture" />

    <div class="profile-details">
      <div class="profile-field"><span class="field-label">Name:</span> <span id="name">Loading...</span></div>
      <div class="profile-field"><span class="field-label">Gender:</span> <span id="gender">Loading...</span></div>
      <div class="profile-field"><span class="field-label">Phone:</span> <span id="phone">Loading...</span></div>
      <div class="profile-field"><span class="field-label">Institution:</span> <span id="institution">Loading...</span></div>
      <div class="profile-field"><span class="field-label">Specialty:</span> <span id="specialty">Loading...</span></div>
      <div class="profile-field"><span class="field-label">Email:</span> <span id="email">Loading...</span></div>
      <div class="profile-field"><span class="field-label">Password:</span> ********</div>
    </div>

    <a class="edit-btn" href="../view/editDoctor.php?uid=<?= $uid ?>">Edit Profile</a>
  </section>

  <script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
    import { getDatabase, ref, get } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";

    const firebaseConfig = {
      apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
      authDomain: "mamamonitor-bc144.firebaseapp.com",
      databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
      projectId: "mamamonitor-bc144",
      storageBucket: "mamamonitor-bc144.appspot.com",
      messagingSenderId: "1053977602705",
      appId: "1:1053977602705:web:e86144988a193e5633ad30"
    };

    const app = initializeApp(firebaseConfig);
    const db = getDatabase(app);
    const uid = "<?= $uid ?>";

    window.onload = async () => {
      const fallback = "Not set";

      if (!uid) {
        console.warn("No UID in URL.");
        document.querySelectorAll(".profile-details span").forEach(el => {
          if (el.id !== "profile-pic") el.textContent = fallback;
        });
        return;
      }

      try {
        const snapshot = await get(ref(db, "users/" + uid));
        if (snapshot.exists()) {
          const doc = snapshot.val();
          const getVal = (key) => doc[key]?.trim() || fallback;

          document.getElementById("name").textContent = getVal("name");
          document.getElementById("gender").textContent = getVal("gender");
          document.getElementById("phone").textContent = getVal("phone");
          document.getElementById("institution").textContent = getVal("institution");
          document.getElementById("specialty").textContent = getVal("specialty");
          document.getElementById("email").textContent = getVal("email");
          document.getElementById("profile-pic").src = doc.profilePic || "../images/blank_profile.png";
        } else {
          console.warn("UID not found in database.");
          document.querySelectorAll(".profile-details span").forEach(el => {
            if (el.id !== "profile-pic") el.textContent = fallback;
          });
        }
      } catch (err) {
        console.error("Firebase error:", err);
      }
    };
  </script>
</body>
</html>
