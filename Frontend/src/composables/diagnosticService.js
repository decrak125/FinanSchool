// resources/js/services/diagnosticService.js - VERSION SIMPLIFIÉE
import axios from 'axios';

class DiagnosticService {
    constructor() {
        this.api = axios.create({
            baseURL: 'http://127.0.0.1:8000/api',
            headers: { 'Accept': 'application/json' }
        });
    }
    
    async getDashboardComplet(dateDebut, dateFin) {
        try {
            console.log('📊 Chargement dashboard:', { dateDebut, dateFin });
            
            const response = await this.api.get('/dashboard/complet', {
                params: { date_debut: dateDebut, date_fin: dateFin }
            });
            
            if (!response.data.success) {
                throw new Error('API returned failure');
            }
            
            return this.formaterDashboard(response.data);
            
        } catch (error) {
            console.error('❌ Erreur dashboard:', error);
            throw new Error(`Impossible de charger le dashboard: ${error.message}`);
        }
    }
    
    formaterDashboard(data) {
        const aspects = [];
        let scoreTotal = 0;
        let aspectsValides = 0;
        
        // Traiter chaque aspect
        Object.keys(data.aspects || {}).forEach(aspectKey => {
            const aspectData = data.aspects[aspectKey];
            const aspectFormate = this.formaterAspect(aspectKey, aspectData);
            
            aspects.push(aspectFormate);
            
            if (aspectFormate.score > 0) {
                scoreTotal += aspectFormate.score;
                aspectsValides++;
            }
        });
        
        // Calcul score global
        const scoreGlobal = aspectsValides > 0 ? Math.round(scoreTotal / aspectsValides) : 0;
        
        return {
            scoreGlobal,
            aspects,
            periode: data.periode,
            metadata: data.metadata
        };
    }
    
    formaterAspect(aspectKey, aspectData) {
        if (!aspectData.success) {
            return {
                code: aspectKey,
                nom: this.getNomAspect(aspectKey),
                score: 0,
                niveau: 'error',
                kpis: [],
                diagnostic: 'Données indisponibles'
            };
        }
        
        // Extraire les KPI selon la structure
        const kpis = this.extraireKpis(aspectKey, aspectData);
        const score = this.calculerScoreKpis(kpis);
        
        return {
            code: aspectKey,
            nom: this.getNomAspect(aspectKey),
            score: score,
            niveau: this.getNiveauFromScore(score),
            kpis: kpis,
            diagnostic: this.getDiagnosticAspect(aspectKey, score),
            couleur: this.getCouleurNiveau(this.getNiveauFromScore(score))
        };
    }
    
    extraireKpis(aspectKey, aspectData) {
        const kpis = [];
        
        // Structure pédagogique spéciale
        if (aspectKey === 'pedagogique' && aspectData.indicateurs_pedagogiques) {
            const indicateurs = aspectData.indicateurs_pedagogiques;
            Object.keys(indicateurs).forEach(kpiKey => {
                kpis.push(this.creerKpi(kpiKey, indicateurs[kpiKey]));
            });
            return kpis;
        }
        
        // Structure standard pour autres aspects
        Object.keys(aspectData).forEach(kpiKey => {
            if (kpiKey !== 'success' && kpiKey !== 'error') {
                const kpiData = aspectData[kpiKey];
                if (kpiData && typeof kpiData === 'object' && 'valeur' in kpiData) {
                    kpis.push(this.creerKpi(kpiKey, kpiData));
                }
            }
        });
        
        return kpis;
    }
    
    creerKpi(kpiKey, kpiData) {
        return {
            nom: this.getNomKpi(kpiKey),
            valeur: kpiData.valeur || 0,
            unite: kpiData.unite || '',
            interpretation: kpiData.interpretation || '',
            niveau: (kpiData.niveau_alerte?.libelle || 'inconnu').toLowerCase(),
            couleur: kpiData.niveau_alerte?.couleur || this.getCouleurDefault()
        };
    }
    
    calculerScoreKpis(kpis) {
        if (kpis.length === 0) return 0;
        
        const scores = {
            'excellent': 100, 'bon': 85, 'moyen': 60, 
            'faible': 35, 'mauvais': 10, 'inconnu': 50
        };
        
        const total = kpis.reduce((sum, kpi) => {
            return sum + (scores[kpi.niveau] || 50);
        }, 0);
        
        return Math.round(total / kpis.length);
    }
    
    getNomAspect(code) {
        const noms = {
            'rentabilite': 'Rentabilité',
            'solvabilite': 'Solvabilité',
            'liquidite': 'Liquidité',
            'pedagogique': 'Pédagogique'
        };
        return noms[code] || code;
    }
    
    getNomKpi(code) {
        const noms = {
            // Rentabilité
            'marge_brute': 'Marge Brute',
            'marge_nette': 'Marge Nette',
            'roe': 'ROE',
            'roa': 'ROA',
            
            // Solvabilité
            'autonomie_financiere': 'Autonomie Financière',
            'ratio_endettement': 'Ratio d\'Endettement',
            'capacite_remboursement': 'Capacité Remboursement',
            
            // Liquidité
            'tresorerie_nette': 'Trésorerie Nette',
            'ratio_liquidite_generale': 'Ratio Liquidité',
            'bfr': 'BFR',
            
            // Pédagogique
            'cout_fonctionnement_par_eleve': 'Coût par Élève',
            'chiffre_affaires_par_eleve': 'CA par Élève',
            'part_masse_salariale_enseignante': 'Part Masse Salariale',
            'marge_par_eleve': 'Marge par Élève'
        };
        
        return noms[code] || code.replace(/_/g, ' ').replace(/\b\w/g, l => l.toUpperCase());
    }
    
    getNiveauFromScore(score) {
        if (score >= 80) return 'excellent';
        if (score >= 60) return 'bon';
        if (score >= 40) return 'moyen';
        if (score >= 20) return 'faible';
        return 'critique';
    }
    
    getCouleurNiveau(niveau) {
        const couleurs = {
            'excellent': '#01CC00',
            'bon': '#4CAF50',
            'moyen': '#F89400',
            'faible': '#FF5722',
            'critique': '#FE0000',
            'error': '#9E9E9E'
        };
        return couleurs[niveau] || '#cccccc';
    }
    
    getDiagnosticAspect(aspectKey, score) {
        const diagnostics = {
            'rentabilite': [
                'Excellente rentabilité',
                'Rentabilité satisfaisante',
                'Rentabilité à améliorer',
                'Rentabilité fragile',
                'Rentabilité critique'
            ],
            'solvabilite': [
                'Structure solide',
                'Structure acceptable',
                'Endettement à surveiller',
                'Structure fragile',
                'Risque financier'
            ],
            'liquidite': [
                'Trésorerie excellente',
                'Liquidité satisfaisante',
                'Surveiller échéances',
                'Liquidité tendue',
                'Problèmes paiement'
            ],
            'pedagogique': [
                'Performance excellente',
                'Performance satisfaisante',
                'Coûts à optimiser',
                'Performance fragile',
                'Modèle à revoir'
            ]
        };
        
        const niveauIndex = Math.floor((100 - score) / 20);
        const index = Math.min(niveauIndex, 4);
        
        return diagnostics[aspectKey] ? diagnostics[aspectKey][index] : `Score: ${score}`;
    }
    
    getCouleurDefault() {
        return '#cccccc';
    }
    
    getCouleurScore(score) {
        return this.getCouleurNiveau(this.getNiveauFromScore(score));
    }
}

export default new DiagnosticService();