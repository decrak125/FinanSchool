import { defineStore } from 'pinia'
import { ref } from 'vue'
import axios from 'axios'

export const useNotificationStore = defineStore('notifications', () => {
  const notifications = ref([])
  const unreadCount = ref(0)
  
  // Ajouter une notification
  const addNotification = (notification) => {
    notifications.value.unshift(notification)
    unreadCount.value++
  }
  
  // Marquer comme lu

   const markAsRead = async (notificationId) => {
    const notification = notifications.value.find(n => n.id === notificationId)
    if (notification && notification.statut === 'non_lu') {
      notification.statut = 'lu'
      unreadCount.value = Math.max(0, unreadCount.value - 1)
    }
    try {
      await axios.post(`http://localhost:8000/api/${notificationId}/read`)
      notification.statut = 'lu'
      notification.lu_a = new Date().toISOString()
      unreadCount.value = Math.max(0, unreadCount.value - 1)
      
      // REDIRECTION DYNAMIQUE
      if (notification.evenement?.donnees_evenement?.lien_redirection) {
        window.location.href = notification.evenement.donnees_evenement.lien_redirection
      }
      
    } catch (error) {
      console.error('Erreur marquer comme lu:', error)
    }
  }
  
  // Supprimer une notification
  const removeNotification = async(notificationId) => {
    const notification = notifications.value.find(n => n.id === notificationId)
    if (notification && notification.statut === 'non_lu') {
      unreadCount.value = Math.max(0, unreadCount.value - 1)
    }
    notifications.value = notifications.value.filter(n => n.id !== notificationId)
    try {
        await axios.delete(`http://localhost:8000/api/notifications/${notificationId}`)
        notifications.value = notifications.value.filter(n => n.id !== notificationId)
        if (notification.statut === 'non_lu') {
          unreadCount.value = Math.max(0, unreadCount.value - 1)
        }
      } catch (error) {
        console.error('Erreur suppression:', error)
      }
  }
  
  // Charger les notifications initiales
  const loadNotifications = async () => {
    try {
      const response = await axios.get('http://localhost:8000/api/notifications')
      notifications.value = response.data
      unreadCount.value = notifications.value.filter(n => n.statut === 'non_lu').length
    } catch (error) {
      console.error('Erreur chargement notifications:', error)
    }
  }


  return {
    notifications,
    unreadCount,
    addNotification,
    markAsRead,
    removeNotification,
    loadNotifications
  }
})