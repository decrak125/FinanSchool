<script setup>
import Page from '../template/Page.vue';
import formCard from '../molecules/Form-card.vue';
import Texte from '../atoms/Texte.vue';
import Input from '../atoms/Input.vue';
import Bouton from '../atoms/Bouton.vue';

</script>

<script>
import { login, getUser, logout } from '../../services/Auth';
import BoutonLoading from '../atoms/Bouton-loading.vue';

export default {
  data() {
    return {
      email: '',
      password: '',
      token: '',
      user: null,
      errorMessage: '',
      successMessage: '',
      loading: false
    };
  },
  methods: {
    async handleLogin() {
      try {
        this.loading = true; // démarrer le loader
        const res = await login(this.email, this.password);
        this.token = res.data.token;
        this.user = res.data.user;

        // Stocker le token
        localStorage.setItem('token', this.token);

        // Message de succès
        this.successMessage = `Bonjour ${this.user.name}, connexion réussie !`;
        this.errorMessage = '';

        // Redirection après 1.5s
        // setTimeout(() => {
          this.$router.push('/dashboard');
        // }, 500);

      } catch (err) {
        console.log(err); // Debug pour voir exactement la réponse
        // Affiche le message envoyé par Laravel
        this.errorMessage = err.response?.data?.message || 'Erreur inconnue';
        this.successMessage = '';
      }
      finally {
        this.loading = false; // arrêter le loader
      }
    },

    async fetchUser() {
      try {
        const token = localStorage.getItem('token');
        if (!token) return;

        const res = await getUser(token);
        this.user = res.data;
      } catch (err) {
        console.error(err.response?.data);
      }
    },

    async handleLogout() {
      try {
        const token = localStorage.getItem('token');
        if (token) {
          await logout(token);
          localStorage.removeItem('token');
          this.user = null;
          this.token = '';
        }
      } catch (err) {
        console.error(err.response?.data);
      }
    }
  },
  mounted() {
    this.fetchUser();
  }
};
</script>


<template>
    <Page>
        <div class="main">
            <div class="gauche">
                <div class="welcome">
                    <Texte type="title-light" texte="Bonjour." />
                    <Texte type="light" texte="Bienvenue sur votre espace financier sécurisé. Suivez, analysez et maîtrisez vos états financiers en toute confiance." />
                </div>
            </div>
            <div class="droite">
                <formCard>
                  <img class="logo" src="../../assets/img/Tracage300.png" alt="">
                    <Texte type="bold-dark" texte="Connectez-vous !" />
                    <form @submit.prevent="handleLogin">
                    <Input :label="'Email'" :type="'email'" v-model="email" :required="'true'"/>
                    <Input :label="'Mot de passe'" :type="'password'" v-model="password" :required="'true'"/>
                    <div class="forgot-pwd">
                        <Texte :type="'thin-dark'" :texte="'Mot de passe oublié ?'" />
                        <a href="/forgot-password">
                            <Texte :type="'thin-primary'" :texte="'Cliquez ici.'" />
                        </a>
                    </div>
                    <div class="button">
                        <Bouton v-if="!loading" :type="'input'" :texte="'Se connecter'" />
                        <BoutonLoading v-if="loading" :type="'input'" :texte="'Connexion ...'" />
                        <div class="forgot-pwd">
                            <Texte :type="'thin-dark'" :texte="'Vous venez d\'arriver ?'" />
                            <a href="/signup">
                                <Texte :type="'thin-primary'" :texte="'Inscrivez-vous.'" />
                            </a>
                        </div>
                    </div>
                </form>
                    <Texte v-if="errorMessage" :type="'thin-error'"
                        :texte="errorMessage" />
                    <Texte v-if="successMessage" :type="'thin-success'"
                        :texte="successMessage" />
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
    <p v-if="errorMessage" style="color:red">{{ errorMessage }}</p>

    <!-- Message de succès -->
    <p v-if="successMessage" style="color:green">{{ successMessage }}</p>
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
.droite {
    opacity: 0;
    transform: translateX(500px);
    animation: fadeInUp 1s ease-out forwards;
    animation-delay: 0.4s;
}
.logo {
    width: 130px;
    height: auto;
    margin-bottom: 20px;
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
.welcome{
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
  @keyframes fadeInUp {
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }
.button {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 10px;
}
</style>