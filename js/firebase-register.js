// firebase-register.js

// Import Modular Firebase SDK
import {
  initializeApp,
  getApps,
  getApp
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-app.js";
import {
  getAuth,
  createUserWithEmailAndPassword
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-auth.js";
import {
  getDatabase,
  ref,
  set
} from "https://www.gstatic.com/firebasejs/9.6.1/firebase-database.js";

// ✅ Correct Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
  authDomain: "mamamonitor-bc144.firebaseapp.com",
  databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
  projectId: "mamamonitor-bc144",
  storageBucket: "mamamonitor-bc144.appspot.com", // ✅ fixed typo here
  messagingSenderId: "1053977602705",
  appId: "1:1053977602705:web:e86144988a193e5633ad30",
  measurementId: "G-C3PWJBLXRQ"
};

// ✅ Prevent duplicate app error
const app = getApps().length ? getApp() : initializeApp(firebaseConfig);
const auth = getAuth(app);
const db = getDatabase(app);

// Handle registration
document.getElementById("register-form").addEventListener("submit", async (e) => {
  e.preventDefault();

  const name = document.getElementById("name").value;
  const email = document.getElementById("email").value;
  const password = document.getElementById("password").value;
  const role = document.getElementById("role").value;

  try {
    const userCredential = await createUserWithEmailAndPassword(auth, email, password);
    const uid = userCredential.user.uid;

    await set(ref(db, "users/" + uid), {
      name: name,
      email: email,
      role: role,
    });

    window.location.href = "../register/login.php";
  } catch (error) {
    document.getElementById("error-msg").textContent = error.message;
  }
});
