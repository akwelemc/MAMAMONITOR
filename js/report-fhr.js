// report.js
import { initializeApp, getApps, getApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import {
  getDatabase,
  ref,
  get,
  child
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";

// ✅ Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
  authDomain: "mamamonitor-bc144.firebaseapp.com",
  databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
  projectId: "mamamonitor-bc144",
  storageBucket: "mamamonitor-bc144.appspot.com",
  messagingSenderId: "1053977602705",
  appId: "1:1053977602705:web:e86144988a193e5633ad30"
};

// ✅ Prevent duplicate initialization
const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
const db = getDatabase(app);

window.addEventListener("DOMContentLoaded", async () => {
  const urlParams = new URLSearchParams(window.location.search);
  const uid = urlParams.get("uid");
  const patientName = urlParams.get("name") || "Unknown";

  document.getElementById("patient-name").textContent = `Patient: ${patientName}`;

  const reportDiv = document.getElementById("report-output");
  reportDiv.textContent = "Generating personalized insights based on patient FHR readings...";

  if (!uid) {
    reportDiv.textContent = "Missing patient ID.";
    return;
  }

  try {
    const snapshot = await get(child(ref(db), `patient_data/heart_rate/${uid}`));
    const data = snapshot.val();

    if (!data || Object.keys(data).length === 0) {
      reportDiv.textContent = "No FHR data available for this patient.";
      return;
    }

    const timestamps = Object.keys(data).sort();
    const values = timestamps.map((t) => data[t]);

    const response = await fetch("../view/generateReport.php", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({
        uid,
        name: patientName,
        heart_rate: data
      })
    });

    const result = await response.json();

    if (result.success && result.report) {
      reportDiv.textContent = result.report;
    } else {
      reportDiv.textContent = "Unable to generate report.";
      console.error("OpenAI response:", result);
    }
  } catch (err) {
    console.error("Error generating report:", err);
    reportDiv.textContent = "Something went wrong. Please try again.";
  }
});
