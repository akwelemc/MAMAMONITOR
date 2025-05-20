<?php 
  $uid = $_GET['uid'] ?? '';
  $name = $_GET['name'] ?? '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Patient Dashboard - MamaMonitor</title>
  <link rel="stylesheet" href="../css/homepage.css" />
  <script type="module" src="../js/live-fhr.js" defer></script>
</head>
<body>
  <header class="header">
    <nav>
      <div class="nav__logo">
        <a href="#">
          <img src="../images/pregnantwoman1.jpg" alt="logo" class="logo-color" style="max-width: 60px;"/>
        </a>
      </div>
      <ul class="nav__links open">
        <li><a href="../view/patientProfile.php?uid=<?= $uid ?>&name=<?= urlencode($name) ?>">Live Data</a></li>
        <li><a href="../view/historicalData.php?uid=<?= $uid ?>&name=<?= urlencode($name) ?>">Historical Data</a></li>
        <li><a href="../view/report.php?uid=<?= $uid ?>&name=<?= urlencode($name) ?>">Report</a></li>
        <li><a href="../view/selectPatient.php">Back to Patients</a></li>
      </ul>
    </nav>
  </header>

  <section class="header__container">
    <div class="header__content">
      <h1 id="patient-name">Patient: Loading...</h1>
      <h2>Live FHR Reading</h2>
      <div id="fhr-live" style="margin-top: 2rem; font-size: 2rem; font-weight: bold;">
        Loading...
      </div>
    </div>
  </section>
</body>
</html>
