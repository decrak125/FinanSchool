<template>
  <div class="notifications">
    <!-- Badge avec compteur -->
    <div @click="toggleNotifications" class="notification-btn">
      <i class="bi bi-bell-fill"></i>
      <span v-if="store.unreadCount > 0" class="badge">{{ store.unreadCount }}</span>
    </div>

    <!-- Liste des notifications -->
    <div v-if="showNotifications" class="notifications-list">
      <div v-for="notification in store.notifications" 
           :key="notification.id"
           :class="['notification-item', `level-${notification.niveau_urgence?.code || 'info'}`]"
           @click="Read(notification)">
        
        <div class="notification-icon">
          <i :class="notification.niveau_urgence?.icone || 'bi bi-info-circle'"></i>
        </div>
        
        <div class="notification-content">
          <strong>{{ notification.titre }}</strong>
          <p>{{ notification.message }}</p>
          <small>{{ formatDate(notification.created_at) }}</small>
        </div>

        <button @click.stop="deleteNotification(notification)" class="delete-btn">
          ×
        </button>
      </div>
    </div>
  </div>
</template>

<script setup>
import { ref, onMounted } from 'vue'
import { useNotificationStore } from '@/stores/notificationStore'

const store = useNotificationStore()
const showNotifications = ref(false)

const toggleNotifications = () => {
  showNotifications.value = !showNotifications.value
}

const Read = async (notification) => {
  store.markAsRead(notification.id)
  
  // Redirection si lien disponible
  // if (notification.evenement?.donnees_evenement?.lien_redirection) {
  //   window.location.href = notification.evenement.donnees_evenement.lien_redirection
  // }
}

const deleteNotification = (notification) => {
  store.removeNotification(notification.id)
}

const formatDate = (dateString) => {
  return new Date(dateString).toLocaleString('fr-FR')
}

onMounted(() => {
  store.loadNotifications()
})
</script>

<style scoped>
.notifications {
  position: relative;
}

.notification-btn {
  position: relative;
  padding: 10px 15px;
  color: rgb(235, 215, 41);
  border: none;
  border-radius: 5px;
  cursor: pointer;
}

.badge {
  position: absolute;
  top: -5px;
  right: -5px;
  background: red;
  color: white;
  border-radius: 50%;
  padding: 2px 6px;
  font-size: 12px;
}

.notifications-list {
  position: absolute;
  top: 100%;
  right: 0;
  width: 400px;
  max-height: 500px;
  overflow-y: auto;
  background: white;
  border: 1px solid #ddd;
  border-radius: 5px;
  box-shadow: 0 2px 10px rgba(0,0,0,0.1);
  z-index: 1000;
}

.notification-item {
  display: flex;
  padding: 15px;
  border-bottom: 1px solid #eee;
  cursor: pointer;
  transition: background 0.2s;
}

.notification-item:hover {
  background: #f8f9fa;
}

.notification-icon {
  margin-right: 10px;
  font-size: 20px;
}

.notification-content {
  flex: 1;
}

.level-info { border-left: 4px solid #17a2b8; }
.level-avertissement { border-left: 4px solid #ffc107; }
.level-urgent { border-left: 4px solid #dc3545; }

.delete-btn {
  background: none;
  border: none;
  font-size: 20px;
  cursor: pointer;
  color: #999;
}
</style>