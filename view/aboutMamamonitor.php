<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>About MamaMonitor</title>
    <link
      href="https://cdn.jsdelivr.net/npm/remixicon@4.1.0/fonts/remixicon.css"
      rel="stylesheet"
    />
    <link rel="stylesheet" href="../css/homepage.css" />
    <style>
      body {
        font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
        line-height: 1.7;
        margin: 0;
        padding: 0;
        background-color: #fffdfd;
        color: #333;
      }

      nav {
        width: 100%;
        display: flex;
        align-items: center;
        justify-content: space-between;
        padding: 1rem 3rem;
        background-color: white;
        border-bottom: 1px solid #eee;
        box-sizing: border-box;
      }

      .nav__logo img {
        width: 50px;
        height: 50px;
        object-fit: cover;
        border-radius: 50%;
        border: 3px solid #FF3E95;
      }

      .nav__links {
        display: flex;
        list-style: none;
        gap: 2rem;
        margin: 0;
        padding: 0;
      }

      .nav__links li a {
        text-decoration: none;
        color: #333;
        font-weight: 600;
        font-size: 16px;
        padding: 5px 10px;
        border-bottom: 2px solid transparent;
        transition: border-color 0.3s ease;
      }

      .nav__links li a:hover {
        border-color: #FF3E95;
      }

      .about-section {
        display: flex;
        justify-content: center;
        align-items: flex-start;
        padding: 4rem 2rem;
        gap: 3rem;
        flex-wrap: wrap;
        max-width: 1200px;
        margin: 0 auto;
      }

      .text-content {
        max-width: 600px;
        flex: 1;
        min-width: 300px;
      }

      .text-content h1 {
        font-size: 2.5rem;
        color: #FF3E95;
        margin-bottom: 1rem;
        text-align: left;
      }

      .text-content p {
        text-align: left;
        margin-bottom: 1.2rem;
      }

      .byline {
        margin-top: 2rem;
        font-style: italic;
        color: #555;
        text-align: left;
      }

      .profile-pic {
        width: 300px;
        height: 300px;
        object-fit: cover;
        border-radius: 50%;
        border: 6px solid #FF3E95;
        flex-shrink: 0;
        margin-top: 3rem; /* ✅ pushes image slightly down */
      }

      @media (max-width: 768px) {
        nav {
          flex-direction: column;
          align-items: center;
        }

        .nav__links {
          flex-direction: column;
          gap: 1rem;
          margin-top: 1rem;
        }

        .about-section {
          flex-direction: column;
          align-items: center;
          text-align: center;
        }

        .text-content h1,
        .text-content p,
        .byline {
          text-align: center;
        }
      }
    </style>
  </head>
  <body>
    <!-- ✅ Navigation Bar -->
    <header class="header">
      <nav>
        <div class="nav__logo">
          <a href="#">
            <img src="../images/Juliann_McAddy.jpg" alt="Juliann Mc-Addy" />
          </a>
        </div>
        <ul class="nav__links" id="nav-links">
          <li><a href="../view/selectPatient.php">Select Patient</a></li>
          <li><a href="../view/aboutMamaMonitor.php">About MamaMonitor</a></li>
          <li><a href="../view/doctorProfile.php">Profile</a></li>
          <li><a href="../register/login.php">Logout</a></li>
        </ul>
      </nav>
    </header>

    <!-- ✅ About Section -->
    <section class="about-section">
      <div class="text-content">
        <h1>The MamaMonitor Story</h1>
        <p>
          MamaMonitor was born from a single, stubborn question I couldn’t shake: what if pregnancy didn’t have to feel so uncertain? What if we could move away from a world where expectant mothers live in fear between checkups, hoping, praying, assuming everything is okay toward one where reassurance and insight are accessible, every day?
        </p>
        <p>
          My inspiration came from watching women close to me face the hidden stress of pregnancy. One particular story stuck with me when a relative of mine who was so anxious during her first pregnancy that she ended up staying at the hospital for nearly five months, even when there wasn’t a medical emergency. She just didn’t want to take chances. And in truth, she wasn’t being dramatic. Many complications don’t announce themselves in dramatic ways, they happen quietly, in the spaces between appointments.
        </p>
        <p>
          That’s when I knew: maternal and fetal care needs to be continuous, not just reactive. It needs to move with the mother—into her home, into her day, into her peace of mind. And that’s what MamaMonitor represents. It’s not just a project or a prototype, it’s a vision. A vision of more informed pregnancies, more confident mothers, and more lives protected simply because we paid attention a little sooner.
        </p>
        <p>
          This project is a love letter to every mother who deserves to feel empowered during her journey, not just cared for when it’s critical. MamaMonitor exists because every heartbeat matters.
        </p>
        <div class="byline">
          — Juliann Akwele Mc-Addy<br />
          Founder & Developer, MamaMonitor
        </div>
      </div>
      <img src="../images/Juliann_McAddy.jpg" alt="Juliann Mc-Addy" class="profile-pic" />
    </section>
  </body>
</html>
