import {
  getDatabase,
  ref,
  onChildAdded,
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";

// Format current time to "YYYY-MM-DD_HH:mm:ss"
function getCurrentFormattedTime() {
  const now = new Date();
  return now.toISOString().replace("T", "_").substring(0, 19);
}

window.addEventListener("DOMContentLoaded", () => {
  const uid = new URLSearchParams(window.location.search).get("uid");
  const patientName = new URLSearchParams(window.location.search).get("name") || "Unknown";
  const nameElement = document.getElementById("patient-name");
  const liveDiv = document.getElementById("fhr-live");
  nameElement.textContent = `Patient: ${patientName}`;
  liveDiv.textContent = `Waiting for signal...`;

  const fhrRef = ref(getDatabase(), `patient_data/heart_rate/${uid}`);
  const ctx = document.getElementById("fhrChart").getContext("2d");

  const pageLoadTime = getCurrentFormattedTime();
  let count = 0;
  const timeLabels = [];
  const dataPoints = [];

  const fhrChart = new Chart(ctx, {
    type: "line",
    data: {
      labels: [],
      datasets: [{
        label: "",
        data: [],
        fill: false,
        borderColor: "#ff3e95",
        tension: 0.3,
        pointRadius: 4,
        pointBackgroundColor: "#ff3e95",
        borderWidth: 2
      }]
    },
    options: {
      maintainAspectRatio: false,
      responsive: true,
      scales: {
        x: {
          type: "linear",
          title: {
            display: true,
            text: "Time (s)"
          },
          ticks: {
            min: 0,
            stepSize: 20,
            maxTicksLimit: 1000,
            callback: function(val) {
              return val % 20 === 0 ? `${val}` : '';
            },
            maxRotation: 0,
            minRotation: 0
          }
        },
        y: {
          min: 80,
          max: 200,
          title: {
            display: true,
            text: "FHR (bpm)"
          }
        }
      },
      plugins: {
        legend: { display: false },
        title: {
          display: true,
          text: "Live Fetal Heart Rate",
          font: { size: 20 },
          color: "#000000",
          padding: { top: 10, bottom: 20 }
        },
        tooltip: {
          callbacks: {
            title: tooltipItems => `Time: ${tooltipItems[0].label}s`,
            label: tooltipItem => `FHR: ${tooltipItem.formattedValue} bpm`
          }
        },
        annotation: {
          annotations: {
            safeZone: {
              type: "box",
              yMin: 110,
              yMax: 160,
              backgroundColor: "rgba(144, 238, 144, 0.15)",
              borderWidth: 0,
              label: {
                enabled: true,
                content: "Safe Range",
                color: "#000000",
                backgroundColor: "rgba(144, 238, 144, 0.6)",
                font: {
                  style: "italic",
                  weight: "bold",
                  size: 12
                },
                position: "start",
                yAdjust: -10
              }
            }
          }
        }
      }
    }
  });

  onChildAdded(fhrRef, (snapshot) => {
    const key = snapshot.key;      // e.g. "2025-05-11_01:16:12"
    const value = snapshot.val();  // e.g. 120

    if (key < pageLoadTime) return; // ✅ ignore old data

    dataPoints.push(value);
    timeLabels.push(count * 10);
    count++;

    liveDiv.textContent = `${value} bpm`;

    fhrChart.data.labels = timeLabels;
    fhrChart.data.datasets[0].data = dataPoints;
    fhrChart.update();
  });
});
