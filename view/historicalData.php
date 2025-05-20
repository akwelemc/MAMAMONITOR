<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Historical FHR Data</title>
  <link rel="stylesheet" href="../css/homepage.css" />
  <script type="module" src="../js/historical-fhr.js" defer></script>
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script type="module" src="../js/alert.js"></script>
  <script type="module" src="../js/exportHistorical.js"></script>
</head>
<body>
  <?php 
    $uid = $_GET['uid'] ?? '';
    $name = $_GET['name'] ?? '';
  ?>

  <header class="header">
    <nav>
      <div class="nav__logo">
        <a href="#"><img src="../images/pregnantwoman1.jpg" alt="logo" class="logo-color" style="max-width: 60px;" /></a>
      </div>
      <ul class="nav__links open">
        <li><a href="../view/liveData.php?uid=<?= $uid ?>&name=<?= urlencode($name) ?>">Live Data</a></li>
        <li><a href="../view/historicalData.php?uid=<?= $uid ?>&name=<?= urlencode($name) ?>">Historical Data</a></li>
        <li><a href="../view/report.php?uid=<?= $uid ?>&name=<?= urlencode($name) ?>">Report</a></li>
        <li><a href="../view/selectPatient.php">Back to Patients</a></li>
      </ul>
    </nav>
  </header>

  <section class="header__container">
    <div class="header__content">
      <h1 id="patient-name">Patient: <?= htmlspecialchars($name) ?: 'Unknown' ?></h1>
      <h2>Historical FHR Records</h2>

      <div id="date-buttons-container" style="margin-top: 1.5rem; display: flex; flex-wrap: wrap; gap: 1rem;"></div>

      <!-- Chart Popup -->
      <div id="chart-popup" style="display:none; position:fixed; top:10%; left:50%; transform:translateX(-50%); width: 700px; background:white; padding:2rem; border-radius:16px; box-shadow:0 0 20px rgba(0,0,0,0.25); z-index:999;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 1rem;">
          <h3 id="popup-date-title" style="margin: 0;"></h3>
          <button onclick="document.getElementById('chart-popup').style.display='none'" style="background:none; border:none; font-size: 1.5rem; cursor:pointer; color: #888;">&times;</button>
        </div>
        <div style="height: 400px;">
          <canvas id="popup-chart" style="width: 100%; height: 100%;"></canvas>
        </div>
        <button id="export-day-btn" style="margin-top: 1rem; background-color:#ff3e95; color:white; border:none; border-radius:6px; padding:10px 16px; font-weight:bold; cursor:pointer;">Export to PDF</button>
      </div>
    </div>
  </section>
</body>
</html>
