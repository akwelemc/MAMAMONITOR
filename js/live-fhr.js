import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import { getDatabase, ref, onValue, get, child } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";

// Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
  authDomain: "mamamonitor-bc144.firebaseapp.com",
  databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
  projectId: "mamamonitor-bc144",
  storageBucket: "mamamonitor-bc144.firebasestorage.app",
  messagingSenderId: "1053977602705",
  appId: "1:1053977602705:web:e86144988a193e5633ad30",
  measurementId: "G-C3PWJBLXRQ"
};

// Initialize Firebase app and database
const app = initializeApp(firebaseConfig);
const db = getDatabase(app);

// Wait until the DOM is fully loaded
window.addEventListener("DOMContentLoaded", () => {
  // Extract uid and name from URL
  const urlParams = new URLSearchParams(window.location.search);
  const uid = urlParams.get('uid');
  const patientName = urlParams.get('name');

  const nameElement = document.getElementById('patient-name');

  // Fallback to fetch name from DB if name param is missing
  if (!patientName && uid) {
    const dbRef = ref(db);
    get(child(dbRef, `users/${uid}`)).then((snapshot) => {
      if (snapshot.exists()) {
        const data = snapshot.val();
        nameElement.textContent = `Patient: ${data.name}`;
      } else {
        nameElement.textContent = `Patient: Unknown`;
      }
    }).catch(() => {
      nameElement.textContent = `Patient: Unknown`;
    });
  } else {
    nameElement.textContent = `Patient: ${patientName || "Unknown"}`;
  }

  // Reference to FHR data
  const fhrRef = ref(db, `patient_data/${uid}/fhr`);
  const liveDiv = document.getElementById('fhr-live');

  // Create and insert a table element
  const table = document.createElement('table');
  table.style.marginTop = '2rem';
  table.style.width = '100%';
  table.style.maxWidth = '700px';
  table.style.borderCollapse = 'collapse';
  table.style.border = '1px solid #ccc';

  const thead = document.createElement('thead');
  thead.innerHTML = `<tr style="background-color: #ffe4ec;">
    <th style="padding: 10px; text-align: left;">Timestamp</th>
    <th style="padding: 10px; text-align: left;">FHR (bpm)</th>
  </tr>`;
  table.appendChild(thead);

  const tbody = document.createElement('tbody');
  table.appendChild(tbody);
  document.querySelector('.header__content').appendChild(table);

  // Listen to Firebase data
  onValue(fhrRef, (snapshot) => {
    const data = snapshot.val();
    if (data) {
      const keys = Object.keys(data).sort().reverse();

      // Set latest reading at the top
      liveDiv.textContent = `${data[keys[0]]} bpm`;

      // Fill the table with all readings
      tbody.innerHTML = '';
      keys.reverse().forEach((timestamp) => {
        const row = document.createElement('tr');
        row.innerHTML = `
          <td style="padding: 8px; border-bottom: 1px solid #eee;">${timestamp}</td>
          <td style="padding: 8px; border-bottom: 1px solid #eee;">${data[timestamp]}</td>
        `;
        tbody.appendChild(row);
      });
    } else {
      liveDiv.textContent = "No data available.";
      tbody.innerHTML = '';
    }
  });
});