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
  try {
    const notification = notifications.value.find(n => n.id === notificationId)
    
    if (!notification || notification.statut === 'lu') {
      return
    }
    
    // Appeler l'API
    await axios.patch(`http://localhost:8000/api/notifications/${notificationId}/read`)
    
    // Mettre à jour localement
    notification.statut = 'lu'
    notification.lu_a = new Date().toISOString()
    
    // Mettre à jour le compteur
    if (unreadCount && unreadCount.value !== undefined) {
      unreadCount.value = Math.max(0, unreadCount.value - 1)
    }
    
    // REDIRECTION DYNAMIQUE - avec parsing JSON
    if (notification.evenement?.donnees_evenement) {
      try {
        // Parser la chaîne JSON (les \/ seront automatiquement gérés)
        const donnees = JSON.parse(notification.evenement.donnees_evenement)
        
        // Vérifier si le lien existe
        if (donnees.lien_redirection) {
          // Optionnel: décoder les slashes si nécessaire
          const lienDecode = donnees.lien_redirection.replace(/\\\//g, '/')
          window.location.href = lienDecode
        }
      } catch (parseError) {
        console.error('Erreur de parsing JSON:', parseError)
        console.error('Données brutes:', notification.evenement.donnees_evenement)
      }
    }
    
  } catch (err) {
    console.error('Erreur lors du marquage comme lu:', err)
    // Vous pourriez vouloir remettre le statut à 'non_lu' en cas d'erreur
    if (notification) {
      notification.statut = 'non_lu'
      if (unreadCount && unreadCount.value !== undefined) {
        unreadCount.value += 1
      }
    }
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