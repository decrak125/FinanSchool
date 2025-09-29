<!-- components/Footer.vue -->
<template>
  <footer class="app-footer">
    <div class="footer-content">
      <div class="footer-info">
        <p class="footer-main">
          {{ currentYear }}, Réalisé par 
          <strong>RAKOTOARIVONY Tianasoa Cédric</strong> & 
          <strong>RAKOTONIRINA Andrianina Nantenaina</strong>
        </p>
        <p class="footer-rights">
          Droits d'Auteurs {{ currentYear }}. Tous droits réservés.
        </p>
      </div>
      
      <div class="footer-links" v-if="showLinks">
        <a href="#" @click.prevent="openModal('privacy')">Politique de confidentialité</a>
        <span class="separator">•</span>
        <a href="#" @click.prevent="openModal('terms')">Conditions d'utilisation</a>
        <span class="separator">•</span>
        <a href="#" @click.prevent="openModal('contact')">Contact</a>
      </div>
    </div>

    <!-- Version info (optionnel) -->
    <div class="version-info" v-if="showVersion">
      <span>Version {{ appVersion }}</span>
    </div>
  </footer>
</template>

<script>
export default {
  name: 'AppFooter',
  props: {
    showLinks: {
      type: Boolean,
      default: true
    },
    showVersion: {
      type: Boolean,
      default: false
    },
    appVersion: {
      type: String,
      default: '1.0.0'
    }
  },
  computed: {
    currentYear() {
      return new Date().getFullYear();
    }
  },
  methods: {
    openModal(type) {
      this.$emit('modal-open', type);
      // Ou vous pouvez gérer l'ouverture de modales ici
      console.log(`Opening ${type} modal`);
    }
  }
}
</script>

<style scoped>
.app-footer {
  background: #ffffff;
  border-top: 1px solid #e2e8f0;
  padding: 24px 32px 16px; /* Espace pour la sidebar */
  transition: margin-left 0.3s ease;
  font-family: Arial, Helvetica, sans-serif;
  margin-top: 50px;
}

.footer-content {
  max-width: 1200px;
  display: flex;
  flex-direction: column;
  gap: 16px;
}

.footer-info {
  text-align: center;
}

.footer-main {
  font-size: 12px;
  color: #64748b;
  margin: 0 0px 8px 0;
  line-height: 1.4;
}

.footer-main strong {
  color: #1e40af;
  font-weight: 600;
}

.footer-rights {
  font-size: 11px;
  color: #94a3b8;
  margin: 0;
  font-weight: 500;
}

.footer-links {
  display: flex;
  justify-content: center;
  align-items: center;
  gap: 8px;
  flex-wrap: wrap;
}

.footer-links a {
  font-size: 11px;
  color: #64748b;
  text-decoration: none;
  padding: 4px 8px;
  border-radius: 4px;
  transition: all 0.2s ease;
}

.footer-links a:hover {
  color: #1e40af;
  background: rgba(30, 64, 175, 0.05);
}

.separator {
  color: #cbd5e1;
  font-size: 12px;
}

.version-info {
  text-align: center;
  margin-top: 12px;
  padding-top: 12px;
  border-top: 1px solid #e2e8f0;
}

.version-info span {
  font-size: 10px;
  color: #94a3b8;
  background: #f1f5f9;
  padding: 2px 8px;
  border-radius: 12px;
  font-family: 'Courier New', monospace;
}

/* Responsive */
@media (max-width: 768px) {
  .app-footer {
    margin-left: 0;
    padding: 20px 16px 12px;
  }
  
  .footer-main {
    font-size: 11px;
  }
  
  .footer-rights {
    font-size: 10px;
  }
  
  .footer-links {
    flex-direction: column;
    gap: 4px;
  }
  
  .separator {
    display: none;
  }
}

@media (max-width: 480px) {
  .footer-main {
    font-size: 10px;
  }
  
  .footer-rights {
    font-size: 9px;
  }
}

/* Pour les pages sans sidebar */
.no-sidebar .app-footer {
  margin-left: 0;
}
</style>