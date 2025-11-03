<template>
  <header class="app-header">
    <!-- Recherche globale -->
    <div class="header-left">
      <div class="search-container">
        <i class="bi bi-search"></i>
        <input
          type="text"
          v-model="searchQuery"
          placeholder="Rechercher..."
          class="search-input"
        />
      </div>
    </div>

    <!-- Section droite (Notifications + Profil) -->
    <div class="header-right">
      <!-- Notifications -->
      <div class="notifications-section">
        <div class="notification-icon" @click="showNotifications = !showNotifications">
          <i class="bi bi-bell"></i>
          <span v-if="unreadCount > 0" class="notification-badge">{{ unreadCount }}</span>
        </div>

        <!-- Dropdown Notifications -->
        <div v-show="showNotifications" class="notifications-dropdown">
          <div class="dropdown-header">
            <h3>Notifications</h3>
            <button @click="markAllAsRead" v-if="unreadCount > 0">Tout lire</button>
          </div>

          <div class="notifications-list">
            <div v-if="notifications.length === 0" class="no-notifications">
              Aucune notification
            </div>
            <div 
              v-for="notification in notifications" 
              :key="notification.id"
              class="notification-item"
              :class="{ unread: notification.statut !== 'lu' }"
              @click="handleNotificationClick(notification)"
            >
              <div
                class="notification-icon-small"
                :style="getNotificationStyle(notification)"
              >
                <i :class="getNotificationIcon(notification)"></i>
              </div>
              <div class="notification-content">
                <p class="notification-title">{{ notification.titre || notification.title }}</p>
                <p class="notification-message">{{ notification.message }}</p>
                <p class="notification-date">{{ formatDate(notification.created_at) }}</p>
              </div>
            </div>
          </div>
        </div>
      </div>

      <!-- Profil -->
      <div class="profile-section">
        <div class="profile-trigger" @click="showProfile = !showProfile">
          <div class="profile-avatar">
            <span class="avatar-initials">{{ getInitials(user?.name || 'U') }}</span>
          </div>
          <div class="profile-info" v-if="user">
            <span class="profile-name" v-if="user && user.name">{{ user.name }}</span>
          </div>
          <i class="bi bi-chevron-down"></i>
        </div>

        <!-- Dropdown Profil -->
        <div v-show="showProfile" class="profile-dropdown">
          <div class="profile-dropdown-header">
            <div class="profile-avatar-large">
              <span class="avatar-initials">{{ getInitials(user?.name || 'U') }}</span>
            </div>
            <div class="profile-details">
              <h3>{{ user.name || 'Utilisateur' }}</h3>
              <p>{{ user.email || 'email@example.com' }}</p>
            </div>
          </div>

          <div class="profile-menu">
            <button @click="handleLogout" class="profile-menu-item logout">
              <i class="bi bi-box-arrow-right"></i>
              <span>Déconnexion</span>
            </button>
          </div>
        </div>
      </div>
    </div>
  </header>
</template>

<script>
import axios from "axios"
import { useRouter } from 'vue-router'

export default {
  name: 'AppHeader',
  props: {
    user: {
      type: Object,
      default: () => ({ name: 'Utilisateur', email: 'email@example.com' })
    }
  },
  data() {
    return {
      searchQuery: '',
      showNotifications: false,
      showProfile: false,
      notifications: []
    }
  },
  computed: {
    unreadCount() {
      return this.notifications.filter(n => n.statut !== 'lu').length
    }
  },
  mounted() {
    this.fetchNotifications()
  },
  methods: {
    getInitials(name) {
      return name
        ? name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2)
        : 'U'
    },
    async fetchNotifications() {
      try {
        const { data } = await axios.get('http://localhost:8000/api/notifications')
        this.notifications = data
      } catch (err) {
        // Optionnel : toasts ou erreur console
      }
    },
    getNotificationIcon(notification) {
      return notification.niveau_urgence?.icone || 'bi-info-circle-fill'
    },
    getNotificationStyle(notification) {
      return {
        background: notification.niveau_urgence?.couleur || '#dbeafe',
        color: '#233'
      }
    },
    formatDate(dateString) {
      return new Date(dateString).toLocaleString('fr-FR')
    },
    async markAsRead(id) {
      const notif = this.notifications.find(n => n.id === id)
      if (notif && notif.statut !== 'lu') {
        try {
          await axios.patch(`http://localhost:8000/api/notifications/${id}/read`)
          notif.statut = 'lu'
        } catch (err) {
          // Optionnel : toast/alerte
        }
      }
    },
    async markAllAsRead() {
      // Marque toutes comme lue en backend puis refetch la liste entière
      const unreadIds = this.notifications.filter(n => n.statut !== 'lu').map(n => n.id)
      await Promise.all(unreadIds.map(id => this.markAsRead(id)))
      // Optionnel : re-fetch pour sync avec backend
      // await this.fetchNotifications()
    },
    async handleNotificationClick(notification) {
      await this.markAsRead(notification.id)
      // Redirection SPA ou classique vers la cible
      // Priorité : redirect_url, lien_redirection, données_evenement.lien_redirection
      const url = notification.redirect_url ||
                  notification.lien_redirection ||
                  notification.evenement?.donnees_evenement?.lien_redirection
      if (url) {
        // SPA ? Remplace par $router.push si possible
        if (this.$router && url.startsWith('/')) {
          this.$router.push(url)
        } else {
          window.location.href = url
        }
      }
    },
    handleLogout() {
      localStorage.removeItem("token");
      this.$router.push("/")
    }
  }
}
</script>

<style scoped>
.app-header {
  background: white;
  border-bottom: 1px solid #e2e8f0;
  padding: 20px 32px;
  margin-left: 278px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.header-left {
  flex: 1;
}

.search-container {
  position: relative;
  max-width: 400px;
}

.search-input {
  width: 100%;
  padding: 8px 12px 8px 36px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.875rem;
  outline: none;
  font-family: 'Stara', sans-serif;
}
.search-input:focus {
  border-color: #1e40af;
  box-shadow: 0 0 0 2px rgba(30, 64, 175, 0.2);
}
.bi-search {
  position: absolute;
  left: 12px;
  top: 50%;
  transform: translateY(-50%);
  color: #64748b;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 20px;
}

.notifications-section {
  position: relative;
}

.notification-icon {
  position: relative;
  width: 40px;
  height: 40px;
  background: #f8fafc;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  cursor: pointer;
}
.notification-icon:hover {
  background: #1e40af;
  color: white;
}

.notification-badge {
  position: absolute;
  top: -6px;
  right: -6px;
  background: #dc2626;
  color: white;
  font-size: 10px;
  font-weight: 600;
  padding: 2px 6px;
  border-radius: 10px;
  min-width: 18px;
}
.notifications-dropdown {
  position: absolute;
  top: 50px;
  right: 0;
  width: 350px;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  z-index: 1000;
}
.dropdown-header {
  padding: 16px 20px;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  justify-content: space-between;
  align-items: center;
}
.dropdown-header h3 {
  font-size: 1rem;
  font-weight: 600;
  margin: 0;
}
.dropdown-header button {
  background: none;
  border: none;
  color: #1e40af;
  font-size: 0.75rem;
  cursor: pointer;
}
.notifications-list {
  max-height: 350px;
  overflow-y: auto;
}
.no-notifications {
  padding: 40px 20px;
  text-align: center;
  color: #94a3b8;
  font-size: 0.875rem;
}
.notification-item {
  padding: 16px 20px;
  border-bottom: 1px solid #f1f5f9;
  cursor: pointer;
  display: flex;
  gap: 12px;
}
.notification-item:hover {
  background: #f8fafc;
}
.notification-item.unread {
  background: #eff6ff;
  border-left: 3px solid #1e40af;
}
.notification-icon-small {
  width: 32px;
  height: 32px;
  border-radius: 6px;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}
.notification-content {
  flex: 1;
}
.notification-title {
  font-size: 0.875rem;
  font-weight: 600;
  margin: 0 0 4px 0;
}
.notification-message {
  font-size: 0.75rem;
  color: #64748b;
  margin: 0;
}

.profile-section {
  position: relative;
}
.profile-trigger {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 12px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  cursor: pointer;
  height: 40px;
  font-family: 'Stara', sans-serif;
}
.profile-trigger:hover {
  background: #f8fafc;
}
.profile-avatar {
  width: 25px;
  height: 25px;
  border-radius: 50%;
  background: #1e40af;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-family: 'Stara', sans-serif;
}
.profile-info {
  display: flex;
  flex-direction: column;
}
.profile-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1e293b;
}
.bi-chevron-down {
  font-size: 0.75rem;
  color: #64748b;
}
.profile-dropdown {
  position: absolute;
  top: 40px;
  right: 0;
  width: 280px;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  font-family: 'Stara', sans-serif;
}
.profile-dropdown-header {
  padding: 20px;
  background: #f8fafc;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  gap: 12px;
}
.profile-avatar-large {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  background: #1e40af;
  color: white;
  display: flex;
  align-items: center;
  justify-content: center;
  font-weight: 600;
  font-size: 1rem;
}
.profile-details h3 {
  font-size: 1rem;
  font-weight: 600;
  margin: 0 0 4px 0;
}
.profile-details p {
  font-size: 0.75rem;
  color: #64748b;
  margin: 0;
}
.profile-menu {
  padding: 8px 0;
}
.profile-menu-item {
  width: 100%;
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 12px 20px;
  border: none;
  background: none;
  cursor: pointer;
  font-size: 0.875rem;
  color: #374151;
  text-align: left;
}
.profile-menu-item:hover {
  background: #f9fafb;
}
.profile-menu-item i {
  width: 20px;
}
.profile-menu-item.logout {
  color: #dc2626;
}
.profile-menu-item.logout:hover {
  background: #fef2f2;
}
.menu-divider {
  height: 1px;
  background: #e5e7eb;
  margin: 8px 0;
}
@media (max-width: 768px) {
  .app-header {
    margin-left: 0;
    padding: 16px 20px;
  }
  .profile-info {
    display: none;
  }
}
</style>
