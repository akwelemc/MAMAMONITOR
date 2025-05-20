<?php 
  $uid  = $_GET['uid']  ?? '';
  $name = $_GET['name'] ?? '';
?>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>AI Health Report</title>
  <link rel="stylesheet" href="../css/homepage.css" />
  <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
  <script src="https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js"></script>
  <script type="module" src="../js/alert.js"></script>
  <script type="module">
    import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
    import { getDatabase, ref, get, child } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";

    const firebaseConfig = {
      apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
      authDomain: "mamamonitor-bc144.firebaseapp.com",
      databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
      projectId: "mamamonitor-bc144",
      storageBucket: "mamamonitor-bc144.appspot.com",
      messagingSenderId: "1053977602705",
      appId: "1:1053977602705:web:e86144988a193e5633ad30",
    };

    const app = initializeApp(firebaseConfig);
    const db  = getDatabase(app);

    window.addEventListener("DOMContentLoaded", async () => {
      const uid      = "<?= htmlspecialchars($uid) ?>";
      const name     = "<?= htmlspecialchars($name) ?>";
      const statusEl = document.getElementById("report-status");
      const outputEl = document.getElementById("report-output");

      document.getElementById("patient-name").textContent = "Patient: " + (name || "Unknown");

      if (!uid) {
        statusEl.textContent = "Missing patient ID.";
        return;
      }

      try {
        const dbRef   = ref(db);
        const snap = await get(child(dbRef, 'patient_data/heart_rate/' + uid));
        if (!snap.exists()) {
          statusEl.textContent = "No FHR data available.";
          return;
        }
        const data = snap.val();

        const res = await fetch("../view/generateReport.php", {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ uid, name, heart_rate: data })
        });

        if (!res.ok) throw new Error(`Server returned ${res.status}: ${await res.text()}`);

        const result = await res.json();
        if (!result || typeof result !== 'object') throw new Error("Invalid response format from server");

        if (result.success) {
          statusEl.style.display = "none";
          outputEl.textContent = result.report;
        } else {
          throw new Error(result.error || "Unknown error");
        }

      } catch (err) {
        console.error("Report Error:", err);
        statusEl.textContent = "Error:" + err.message;
      }

      // Export to PDF logic
      document.getElementById("export-report-btn").addEventListener("click", () => {
        const { jsPDF } = window.jspdf;
        const doc = new jsPDF();

        const name = document.getElementById("patient-name")?.textContent || "Patient";
        const reportText = document.getElementById("report-output")?.textContent || "No report generated.";
        const currentDate = new Date().toLocaleString();

        const logo = new Image();
        logo.src = "../images/pregnantwoman4.png";
        logo.onload = () => {
          doc.addImage(logo, "PNG", 15, 10, 20, 20);

          doc.setFontSize(20);
          doc.setFont(undefined, "bold");
          doc.text("MAMA MONITOR: ENHANCING PRENATAL CARE", 40, 20);

          doc.setFontSize(12);
          doc.setFont(undefined, "normal");
          doc.text(name, 15, 40);
          doc.text("Exported: " + currentDate, 15, 48);

          const lines = doc.splitTextToSize(reportText, 180);
          doc.text(lines, 15, 60);

          const fileName = name.replace(/\s+/g, "_").toLowerCase() + "_report.pdf";
          doc.save(fileName);
        };
      });
    });
  </script>
</head>
<body>
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
      <h1 id="patient-name">Patient: <?= htmlspecialchars($name ?: "Unknown") ?></h1>
      <h2>AI-Generated Health Report</h2>
      <div id="report-status" style="margin-top: 1rem; font-weight: bold; background-color: #ffeeee; padding: 1rem;">
        Generating personalized insights based on patient FHR readings...
      </div>
      <div id="report-output" style="margin-top: 2rem; white-space: pre-wrap; font-size: 1rem;"></div>

      <!-- Export Button -->
      <button id="export-report-btn" style="margin-top: 1.5rem; padding: 10px 20px; background-color: #ff3e95; color: white; border: none; border-radius: 8px; font-weight: bold; cursor: pointer;">
        📄 Export to PDF
      </button>
    </div>
  </section>
</body>
</html>
