<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>Login | MamaMonitor</title>
  <link rel="stylesheet" href="../css/register.css" />

  <!-- Firebase Modular SDK -->
  <script type="module" src="../js/firebase-login.js"></script>
</head>
<body>
  <section>
    <div class="imgBx">
      <img src="../images/pregnantwoman1.jpg" alt="MamaMonitor">
    </div>
    <div class="contentBx">
      <div class="formBx">
        <h2>Login to MamaMonitor</h2>
        <form id="login-form">
          <div class="inputBx">
            <span>Email</span>
            <input type="email" id="email" required />
          </div>

          <div class="inputBx">
            <span>Password</span>
            <input type="password" id="password" required />
          </div>

          <div class="inputBx">
            <button type="submit">Login</button>
          </div>

          <p id="error-msg" style="color: red;"></p>
        </form>

        <!-- 👇 New sign-up link -->
        <div class="inputBx">
          <p>Don't have an account? <a href="../register/signup.php">Sign up!</a></p>
        </div>
      </div>
    </div>
  </section>
</body>
</html>
