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
              :class="{ unread: !notification.read }"
              @click="markAsRead(notification.id)"
            >
              <div class="notification-icon-small" :class="notification.type">
                <i :class="getNotificationIcon(notification.type)"></i>
              </div>
              <div class="notification-content">
                <p class="notification-title">{{ notification.title }}</p>
                <p class="notification-message">{{ notification.message }}</p>
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
            <span class="profile-name">{{ user.name }}</span>
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
import { getUser } from "../../services/Auth";

export default {
  name: 'AppHeader',
  props: {
    user: {
      type: Object,
      default: () => ({ name: 'Utilisateur' })
    }
  },
  data() {
    return {
      searchQuery: '',
      showNotifications: false,
      showProfile: false,
      notifications: [
        {
          id: 1,
          type: 'success',
          title: 'Import réussi',
          message: 'Les données ont été importées',
          read: false
        },
        {
          id: 2,
          type: 'warning',
          title: 'Attention',
          message: 'Vérifiez les écritures',
          read: false
        }
      ]
    };
  },



  computed: {
    unreadCount() {
      return this.notifications.filter(n => !n.read).length;
    }
  },
  methods: {
    getInitials(name) {
      return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
    },
    getNotificationIcon(type) {
      const icons = {
        success: 'bi-check-circle-fill',
        warning: 'bi-exclamation-triangle-fill',
        info: 'bi-info-circle-fill'
      };
      return icons[type] || 'bi-info-circle-fill';
    },
    markAsRead(id) {
      const notif = this.notifications.find(n => n.id === id);
      if (notif) notif.read = true;
    },
    markAllAsRead() {
      this.notifications.forEach(n => n.read = true);
    },
    handleLogout() {
      localStorage.removeItem("token");
      router.push("/");
    }
  }
};
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

/* NOTIFICATIONS */
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

.notification-icon-small.success { 
  background: #dcfce7; 
  color: #16a34a;
}

.notification-icon-small.warning { 
  background: #fef3c7; 
  color: #d97706;
}

.notification-icon-small.info { 
  background: #dbeafe; 
  color: #2563eb;
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

/* PROFIL */
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
