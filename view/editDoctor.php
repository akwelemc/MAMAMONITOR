<?php
  $uid = $_GET['uid'] ?? '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Edit Profile | MamaMonitor</title>
  <link rel="stylesheet" href="../css/selectpatient.css" />
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-database-compat.js"></script>
  <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-storage-compat.js"></script>
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
      padding: 2rem;
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
      margin-bottom: 1rem;
    }

    .profile-details {
      text-align: left;
      margin: 0 auto;
      max-width: 400px;
    }

    .profile-field {
      margin-bottom: 15px;
    }

    .field-label {
      font-weight: bold;
      color: #ff3e95;
      display: block;
      margin-bottom: 5px;
    }

    .input-field {
      width: 100%;
      padding: 10px;
      border: 1px solid #ccc;
      border-radius: 10px;
      font-size: 14px;
    }

    .save-btn {
      margin-top: 1.5rem;
      display: inline-block;
      padding: 10px 20px;
      background-color: #ff3e95;
      color: white;
      border: none;
      border-radius: 8px;
      font-size: 16px;
      cursor: pointer;
    }

    .save-btn:hover {
      background-color: #e53787;
    }
  </style>
</head>
<body>
  <header class="header">
    <nav>
      <div class="nav__logo">
        <a href="#"><img src="../images/pregnantwoman1.jpg" alt="logo" style="max-width: 60px;" /></a>
      </div>
      <ul class="nav__links">
        <li><a href="../view/doctorDashboard.php">Dashboard</a></li>
        <li><a href="../view/selectPatient.php">Select Patient</a></li>
        <li><a href="../register/login.php">Logout</a></li>
      </ul>
    </nav>
    <div class="header__content">
      <h1>Edit Profile</h1>
      <p>Update your details and profile picture.</p>
    </div>
  </header>

  <section class="profile-container">
    <img id="profile-pic-preview" class="profile-pic" src="../images/blank_profile.png" alt="Profile Picture" />

    <div class="profile-field">
      <label class="field-label">Change Profile Picture:</label>
      <input type="file" id="profile-pic-input" accept="image/*" />
    </div>

    <div class="profile-details">
      <div class="profile-field">
        <label class="field-label">Name:</label>
        <input type="text" id="name" class="input-field" />
      </div>
      <div class="profile-field">
        <label class="field-label">Gender:</label>
        <input type="text" id="gender" class="input-field" />
      </div>
      <div class="profile-field">
        <label class="field-label">Phone:</label>
        <input type="text" id="phone" class="input-field" />
      </div>
      <div class="profile-field">
        <label class="field-label">Institution:</label>
        <input type="text" id="institution" class="input-field" />
      </div>
      <div class="profile-field">
        <label class="field-label">Specialty:</label>
        <input type="text" id="specialty" class="input-field" />
      </div>
      <div class="profile-field">
        <label class="field-label">Email:</label>
        <input type="email" id="email" class="input-field" />
      </div>
    </div>

    <button class="save-btn" onclick="saveChanges()">Save Changes</button>
  </section>

  <script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
    import { getDatabase, ref, get, update } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";
    import { getStorage, ref as storageRef, uploadBytes, getDownloadURL } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-storage.js";

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
    const storage = getStorage(app);
    const uid = "<?= $uid ?>";

    const preview = document.getElementById("profile-pic-preview");
    const input = document.getElementById("profile-pic-input");

    input.addEventListener("change", () => {
      const file = input.files[0];
      if (file) {
        preview.src = URL.createObjectURL(file);
      }
    });

    window.onload = async () => {
      const snapshot = await get(ref(db, "users/" + uid));
      if (snapshot.exists()) {
        const doc = snapshot.val();
        document.getElementById("name").value = doc.name || "";
        document.getElementById("gender").value = doc.gender || "";
        document.getElementById("phone").value = doc.phone || "";
        document.getElementById("institution").value = doc.institution || "";
        document.getElementById("specialty").value = doc.specialty || "";
        document.getElementById("email").value = doc.email || "";
        preview.src = doc.profilePic || "../images/blank_profile.png";
      }
    };

    window.saveChanges = async () => {
      const updates = {
        name: document.getElementById("name").value.trim(),
        gender: document.getElementById("gender").value.trim(),
        phone: document.getElementById("phone").value.trim(),
        institution: document.getElementById("institution").value.trim(),
        specialty: document.getElementById("specialty").value.trim(),
        email: document.getElementById("email").value.trim(),
      };

      const file = input.files[0];
      if (file) {
        const fileExt = file.name.split('.').pop();
        const storagePath = storageRef(storage, `users/${uid}/profileImage.${fileExt}`);
        await uploadBytes(storagePath, file);
        const url = await getDownloadURL(storagePath);
        updates.profilePic = url;
      }

      await update(ref(db, "users/" + uid), updates);

      Swal.fire({
        icon: 'success',
        title: 'Profile Updated',
        text: 'Changes saved!',
        showConfirmButton: false,
        timer: 1500
      }).then(() => {
        window.location.href = `doctorProfile.php?uid=${uid}`;
      });
    };
  </script>
</body>
</html>
