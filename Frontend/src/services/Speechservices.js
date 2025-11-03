import EasySpeech from 'easy-speech'

let isInitialized = false

export async function initSpeech() {
  if (isInitialized) return
  
  try {
    await EasySpeech.init({ maxTimeout: 5000, interval: 250 })
    isInitialized = true
    console.log('EasySpeech initialized successfully')
  } catch (e) {
    console.error('EasySpeech initialization failed:', e)
    isInitialized = false
  }
}

// Fonction pour ajouter les balises SSML pour les intonations
function addIntonationMarkup(text) {
  let result = '<speak>'
  
  // Diviser le texte par phrases
  const sentences = text.match(/[^.!?]+[.!?]+/g) || [text]
  
  sentences.forEach((sentence) => {
    let trimmed = sentence.trim()
    
    // Question - élever légèrement la voix
    if (trimmed.endsWith('?')) {
      const questionText = trimmed.slice(0, -1)
      result += `<prosody pitch="+10%">${questionText}?</prosody>`
    }
    // Exclamation - accent sur l'emphase
    else if (trimmed.endsWith('!')) {
      const exclamationText = trimmed.slice(0, -1)
      result += `<emphasis level="strong"><prosody pitch="+5%" rate="95%">${exclamationText}!</prosody></emphasis>`
    }
    // Point normal - légère pause
    else if (trimmed.endsWith('.')) {
      result += `${trimmed}<break time="500ms" />`
    }
    // Sans ponctuation
    else {
      result += `${trimmed}<break time="300ms" />`
    }
  })
  
  result += '</speak>'
  return result
}

// Fonction avancée : analyser et ajouter des intonations intelligentes
function addSmartIntonation(text) {
  let result = '<speak>'
  
  // Patterns pour détecter les types de phrases
  const patterns = {
    question: /.*\?$/,
    exclamation: /.*!$/,
    emphasis: /\*\*(.*?)\*\*|__(.*?)__/g,
    pause: /\.\.\./g
  }
  
  // Nettoyer les marqueurs d'emphase
  let processedText = text.replace(/\*\*(.*?)\*\*/g, (match, p1) => {
    return `<emphasis level="strong">${p1}</emphasis>`
  })
  
  // Remplacer les points de suspension par une pause
  processedText = processedText.replace(/\.\.\./g, '<break time="1000ms" />')
  
  // Diviser par phrases et appliquer les intonations
  const sentences = processedText.match(/[^.!?]+[.!?]+|[^.!?]+$/g) || [processedText]
  
  sentences.forEach((sentence) => {
    let trimmed = sentence.trim()
    
    if (!trimmed) return
    
    // Question
    if (patterns.question.test(trimmed)) {
      const questionText = trimmed.slice(0, -1).trim()
      result += `<prosody pitch="+15%" rate="95%">${questionText}?</prosody>`
      result += '<break time="500ms" />'
    }
    // Exclamation
    else if (patterns.exclamation.test(trimmed)) {
      const exclamationText = trimmed.slice(0, -1).trim()
      result += `<emphasis level="strong"><prosody pitch="+10%" rate="85%">${exclamationText}!</prosody></emphasis>`
      result += '<break time="400ms" />'
    }
    // Phrase normale
    else {
      result += `<prosody rate="100%">${trimmed}</prosody>`
      result += '<break time="300ms" />'
    }
  })
  
  result += '</speak>'
  return result
}

export async function speakMessage(text, useSmartIntonation = true) {
  try {
    // Arrêter toute lecture en cours
    await EasySpeech.cancel()

    // Ajouter les intonations au texte
    const processedText = useSmartIntonation 
      ? addSmartIntonation(text) 
      : addIntonationMarkup(text)

    // Obtenir les voix disponibles en français
    const voices = EasySpeech.voices()
    const frenchVoice = voices.find(voice => voice.lang === 'fr-FR') || voices[0]

    // Parler le texte avec SSML
    await EasySpeech.speak({
      text: processedText,
      voice: frenchVoice,
      lang: 'fr-FR',
      pitch: 1,
      rate: 1, // Garder un rate normal, car SSML gère la vitesse
      volume: 1,
      onend: () => console.log('Lecture terminée'),
      onerror: (error) => console.error('Erreur de synthèse vocale:', error)
    })
  } catch (error) {
    console.error('Erreur dans speakMessage:', error)
  }
}

export function cancelSpeech() {
  try {
    EasySpeech.cancel()
  } catch (error) {
    console.error('Erreur lors de l\'annulation:', error)
  }
}
