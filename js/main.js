// ===== Toggle Mobile Navigation Menu =====
const menuBtn = document.getElementById("menu-btn");
const navLinks = document.getElementById("nav-links");
const menuBtnIcon = menuBtn.querySelector("i");

menuBtn.addEventListener("click", () => {
  navLinks.classList.toggle("open");

  const isOpen = navLinks.classList.contains("open");
  menuBtnIcon.setAttribute("class", isOpen ? "ri-close-line" : "ri-menu-line");
});

navLinks.addEventListener("click", () => {
  navLinks.classList.remove("open");
  menuBtnIcon.setAttribute("class", "ri-menu-line");
});

// ===== Trigger Image Reveal After Animation =====
const headerImage = document.querySelector(".header__image");

// Just in case animation doesn't fire, fallback after load
window.addEventListener("load", () => {
  setTimeout(() => {
    headerImage.classList.add("reveal");
  }, 500); // slight delay to mimic animation timing
});

// ===== ScrollReveal Animations =====
const scrollRevealOption = {
  distance: "50px",
  origin: "bottom",
  duration: 1000,
};

ScrollReveal().reveal(".header__content h1", {
  ...scrollRevealOption,
  delay: 1500,
});
ScrollReveal().reveal(".header__content h2", {
  ...scrollRevealOption,
  delay: 2000,
});
ScrollReveal().reveal(".header__content p", {
  ...scrollRevealOption,
  delay: 2500,
});
ScrollReveal().reveal(".header__content div", {
  ...scrollRevealOption,
  delay: 3000,
});
ScrollReveal().reveal(".header .nav__links", {
  delay: 3500,
});
