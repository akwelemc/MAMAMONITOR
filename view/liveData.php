<?php   
  $uid = $_GET['uid'] ?? '';
  $name = $_GET['name'] ?? '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Live FHR MamaMonitor</title>
  <link rel="stylesheet" href="../css/homepage.css" />

  <!-- Chart.js for graph rendering -->
  <script src="https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/chartjs-plugin-annotation@1.4.0"></script>

  <!-- SweetAlert2 for alerts -->
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>

  <!-- Firebase Initialization -->
  <script type="module">
    import { initializeApp, getApps } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
    const firebaseConfig = {
      apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
      authDomain: "mamamonitor-bc144.firebaseapp.com",
      databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
      projectId: "mamamonitor-bc144",
      storageBucket: "mamamonitor-bc144.appspot.com",
      messagingSenderId: "1053977602705",
      appId: "1:1053977602705:web:e86144988a193e5633ad30"
    };
    if (getApps().length === 0) {
      initializeApp(firebaseConfig);
    }
  </script>

  <!-- Custom Scripts -->
  <script type="module" src="../js/alert.js" defer></script>
  <script type="module" src="../js/live-kfhr.js" defer></script>

  <!-- Inline Custom Styles -->
  <style>
    body {
      margin: 0;
      font-family: 'Poppins', sans-serif;
      background-color: #fff;
    }

    .header {
      background-color: #fff;
      border-bottom: 1px solid #eee;
      padding: 1rem 2rem;
    }

    nav {
      display: flex;
      align-items: center;
      justify-content: space-between;
    }

    .nav__links {
      display: flex;
      gap: 2rem;
      list-style: none;
      margin-left: 4rem;
      margin-top: 0.5rem;
    }

    .nav__links li a {
      text-decoration: none;
      color: #000;
      
      
      padding: 0.5rem 1rem;
      border-radius: 20px;
    }

    .nav__logo img {
  max-width: 60px;
  margin-bottom: 0.5rem;
  margin-top: 0.5rem; /* 👈 shifts logo down */
    }

    .header__container {
      padding: 2rem;
    }

    .header__content {
      max-width: 100%;
      margin-bottom: 2rem;
    }

    #chart-container {
      width: 100%;
      height: 480px;
      background-color:rgb(255, 255, 255);
      border: 2px solid #f0a3b8;
      border-radius: 10px;
      padding: 1rem;
    }

    #fhrChart {
      width: 100% !important;
      height: 100% !important;
    }

    h1 {
      font-size: 2.8rem;
      margin-bottom: 0.5rem;
    }

    h2 {
      font-size: 2rem;
      font-weight: 400;
      margin-bottom: 1rem;
    }

    #fhr-live {
      font-size: 2rem;
      font-weight: bold;
      color: #000;
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
        <li><a href="../view/liveData.php?uid=<?= $uid ?>&name=<?= urlencode($name) ?>">Live Data</a></li>
        <li><a href="../view/historicalData.php?uid=<?= $uid ?>&name=<?= urlencode($name) ?>">History</a></li>
        <li><a href="../view/report.php?uid=<?= $uid ?>&name=<?= urlencode($name) ?>">Report</a></li>
        <li><a href="../view/selectPatient.php">Back to Patients</a></li>
      </ul>
    </nav>
  </header>

  <section class="header__container">
    <div class="header__content">
      <h1 id="patient-name">Patient: <?= htmlspecialchars($name ?: "Unknown") ?></h1>
      <h2>Live Fetal Heart Rate (FHR)</h2>
      <div id="fhr-live">Loading live data...</div>
    </div>
    <div id="chart-container">
      <canvas id="fhrChart"></canvas>
    </div>
  </section>
</body>
</html>
