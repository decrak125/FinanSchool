<script setup>
import Page from '@/components/template/Page.vue';
import formCard from '@/components/molecules/Form-card.vue';
import Texte from '@/components/atoms/Texte.vue';
import Input from '@/components/atoms/Input.vue';
import Bouton from '@/components/atoms/Bouton.vue';
import axios from 'axios'
import Icon from '@/components/atoms/Icon.vue';
import { ref } from 'vue';
import Popup from '@/components/molecules/Pop-up-card.vue';
import BoutonLoading from '@/components/atoms/Bouton-loading.vue';

const email = ref('')
const showOpenMail = ref(false)
const loading = ref(false)
const message = ref('')

const sendLink = async () => {
    try {
        loading.value = true
        await axios.post('http://127.0.0.1:8000/api/forgot-password', { email: email.value })
        // alert('Lien envoyé par email !')
        showOpenMail.value = true
    } catch (err) {
        message.value = err.response?.data?.message
    }
    finally {
        loading.value = false
    }
}

// Ouvre Gmail dans un nouvel onglet
const openGmail = () => {
    window.open('https://mail.google.com', '_blank')
}
</script>
<template>
    <Page>
    <Popup v-if="showOpenMail">
      <Icon :color="'primary'" :icon="'bi bi-envelope'" />
      <Texte :type="'bold-dark'" texte="Consultez votre email" />
      <Texte :type="'dark'" texte="nous avons envoyé des instructions de récupération de mot de passe à votre email" />
      <Bouton @click="openGmail" :type="'input'" :texte="'Ouvrir la messagerie'"/>
    </Popup>

        <div class="main">
            <div class="gauche">
                <div class="welcome">
                    <Texte type="title-light" texte="Bonjour." />
                    <Texte type="light"
                        texte="Bienvenue sur votre espace financier sécurisé. Suivez, analysez et maîtrisez vos états financiers en toute confiance." />
                </div>
            </div>
            <div class="droite">
                <formCard>
                    <Icon :color="'primary'" :icon="'bi bi-key'" />
                    <div class="texte">
                        <Texte type="bold-dark" texte="Mot de passe oublié ?" />
                        <Texte type="thin-dark"
                            texte="Veuillez entrer votre adresse email pour pouvoir réinitialiser votre mot de passe." />
                    </div>
                    <Input :label="'Email'" :type="'email'" v-model="email" :required="'true'"/>
                    <div class="button">
                        <Bouton v-if="!loading" @click="sendLink" :type="'input'" :texte="'Envoyer le lien'" />
                        <BoutonLoading v-if="loading" :type="'input'" :texte="'Connexion ...'" />
                        <div class="forgot-pwd">
                            <Texte :type="'thin-dark'" :texte="'Vous venez d\'arriver ?'" />
                            <a href="/signup">
                                <Texte :type="'thin-primary'" :texte="'Inscrivez-vous.'" />
                            </a>
                        </div>
                    </div>
                    <Texte v-if="message" :class="{'error': true}" :type="'thin-error'"
                        :texte="message" />
                    <!-- <div v-if="showOpenMail">
                        <button @click="openGmail">📧 Ouvrir Gmail</button>
                    </div> -->
                </formCard>
            </div>
        </div>
    </Page>
</template>
<style lang="scss" scoped>
.texte{
    width:300px;
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

.welcome {
    display: flex;
    width: 494px;
    flex-direction: column;
    align-items: flex-start;
}

.button {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
}
</style>