<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Select Patient | MamaMonitor</title>
  <link rel="stylesheet" href="../css/selectpatient.css" />
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script type="module" src="../js/alert.js"></script>

  <style>
    body {
      font-family: 'Segoe UI', sans-serif;
      background-color: #ffffff;
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
    .header__content h2 {
      font-size: 36px;
      color: #ff3e95;
      margin-bottom: 10px;
    }
    .header__content p {
      font-size: 16px;
      color: #333;
    }
    .patient-container {
      max-width: 800px;
      margin: 3rem auto;
      padding: 2rem;
      background: #ffffff;
      border-radius: 12px;
      box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
    }
    .patient-container h3 {
      text-align: center;
      color: #222;
      font-size: 24px;
      margin-bottom: 20px;
    }
    .patient-list {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 1rem;
      padding: 0;
      list-style: none;
    }
    .patient-card {
      background: #ffe4ec;
      border-radius: 10px;
      padding: 1rem;
      text-align: center;
      transition: transform 0.2s ease-in-out;
    }
    .patient-card:hover {
      transform: translateY(-5px);
      background: #ffd1e4;
    }
    .patient-card a {
      text-decoration: none;
      font-weight: bold;
      color: #ff3e95;
      font-size: 18px;
    }
  </style>
</head>
<body>
  <header class="header">
    <nav>
      <div class="nav__logo">
        <a href="#">
          <img src="../images/pregnantwoman1.jpg" alt="logo" class="logo-color" style="max-width: 60px;" />
        </a>
      </div>
      <ul class="nav__links" id="nav-links">
        <li><a href="../view/doctorDashboard.php">Dashboard</a></li>
        <li><a href="../view/selectPatient.php">Select Patient</a></li>
        <li><a href="../register/login.php">Logout</a></li>
      </ul>
    </nav>
    <div class="header__content">
      <h1>Select a Patient</h1>
      <p>View all your patients here and access their real-time health data and reports.</p>
    </div>
  </header>

  <section class="patient-container">
    <h3>Patient List</h3>
    <ul class="patient-list" id="list"></ul>
  </section>

  <script type="module">
    import { initializeApp, getApps, getApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
    import { getDatabase, ref, get, child } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";

    const firebaseConfig = {
      apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
      authDomain: "mamamonitor-bc144.firebaseapp.com",
      databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
      projectId: "mamamonitor-bc144",
      storageBucket: "mamamonitor-bc144.appspot.com", // ✅ fixed
      messagingSenderId: "1053977602705",
      appId: "1:1053977602705:web:e86144988a193e5633ad30",
      measurementId: "G-C3PWJBLXRQ"
    };

    const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
    const db = getDatabase(app);
    const dbRef = ref(db);

    get(child(dbRef, "users"))
      .then((snapshot) => {
        if (snapshot.exists()) {
          const data = snapshot.val();
          const patients = [];

          for (const uid in data) {
            if (data[uid].role === "patient") {
              patients.push({ name: data[uid].name, uid: uid });
            }
          }

          patients.sort((a, b) => a.name.localeCompare(b.name));

          const list = document.getElementById("list");
          patients.forEach((patient) => {
            const li = document.createElement("li");
            li.classList.add("patient-card");
            li.innerHTML = `<a href="../view/liveData.php?uid=${patient.uid}&name=${encodeURIComponent(patient.name)}">${patient.name}</a>`;
            list.appendChild(li);
          });
        } else {
          document.getElementById("list").innerHTML = "<p>No patients found.</p>";
        }
      })
      .catch((error) => {
        console.error("Error fetching patient data:", error);
      });
  </script>
</body>
</html>
