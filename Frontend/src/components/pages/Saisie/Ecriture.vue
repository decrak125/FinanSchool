<template>
    <div class="p-6">
      <h1 class="text-2xl font-bold mb-4">Écriture Comptable</h1>
  
      <!-- FORMULAIRE MOUVEMENT -->
      <form @submit.prevent="createMouvement" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
        <div>
          <label class="block font-semibold">Date du Mouvement</label>
          <input v-model="mouvementForm.Date_mouvement" type="date" class="w-full border rounded px-2 py-1" required />
        </div>
        <div>
          <label class="block font-semibold">Journal</label>
          <select v-model="mouvementForm.Id_Journal" class="w-full border rounded px-2 py-1" required>
            <option value="">-- Sélectionner --</option>
            <option v-for="journal in journals" :key="journal.Id_Journal" :value="journal.Id_Journal">
              {{ journal.Code }} - {{ journal.Libelle }}
            </option>
          </select>
        </div>
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded">Créer Mouvement</button>
      </form>
  
      <!-- FORMULAIRE LIGNE ÉCRITURE -->
      <div v-if="currentMouvement" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
        <h2 class="font-bold mb-2">Ajouter Ligne pour {{ currentMouvement.Numero_piece }}</h2>
        <form @submit.prevent="addLigne">
          <div class="grid grid-cols-2 gap-4">
            <div>
              <label>Libellé</label>
              <input v-model="ligneForm.Libelle" type="text" class="w-full border rounded px-2 py-1" required />
            </div>
            <div>
              <label>Débit</label>
              <input v-model.number="ligneForm.Debit" type="number" class="w-full border rounded px-2 py-1" />
            </div>
            <div>
              <label>Crédit</label>
              <input v-model.number="ligneForm.Credit" type="number" class="w-full border rounded px-2 py-1" />
            </div>
            <div>
              <label>Référence</label>
              <input v-model="ligneForm.Reference" type="text" class="w-full border rounded px-2 py-1" />
            </div>
            <div>
              <label>Quantité</label>
              <input v-model.number="ligneForm.Quantite" type="number" class="w-full border rounded px-2 py-1" />
            </div>
            <div>
              <label>Mode de Paiement</label>
              <select v-model="ligneForm.Id_Mode_paiement" class="w-full border rounded px-2 py-1">
                <option value="">-- Sélectionner --</option>
                <option v-for="mode in modesPaiement" :key="mode.Id_Mode_paiement" :value="mode.Id_Mode_paiement">
                  {{ mode.Libelle }}
                </option>
              </select>
            </div>
            <div>
              <label>Sous-compte</label>
              <select v-model="ligneForm.Id_Sous_compte" class="w-full border rounded px-2 py-1" required>
                <option value="">-- Sélectionner --</option>
                <option v-for="compte in sousComptes" :key="compte.Id_Sous_compte" :value="compte.Id_Sous_compte">
                  {{ compte.Code }} - {{ compte.Libelle }}
                </option>
              </select>
            </div>
          </div>
          <button type="submit" class="mt-3 bg-green-600 text-white px-4 py-2 rounded">Ajouter Ligne</button>
        </form>
      </div>
  
      <!-- TABLEAU DES MOUVEMENTS ET LIGNES -->
      <div v-for="m in mouvements" :key="m.Id_Mouvement_ecriture" class="mb-6">
        <h2 class="font-bold">{{ m.Numero_piece }} ({{ m.Date_mouvement }})</h2>
        <table class="w-full border-collapse border">
          <thead>
            <tr class="bg-gray-200">
              <th class="border px-3 py-2">Libellé</th>
              <th class="border px-3 py-2">Débit</th>
              <th class="border px-3 py-2">Crédit</th>
              <th class="border px-3 py-2">Référence</th>
              <th class="border px-3 py-2">Quantité</th>
              <th class="border px-3 py-2">Mode Paiement</th>
              <th class="border px-3 py-2">Sous-compte</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="ligne in m.lignes" :key="ligne.Id_Ligne_ecriture">
              <td class="border px-3 py-2">{{ ligne.Libelle }}</td>
              <td class="border px-3 py-2">{{ ligne.Debit }}</td>
              <td class="border px-3 py-2">{{ ligne.Credit }}</td>
              <td class="border px-3 py-2">{{ ligne.Reference }}</td>
              <td class="border px-3 py-2">{{ ligne.Quantite }}</td>
              <td class="border px-3 py-2">{{ ligne.mode_paiement?.Libelle || '-' }}</td>
              <td class="border px-3 py-2">{{ ligne.sous_compte?.Libelle || '-' }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </template>
  
  <script setup>
  import { ref, onMounted } from "vue";
  import axios from "axios";
  
  const mouvements = ref([]);
  const journals = ref([]);
  const sousComptes = ref([]);
  const modesPaiement = ref([]);
  
  const mouvementForm = ref({
    Date_mouvement: "",
    Id_Journal: "",
  });
  
  const ligneForm = ref({
    Libelle: "",
    Debit: 0,
    Credit: 0,
    Reference: "",
    Quantite: 1,
    Id_Mode_paiement: "",
    Id_Sous_compte: "",
    Id_Mouvement_ecriture: "",
    Id_Journal: "",
  });
  
  const currentMouvement = ref(null);
  
  // Charger tous les mouvements avec leurs lignes
  const fetchMouvements = async () => {
    const res = await axios.get("http://127.0.0.1:8000/api/mouvements");
    const mouvementsData = res.data;
  
    // Pour chaque mouvement, récupérer ses lignes
    for (let m of mouvementsData) {
      const lignesRes = await axios.get(`http://127.0.0.1:8000/api/lignes`);
      m.lignes = lignesRes.data.filter(l => l.Id_Mouvement_ecriture === m.Id_Mouvement_ecriture);
    }
    mouvements.value = mouvementsData;
  };
  
  // Charger options
  const fetchOptions = async () => {
    const j = await axios.get("http://127.0.0.1:8000/api/journals");
    journals.value = j.data;
  
    const s = await axios.get("http://127.0.0.1:8000/api/sous-comptes");
    sousComptes.value = s.data;
  
    const m = await axios.get("http://127.0.0.1:8000/api/mode-paiements");
    modesPaiement.value = m.data;
  };
  
  // Créer un mouvement
  const createMouvement = async () => {
    const res = await axios.post("http://127.0.0.1:8000/api/mouvements", mouvementForm.value);
    currentMouvement.value = res.data.mouvement;
    ligneForm.value.Id_Mouvement_ecriture = currentMouvement.value.Id_Mouvement_ecriture;
    ligneForm.value.Id_Journal = currentMouvement.value.Id_Journal;
    fetchMouvements();
  };
  
  // Ajouter ligne
  const addLigne = async () => {
    await axios.post("http://127.0.0.1:8000/api/lignes", ligneForm.value);
    // reset
    ligneForm.value.Libelle = "";
    ligneForm.value.Debit = 0;
    ligneForm.value.Credit = 0;
    ligneForm.value.Reference = "";
    ligneForm.value.Quantite = 1;
    ligneForm.value.Id_Mode_paiement = "";
    fetchMouvements();
  };
  
  onMounted(() => {
    fetchOptions();
    fetchMouvements();
  });
  </script>
  
  <style scoped>
  table {
    margin-top: 1rem;
  }
  </style>
  