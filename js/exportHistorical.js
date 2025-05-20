// exportHistorical.js
import "https://cdnjs.cloudflare.com/ajax/libs/jspdf/2.5.1/jspdf.umd.min.js";

window.addEventListener("DOMContentLoaded", () => {
  const exportBtn = document.getElementById("export-day-btn");

  if (exportBtn) {
    exportBtn.addEventListener("click", () => {
      const { jsPDF } = window.jspdf;
      const doc = new jsPDF();

      const name = document.getElementById("patient-name")?.textContent || "Patient";
      const title = document.getElementById("popup-date-title")?.textContent || "FHR Report";
      const canvas = document.getElementById("popup-chart");

      const logo = new Image();
      logo.src = "../images/pregnantwoman4.png";
      logo.onload = () => {
        // Add logo
        doc.addImage(logo, "PNG", 15, 10, 20, 20);

        // Header text
        doc.setFontSize(20);
        doc.setFont(undefined, "bold");
        doc.text("MAMA MONITOR: ENHANCING PRENATAL CARE", 40, 20);

        doc.setFontSize(12);
        doc.setFont(undefined, "normal");
        doc.text(name, 15, 40);
        doc.text(title, 15, 48);
        doc.text("Exported: " + new Date().toLocaleString(), 15, 56);

        // Chart image
        const chartImg = canvas.toDataURL("image/png");
        doc.addImage(chartImg, "PNG", 15, 65, 180, 90);

        const cleanTitle = title.replace(/\s+/g, "_").toLowerCase();
        doc.save(`${cleanTitle}_fhr.pdf`);
      };
    });
  }
});
