import { initializeApp, getApp, getApps } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import { getDatabase, ref, onValue } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";

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

// ✅ Ensure Firebase is initialized
const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
const db = getDatabase(app);

window.addEventListener("DOMContentLoaded", () => {
  const urlParams = new URLSearchParams(window.location.search);
  const uid = urlParams.get("uid");
  const patientName = urlParams.get("name") || "Unknown";

  if (!uid) return;

  const heartRateRef = ref(db, `patient_data/heart_rate/${uid}`);
  let consecutiveAbnormal = 0;
  let alertShown = false;

  onValue(heartRateRef, (snapshot) => {
    const data = snapshot.val();
    if (!data) return;

    const timestamps = Object.keys(data).sort();
    const latestBpm = parseInt(data[timestamps[timestamps.length - 1]]);

    if (latestBpm < 110 || latestBpm > 160) {
      consecutiveAbnormal++;

      if (consecutiveAbnormal >= 15 && !alertShown) {
        alertShown = true;

        Swal.fire({
          title: "⚠️ Abnormal Heart Rate Alert",
          text: `${patientName}'s fetal heart rate has been outside the safe threshold (110–160 bpm) for over 15 seconds.`,
          icon: "warning",
          confirmButtonText: "View Details",
        });
      }
    } else {
      consecutiveAbnormal = 0;
      alertShown = false;
    }
  });
});
