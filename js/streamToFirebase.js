import { initializeApp } from "firebase/app";
import { getDatabase, ref, set } from "firebase/database";
import fs from "fs";
import path from "path";

// Edwita's UID
const uid = "r8HfZmV9yYNOLBncYzv2XKJtkzQ2";

// Firebase config
const firebaseConfig = {
  apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
  authDomain: "mamamonitor-bc144.firebaseapp.com",
  databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
  projectId: "mamamonitor-bc144",
  storageBucket: "mamamonitor-bc144.appspot.com",
  messagingSenderId: "1053977602705",
  appId: "1:1053977602705:web:e86144988a193e5633ad30",
  measurementId: "G-C3PWJBLXRQ"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
const db = getDatabase(app);

// Load heart rate data from JSON file
const dataPath = path.join("./", "KD.json"); // Make sure fhr.json is in the same folder
const rawData = fs.readFileSync(dataPath);
const heartRateData = JSON.parse(rawData);

// Simulate live pushing
const sendDataToFirebase = async () => {
  for (const [timestamp, bpm] of Object.entries(heartRateData)) {
    // Firebase path-safe timestamp
    const formattedTime = timestamp.replace(/[:. ]/g, "_");

    // Set value in Firebase
    await set(ref(db, `patient_data/${uid}/heart_rate/${formattedTime}`), bpm);

    console.log(`Sent ${bpm} at ${timestamp}`);
    
    // Wait 1 second before next push
    await new Promise(resolve => setTimeout(resolve, 1000));
  }

  console.log("All data sent ✅");
};

sendDataToFirebase();
