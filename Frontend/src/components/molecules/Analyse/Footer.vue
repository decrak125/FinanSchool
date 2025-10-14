<template>
  <footer class="footer">
    <div class="footer-container">
      <!-- Partie gauche -->
      <div class="footer-left">
        <h2 class="footer-logo">RAITRA Kidz <span>Finances</span></h2>
        <p class="copyright">© 2025, Réalisé par RAKOTOARIVONY Tianasoa Cédric & RAKOTONIRINA Andrianina Nantenaina.</p>
      </div>

      <!-- Partie droite -->
      <div class="footer-right">
        <div class="socials">
          <a href="#"><i class="bi bi-facebook"></i></a>
          <a href="#"><i class="bi bi-twitter"></i></a>
          <a href="#"><i class="bi bi-youtube"></i></a>
          <a href="#"><i class="bi bi-instagram"></i></a>
        </div>
        <p class="support">
          Support:
          <a href="mailto:contact@mced.com">contact@mced.com</a>
        </p>
      </div>
    </div>
  </footer>
</template>

<script setup>
// Aucun script nécessaire ici
</script>

<style scoped lang="scss">
.footer {
  width: 100%;
//   background-color: #6e6b6b;
  color: $dark;
  padding: 12px 32px;
  @media (max-width: 768px) {
    padding: 24px;
  }
  border-top: $dark;
}

.footer-container {
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-wrap: wrap;
//   gap: 32px;
//   max-width: 1200px;
  margin: 0 auto;
}

.footer-left {
  display: flex;
  flex-direction: column;
  align-items: flex-start;
//   padding: 0;
//   gap: 12px;
}

.footer-logo {
  color: $primary;
  font-size: 1.4rem;
  font-family: $stara-black;
  padding: 0;
  line-height: 0;
  span {
    color: $dark;
    font-family: $stara-bold;
  }
}

.copyright {
  font-size: 0.75rem;
  color: $gris;
  margin-top: 10px;
  font-family: $stara-medium;
}

.footer-right {
  display: flex;
  flex-direction: column;
  align-items: flex-end;

//   gap: 10px;

  @media (max-width: 768px) {
    align-items: flex-start;
  }
}

.socials {
  display: flex;
  gap: 16px;
    
  a {
    color: $gris;
    font-size: 1.3rem;
    transition: color 0.3s ease;

    &:hover {
      color: $primary;
    }
  }
}

.support {
  font-size: 0.9rem;
    font-family: $stara-bold;
  a {
    font-family: $stara-medium;
    color: $primary;
    text-decoration: none;

    &:hover {
      text-decoration: underline;
    }
  }
}
</style>
