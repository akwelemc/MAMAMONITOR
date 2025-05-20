// firebase-login.js
import { initializeApp } from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import {
  getAuth,
  signInWithEmailAndPassword
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";
import {
  getDatabase,
  ref,
  get,
  child
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";

// Your Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
  authDomain: "mamamonitor-bc144.firebaseapp.com",
  databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
  projectId: "mamamonitor-bc144",
  storageBucket: "mamamonitor-bc144.appspot.com",
  messagingSenderId: "1053977602705",
  appId: "1:1053977602705:web:e86144988a193e5633ad30"
};

const app = initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getDatabase(app);

const form = document.getElementById("login-form");
const errorMsg = document.getElementById("error-msg");

form.addEventListener("submit", async (e) => {
  e.preventDefault();
  const email = document.getElementById("email").value.trim();
  const password = document.getElementById("password").value.trim();

  try {
    const userCredential = await signInWithEmailAndPassword(auth, email, password);
    const user = userCredential.user;

    const uid = user.uid;

    // ✅ OPTIONAL: You can store UID in localStorage
    localStorage.setItem("mamamonitor_uid", uid);

    // ✅ Fetch the role and redirect accordingly
    const userRef = ref(db, `users/${uid}`);
    const snapshot = await get(userRef);

    if (snapshot.exists()) {
      const data = snapshot.val();
      const role = data.role;

      if (role === "doctor") {
        // ✅ Pass UID via URL to the doctor dashboard
        window.location.href = `../view/doctorDashboard.php?uid=${uid}`;
      } else if (role === "patient") {
        window.location.href = `../view/patientDashboard.php?uid=${uid}`;
      } else {
        errorMsg.textContent = "Unrecognized role. Contact admin.";
      }
    } else {
      errorMsg.textContent = "No user data found.";
    }
  } catch (error) {
    console.error("Login error:", error);
    errorMsg.textContent = "Invalid credentials. Please try again.";
  }
});
