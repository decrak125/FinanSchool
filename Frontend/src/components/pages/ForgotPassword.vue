<script setup>
import Page from '../template/Page.vue';
import formCard from '../molecules/Form-card.vue';
import Texte from '../atoms/Texte.vue';
import Input from '../atoms/Input.vue';
import Bouton from '../atoms/Bouton.vue';
import axios from 'axios'
import Icon from '../atoms/Icon.vue';
import { ref } from 'vue';
import Popup from '../molecules/Pop-up-card.vue';

const email = ref('')
const showOpenMail = ref(false)

const sendLink = async () => {
    try {
        await axios.post('http://127.0.0.1:8000/api/forgot-password', { email: email.value })
        // alert('Lien envoyé par email !')
        showOpenMail.value = true
    } catch (err) {
        alert('Erreur : ' + err.response.data.message)
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
                        <Bouton @click="sendLink" :type="'input'" :texte="'Envoyer le lien'" />
                        <div class="forgot-pwd">
                            <Texte :type="'thin-dark'" :texte="'Vous venez d\'arriver ?'" />
                            <a href="/signup">
                                <Texte :type="'thin-primary'" :texte="'Inscrivez-vous.'" />
                            </a>
                        </div>
                    </div>
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