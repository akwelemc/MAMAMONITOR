import { initializeApp, getApps, getApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js"; 
import { getDatabase, ref, onValue } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";
import "https://cdn.jsdelivr.net/npm/chart.js@4.4.0/dist/chart.umd.min.js";

// Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
  authDomain: "mamamonitor-bc144.firebaseapp.com",
  databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
  projectId: "mamamonitor-bc144",
  storageBucket: "mamamonitor-bc144.appspot.com",
  messagingSenderId: "1053977602705",
  appId: "1:1053977602705:web:e86144988a193e5633ad30"
};

// Initialize app only once
const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
const db = getDatabase(app);

window.addEventListener("DOMContentLoaded", () => {
  const urlParams = new URLSearchParams(window.location.search);
  const uid = urlParams.get("uid");
  const patientName = urlParams.get("name");

  document.getElementById("patient-name").textContent = `Patient: ${patientName || "Unknown"}`;

  const dateContainer = document.getElementById("date-buttons-container");
  const popup = document.getElementById("chart-popup");
  const popupTitle = document.getElementById("popup-date-title");
  const popupCanvas = document.getElementById("popup-chart");

  const heartRateRef = ref(db, `patient_data/heart_rate/${uid}`);

  onValue(heartRateRef, (snapshot) => {
    const data = snapshot.val();
    if (!data) {
      dateContainer.innerHTML = "<p>No historical data available.</p>";
      return;
    }

    const groupedByDate = {};
    Object.entries(data).forEach(([timestamp, value]) => {
      const [datePart] = timestamp.split("_");
      if (!groupedByDate[datePart]) groupedByDate[datePart] = [];
      groupedByDate[datePart].push({ timestamp, value });
    });

    dateContainer.innerHTML = "";

    Object.keys(groupedByDate).sort().forEach((date) => {
      const btn = document.createElement("button");
      btn.textContent = date;
      btn.style.cssText =
        "padding: 10px 16px; border-radius: 20px; background: #ff3e95; color: white; border: none; font-weight: bold; cursor: pointer;";
      btn.onclick = () => showChart(date, groupedByDate[date]);
      dateContainer.appendChild(btn);
    });

    function showChart(date, records) {
      popup.style.display = "block";
      popupTitle.textContent = `Readings for ${date}`;

      const labels = records.map((r) => {
        const parts = r.timestamp.split("_")[1]; // "14:02:11"
        return parts.substring(0, 5); // "14:02"
      });

      const values = records.map((r) => r.value);

      if (window.popupChart) window.popupChart.destroy();

      window.popupChart = new Chart(popupCanvas, {
        type: "line",
        data: {
          labels,
          datasets: [{
            label: "FHR (bpm)",
            data: values,
            borderColor: "#ff3e95",
            pointBackgroundColor: "#ff3e95",
            tension: 0.3,
            pointRadius: 4,
            fill: false,
            borderWidth: 2,
          }]
        },
        options: {
          maintainAspectRatio: false,
          responsive: true,
          scales: {
            x: {
              type: "category",
              title: { display: true, text: "Time (HH:MM)" },
              ticks: {
                maxRotation: 90,
                minRotation: 45,
              }
            },
            y: {
              min: 80,
              max: 200,
              title: { display: true, text: "FHR (bpm)" }
            }
          },
          plugins: {
            legend: { display: false },
            title: {
              display: true,
              text: `Live Fetal Heart Rate for ${date}`,
              font: { size: 16 },
              color: "#000000"
            }
          }
        }
      });
    }
  });
});
