
  <script setup>
    const props = defineProps({
    reference : String,
    methode: Function,
    fileName: Object,
    });

  </script>
  <template>
    <div class="file-upload">
      <!-- Input masqué -->
      <input 
        type="file" 
        id="fileInput" 
        @change="props.methode"
        v-bind:ref="reference"
        hidden
      />
      <!-- Texte affiché -->
        <i class="bi bi-upload"></i>
      <span v-if="fileName" class="file-name">{{ fileName.name }}</span>
      <span v-else class="file-name text-gray-400">CSV, Excel</span>
      <!-- Bouton personnalisé -->
      <label for="fileInput" class="custom-file-label">
        Parcourir
      </label>
      
    </div>
  </template>
  
  <style lang="scss" scoped>
  .file-upload{
    background-color: $light;
    display: flex;
    height: 189px;
    padding: 10px;
    flex-direction: column;
    justify-content: center;
    align-items: center;
    gap: 10px;
    align-self: stretch;
    border-radius: $radius-pm;
    border: 1px dashed #515151;
  }
  .custom-file-label {
    cursor: pointer;
      @include bouton($primary, $light, $radius-pm, $stara-medium);
      transition: all 0.5s ease-in-out;
  }

  .file-name {
    color: $dark;
    font-family: Stara;
    font-size: 16px;
    font-style: normal;
    font-weight: 500;
    line-height: normal;
  }
  </style>
  