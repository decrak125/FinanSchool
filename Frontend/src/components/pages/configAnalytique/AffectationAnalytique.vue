<script setup>
import { onMounted } from "vue";
import { useAffectations } from "@/composables/useAffectations";

const {
    affectations, centres, comptes,
    form, isEditing, fileInput, message, importSuccess,
    importCSV,
    fetchData, save, edit, remove, resetForm,
    searchTerm, suggestions, showSuggestions,
    searchCompte, selectCompte
} = useAffectations();

// const token = localStorage.getItem("token"); 

// if (!token) {
//   window.location.href = "/";
// } else {
//   axios.defaults.headers.common["Authorization"] = `Bearer ${token}`;
// }

onMounted(fetchData);
</script>

<template>
  <div class="p-6">
    <h1 class="text-2xl font-bold mb-4">Gestion des Affectations Analytiques</h1>

    <!-- Formulaire -->
    <form @submit.prevent="save" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
      <div class="relative">
        <label class="block font-semibold">Compte</label>
        <input
          type="text"
          v-model="searchTerm"
          @input="searchCompte"
          placeholder="Tapez le code ou libellé du compte"
          class="w-full border rounded px-2 py-1"
          required
        />
        <ul v-if="showSuggestions" class="absolute z-10 bg-white border w-full max-h-40 overflow-y-auto">
          <li
            v-for="compte in suggestions"
            :key="compte.Id_Compte"
            @click="selectCompte(compte)"
            class="px-2 py-1 hover:bg-gray-200 cursor-pointer"
          >
            {{ compte.Code_compte }} - {{ compte.Libelle }}
          </li>
        </ul>
      </div>

      <div>
        <label class="block font-semibold">Centre Analytique</label>
        <select v-model="form.id_centre" class="w-full border rounded px-2 py-1" required>
          <option value="" disabled>-- Sélectionner un centre --</option>
          <option v-for="centre in centres" :key="centre.id_centre" :value="centre.id_centre">
            {{ centre.nom }}
          </option>
        </select>
      </div>

      <div>
        <label class="block font-semibold">Description</label>
        <input v-model="form.description" type="text" class="w-full border rounded px-2 py-1" />
      </div>

      <div>
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded">
          {{ isEditing ? "Mettre à jour" : "Ajouter" }}
        </button>
        <button v-if="isEditing" type="button" @click="resetForm" class="ml-2 bg-gray-500 text-white px-4 py-2 rounded">
          Annuler
        </button>
      </div>
    </form>

    <form @submit.prevent="importCSV" class="mb-6 space-y-3 bg-gray-100 p-4 rounded">
      <div>
        <label class="block font-semibold">Importer un CSV</label>
        <input type="file" ref="fileInput" class="w-full" />
      </div>
      <div>
        <button type="submit" class="bg-blue-600 text-white px-4 py-2 rounded">
          Importer
        </button>
      </div>
    </form>
    <!-- Message de feedback -->
<div v-if="message.text" :class="['p-3 mb-4 rounded', messageClass]">
  {{ message.text }}
</div>


    <!-- Tableau -->
    <table class="w-full border-collapse border">
      <thead>
        <tr class="bg-gray-200">
          <th class="border px-3 py-2">#</th>
          <th class="border px-3 py-2">Compte</th>
          <th class="border px-3 py-2">Centre</th>
          <th class="border px-3 py-2">Description</th>
          <th class="border px-3 py-2">Actions</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="aff in affectations" :key="aff.id_affectation">
          <td class="border px-3 py-2">{{ aff.id_affectation }}</td>
          <td class="border px-3 py-2">{{ aff.sous_compte?.Code_sous_compte }} - {{ aff.sous_compte?.Libelle }}</td>
          <td class="border px-3 py-2">{{ aff.centre?.nom }}</td>
          <td class="border px-3 py-2">{{ aff.description }}</td>
          <td class="border px-3 py-2 text-center">
            <button @click="edit(aff)" class="bg-yellow-500 text-white px-2 py-1 rounded">✏️</button>
            <button @click="remove(aff.id_affectation)" class="ml-2 bg-red-600 text-white px-2 py-1 rounded">🗑️</button>
          </td>
        </tr>
      </tbody>
    </table>
  </div>
</template>
