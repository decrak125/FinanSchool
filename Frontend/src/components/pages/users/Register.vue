<script setup>
import { ref } from 'vue'
import axios from 'axios'

import Page from '@/components/template/Page.vue';
import formCard from '@/components/molecules/Form-card.vue';
import Texte from '@/components/atoms/Texte.vue';
import Input from '@/components/atoms/Input.vue';
import Bouton from '@/components/atoms/Bouton.vue';
import Icon from '@/components/atoms/Icon.vue';
import Popup from '@/components/molecules/Pop-up-card.vue';
import BoutonLoading from '@/components/atoms/Bouton-loading.vue';

const step = ref(1)
const email = ref('')
const name = ref('')
const password = ref('')
const password_confirmation = ref('')
const codeDigits = ref(['', '', '', '', '', ''])
const message = ref('')
const error = ref(false)
const loading = ref(false)
const successMessage = ref('')
const registered = ref('')

const API_URL = 'http://localhost:8000/api'

// Étape 1 : envoyer le code
const sendCode = async () => {
    message.value = ''
    successMessage.value = ''
    error.value = false
    try {
        loading.value = true
        const res = await axios.post(`${API_URL}/request-verification`, { email: email.value })
        if (res.data.status === 'success') {
            step.value = 2
            successMessage.value = res.data.message
        }
    } catch (err) {
        error.value = true
        message.value = err.response?.data?.message || 'Erreur lors de l\'envoi du code'
    }
    finally {
        loading.value = false
    }
}

// Gérer le focus automatique sur chaque input du code
const focusNext = (index, e) => {
    if (e.inputType === 'insertText' && index < 5) {
        const nextInput = e.target.parentNode.children[index + 1]
        nextInput.focus()
    }
}

// Étape 2 : vérifier le code
const verifyCode = async () => {
    message.value = ''
    successMessage.value = ''
    error.value = false
    const code = codeDigits.value.join('')
    try {
        loading.value = true
        const res = await axios.post(`${API_URL}/verify-code`, { email: email.value, code })
        if (res.data.status === 'success') {
            step.value = 3
            successMessage.value = 'Code validé, finalisez votre inscription'
        }
    } catch (err) {
        error.value = true
        message.value = err.response?.data?.message || 'Code invalide'
    }
    finally {
        loading.value = false
    }
}

// Étape 3 : finaliser inscription
const registerUser = async () => {
    message.value = ''
    successMessage.value = ''
    registered.value = ''
    error.value = false
    try {
        loading.value = true
        const res = await axios.post(`${API_URL}/register`, {
            email: email.value,
            name: name.value,
            password: password.value,
            password_confirmation: password_confirmation.value
        })
        if (res.data.status === 'success') {
            successMessage.value = 'Inscription réussie'
            registered.value = 'Inscription réussie'

            // Réinitialiser les champs
            step.value = 1
            email.value = ''
            name.value = ''
            password.value = ''
            password_confirmation.value = ''
            codeDigits.value = ['', '', '', '', '', '']

            // ✅ Redirection vers login après 1 seconde
            // setTimeout(() => {
            //     window.location.href = '/'  // ou this.$router.push('/') si tu es dans un component classique
            // }, 1000)
        }
    } catch (err) {
        error.value = true
        message.value = err.response?.data?.message || 'Erreur lors de la création'
    }
    finally {
        loading.value = false
    }
}
const login = async () => {
    window.location.href = '/';
};
</script>
<template>
    <Page>
        <div class="main">
            <Popup v-if="registered">
                <Icon :color="'vert'" :icon="'bi bi-check2'" />
                    <Texte :type="'bold-dark'" texte="Félicitations, vous etes inscrit !" />
                    <Bouton @click="login" :type="'input'" :texte="'Se connecter'" />
                </Popup>
            <div class="gauche">
                <div class="welcome">
                    <Texte type="title-light" texte="Bonjour." />
                    <Texte type="light"
                        texte="Bienvenue sur votre espace financier sécurisé. Suivez, analysez et maîtrisez vos états financiers en toute confiance." />
                </div>
            </div>
            <div class="droite">
                <formCard v-if="step === 1">
                    <img class="logo" src="../../assets/img/01Raitra kidz 300px.png" alt="">
                    <Texte type="bold-dark" texte="Inscrivez-vous !" />
                    <Input :label="'Email'" :type="'email'" v-model="email" :required="'true'" />
                    <div class="button">
                        <Bouton v-if="!loading" @click="sendCode" :type="'input'" :texte="'Confirmer email'" />
                        <BoutonLoading v-if="loading" :type="'input'" :texte="'Connexion ...'" />
                        <div class="forgot-pwd">
                            <Texte :type="'thin-dark'" :texte="'Vous avez déjà un compte?'" />
                            <a href="/">
                                <Texte :type="'thin-primary'" :texte="'Connectez-vous.'" />
                            </a>
                        </div>
                    </div>
                    <Texte v-if="message" :class="{'error': error}" :type="'thin-error'"
                        :texte="message" />
                    <Texte v-if="successMessage" :class="{'error': error}" :type="'thin-success'"
                        :texte="successMessage" />
                </formCard>
                <formCard v-if="step === 2">
                    <Icon :color="'primary'" :icon="'bi bi-envelope'" />
                    <Texte type="bold-dark" texte="Consultez votre email." />
                    <Texte :type="'thin-dark'" :texte="'Entrez le code à 6 chiffres envoyé à votre email ' +  email " />
                    <div class="code-boxes">
                        
                        <!-- original -->
                        <input class="digit" v-for="(digit, index) in codeDigits" 
                        :key="index" 
                        type="text" 
                        maxlength="1" 
                        v-model="codeDigits[index]"
                        @input="focusNext(index, $event)" 
                        required/>
                    </div>
                    <Bouton v-if="!loading" @click="verifyCode" :type="'input'" :texte="'Vérifier le code'" />
                    <BoutonLoading v-if="loading" :type="'input'" :texte="'Connexion ...'" />
                    <Texte @click="sendCode" :type="'primary'" :texte="'Renvoyer le code.'" />
                    <Texte v-if="message" :class="{'error': error}" :type="'thin-error'"
                        :texte="message" />
                    <Texte v-if="successMessage" :class="{'error': error}" :type="'thin-success'"
                        :texte="successMessage" />
                </formCard>
                <formCard v-if="step === 3">
                    <Icon :color="'primary'" :icon="'bi bi-pencil-square'" />
                    <Texte type="bold-dark" texte="Finalisez votre inscription." />
                    <Texte v-if="message" :class="{'error': error}" :type="'thin-error'"
                        :texte="message" />
                        <Texte v-if="successMessage" :class="{'error': error}" :type="'thin-success'"
                        :texte="successMessage" />
                <div class="">
                    <Input  :label="'Nom d\'utilisateur'" :type="'text'" v-model="name" :required="'true'" />
                    <Input :label="'Mot de passe'" :type="'password'" v-model="password" :required="'true'"/>
                    <Input  :label="'Confirmer mot de passe'" :type="'password'" v-model="password_confirmation" :required="'true'" />
                </div>
                    <Bouton v-if="!loading" @click="registerUser" :type="'input'" :texte="'Finaliser l\'inscription'" />
                    <BoutonLoading v-if="loading" :type="'input'" :texte="'Connexion ...'" />
                </formCard>
            </div>
        </div>
    </Page>
    <div v-if="user">
        <h2>Utilisateur connecté :</h2>
        <pre>{{ user }}</pre>
        <button @click="handleLogout">Déconnecter</button>
    </div>

    <!-- Message d'erreur -->
    <!-- <p v-if="errorMessage" style="color:red">{{ errorMessage }}</p> -->

    <!-- Message de succès -->
    <!-- <p v-if="successMessage" style="color:green">{{ successMessage }}</p> -->
</template>
<style lang="scss" scoped>

.digit{
  @include digit($dark, $dark, $radius-pm, $stara);
    width: 24px;
    .input::placeholder{
        color: $dark;
    }
}
.forgot-pwd {
    display: flex;
    width: auto;
    gap: 8px;
    justify-content: center;

    a {
        text-decoration: none;
        height: 0px;
        margin: 0%;
        padding: 0%;
    }
}
.logo {
    width: 140px;
    height: auto;
    margin-bottom: 20px;
}
.droite {
    opacity: 0;
    transform: translateX(500px);
    animation: fadeInUp 1s ease-out forwards;
    animation-delay: 0.4s;
}
.main {
    display: flex;
    width: 100%;
    height: 100%;
    background: url('@/assets/img/pattern01.png') repeat-x; // répétition horizontale
    background-size: auto 100%; // garde la taille du pattern
    animation: scroll-bg 60s linear infinite;
    .gauche {
        @include position-contenus(flex, center, center);
        width: 100%;
        height: 100vh;
        border-radius: 0 var(--border-radius, 32px) var(--border-radius, 32px) 0;
    }
}
.code-boxes {
  display: flex;
  gap: 5px;
}
.welcome {
    display: flex;
    width: 494px;
    flex-direction: column;
    align-items: flex-start;
    opacity: 0;
    transform: translateY(40px);
    transform: translateX(400px);
    animation: fadeInUp 1s ease-out forwards;
    // animation-delay: 0.3s;
  }


.button {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
}

</style>
