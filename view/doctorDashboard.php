<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Doctor Dashboard | MamaMonitor</title>

    <link href="https://cdn.jsdelivr.net/npm/remixicon@4.1.0/fonts/remixicon.css" rel="stylesheet" />
    <link rel="stylesheet" href="../css/homepage.css" />

    <!-- Firebase SDKs -->
    <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-app-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-auth-compat.js"></script>
    <script src="https://www.gstatic.com/firebasejs/9.6.1/firebase-database-compat.js"></script>

    <!-- SweetAlert & other scripts -->
    <script src="https://cdn.jsdelivr.net/npm/sweetalert2@11"></script>
    <script type="module" src="../js/alert.js"></script>

    <script>
      const firebaseConfig = {
        apiKey: "AIzaSyDOLKht4WGOqkOvLVYJ8kXfNXDpHdHkofo",
        authDomain: "mamamonitor-bc144.firebaseapp.com",
        databaseURL: "https://mamamonitor-bc144-default-rtdb.firebaseio.com",
        projectId: "mamamonitor-bc144",
        storageBucket: "mamamonitor-bc144.appspot.com",
        messagingSenderId: "1053977602705",
        appId: "1:1053977602705:web:e86144988a193e5633ad30"
      };

      firebase.initializeApp(firebaseConfig);

      window.onload = function () {
        firebase.auth().onAuthStateChanged(function (user) {
          if (user) {
            const uid = user.uid;

            // Update doctor name
            firebase.database().ref('users/' + uid + '/name').once('value')
              .then((snapshot) => {
                const name = snapshot.val();
                if (name) {
                  document.getElementById('doctor-name').textContent = 'Dr. ' + name;
                }
              }).catch((error) => {
                console.error("Error fetching name:", error);
              });

            // ✅ Inject UID into Profile nav link
            const profileLink = document.getElementById('profile-link');
            profileLink.href = `../view/doctorProfile.php?uid=${uid}`;

          } else {
            window.location.href = "../register/login.php";
          }
        });
      };
    </script>
  </head>
  <body>
    <header class="header">
      <nav>
        <div class="nav__logo">
          <a href="#">
            <img src="../images/pregnantwoman1.jpg" alt="logo" class="logo-color" />
            <img src="../images/pregnantwoman1.jpg" alt="logo" class="logo-white" />
          </a>
        </div>
        <ul class="nav__links" id="nav-links">
          <li><a href="../view/selectPatient.php">Select Patient</a></li>
          <li><a href="../view/aboutMamamonitor.php">About MamaMonitor</a></li>
          <li><a id="profile-link" href="#">Profile</a></li> <!-- ✅ this will be updated via JS -->
          <li><a href="../register/login.php">Logout</a></li>
        </ul>
        <div class="nav__menu__btn" id="menu-btn">
          <span><i class="ri-menu-line"></i></span>
        </div>
      </nav>
      <div class="header__container">
        <div class="header__image reveal"></div>
        <div class="header__content">
          <h1>WELCOME,</h1>
          <h2 id="doctor-name">Doctor</h2>
          <p>
            Access your patients' real-time fetal and maternal health data.
            Monitor trends, review reports, and deliver timely care.
          </p>
        </div>
      </div>
    </header>

    <script src="https://unpkg.com/scrollreveal"></script>
    <script src="../js/main.js"></script>
  </body>
</html>
