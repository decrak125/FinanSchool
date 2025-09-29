<template>
  <header class="app-header">
    <!-- Recherche globale -->
    <div class="header-left">
      <div class="search-container">
        <i class="bi bi-search"></i>
        <input
          type="text"
          v-model="searchQuery"
          @input="handleSearch"
          placeholder="Rechercher..."
          class="search-input"
        />
      </div>
    </div>

    <!-- Section droite (Notifications + Profil) -->
    <div class="header-right">
      <!-- Section Notifications -->
      <div class="notifications-section">
        <div class="notification-icon" @click="toggleNotifications" :class="{ active: showNotifications }">
          <i class="bi bi-bell"></i>
          <span v-if="unreadCount > 0" class="notification-badge">{{ unreadCount > 99 ? '99+' : unreadCount }}</span>
        </div>
        
        <!-- Dropdown Notifications -->
        <div v-if="showNotifications" class="notifications-dropdown" v-click-outside="closeNotifications">
          <div class="dropdown-header">
            <h3>Notifications</h3>
            <button @click="markAllAsRead" class="mark-all-read" v-if="unreadCount > 0">
              Tout marquer comme lu
            </button>
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
                <span class="notification-time">{{ formatTime(notification.createdAt) }}</span>
              </div>
            </div>
          </div>
          
          <div class="dropdown-footer">
            <button @click="viewAllNotifications" class="view-all-btn">
              Voir toutes les notifications
            </button>
          </div>
        </div>
      </div>

      <!-- Section Profil -->
      <div class="profile-section">
        <div class="profile-trigger" @click="toggleProfile" :class="{ active: showProfile }">
          <div class="profile-avatar">
            <img v-if="user?.avatar" :src="user.avatar" :alt="user.name" />
            <span v-else class="avatar-initials">{{ getInitials(user?.name || 'User') }}</span>
          </div>
          <div class="profile-info" v-if="user">
            <span class="profile-name">{{ user.name }}</span>
            <span class="profile-role">{{ user.role || 'Utilisateur' }}</span>
          </div>
          <i class="bi bi-chevron-down" :class="{ 'rotated': showProfile }"></i>
        </div>

        <!-- Dropdown Profil -->
        <div v-if="showProfile" class="profile-dropdown" v-click-outside="closeProfile">
          <div class="profile-dropdown-header">
            <div class="profile-avatar-large">
              <img v-if="user?.avatar" :src="user.avatar" :alt="user.name" />
              <span v-else class="avatar-initials">{{ getInitials(user?.name || 'User') }}</span>
            </div>
            <div class="profile-details">
              <h3>{{ user?.name || 'Utilisateur' }}</h3>
              <p>{{ user?.email || 'email@example.com' }}</p>
            </div>
          </div>
          
          <div class="profile-menu">
            <button @click="viewProfile" class="profile-menu-item">
              <i class="bi bi-person"></i>
              <span>Mon profil</span>
            </button>
            
            <button @click="openSettings" class="profile-menu-item">
              <i class="bi bi-gear"></i>
              <span>Paramètres</span>
            </button>
            
            <button @click="openHelp" class="profile-menu-item">
              <i class="bi bi-question-circle"></i>
              <span>Aide</span>
            </button>
            
            <div class="menu-divider"></div>
            
            <button @click="logout" class="profile-menu-item logout">
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
import { ref, computed } from 'vue';

export default {
  name: 'AppHeader',
  props: {
    pageSubtitle: {
      type: String,
      default: ''
    },
    user: {
      type: Object,
      default: () => ({})
    }
  },
  setup() {
    const showNotifications = ref(false);
    const showProfile = ref(false);
    const searchQuery = ref('');
    const notifications = ref([
      {
        id: 1,
        type: 'success',
        title: 'Import réussi',
        message: 'Les données ont été importées avec succès',
        read: false,
        createdAt: new Date(Date.now() - 5 * 60000) // 5 min ago
      },
      {
        id: 2,
        type: 'warning',
        title: 'Attention',
        message: 'Votre période d\'essai expire dans 3 jours',
        read: false,
        createdAt: new Date(Date.now() - 30 * 60000) // 30 min ago
      },
      {
        id: 3,
        type: 'info',
        title: 'Mise à jour',
        message: 'Une nouvelle version est disponible',
        read: true,
        createdAt: new Date(Date.now() - 2 * 60 * 60000) // 2 hours ago
      }
    ]);

    const unreadCount = computed(() => notifications.value.filter(n => !n.read).length);

    const toggleNotifications = () => {
      showNotifications.value = !showNotifications.value;
      showProfile.value = false;
    };

    const toggleProfile = () => {
      showProfile.value = !showProfile.value;
      showNotifications.value = false;
    };

    const closeNotifications = () => {
      showNotifications.value = false;
    };

    const closeProfile = () => {
      showProfile.value = false;
    };

    const markAsRead = (notificationId) => {
      const notification = notifications.value.find(n => n.id === notificationId);
      if (notification) notification.read = true;
    };

    const markAllAsRead = () => {
      notifications.value.forEach(n => n.read = true);
    };

    const getNotificationIcon = (type) => {
      const icons = {
        success: 'bi-check-circle',
        warning: 'bi-exclamation-triangle',
        info: 'bi-info-circle',
        error: 'bi-x-circle'
      };
      return icons[type] || 'bi-info-circle';
    };

    const formatTime = (date) => {
      const now = new Date();
      const diff = now - date;
      const minutes = Math.floor(diff / 60000);
      const hours = Math.floor(diff / 3600000);
      const days = Math.floor(diff / 86400000);
      
      if (minutes < 1) return 'À l\'instant';
      if (minutes < 60) return `Il y a ${minutes} min`;
      if (hours < 24) return `Il y a ${hours}h`;
      return `Il y a ${days} jour${days > 1 ? 's' : ''}`;
    };

    const getInitials = (name) => {
      return name.split(' ').map(n => n[0]).join('').toUpperCase().slice(0, 2);
    };

    const handleSearch = () => {
      // Émettre un événement ou effectuer une recherche ici
      this.$emit('search', searchQuery.value);
    };

    const viewAllNotifications = () => {
      this.$emit('view-all-notifications');
      closeNotifications();
    };

    const viewProfile = () => {
      this.$emit('view-profile');
      closeProfile();
    };

    const openSettings = () => {
      this.$emit('open-settings');
      closeProfile();
    };

    const openHelp = () => {
      this.$emit('open-help');
      closeProfile();
    };

    const logout = () => {
      this.$emit('logout');
      closeProfile();
    };

    return {
      showNotifications,
      showProfile,
      searchQuery,
      notifications,
      unreadCount,
      toggleNotifications,
      toggleProfile,
      closeNotifications,
      closeProfile,
      markAsRead,
      markAllAsRead,
      getNotificationIcon,
      formatTime,
      getInitials,
      handleSearch,
      viewAllNotifications,
      viewProfile,
      openSettings,
      openHelp,
      logout
    };
  },
  directives: {
    'click-outside': {
      beforeMount(el, binding) {
        el.clickOutsideEvent = (event) => {
          if (!(el === event.target || el.contains(event.target))) {
            binding.value(event);
          }
        };
        document.addEventListener('click', el.clickOutsideEvent);
      },
      unmounted(el) {
        document.removeEventListener('click', el.clickOutsideEvent);
      }
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
  display: flex;
  align-items: center;
  width: 100%;
  max-width: 400px;
}

.search-input {
  width: 100%;
  padding: 8px 12px;
  padding-left: 36px;
  border: 1px solid #e2e8f0;
  border-radius: 8px;
  font-size: 0.875rem;
  outline: none;
  transition: border-color 0.3s ease;
}

.search-input:focus {
  border-color: #1e40af;
  box-shadow: 0 0 0 2px rgba(30, 64, 175, 0.2);
}

.bi-search {
  position: absolute;
  margin-left: 12px;
  color: #64748b;
  font-size: 1rem;
}

.header-right {
  display: flex;
  align-items: center;
  gap: 24px;
}

/* ===== NOTIFICATIONS ===== */
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
  transition: all 0.3s ease;
}

.notification-icon:hover,
.notification-icon.active {
  background: #1e40af;
  border-color: #1e40af;
  color: white;
}

.notification-icon .bi-bell {
  font-size: 1.2rem;
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
  text-align: center;
  line-height: 1.2;
}

.notifications-dropdown {
  position: absolute;
  top: 50px;
  right: 0;
  width: 380px;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  max-height: 500px;
  overflow-y: auto;
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
  color: #1e293b;
  margin: 0;
}

.mark-all-read {
  background: none;
  border: none;
  color: #1e40af;
  font-size: 0.75rem;
  cursor: pointer;
  font-weight: 500;
}

.mark-all-read:hover {
  text-decoration: underline;
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
  transition: background 0.2s ease;
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

.notification-icon-small.success { background: #dcfce7; }
.notification-icon-small.warning { background: #fef3c7; }
.notification-icon-small.info { background: #dbeafe; }
.notification-icon-small.error { background: #fecaca; }

.notification-icon-small i {
  font-size: 1rem;
}

.notification-content {
  flex: 1;
  min-width: 0;
}

.notification-title {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1e293b;
  margin: 0 0 4px 0;
}

.notification-message {
  font-size: 0.75rem;
  color: #64748b;
  margin: 0 0 6px 0;
  line-height: 1.4;
}

.notification-time {
  font-size: 0.6875rem;
  color: #94a3b8;
}

.dropdown-footer {
  padding: 12px 20px;
  border-top: 1px solid #e2e8f0;
  text-align: center;
}

.view-all-btn {
  background: none;
  border: none;
  color: #1e40af;
  font-size: 0.875rem;
  cursor: pointer;
  font-weight: 500;
  width: 100%;
  padding: 8px;
  border-radius: 6px;
  transition: background 0.2s ease;
}

.view-all-btn:hover {
  background: #f1f5f9;
}

/* ===== PROFIL ===== */
.profile-section {
  position: relative;
}

.profile-trigger {
  display: flex;
  align-items: center;
  gap: 12px;
  padding: 8px 12px;
  border-radius: 8px;
  cursor: pointer;
  transition: all 0.3s ease;
  border: 1px solid transparent;
}

.profile-trigger:hover,
.profile-trigger.active {
  background: #f8fafc;
  border-color: #e2e8f0;
}

.profile-avatar {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #1e40af;
  color: white;
  font-weight: 600;
  font-size: 0.875rem;
}

.profile-avatar img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.profile-info {
  display: flex;
  flex-direction: column;
  text-align: left;
}

.profile-name {
  font-size: 0.875rem;
  font-weight: 600;
  color: #1e293b;
  line-height: 1.2;
}

.profile-role {
  font-size: 0.75rem;
  color: #64748b;
  line-height: 1.2;
}

.bi-chevron-down {
  width: 16px;
  height: 16px;
  transition: transform 0.3s ease;
}

.bi-chevron-down.rotated {
  transform: rotate(180deg);
}

.profile-dropdown {
  position: absolute;
  top: 60px;
  right: 0;
  width: 280px;
  background: white;
  border: 1px solid #e2e8f0;
  border-radius: 12px;
  box-shadow: 0 10px 25px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  overflow: hidden;
}

.profile-dropdown-header {
  padding: 20px;
  background: #f8fafc;
  border-bottom: 1px solid #e2e8f0;
  display: flex;
  align-items: center;
  gap: 12px;
}

.profile-avatar-large {
  width: 50px;
  height: 50px;
  border-radius: 50%;
  overflow: hidden;
  display: flex;
  align-items: center;
  justify-content: center;
  background: #1e40af;
  color: white;
  font-weight: 600;
  font-size: 1rem;
}

.profile-avatar-large img {
  width: 100%;
  height: 100%;
  object-fit: cover;
}

.profile-details h3 {
  font-size: 1rem;
  font-weight: 600;
  color: #1e293b;
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
  transition: background 0.2s ease;
  text-align: left;
  font-size: 0.875rem;
  color: #374151;
}

.profile-menu-item:hover {
  background: #f9fafb;
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

/* ===== RESPONSIVE ===== */
@media (max-width: 768px) {
  .app-header {
    margin-left: 0;
    padding: 16px 20px;
    flex-direction: column;
    gap: 16px;
    align-items: flex-start;
  }
  
  .header-right {
    align-self: flex-end;
    gap: 16px;
  }
  
  .profile-info {
    display: none;
  }
  
  .notifications-dropdown,
  .profile-dropdown {
    right: -20px;
    width: 320px;
  }
}

@media (max-width: 480px) {
  .notifications-dropdown,
  .profile-dropdown {
    width: 280px;
  }
  
  .search-container {
    max-width: 100%;
  }
  
  .search-input {
    width: 100%;
  }
}
</style>