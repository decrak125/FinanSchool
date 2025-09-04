<template>
  <div class="produits">
    <h2>🛒 Liste des Produits</h2>

    <table>
      <thead>
        <tr>
          <th>ID</th>
          <th>Nom</th>
          <th>Prix</th>
        </tr>
      </thead>
      <tbody>
        <tr v-for="produit in produits" :key="produit.id">
          <td>{{ produit.id }}</td>
          <td>{{ produit.name }}</td>
          <td>{{ produit.price }} €</td>
        </tr>
      </tbody>
    </table>
  </div>
</template>

<script>
import axios from "axios";

export default {
  data() {
    return {
      produits: []
    };
  },
  mounted() {
    axios.get("http://127.0.0.1:8000/api/produits")
      .then(res => this.produits = res.data)
      .catch(err => console.error(err));
  }
};
</script>

<style scoped>
.produits {
  background: white;
  padding: 2rem;
  border-radius: 12px;
  box-shadow: 0 2px 8px rgba(0, 0, 0, 0.1);
}

h2 {
  margin-bottom: 1.5rem;
  color: #35495e;
  text-align: center;
}

table {
  width: 100%;
  border-collapse: collapse;
  background: white;
}

th, td {
  border: 1px solid #ddd;
  padding: 0.8rem;
  text-align: left;
}

th {
  background: #42b883;
  color: white;
}

tr:nth-child(even) {
  background: #f9f9f9;
}

tr:hover {
  background: #e8f5e9;
}
</style>
