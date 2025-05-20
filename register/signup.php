<!DOCTYPE html> 
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <title>MamaMonitor Registration</title>

  <!-- Link to your register.css -->
  <link rel="stylesheet" href="../css/register.css" />

  <style>
    .valid {
      color: green;
    }
    .invalid {
      color: red;
    }
    .checklist {
      font-size: 14px;
      margin-top: 5px;
    }
    .checklist p::before {
      content: "\2716 "; /* ❌ */
      color: red;
      font-weight: bold;
      margin-right: 5px;
    }
    .checklist p.valid::before {
      content: "\2714 "; /* ✅ */
      color: green;
    }
  </style>
</head>
<body>
  <section>
    <div class="imgBx">
      <img src="../images/pregnantwoman1.jpg" alt="Background Image">
    </div>
    <div class="contentBx">
      <div class="formBx">
        <h2>Register for MamaMonitor</h2>
        <form id="register-form">
          <div class="inputBx">
            <span>Name</span>
            <input type="text" id="name" required>
          </div>

          <div class="inputBx">
            <span>Email</span>
            <input type="email" id="email" required>
          </div>

          <div class="inputBx">
            <span>Password</span>
            <input type="password" id="password" required>
            <div class="checklist" id="password-checklist">
              <p id="length" class="invalid">At least 8 characters</p>
              <p id="uppercase" class="invalid">At least 1 uppercase letter</p>
              <p id="symbol" class="invalid">At least 1 symbol (!@#$%^&*)</p>
            </div>
          </div>

          <div class="inputBx">
            <span>Confirm Password</span>
            <input type="password" id="confirm-password" required>
          </div>

          <!-- Hidden default doctor role -->
          <input type="hidden" id="role" value="doctor" />

          <div class="inputBx">
            <button type="submit">Register</button>
          </div>

          <p id="error-msg" style="color:red;"></p>
        </form>

        <div class="inputBx">
          <p>Already have an account? <a href="../register/login.php">Login</a></p>
        </div>
      </div>
    </div>
  </section>

  <script>
    window.addEventListener("DOMContentLoaded", () => {
      const passwordInput = document.getElementById("password");
      const confirmInput = document.getElementById("confirm-password");
      const form = document.getElementById("register-form");
      const errorMsg = document.getElementById("error-msg");

      const lengthCheck = document.getElementById("length");
      const uppercaseCheck = document.getElementById("uppercase");
      const symbolCheck = document.getElementById("symbol");

      passwordInput.addEventListener("input", () => {
        const pwd = passwordInput.value;
        lengthCheck.className = pwd.length >= 8 ? "valid" : "invalid";
        uppercaseCheck.className = /[A-Z]/.test(pwd) ? "valid" : "invalid";
        symbolCheck.className = /[!@#$%^&*]/.test(pwd) ? "valid" : "invalid";
      });

      form.addEventListener("submit", (e) => {
        const pwd = passwordInput.value;
        const confirm = confirmInput.value;

        if (pwd !== confirm) {
          e.preventDefault();
          errorMsg.textContent = "Passwords do not match.";
          return;
        }

        if (
          pwd.length < 8 ||
          !/[A-Z]/.test(pwd) ||
          !/[!@#$%^&*]/.test(pwd)
        ) {
          e.preventDefault();
          errorMsg.textContent = "Password does not meet strength requirements.";
          return;
        }
      });
    });
  </script>
  <script type="module" src="../js/firebase-register.js"></script>
</body>
</html>
