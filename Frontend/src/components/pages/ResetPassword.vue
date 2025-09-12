<script setup>
import Page from '../template/Page.vue';
import formCard from '../molecules/Form-card.vue';
import Texte from '../atoms/Texte.vue';
import Input from '../atoms/Input.vue';
import Bouton from '../atoms/Bouton.vue';
import { ref, onMounted } from 'vue';
import axios from 'axios';
import Icon from '../atoms/Icon.vue';
import Popup from '../molecules/Pop-up-card.vue';


const email = ref('');
const password = ref('');
const password_confirmation = ref('');
const token = ref('');
const errorMessage = ref('');
const successMessage = ref('');

// Récupérer token + email depuis l'URL
onMounted(() => {
    const urlParams = new URLSearchParams(window.location.search);
    token.value = urlParams.get('token');
    email.value = urlParams.get('email');
});

const submitForm = async () => {
    try {
        await axios.post('http://127.0.0.1:8000/api/reset-password', {
            token: token.value,
            email: email.value,
            password: password.value,
            password_confirmation: password_confirmation.value
        });
        successMessage.value = 'Mot de passe réinitialisé avec succès !';
        errorMessage.value = '';
    } catch (error) {
        console.error(error);
        errorMessage.value = 'Erreur lors de la réinitialisation.';
        successMessage.value = '';
    }
};
const login = async () => {
    window.location.href = '/';
};
</script>

<template>
    <Page>
        <div class="main">
            <Popup v-if="successMessage">
                <Icon :color="'vert'" :icon="'bi bi-check2'" />
                <Texte :type="'bold-dark'" texte="Mot de passe réinitialisé !" />
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
                <formCard>
                    <Icon :color="'primary'" :icon="'bi bi-lock'" />
                    <Texte type="bold-dark" texte="Créez un nouveau mot de passe." />
                    <form @submit.prevent="submitForm">
                        <Input :label="'Email'" :type="'email'" v-model="email" :read="'true'" />
                        <Input :label="'Mot de passe'" :type="'password'" v-model="password" :required="'true'" />
                        <Input :label="'Confirmer le mot de passe'" :type="'password'" v-model="password_confirmation"
                            :required="'true'" />
                        <div class="button" style="margin-top: 24px;">
                            <Bouton :type="'input'" :texte="'Réinitialiser'" />
                        </div>
                    </form>
                    <Texte v-if="errorMessage" :type="'thin-error'" :texte="errorMessage" />
                    <Texte v-if="successMessage" :type="'thin-success'" :texte="successMessage" />
                </formCard>
            </div>
        </div>
    </Page>
</template>
<style lang="scss" scoped>
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