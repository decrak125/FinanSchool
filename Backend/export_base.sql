--
-- PostgreSQL database dump
--

-- Dumped from database version 16.0
-- Dumped by pg_dump version 16.0

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: rafraichir_vues_temporelles(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION public.rafraichir_vues_temporelles() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_analyse_mensuelle;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_analyse_trimestrielle;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_comparaison_annuelle;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_evolution_12_mois;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_comparaison_cout_profit;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_stats_globales_temporelles;
END;
$$;


ALTER FUNCTION public.rafraichir_vues_temporelles() OWNER TO postgres;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: affectationanalytique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.affectationanalytique (
    id_affectation bigint NOT NULL,
    description character varying(255),
    id_centre bigint NOT NULL,
    "Id_Sous_compte" bigint NOT NULL,
    taux numeric(5,2) DEFAULT '100'::numeric NOT NULL,
    id_type integer NOT NULL,
    id_code bigint
);


ALTER TABLE public.affectationanalytique OWNER TO postgres;

--
-- Name: COLUMN affectationanalytique.taux; Type: COMMENT; Schema: public; Owner: postgres
--

COMMENT ON COLUMN public.affectationanalytique.taux IS 'Pourcentage du coût affecté (0-100)';


--
-- Name: affectationanalytique_id_affectation_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.affectationanalytique_id_affectation_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.affectationanalytique_id_affectation_seq OWNER TO postgres;

--
-- Name: affectationanalytique_id_affectation_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.affectationanalytique_id_affectation_seq OWNED BY public.affectationanalytique.id_affectation;


--
-- Name: axesanalytique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.axesanalytique (
    id_axe bigint NOT NULL,
    axe character varying(100) NOT NULL,
    description character varying(255)
);


ALTER TABLE public.axesanalytique OWNER TO postgres;

--
-- Name: axesanalytique_id_axe_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.axesanalytique_id_axe_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.axesanalytique_id_axe_seq OWNER TO postgres;

--
-- Name: axesanalytique_id_axe_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.axesanalytique_id_axe_seq OWNED BY public.axesanalytique.id_axe;


--
-- Name: cache; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache (
    key character varying(255) NOT NULL,
    value text NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache OWNER TO postgres;

--
-- Name: cache_locks; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.cache_locks (
    key character varying(255) NOT NULL,
    owner character varying(255) NOT NULL,
    expiration integer NOT NULL
);


ALTER TABLE public.cache_locks OWNER TO postgres;

--
-- Name: categorie_fonctionelles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.categorie_fonctionelles (
    id_categorie_fonctionelle bigint NOT NULL,
    code character varying(50) NOT NULL,
    libelle character varying(255) NOT NULL,
    calcul_auto boolean DEFAULT true NOT NULL,
    id_duree bigint NOT NULL,
    id_fonction_economique bigint NOT NULL,
    id_nature_comptable bigint NOT NULL,
    id_type_categorie bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.categorie_fonctionelles OWNER TO postgres;

--
-- Name: categorie_fonctionelles_id_categorie_fonctionelle_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.categorie_fonctionelles_id_categorie_fonctionelle_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.categorie_fonctionelles_id_categorie_fonctionelle_seq OWNER TO postgres;

--
-- Name: categorie_fonctionelles_id_categorie_fonctionelle_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.categorie_fonctionelles_id_categorie_fonctionelle_seq OWNED BY public.categorie_fonctionelles.id_categorie_fonctionelle;


--
-- Name: centreanalytique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.centreanalytique (
    id_centre bigint NOT NULL,
    nom character varying(100) NOT NULL,
    description character varying(255),
    id_axe bigint NOT NULL
);


ALTER TABLE public.centreanalytique OWNER TO postgres;

--
-- Name: centreanalytique_id_centre_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.centreanalytique_id_centre_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.centreanalytique_id_centre_seq OWNER TO postgres;

--
-- Name: centreanalytique_id_centre_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.centreanalytique_id_centre_seq OWNED BY public.centreanalytique.id_centre;


--
-- Name: chat_messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.chat_messages (
    id bigint NOT NULL,
    message text NOT NULL,
    response text,
    session_id character varying(255) NOT NULL,
    user_id bigint,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.chat_messages OWNER TO postgres;

--
-- Name: chat_messages_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.chat_messages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.chat_messages_id_seq OWNER TO postgres;

--
-- Name: chat_messages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.chat_messages_id_seq OWNED BY public.chat_messages.id;


--
-- Name: classes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.classes (
    "Id_Classe" bigint NOT NULL,
    "Code" character varying(1) NOT NULL,
    "Libelle" character varying(255) NOT NULL
);


ALTER TABLE public.classes OWNER TO postgres;

--
-- Name: classes_Id_Classe_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."classes_Id_Classe_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."classes_Id_Classe_seq" OWNER TO postgres;

--
-- Name: classes_Id_Classe_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."classes_Id_Classe_seq" OWNED BY public.classes."Id_Classe";


--
-- Name: code_analytique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.code_analytique (
    id_code bigint NOT NULL,
    code character varying(10) NOT NULL,
    libelle character varying(150) NOT NULL,
    plage_de_extension character varying(20)
);


ALTER TABLE public.code_analytique OWNER TO postgres;

--
-- Name: code_analytique_id_code_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.code_analytique_id_code_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.code_analytique_id_code_seq OWNER TO postgres;

--
-- Name: code_analytique_id_code_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.code_analytique_id_code_seq OWNED BY public.code_analytique.id_code;


--
-- Name: compte_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.compte_categories (
    id_compte_categorie bigint NOT NULL,
    poids numeric(15,2) DEFAULT '1'::numeric NOT NULL,
    date_debut date NOT NULL,
    date_fin date,
    actif boolean,
    id_sous_compte bigint NOT NULL,
    id_categorie_fonctionelle bigint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.compte_categories OWNER TO postgres;

--
-- Name: compte_categories_id_compte_categorie_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.compte_categories_id_compte_categorie_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.compte_categories_id_compte_categorie_seq OWNER TO postgres;

--
-- Name: compte_categories_id_compte_categorie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.compte_categories_id_compte_categorie_seq OWNED BY public.compte_categories.id_compte_categorie;


--
-- Name: comptes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.comptes (
    "Id_Compte" bigint NOT NULL,
    "Code_compte" character varying(3) NOT NULL,
    "Libelle" character varying(255) NOT NULL,
    "Id_Rubrique" bigint NOT NULL
);


ALTER TABLE public.comptes OWNER TO postgres;

--
-- Name: comptes_Id_Compte_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."comptes_Id_Compte_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."comptes_Id_Compte_seq" OWNER TO postgres;

--
-- Name: comptes_Id_Compte_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."comptes_Id_Compte_seq" OWNED BY public.comptes."Id_Compte";


--
-- Name: devises; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.devises (
    "Id_Devise" bigint NOT NULL,
    "Libelle" character varying(100) NOT NULL,
    "Code" character varying(10) NOT NULL,
    "Sigle" character varying(10) NOT NULL
);


ALTER TABLE public.devises OWNER TO postgres;

--
-- Name: devises_Id_Devise_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."devises_Id_Devise_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."devises_Id_Devise_seq" OWNER TO postgres;

--
-- Name: devises_Id_Devise_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."devises_Id_Devise_seq" OWNED BY public.devises."Id_Devise";


--
-- Name: durees; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.durees (
    id_duree bigint NOT NULL,
    code character varying(50) NOT NULL,
    libelle character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.durees OWNER TO postgres;

--
-- Name: durees_id_duree_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.durees_id_duree_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.durees_id_duree_seq OWNER TO postgres;

--
-- Name: durees_id_duree_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.durees_id_duree_seq OWNED BY public.durees.id_duree;


--
-- Name: email_verifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.email_verifications (
    id bigint NOT NULL,
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.email_verifications OWNER TO postgres;

--
-- Name: email_verifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.email_verifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.email_verifications_id_seq OWNER TO postgres;

--
-- Name: email_verifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.email_verifications_id_seq OWNED BY public.email_verifications.id;


--
-- Name: errors; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.errors (
    id bigint NOT NULL,
    message character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.errors OWNER TO postgres;

--
-- Name: errors_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.errors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.errors_id_seq OWNER TO postgres;

--
-- Name: errors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.errors_id_seq OWNED BY public.errors.id;


--
-- Name: evenements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.evenements (
    id bigint NOT NULL,
    type_evenement_id bigint NOT NULL,
    donnees_evenement json NOT NULL
);


ALTER TABLE public.evenements OWNER TO postgres;

--
-- Name: evenements_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.evenements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.evenements_id_seq OWNER TO postgres;

--
-- Name: evenements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.evenements_id_seq OWNED BY public.evenements.id;


--
-- Name: exercice_comptable; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.exercice_comptable (
    "Id_Exercice_comptable" bigint NOT NULL,
    "Date_debut" date NOT NULL,
    "Date_fin" date NOT NULL,
    "Statut" character varying(255) DEFAULT 'OUVERT'::character varying NOT NULL,
    "Annee_fiscale" smallint NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT chk_annee_fiscale CHECK ((("Annee_fiscale" >= 2000) AND ("Annee_fiscale" <= 2100))),
    CONSTRAINT chk_dates CHECK (("Date_fin" > "Date_debut")),
    CONSTRAINT "exercice_comptable_Statut_check" CHECK ((("Statut")::text = ANY ((ARRAY['OUVERT'::character varying, 'CLOTURE'::character varying, 'PROVISOIRE'::character varying])::text[])))
);


ALTER TABLE public.exercice_comptable OWNER TO postgres;

--
-- Name: exercice_comptable_Id_Exercice_comptable_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."exercice_comptable_Id_Exercice_comptable_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."exercice_comptable_Id_Exercice_comptable_seq" OWNER TO postgres;

--
-- Name: exercice_comptable_Id_Exercice_comptable_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."exercice_comptable_Id_Exercice_comptable_seq" OWNED BY public.exercice_comptable."Id_Exercice_comptable";


--
-- Name: failed_jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.failed_jobs (
    id bigint NOT NULL,
    uuid character varying(255) NOT NULL,
    connection text NOT NULL,
    queue text NOT NULL,
    payload text NOT NULL,
    exception text NOT NULL,
    failed_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


ALTER TABLE public.failed_jobs OWNER TO postgres;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.failed_jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.failed_jobs_id_seq OWNER TO postgres;

--
-- Name: failed_jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.failed_jobs_id_seq OWNED BY public.failed_jobs.id;


--
-- Name: fonction_economiques; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.fonction_economiques (
    id_fonction_economique bigint NOT NULL,
    code character varying(255) NOT NULL,
    libelle character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.fonction_economiques OWNER TO postgres;

--
-- Name: fonction_economiques_id_fonction_economique_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.fonction_economiques_id_fonction_economique_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.fonction_economiques_id_fonction_economique_seq OWNER TO postgres;

--
-- Name: fonction_economiques_id_fonction_economique_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.fonction_economiques_id_fonction_economique_seq OWNED BY public.fonction_economiques.id_fonction_economique;


--
-- Name: immobilisations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.immobilisations (
    id bigint NOT NULL,
    libelle character varying(255) NOT NULL,
    "Id_Sous_compte" bigint NOT NULL,
    taux_amortissement_id bigint NOT NULL,
    valeur_brute numeric(19,2) NOT NULL,
    date_acquisition date NOT NULL,
    date_debut_utilisation date,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.immobilisations OWNER TO postgres;

--
-- Name: immobilisations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.immobilisations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.immobilisations_id_seq OWNER TO postgres;

--
-- Name: immobilisations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.immobilisations_id_seq OWNED BY public.immobilisations.id;


--
-- Name: import_histories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.import_histories (
    id bigint NOT NULL,
    nom_fichier character varying(255) NOT NULL,
    imported_at timestamp(0) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    imported_by bigint,
    nombre_mouvements integer DEFAULT 0 NOT NULL,
    nombre_lignes integer DEFAULT 0 NOT NULL,
    statut character varying(255) NOT NULL,
    erreur text,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT import_histories_statut_check CHECK (((statut)::text = ANY ((ARRAY['réussi'::character varying, 'échec'::character varying])::text[])))
);


ALTER TABLE public.import_histories OWNER TO postgres;

--
-- Name: import_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.import_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.import_histories_id_seq OWNER TO postgres;

--
-- Name: import_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.import_histories_id_seq OWNED BY public.import_histories.id;


--
-- Name: indicateurs_analytique; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.indicateurs_analytique (
    id_indicateur_analytique bigint NOT NULL,
    libelle character varying(255) NOT NULL,
    description text NOT NULL,
    formule text NOT NULL
);


ALTER TABLE public.indicateurs_analytique OWNER TO postgres;

--
-- Name: indicateurs_analytique_id_indicateur_analytique_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.indicateurs_analytique_id_indicateur_analytique_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.indicateurs_analytique_id_indicateur_analytique_seq OWNER TO postgres;

--
-- Name: indicateurs_analytique_id_indicateur_analytique_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.indicateurs_analytique_id_indicateur_analytique_seq OWNED BY public.indicateurs_analytique.id_indicateur_analytique;


--
-- Name: interpretation_indicateur; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.interpretation_indicateur (
    id_interpretation_indicateur bigint NOT NULL,
    id_indicateur_analytique bigint NOT NULL,
    valeur numeric(10,2) NOT NULL,
    interpretation text NOT NULL,
    id_niveau_alerte bigint NOT NULL
);


ALTER TABLE public.interpretation_indicateur OWNER TO postgres;

--
-- Name: interpretation_indicateur_id_interpretation_indicateur_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.interpretation_indicateur_id_interpretation_indicateur_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.interpretation_indicateur_id_interpretation_indicateur_seq OWNER TO postgres;

--
-- Name: interpretation_indicateur_id_interpretation_indicateur_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.interpretation_indicateur_id_interpretation_indicateur_seq OWNED BY public.interpretation_indicateur.id_interpretation_indicateur;


--
-- Name: intervalle_comptes_categorie; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.intervalle_comptes_categorie (
    id integer NOT NULL,
    compte_debut character varying(10),
    compte_fin character varying(10),
    id_categorie_fonctionelle integer
);


ALTER TABLE public.intervalle_comptes_categorie OWNER TO postgres;

--
-- Name: intervalle_comptes_categorie_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.intervalle_comptes_categorie_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.intervalle_comptes_categorie_id_seq OWNER TO postgres;

--
-- Name: intervalle_comptes_categorie_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.intervalle_comptes_categorie_id_seq OWNED BY public.intervalle_comptes_categorie.id;


--
-- Name: job_batches; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.job_batches (
    id character varying(255) NOT NULL,
    name character varying(255) NOT NULL,
    total_jobs integer NOT NULL,
    pending_jobs integer NOT NULL,
    failed_jobs integer NOT NULL,
    failed_job_ids text NOT NULL,
    options text,
    cancelled_at integer,
    created_at integer NOT NULL,
    finished_at integer
);


ALTER TABLE public.job_batches OWNER TO postgres;

--
-- Name: jobs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.jobs (
    id bigint NOT NULL,
    queue character varying(255) NOT NULL,
    payload text NOT NULL,
    attempts smallint NOT NULL,
    reserved_at integer,
    available_at integer NOT NULL,
    created_at integer NOT NULL
);


ALTER TABLE public.jobs OWNER TO postgres;

--
-- Name: jobs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.jobs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.jobs_id_seq OWNER TO postgres;

--
-- Name: jobs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.jobs_id_seq OWNED BY public.jobs.id;


--
-- Name: journals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.journals (
    "Id_Journal" bigint NOT NULL,
    "Code" character varying(50) NOT NULL,
    "Libelle" character varying(50) NOT NULL,
    "Id_Type_Journal" bigint NOT NULL,
    "Id_Sous_compte" bigint
);


ALTER TABLE public.journals OWNER TO postgres;

--
-- Name: journals_Id_Journal_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."journals_Id_Journal_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."journals_Id_Journal_seq" OWNER TO postgres;

--
-- Name: journals_Id_Journal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."journals_Id_Journal_seq" OWNED BY public.journals."Id_Journal";


--
-- Name: ligne_ecritures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.ligne_ecritures (
    "Id_Ligne_ecriture" bigint NOT NULL,
    "Libelle" character varying(255) NOT NULL,
    "Debit" numeric(15,2) NOT NULL,
    "Credit" numeric(15,2) NOT NULL,
    "Reference" character varying(50),
    "Quantite" integer,
    "Id_Mode_paiement" bigint,
    "Id_Mouvement_ecriture" bigint NOT NULL,
    "Id_Journal" bigint NOT NULL,
    "Id_Sous_compte" bigint NOT NULL,
    statut character varying(255) DEFAULT 'brouillon'::character varying NOT NULL,
    date_validation timestamp(0) without time zone,
    valide_par bigint,
    CONSTRAINT ligne_ecritures_statut_check CHECK (((statut)::text = ANY ((ARRAY['brouillon'::character varying, 'valide'::character varying, 'annule'::character varying])::text[])))
);


ALTER TABLE public.ligne_ecritures OWNER TO postgres;

--
-- Name: ligne_ecritures_Id_Ligne_ecriture_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."ligne_ecritures_Id_Ligne_ecriture_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."ligne_ecritures_Id_Ligne_ecriture_seq" OWNER TO postgres;

--
-- Name: ligne_ecritures_Id_Ligne_ecriture_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."ligne_ecritures_Id_Ligne_ecriture_seq" OWNED BY public.ligne_ecritures."Id_Ligne_ecriture";


--
-- Name: migrations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.migrations (
    id integer NOT NULL,
    migration character varying(255) NOT NULL,
    batch integer NOT NULL
);


ALTER TABLE public.migrations OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.migrations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.migrations_id_seq OWNER TO postgres;

--
-- Name: migrations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.migrations_id_seq OWNED BY public.migrations.id;


--
-- Name: mode_paiements; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mode_paiements (
    "Id_Mode_paiement" bigint NOT NULL,
    "Libelle" character varying(50) NOT NULL,
    "Abr" character varying(50) NOT NULL
);


ALTER TABLE public.mode_paiements OWNER TO postgres;

--
-- Name: mode_paiements_Id_Mode_paiement_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."mode_paiements_Id_Mode_paiement_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."mode_paiements_Id_Mode_paiement_seq" OWNER TO postgres;

--
-- Name: mode_paiements_Id_Mode_paiement_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."mode_paiements_Id_Mode_paiement_seq" OWNED BY public.mode_paiements."Id_Mode_paiement";


--
-- Name: mouvement_ecritures; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.mouvement_ecritures (
    "Id_Mouvement_ecriture" bigint NOT NULL,
    "Date_mouvement" date NOT NULL,
    "Numero_piece" character varying(50),
    "Id_Journal" bigint NOT NULL
);


ALTER TABLE public.mouvement_ecritures OWNER TO postgres;

--
-- Name: mouvement_ecritures_Id_Mouvement_ecriture_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."mouvement_ecritures_Id_Mouvement_ecriture_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."mouvement_ecritures_Id_Mouvement_ecriture_seq" OWNER TO postgres;

--
-- Name: mouvement_ecritures_Id_Mouvement_ecriture_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."mouvement_ecritures_Id_Mouvement_ecriture_seq" OWNED BY public.mouvement_ecritures."Id_Mouvement_ecriture";


--
-- Name: mv_analyse_mensuelle; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_analyse_mensuelle AS
 SELECT EXTRACT(month FROM me."Date_mouvement") AS mois,
    to_char((me."Date_mouvement")::timestamp with time zone, 'Month'::text) AS nom_mois,
    EXTRACT(year FROM me."Date_mouvement") AS annee,
    ca.id_centre,
    ca.nom AS centre,
    aa.id_type,
    abs(sum(((le."Debit" - le."Credit") * (aa.taux / 100.0)))) AS montant_ventile,
    abs(sum((le."Debit" - le."Credit"))) AS montant_brut,
    count(DISTINCT le."Id_Sous_compte") AS nombre_sous_comptes,
    now() AS date_mise_a_jour
   FROM (((public.ligne_ecritures le
     JOIN public.affectationanalytique aa ON ((le."Id_Sous_compte" = aa."Id_Sous_compte")))
     JOIN public.centreanalytique ca ON ((aa.id_centre = ca.id_centre)))
     JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
  GROUP BY (EXTRACT(month FROM me."Date_mouvement")), (to_char((me."Date_mouvement")::timestamp with time zone, 'Month'::text)), (EXTRACT(year FROM me."Date_mouvement")), ca.id_centre, ca.nom, aa.id_type
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_analyse_mensuelle OWNER TO postgres;

--
-- Name: mv_analyse_trimestrielle; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_analyse_trimestrielle AS
 SELECT EXTRACT(quarter FROM me."Date_mouvement") AS trimestre,
    concat('T', EXTRACT(quarter FROM me."Date_mouvement")) AS nom_trimestre,
    EXTRACT(year FROM me."Date_mouvement") AS annee,
    ca.id_centre,
    ca.nom AS centre,
    aa.id_type,
    abs(sum(((le."Debit" - le."Credit") * (aa.taux / 100.0)))) AS montant_ventile,
    abs(sum((le."Debit" - le."Credit"))) AS montant_brut,
    count(DISTINCT le."Id_Sous_compte") AS nombre_sous_comptes,
    count(DISTINCT EXTRACT(month FROM me."Date_mouvement")) AS mois_actifs,
    now() AS date_mise_a_jour
   FROM (((public.ligne_ecritures le
     JOIN public.affectationanalytique aa ON ((le."Id_Sous_compte" = aa."Id_Sous_compte")))
     JOIN public.centreanalytique ca ON ((aa.id_centre = ca.id_centre)))
     JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
  GROUP BY (EXTRACT(quarter FROM me."Date_mouvement")), (EXTRACT(year FROM me."Date_mouvement")), ca.id_centre, ca.nom, aa.id_type
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_analyse_trimestrielle OWNER TO postgres;

--
-- Name: mv_comparaison_annuelle; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_comparaison_annuelle AS
 SELECT EXTRACT(year FROM me."Date_mouvement") AS annee,
    ca.id_centre,
    ca.nom AS centre,
    aa.id_type,
    abs(sum(((le."Debit" - le."Credit") * (aa.taux / 100.0)))) AS montant_ventile,
    abs(sum((le."Debit" - le."Credit"))) AS montant_brut,
    count(DISTINCT le."Id_Sous_compte") AS nombre_sous_comptes,
    count(DISTINCT EXTRACT(month FROM me."Date_mouvement")) AS mois_actifs,
    now() AS date_mise_a_jour
   FROM (((public.ligne_ecritures le
     JOIN public.affectationanalytique aa ON ((le."Id_Sous_compte" = aa."Id_Sous_compte")))
     JOIN public.centreanalytique ca ON ((aa.id_centre = ca.id_centre)))
     JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
  GROUP BY (EXTRACT(year FROM me."Date_mouvement")), ca.id_centre, ca.nom, aa.id_type
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_comparaison_annuelle OWNER TO postgres;

--
-- Name: mv_comparaison_cout_profit; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_comparaison_cout_profit AS
 SELECT EXTRACT(year FROM me."Date_mouvement") AS annee,
    EXTRACT(month FROM me."Date_mouvement") AS mois,
    to_char((me."Date_mouvement")::timestamp with time zone, 'Month YYYY'::text) AS nom_periode,
    aa.id_type,
    sum(
        CASE
            WHEN (le."Debit" > (0)::numeric) THEN (le."Debit" * (aa.taux / 100.0))
            ELSE (0)::numeric
        END) AS total_couts_ventiles,
    sum(
        CASE
            WHEN (le."Debit" > (0)::numeric) THEN le."Debit"
            ELSE (0)::numeric
        END) AS total_couts_bruts,
    sum(
        CASE
            WHEN (le."Credit" > (0)::numeric) THEN (le."Credit" * (aa.taux / 100.0))
            ELSE (0)::numeric
        END) AS total_profits_ventiles,
    sum(
        CASE
            WHEN (le."Credit" > (0)::numeric) THEN le."Credit"
            ELSE (0)::numeric
        END) AS total_profits_bruts,
    (sum(
        CASE
            WHEN (le."Credit" > (0)::numeric) THEN (le."Credit" * (aa.taux / 100.0))
            ELSE (0)::numeric
        END) - sum(
        CASE
            WHEN (le."Debit" > (0)::numeric) THEN (le."Debit" * (aa.taux / 100.0))
            ELSE (0)::numeric
        END)) AS solde_net_ventile,
    (sum(
        CASE
            WHEN (le."Credit" > (0)::numeric) THEN le."Credit"
            ELSE (0)::numeric
        END) - sum(
        CASE
            WHEN (le."Debit" > (0)::numeric) THEN le."Debit"
            ELSE (0)::numeric
        END)) AS solde_net_brut,
        CASE
            WHEN (sum(
            CASE
                WHEN (le."Debit" > (0)::numeric) THEN (le."Debit" * (aa.taux / 100.0))
                ELSE (0)::numeric
            END) > (0)::numeric) THEN (((sum(
            CASE
                WHEN (le."Credit" > (0)::numeric) THEN (le."Credit" * (aa.taux / 100.0))
                ELSE (0)::numeric
            END) - sum(
            CASE
                WHEN (le."Debit" > (0)::numeric) THEN (le."Debit" * (aa.taux / 100.0))
                ELSE (0)::numeric
            END)) / sum(
            CASE
                WHEN (le."Debit" > (0)::numeric) THEN (le."Debit" * (aa.taux / 100.0))
                ELSE (0)::numeric
            END)) * (100)::numeric)
            ELSE (0)::numeric
        END AS marge_nette_percent,
    count(DISTINCT le."Id_Sous_compte") AS nombre_sous_comptes,
    count(DISTINCT ca.id_centre) AS nombre_centres,
    now() AS date_mise_a_jour
   FROM (((public.ligne_ecritures le
     JOIN public.affectationanalytique aa ON ((le."Id_Sous_compte" = aa."Id_Sous_compte")))
     JOIN public.centreanalytique ca ON ((aa.id_centre = ca.id_centre)))
     JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
  GROUP BY (EXTRACT(year FROM me."Date_mouvement")), (EXTRACT(month FROM me."Date_mouvement")), (to_char((me."Date_mouvement")::timestamp with time zone, 'Month YYYY'::text)), aa.id_type
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_comparaison_cout_profit OWNER TO postgres;

--
-- Name: mv_evolution_12_mois; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_evolution_12_mois AS
 SELECT date_trunc('month'::text, (me."Date_mouvement")::timestamp with time zone) AS mois,
    to_char((me."Date_mouvement")::timestamp with time zone, 'YYYY-MM'::text) AS periode,
    to_char((me."Date_mouvement")::timestamp with time zone, 'Month YYYY'::text) AS nom_periode,
    ca.id_centre,
    ca.nom AS centre,
    aa.id_type,
    abs(sum(((le."Debit" - le."Credit") * (aa.taux / 100.0)))) AS montant_ventile,
    abs(sum((le."Debit" - le."Credit"))) AS montant_brut,
    count(DISTINCT le."Id_Sous_compte") AS nombre_sous_comptes,
    now() AS date_mise_a_jour
   FROM (((public.ligne_ecritures le
     JOIN public.affectationanalytique aa ON ((le."Id_Sous_compte" = aa."Id_Sous_compte")))
     JOIN public.centreanalytique ca ON ((aa.id_centre = ca.id_centre)))
     JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
  WHERE ((me."Date_mouvement" >= (CURRENT_DATE - '1 year'::interval)) AND (me."Date_mouvement" <= CURRENT_DATE))
  GROUP BY (date_trunc('month'::text, (me."Date_mouvement")::timestamp with time zone)), (to_char((me."Date_mouvement")::timestamp with time zone, 'YYYY-MM'::text)), (to_char((me."Date_mouvement")::timestamp with time zone, 'Month YYYY'::text)), ca.id_centre, ca.nom, aa.id_type
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_evolution_12_mois OWNER TO postgres;

--
-- Name: mv_stats_globales_temporelles; Type: MATERIALIZED VIEW; Schema: public; Owner: postgres
--

CREATE MATERIALIZED VIEW public.mv_stats_globales_temporelles AS
 SELECT row_number() OVER () AS id_unique,
    type_analyse,
    annee,
    trimestre,
    annee_comparaison,
    nombre_centres,
    nombre_periodes,
    total_ventile,
    total_brut,
    date_mise_a_jour
   FROM ( SELECT 'mensuelle'::text AS type_analyse,
            EXTRACT(year FROM me."Date_mouvement") AS annee,
            NULL::integer AS trimestre,
            NULL::integer AS annee_comparaison,
            count(DISTINCT ca.id_centre) AS nombre_centres,
            count(DISTINCT EXTRACT(month FROM me."Date_mouvement")) AS nombre_periodes,
            sum(abs(((le."Debit" - le."Credit") * (aa.taux / 100.0)))) AS total_ventile,
            sum(abs((le."Debit" - le."Credit"))) AS total_brut,
            now() AS date_mise_a_jour
           FROM (((public.ligne_ecritures le
             JOIN public.affectationanalytique aa ON ((le."Id_Sous_compte" = aa."Id_Sous_compte")))
             JOIN public.centreanalytique ca ON ((aa.id_centre = ca.id_centre)))
             JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
          WHERE (aa.id_type = 1)
          GROUP BY (EXTRACT(year FROM me."Date_mouvement"))
        UNION ALL
         SELECT 'trimestrielle'::text AS type_analyse,
            EXTRACT(year FROM me."Date_mouvement") AS annee,
            EXTRACT(quarter FROM me."Date_mouvement") AS trimestre,
            NULL::integer AS annee_comparaison,
            count(DISTINCT ca.id_centre) AS nombre_centres,
            count(DISTINCT EXTRACT(quarter FROM me."Date_mouvement")) AS nombre_periodes,
            sum(abs(((le."Debit" - le."Credit") * (aa.taux / 100.0)))) AS total_ventile,
            sum(abs((le."Debit" - le."Credit"))) AS total_brut,
            now() AS date_mise_a_jour
           FROM (((public.ligne_ecritures le
             JOIN public.affectationanalytique aa ON ((le."Id_Sous_compte" = aa."Id_Sous_compte")))
             JOIN public.centreanalytique ca ON ((aa.id_centre = ca.id_centre)))
             JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
          WHERE (aa.id_type = 1)
          GROUP BY (EXTRACT(year FROM me."Date_mouvement")), (EXTRACT(quarter FROM me."Date_mouvement"))
        UNION ALL
         SELECT 'annuelle'::text AS type_analyse,
            EXTRACT(year FROM me."Date_mouvement") AS annee,
            NULL::integer AS trimestre,
            NULL::integer AS annee_comparaison,
            count(DISTINCT ca.id_centre) AS nombre_centres,
            1 AS nombre_periodes,
            sum(abs(((le."Debit" - le."Credit") * (aa.taux / 100.0)))) AS total_ventile,
            sum(abs((le."Debit" - le."Credit"))) AS total_brut,
            now() AS date_mise_a_jour
           FROM (((public.ligne_ecritures le
             JOIN public.affectationanalytique aa ON ((le."Id_Sous_compte" = aa."Id_Sous_compte")))
             JOIN public.centreanalytique ca ON ((aa.id_centre = ca.id_centre)))
             JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
          WHERE (aa.id_type = 1)
          GROUP BY (EXTRACT(year FROM me."Date_mouvement"))) subquery
  WITH NO DATA;


ALTER MATERIALIZED VIEW public.mv_stats_globales_temporelles OWNER TO postgres;

--
-- Name: nature_comptables; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.nature_comptables (
    id_nature_comptable bigint NOT NULL,
    code_nature character varying(50) NOT NULL,
    libelle character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.nature_comptables OWNER TO postgres;

--
-- Name: nature_comptables_id_nature_comptable_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.nature_comptables_id_nature_comptable_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.nature_comptables_id_nature_comptable_seq OWNER TO postgres;

--
-- Name: nature_comptables_id_nature_comptable_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.nature_comptables_id_nature_comptable_seq OWNED BY public.nature_comptables.id_nature_comptable;


--
-- Name: niveau_alerte; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.niveau_alerte (
    id_niveau_alerte bigint NOT NULL,
    libelle character varying(100) NOT NULL,
    couleur character varying(20) NOT NULL
);


ALTER TABLE public.niveau_alerte OWNER TO postgres;

--
-- Name: niveau_alerte_id_niveau_alerte_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.niveau_alerte_id_niveau_alerte_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.niveau_alerte_id_niveau_alerte_seq OWNER TO postgres;

--
-- Name: niveau_alerte_id_niveau_alerte_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.niveau_alerte_id_niveau_alerte_seq OWNED BY public.niveau_alerte.id_niveau_alerte;


--
-- Name: niveaux_urgence; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.niveaux_urgence (
    id bigint NOT NULL,
    code character varying(50) NOT NULL,
    nom character varying(100) NOT NULL,
    icone character varying(50) NOT NULL,
    couleur character varying(20) NOT NULL,
    ordre integer NOT NULL
);


ALTER TABLE public.niveaux_urgence OWNER TO postgres;

--
-- Name: niveaux_urgence_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.niveaux_urgence_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.niveaux_urgence_id_seq OWNER TO postgres;

--
-- Name: niveaux_urgence_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.niveaux_urgence_id_seq OWNED BY public.niveaux_urgence.id;


--
-- Name: notifications; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    evenement_id bigint NOT NULL,
    niveau_urgence_id bigint NOT NULL,
    titre character varying(255) NOT NULL,
    message text NOT NULL,
    statut character varying(255) DEFAULT 'non_lu'::character varying NOT NULL,
    lu_a timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone,
    CONSTRAINT notifications_statut_check CHECK (((statut)::text = ANY ((ARRAY['non_lu'::character varying, 'lu'::character varying, 'archive'::character varying])::text[])))
);


ALTER TABLE public.notifications OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.notifications_id_seq OWNER TO postgres;

--
-- Name: notifications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.notifications_id_seq OWNED BY public.notifications.id;


--
-- Name: password_reset_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_reset_tokens (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_reset_tokens OWNER TO postgres;

--
-- Name: password_resets; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.password_resets (
    email character varying(255) NOT NULL,
    token character varying(255) NOT NULL,
    created_at timestamp(0) without time zone
);


ALTER TABLE public.password_resets OWNER TO postgres;

--
-- Name: personal_access_tokens; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.personal_access_tokens (
    id bigint NOT NULL,
    tokenable_type character varying(255) NOT NULL,
    tokenable_id bigint NOT NULL,
    name text NOT NULL,
    token character varying(64) NOT NULL,
    abilities text,
    last_used_at timestamp(0) without time zone,
    expires_at timestamp(0) without time zone,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.personal_access_tokens OWNER TO postgres;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.personal_access_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.personal_access_tokens_id_seq OWNER TO postgres;

--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.personal_access_tokens_id_seq OWNED BY public.personal_access_tokens.id;


--
-- Name: rubriques; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.rubriques (
    "Id_Rubrique" bigint NOT NULL,
    "Code_rubrique" character varying(2) NOT NULL,
    "Libelle" character varying(255) NOT NULL,
    "Id_Classe" bigint NOT NULL
);


ALTER TABLE public.rubriques OWNER TO postgres;

--
-- Name: rubriques_Id_Rubrique_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."rubriques_Id_Rubrique_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."rubriques_Id_Rubrique_seq" OWNER TO postgres;

--
-- Name: rubriques_Id_Rubrique_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."rubriques_Id_Rubrique_seq" OWNED BY public.rubriques."Id_Rubrique";


--
-- Name: sessions; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sessions (
    id character varying(255) NOT NULL,
    user_id bigint,
    ip_address character varying(45),
    user_agent text,
    payload text NOT NULL,
    last_activity integer NOT NULL
);


ALTER TABLE public.sessions OWNER TO postgres;

--
-- Name: sous_comptes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.sous_comptes (
    "Id_Sous_compte" bigint NOT NULL,
    "Code_sous_compte" character varying(6) NOT NULL,
    "Libelle" character varying(255) NOT NULL,
    "Id_Compte" bigint NOT NULL
);


ALTER TABLE public.sous_comptes OWNER TO postgres;

--
-- Name: sous_comptes_Id_Sous_compte_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."sous_comptes_Id_Sous_compte_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."sous_comptes_Id_Sous_compte_seq" OWNER TO postgres;

--
-- Name: sous_comptes_Id_Sous_compte_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."sous_comptes_Id_Sous_compte_seq" OWNED BY public.sous_comptes."Id_Sous_compte";


--
-- Name: taux_amortissement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.taux_amortissement (
    id bigint NOT NULL,
    intitule character varying(255) NOT NULL,
    taux numeric(5,2) NOT NULL,
    duree integer NOT NULL,
    unite_duree character varying(255) DEFAULT 'ans'::character varying NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.taux_amortissement OWNER TO postgres;

--
-- Name: taux_amortissement_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.taux_amortissement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.taux_amortissement_id_seq OWNER TO postgres;

--
-- Name: taux_amortissement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.taux_amortissement_id_seq OWNED BY public.taux_amortissement.id;


--
-- Name: type_categories; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_categories (
    id_type_categorie bigint NOT NULL,
    code_type character varying(50) NOT NULL,
    libelle character varying(255) NOT NULL,
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.type_categories OWNER TO postgres;

--
-- Name: type_categories_id_type_categorie_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.type_categories_id_type_categorie_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.type_categories_id_type_categorie_seq OWNER TO postgres;

--
-- Name: type_categories_id_type_categorie_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.type_categories_id_type_categorie_seq OWNED BY public.type_categories.id_type_categorie;


--
-- Name: type_journals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.type_journals (
    "Id_Type_Journal" bigint NOT NULL,
    "Type" character varying(50) NOT NULL
);


ALTER TABLE public.type_journals OWNER TO postgres;

--
-- Name: type_journals_Id_Type_Journal_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public."type_journals_Id_Type_Journal_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public."type_journals_Id_Type_Journal_seq" OWNER TO postgres;

--
-- Name: type_journals_Id_Type_Journal_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public."type_journals_Id_Type_Journal_seq" OWNED BY public.type_journals."Id_Type_Journal";


--
-- Name: typecentre; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.typecentre (
    id_type bigint NOT NULL,
    code character varying(50) NOT NULL,
    libelle character varying(100) NOT NULL
);


ALTER TABLE public.typecentre OWNER TO postgres;

--
-- Name: typecentre_id_type_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.typecentre_id_type_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.typecentre_id_type_seq OWNER TO postgres;

--
-- Name: typecentre_id_type_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.typecentre_id_type_seq OWNED BY public.typecentre.id_type;


--
-- Name: types_evenement; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.types_evenement (
    id bigint NOT NULL,
    code character varying(50) NOT NULL,
    nom character varying(100) NOT NULL,
    description text,
    est_actif boolean DEFAULT true NOT NULL
);


ALTER TABLE public.types_evenement OWNER TO postgres;

--
-- Name: types_evenement_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.types_evenement_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.types_evenement_id_seq OWNER TO postgres;

--
-- Name: types_evenement_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.types_evenement_id_seq OWNED BY public.types_evenement.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    name character varying(255) NOT NULL,
    email character varying(255) NOT NULL,
    email_verified_at timestamp(0) without time zone,
    password character varying(255) NOT NULL,
    remember_token character varying(100),
    created_at timestamp(0) without time zone,
    updated_at timestamp(0) without time zone
);


ALTER TABLE public.users OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.users_id_seq OWNER TO postgres;

--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: vue_balance_generale; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_balance_generale AS
 SELECT c."Code_compte" AS code_compte,
    c."Libelle" AS libelle_compte,
    sc."Code_sous_compte" AS code_sous_compte,
    sc."Libelle" AS libelle_sous_compte,
    COALESCE(sum(le."Debit"), (0)::numeric) AS total_debit,
    COALESCE(sum(le."Credit"), (0)::numeric) AS total_credit,
    COALESCE((sum(le."Debit") - sum(le."Credit")), (0)::numeric) AS solde_final,
    me."Date_mouvement" AS date_mouvement
   FROM (((public.ligne_ecritures le
     JOIN public.sous_comptes sc ON ((le."Id_Sous_compte" = sc."Id_Sous_compte")))
     JOIN public.comptes c ON ((sc."Id_Compte" = c."Id_Compte")))
     JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
  GROUP BY c."Code_compte", c."Libelle", sc."Code_sous_compte", sc."Libelle", me."Date_mouvement"
  ORDER BY c."Code_compte", sc."Code_sous_compte", me."Date_mouvement";


ALTER VIEW public.vue_balance_generale OWNER TO postgres;

--
-- Name: vue_balance_generales; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_balance_generales AS
 SELECT c."Code_compte" AS code_compte,
    c."Libelle" AS libelle_compte,
    sc."Code_sous_compte" AS code_sous_compte,
    sc."Libelle" AS libelle_sous_compte,
    COALESCE(sum(le."Debit"), (0)::numeric) AS total_debit,
    COALESCE(sum(le."Credit"), (0)::numeric) AS total_credit,
    COALESCE((sum(le."Debit") - sum(le."Credit")), (0)::numeric) AS solde_final
   FROM ((public.ligne_ecritures le
     JOIN public.sous_comptes sc ON ((le."Id_Sous_compte" = sc."Id_Sous_compte")))
     JOIN public.comptes c ON ((sc."Id_Compte" = c."Id_Compte")))
  GROUP BY c."Code_compte", c."Libelle", sc."Code_sous_compte", sc."Libelle"
  ORDER BY c."Code_compte", sc."Code_sous_compte";


ALTER VIEW public.vue_balance_generales OWNER TO postgres;

--
-- Name: vue_grand_livre; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW public.vue_grand_livre AS
 WITH sous_compte_totals AS (
         SELECT sc_1."Id_Sous_compte",
            sum(le_1."Debit") AS total_debit_sous_compte,
            sum(le_1."Credit") AS total_credit_sous_compte,
            (sum(le_1."Debit") - sum(le_1."Credit")) AS solde_final_sous_compte
           FROM (public.ligne_ecritures le_1
             JOIN public.sous_comptes sc_1 ON ((le_1."Id_Sous_compte" = sc_1."Id_Sous_compte")))
          GROUP BY sc_1."Id_Sous_compte"
        ), compte_totals AS (
         SELECT c_1."Id_Compte",
            sum(le_1."Debit") AS total_debit_compte,
            sum(le_1."Credit") AS total_credit_compte,
            (sum(le_1."Debit") - sum(le_1."Credit")) AS solde_final_compte
           FROM ((public.ligne_ecritures le_1
             JOIN public.sous_comptes sc_1 ON ((le_1."Id_Sous_compte" = sc_1."Id_Sous_compte")))
             JOIN public.comptes c_1 ON ((sc_1."Id_Compte" = c_1."Id_Compte")))
          GROUP BY c_1."Id_Compte"
        )
 SELECT c."Code_compte" AS code_compte,
    c."Libelle" AS libelle_compte,
    sc."Code_sous_compte" AS code_sous_compte,
    sc."Libelle" AS libelle_sous_compte,
    me."Date_mouvement" AS date_mouvement,
    me."Numero_piece" AS numero_piece,
    le."Libelle" AS libelle_ecriture,
    le."Debit",
    le."Credit",
    sum((le."Debit" - le."Credit")) OVER (PARTITION BY sc."Id_Sous_compte" ORDER BY me."Date_mouvement", le."Id_Ligne_ecriture") AS solde_progressif,
    sct.solde_final_sous_compte,
    ct.solde_final_compte
   FROM (((((public.ligne_ecritures le
     JOIN public.sous_comptes sc ON ((le."Id_Sous_compte" = sc."Id_Sous_compte")))
     JOIN public.comptes c ON ((sc."Id_Compte" = c."Id_Compte")))
     JOIN public.mouvement_ecritures me ON ((le."Id_Mouvement_ecriture" = me."Id_Mouvement_ecriture")))
     JOIN sous_compte_totals sct ON ((sc."Id_Sous_compte" = sct."Id_Sous_compte")))
     JOIN compte_totals ct ON ((c."Id_Compte" = ct."Id_Compte")))
  ORDER BY c."Code_compte", sc."Code_sous_compte", me."Date_mouvement", le."Id_Ligne_ecriture";


ALTER VIEW public.vue_grand_livre OWNER TO postgres;

--
-- Name: affectationanalytique id_affectation; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affectationanalytique ALTER COLUMN id_affectation SET DEFAULT nextval('public.affectationanalytique_id_affectation_seq'::regclass);


--
-- Name: axesanalytique id_axe; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.axesanalytique ALTER COLUMN id_axe SET DEFAULT nextval('public.axesanalytique_id_axe_seq'::regclass);


--
-- Name: categorie_fonctionelles id_categorie_fonctionelle; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie_fonctionelles ALTER COLUMN id_categorie_fonctionelle SET DEFAULT nextval('public.categorie_fonctionelles_id_categorie_fonctionelle_seq'::regclass);


--
-- Name: centreanalytique id_centre; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.centreanalytique ALTER COLUMN id_centre SET DEFAULT nextval('public.centreanalytique_id_centre_seq'::regclass);


--
-- Name: chat_messages id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages ALTER COLUMN id SET DEFAULT nextval('public.chat_messages_id_seq'::regclass);


--
-- Name: classes Id_Classe; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes ALTER COLUMN "Id_Classe" SET DEFAULT nextval('public."classes_Id_Classe_seq"'::regclass);


--
-- Name: code_analytique id_code; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.code_analytique ALTER COLUMN id_code SET DEFAULT nextval('public.code_analytique_id_code_seq'::regclass);


--
-- Name: compte_categories id_compte_categorie; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compte_categories ALTER COLUMN id_compte_categorie SET DEFAULT nextval('public.compte_categories_id_compte_categorie_seq'::regclass);


--
-- Name: comptes Id_Compte; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comptes ALTER COLUMN "Id_Compte" SET DEFAULT nextval('public."comptes_Id_Compte_seq"'::regclass);


--
-- Name: devises Id_Devise; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devises ALTER COLUMN "Id_Devise" SET DEFAULT nextval('public."devises_Id_Devise_seq"'::regclass);


--
-- Name: durees id_duree; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.durees ALTER COLUMN id_duree SET DEFAULT nextval('public.durees_id_duree_seq'::regclass);


--
-- Name: email_verifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_verifications ALTER COLUMN id SET DEFAULT nextval('public.email_verifications_id_seq'::regclass);


--
-- Name: errors id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.errors ALTER COLUMN id SET DEFAULT nextval('public.errors_id_seq'::regclass);


--
-- Name: evenements id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evenements ALTER COLUMN id SET DEFAULT nextval('public.evenements_id_seq'::regclass);


--
-- Name: exercice_comptable Id_Exercice_comptable; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercice_comptable ALTER COLUMN "Id_Exercice_comptable" SET DEFAULT nextval('public."exercice_comptable_Id_Exercice_comptable_seq"'::regclass);


--
-- Name: failed_jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs ALTER COLUMN id SET DEFAULT nextval('public.failed_jobs_id_seq'::regclass);


--
-- Name: fonction_economiques id_fonction_economique; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fonction_economiques ALTER COLUMN id_fonction_economique SET DEFAULT nextval('public.fonction_economiques_id_fonction_economique_seq'::regclass);


--
-- Name: immobilisations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.immobilisations ALTER COLUMN id SET DEFAULT nextval('public.immobilisations_id_seq'::regclass);


--
-- Name: import_histories id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_histories ALTER COLUMN id SET DEFAULT nextval('public.import_histories_id_seq'::regclass);


--
-- Name: indicateurs_analytique id_indicateur_analytique; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.indicateurs_analytique ALTER COLUMN id_indicateur_analytique SET DEFAULT nextval('public.indicateurs_analytique_id_indicateur_analytique_seq'::regclass);


--
-- Name: interpretation_indicateur id_interpretation_indicateur; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interpretation_indicateur ALTER COLUMN id_interpretation_indicateur SET DEFAULT nextval('public.interpretation_indicateur_id_interpretation_indicateur_seq'::regclass);


--
-- Name: intervalle_comptes_categorie id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intervalle_comptes_categorie ALTER COLUMN id SET DEFAULT nextval('public.intervalle_comptes_categorie_id_seq'::regclass);


--
-- Name: jobs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs ALTER COLUMN id SET DEFAULT nextval('public.jobs_id_seq'::regclass);


--
-- Name: journals Id_Journal; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journals ALTER COLUMN "Id_Journal" SET DEFAULT nextval('public."journals_Id_Journal_seq"'::regclass);


--
-- Name: ligne_ecritures Id_Ligne_ecriture; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ligne_ecritures ALTER COLUMN "Id_Ligne_ecriture" SET DEFAULT nextval('public."ligne_ecritures_Id_Ligne_ecriture_seq"'::regclass);


--
-- Name: migrations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations ALTER COLUMN id SET DEFAULT nextval('public.migrations_id_seq'::regclass);


--
-- Name: mode_paiements Id_Mode_paiement; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mode_paiements ALTER COLUMN "Id_Mode_paiement" SET DEFAULT nextval('public."mode_paiements_Id_Mode_paiement_seq"'::regclass);


--
-- Name: mouvement_ecritures Id_Mouvement_ecriture; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mouvement_ecritures ALTER COLUMN "Id_Mouvement_ecriture" SET DEFAULT nextval('public."mouvement_ecritures_Id_Mouvement_ecriture_seq"'::regclass);


--
-- Name: nature_comptables id_nature_comptable; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nature_comptables ALTER COLUMN id_nature_comptable SET DEFAULT nextval('public.nature_comptables_id_nature_comptable_seq'::regclass);


--
-- Name: niveau_alerte id_niveau_alerte; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.niveau_alerte ALTER COLUMN id_niveau_alerte SET DEFAULT nextval('public.niveau_alerte_id_niveau_alerte_seq'::regclass);


--
-- Name: niveaux_urgence id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.niveaux_urgence ALTER COLUMN id SET DEFAULT nextval('public.niveaux_urgence_id_seq'::regclass);


--
-- Name: notifications id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);


--
-- Name: personal_access_tokens id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens ALTER COLUMN id SET DEFAULT nextval('public.personal_access_tokens_id_seq'::regclass);


--
-- Name: rubriques Id_Rubrique; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rubriques ALTER COLUMN "Id_Rubrique" SET DEFAULT nextval('public."rubriques_Id_Rubrique_seq"'::regclass);


--
-- Name: sous_comptes Id_Sous_compte; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sous_comptes ALTER COLUMN "Id_Sous_compte" SET DEFAULT nextval('public."sous_comptes_Id_Sous_compte_seq"'::regclass);


--
-- Name: taux_amortissement id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taux_amortissement ALTER COLUMN id SET DEFAULT nextval('public.taux_amortissement_id_seq'::regclass);


--
-- Name: type_categories id_type_categorie; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_categories ALTER COLUMN id_type_categorie SET DEFAULT nextval('public.type_categories_id_type_categorie_seq'::regclass);


--
-- Name: type_journals Id_Type_Journal; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_journals ALTER COLUMN "Id_Type_Journal" SET DEFAULT nextval('public."type_journals_Id_Type_Journal_seq"'::regclass);


--
-- Name: typecentre id_type; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typecentre ALTER COLUMN id_type SET DEFAULT nextval('public.typecentre_id_type_seq'::regclass);


--
-- Name: types_evenement id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_evenement ALTER COLUMN id SET DEFAULT nextval('public.types_evenement_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Data for Name: affectationanalytique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.affectationanalytique (id_affectation, description, id_centre, "Id_Sous_compte", taux, id_type, id_code) FROM stdin;
\.


--
-- Data for Name: axesanalytique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.axesanalytique (id_axe, axe, description) FROM stdin;
1	Nature	nature
2	cycle	Analyse par Cycle
3	fonction	Analyse par Fonction
\.


--
-- Data for Name: cache; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cache (key, value, expiration) FROM stdin;
\.


--
-- Data for Name: cache_locks; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.cache_locks (key, owner, expiration) FROM stdin;
\.


--
-- Data for Name: categorie_fonctionelles; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.categorie_fonctionelles (id_categorie_fonctionelle, code, libelle, calcul_auto, id_duree, id_fonction_economique, id_nature_comptable, id_type_categorie, created_at, updated_at) FROM stdin;
1	CA	Chiffre d’affaires	t	1	3	4	2	\N	\N
2	PRODSTOCK	Production stockée	t	1	3	4	2	\N	\N
3	PRODIMMO	Production immobilisée	t	2	3	4	2	\N	\N
4	ACHATCONSOM	Achats consommés	t	1	3	3	2	\N	\N
5	SERVEXT	Services extérieurs et autres consommations	t	1	3	3	2	\N	\N
6	SUBVENT	Subventions d’exploitation	t	1	3	4	2	\N	\N
7	CHPERS	Charges de personnel	t	1	3	3	2	\N	\N
8	CHAREXPL	Charges exploitation spécifique	t	1	3	3	2	\N	\N
9	IMPTAX	Impôts, taxes et versements assimilés	t	1	3	3	2	\N	\N
10	AUTPRODOP	Autres produits opérationnels	t	1	3	4	2	\N	\N
11	AUTCHOP	Autres charges opérationnelles	t	1	3	3	2	\N	\N
12	AMORTPROV	Dotations aux amortissements/provisions/pertes de valeur	t	2	3	3	2	\N	\N
13	REPRISEPROV	Reprise sur provisions et pertes de valeur	t	2	3	4	2	\N	\N
14	PRODFIN	Produits financiers	t	1	1	4	2	\N	\N
15	CHARGEFIN	Charges financières	t	1	1	3	2	\N	\N
16	IMPOT	Impôts exigibles sur resultat	t	1	1	3	2	\N	\N
17	IMPOTDIFF	Impôts différés	t	1	1	3	2	\N	\N
18	PRODEXCEPT	Produits extraordinaires	t	1	5	4	2	\N	\N
19	CHAREXCEPT	Charges extraordinaires	t	1	5	3	2	\N	\N
20	VENTES	Produit des activités ordinaires	t	1	3	4	2	\N	\N
21	COUTVENTE	Coût des ventes	t	1	3	3	2	\N	\N
22	CHARGECOMM	Coûts commerciaux	t	1	3	3	2	\N	\N
23	CHARGEADM	Charges administratives	t	1	3	3	2	\N	\N
24	GOODWILL	Ecart d’acquisition ou goodwill	t	2	2	1	1	\N	\N
25	IMMOINC	Immobilisations incorporelles	t	2	2	1	1	\N	\N
26	IMMOCO	Immobilisations corporelles	t	2	2	1	1	\N	\N
27	IMMOCOURS	Immobilisations en cours	t	2	2	1	1	\N	\N
28	AMORT_IMMOCO	Immobilisations en cours	t	2	2	1	1	\N	\N
29	AMORT_IMMOINC	Amortissement incorporelles	t	2	2	1	1	\N	\N
30	IMMOFIN	Immobilisations financières	t	2	2	1	1	\N	\N
31	TITRSEQ	Titres mis en équivalence	t	2	2	1	1	\N	\N
32	AUTPART	Autres participations et créances rattachées	t	2	1	1	1	\N	\N
33	AUTIMMOFIN	Autres titres immobilisés	t	2	2	1	1	\N	\N
34	PRET	Prêts et autres immobilisations financières	t	2	2	1	1	\N	\N
35	STOCKS	Stocks et en-cours	t	1	3	1	1	\N	\N
36	CREANCES	Créances et emplois assimilés	t	1	3	1	1	\N	\N
37	CLIENTS	Clients et autres débiteurs	t	1	3	1	1	\N	\N
38	IMPT	Impôts actifs	t	1	3	1	1	\N	\N
39	AUTCREANCES	Autres créances et actifs assimilés	t	1	3	1	1	\N	\N
40	TRESO	Trésorerie et équivalents de trésorerie	t	1	4	1	1	\N	\N
41	PLACEMENTS	Placements et autres équivalents de trésorerie	t	1	4	1	1	\N	\N
42	TRESOFONDS	Trésorerie fonds en caisse et dépôts à vue	t	1	4	1	1	\N	\N
43	CAPITAL	Capital émis	t	2	1	5	1	\N	\N
44	PRIME	Primes et réserves consolidées	t	2	1	5	1	\N	\N
45	EVAL	Ecarts d’évaluation	t	2	1	5	1	\N	\N
46	EQUIV	Ecart d’équivalence	t	2	1	5	1	\N	\N
47	RESULT	Résultat net (part du groupe)	t	2	1	5	1	\N	\N
48	AUTCPRO	Autres capitaux propres - Report à nouveau	t	2	1	5	1	\N	\N
49	SUBVINV	Subventions d’investissement	t	2	2	2	1	\N	\N
50	IMPTPASS	Impôts différés	t	2	1	2	1	\N	\N
51	EMPRUNT	Emprunts et dettes financières	t	2	1	2	1	\N	\N
52	PROVNCOUR	Provisions et produits constatés d’avance	t	2	1	2	1	\N	\N
53	DETTECT	Dettes court terme	t	1	1	2	1	\N	\N
54	FOURN	Fournisseurs et comptes rattachés	t	1	3	2	1	\N	\N
55	PROVC	Provisions et produits constatés d’avance passifs courants	t	1	1	2	1	\N	\N
56	AUTDETTE	Autres dettes	t	1	1	2	1	\N	\N
57	DECOUV	Comptes de trésorerie découverts bancaires	t	1	4	2	1	\N	\N
\.


--
-- Data for Name: centreanalytique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.centreanalytique (id_centre, nom, description, id_axe) FROM stdin;
1	cantine	cantine	1
2	Pédagogie	Support pédagogique et matériel	3
3	Administration	Gestion administrative et financière	3
4	Restauration	Service de restauration scolaire	3
5	Transport	Transport scolaire et véhicules	3
6	Infrastructure	Maintenance des bâtiments et équipements	3
7	Activités	Activités parascolaires et événements	3
8	Ventes	Ventes et prestations de services	3
9	Finances	Gestion financière et subventions	3
10	Sécurité	Sécurité et assurances	3
11	RH	Ressources humaines et paie	3
12	Production	Production et immobilisations	3
13	Communication	Publicité et communication	3
\.


--
-- Data for Name: chat_messages; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.chat_messages (id, message, response, session_id, user_id, created_at, updated_at) FROM stdin;
1	Bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	1	\N	2025-11-01 13:29:31	2025-11-01 13:29:32
2	Bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	1	\N	2025-11-01 13:29:59	2025-11-01 13:29:59
3	Bonjour	Bonjour ! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	1	\N	2025-11-01 13:42:51	2025-11-01 13:42:51
4	Bonjour	Bonjour ! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	1	\N	2025-11-01 13:43:29	2025-11-01 13:43:29
5	Bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	1	\N	2025-11-01 13:44:01	2025-11-01 13:44:01
6	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762004985544_0p7hzp6t4	\N	2025-11-01 13:49:50	2025-11-01 13:49:50
7	eleve	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762004985544_0p7hzp6t4	\N	2025-11-01 13:50:05	2025-11-01 13:50:05
8	depense	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762004985544_0p7hzp6t4	\N	2025-11-01 13:51:03	2025-11-01 13:51:03
9	bonjour	Bonjour ! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762007931372_r7n7nhjn1	\N	2025-11-01 14:39:03	2025-11-01 14:39:03
10	eleve	Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762007931372_r7n7nhjn1	\N	2025-11-01 14:39:20	2025-11-01 14:39:20
11	liste des sous comptes	\N	1	\N	2025-11-01 14:45:24	2025-11-01 14:45:24
12	liste des sous comptes	\N	1	\N	2025-11-01 14:46:10	2025-11-01 14:46:10
13	liste des sous comptes	📊 Les sous-comptes disponibles :\n\n1. **101001** - Capital verse par l Etat\n   └─ Compte parent : 101\n\n2. **101002** - Capital apporte par les fondateurs prives\n   └─ Compte parent : 101\n\n3. **106001** - Reserve legale\n   └─ Compte parent : 106\n\n4. **106002** - Autres reserves (fonds scolaires)\n   └─ Compte parent : 106\n\n5. **108001** - Compte du directeur detablissement\n   └─ Compte parent : 108\n\n6. **211001** - Terrains du campus\n   └─ Compte parent : 211\n\n7. **213001** - Constructions - Batiments administratifs\n   └─ Compte parent : 213\n\n8. **213002** - Constructions - Salles de classe\n   └─ Compte parent : 213\n\n9. **213003** - Constructions - Bibliotheque et laboratoires\n   └─ Compte parent : 213\n\n10. **215001** - Materiel informatique\n   └─ Compte parent : 215\n\n11. **215002** - Materiel pedagogique\n   └─ Compte parent : 215\n\n12. **218001** - Mobilier scolaire\n   └─ Compte parent : 218\n\n13. **218002** - Vehicules de transport scolaire\n   └─ Compte parent : 218\n\n14. **321001** - Matiere consommables - produits chimiques labo\n   └─ Compte parent : 321\n\n15. **321002** - Matiere consommables - materiel pedagogique\n   └─ Compte parent : 321\n\n... et 207 autres sous-comptes\nDemandez-moi des détails sur un code spécifique !	1	\N	2025-11-01 14:47:12	2025-11-01 14:47:12
14	statistiques des sous comptes	📈 Statistiques des sous-comptes :\n\n• **Total de sous-comptes** : 222\n• **Comptes disponibles** : 243\n• **Comptes avec sous-comptes** : 122\n• **Moyenne par compte** : 1.82\n	1	\N	2025-11-01 15:04:44	2025-11-01 15:04:44
15	liste sous comptes	📊 Les sous-comptes disponibles :\n\n1. **101001** - Capital verse par l Etat\n   └─ Compte parent : 101\n\n2. **101002** - Capital apporte par les fondateurs prives\n   └─ Compte parent : 101\n\n3. **106001** - Reserve legale\n   └─ Compte parent : 106\n\n4. **106002** - Autres reserves (fonds scolaires)\n   └─ Compte parent : 106\n\n5. **108001** - Compte du directeur detablissement\n   └─ Compte parent : 108\n\n6. **211001** - Terrains du campus\n   └─ Compte parent : 211\n\n7. **213001** - Constructions - Batiments administratifs\n   └─ Compte parent : 213\n\n8. **213002** - Constructions - Salles de classe\n   └─ Compte parent : 213\n\n9. **213003** - Constructions - Bibliotheque et laboratoires\n   └─ Compte parent : 213\n\n10. **215001** - Materiel informatique\n   └─ Compte parent : 215\n\n11. **215002** - Materiel pedagogique\n   └─ Compte parent : 215\n\n12. **218001** - Mobilier scolaire\n   └─ Compte parent : 218\n\n13. **218002** - Vehicules de transport scolaire\n   └─ Compte parent : 218\n\n14. **321001** - Matiere consommables - produits chimiques labo\n   └─ Compte parent : 321\n\n15. **321002** - Matiere consommables - materiel pedagogique\n   └─ Compte parent : 321\n\n... et 207 autres sous-comptes\nDemandez-moi des détails sur un code spécifique !	chat_1762017250245_cs2e4eu7v	\N	2025-11-01 17:14:26	2025-11-01 17:14:26
16	Statistiques des sous compte	📈 Statistiques des sous-comptes :\n\n• **Total de sous-comptes** : 222\n• **Comptes disponibles** : 243\n• **Comptes avec sous-comptes** : 122\n• **Moyenne par compte** : 1.82\n	chat_1762020357072_so2zatv78	\N	2025-11-01 18:06:15	2025-11-01 18:06:15
17	je cherche le sous comptes 512001	❌ Le sous-compte **CHERCHE** n'existe pas en base de données.	chat_1762021432582_c0itdghhr	\N	2025-11-01 18:24:34	2025-11-01 18:24:34
18	cherche	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762021432582_c0itdghhr	\N	2025-11-01 18:25:02	2025-11-01 18:25:02
19	je cherche le code 512001	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762021432582_c0itdghhr	\N	2025-11-01 18:25:22	2025-11-01 18:25:22
20	cherche le sous compte 512001	❌ Le sous-compte **CHERCHE** n'existe pas en base de données.	chat_1762021432582_c0itdghhr	\N	2025-11-01 18:25:43	2025-11-01 18:25:43
21	Quels sont les sous-comptes du compte 401	Veuillez préciser le code du compte (ex: 401, 512, 401).	chat_1762021432582_c0itdghhr	\N	2025-11-01 18:25:57	2025-11-01 18:25:57
22	Cherche le sous-compte 401001	❌ Le sous-compte **CHERCHE** n'existe pas en base de données.	chat_1762021432582_c0itdghhr	\N	2025-11-01 18:26:14	2025-11-01 18:26:14
77	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762530227164_12ew9ohuk	\N	2025-11-07 15:43:55	2025-11-07 15:43:55
23	512001	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762021432582_c0itdghhr	\N	2025-11-01 18:26:32	2025-11-01 18:26:32
24	Cherche les sous-comptes avec trésorerie	❌ Le sous-compte **CHERCHE** n'existe pas en base de données.	chat_1762021432582_c0itdghhr	\N	2025-11-01 18:27:04	2025-11-01 18:27:04
25	Statistiques sous-comptes	📈 Statistiques des sous-comptes :\n\n• **Total de sous-comptes** : 222\n• **Comptes disponibles** : 243\n• **Comptes avec sous-comptes** : 122\n• **Moyenne par compte** : 1.82\n	chat_1762021682146_bq59uspnn	\N	2025-11-01 18:28:04	2025-11-01 18:28:04
26	512001 cherche	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762021682146_bq59uspnn	\N	2025-11-01 18:30:50	2025-11-01 18:30:50
27	cherche le comptes 512001	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762021682146_bq59uspnn	\N	2025-11-01 18:35:49	2025-11-01 18:35:49
28	Détaille le sous-compte 512001	Veuillez préciser le code du compte (ex: 401, 512, 401).	chat_1762022707920_2hol2cfxd	\N	2025-11-01 18:45:10	2025-11-01 18:45:10
29	Sous-compte avec le code 65874	Veuillez préciser le code du sous-compte (ex: 401001, 512001).	chat_1762022707920_2hol2cfxd	\N	2025-11-01 18:46:01	2025-11-01 18:46:01
30	Sous-compte avec le code 512001	✅ Détails du sous-compte :\n\n**Code** : 512001\n**Libellé** : BNI - compte courant\n**Compte parent** : 512 - Banques comptes courants\n**ID** : 53\n	chat_1762022707920_2hol2cfxd	\N	2025-11-01 18:46:10	2025-11-01 18:46:11
31	cheche le sous compte avec le code 531001	✅ Détails du sous-compte :\n\n**Code** : 531001\n**Libellé** : Caisse école\n**Compte parent** : 531 - Caisse école\n**ID** : 236\n	chat_1762022707920_2hol2cfxd	\N	2025-11-01 18:46:29	2025-11-01 18:46:29
32	cherche le sous compte avec le code 531001	✅ Détails du sous-compte :\n\n**Code** : 531001\n**Libellé** : Caisse école\n**Compte parent** : 531 - Caisse école\n**ID** : 236\n	chat_1762022707920_2hol2cfxd	\N	2025-11-01 18:46:45	2025-11-01 18:46:45
33	Cherche les sous-comptes avec "caisse"	Veuillez préciser le code du sous-compte (ex: 401001, 512001).	chat_1762022832761_jomxikcru	\N	2025-11-01 18:58:42	2025-11-01 18:58:42
34	Quels sont nos ratios financiers ?	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762022832761_jomxikcru	\N	2025-11-01 18:58:54	2025-11-01 18:58:54
35	liste des sous compte	📊 Les sous-comptes disponibles :\n\n1. **101001** - Capital verse par l Etat\n   └─ Compte parent : 101\n\n2. **101002** - Capital apporte par les fondateurs prives\n   └─ Compte parent : 101\n\n3. **106001** - Reserve legale\n   └─ Compte parent : 106\n\n4. **106002** - Autres reserves (fonds scolaires)\n   └─ Compte parent : 106\n\n5. **108001** - Compte du directeur detablissement\n   └─ Compte parent : 108\n\n6. **211001** - Terrains du campus\n   └─ Compte parent : 211\n\n7. **213001** - Constructions - Batiments administratifs\n   └─ Compte parent : 213\n\n8. **213002** - Constructions - Salles de classe\n   └─ Compte parent : 213\n\n9. **213003** - Constructions - Bibliotheque et laboratoires\n   └─ Compte parent : 213\n\n10. **215001** - Materiel informatique\n   └─ Compte parent : 215\n\n11. **215002** - Materiel pedagogique\n   └─ Compte parent : 215\n\n12. **218001** - Mobilier scolaire\n   └─ Compte parent : 218\n\n13. **218002** - Vehicules de transport scolaire\n   └─ Compte parent : 218\n\n14. **321001** - Matiere consommables - produits chimiques labo\n   └─ Compte parent : 321\n\n15. **321002** - Matiere consommables - materiel pedagogique\n   └─ Compte parent : 321\n\n... et 207 autres sous-comptes\nDemandez-moi des détails sur un code spécifique !	chat_1762023883313_38z81crp8	\N	2025-11-01 19:05:20	2025-11-01 19:05:20
36	statistiques des sous compte	📈 Statistiques des sous-comptes :\n\n• **Total de sous-comptes** : 222\n• **Comptes disponibles** : 243\n• **Comptes avec sous-comptes** : 122\n• **Moyenne par compte** : 1.82\n	chat_1762024244712_f715ripim	\N	2025-11-01 19:11:56	2025-11-01 19:11:56
37	statistiques des sous compte	📈 Statistiques des sous-comptes :\n\n• **Total de sous-comptes** : 222\n• **Comptes disponibles** : 243\n• **Comptes avec sous-comptes** : 122\n• **Moyenne par compte** : 1.82\n	chat_1762024773903_rghz2qfmw	\N	2025-11-01 19:19:53	2025-11-01 19:19:53
38	Quels sont nos ratios financiers ?	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762024773903_rghz2qfmw	\N	2025-11-01 19:24:23	2025-11-01 19:24:23
39	2025	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762025867779_ur0o40x12	\N	2025-11-01 19:37:54	2025-11-01 19:37:54
40	liste des journaux	📓 **Liste des journaux disponibles** :\n\n- **BNI** : Journal Banque\n	chat_1762028902322_plc3stsn9	\N	2025-11-01 20:28:32	2025-11-01 20:28:32
41	tous les journaux	📓 **Liste des journaux disponibles** :\n\n- **BNI** : Journal Banque\n	chat_1762096112115_y8mnwk86v	\N	2025-11-02 15:09:10	2025-11-02 15:09:10
42	Quels sont nos ratios financiers ?	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762096112115_y8mnwk86v	\N	2025-11-02 16:46:54	2025-11-02 16:46:54
43	donne moi la statistiques des sous comptes	📈 Statistiques des sous-comptes :\n\n• **Total de sous-comptes** : 222\n• **Comptes disponibles** : 243\n• **Comptes avec sous-comptes** : 122\n• **Moyenne par compte** : 1.82\n	chat_1762105807637_4a1janv2n	\N	2025-11-02 17:50:41	2025-11-02 17:50:41
44	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762105961601_8ppou48zp	\N	2025-11-02 17:52:47	2025-11-02 17:52:47
45	pipi caca	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762105961601_8ppou48zp	\N	2025-11-02 17:53:15	2025-11-02 17:53:15
46	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762106022581_cx2a8oxg8	\N	2025-11-02 17:53:50	2025-11-02 17:53:50
47	nemany	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762106022581_cx2a8oxg8	\N	2025-11-02 17:54:05	2025-11-02 17:54:05
48	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762108239403_6j5j0dc3u	\N	2025-11-02 18:30:45	2025-11-02 18:30:45
49	statistiques des sous compte	📈 Statistiques des sous-comptes :\n\n• **Total de sous-comptes** : 222\n• **Comptes disponibles** : 243\n• **Comptes avec sous-comptes** : 122\n• **Moyenne par compte** : 1.82\n	chat_1762108239403_6j5j0dc3u	\N	2025-11-02 18:31:12	2025-11-02 18:31:13
50	caisse école	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762108239403_6j5j0dc3u	\N	2025-11-02 18:32:01	2025-11-02 18:32:01
51	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762110254507_ndj5labur	\N	2025-11-02 19:04:21	2025-11-02 19:04:21
52	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762110503691_gk8cwr5kw	\N	2025-11-02 19:08:30	2025-11-02 19:08:30
53	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762111141021_4g635yogc	\N	2025-11-02 19:19:09	2025-11-02 19:19:09
54	le sous comptes 512001	Veuillez préciser le code du compte (ex: 401, 512, 401).	chat_1762111141021_4g635yogc	\N	2025-11-02 19:19:30	2025-11-02 19:19:31
55	cherche le sous compte 512001	✅ Détails du sous-compte :\n\n**Code** : 512001\n**Libellé** : BNI - compte courant\n**Compte parent** : 512 - Banques comptes courants\n**ID** : 53\n	chat_1762111141021_4g635yogc	\N	2025-11-02 19:19:53	2025-11-02 19:19:53
56	le sous compte 512001	Veuillez préciser le code du compte (ex: 401, 512, 401).	chat_1762111141021_4g635yogc	\N	2025-11-02 19:22:36	2025-11-02 19:22:36
57	cherche le sous comptes 512001	✅ Détails du sous-compte :\n\n**Code** : 512001\n**Libellé** : BNI - compte courant\n**Compte parent** : 512 - Banques comptes courants\n**ID** : 53\n	chat_1762111141021_4g635yogc	\N	2025-11-02 19:22:52	2025-11-02 19:22:52
58	cherche le sous compte 512001	✅ Détails du sous compte :\n\n**Code** : 512001\n**Libellé** : BNI - compte courant\n**Compte parent** : 512 - Banques comptes courants\n**ID** : 53\n	chat_1762111141021_4g635yogc	\N	2025-11-02 19:24:15	2025-11-02 19:24:15
59	cherche le sous comptes 531001	✅ Détails du sous-compte :\n\n**Code** : 531001\n**Libellé** : Caisse école\n**Compte parent** : 531 - Caisse école\n**ID** : 236\n	chat_1762111606682_6v1wq8wzm	\N	2025-11-02 19:27:04	2025-11-02 19:27:04
60	cherche le sous comptes 531001	✅ Détails du sous-compte :\n\n**Code** : 531001\n**Libellé** : Caisse école\n**Compte parent** : 531 - Caisse école\n**ID** : 236\n	chat_1762111649398_63l6lcsr2	\N	2025-11-02 19:27:50	2025-11-02 19:27:50
61	cherche le sous comptes 531001	✅ Détails du sous-compte :\n\n**Code** : 531001,\n**Libellé** : Caisse école,\n**Compte parent** : 531 - Caisse école,\n**ID** : 236,\nAvez-vous d'autres questions sur ce sous-compte ?	chat_1762111649398_63l6lcsr2	\N	2025-11-02 19:29:50	2025-11-02 19:29:50
62	Quels sont nos ratios financiers ?	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762111649398_63l6lcsr2	\N	2025-11-02 19:30:56	2025-11-02 19:30:56
63	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762157600835_5wk6r9uhz	\N	2025-11-03 08:13:28	2025-11-03 08:13:28
64	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762157622008_vwqay9bcv	\N	2025-11-03 08:15:26	2025-11-03 08:15:26
65	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762158430407_jt7j5rlbw	\N	2025-11-03 08:27:14	2025-11-03 08:27:14
66	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762158520166_86k5w9uts	\N	2025-11-03 08:28:49	2025-11-03 08:28:49
67	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762186236449_lp7g8jf0l	\N	2025-11-03 16:10:49	2025-11-03 16:10:49
68	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762283478419_qmtrstdt4	\N	2025-11-04 19:11:28	2025-11-04 19:11:28
69	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762358862461_t9fxam278	\N	2025-11-05 16:07:46	2025-11-05 16:07:46
70	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762358862461_t9fxam278	\N	2025-11-05 16:09:17	2025-11-05 16:09:17
71	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762359796649_g71hq5vtf	\N	2025-11-05 16:23:21	2025-11-05 16:23:21
72	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762360052735_lfkvxrhng	\N	2025-11-05 16:27:36	2025-11-05 16:27:36
73	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762360232399_rjs5em9v2	\N	2025-11-05 16:30:36	2025-11-05 16:30:36
74	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762360471679_a19khke1m	\N	2025-11-05 16:34:35	2025-11-05 16:34:35
75	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762361306947_t9vmi0oxq	\N	2025-11-05 16:48:34	2025-11-05 16:48:34
76	Bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762530206331_rjz2q9xxw	\N	2025-11-07 15:43:35	2025-11-07 15:43:35
78	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762530252430_1hvjf4xg5	\N	2025-11-07 15:44:16	2025-11-07 15:44:16
79	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762530320110_mcoxn9erh	\N	2025-11-07 15:45:26	2025-11-07 15:45:26
80	liste des comptes	Bonjour Utilisateur, Je suis votre assistant financier pour établissements scolaires. Actuellement en cours de configuration, je pourrai bientôt vous aider avec :\n\n• 📊 Analyse des budgets\n• 📈 Suivi des dépenses  \n• 🎓 Indicateurs par élève\n• ⚖️ Équilibre financier\n\nPosez-moi une question simple pour tester !	chat_1762530320110_mcoxn9erh	\N	2025-11-07 15:45:55	2025-11-07 15:45:55
81	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762530320110_mcoxn9erh	\N	2025-11-07 15:54:40	2025-11-07 15:54:40
82	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762530937836_2lxxhgu4q	\N	2025-11-07 15:55:54	2025-11-07 15:55:54
83	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762530974684_gjfidezha	\N	2025-11-07 15:56:21	2025-11-07 15:56:21
84	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762530994561_9n8kvmyr9	\N	2025-11-07 15:56:39	2025-11-07 15:56:39
85	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762531010681_ahfzd6ocm	\N	2025-11-07 15:56:59	2025-11-07 15:56:59
86	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762531028640_tnuk709lr	\N	2025-11-07 15:57:13	2025-11-07 15:57:13
87	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1762848674027_evmc01wk6	\N	2025-11-11 08:11:18	2025-11-11 08:11:18
88	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1763022409462_g7z5swonf	\N	2025-11-13 08:27:03	2025-11-13 08:27:03
89	bonjour	Bonjour Utilisateur! Je suis votre assistant pour l'analyse financière scolaire. Comment puis-je vous aider ?	chat_1763228771523_4trngeq3t	\N	2025-11-15 17:46:19	2025-11-15 17:46:19
\.


--
-- Data for Name: classes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.classes ("Id_Classe", "Code", "Libelle") FROM stdin;
1	1	Comptes de capitaux
2	2	Comptes dimmobilisations
3	3	Comptes de stocks et en-cours
4	4	Comptes de tiers
5	5	Comptes financiers
6	6	Comptes de charges
7	7	Comptes de produits
\.


--
-- Data for Name: code_analytique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.code_analytique (id_code, code, libelle, plage_de_extension) FROM stdin;
\.


--
-- Data for Name: compte_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.compte_categories (id_compte_categorie, poids, date_debut, date_fin, actif, id_sous_compte, id_categorie_fonctionelle, created_at, updated_at) FROM stdin;
1	1.00	2025-10-27	\N	t	196	1	2025-10-27 19:32:57	2025-10-27 19:32:57
2	1.00	2025-10-27	\N	t	191	1	2025-10-27 19:32:57	2025-10-27 19:32:57
3	1.00	2025-10-27	\N	t	193	1	2025-10-27 19:32:57	2025-10-27 19:32:57
4	1.00	2025-10-27	\N	t	198	1	2025-10-27 19:32:57	2025-10-27 19:32:57
5	1.00	2025-10-27	\N	t	186	1	2025-10-27 19:32:57	2025-10-27 19:32:57
6	1.00	2025-10-27	\N	t	189	1	2025-10-27 19:32:57	2025-10-27 19:32:57
7	1.00	2025-10-27	\N	t	184	1	2025-10-27 19:32:57	2025-10-27 19:32:57
8	1.00	2025-10-27	\N	t	202	1	2025-10-27 19:32:57	2025-10-27 19:32:57
9	1.00	2025-10-27	\N	t	195	1	2025-10-27 19:32:57	2025-10-27 19:32:57
10	1.00	2025-10-27	\N	t	204	1	2025-10-27 19:32:57	2025-10-27 19:32:57
11	1.00	2025-10-27	\N	t	185	1	2025-10-27 19:32:57	2025-10-27 19:32:57
12	1.00	2025-10-27	\N	t	205	1	2025-10-27 19:32:57	2025-10-27 19:32:57
13	1.00	2025-10-27	\N	t	197	1	2025-10-27 19:32:57	2025-10-27 19:32:57
14	1.00	2025-10-27	\N	t	187	1	2025-10-27 19:32:57	2025-10-27 19:32:57
15	1.00	2025-10-27	\N	t	194	1	2025-10-27 19:32:57	2025-10-27 19:32:57
16	1.00	2025-10-27	\N	t	203	1	2025-10-27 19:32:57	2025-10-27 19:32:57
17	1.00	2025-10-27	\N	t	192	1	2025-10-27 19:32:57	2025-10-27 19:32:57
18	1.00	2025-10-27	\N	t	190	1	2025-10-27 19:32:57	2025-10-27 19:32:57
19	1.00	2025-10-27	\N	t	200	1	2025-10-27 19:32:57	2025-10-27 19:32:57
20	1.00	2025-10-27	\N	t	199	1	2025-10-27 19:32:57	2025-10-27 19:32:57
21	1.00	2025-10-27	\N	t	201	1	2025-10-27 19:32:57	2025-10-27 19:32:57
22	1.00	2025-10-27	\N	t	188	1	2025-10-27 19:32:57	2025-10-27 19:32:57
23	1.00	2025-10-27	\N	t	183	1	2025-10-27 19:32:57	2025-10-27 19:32:57
24	1.00	2025-10-27	\N	t	209	2	2025-10-27 19:32:57	2025-10-27 19:32:57
25	1.00	2025-10-27	\N	t	207	2	2025-10-27 19:32:57	2025-10-27 19:32:57
26	1.00	2025-10-27	\N	t	208	2	2025-10-27 19:32:57	2025-10-27 19:32:57
27	1.00	2025-10-27	\N	t	206	2	2025-10-27 19:32:57	2025-10-27 19:32:57
28	1.00	2025-10-27	\N	t	211	3	2025-10-27 19:32:57	2025-10-27 19:32:57
29	1.00	2025-10-27	\N	t	210	3	2025-10-27 19:32:57	2025-10-27 19:32:57
30	1.00	2025-10-27	\N	t	214	6	2025-10-27 19:32:57	2025-10-27 19:32:57
31	1.00	2025-10-27	\N	t	213	6	2025-10-27 19:32:57	2025-10-27 19:32:57
32	1.00	2025-10-27	\N	t	215	6	2025-10-27 19:32:57	2025-10-27 19:32:57
33	1.00	2025-10-27	\N	t	212	6	2025-10-27 19:32:57	2025-10-27 19:32:57
34	1.00	2025-10-27	\N	t	218	9	2025-10-27 19:32:57	2025-10-27 19:32:57
35	1.00	2025-10-27	\N	t	221	9	2025-10-27 19:32:57	2025-10-27 19:32:57
36	1.00	2025-10-27	\N	t	216	9	2025-10-27 19:32:57	2025-10-27 19:32:57
37	1.00	2025-10-27	\N	t	224	9	2025-10-27 19:32:57	2025-10-27 19:32:57
38	1.00	2025-10-27	\N	t	219	9	2025-10-27 19:32:57	2025-10-27 19:32:57
39	1.00	2025-10-27	\N	t	222	9	2025-10-27 19:32:57	2025-10-27 19:32:57
40	1.00	2025-10-27	\N	t	225	9	2025-10-27 19:32:57	2025-10-27 19:32:57
41	1.00	2025-10-27	\N	t	220	9	2025-10-27 19:32:57	2025-10-27 19:32:57
42	1.00	2025-10-27	\N	t	223	9	2025-10-27 19:32:57	2025-10-27 19:32:57
43	1.00	2025-10-27	\N	t	217	9	2025-10-27 19:32:57	2025-10-27 19:32:57
44	1.00	2025-10-27	\N	t	230	13	2025-10-27 19:32:57	2025-10-27 19:32:57
45	1.00	2025-10-27	\N	t	228	13	2025-10-27 19:32:57	2025-10-27 19:32:57
46	1.00	2025-10-27	\N	t	226	13	2025-10-27 19:32:57	2025-10-27 19:32:57
47	1.00	2025-10-27	\N	t	227	13	2025-10-27 19:32:57	2025-10-27 19:32:57
48	1.00	2025-10-27	\N	t	229	13	2025-10-27 19:32:57	2025-10-27 19:32:57
49	1.00	2025-10-27	\N	t	234	12	2025-10-27 19:32:57	2025-10-27 19:32:57
50	1.00	2025-10-27	\N	t	233	12	2025-10-27 19:32:57	2025-10-27 19:32:57
51	1.00	2025-10-27	\N	t	232	12	2025-10-27 19:32:57	2025-10-27 19:32:57
52	1.00	2025-10-27	\N	t	235	12	2025-10-27 19:32:57	2025-10-27 19:32:57
53	1.00	2025-10-27	\N	t	231	12	2025-10-27 19:32:57	2025-10-27 19:32:57
54	1.00	2025-10-27	\N	t	106	4	2025-10-27 19:32:57	2025-10-27 19:32:57
55	1.00	2025-10-27	\N	t	101	4	2025-10-27 19:32:57	2025-10-27 19:32:57
56	1.00	2025-10-27	\N	t	82	4	2025-10-27 19:32:57	2025-10-27 19:32:57
57	1.00	2025-10-27	\N	t	93	4	2025-10-27 19:32:57	2025-10-27 19:32:57
58	1.00	2025-10-27	\N	t	89	4	2025-10-27 19:32:57	2025-10-27 19:32:57
59	1.00	2025-10-27	\N	t	109	4	2025-10-27 19:32:57	2025-10-27 19:32:57
60	1.00	2025-10-27	\N	t	98	4	2025-10-27 19:32:57	2025-10-27 19:32:57
61	1.00	2025-10-27	\N	t	104	4	2025-10-27 19:32:57	2025-10-27 19:32:57
62	1.00	2025-10-27	\N	t	102	4	2025-10-27 19:32:57	2025-10-27 19:32:57
63	1.00	2025-10-27	\N	t	83	4	2025-10-27 19:32:57	2025-10-27 19:32:57
64	1.00	2025-10-27	\N	t	91	4	2025-10-27 19:32:57	2025-10-27 19:32:57
65	1.00	2025-10-27	\N	t	96	4	2025-10-27 19:32:57	2025-10-27 19:32:57
66	1.00	2025-10-27	\N	t	107	4	2025-10-27 19:32:57	2025-10-27 19:32:57
67	1.00	2025-10-27	\N	t	108	4	2025-10-27 19:32:57	2025-10-27 19:32:57
68	1.00	2025-10-27	\N	t	85	4	2025-10-27 19:32:57	2025-10-27 19:32:57
69	1.00	2025-10-27	\N	t	100	4	2025-10-27 19:32:57	2025-10-27 19:32:57
70	1.00	2025-10-27	\N	t	80	4	2025-10-27 19:32:57	2025-10-27 19:32:57
71	1.00	2025-10-27	\N	t	110	4	2025-10-27 19:32:57	2025-10-27 19:32:57
72	1.00	2025-10-27	\N	t	99	4	2025-10-27 19:32:57	2025-10-27 19:32:57
73	1.00	2025-10-27	\N	t	94	4	2025-10-27 19:32:57	2025-10-27 19:32:57
74	1.00	2025-10-27	\N	t	95	4	2025-10-27 19:32:57	2025-10-27 19:32:57
75	1.00	2025-10-27	\N	t	97	4	2025-10-27 19:32:57	2025-10-27 19:32:57
76	1.00	2025-10-27	\N	t	81	4	2025-10-27 19:32:57	2025-10-27 19:32:57
77	1.00	2025-10-27	\N	t	79	4	2025-10-27 19:32:57	2025-10-27 19:32:57
78	1.00	2025-10-27	\N	t	90	4	2025-10-27 19:32:57	2025-10-27 19:32:57
79	1.00	2025-10-27	\N	t	84	4	2025-10-27 19:32:57	2025-10-27 19:32:57
80	1.00	2025-10-27	\N	t	103	4	2025-10-27 19:32:57	2025-10-27 19:32:57
81	1.00	2025-10-27	\N	t	92	4	2025-10-27 19:32:57	2025-10-27 19:32:57
82	1.00	2025-10-27	\N	t	86	4	2025-10-27 19:32:57	2025-10-27 19:32:57
83	1.00	2025-10-27	\N	t	105	4	2025-10-27 19:32:57	2025-10-27 19:32:57
84	1.00	2025-10-27	\N	t	87	4	2025-10-27 19:32:57	2025-10-27 19:32:57
85	1.00	2025-10-27	\N	t	88	4	2025-10-27 19:32:57	2025-10-27 19:32:57
86	1.00	2025-10-27	\N	t	120	5	2025-10-27 19:32:57	2025-10-27 19:32:57
87	1.00	2025-10-27	\N	t	119	5	2025-10-27 19:32:57	2025-10-27 19:32:57
88	1.00	2025-10-27	\N	t	125	5	2025-10-27 19:32:57	2025-10-27 19:32:57
89	1.00	2025-10-27	\N	t	123	5	2025-10-27 19:32:57	2025-10-27 19:32:57
90	1.00	2025-10-27	\N	t	112	5	2025-10-27 19:32:57	2025-10-27 19:32:57
91	1.00	2025-10-27	\N	t	113	5	2025-10-27 19:32:57	2025-10-27 19:32:57
92	1.00	2025-10-27	\N	t	122	5	2025-10-27 19:32:57	2025-10-27 19:32:57
93	1.00	2025-10-27	\N	t	127	5	2025-10-27 19:32:57	2025-10-27 19:32:57
94	1.00	2025-10-27	\N	t	117	5	2025-10-27 19:32:57	2025-10-27 19:32:57
95	1.00	2025-10-27	\N	t	114	5	2025-10-27 19:32:57	2025-10-27 19:32:57
96	1.00	2025-10-27	\N	t	126	5	2025-10-27 19:32:57	2025-10-27 19:32:57
97	1.00	2025-10-27	\N	t	116	5	2025-10-27 19:32:57	2025-10-27 19:32:57
98	1.00	2025-10-27	\N	t	115	5	2025-10-27 19:32:57	2025-10-27 19:32:57
99	1.00	2025-10-27	\N	t	111	5	2025-10-27 19:32:57	2025-10-27 19:32:57
100	1.00	2025-10-27	\N	t	124	5	2025-10-27 19:32:57	2025-10-27 19:32:57
101	1.00	2025-10-27	\N	t	121	5	2025-10-27 19:32:57	2025-10-27 19:32:57
102	1.00	2025-10-27	\N	t	118	5	2025-10-27 19:32:57	2025-10-27 19:32:57
103	1.00	2025-10-27	\N	t	137	5	2025-10-27 19:32:58	2025-10-27 19:32:58
104	1.00	2025-10-27	\N	t	136	5	2025-10-27 19:32:58	2025-10-27 19:32:58
105	1.00	2025-10-27	\N	t	135	5	2025-10-27 19:32:58	2025-10-27 19:32:58
106	1.00	2025-10-27	\N	t	131	5	2025-10-27 19:32:58	2025-10-27 19:32:58
107	1.00	2025-10-27	\N	t	142	5	2025-10-27 19:32:58	2025-10-27 19:32:58
108	1.00	2025-10-27	\N	t	139	5	2025-10-27 19:32:58	2025-10-27 19:32:58
109	1.00	2025-10-27	\N	t	143	5	2025-10-27 19:32:58	2025-10-27 19:32:58
110	1.00	2025-10-27	\N	t	140	5	2025-10-27 19:32:58	2025-10-27 19:32:58
111	1.00	2025-10-27	\N	t	133	5	2025-10-27 19:32:58	2025-10-27 19:32:58
112	1.00	2025-10-27	\N	t	128	5	2025-10-27 19:32:58	2025-10-27 19:32:58
113	1.00	2025-10-27	\N	t	129	5	2025-10-27 19:32:58	2025-10-27 19:32:58
114	1.00	2025-10-27	\N	t	132	5	2025-10-27 19:32:58	2025-10-27 19:32:58
115	1.00	2025-10-27	\N	t	134	5	2025-10-27 19:32:58	2025-10-27 19:32:58
116	1.00	2025-10-27	\N	t	141	5	2025-10-27 19:32:58	2025-10-27 19:32:58
117	1.00	2025-10-27	\N	t	138	5	2025-10-27 19:32:58	2025-10-27 19:32:58
118	1.00	2025-10-27	\N	t	130	5	2025-10-27 19:32:58	2025-10-27 19:32:58
119	1.00	2025-10-27	\N	t	144	5	2025-10-27 19:32:58	2025-10-27 19:32:58
120	1.00	2025-10-27	\N	t	145	8	2025-10-27 19:32:58	2025-10-27 19:32:58
121	1.00	2025-10-27	\N	t	146	8	2025-10-27 19:32:58	2025-10-27 19:32:58
122	1.00	2025-10-27	\N	t	147	8	2025-10-27 19:32:58	2025-10-27 19:32:58
123	1.00	2025-10-27	\N	t	148	8	2025-10-27 19:32:58	2025-10-27 19:32:58
124	1.00	2025-10-27	\N	t	149	8	2025-10-27 19:32:58	2025-10-27 19:32:58
125	1.00	2025-10-27	\N	t	151	7	2025-10-27 19:32:58	2025-10-27 19:32:58
126	1.00	2025-10-27	\N	t	153	7	2025-10-27 19:32:58	2025-10-27 19:32:58
127	1.00	2025-10-27	\N	t	152	7	2025-10-27 19:32:58	2025-10-27 19:32:58
128	1.00	2025-10-27	\N	t	155	7	2025-10-27 19:32:58	2025-10-27 19:32:58
129	1.00	2025-10-27	\N	t	154	7	2025-10-27 19:32:58	2025-10-27 19:32:58
130	1.00	2025-10-27	\N	t	150	7	2025-10-27 19:32:58	2025-10-27 19:32:58
131	1.00	2025-10-27	\N	t	160	10	2025-10-27 19:32:58	2025-10-27 19:32:58
132	1.00	2025-10-27	\N	t	163	10	2025-10-27 19:32:58	2025-10-27 19:32:58
133	1.00	2025-10-27	\N	t	165	10	2025-10-27 19:32:58	2025-10-27 19:32:58
134	1.00	2025-10-27	\N	t	164	10	2025-10-27 19:32:58	2025-10-27 19:32:58
135	1.00	2025-10-27	\N	t	158	10	2025-10-27 19:32:58	2025-10-27 19:32:58
136	1.00	2025-10-27	\N	t	162	10	2025-10-27 19:32:58	2025-10-27 19:32:58
137	1.00	2025-10-27	\N	t	156	10	2025-10-27 19:32:58	2025-10-27 19:32:58
138	1.00	2025-10-27	\N	t	159	10	2025-10-27 19:32:58	2025-10-27 19:32:58
139	1.00	2025-10-27	\N	t	166	10	2025-10-27 19:32:58	2025-10-27 19:32:58
140	1.00	2025-10-27	\N	t	161	10	2025-10-27 19:32:58	2025-10-27 19:32:58
141	1.00	2025-10-27	\N	t	157	10	2025-10-27 19:32:58	2025-10-27 19:32:58
142	1.00	2025-10-27	\N	t	168	14	2025-10-27 19:32:58	2025-10-27 19:32:58
143	1.00	2025-10-27	\N	t	167	14	2025-10-27 19:32:58	2025-10-27 19:32:58
144	1.00	2025-10-27	\N	t	172	14	2025-10-27 19:32:58	2025-10-27 19:32:58
145	1.00	2025-10-27	\N	t	170	14	2025-10-27 19:32:58	2025-10-27 19:32:58
146	1.00	2025-10-27	\N	t	171	14	2025-10-27 19:32:58	2025-10-27 19:32:58
147	1.00	2025-10-27	\N	t	169	14	2025-10-27 19:32:58	2025-10-27 19:32:58
148	1.00	2025-10-27	\N	t	173	14	2025-10-27 19:32:58	2025-10-27 19:32:58
149	1.00	2025-10-27	\N	t	178	11	2025-10-27 19:32:58	2025-10-27 19:32:58
150	1.00	2025-10-27	\N	t	177	11	2025-10-27 19:32:58	2025-10-27 19:32:58
151	1.00	2025-10-27	\N	t	175	11	2025-10-27 19:32:58	2025-10-27 19:32:58
152	1.00	2025-10-27	\N	t	174	11	2025-10-27 19:32:58	2025-10-27 19:32:58
153	1.00	2025-10-27	\N	t	176	11	2025-10-27 19:32:58	2025-10-27 19:32:58
154	1.00	2025-10-27	\N	t	179	15	2025-10-27 19:32:58	2025-10-27 19:32:58
155	1.00	2025-10-27	\N	t	180	15	2025-10-27 19:32:58	2025-10-27 19:32:58
156	1.00	2025-10-27	\N	t	181	15	2025-10-27 19:32:58	2025-10-27 19:32:58
157	1.00	2025-10-27	\N	t	182	15	2025-10-27 19:32:58	2025-10-27 19:32:58
158	1.00	2025-10-27	\N	t	11	25	2025-10-27 19:32:58	2025-10-27 19:32:58
159	1.00	2025-10-27	\N	t	12	25	2025-10-27 19:32:58	2025-10-27 19:32:58
160	1.00	2025-10-27	\N	t	10	25	2025-10-27 19:32:58	2025-10-27 19:32:58
161	1.00	2025-10-27	\N	t	13	25	2025-10-27 19:32:58	2025-10-27 19:32:58
162	1.00	2025-10-27	\N	t	8	25	2025-10-27 19:32:58	2025-10-27 19:32:58
163	1.00	2025-10-27	\N	t	6	25	2025-10-27 19:32:58	2025-10-27 19:32:58
164	1.00	2025-10-27	\N	t	9	25	2025-10-27 19:32:58	2025-10-27 19:32:58
165	1.00	2025-10-27	\N	t	7	25	2025-10-27 19:32:58	2025-10-27 19:32:58
166	1.00	2025-10-27	\N	t	20	32	2025-10-27 19:32:58	2025-10-27 19:32:58
167	1.00	2025-10-27	\N	t	25	32	2025-10-27 19:32:58	2025-10-27 19:32:58
168	1.00	2025-10-27	\N	t	26	32	2025-10-27 19:32:58	2025-10-27 19:32:58
169	1.00	2025-10-27	\N	t	27	32	2025-10-27 19:32:58	2025-10-27 19:32:58
170	1.00	2025-10-27	\N	t	39	32	2025-10-27 19:32:58	2025-10-27 19:32:58
171	1.00	2025-10-27	\N	t	17	32	2025-10-27 19:32:58	2025-10-27 19:32:58
172	1.00	2025-10-27	\N	t	33	32	2025-10-27 19:32:58	2025-10-27 19:32:58
173	1.00	2025-10-27	\N	t	31	32	2025-10-27 19:32:58	2025-10-27 19:32:58
174	1.00	2025-10-27	\N	t	34	32	2025-10-27 19:32:58	2025-10-27 19:32:58
175	1.00	2025-10-27	\N	t	18	32	2025-10-27 19:32:58	2025-10-27 19:32:58
176	1.00	2025-10-27	\N	t	15	32	2025-10-27 19:32:58	2025-10-27 19:32:58
177	1.00	2025-10-27	\N	t	21	32	2025-10-27 19:32:58	2025-10-27 19:32:58
178	1.00	2025-10-27	\N	t	19	32	2025-10-27 19:32:58	2025-10-27 19:32:58
179	1.00	2025-10-27	\N	t	37	32	2025-10-27 19:32:58	2025-10-27 19:32:58
180	1.00	2025-10-27	\N	t	32	32	2025-10-27 19:32:58	2025-10-27 19:32:58
181	1.00	2025-10-27	\N	t	24	32	2025-10-27 19:32:58	2025-10-27 19:32:58
182	1.00	2025-10-27	\N	t	38	32	2025-10-27 19:32:58	2025-10-27 19:32:58
183	1.00	2025-10-27	\N	t	28	32	2025-10-27 19:32:58	2025-10-27 19:32:58
184	1.00	2025-10-27	\N	t	30	32	2025-10-27 19:32:58	2025-10-27 19:32:58
185	1.00	2025-10-27	\N	t	29	32	2025-10-27 19:32:58	2025-10-27 19:32:58
186	1.00	2025-10-27	\N	t	16	32	2025-10-27 19:32:58	2025-10-27 19:32:58
187	1.00	2025-10-27	\N	t	36	32	2025-10-27 19:32:58	2025-10-27 19:32:58
188	1.00	2025-10-27	\N	t	23	32	2025-10-27 19:32:58	2025-10-27 19:32:58
189	1.00	2025-10-27	\N	t	22	32	2025-10-27 19:32:58	2025-10-27 19:32:58
190	1.00	2025-10-27	\N	t	14	32	2025-10-27 19:32:58	2025-10-27 19:32:58
191	1.00	2025-10-27	\N	t	35	32	2025-10-27 19:32:58	2025-10-27 19:32:58
192	1.00	2025-10-27	\N	t	42	34	2025-10-27 19:32:58	2025-10-27 19:32:58
193	1.00	2025-10-27	\N	t	44	34	2025-10-27 19:32:58	2025-10-27 19:32:58
194	1.00	2025-10-27	\N	t	43	34	2025-10-27 19:32:58	2025-10-27 19:32:58
195	1.00	2025-10-27	\N	t	47	36	2025-10-27 19:32:58	2025-10-27 19:32:58
196	1.00	2025-10-27	\N	t	46	36	2025-10-27 19:32:58	2025-10-27 19:32:58
197	1.00	2025-10-27	\N	t	48	36	2025-10-27 19:32:58	2025-10-27 19:32:58
198	1.00	2025-10-27	\N	t	50	36	2025-10-27 19:32:58	2025-10-27 19:32:58
199	1.00	2025-10-27	\N	t	49	36	2025-10-27 19:32:58	2025-10-27 19:32:58
200	1.00	2025-10-27	\N	t	45	36	2025-10-27 19:32:58	2025-10-27 19:32:58
201	1.00	2025-10-27	\N	t	52	37	2025-10-27 19:32:58	2025-10-27 19:32:58
202	1.00	2025-10-27	\N	t	51	37	2025-10-27 19:32:58	2025-10-27 19:32:58
203	1.00	2025-10-27	\N	t	54	37	2025-10-27 19:32:58	2025-10-27 19:32:58
204	1.00	2025-10-27	\N	t	53	37	2025-10-27 19:32:58	2025-10-27 19:32:58
205	1.00	2025-10-27	\N	t	2	40	2025-10-27 19:32:58	2025-10-27 19:32:58
206	1.00	2025-10-27	\N	t	5	40	2025-10-27 19:32:58	2025-10-27 19:32:58
207	1.00	2025-10-27	\N	t	4	40	2025-10-27 19:32:58	2025-10-27 19:32:58
208	1.00	2025-10-27	\N	t	1	40	2025-10-27 19:32:58	2025-10-27 19:32:58
209	1.00	2025-10-27	\N	t	3	40	2025-10-27 19:32:58	2025-10-27 19:32:58
210	1.00	2025-10-27	\N	t	3	41	2025-10-27 19:32:58	2025-10-27 19:32:58
211	1.00	2025-10-27	\N	t	4	41	2025-10-27 19:32:58	2025-10-27 19:32:58
212	1.00	2025-10-27	\N	t	40	51	2025-10-27 19:32:58	2025-10-27 19:32:58
213	1.00	2025-10-27	\N	t	41	51	2025-10-27 19:32:58	2025-10-27 19:32:58
214	1.00	2025-10-27	\N	t	47	50	2025-10-27 19:32:58	2025-10-27 19:32:58
215	1.00	2025-10-27	\N	t	46	50	2025-10-27 19:32:58	2025-10-27 19:32:58
216	1.00	2025-10-27	\N	t	48	50	2025-10-27 19:32:58	2025-10-27 19:32:58
217	1.00	2025-10-27	\N	t	50	50	2025-10-27 19:32:58	2025-10-27 19:32:58
218	1.00	2025-10-27	\N	t	49	50	2025-10-27 19:32:58	2025-10-27 19:32:58
219	1.00	2025-10-27	\N	t	45	50	2025-10-27 19:32:58	2025-10-27 19:32:58
220	1.00	2025-10-27	\N	t	51	38	2025-10-27 19:32:58	2025-10-27 19:32:58
221	1.00	2025-10-27	\N	t	52	38	2025-10-27 19:32:58	2025-10-27 19:32:58
222	1.00	2025-10-27	\N	t	53	38	2025-10-27 19:32:58	2025-10-27 19:32:58
223	1.00	2025-10-27	\N	t	54	38	2025-10-27 19:32:58	2025-10-27 19:32:58
224	1.00	2025-10-27	\N	t	236	39	2025-10-27 19:32:58	2025-10-27 19:32:58
225	1.00	2025-10-27	\N	t	237	48	2025-10-27 19:40:37	2025-10-27 19:40:37
226	1.00	2025-10-27	\N	t	238	7	2025-10-27 19:41:31	2025-10-27 19:41:31
227	1.00	2025-10-27	\N	t	239	7	2025-10-27 19:42:23	2025-10-27 19:42:23
228	1.00	2025-10-27	\N	t	240	7	2025-10-27 19:42:53	2025-10-27 19:42:53
229	1.00	2025-10-27	\N	t	241	4	2025-10-27 19:44:10	2025-10-27 19:44:10
230	1.00	2025-10-27	\N	t	242	4	2025-10-27 19:44:52	2025-10-27 19:44:52
231	1.00	2025-10-27	\N	t	243	4	2025-10-27 19:45:11	2025-10-27 19:45:11
232	1.00	2025-10-28	\N	t	244	48	2025-10-28 09:47:59	2025-10-28 09:47:59
233	1.00	2025-10-30	\N	t	245	55	2025-10-30 14:58:34	2025-10-30 14:58:34
234	1.00	2025-11-14	\N	t	216	10	2025-11-14 17:40:47	2025-11-14 17:40:47
235	1.00	2025-11-14	\N	t	217	10	2025-11-14 17:40:47	2025-11-14 17:40:47
236	1.00	2025-11-14	\N	t	218	10	2025-11-14 17:40:47	2025-11-14 17:40:47
237	1.00	2025-11-14	\N	t	219	10	2025-11-14 17:40:47	2025-11-14 17:40:47
238	1.00	2025-11-14	\N	t	220	10	2025-11-14 17:40:47	2025-11-14 17:40:47
239	1.00	2025-11-14	\N	t	221	10	2025-11-14 17:40:47	2025-11-14 17:40:47
240	1.00	2025-11-14	\N	t	222	10	2025-11-14 17:40:47	2025-11-14 17:40:47
241	1.00	2025-11-14	\N	t	223	10	2025-11-14 17:40:47	2025-11-14 17:40:47
242	1.00	2025-11-14	\N	t	224	10	2025-11-14 17:40:47	2025-11-14 17:40:47
243	1.00	2025-11-14	\N	t	225	10	2025-11-14 17:40:47	2025-11-14 17:40:47
244	1.00	2025-11-14	\N	t	226	14	2025-11-14 17:40:47	2025-11-14 17:40:47
245	1.00	2025-11-14	\N	t	227	14	2025-11-14 17:40:47	2025-11-14 17:40:47
246	1.00	2025-11-14	\N	t	228	14	2025-11-14 17:40:47	2025-11-14 17:40:47
247	1.00	2025-11-14	\N	t	229	14	2025-11-14 17:40:47	2025-11-14 17:40:47
248	1.00	2025-11-14	\N	t	230	14	2025-11-14 17:40:47	2025-11-14 17:40:47
249	1.00	2025-11-14	\N	t	231	13	2025-11-14 17:40:47	2025-11-14 17:40:47
250	1.00	2025-11-14	\N	t	232	13	2025-11-14 17:40:47	2025-11-14 17:40:47
251	1.00	2025-11-14	\N	t	233	13	2025-11-14 17:40:47	2025-11-14 17:40:47
252	1.00	2025-11-14	\N	t	234	13	2025-11-14 17:40:47	2025-11-14 17:40:47
253	1.00	2025-11-14	\N	t	235	13	2025-11-14 17:40:47	2025-11-14 17:40:47
254	1.00	2025-11-14	\N	t	145	9	2025-11-14 17:40:47	2025-11-14 17:40:47
255	1.00	2025-11-14	\N	t	146	9	2025-11-14 17:40:47	2025-11-14 17:40:47
256	1.00	2025-11-14	\N	t	147	9	2025-11-14 17:40:47	2025-11-14 17:40:47
257	1.00	2025-11-14	\N	t	148	9	2025-11-14 17:40:47	2025-11-14 17:40:47
258	1.00	2025-11-14	\N	t	149	9	2025-11-14 17:40:47	2025-11-14 17:40:47
259	1.00	2025-11-14	\N	t	156	11	2025-11-14 17:40:47	2025-11-14 17:40:47
260	1.00	2025-11-14	\N	t	157	11	2025-11-14 17:40:47	2025-11-14 17:40:47
261	1.00	2025-11-14	\N	t	158	11	2025-11-14 17:40:47	2025-11-14 17:40:47
262	1.00	2025-11-14	\N	t	159	11	2025-11-14 17:40:47	2025-11-14 17:40:47
263	1.00	2025-11-14	\N	t	160	11	2025-11-14 17:40:47	2025-11-14 17:40:47
264	1.00	2025-11-14	\N	t	161	11	2025-11-14 17:40:47	2025-11-14 17:40:47
265	1.00	2025-11-14	\N	t	162	11	2025-11-14 17:40:47	2025-11-14 17:40:47
266	1.00	2025-11-14	\N	t	163	11	2025-11-14 17:40:47	2025-11-14 17:40:47
267	1.00	2025-11-14	\N	t	164	11	2025-11-14 17:40:47	2025-11-14 17:40:47
268	1.00	2025-11-14	\N	t	165	11	2025-11-14 17:40:47	2025-11-14 17:40:47
269	1.00	2025-11-14	\N	t	166	11	2025-11-14 17:40:47	2025-11-14 17:40:47
270	1.00	2025-11-14	\N	t	168	15	2025-11-14 17:40:47	2025-11-14 17:40:47
271	1.00	2025-11-14	\N	t	167	15	2025-11-14 17:40:47	2025-11-14 17:40:47
272	1.00	2025-11-14	\N	t	172	15	2025-11-14 17:40:47	2025-11-14 17:40:47
273	1.00	2025-11-14	\N	t	170	15	2025-11-14 17:40:47	2025-11-14 17:40:47
274	1.00	2025-11-14	\N	t	171	15	2025-11-14 17:40:47	2025-11-14 17:40:47
275	1.00	2025-11-14	\N	t	169	15	2025-11-14 17:40:47	2025-11-14 17:40:47
276	1.00	2025-11-14	\N	t	173	15	2025-11-14 17:40:47	2025-11-14 17:40:47
277	1.00	2025-11-14	\N	t	178	12	2025-11-14 17:40:47	2025-11-14 17:40:47
278	1.00	2025-11-14	\N	t	177	12	2025-11-14 17:40:47	2025-11-14 17:40:47
279	1.00	2025-11-14	\N	t	175	12	2025-11-14 17:40:47	2025-11-14 17:40:47
280	1.00	2025-11-14	\N	t	174	12	2025-11-14 17:40:47	2025-11-14 17:40:47
281	1.00	2025-11-14	\N	t	176	12	2025-11-14 17:40:47	2025-11-14 17:40:47
282	1.00	2025-11-14	\N	t	179	16	2025-11-14 17:40:47	2025-11-14 17:40:47
283	1.00	2025-11-14	\N	t	180	16	2025-11-14 17:40:47	2025-11-14 17:40:47
284	1.00	2025-11-14	\N	t	181	16	2025-11-14 17:40:47	2025-11-14 17:40:47
285	1.00	2025-11-14	\N	t	182	16	2025-11-14 17:40:47	2025-11-14 17:40:47
286	1.00	2025-11-14	\N	t	6	26	2025-11-14 17:40:47	2025-11-14 17:40:47
287	1.00	2025-11-14	\N	t	7	26	2025-11-14 17:40:47	2025-11-14 17:40:47
288	1.00	2025-11-14	\N	t	8	26	2025-11-14 17:40:47	2025-11-14 17:40:47
289	1.00	2025-11-14	\N	t	9	26	2025-11-14 17:40:47	2025-11-14 17:40:47
290	1.00	2025-11-14	\N	t	10	26	2025-11-14 17:40:47	2025-11-14 17:40:47
291	1.00	2025-11-14	\N	t	11	26	2025-11-14 17:40:47	2025-11-14 17:40:47
292	1.00	2025-11-14	\N	t	12	26	2025-11-14 17:40:47	2025-11-14 17:40:47
293	1.00	2025-11-14	\N	t	13	26	2025-11-14 17:40:47	2025-11-14 17:40:47
294	1.00	2025-11-14	\N	t	245	28	2025-11-14 17:40:47	2025-11-14 17:40:47
295	1.00	2025-11-14	\N	t	14	35	2025-11-14 17:40:47	2025-11-14 17:40:47
296	1.00	2025-11-14	\N	t	15	35	2025-11-14 17:40:47	2025-11-14 17:40:47
297	1.00	2025-11-14	\N	t	16	35	2025-11-14 17:40:47	2025-11-14 17:40:47
298	1.00	2025-11-14	\N	t	17	35	2025-11-14 17:40:47	2025-11-14 17:40:47
299	1.00	2025-11-14	\N	t	18	35	2025-11-14 17:40:47	2025-11-14 17:40:47
300	1.00	2025-11-14	\N	t	19	35	2025-11-14 17:40:47	2025-11-14 17:40:47
301	1.00	2025-11-14	\N	t	20	35	2025-11-14 17:40:47	2025-11-14 17:40:47
302	1.00	2025-11-14	\N	t	21	35	2025-11-14 17:40:47	2025-11-14 17:40:47
303	1.00	2025-11-14	\N	t	22	35	2025-11-14 17:40:47	2025-11-14 17:40:47
304	1.00	2025-11-14	\N	t	23	35	2025-11-14 17:40:47	2025-11-14 17:40:47
305	1.00	2025-11-14	\N	t	24	35	2025-11-14 17:40:47	2025-11-14 17:40:47
306	1.00	2025-11-14	\N	t	25	35	2025-11-14 17:40:47	2025-11-14 17:40:47
307	1.00	2025-11-14	\N	t	26	35	2025-11-14 17:40:47	2025-11-14 17:40:47
308	1.00	2025-11-14	\N	t	27	35	2025-11-14 17:40:47	2025-11-14 17:40:47
309	1.00	2025-11-14	\N	t	28	35	2025-11-14 17:40:47	2025-11-14 17:40:47
310	1.00	2025-11-14	\N	t	29	35	2025-11-14 17:40:47	2025-11-14 17:40:47
311	1.00	2025-11-14	\N	t	30	35	2025-11-14 17:40:47	2025-11-14 17:40:47
312	1.00	2025-11-14	\N	t	31	35	2025-11-14 17:40:47	2025-11-14 17:40:47
313	1.00	2025-11-14	\N	t	32	35	2025-11-14 17:40:47	2025-11-14 17:40:47
314	1.00	2025-11-14	\N	t	33	35	2025-11-14 17:40:47	2025-11-14 17:40:47
315	1.00	2025-11-14	\N	t	34	35	2025-11-14 17:40:47	2025-11-14 17:40:47
316	1.00	2025-11-14	\N	t	35	35	2025-11-14 17:40:47	2025-11-14 17:40:47
317	1.00	2025-11-14	\N	t	36	35	2025-11-14 17:40:47	2025-11-14 17:40:47
318	1.00	2025-11-14	\N	t	37	35	2025-11-14 17:40:47	2025-11-14 17:40:47
319	1.00	2025-11-14	\N	t	38	35	2025-11-14 17:40:47	2025-11-14 17:40:47
320	1.00	2025-11-14	\N	t	39	35	2025-11-14 17:40:47	2025-11-14 17:40:47
321	1.00	2025-11-14	\N	t	42	37	2025-11-14 17:40:47	2025-11-14 17:40:47
322	1.00	2025-11-14	\N	t	44	37	2025-11-14 17:40:47	2025-11-14 17:40:47
323	1.00	2025-11-14	\N	t	43	37	2025-11-14 17:40:47	2025-11-14 17:40:47
324	1.00	2025-11-14	\N	t	45	39	2025-11-14 17:40:47	2025-11-14 17:40:47
325	1.00	2025-11-14	\N	t	46	39	2025-11-14 17:40:47	2025-11-14 17:40:47
326	1.00	2025-11-14	\N	t	47	39	2025-11-14 17:40:47	2025-11-14 17:40:47
327	1.00	2025-11-14	\N	t	48	39	2025-11-14 17:40:47	2025-11-14 17:40:47
328	1.00	2025-11-14	\N	t	49	39	2025-11-14 17:40:47	2025-11-14 17:40:47
329	1.00	2025-11-14	\N	t	50	39	2025-11-14 17:40:47	2025-11-14 17:40:47
330	1.00	2025-11-14	\N	t	52	40	2025-11-14 17:40:47	2025-11-14 17:40:47
331	1.00	2025-11-14	\N	t	51	40	2025-11-14 17:40:47	2025-11-14 17:40:47
332	1.00	2025-11-14	\N	t	54	40	2025-11-14 17:40:47	2025-11-14 17:40:47
333	1.00	2025-11-14	\N	t	53	40	2025-11-14 17:40:47	2025-11-14 17:40:47
334	1.00	2025-11-14	\N	t	1	43	2025-11-14 17:40:47	2025-11-14 17:40:47
335	1.00	2025-11-14	\N	t	2	43	2025-11-14 17:40:47	2025-11-14 17:40:47
336	1.00	2025-11-14	\N	t	3	43	2025-11-14 17:40:47	2025-11-14 17:40:47
337	1.00	2025-11-14	\N	t	4	43	2025-11-14 17:40:47	2025-11-14 17:40:47
338	1.00	2025-11-14	\N	t	5	43	2025-11-14 17:40:47	2025-11-14 17:40:47
340	1.00	2025-11-14	\N	t	3	44	2025-11-14 17:55:33	2025-11-14 17:55:33
341	1.00	2025-11-14	\N	t	4	44	2025-11-14 17:55:33	2025-11-14 17:55:33
342	1.00	2025-11-14	\N	t	244	51	2025-11-14 17:55:33	2025-11-14 17:55:33
343	1.00	2025-11-14	\N	t	237	51	2025-11-14 17:55:33	2025-11-14 17:55:33
344	1.00	2025-11-14	\N	t	40	54	2025-11-14 17:55:33	2025-11-14 17:55:33
345	1.00	2025-11-14	\N	t	41	54	2025-11-14 17:55:33	2025-11-14 17:55:33
346	1.00	2025-11-14	\N	t	45	53	2025-11-14 17:55:33	2025-11-14 17:55:33
347	1.00	2025-11-14	\N	t	46	53	2025-11-14 17:55:33	2025-11-14 17:55:33
348	1.00	2025-11-14	\N	t	47	53	2025-11-14 17:55:33	2025-11-14 17:55:33
349	1.00	2025-11-14	\N	t	48	53	2025-11-14 17:55:33	2025-11-14 17:55:33
350	1.00	2025-11-14	\N	t	49	53	2025-11-14 17:55:33	2025-11-14 17:55:33
351	1.00	2025-11-14	\N	t	50	53	2025-11-14 17:55:33	2025-11-14 17:55:33
352	1.00	2025-11-14	\N	t	52	41	2025-11-14 17:55:33	2025-11-14 17:55:33
353	1.00	2025-11-14	\N	t	51	41	2025-11-14 17:55:33	2025-11-14 17:55:33
354	1.00	2025-11-14	\N	t	54	41	2025-11-14 17:55:33	2025-11-14 17:55:33
355	1.00	2025-11-14	\N	t	53	41	2025-11-14 17:55:33	2025-11-14 17:55:33
356	1.00	2025-11-14	\N	t	236	42	2025-11-14 17:55:33	2025-11-14 17:55:33
\.


--
-- Data for Name: comptes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.comptes ("Id_Compte", "Code_compte", "Libelle", "Id_Rubrique") FROM stdin;
1	101	Capital	1
2	104	Primes liees au capital social	1
3	105	Ecart de evaluation	1
4	106	Reserves	1
5	107	Ecart de equivalence	1
6	108	Compte de lexploitant	1
7	109	Actionnaires, capital souscrit non appele	1
8	110	Report a nouveau solde crediteur	2
9	119	Report a nouveau solde debiteur	2
10	120	Resultat de lexercice (benefice)	3
11	129	Resultat de lexercice (perte)	3
12	131	Subventions dequipement	4
13	132	Autres subventions dinvestissement	4
14	133	Impots differes actif	4
15	134	Impots differes passif	4
16	138	Autres produits et charges differes	4
17	153	Provisions pour pensions et obligations similaires	6
18	155	Provisions pour impots	6
19	156	Provisions pour renouvellement des immobilisations (concession)	6
20	158	Autres provisions pour charges - passifs non courants	6
21	161	Emprunts obligataires convertibles	7
22	163	Autres emprunts obligataires	7
23	164	Emprunts aupres des etablissements de credit	7
24	165	Depots et cautionnements recus	7
25	167	Dettes sur contrat de location-financement	7
26	168	Autres emprunts et dettes assimiles	7
27	169	Primes de remboursement des obligations	7
28	171	Dettes rattachees a des participations groupe	8
29	172	Dettes rattachees a des participations hors groupe	8
30	173	Dettes rattachees a des societes en participation	8
31	178	Autres dettes rattachees a des participations	8
32	181	Comptes de liaison entre etablissements	9
33	188	Comptes de liaison entre societes en participation	9
34	203	Frais de developpement immobilisables	11
35	204	Logiciels informatiques et assimiles	11
36	205	Concessions et droits similaires, brevets, licences, marques	11
37	207	Fonds commercial	11
38	208	Autres immobilisations incorporelles	11
39	211	Terrains	12
40	212	Agencements et amenagements de terrain	12
41	213	Constructions	12
42	215	Installations techniques	12
43	218	Autres immobilisations corporelles	12
44	221	Terrains en concession	13
45	222	Agencements et amenagements de terrain en concession	13
46	223	Constructions en concession	13
47	225	Installations techniques en concession	13
48	228	Autres immobilisations corporelles en concession	13
49	229	Droits du concedant	13
50	232	Immobilisations corporelles en cours	14
51	237	Immobilisations incorporelles en cours	14
52	238	Avances et acomptes verses sur commandes dimmobilisations	14
53	261	Titres de participation	17
54	262	Autres formes de participations	17
55	265	Titres de participation evalues par equivalence	17
56	266	Creances rattachees a des participations groupe	17
57	267	Creances rattachees a des participations hors groupe	17
58	268	Creances rattachees a des societes en participation	17
59	269	Versements restant a effectuer sur titres de participation non liberes	17
60	271	Titres immobilises autres que titres immobilises de lactivite de portefeuille	18
61	272	Titres representatifs de droit de creance (obligations, bons)	18
62	273	Titres immobilises de lactivite de portefeuille	18
63	274	Prets	18
64	275	Depots et cautionnements verses	18
65	276	Autres creances immobilisees	18
66	277	Actions propres (ou parts propres)	18
67	279	Versements restant a effectuer sur titres immobilises non liberes	18
68	280	Amortissement des immobilisations incorporelles	19
69	281	Amortissement des immobilisations corporelles	19
70	282	Amortissement des immobilisations mises en concession	19
71	290	Perte de valeur sur immobilisations incorporelles	20
72	291	Perte de valeur sur immobilisations corporelles	20
73	292	Depreciation sur immobilisations mises en concession	20
74	293	Perte de valeur sur immobilisations en cours	20
75	296	Perte de valeur sur participations et creances rattachees a participations	20
76	297	Perte de valeur sur autres immobilisations financieres	20
77	321	Matiere consommables	22
78	322	Fournitures consommables	22
79	326	Emballages	22
80	331	Produit en-cours	23
81	335	Travaux en-cours 	23
82	341	Etudes en-cours	24
83	345	Prestations de service en cours	24
84	351	Produits intermediaires	25
85	355	Produits finis	25
86	358	Produits residuels ou matieres de recuperation (dechets,rebuts)	25
87	391	Perte de valeur sur matieres premieres et fournitures	29
88	392	Perte de valeur sur autres approvisionnements	29
89	393	Perte de valeur sur en-cours de production de biens	29
90	394	Perte de valeur sur en-cours de production de services	29
91	395	Perte de valeur sur produits	29
92	397	Perte de valeur sur stocks provenant dapprovisionnements	29
93	398	Perte de valeur sur stocks provenant dimmobilisations	29
94	401	Fournisseurs de biens et services	30
95	403	Fournisseurs - effets a payer	30
96	404	Fournisseurs - immobilisations	30
97	405	Fournisseurs - immobilisations effets a payer	30
98	408	Fournisseurs - factures non parvenues	30
99	409	Fournisseurs debiteurs  : avances et acomptes, RRR a obtenir, autres creances	30
100	411	Clients	31
101	413	Clients - effets a recevoir	31
102	416	Clients douteux	31
103	417	Creances sur travaux non encore facturables	31
104	418	Clients - produits non encore factures	31
105	419	Clients crediteurs	31
106	421	Personnel - remunerations dues	32
107	422	Fonds sociaux - oeuvres sociales	32
108	425	Personnel - avances et acomptes	32
109	426	Personnel - depot reçus	32
110	427	Personnel oppositions	32
111	428	Personnel - charges a payer et produits a recevoir	32
112	431	 Organismes sociaux A	33
113	432	 Organismes sociaux B	33
114	438	Organismes sociaux, charges a payer	33
115	441	Etat, subventions a recevoir	34
116	442	Etat, impots et taxes recouvrables sur des tiers	34
117	443	Operations particulieres avec lEtat et autres organismes publiques	34
118	444	Etat, impots sur les resultats	34
119	445	Etat, taxes sur le chiffre d affaires	34
120	447	Autres impots, taxes et versements assimiles	34
121	448	Etat, charges a payer et produits a recevoir	34
122	451	Operations Groupe	35
123	455	Associes - comptes courants	35
124	456	Associes, operations sur le capital	35
125	457	Associes, dividendes a payer	35
126	458	Associes, operations faites en commun ou en groupement	35
127	462	Creances sur cessions d immobilisations	36
128	464	Dettes sur acquisitions de valeurs mobilieres de placement	36
129	465	Creances sur cessions de valeurs mobilieres de placement	36
130	467	Autres comptes debiteurs ou crediteurs	36
131	468	Divers charges a payer ou produits a recevoir	36
132	481	Provisions - passifs courants	38
133	486	Charges constatees d avance	38
134	487	Produits constates d avance	38
135	491	Perte de valeur sur comptes de clients	39
136	495	Perte de valeur sur comptes du groupe et des associes	39
137	498	Pertes de valeur sur comptes de débiteurs divers	39
138	501	Parts dans des entreprises liees	40
139	503	Actions	40
140	504	Autres titres conferant un droit de propriete	40
141	505	Obligations et bons emis par la societe et rachetes par elle	40
142	506	Obligations	40
143	507	Bons du tresor et bons de caisse a court terme	40
144	508	Autres valeurs mobilieres de placement et creances assimilees	40
145	509	Versements restant a effectuer sur VMP non liberees	40
146	511	Valeurs a l encaissement	41
147	512	Banques comptes courants	41
148	515	Caisse du Tresor Public et etablissements publics	41
149	517	Autres organismes financiers	41
150	518	Interets courus	41
151	519	Concours bancaires courants	41
152	581	Virements de fonds	48
153	588	Autres virements internes	48
154	591	Pertes de valeur sur valeurs en banque et etablissements financiers	49
155	594	Pertes de valeur sur regies d avances et accredtitifs	49
156	601	Matières premières	50
157	602	Autres approvisionnements	50
158	603	Variations des stocks	50
159	604	Achats d’études et de prestations de service	50
160	605	Achats de matériels, équipements et travaux	50
161	606	Achats non stockés de matières et fournitures	50
162	607	Achats de marchandises	50
163	608	Frais accessoires d’achat	50
164	609	Rabais, remises et ristournes obtenus sur achats	50
165	611	Sous-traitance générale	51
166	613	Locations	51
167	614	Charges locatives et de copropriété	51
168	615	Entretien, réparations et maintenance	51
169	616	Primes d’assurances	51
170	617	Études et recherches	51
171	618	Documentation et divers	51
172	619	Rabais, remises, ristournes sur services extérieurs	51
173	621	Personnel extérieur à l’entreprise	52
174	622	Rémunérations d’intermédiaires et honoraires	52
175	623	Publicité, publication, relations publiques	52
176	624	Transports de biens et transport collectif du personnel	52
177	625	Déplacements, missions et réceptions	52
178	626	Frais postaux et de télécommunications	52
179	627	Services bancaires et assimilés	52
180	628	Cotisations et divers	52
181	629	Rabais, remises, ristournes sur autres services extérieurs	52
182	631	Impôts, taxes et versements assimilés sur rémunérations	53
183	635	Autres impôts et taxes	53
184	641	Rémunérations du personnel	54
185	644	Rémunérations des dirigeants	54
186	645	Cotisations aux organismes sociaux	54
187	646	Charges sociales sur rémunérations des dirigeants	54
188	647	Autres charges sociales	54
189	648	Autres charges de personnel	54
190	651	Redevances pour concessions, brevets, licences, logiciels et valeurs similaires	55
191	652	Moins-values sur cessions d’actifs non courants	55
192	653	Jetons de présence	55
193	654	Pertes sur créances irrécouvrables	55
194	655	Quote-part de résultat sur opérations faites en commun	55
195	656	Amendes, pénalités, subventions accordées, dons et libéralités	55
196	657	Charges exceptionnelles de gestion courante	55
197	658	Autres charges de gestion courante	55
198	661	Charges d’intérêts	56
199	664	Pertes sur créances liées à des participations	56
200	665	Moins-values sur titres de placement	56
201	666	Pertes de change	56
202	667	Moins-values sur instruments financiers et assimilés	56
203	668	Autres charges financières	56
204	681	Dotations - actifs non courants	58
205	685	Dotations - actifs courants	58
206	692	Imposition différée actif	59
207	693	Imposition différée passif	59
208	695	Impôts sur les bénéfices basés sur le résultat des activités ordinaires	59
209	698	Autres impôts sur les résultats	59
210	701	Ventes de produits finis	60
211	702	Ventes de produits intermediaires	60
212	703	Ventes de produits residuels	60
213	704	Vente de travaux	60
214	705	Vente detudes	60
215	706	Vente de prestations de service	60
216	707	Ventes de marchandises	60
217	708	Produits des activites annexes	60
218	709	Rabais, remises et ristournes accordes	60
219	713	Variation de stocks den cours	61
220	714	Variation de stocks de produits	61
221	721	Production immobilisee d actif incorporel	62
222	722	Production immobilisee d actif corporel	62
223	741	Subvention dequilibre	63
224	748	Autres subventions dexploitation	63
225	751	Redevances pour concessions, brevets, licences, logiciels et valeurs similaires	64
226	752	Plus values sur cessions d actifs non courants	64
227	753	Jetons de presence et remunerations dadministrateurs ou de gerant	64
228	754	Quotes parts de subventions dinvestissement virees au resultat	64
229	755	Quote part de resultat sur operations faites en commun	64
230	756	Liberalites percues, entrees sur creances amorties	64
231	757	Produits exceptionnels sur operations de gestion	64
232	758	Autres produits de gestion courante	64
233	761	Produits de participations	65
234	762	Produits des autres immobilisations financieres	65
235	763	Revenus des autres creances	65
236	764	Revenus et plus values des valeurs mobilieres de placement	65
237	766	Gains de change	65
238	767	Produits nets sur cessions de valeurs mobilieres de placement	65
239	768	Autres produits financiers	65
240	781	Reprise dexploitation - actifs non courants	67
241	785	Reprise dexploitation - actifs courants	67
242	786	Reprises financieres	67
243	531	Caisse école	43
\.


--
-- Data for Name: devises; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.devises ("Id_Devise", "Libelle", "Code", "Sigle") FROM stdin;
1	Ariary	MGA	MGA
\.


--
-- Data for Name: durees; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.durees (id_duree, code, libelle, created_at, updated_at) FROM stdin;
1	CT	Court terme	2025-10-14 08:54:41	2025-10-14 08:54:41
2	LT	Long terme	2025-10-14 08:54:41	2025-10-14 08:54:41
3	MIXTE	Mixte	2025-10-14 08:54:41	2025-10-14 08:54:41
\.


--
-- Data for Name: email_verifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.email_verifications (id, email, token, created_at) FROM stdin;
\.


--
-- Data for Name: errors; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.errors (id, message, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: evenements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.evenements (id, type_evenement_id, donnees_evenement) FROM stdin;
1	2	{"nom_fichier":"Ecriture 2025.csv","nombre_mouvements":237,"nombre_lignes":498}
2	5	{"nombre_ecritures":498,"date_cloture":"2025-12-31","exercice_id":8,"annee_fiscale":2025,"lien_redirection":"http:\\/\\/localhost:5173\\/ecritures-a-valider"}
\.


--
-- Data for Name: exercice_comptable; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.exercice_comptable ("Id_Exercice_comptable", "Date_debut", "Date_fin", "Statut", "Annee_fiscale", created_at, updated_at) FROM stdin;
1	2018-01-01	2018-12-31	CLOTURE	2018	2025-10-27 16:22:43	2025-10-27 16:22:43
2	2019-01-01	2019-12-31	CLOTURE	2019	2025-10-27 16:22:43	2025-10-27 16:22:43
3	2020-01-01	2020-12-31	CLOTURE	2020	2025-10-27 16:22:43	2025-10-27 16:22:43
4	2021-01-01	2021-12-31	CLOTURE	2021	2025-10-27 16:22:43	2025-10-27 16:22:43
5	2022-01-01	2022-12-31	CLOTURE	2022	2025-10-27 16:22:43	2025-10-27 16:22:43
6	2023-01-01	2023-12-31	CLOTURE	2023	2025-10-27 16:22:43	2025-10-27 16:22:43
7	2024-01-01	2024-12-31	CLOTURE	2024	2025-10-27 16:22:43	2025-10-27 16:22:43
8	2025-01-01	2025-12-31	OUVERT	2025	2025-10-27 16:22:43	2025-10-27 16:22:43
9	2026-01-01	2026-12-31	CLOTURE	2026	2025-10-27 16:22:43	2025-10-27 16:22:43
10	2027-01-01	2027-12-31	CLOTURE	2027	2025-10-27 16:22:43	2025-10-27 16:22:43
11	2028-01-01	2028-12-31	CLOTURE	2028	2025-10-27 16:22:43	2025-10-27 16:22:43
12	2029-01-01	2029-12-31	CLOTURE	2029	2025-10-27 16:22:43	2025-10-27 16:22:43
13	2030-01-01	2030-12-31	CLOTURE	2030	2025-10-27 16:22:43	2025-10-27 16:22:43
14	2031-01-01	2031-12-31	CLOTURE	2031	2025-10-27 16:22:43	2025-10-27 16:22:43
15	2032-01-01	2032-12-31	CLOTURE	2032	2025-10-27 16:22:43	2025-10-27 16:22:43
16	2033-01-01	2033-12-31	CLOTURE	2033	2025-10-27 16:22:43	2025-10-27 16:22:43
17	2034-01-01	2034-12-31	CLOTURE	2034	2025-10-27 16:22:43	2025-10-27 16:22:43
18	2035-01-01	2035-12-31	CLOTURE	2035	2025-10-27 16:22:43	2025-10-27 16:22:43
19	2036-01-01	2036-12-31	CLOTURE	2036	2025-10-27 16:22:43	2025-10-27 16:22:43
20	2037-01-01	2037-12-31	CLOTURE	2037	2025-10-27 16:22:43	2025-10-27 16:22:43
21	2038-01-01	2038-12-31	CLOTURE	2038	2025-10-27 16:22:43	2025-10-27 16:22:43
\.


--
-- Data for Name: failed_jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.failed_jobs (id, uuid, connection, queue, payload, exception, failed_at) FROM stdin;
\.


--
-- Data for Name: fonction_economiques; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.fonction_economiques (id_fonction_economique, code, libelle, created_at, updated_at) FROM stdin;
1	FINANCE	Financement	2025-10-14 08:55:22	2025-10-14 08:55:22
2	INVEST	Investissement	2025-10-14 08:55:22	2025-10-14 08:55:22
3	EXPLOIT	Exploitation	2025-10-14 08:55:22	2025-10-14 08:55:22
4	TRESO	Trésorerie	2025-10-14 08:55:22	2025-10-14 08:55:22
5	EXCEPT	Exceptionnel	2025-10-14 08:55:22	2025-10-14 08:55:22
\.


--
-- Data for Name: immobilisations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.immobilisations (id, libelle, "Id_Sous_compte", taux_amortissement_id, valeur_brute, date_acquisition, date_debut_utilisation, created_at, updated_at) FROM stdin;
1	Mobilier	12	3	200000.00	2025-10-30	2025-10-30	2025-10-30 20:19:54	2025-10-30 20:19:54
2	Ordinateurs	10	1	2000000.00	2024-06-01	2025-01-01	2025-10-31 06:45:52	2025-10-31 06:45:52
3	MMB	7	3	5400000.00	2025-01-01	2025-10-01	2025-10-31 06:48:23	2025-10-31 06:48:23
4	Immo	11	1	100000.00	2025-11-15	2025-11-15	2025-10-31 06:56:35	2025-10-31 06:56:35
5	Voiture	13	1	24000000.00	2023-11-14	2023-11-14	2025-11-14 07:30:05	2025-11-14 07:30:05
\.


--
-- Data for Name: import_histories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.import_histories (id, nom_fichier, imported_at, imported_by, nombre_mouvements, nombre_lignes, statut, erreur, created_at, updated_at) FROM stdin;
1	Exercice 2025-2026.csv	2025-10-21 21:49:57	\N	16	34	échec	Sous-compte 129001 introuvable	2025-10-21 18:49:56	2025-10-21 18:49:56
2	Exercice 2025-2026.csv	2025-10-21 21:51:10	\N	16	35	réussi	\N	2025-10-21 18:51:09	2025-10-21 18:51:09
3	Exercice 2025-2026.csv	2025-10-21 21:57:31	\N	16	35	réussi	\N	2025-10-21 18:57:31	2025-10-21 18:57:31
4	Exercice 2024-2025.csv	2025-10-21 22:05:20	\N	0	0	échec	Ligne 38: Sous-compte 129001 introuvable	2025-10-21 19:05:20	2025-10-21 19:05:20
5	Exercice 2024-2025.csv	2025-10-21 22:05:56	\N	17	37	réussi	\N	2025-10-21 19:05:55	2025-10-21 19:05:55
6	Exercice 2025-2026.csv	2025-10-24 10:07:40	\N	16	35	réussi	\N	2025-10-24 07:07:40	2025-10-24 07:07:40
7	Exercice 2024-2025.csv	2025-10-24 10:08:45	\N	17	37	réussi	\N	2025-10-24 07:08:45	2025-10-24 07:08:45
8	Exercice 2024-2025.csv	2025-10-26 22:03:41	\N	0	0	échec	Ligne 2: Journal BNI introuvable\nLigne 3: Journal BNI introuvable\nLigne 4: Journal BNI introuvable\nLigne 5: Journal BNI introuvable\nLigne 6: Journal BNI introuvable\nLigne 7: Journal BNI introuvable\nLigne 8: Journal BNI introuvable\nLigne 9: Journal BNI introuvable\nLigne 10: Journal BNI introuvable\nLigne 11: Journal BNI introuvable\nLigne 12: Journal BNI introuvable\nLigne 13: Journal BNI introuvable\nLigne 14: Journal BNI introuvable\nLigne 15: Journal BNI introuvable\nLigne 16: Journal BNI introuvable\nLigne 17: Sous-compte 633001 introuvable\nLigne 17: Journal BNI introuvable\nLigne 18: Journal BNI introuvable\nLigne 19: Journal BNI introuvable\nLigne 20: Journal BNI introuvable\nLigne 21: Sous-compte 612001 introuvable\nLigne 21: Journal BNI introuvable\nLigne 22: Journal BNI introuvable\nLigne 23: Sous-compte 636001 introuvable\nLigne 23: Journal BNI introuvable\nLigne 24: Journal BNI introuvable\nLigne 25: Journal BNI introuvable\nLigne 26: Journal BNI introuvable\nLigne 27: Journal BNI introuvable\nLigne 28: Journal BNI introuvable\nLigne 29: Journal BNI introuvable\nLigne 30: Journal BNI introuvable\nLigne 31: Journal BNI introuvable\nLigne 32: Sous-compte 281001 introuvable\nLigne 32: Journal BNI introuvable\nLigne 33: Sous-compte 642001 introuvable\nLigne 33: Journal BNI introuvable\nLigne 34: Sous-compte 280001 introuvable\nLigne 34: Journal BNI introuvable\nLigne 35: Journal BNI introuvable\nLigne 36: Sous-compte 491001 introuvable\nLigne 36: Journal BNI introuvable\nLigne 37: Sous-compte 120001 introuvable\nLigne 37: Journal BNI introuvable\nLigne 38: Sous-compte 119001 introuvable\nLigne 38: Journal BNI introuvable	2025-10-26 19:03:41	2025-10-26 19:03:41
9	Ecriture teste.csv	2025-10-27 19:28:48	\N	0	0	échec	Ligne 3: Sous-compte 531001 introuvable\nLigne 5: Sous-compte 531001 introuvable\nLigne 7: Sous-compte 531001 introuvable\nLigne 9: Sous-compte 531001 introuvable\nLigne 11: Sous-compte 531001 introuvable\nLigne 13: Sous-compte 531001 introuvable\nLigne 15: Sous-compte 531001 introuvable\nLigne 16: Sous-compte 601006 introuvable\nLigne 17: Sous-compte 531001 introuvable\nLigne 18: Sous-compte 601008 introuvable\nLigne 19: Sous-compte 601009 introuvable\nLigne 20: Sous-compte 531001 introuvable\nLigne 22: Sous-compte 531001 introuvable\nLigne 24: Sous-compte 531001 introuvable\nLigne 26: Sous-compte 531001 introuvable\nLigne 28: Sous-compte 531001 introuvable\nLigne 29: Sous-compte 168001 introuvable\nLigne 30: Sous-compte 531001 introuvable\nLigne 32: Sous-compte 531001 introuvable\nLigne 34: Sous-compte 531001 introuvable\nLigne 36: Sous-compte 531001 introuvable\nLigne 37: Sous-compte 641002 introuvable\nLigne 38: Sous-compte 531001 introuvable\nLigne 39: Sous-compte 641002 introuvable\nLigne 40: Sous-compte 641002 introuvable\nLigne 41: Sous-compte 531001 introuvable\nLigne 43: Sous-compte 531001 introuvable\nLigne 44: Sous-compte 641004 introuvable\nLigne 45: Sous-compte 641005 introuvable\nLigne 46: Sous-compte 531001 introuvable	2025-10-27 16:28:47	2025-10-27 16:28:47
10	Ecriture teste.csv	2025-10-27 19:43:09	\N	0	0	échec	Ligne 16: Sous-compte 601006 introuvable\nLigne 18: Sous-compte 601008 introuvable\nLigne 19: Sous-compte 601009 introuvable	2025-10-27 16:43:08	2025-10-27 16:43:08
11	Ecriture teste.csv	2025-10-27 19:45:54	\N	12	45	réussi	\N	2025-10-27 16:45:54	2025-10-27 16:45:54
12	Ecriture teste - Copie.csv	2025-10-27 20:55:51	\N	12	45	réussi	\N	2025-10-27 17:55:50	2025-10-27 17:55:50
13	Ecriture teste - Copie.csv	2025-10-27 20:57:12	\N	12	45	réussi	\N	2025-10-27 17:57:11	2025-10-27 17:57:11
14	Ecriture teste - Copie.csv	2025-10-28 09:46:00	\N	12	45	réussi	\N	2025-10-28 06:46:00	2025-10-28 06:46:00
15	generated_ecritures_v2.csv	2025-10-28 14:18:58	\N	0	0	échec	Ligne 2: Code journal manquant\nLigne 3: Code journal manquant\nLigne 4: Code journal manquant\nLigne 5: Code journal manquant\nLigne 6: Code journal manquant\nLigne 7: Code journal manquant\nLigne 8: Code journal manquant\nLigne 9: Code journal manquant\nLigne 10: Code journal manquant\nLigne 11: Code journal manquant\nLigne 12: Code journal manquant\nLigne 13: Code journal manquant\nLigne 14: Code journal manquant\nLigne 15: Code journal manquant\nLigne 16: Code journal manquant\nLigne 17: Code journal manquant\nLigne 18: Code journal manquant\nLigne 19: Code journal manquant\nLigne 20: Code journal manquant\nLigne 21: Code journal manquant\nLigne 22: Code journal manquant\nLigne 23: Code journal manquant\nLigne 24: Code journal manquant\nLigne 25: Code journal manquant\nLigne 26: Code journal manquant\nLigne 27: Code journal manquant\nLigne 28: Code journal manquant\nLigne 29: Code journal manquant\nLigne 30: Code journal manquant\nLigne 31: Code journal manquant\nLigne 32: Code journal manquant\nLigne 33: Code journal manquant\nLigne 34: Code journal manquant\nLigne 35: Code journal manquant\nLigne 36: Code journal manquant\nLigne 37: Code journal manquant\nLigne 38: Code journal manquant\nLigne 39: Code journal manquant\nLigne 40: Code journal manquant\nLigne 41: Code journal manquant\nLigne 42: Code journal manquant\nLigne 43: Code journal manquant\nLigne 44: Code journal manquant\nLigne 45: Code journal manquant\nLigne 46: Code journal manquant\nLigne 47: Code journal manquant\nLigne 48: Code journal manquant\nLigne 49: Code journal manquant\nLigne 50: Code journal manquant\nLigne 51: Code journal manquant\nLigne 52: Code journal manquant\nLigne 53: Code journal manquant\nLigne 54: Code journal manquant\nLigne 55: Code journal manquant\nLigne 56: Code journal manquant\nLigne 57: Code journal manquant\nLigne 58: Code journal manquant\nLigne 59: Code journal manquant\nLigne 60: Code journal manquant\nLigne 61: Code journal manquant\nLigne 62: Code journal manquant\nLigne 63: Code journal manquant\nLigne 64: Code journal manquant\nLigne 65: Code journal manquant\nLigne 66: Code journal manquant\nLigne 67: Code journal manquant\nLigne 68: Code journal manquant\nLigne 69: Code journal manquant\nLigne 70: Code journal manquant\nLigne 71: Code journal manquant\nLigne 72: Code journal manquant\nLigne 73: Code journal manquant\nLigne 74: Code journal manquant\nLigne 75: Code journal manquant\nLigne 76: Code journal manquant\nLigne 77: Code journal manquant\nLigne 78: Code journal manquant\nLigne 79: Code journal manquant\nLigne 80: Code journal manquant\nLigne 81: Code journal manquant\nLigne 82: Code journal manquant\nLigne 83: Code journal manquant\nLigne 84: Code journal manquant\nLigne 85: Code journal manquant\nLigne 86: Code journal manquant\nLigne 87: Code journal manquant\nLigne 88: Code journal manquant\nLigne 89: Code journal manquant\nLigne 90: Code journal manquant\nLigne 91: Code journal manquant\nLigne 92: Code journal manquant\nLigne 93: Code journal manquant\nLigne 94: Code journal manquant\nLigne 95: Code journal manquant\nLigne 96: Code journal manquant\nLigne 97: Code journal manquant\nLigne 98: Code journal manquant\nLigne 99: Code journal manquant\nLigne 100: Code journal manquant\nLigne 101: Code journal manquant\nLigne 102: Code journal manquant\nLigne 103: Code journal manquant\nLigne 104: Code journal manquant\nLigne 105: Code journal manquant\nLigne 106: Code journal manquant\nLigne 107: Code journal manquant\nLigne 108: Code journal manquant\nLigne 109: Code journal manquant\nLigne 110: Code journal manquant\nLigne 111: Code journal manquant\nLigne 112: Code journal manquant\nLigne 113: Code journal manquant\nLigne 114: Code journal manquant\nLigne 115: Code journal manquant\nLigne 116: Code journal manquant\nLigne 117: Code journal manquant\nLigne 118: Code journal manquant\nLigne 119: Code journal manquant\nLigne 120: Code journal manquant\nLigne 121: Code journal manquant\nLigne 122: Code journal manquant\nLigne 123: Code journal manquant\nLigne 124: Code journal manquant\nLigne 125: Code journal manquant\nLigne 126: Code journal manquant\nLigne 127: Code journal manquant\nLigne 128: Code journal manquant\nLigne 129: Code journal manquant\nLigne 130: Code journal manquant\nLigne 131: Code journal manquant\nLigne 132: Code journal manquant\nLigne 133: Code journal manquant\nLigne 134: Code journal manquant\nLigne 135: Code journal manquant\nLigne 136: Code journal manquant\nLigne 137: Code journal manquant\nLigne 138: Code journal manquant\nLigne 139: Code journal manquant\nLigne 140: Code journal manquant\nLigne 141: Code journal manquant\nLigne 142: Code journal manquant\nLigne 143: Code journal manquant\nLigne 144: Code journal manquant\nLigne 145: Code journal manquant\nLigne 146: Code journal manquant\nLigne 147: Code journal manquant\nLigne 148: Code journal manquant\nLigne 149: Code journal manquant\nLigne 150: Code journal manquant\nLigne 151: Code journal manquant\nLigne 152: Code journal manquant\nLigne 153: Code journal manquant\nLigne 154: Code journal manquant\nLigne 155: Code journal manquant\nLigne 156: Code journal manquant\nLigne 157: Code journal manquant\nLigne 158: Code journal manquant\nLigne 159: Code journal manquant\nLigne 160: Code journal manquant\nLigne 161: Code journal manquant\nLigne 162: Code journal manquant\nLigne 163: Code journal manquant\nLigne 164: Code journal manquant\nLigne 165: Code journal manquant\nLigne 166: Code journal manquant\nLigne 167: Code journal manquant\nLigne 168: Code journal manquant\nLigne 169: Code journal manquant\nLigne 170: Code journal manquant\nLigne 171: Code journal manquant\nLigne 172: Code journal manquant\nLigne 173: Code journal manquant\nLigne 174: Code journal manquant\nLigne 175: Code journal manquant\nLigne 176: Code journal manquant\nLigne 177: Code journal manquant\nLigne 178: Code journal manquant\nLigne 179: Code journal manquant\nLigne 180: Code journal manquant\nLigne 181: Code journal manquant\nLigne 182: Code journal manquant\nLigne 183: Code journal manquant\nLigne 184: Code journal manquant\nLigne 185: Code journal manquant\nLigne 186: Code journal manquant\nLigne 187: Code journal manquant\nLigne 188: Code journal manquant\nLigne 189: Code journal manquant\nLigne 190: Code journal manquant\nLigne 191: Code journal manquant\nLigne 192: Code journal manquant\nLigne 193: Code journal manquant\nLigne 194: Code journal manquant\nLigne 195: Code journal manquant\nLigne 196: Code journal manquant\nLigne 197: Code journal manquant\nLigne 198: Code journal manquant\nLigne 199: Code journal manquant\nLigne 200: Code journal manquant\nLigne 201: Code journal manquant\nLigne 202: Code journal manquant\nLigne 203: Code journal manquant\nLigne 204: Code journal manquant\nLigne 205: Code journal manquant\nLigne 206: Code journal manquant\nLigne 207: Code journal manquant\nLigne 208: Code journal manquant\nLigne 209: Code journal manquant\nLigne 210: Code journal manquant\nLigne 211: Code journal manquant\nLigne 212: Code journal manquant\nLigne 213: Code journal manquant\nLigne 214: Code journal manquant\nLigne 215: Code journal manquant\nLigne 216: Code journal manquant\nLigne 217: Code journal manquant\nLigne 218: Code journal manquant\nLigne 219: Code journal manquant\nLigne 220: Code journal manquant\nLigne 221: Code journal manquant\nLigne 222: Code journal manquant\nLigne 223: Code journal manquant\nLigne 224: Code journal manquant\nLigne 225: Code journal manquant\nLigne 226: Code journal manquant\nLigne 227: Code journal manquant\nLigne 228: Code journal manquant\nLigne 229: Code journal manquant\nLigne 230: Code journal manquant\nLigne 231: Code journal manquant\nLigne 232: Code journal manquant\nLigne 233: Code journal manquant\nLigne 234: Code journal manquant\nLigne 235: Code journal manquant\nLigne 236: Code journal manquant\nLigne 237: Code journal manquant\nLigne 238: Code journal manquant\nLigne 239: Code journal manquant\nLigne 240: Code journal manquant\nLigne 241: Code journal manquant\nLigne 242: Code journal manquant\nLigne 243: Code journal manquant\nLigne 244: Code journal manquant\nLigne 245: Code journal manquant\nLigne 246: Code journal manquant\nLigne 247: Code journal manquant\nLigne 248: Code journal manquant\nLigne 249: Code journal manquant\nLigne 250: Code journal manquant\nLigne 251: Code journal manquant\nLigne 252: Code journal manquant\nLigne 253: Code journal manquant\nLigne 254: Code journal manquant\nLigne 255: Code journal manquant\nLigne 256: Code journal manquant\nLigne 257: Code journal manquant\nLigne 258: Code journal manquant\nLigne 259: Code journal manquant\nLigne 260: Code journal manquant\nLigne 261: Code journal manquant\nLigne 262: Code journal manquant\nLigne 263: Code journal manquant\nLigne 264: Code journal manquant\nLigne 265: Code journal manquant\nLigne 266: Code journal manquant\nLigne 267: Code journal manquant\nLigne 268: Code journal manquant\nLigne 269: Code journal manquant\nLigne 270: Code journal manquant\nLigne 271: Code journal manquant\nLigne 272: Code journal manquant\nLigne 273: Code journal manquant\nLigne 274: Code journal manquant\nLigne 275: Code journal manquant\nLigne 276: Code journal manquant\nLigne 277: Code journal manquant\nLigne 278: Code journal manquant\nLigne 279: Code journal manquant\nLigne 280: Code journal manquant\nLigne 281: Code journal manquant\nLigne 282: Code journal manquant\nLigne 283: Code journal manquant\nLigne 284: Code journal manquant\nLigne 285: Code journal manquant\nLigne 286: Code journal manquant\nLigne 287: Code journal manquant\nLigne 288: Code journal manquant\nLigne 289: Code journal manquant\nLigne 290: Code journal manquant\nLigne 291: Code journal manquant\nLigne 292: Code journal manquant\nLigne 293: Code journal manquant\nLigne 294: Code journal manquant\nLigne 295: Code journal manquant\nLigne 296: Code journal manquant\nLigne 297: Code journal manquant\nLigne 298: Code journal manquant\nLigne 299: Code journal manquant\nLigne 300: Code journal manquant\nLigne 301: Code journal manquant\nLigne 302: Code journal manquant\nLigne 303: Code journal manquant\nLigne 304: Code journal manquant\nLigne 305: Code journal manquant\nLigne 306: Code journal manquant\nLigne 307: Code journal manquant\nLigne 308: Code journal manquant\nLigne 309: Code journal manquant\nLigne 310: Code journal manquant\nLigne 311: Code journal manquant\nLigne 312: Code journal manquant\nLigne 313: Code journal manquant\nLigne 314: Code journal manquant\nLigne 315: Code journal manquant\nLigne 316: Code journal manquant\nLigne 317: Code journal manquant\nLigne 318: Code journal manquant\nLigne 319: Code journal manquant\nLigne 320: Code journal manquant\nLigne 321: Code journal manquant\nLigne 322: Code journal manquant\nLigne 323: Code journal manquant\nLigne 324: Code journal manquant\nLigne 325: Code journal manquant\nLigne 326: Code journal manquant\nLigne 327: Code journal manquant\nLigne 328: Code journal manquant\nLigne 329: Code journal manquant\nLigne 330: Code journal manquant\nLigne 331: Code journal manquant\nLigne 332: Code journal manquant\nLigne 333: Code journal manquant\nLigne 334: Code journal manquant\nLigne 335: Code journal manquant\nLigne 336: Code journal manquant\nLigne 337: Code journal manquant\nLigne 338: Code journal manquant\nLigne 339: Code journal manquant\nLigne 340: Code journal manquant\nLigne 341: Code journal manquant\nLigne 342: Code journal manquant\nLigne 343: Code journal manquant\nLigne 344: Code journal manquant\nLigne 345: Code journal manquant\nLigne 346: Code journal manquant\nLigne 347: Code journal manquant\nLigne 348: Code journal manquant\nLigne 349: Code journal manquant\nLigne 350: Code journal manquant\nLigne 351: Code journal manquant\nLigne 352: Code journal manquant\nLigne 353: Code journal manquant\nLigne 354: Code journal manquant\nLigne 355: Code journal manquant\nLigne 356: Code journal manquant\nLigne 357: Code journal manquant\nLigne 358: Code journal manquant\nLigne 359: Code journal manquant\nLigne 360: Code journal manquant\nLigne 361: Code journal manquant\nLigne 362: Code journal manquant\nLigne 363: Code journal manquant\nLigne 364: Code journal manquant\nLigne 365: Code journal manquant\nLigne 366: Code journal manquant\nLigne 367: Code journal manquant\nLigne 368: Code journal manquant\nLigne 369: Code journal manquant\nLigne 370: Code journal manquant\nLigne 371: Code journal manquant\nLigne 372: Code journal manquant\nLigne 373: Code journal manquant\nLigne 374: Code journal manquant\nLigne 375: Code journal manquant\nLigne 376: Code journal manquant\nLigne 377: Code journal manquant\nLigne 378: Code journal manquant\nLigne 379: Code journal manquant\nLigne 380: Code journal manquant\nLigne 381: Code journal manquant\nLigne 382: Code journal manquant\nLigne 383: Code journal manquant\nLigne 384: Code journal manquant\nLigne 385: Code journal manquant\nLigne 386: Code journal manquant\nLigne 387: Code journal manquant\nLigne 388: Code journal manquant\nLigne 389: Code journal manquant\nLigne 390: Code journal manquant\nLigne 391: Code journal manquant\nLigne 392: Code journal manquant\nLigne 393: Code journal manquant\nLigne 394: Code journal manquant\nLigne 395: Code journal manquant\nLigne 396: Code journal manquant\nLigne 397: Code journal manquant\nLigne 398: Code journal manquant\nLigne 399: Code journal manquant\nLigne 400: Code journal manquant\nLigne 401: Code journal manquant\nLigne 402: Code journal manquant\nLigne 403: Code journal manquant\nLigne 404: Code journal manquant\nLigne 405: Code journal manquant\nLigne 406: Code journal manquant\nLigne 407: Code journal manquant\nLigne 408: Code journal manquant\nLigne 409: Code journal manquant\nLigne 410: Code journal manquant\nLigne 411: Code journal manquant\nLigne 412: Code journal manquant\nLigne 413: Code journal manquant\nLigne 414: Code journal manquant\nLigne 415: Code journal manquant\nLigne 416: Code journal manquant\nLigne 417: Code journal manquant\nLigne 418: Code journal manquant\nLigne 419: Code journal manquant\nLigne 420: Code journal manquant\nLigne 421: Code journal manquant\nLigne 422: Code journal manquant\nLigne 423: Code journal manquant\nLigne 424: Code journal manquant\nLigne 425: Code journal manquant\nLigne 426: Code journal manquant\nLigne 427: Code journal manquant\nLigne 428: Code journal manquant\nLigne 429: Code journal manquant\nLigne 430: Code journal manquant\nLigne 431: Code journal manquant\nLigne 432: Code journal manquant\nLigne 433: Code journal manquant\nLigne 434: Code journal manquant\nLigne 435: Code journal manquant\nLigne 436: Code journal manquant\nLigne 437: Code journal manquant\nLigne 438: Code journal manquant\nLigne 439: Code journal manquant\nLigne 440: Code journal manquant\nLigne 441: Code journal manquant	2025-10-28 11:18:58	2025-10-28 11:18:58
16	generated_ecritures_v2.csv	2025-10-28 14:19:27	\N	220	440	réussi	\N	2025-10-28 11:19:26	2025-10-28 11:19:26
17	Ecriture teste.csv	2025-10-30 10:34:43	\N	12	45	réussi	\N	2025-10-30 07:34:43	2025-10-30 07:34:43
18	generated_ecritures_v2.csv	2025-10-30 14:01:17	\N	220	440	réussi	\N	2025-10-30 11:01:17	2025-10-30 11:01:17
19	generated_ecritures_v2.csv	2025-11-01 00:07:36	\N	220	440	réussi	\N	2025-10-31 21:07:35	2025-10-31 21:07:35
20	Exercice 2025-2026.csv	2025-11-03 21:17:30	\N	0	0	échec	Ligne 15: Sous-compte 633001 introuvable\nLigne 19: Sous-compte 612002 introuvable\nLigne 21: Sous-compte 636001 introuvable\nLigne 31: Sous-compte 642001 introuvable\nLigne 32: Sous-compte 280001 introuvable\nLigne 34: Sous-compte 491001 introuvable\nLigne 35: Sous-compte 120001 introuvable\nLigne 36: Sous-compte 119001 introuvable	2025-11-03 18:17:30	2025-11-03 18:17:30
21	generated_ecritures_v2.csv	2025-11-03 21:48:51	\N	220	440	réussi	\N	2025-11-03 18:48:50	2025-11-03 18:48:50
22	Exercice 2025-2026.csv	2025-11-11 14:33:47	\N	0	0	échec	Ligne 15: Sous-compte 633001 introuvable\nLigne 19: Sous-compte 612002 introuvable\nLigne 21: Sous-compte 636001 introuvable\nLigne 31: Sous-compte 642001 introuvable\nLigne 32: Sous-compte 280001 introuvable\nLigne 34: Sous-compte 491001 introuvable\nLigne 35: Sous-compte 120001 introuvable\nLigne 36: Sous-compte 119001 introuvable	2025-11-11 11:33:46	2025-11-11 11:33:46
23	Exercice 2025-2026.csv	2025-11-11 14:41:39	\N	0	0	échec	Ligne 15: Sous-compte 633001 introuvable\nLigne 19: Sous-compte 612002 introuvable\nLigne 21: Sous-compte 636001 introuvable\nLigne 31: Sous-compte 642001 introuvable\nLigne 32: Sous-compte 280001 introuvable\nLigne 34: Sous-compte 491001 introuvable\nLigne 35: Sous-compte 120001 introuvable\nLigne 36: Sous-compte 119001 introuvable	2025-11-11 11:41:38	2025-11-11 11:41:38
24	Ecriture teste.csv	2025-11-11 14:42:52	\N	12	45	réussi	\N	2025-11-11 11:42:52	2025-11-11 11:42:52
25	Ecriture 2023.csv	2025-11-14 10:20:47	\N	208	440	réussi	\N	2025-11-14 07:20:47	2025-11-14 07:20:47
26	Ecriture 2024.csv	2025-11-14 10:21:09	\N	225	474	réussi	\N	2025-11-14 07:21:09	2025-11-14 07:21:09
27	Ecriture 2025.csv	2025-11-14 10:21:30	\N	237	498	réussi	\N	2025-11-14 07:21:29	2025-11-14 07:21:29
28	Ecriture 2025.csv	2025-11-16 20:44:34	\N	237	498	réussi	\N	2025-11-16 17:44:33	2025-11-16 17:44:33
\.


--
-- Data for Name: indicateurs_analytique; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.indicateurs_analytique (id_indicateur_analytique, libelle, description, formule) FROM stdin;
1	Total Produits	Tous les revenus de l'école	Somme des comptes de classe 7
2	Total Charges	Ensemble des dépenses	Somme des comptes de classe 6
3	Résultat net	Bénéfice ou perte de l'exercice	Produits – Charges
4	Marge d'exploitation	Capacité de l'école à dégager une marge sur son activité	(Produits d'exploitation – Charges d'exploitation) / Produits d'exploitation × 100
5	Nombre d'élèves	Sert à calculer les ratios par élève	Donnée administrative
6	Marge brute	Mesure la rentabilité opérationnelle de base	(Chiffre d'affaires – Coût des ventes) / Chiffre d'affaires
7	Marge d'exploitation (EBIT)	Évalue la performance des activités principales	Résultat d'exploitation / Chiffre d'affaires
8	Marge nette	Montre le bénéfice final par euro de ventes	Résultat net / Chiffre d'affaires
9	ROE (Return on Equity)	Rendement des fonds propres	Résultat net / Capitaux propres
10	ROA (Return on Assets)	Efficacité globale des actifs	Résultat net / Total actif
11	Ratio de liquidité générale	> 1 indique une bonne solvabilité à court terme	Actif circulant / Passif à court terme
12	Trésorerie Nette	Solde de trésorerie	Encaissements - Décaissements
13	Besoin en fonds de roulement (BFR)	Permet d'évaluer le besoin financier d'exploitation	(Stocks + Créances clients) - Dettes fournisseurs
14	Ratio d'endettement	Plus il est faible, plus la structure est solide	Dettes financières / Capitaux propres
15	Autonomie financière	> 30% = bonne autonomie financière	Capitaux propres / Total bilan
16	Capacité de remboursement	Nombre d'années nécessaires pour rembourser la dette	Endettement net / CAF (Cash Flow)
\.


--
-- Data for Name: interpretation_indicateur; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.interpretation_indicateur (id_interpretation_indicateur, id_indicateur_analytique, valeur, interpretation, id_niveau_alerte) FROM stdin;
1	1	0.00	Tous les revenus de l'école	3
2	2	0.00	Ensemble des dépenses	3
3	3	0.00	Bénéfice de l'exercice	3
4	3	-1.00	Perte de l'exercice	1
5	4	20.00	Excellente santé financière - Forte rentabilité	3
6	4	10.00	Bonne santé financière - Rentabilité satisfaisante	3
7	4	0.00	Situation acceptable - Rentabilité faible	2
8	4	-1.00	Déficit d'exploitation - Situation préoccupante	1
9	5	0.00	Sert à calculer les ratios par élève	3
10	6	40.00	Excellente marge brute - Très bonne performance commerciale	3
11	6	25.00	Bonne marge brute - Performance commerciale satisfaisante	3
12	6	15.00	Marge brute acceptable - Performance commerciale moyenne	2
13	6	0.00	Marge brute faible - Revoir la stratégie commerciale ou les coûts	1
14	7	15.00	Excellente performance opérationnelle - Très bonne rentabilité	3
15	7	8.00	Bonne performance opérationnelle - Rentabilité satisfaisante	3
16	7	0.00	Performance opérationnelle acceptable - Rentabilité modérée	2
17	7	-1.00	Performance opérationnelle déficitaire - Situation à améliorer	1
18	8	10.00	Excellente rentabilité nette - Très bon bénéfice final	3
19	8	5.00	Bonne rentabilité nette - Bénéfice final satisfaisant	3
20	8	0.00	Rentabilité nette acceptable - Bénéfice final modéré	2
21	8	-1.00	Rentabilité nette négative - Déficit final	1
22	9	15.00	Excellente rentabilité des fonds propres	3
23	9	8.00	Bonne rentabilité des fonds propres	3
24	9	0.00	Rentabilité modérée des fonds propres	2
25	9	-1.00	Rentabilité insuffisante des fonds propres	1
26	10	10.00	Excellente efficacité des actifs	3
27	10	5.00	Bonne efficacité des actifs	3
28	10	0.00	Efficacité modérée des actifs	2
29	10	-1.00	Efficacité insuffisante des actifs	1
30	11	1.50	Très bonne solvabilité à court terme - Excédent de liquidité	3
31	11	1.00	Bonne solvabilité à court terme - Situation saine	3
32	11	0.80	Solvabilité acceptable - Surveillance recommandée	2
33	11	0.00	Solvabilité insuffisante - Risque de liquidité	1
34	12	0.00	Excédent de trésorerie - Situation favorable	3
35	12	-1.00	Déficit de trésorerie - Attention nécessaire	1
36	13	0.00	BFR positif - Besoin de financement du cycle d'exploitation	2
37	13	-1.00	BFR négatif - Ressource dégagée du cycle d'exploitation	3
38	14	0.50	Structure financière très solide - Faible endettement	3
39	14	1.00	Structure financière saine - Endettement modéré	3
40	14	2.00	Endettement élevé - Surveillance nécessaire	2
41	14	3.00	Endettement très élevé - Situation risquée	1
42	15	50.00	Très forte autonomie financière - Structure excellente	3
43	15	30.00	Bonne autonomie financière - Structure saine	3
44	15	20.00	Autonomie acceptable - Surveillance recommandée	2
45	15	0.00	Autonomie insuffisante - Dépendance financière élevée	1
46	16	3.00	Très bonne capacité de remboursement - Dette facilement remboursable	3
47	16	5.00	Bonne capacité de remboursement - Dette gérable	3
48	16	7.00	Capacité de remboursement acceptable - Surveillance nécessaire	2
49	16	10.00	Capacité de remboursement faible - Risque élevé	1
\.


--
-- Data for Name: intervalle_comptes_categorie; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.intervalle_comptes_categorie (id, compte_debut, compte_fin, id_categorie_fonctionelle) FROM stdin;
1	700	709	1
2	710	719	2
3	720	729	3
4	740	749	6
5	750	759	10
6	760	769	14
7	770	779	18
8	780	789	13
9	601	609	4
10	611	619	5
11	620	629	5
12	630	639	9
13	640	649	7
14	651	659	11
15	660	669	15
16	670	679	19
17	680	689	12
18	690	699	16
19	200	209	25
20	210	219	26
21	230	239	27
22	260	279	30
23	280	280	29
24	281	281	28
25	310	399	35
26	411	419	37
27	420	499	39
28	512	519	40
29	100	119	43
30	110	119	48
31	104	104	44
32	106	106	44
33	120	129	47
34	130	139	45
35	140	149	46
36	150	159	52
37	160	169	51
38	170	189	53
39	480	489	55
40	400	409	54
41	420	449	53
42	450	499	56
43	501	529	41
44	530	539	42
\.


--
-- Data for Name: job_batches; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.job_batches (id, name, total_jobs, pending_jobs, failed_jobs, failed_job_ids, options, cancelled_at, created_at, finished_at) FROM stdin;
\.


--
-- Data for Name: jobs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.jobs (id, queue, payload, attempts, reserved_at, available_at, created_at) FROM stdin;
1	default	{"uuid":"6ac1f358-3899-4a5c-ae59-985d97a9a606","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:09:42\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:09:42\\";s:2:\\"id\\";i:1;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:09:42\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:09:42\\";s:2:\\"id\\";i:1;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186182,"delay":null}	0	\N	1762186182	1762186182
2	default	{"uuid":"fe47d17b-c919-46c8-af94-7abacc9eaaad","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:2;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:09:45\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:09:45\\";s:2:\\"id\\";i:2;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:2;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:09:45\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:09:45\\";s:2:\\"id\\";i:2;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186185,"delay":null}	0	\N	1762186185	1762186185
3	default	{"uuid":"d8fae320-f144-484c-8790-7ee56292aef8","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:3;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:10:11\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:10:11\\";s:2:\\"id\\";i:3;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:3;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:10:11\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:10:11\\";s:2:\\"id\\";i:3;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186211,"delay":null}	0	\N	1762186211	1762186211
4	default	{"uuid":"a2ad8d4b-9454-4677-9588-91bbb9c06f85","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:4;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:10:13\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:10:13\\";s:2:\\"id\\";i:4;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:4;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:10:13\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:10:13\\";s:2:\\"id\\";i:4;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186213,"delay":null}	0	\N	1762186213	1762186213
5	default	{"uuid":"2a917c43-bbab-41d0-b601-16968f513b3d","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:5;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:10:15\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:10:15\\";s:2:\\"id\\";i:5;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:5;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:10:15\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:10:15\\";s:2:\\"id\\";i:5;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186216,"delay":null}	0	\N	1762186216	1762186216
6	default	{"uuid":"6726b4ab-2648-41d3-9185-3c1a842b2ae1","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:6;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:10:18\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:10:18\\";s:2:\\"id\\";i:6;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:6;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:10:18\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:10:18\\";s:2:\\"id\\";i:6;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186218,"delay":null}	0	\N	1762186218	1762186218
7	default	{"uuid":"024a362e-eb39-4220-9fff-d6163d9a336b","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:7;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:22:52\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:22:52\\";s:2:\\"id\\";i:7;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:7;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:22:52\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:22:52\\";s:2:\\"id\\";i:7;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186972,"delay":null}	0	\N	1762186972	1762186972
8	default	{"uuid":"a0a5a84c-22bd-4075-81fd-5ec4e8634b14","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:8;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:22:54\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:22:54\\";s:2:\\"id\\";i:8;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:8;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:22:54\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:22:54\\";s:2:\\"id\\";i:8;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186974,"delay":null}	0	\N	1762186974	1762186974
9	default	{"uuid":"91fff485-ca56-4722-b923-d4bb9c017cd7","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:9;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:23:03\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:23:03\\";s:2:\\"id\\";i:9;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:9;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:23:03\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:23:03\\";s:2:\\"id\\";i:9;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186983,"delay":null}	0	\N	1762186983	1762186983
10	default	{"uuid":"d05a0364-8e48-492d-bf23-f24233a10f1d","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:10;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:23:05\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:23:05\\";s:2:\\"id\\";i:10;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:10;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";s:32:\\"Comptes non affectés détectés\\";s:7:\\"message\\";s:58:\\"163 compte(s) non affecté(s) nécessitent votre attention\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 16:23:05\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 16:23:05\\";s:2:\\"id\\";i:10;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762186985,"delay":null}	0	\N	1762186985	1762186985
11	default	{"uuid":"b0c47518-5056-418d-94c0-154bedc5a0cc","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:11;s:17:\\"niveau_urgence_id\\";i:3;s:5:\\"titre\\";s:18:\\"Échec importation\\";s:7:\\"message\\";s:398:\\"Erreur lors de l'import du fichier 'Exercice 2025-2026.csv' : Ligne 15: Sous-compte 633001 introuvable, Ligne 19: Sous-compte 612002 introuvable, Ligne 21: Sous-compte 636001 introuvable, Ligne 31: Sous-compte 642001 introuvable, Ligne 32: Sous-compte 280001 introuvable, Ligne 34: Sous-compte 491001 introuvable, Ligne 35: Sous-compte 120001 introuvable, Ligne 36: Sous-compte 119001 introuvable\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 18:17:30\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 18:17:30\\";s:2:\\"id\\";i:11;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:11;s:17:\\"niveau_urgence_id\\";i:3;s:5:\\"titre\\";s:18:\\"Échec importation\\";s:7:\\"message\\";s:398:\\"Erreur lors de l'import du fichier 'Exercice 2025-2026.csv' : Ligne 15: Sous-compte 633001 introuvable, Ligne 19: Sous-compte 612002 introuvable, Ligne 21: Sous-compte 636001 introuvable, Ligne 31: Sous-compte 642001 introuvable, Ligne 32: Sous-compte 280001 introuvable, Ligne 34: Sous-compte 491001 introuvable, Ligne 35: Sous-compte 120001 introuvable, Ligne 36: Sous-compte 119001 introuvable\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 18:17:30\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 18:17:30\\";s:2:\\"id\\";i:11;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762193850,"delay":null}	0	\N	1762193850	1762193850
12	default	{"uuid":"0551ecf4-67b2-4d97-a7ad-ef529cf0a66e","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:12;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:101:\\"Le fichier 'generated_ecritures_v2.csv' a été importé avec succès : 220 mouvements, 440 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 18:48:50\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 18:48:50\\";s:2:\\"id\\";i:12;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:12;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:101:\\"Le fichier 'generated_ecritures_v2.csv' a été importé avec succès : 220 mouvements, 440 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-03 18:48:50\\";s:10:\\"created_at\\";s:19:\\"2025-11-03 18:48:50\\";s:2:\\"id\\";i:12;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762195730,"delay":null}	0	\N	1762195730	1762195730
13	default	{"uuid":"750d6188-61e4-4759-bfa0-f2932777c7e8","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:13;s:17:\\"niveau_urgence_id\\";i:3;s:5:\\"titre\\";s:18:\\"Échec importation\\";s:7:\\"message\\";s:398:\\"Erreur lors de l'import du fichier 'Exercice 2025-2026.csv' : Ligne 15: Sous-compte 633001 introuvable, Ligne 19: Sous-compte 612002 introuvable, Ligne 21: Sous-compte 636001 introuvable, Ligne 31: Sous-compte 642001 introuvable, Ligne 32: Sous-compte 280001 introuvable, Ligne 34: Sous-compte 491001 introuvable, Ligne 35: Sous-compte 120001 introuvable, Ligne 36: Sous-compte 119001 introuvable\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-11 11:33:46\\";s:10:\\"created_at\\";s:19:\\"2025-11-11 11:33:46\\";s:2:\\"id\\";i:13;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:13;s:17:\\"niveau_urgence_id\\";i:3;s:5:\\"titre\\";s:18:\\"Échec importation\\";s:7:\\"message\\";s:398:\\"Erreur lors de l'import du fichier 'Exercice 2025-2026.csv' : Ligne 15: Sous-compte 633001 introuvable, Ligne 19: Sous-compte 612002 introuvable, Ligne 21: Sous-compte 636001 introuvable, Ligne 31: Sous-compte 642001 introuvable, Ligne 32: Sous-compte 280001 introuvable, Ligne 34: Sous-compte 491001 introuvable, Ligne 35: Sous-compte 120001 introuvable, Ligne 36: Sous-compte 119001 introuvable\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-11 11:33:46\\";s:10:\\"created_at\\";s:19:\\"2025-11-11 11:33:46\\";s:2:\\"id\\";i:13;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762860826,"delay":null}	0	\N	1762860826	1762860826
14	default	{"uuid":"aec82adf-d2c2-41af-9359-a767bcdd0fbe","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:14;s:17:\\"niveau_urgence_id\\";i:3;s:5:\\"titre\\";s:18:\\"Échec importation\\";s:7:\\"message\\";s:398:\\"Erreur lors de l'import du fichier 'Exercice 2025-2026.csv' : Ligne 15: Sous-compte 633001 introuvable, Ligne 19: Sous-compte 612002 introuvable, Ligne 21: Sous-compte 636001 introuvable, Ligne 31: Sous-compte 642001 introuvable, Ligne 32: Sous-compte 280001 introuvable, Ligne 34: Sous-compte 491001 introuvable, Ligne 35: Sous-compte 120001 introuvable, Ligne 36: Sous-compte 119001 introuvable\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-11 11:41:38\\";s:10:\\"created_at\\";s:19:\\"2025-11-11 11:41:38\\";s:2:\\"id\\";i:14;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:14;s:17:\\"niveau_urgence_id\\";i:3;s:5:\\"titre\\";s:18:\\"Échec importation\\";s:7:\\"message\\";s:398:\\"Erreur lors de l'import du fichier 'Exercice 2025-2026.csv' : Ligne 15: Sous-compte 633001 introuvable, Ligne 19: Sous-compte 612002 introuvable, Ligne 21: Sous-compte 636001 introuvable, Ligne 31: Sous-compte 642001 introuvable, Ligne 32: Sous-compte 280001 introuvable, Ligne 34: Sous-compte 491001 introuvable, Ligne 35: Sous-compte 120001 introuvable, Ligne 36: Sous-compte 119001 introuvable\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-11 11:41:38\\";s:10:\\"created_at\\";s:19:\\"2025-11-11 11:41:38\\";s:2:\\"id\\";i:14;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762861298,"delay":null}	0	\N	1762861298	1762861298
15	default	{"uuid":"d2930fa2-0d10-4bda-8b9c-e605db1db0fd","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:15;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:91:\\"Le fichier 'Ecriture teste.csv' a été importé avec succès : 12 mouvements, 45 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-11 11:42:52\\";s:10:\\"created_at\\";s:19:\\"2025-11-11 11:42:52\\";s:2:\\"id\\";i:15;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:15;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:91:\\"Le fichier 'Ecriture teste.csv' a été importé avec succès : 12 mouvements, 45 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-11 11:42:52\\";s:10:\\"created_at\\";s:19:\\"2025-11-11 11:42:52\\";s:2:\\"id\\";i:15;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1762861372,"delay":null}	0	\N	1762861372	1762861372
16	default	{"uuid":"f1420afa-90d8-4341-a2db-82ebc868ef03","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:16;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:92:\\"Le fichier 'Ecriture 2023.csv' a été importé avec succès : 208 mouvements, 440 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-14 07:20:47\\";s:10:\\"created_at\\";s:19:\\"2025-11-14 07:20:47\\";s:2:\\"id\\";i:16;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:16;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:92:\\"Le fichier 'Ecriture 2023.csv' a été importé avec succès : 208 mouvements, 440 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-14 07:20:47\\";s:10:\\"created_at\\";s:19:\\"2025-11-14 07:20:47\\";s:2:\\"id\\";i:16;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1763104847,"delay":null}	0	\N	1763104847	1763104847
17	default	{"uuid":"d4f39bba-e323-4623-a68f-e1205fb49dd4","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:17;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:92:\\"Le fichier 'Ecriture 2024.csv' a été importé avec succès : 225 mouvements, 474 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-14 07:21:09\\";s:10:\\"created_at\\";s:19:\\"2025-11-14 07:21:09\\";s:2:\\"id\\";i:17;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:17;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:92:\\"Le fichier 'Ecriture 2024.csv' a été importé avec succès : 225 mouvements, 474 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-14 07:21:09\\";s:10:\\"created_at\\";s:19:\\"2025-11-14 07:21:09\\";s:2:\\"id\\";i:17;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1763104869,"delay":null}	0	\N	1763104869	1763104869
18	default	{"uuid":"ebb830a5-6d0d-454f-8eeb-262b259717f3","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:18;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:92:\\"Le fichier 'Ecriture 2025.csv' a été importé avec succès : 237 mouvements, 498 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-14 07:21:29\\";s:10:\\"created_at\\";s:19:\\"2025-11-14 07:21:29\\";s:2:\\"id\\";i:18;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:18;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:92:\\"Le fichier 'Ecriture 2025.csv' a été importé avec succès : 237 mouvements, 498 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-14 07:21:29\\";s:10:\\"created_at\\";s:19:\\"2025-11-14 07:21:29\\";s:2:\\"id\\";i:18;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1763104889,"delay":null}	0	\N	1763104889	1763104889
19	default	{"uuid":"e210ebe3-9e7a-4676-8652-e65ee8b1766b","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:92:\\"Le fichier 'Ecriture 2025.csv' a été importé avec succès : 237 mouvements, 498 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-16 17:44:33\\";s:10:\\"created_at\\";s:19:\\"2025-11-16 17:44:33\\";s:2:\\"id\\";i:1;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:20:\\"Importation réussie\\";s:7:\\"message\\";s:92:\\"Le fichier 'Ecriture 2025.csv' a été importé avec succès : 237 mouvements, 498 lignes.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-16 17:44:33\\";s:10:\\"created_at\\";s:19:\\"2025-11-16 17:44:33\\";s:2:\\"id\\";i:1;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1763315074,"delay":null}	0	\N	1763315074	1763315074
20	default	{"uuid":"b7cb2a14-3af6-49a8-842f-7b4ab256f3e7","displayName":"App\\\\Events\\\\NotificationCreee","job":"Illuminate\\\\Queue\\\\CallQueuedHandler@call","maxTries":null,"maxExceptions":null,"failOnTimeout":false,"backoff":null,"timeout":null,"retryUntil":null,"data":{"commandName":"Illuminate\\\\Broadcasting\\\\BroadcastEvent","command":"O:38:\\"Illuminate\\\\Broadcasting\\\\BroadcastEvent\\":14:{s:5:\\"event\\";O:28:\\"App\\\\Events\\\\NotificationCreee\\":1:{s:12:\\"notification\\";O:37:\\"App\\\\Models\\\\notifications\\\\Notification\\":33:{s:13:\\"\\u0000*\\u0000connection\\";s:5:\\"pgsql\\";s:8:\\"\\u0000*\\u0000table\\";s:13:\\"notifications\\";s:13:\\"\\u0000*\\u0000primaryKey\\";s:2:\\"id\\";s:10:\\"\\u0000*\\u0000keyType\\";s:3:\\"int\\";s:12:\\"incrementing\\";b:1;s:7:\\"\\u0000*\\u0000with\\";a:0:{}s:12:\\"\\u0000*\\u0000withCount\\";a:0:{}s:19:\\"preventsLazyLoading\\";b:0;s:10:\\"\\u0000*\\u0000perPage\\";i:15;s:6:\\"exists\\";b:1;s:18:\\"wasRecentlyCreated\\";b:1;s:28:\\"\\u0000*\\u0000escapeWhenCastingToString\\";b:0;s:13:\\"\\u0000*\\u0000attributes\\";a:8:{s:12:\\"evenement_id\\";i:2;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:37:\\"Clôture exercice comptable imminente\\";s:7:\\"message\\";s:86:\\"L'exercice 2025 sera clôturé dans un mois (31\\/12\\/2025). 498 écriture(s) à valider.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-16 18:06:38\\";s:10:\\"created_at\\";s:19:\\"2025-11-16 18:06:38\\";s:2:\\"id\\";i:2;}s:11:\\"\\u0000*\\u0000original\\";a:8:{s:12:\\"evenement_id\\";i:2;s:17:\\"niveau_urgence_id\\";i:1;s:5:\\"titre\\";s:37:\\"Clôture exercice comptable imminente\\";s:7:\\"message\\";s:86:\\"L'exercice 2025 sera clôturé dans un mois (31\\/12\\/2025). 498 écriture(s) à valider.\\";s:6:\\"statut\\";s:6:\\"non_lu\\";s:10:\\"updated_at\\";s:19:\\"2025-11-16 18:06:38\\";s:10:\\"created_at\\";s:19:\\"2025-11-16 18:06:38\\";s:2:\\"id\\";i:2;}s:10:\\"\\u0000*\\u0000changes\\";a:0:{}s:11:\\"\\u0000*\\u0000previous\\";a:0:{}s:8:\\"\\u0000*\\u0000casts\\";a:1:{s:4:\\"lu_a\\";s:8:\\"datetime\\";}s:17:\\"\\u0000*\\u0000classCastCache\\";a:0:{}s:21:\\"\\u0000*\\u0000attributeCastCache\\";a:0:{}s:13:\\"\\u0000*\\u0000dateFormat\\";N;s:10:\\"\\u0000*\\u0000appends\\";a:0:{}s:19:\\"\\u0000*\\u0000dispatchesEvents\\";a:0:{}s:14:\\"\\u0000*\\u0000observables\\";a:0:{}s:12:\\"\\u0000*\\u0000relations\\";a:0:{}s:10:\\"\\u0000*\\u0000touches\\";a:0:{}s:27:\\"\\u0000*\\u0000relationAutoloadCallback\\";N;s:26:\\"\\u0000*\\u0000relationAutoloadContext\\";N;s:10:\\"timestamps\\";b:1;s:13:\\"usesUniqueIds\\";b:0;s:9:\\"\\u0000*\\u0000hidden\\";a:0:{}s:10:\\"\\u0000*\\u0000visible\\";a:0:{}s:11:\\"\\u0000*\\u0000fillable\\";a:6:{i:0;s:12:\\"evenement_id\\";i:1;s:17:\\"niveau_urgence_id\\";i:2;s:5:\\"titre\\";i:3;s:7:\\"message\\";i:4;s:6:\\"statut\\";i:5;s:4:\\"lu_a\\";}s:10:\\"\\u0000*\\u0000guarded\\";a:1:{i:0;s:1:\\"*\\";}}}s:5:\\"tries\\";N;s:7:\\"timeout\\";N;s:7:\\"backoff\\";N;s:13:\\"maxExceptions\\";N;s:10:\\"connection\\";N;s:5:\\"queue\\";N;s:5:\\"delay\\";N;s:11:\\"afterCommit\\";N;s:10:\\"middleware\\";a:0:{}s:7:\\"chained\\";a:0:{}s:15:\\"chainConnection\\";N;s:10:\\"chainQueue\\";N;s:19:\\"chainCatchCallbacks\\";N;}"},"createdAt":1763316398,"delay":null}	0	\N	1763316398	1763316398
\.


--
-- Data for Name: journals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.journals ("Id_Journal", "Code", "Libelle", "Id_Type_Journal", "Id_Sous_compte") FROM stdin;
1	BNI	Journal Banque	1	53
\.


--
-- Data for Name: ligne_ecritures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.ligne_ecritures ("Id_Ligne_ecriture", "Libelle", "Debit", "Credit", "Reference", "Quantite", "Id_Mode_paiement", "Id_Mouvement_ecriture", "Id_Journal", "Id_Sous_compte", statut, date_validation, valide_par) FROM stdin;
253	Jirama	36500.00	0.00	JIRAMA-20230725	\N	\N	120	1	99	valide	2025-11-14 07:25:37	\N
1420	Amortissement mobilier scolaire	9600000.00	0.00	\N	1	\N	673	1	245	brouillon	2025-11-15 18:08:06	\N
1421	Amortissement mobilier scolaire	0.00	9600000.00	\N	1	\N	673	1	174	brouillon	2025-11-15 18:08:06	\N
1422	Papier, cahiers et copies	100000.00	0.00	\N	1	\N	674	1	79	brouillon	2025-11-15 18:07:13	\N
1423	Papier, cahiers et copies	0.00	100000.00	\N	1	\N	674	1	53	brouillon	2025-11-15 18:07:13	\N
1424	Achat legumes	14800.00	0.00	CANTINE-20250102	\N	\N	675	1	241	brouillon	\N	\N
1425	Achat legumes	0.00	14800.00	CANTINE-20250102	\N	\N	675	1	236	brouillon	\N	\N
1426	Achat viande	17800.00	0.00	CANTINE-20250103	\N	\N	676	1	242	brouillon	\N	\N
1427	Achat viande	0.00	17800.00	CANTINE-20250103	\N	\N	676	1	236	brouillon	\N	\N
1428	Achat gouter	6500.00	0.00	CANTINE-20250106	\N	\N	677	1	243	brouillon	\N	\N
1429	Achat gouter	0.00	6500.00	CANTINE-20250106	\N	\N	677	1	236	brouillon	\N	\N
1430	Achat legumes	15100.00	0.00	CANTINE-20250107	\N	\N	678	1	241	brouillon	\N	\N
1431	Achat legumes	0.00	15100.00	CANTINE-20250107	\N	\N	678	1	236	brouillon	\N	\N
1432	Achat viande	18100.00	0.00	CANTINE-20250108	\N	\N	679	1	242	brouillon	\N	\N
1433	Achat viande	0.00	18100.00	CANTINE-20250108	\N	\N	679	1	236	brouillon	\N	\N
1434	Achat gouter	6700.00	0.00	CANTINE-20250109	\N	\N	680	1	243	brouillon	\N	\N
1435	Achat gouter	0.00	6700.00	CANTINE-20250109	\N	\N	680	1	236	brouillon	\N	\N
1436	Achat legumes	15400.00	0.00	CANTINE-20250110	\N	\N	681	1	241	brouillon	\N	\N
1437	Achat legumes	0.00	15400.00	CANTINE-20250110	\N	\N	681	1	236	brouillon	\N	\N
1438	Achat viande	18400.00	0.00	CANTINE-20250113	\N	\N	682	1	242	brouillon	\N	\N
1439	Achat viande	0.00	18400.00	CANTINE-20250113	\N	\N	682	1	236	brouillon	\N	\N
1440	Achat gouter	6900.00	0.00	CANTINE-20250114	\N	\N	683	1	243	brouillon	\N	\N
1441	Achat gouter	0.00	6900.00	CANTINE-20250114	\N	\N	683	1	236	brouillon	\N	\N
1442	Achat legumes	15700.00	0.00	CANTINE-20250115	\N	\N	684	1	241	brouillon	\N	\N
1443	Achat legumes	0.00	15700.00	CANTINE-20250115	\N	\N	684	1	236	brouillon	\N	\N
1444	Achat viande	18700.00	0.00	CANTINE-20250116	\N	\N	685	1	242	brouillon	\N	\N
1445	Achat viande	0.00	18700.00	CANTINE-20250116	\N	\N	685	1	236	brouillon	\N	\N
1446	Achat gouter	7100.00	0.00	CANTINE-20250117	\N	\N	686	1	243	brouillon	\N	\N
1447	Achat gouter	0.00	7100.00	CANTINE-20250117	\N	\N	686	1	236	brouillon	\N	\N
1448	Achat legumes	16000.00	0.00	CANTINE-20250120	\N	\N	687	1	241	brouillon	\N	\N
1449	Achat legumes	0.00	16000.00	CANTINE-20250120	\N	\N	687	1	236	brouillon	\N	\N
1450	Achat viande	19000.00	0.00	CANTINE-20250121	\N	\N	688	1	242	brouillon	\N	\N
1451	Achat viande	0.00	19000.00	CANTINE-20250121	\N	\N	688	1	236	brouillon	\N	\N
1452	Ecolage divers élèves	0.00	1550000.00	ECOL-20250122	\N	\N	689	1	193	brouillon	\N	\N
1453	Ecolage divers élèves	1550000.00	0.00	ECOL-20250122	\N	\N	689	1	236	brouillon	\N	\N
1454	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250125	\N	\N	690	1	238	brouillon	\N	\N
1455	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250125	\N	\N	690	1	239	brouillon	\N	\N
1456	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250125	\N	\N	690	1	240	brouillon	\N	\N
1457	Paiement salaires	0.00	580000.00	SALAIRE-20250125	\N	\N	690	1	236	brouillon	\N	\N
1458	Jirama	34500.00	0.00	JIRAMA-20250127	\N	\N	691	1	99	brouillon	\N	\N
1459	Jirama	0.00	34500.00	JIRAMA-20250127	\N	\N	691	1	236	brouillon	\N	\N
1460	Echeancier pret bancaire	900000.00	0.00	PRET-20250128	\N	\N	692	1	244	brouillon	\N	\N
1461	Echeancier pret bancaire	0.00	900000.00	PRET-20250128	\N	\N	692	1	236	brouillon	\N	\N
1462	Achat fournitures scolaires	130000.00	0.00	FOURN-20250130	\N	\N	693	1	79	brouillon	\N	\N
1463	Achat fournitures scolaires	0.00	130000.00	FOURN-20250130	\N	\N	693	1	40	brouillon	\N	\N
1464	Règlement fournisseur	130000.00	0.00	REG-FOURN-20250131	\N	\N	694	1	40	brouillon	\N	\N
1465	Règlement fournisseur	0.00	130000.00	REG-FOURN-20250131	\N	\N	694	1	236	brouillon	\N	\N
1466	Achat legumes	15900.00	0.00	CANTINE-20250203	\N	\N	695	1	241	brouillon	\N	\N
1467	Achat legumes	0.00	15900.00	CANTINE-20250203	\N	\N	695	1	236	brouillon	\N	\N
1468	Achat viande	18900.00	0.00	CANTINE-20250204	\N	\N	696	1	242	brouillon	\N	\N
1469	Achat viande	0.00	18900.00	CANTINE-20250204	\N	\N	696	1	236	brouillon	\N	\N
1470	Achat gouter	7300.00	0.00	CANTINE-20250205	\N	\N	697	1	243	brouillon	\N	\N
1471	Achat gouter	0.00	7300.00	CANTINE-20250205	\N	\N	697	1	236	brouillon	\N	\N
1472	Achat legumes	16200.00	0.00	CANTINE-20250206	\N	\N	698	1	241	brouillon	\N	\N
1473	Achat legumes	0.00	16200.00	CANTINE-20250206	\N	\N	698	1	236	brouillon	\N	\N
1474	Achat viande	19200.00	0.00	CANTINE-20250207	\N	\N	699	1	242	brouillon	\N	\N
1475	Achat viande	0.00	19200.00	CANTINE-20250207	\N	\N	699	1	236	brouillon	\N	\N
1476	Achat gouter	7500.00	0.00	CANTINE-20250210	\N	\N	700	1	243	brouillon	\N	\N
1477	Achat gouter	0.00	7500.00	CANTINE-20250210	\N	\N	700	1	236	brouillon	\N	\N
1478	Achat legumes	16500.00	0.00	CANTINE-20250211	\N	\N	701	1	241	brouillon	\N	\N
1479	Achat legumes	0.00	16500.00	CANTINE-20250211	\N	\N	701	1	236	brouillon	\N	\N
1480	Achat viande	19500.00	0.00	CANTINE-20250212	\N	\N	702	1	242	brouillon	\N	\N
1481	Achat viande	0.00	19500.00	CANTINE-20250212	\N	\N	702	1	236	brouillon	\N	\N
1482	Achat gouter	7700.00	0.00	CANTINE-20250213	\N	\N	703	1	243	brouillon	\N	\N
1483	Achat gouter	0.00	7700.00	CANTINE-20250213	\N	\N	703	1	236	brouillon	\N	\N
1484	Achat legumes	16800.00	0.00	CANTINE-20250214	\N	\N	704	1	241	brouillon	\N	\N
1485	Achat legumes	0.00	16800.00	CANTINE-20250214	\N	\N	704	1	236	brouillon	\N	\N
1486	Appro caisse via BMOI	0.00	2000000.00	APPRO-20250215	\N	\N	705	1	53	brouillon	\N	\N
1487	Appro caisse via BMOI	2000000.00	0.00	APPRO-20250215	\N	\N	705	1	236	brouillon	\N	\N
1488	Achat viande	19800.00	0.00	CANTINE-20250217	\N	\N	706	1	242	brouillon	\N	\N
1489	Achat viande	0.00	19800.00	CANTINE-20250217	\N	\N	706	1	236	brouillon	\N	\N
1490	Achat gouter	7900.00	0.00	CANTINE-20250218	\N	\N	707	1	243	brouillon	\N	\N
1491	Achat gouter	0.00	7900.00	CANTINE-20250218	\N	\N	707	1	236	brouillon	\N	\N
1492	Achat legumes	17100.00	0.00	CANTINE-20250219	\N	\N	708	1	241	brouillon	\N	\N
1493	Achat legumes	0.00	17100.00	CANTINE-20250219	\N	\N	708	1	236	brouillon	\N	\N
1494	Ecolage divers élèves	0.00	1570000.00	ECOL-20250220	\N	\N	709	1	193	brouillon	\N	\N
1495	Ecolage divers élèves	1570000.00	0.00	ECOL-20250220	\N	\N	709	1	236	brouillon	\N	\N
1496	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250225	\N	\N	710	1	238	brouillon	\N	\N
1497	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250225	\N	\N	710	1	239	brouillon	\N	\N
1498	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250225	\N	\N	710	1	240	brouillon	\N	\N
1499	Paiement salaires	0.00	580000.00	SALAIRE-20250225	\N	\N	710	1	236	brouillon	\N	\N
1500	Jirama	35800.00	0.00	JIRAMA-20250227	\N	\N	711	1	99	brouillon	\N	\N
1501	Jirama	0.00	35800.00	JIRAMA-20250227	\N	\N	711	1	236	brouillon	\N	\N
1502	Achat fournitures bureau	124000.00	0.00	FOURN-20250228	\N	\N	712	1	105	brouillon	\N	\N
1503	Achat fournitures bureau	0.00	124000.00	FOURN-20250228	\N	\N	712	1	40	brouillon	\N	\N
1504	Règlement fournisseur	124000.00	0.00	REG-FOURN-20250302	\N	\N	713	1	40	brouillon	\N	\N
1505	Règlement fournisseur	0.00	124000.00	REG-FOURN-20250302	\N	\N	713	1	236	brouillon	\N	\N
1506	Achat legumes	17000.00	0.00	CANTINE-20250303	\N	\N	714	1	241	brouillon	\N	\N
1507	Achat legumes	0.00	17000.00	CANTINE-20250303	\N	\N	714	1	236	brouillon	\N	\N
1508	Achat viande	20000.00	0.00	CANTINE-20250304	\N	\N	715	1	242	brouillon	\N	\N
1509	Achat viande	0.00	20000.00	CANTINE-20250304	\N	\N	715	1	236	brouillon	\N	\N
1510	Achat gouter	8100.00	0.00	CANTINE-20250305	\N	\N	716	1	243	brouillon	\N	\N
1511	Achat gouter	0.00	8100.00	CANTINE-20250305	\N	\N	716	1	236	brouillon	\N	\N
1512	Achat legumes	17300.00	0.00	CANTINE-20250306	\N	\N	717	1	241	brouillon	\N	\N
1513	Achat legumes	0.00	17300.00	CANTINE-20250306	\N	\N	717	1	236	brouillon	\N	\N
1514	Achat viande	20300.00	0.00	CANTINE-20250307	\N	\N	718	1	242	brouillon	\N	\N
1515	Achat viande	0.00	20300.00	CANTINE-20250307	\N	\N	718	1	236	brouillon	\N	\N
1516	Achat gouter	8300.00	0.00	CANTINE-20250310	\N	\N	719	1	243	brouillon	\N	\N
1517	Achat gouter	0.00	8300.00	CANTINE-20250310	\N	\N	719	1	236	brouillon	\N	\N
1518	Achat legumes	17600.00	0.00	CANTINE-20250311	\N	\N	720	1	241	brouillon	\N	\N
1519	Achat legumes	0.00	17600.00	CANTINE-20250311	\N	\N	720	1	236	brouillon	\N	\N
1520	Achat viande	20600.00	0.00	CANTINE-20250312	\N	\N	721	1	242	brouillon	\N	\N
1521	Achat viande	0.00	20600.00	CANTINE-20250312	\N	\N	721	1	236	brouillon	\N	\N
1522	Achat gouter	8500.00	0.00	CANTINE-20250313	\N	\N	722	1	243	brouillon	\N	\N
1523	Achat gouter	0.00	8500.00	CANTINE-20250313	\N	\N	722	1	236	brouillon	\N	\N
1524	Achat legumes	17900.00	0.00	CANTINE-20250314	\N	\N	723	1	241	brouillon	\N	\N
1525	Achat legumes	0.00	17900.00	CANTINE-20250314	\N	\N	723	1	236	brouillon	\N	\N
1526	Achat viande	20900.00	0.00	CANTINE-20250317	\N	\N	724	1	242	brouillon	\N	\N
1527	Achat viande	0.00	20900.00	CANTINE-20250317	\N	\N	724	1	236	brouillon	\N	\N
1528	Achat gouter	8700.00	0.00	CANTINE-20250318	\N	\N	725	1	243	brouillon	\N	\N
1529	Achat gouter	0.00	8700.00	CANTINE-20250318	\N	\N	725	1	236	brouillon	\N	\N
1530	Achat legumes	18200.00	0.00	CANTINE-20250319	\N	\N	726	1	241	brouillon	\N	\N
1531	Achat legumes	0.00	18200.00	CANTINE-20250319	\N	\N	726	1	236	brouillon	\N	\N
1532	Versement en banque BMOI	130000.00	0.00	VERS200325	\N	\N	727	1	53	brouillon	\N	\N
1533	Versement en banque BMOI	0.00	130000.00	VERS200325	\N	\N	727	1	236	brouillon	\N	\N
1534	Ecolage divers élèves	0.00	1590000.00	ECOL-20250320	\N	\N	728	1	193	brouillon	\N	\N
1535	Ecolage divers élèves	1590000.00	0.00	ECOL-20250320	\N	\N	728	1	236	brouillon	\N	\N
1536	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250325	\N	\N	729	1	238	brouillon	\N	\N
1537	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250325	\N	\N	729	1	239	brouillon	\N	\N
1538	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250325	\N	\N	729	1	240	brouillon	\N	\N
1539	Paiement salaires	0.00	580000.00	SALAIRE-20250325	\N	\N	729	1	236	brouillon	\N	\N
1540	Jirama	37200.00	0.00	JIRAMA-20250327	\N	\N	730	1	99	brouillon	\N	\N
1541	Jirama	0.00	37200.00	JIRAMA-20250327	\N	\N	730	1	236	brouillon	\N	\N
1542	Achat matériel éducatif	136000.00	0.00	FOURN-20250330	\N	\N	731	1	97	brouillon	\N	\N
1543	Achat matériel éducatif	0.00	136000.00	FOURN-20250330	\N	\N	731	1	40	brouillon	\N	\N
1544	Règlement fournisseur	136000.00	0.00	REG-FOURN-20250331	\N	\N	732	1	40	brouillon	\N	\N
1545	Règlement fournisseur	0.00	136000.00	REG-FOURN-20250331	\N	\N	732	1	236	brouillon	\N	\N
1546	Achat legumes	18100.00	0.00	CANTINE-20250401	\N	\N	733	1	241	brouillon	\N	\N
1547	Achat legumes	0.00	18100.00	CANTINE-20250401	\N	\N	733	1	236	brouillon	\N	\N
1548	Achat viande	21100.00	0.00	CANTINE-20250402	\N	\N	734	1	242	brouillon	\N	\N
1549	Achat viande	0.00	21100.00	CANTINE-20250402	\N	\N	734	1	236	brouillon	\N	\N
1550	Achat gouter	8900.00	0.00	CANTINE-20250403	\N	\N	735	1	243	brouillon	\N	\N
1551	Achat gouter	0.00	8900.00	CANTINE-20250403	\N	\N	735	1	236	brouillon	\N	\N
1552	Achat legumes	18400.00	0.00	CANTINE-20250404	\N	\N	736	1	241	brouillon	\N	\N
1553	Achat legumes	0.00	18400.00	CANTINE-20250404	\N	\N	736	1	236	brouillon	\N	\N
1554	Achat viande	21400.00	0.00	CANTINE-20250407	\N	\N	737	1	242	brouillon	\N	\N
1555	Achat viande	0.00	21400.00	CANTINE-20250407	\N	\N	737	1	236	brouillon	\N	\N
1556	Achat gouter	9100.00	0.00	CANTINE-20250408	\N	\N	738	1	243	brouillon	\N	\N
1557	Achat gouter	0.00	9100.00	CANTINE-20250408	\N	\N	738	1	236	brouillon	\N	\N
1558	Achat legumes	18700.00	0.00	CANTINE-20250409	\N	\N	739	1	241	brouillon	\N	\N
1559	Achat legumes	0.00	18700.00	CANTINE-20250409	\N	\N	739	1	236	brouillon	\N	\N
1560	Achat viande	21700.00	0.00	CANTINE-20250410	\N	\N	740	1	242	brouillon	\N	\N
1561	Achat viande	0.00	21700.00	CANTINE-20250410	\N	\N	740	1	236	brouillon	\N	\N
1562	Achat gouter	9300.00	0.00	CANTINE-20250411	\N	\N	741	1	243	brouillon	\N	\N
1563	Achat gouter	0.00	9300.00	CANTINE-20250411	\N	\N	741	1	236	brouillon	\N	\N
1564	Achat legumes	19000.00	0.00	CANTINE-20250414	\N	\N	742	1	241	brouillon	\N	\N
1565	Achat legumes	0.00	19000.00	CANTINE-20250414	\N	\N	742	1	236	brouillon	\N	\N
1566	Achat viande	22000.00	0.00	CANTINE-20250415	\N	\N	743	1	242	brouillon	\N	\N
1567	Achat viande	0.00	22000.00	CANTINE-20250415	\N	\N	743	1	236	brouillon	\N	\N
1568	Achat gouter	9500.00	0.00	CANTINE-20250416	\N	\N	744	1	243	brouillon	\N	\N
1569	Achat gouter	0.00	9500.00	CANTINE-20250416	\N	\N	744	1	236	brouillon	\N	\N
1570	Achat legumes	19300.00	0.00	CANTINE-20250417	\N	\N	745	1	241	brouillon	\N	\N
1571	Achat legumes	0.00	19300.00	CANTINE-20250417	\N	\N	745	1	236	brouillon	\N	\N
1572	Achat viande	22300.00	0.00	CANTINE-20250418	\N	\N	746	1	242	brouillon	\N	\N
1573	Achat viande	0.00	22300.00	CANTINE-20250418	\N	\N	746	1	236	brouillon	\N	\N
1574	Achat gouter	9700.00	0.00	CANTINE-20250421	\N	\N	747	1	243	brouillon	\N	\N
1575	Achat gouter	0.00	9700.00	CANTINE-20250421	\N	\N	747	1	236	brouillon	\N	\N
1576	Ecolage divers élèves	0.00	1610000.00	ECOL-20250422	\N	\N	748	1	193	brouillon	\N	\N
1577	Ecolage divers élèves	1610000.00	0.00	ECOL-20250422	\N	\N	748	1	236	brouillon	\N	\N
1578	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250425	\N	\N	749	1	238	brouillon	\N	\N
1579	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250425	\N	\N	749	1	239	brouillon	\N	\N
1580	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250425	\N	\N	749	1	240	brouillon	\N	\N
1581	Paiement salaires	0.00	580000.00	SALAIRE-20250425	\N	\N	749	1	236	brouillon	\N	\N
1582	Jirama	38500.00	0.00	JIRAMA-20250427	\N	\N	750	1	99	brouillon	\N	\N
1583	Jirama	0.00	38500.00	JIRAMA-20250427	\N	\N	750	1	236	brouillon	\N	\N
1584	Achat fournitures pédagogiques	133000.00	0.00	FOURN-20250429	\N	\N	751	1	106	brouillon	\N	\N
1585	Achat fournitures pédagogiques	0.00	133000.00	FOURN-20250429	\N	\N	751	1	40	brouillon	\N	\N
1586	Règlement fournisseur	133000.00	0.00	REG-FOURN-20250430	\N	\N	752	1	40	brouillon	\N	\N
1587	Règlement fournisseur	0.00	133000.00	REG-FOURN-20250430	\N	\N	752	1	236	brouillon	\N	\N
1588	Achat legumes	19200.00	0.00	CANTINE-20250502	\N	\N	753	1	241	brouillon	\N	\N
1589	Achat legumes	0.00	19200.00	CANTINE-20250502	\N	\N	753	1	236	brouillon	\N	\N
1590	Achat viande	22200.00	0.00	CANTINE-20250504	\N	\N	754	1	242	brouillon	\N	\N
1591	Achat viande	0.00	22200.00	CANTINE-20250504	\N	\N	754	1	236	brouillon	\N	\N
1592	Achat gouter	9900.00	0.00	CANTINE-20250505	\N	\N	755	1	243	brouillon	\N	\N
1593	Achat gouter	0.00	9900.00	CANTINE-20250505	\N	\N	755	1	236	brouillon	\N	\N
1594	Achat legumes	19500.00	0.00	CANTINE-20250506	\N	\N	756	1	241	brouillon	\N	\N
1595	Achat legumes	0.00	19500.00	CANTINE-20250506	\N	\N	756	1	236	brouillon	\N	\N
1596	Achat viande	22500.00	0.00	CANTINE-20250507	\N	\N	757	1	242	brouillon	\N	\N
1597	Achat viande	0.00	22500.00	CANTINE-20250507	\N	\N	757	1	236	brouillon	\N	\N
1598	Achat gouter	10100.00	0.00	CANTINE-20250508	\N	\N	758	1	243	brouillon	\N	\N
1599	Achat gouter	0.00	10100.00	CANTINE-20250508	\N	\N	758	1	236	brouillon	\N	\N
1600	Achat legumes	19800.00	0.00	CANTINE-20250509	\N	\N	759	1	241	brouillon	\N	\N
1601	Achat legumes	0.00	19800.00	CANTINE-20250509	\N	\N	759	1	236	brouillon	\N	\N
1602	Echeancier pret bancaire	1000000.00	0.00	PRET-20250510	\N	\N	760	1	244	brouillon	\N	\N
1603	Echeancier pret bancaire	0.00	1000000.00	PRET-20250510	\N	\N	760	1	236	brouillon	\N	\N
1604	Achat viande	22800.00	0.00	CANTINE-20250512	\N	\N	761	1	242	brouillon	\N	\N
1605	Achat viande	0.00	22800.00	CANTINE-20250512	\N	\N	761	1	236	brouillon	\N	\N
1606	Achat gouter	10300.00	0.00	CANTINE-20250513	\N	\N	762	1	243	brouillon	\N	\N
1607	Achat gouter	0.00	10300.00	CANTINE-20250513	\N	\N	762	1	236	brouillon	\N	\N
1608	Achat legumes	20100.00	0.00	CANTINE-20250514	\N	\N	763	1	241	brouillon	\N	\N
1609	Achat legumes	0.00	20100.00	CANTINE-20250514	\N	\N	763	1	236	brouillon	\N	\N
1610	Achat viande	23100.00	0.00	CANTINE-20250515	\N	\N	764	1	242	brouillon	\N	\N
1611	Achat viande	0.00	23100.00	CANTINE-20250515	\N	\N	764	1	236	brouillon	\N	\N
1612	Achat gouter	10500.00	0.00	CANTINE-20250516	\N	\N	765	1	243	brouillon	\N	\N
1613	Achat gouter	0.00	10500.00	CANTINE-20250516	\N	\N	765	1	236	brouillon	\N	\N
1614	Achat legumes	20400.00	0.00	CANTINE-20250519	\N	\N	766	1	241	brouillon	\N	\N
1615	Achat legumes	0.00	20400.00	CANTINE-20250519	\N	\N	766	1	236	brouillon	\N	\N
1616	Ecolage divers élèves	0.00	1630000.00	ECOL-20250520	\N	\N	767	1	193	brouillon	\N	\N
1617	Ecolage divers élèves	1630000.00	0.00	ECOL-20250520	\N	\N	767	1	236	brouillon	\N	\N
1618	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250525	\N	\N	768	1	238	brouillon	\N	\N
1619	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250525	\N	\N	768	1	239	brouillon	\N	\N
1620	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250525	\N	\N	768	1	240	brouillon	\N	\N
1621	Paiement salaires	0.00	580000.00	SALAIRE-20250525	\N	\N	768	1	236	brouillon	\N	\N
1622	Jirama	39800.00	0.00	JIRAMA-20250527	\N	\N	769	1	99	brouillon	\N	\N
1623	Jirama	0.00	39800.00	JIRAMA-20250527	\N	\N	769	1	236	brouillon	\N	\N
1624	Achat fournitures scolaires	142000.00	0.00	FOURN-20250529	\N	\N	770	1	79	brouillon	\N	\N
1625	Achat fournitures scolaires	0.00	142000.00	FOURN-20250529	\N	\N	770	1	40	brouillon	\N	\N
1626	Règlement fournisseur	142000.00	0.00	REG-FOURN-20250531	\N	\N	771	1	40	brouillon	\N	\N
1627	Règlement fournisseur	0.00	142000.00	REG-FOURN-20250531	\N	\N	771	1	236	brouillon	\N	\N
1628	Achat legumes	20300.00	0.00	CANTINE-20250602	\N	\N	772	1	241	brouillon	\N	\N
1629	Achat legumes	0.00	20300.00	CANTINE-20250602	\N	\N	772	1	236	brouillon	\N	\N
1630	Achat viande	23300.00	0.00	CANTINE-20250603	\N	\N	773	1	242	brouillon	\N	\N
1631	Achat viande	0.00	23300.00	CANTINE-20250603	\N	\N	773	1	236	brouillon	\N	\N
1632	Achat gouter	10700.00	0.00	CANTINE-20250604	\N	\N	774	1	243	brouillon	\N	\N
1633	Achat gouter	0.00	10700.00	CANTINE-20250604	\N	\N	774	1	236	brouillon	\N	\N
1634	Achat legumes	20600.00	0.00	CANTINE-20250605	\N	\N	775	1	241	brouillon	\N	\N
1635	Achat legumes	0.00	20600.00	CANTINE-20250605	\N	\N	775	1	236	brouillon	\N	\N
1636	Achat viande	23600.00	0.00	CANTINE-20250606	\N	\N	776	1	242	brouillon	\N	\N
1637	Achat viande	0.00	23600.00	CANTINE-20250606	\N	\N	776	1	236	brouillon	\N	\N
1638	Achat gouter	10900.00	0.00	CANTINE-20250609	\N	\N	777	1	243	brouillon	\N	\N
1639	Achat gouter	0.00	10900.00	CANTINE-20250609	\N	\N	777	1	236	brouillon	\N	\N
1640	Achat legumes	20900.00	0.00	CANTINE-20250610	\N	\N	778	1	241	brouillon	\N	\N
1641	Achat legumes	0.00	20900.00	CANTINE-20250610	\N	\N	778	1	236	brouillon	\N	\N
1642	Achat viande	23900.00	0.00	CANTINE-20250611	\N	\N	779	1	242	brouillon	\N	\N
1643	Achat viande	0.00	23900.00	CANTINE-20250611	\N	\N	779	1	236	brouillon	\N	\N
1644	Achat gouter	11100.00	0.00	CANTINE-20250612	\N	\N	780	1	243	brouillon	\N	\N
1645	Achat gouter	0.00	11100.00	CANTINE-20250612	\N	\N	780	1	236	brouillon	\N	\N
1646	Achat legumes	21200.00	0.00	CANTINE-20250613	\N	\N	781	1	241	brouillon	\N	\N
1647	Achat legumes	0.00	21200.00	CANTINE-20250613	\N	\N	781	1	236	brouillon	\N	\N
1648	Achat viande	24200.00	0.00	CANTINE-20250616	\N	\N	782	1	242	brouillon	\N	\N
1649	Achat viande	0.00	24200.00	CANTINE-20250616	\N	\N	782	1	236	brouillon	\N	\N
1650	Achat gouter	11300.00	0.00	CANTINE-20250617	\N	\N	783	1	243	brouillon	\N	\N
1651	Achat gouter	0.00	11300.00	CANTINE-20250617	\N	\N	783	1	236	brouillon	\N	\N
1652	Achat legumes	21500.00	0.00	CANTINE-20250618	\N	\N	784	1	241	brouillon	\N	\N
1653	Achat legumes	0.00	21500.00	CANTINE-20250618	\N	\N	784	1	236	brouillon	\N	\N
1654	Achat viande	24500.00	0.00	CANTINE-20250619	\N	\N	785	1	242	brouillon	\N	\N
1655	Achat viande	0.00	24500.00	CANTINE-20250619	\N	\N	785	1	236	brouillon	\N	\N
1656	Ecolage divers élèves	0.00	1650000.00	ECOL-20250620	\N	\N	786	1	193	brouillon	\N	\N
1657	Ecolage divers élèves	1650000.00	0.00	ECOL-20250620	\N	\N	786	1	236	brouillon	\N	\N
1658	Versement en banque BMOI	160000.00	0.00	VERS250625	\N	\N	787	1	53	brouillon	\N	\N
1659	Versement en banque BMOI	0.00	160000.00	VERS250625	\N	\N	787	1	236	brouillon	\N	\N
1660	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250625	\N	\N	788	1	238	brouillon	\N	\N
1661	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250625	\N	\N	788	1	239	brouillon	\N	\N
1662	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250625	\N	\N	788	1	240	brouillon	\N	\N
1663	Paiement salaires	0.00	580000.00	SALAIRE-20250625	\N	\N	788	1	236	brouillon	\N	\N
1664	Jirama	41200.00	0.00	JIRAMA-20250627	\N	\N	789	1	99	brouillon	\N	\N
1665	Jirama	0.00	41200.00	JIRAMA-20250627	\N	\N	789	1	236	brouillon	\N	\N
1666	Achat fournitures bureau	135000.00	0.00	FOURN-20250628	\N	\N	790	1	105	brouillon	\N	\N
1667	Achat fournitures bureau	0.00	135000.00	FOURN-20250628	\N	\N	790	1	40	brouillon	\N	\N
1668	Règlement fournisseur	135000.00	0.00	REG-FOURN-20250630	\N	\N	791	1	40	brouillon	\N	\N
1669	Règlement fournisseur	0.00	135000.00	REG-FOURN-20250630	\N	\N	791	1	236	brouillon	\N	\N
1670	Achat legumes	21400.00	0.00	CANTINE-20250701	\N	\N	792	1	241	brouillon	\N	\N
1671	Achat legumes	0.00	21400.00	CANTINE-20250701	\N	\N	792	1	236	brouillon	\N	\N
1672	Achat viande	24400.00	0.00	CANTINE-20250702	\N	\N	793	1	242	brouillon	\N	\N
1673	Achat viande	0.00	24400.00	CANTINE-20250702	\N	\N	793	1	236	brouillon	\N	\N
1674	Achat gouter	11500.00	0.00	CANTINE-20250703	\N	\N	794	1	243	brouillon	\N	\N
1675	Achat gouter	0.00	11500.00	CANTINE-20250703	\N	\N	794	1	236	brouillon	\N	\N
1676	Achat legumes	21700.00	0.00	CANTINE-20250704	\N	\N	795	1	241	brouillon	\N	\N
1677	Achat legumes	0.00	21700.00	CANTINE-20250704	\N	\N	795	1	236	brouillon	\N	\N
1678	Achat viande	24700.00	0.00	CANTINE-20250707	\N	\N	796	1	242	brouillon	\N	\N
1679	Achat viande	0.00	24700.00	CANTINE-20250707	\N	\N	796	1	236	brouillon	\N	\N
1680	Achat gouter	11700.00	0.00	CANTINE-20250708	\N	\N	797	1	243	brouillon	\N	\N
1681	Achat gouter	0.00	11700.00	CANTINE-20250708	\N	\N	797	1	236	brouillon	\N	\N
1682	Achat legumes	22000.00	0.00	CANTINE-20250709	\N	\N	798	1	241	brouillon	\N	\N
1683	Achat legumes	0.00	22000.00	CANTINE-20250709	\N	\N	798	1	236	brouillon	\N	\N
1684	Achat viande	25000.00	0.00	CANTINE-20250710	\N	\N	799	1	242	brouillon	\N	\N
1685	Achat viande	0.00	25000.00	CANTINE-20250710	\N	\N	799	1	236	brouillon	\N	\N
1686	Achat gouter	11900.00	0.00	CANTINE-20250711	\N	\N	800	1	243	brouillon	\N	\N
1687	Achat gouter	0.00	11900.00	CANTINE-20250711	\N	\N	800	1	236	brouillon	\N	\N
1688	Achat legumes	22300.00	0.00	CANTINE-20250714	\N	\N	801	1	241	brouillon	\N	\N
1689	Achat legumes	0.00	22300.00	CANTINE-20250714	\N	\N	801	1	236	brouillon	\N	\N
1690	Achat viande	25300.00	0.00	CANTINE-20250715	\N	\N	802	1	242	brouillon	\N	\N
1691	Achat viande	0.00	25300.00	CANTINE-20250715	\N	\N	802	1	236	brouillon	\N	\N
1692	Achat gouter	12100.00	0.00	CANTINE-20250716	\N	\N	803	1	243	brouillon	\N	\N
1693	Achat gouter	0.00	12100.00	CANTINE-20250716	\N	\N	803	1	236	brouillon	\N	\N
1694	Achat legumes	22600.00	0.00	CANTINE-20250717	\N	\N	804	1	241	brouillon	\N	\N
1695	Achat legumes	0.00	22600.00	CANTINE-20250717	\N	\N	804	1	236	brouillon	\N	\N
1696	Achat viande	25600.00	0.00	CANTINE-20250718	\N	\N	805	1	242	brouillon	\N	\N
1697	Achat viande	0.00	25600.00	CANTINE-20250718	\N	\N	805	1	236	brouillon	\N	\N
1698	Achat gouter	12300.00	0.00	CANTINE-20250721	\N	\N	806	1	243	brouillon	\N	\N
1699	Achat gouter	0.00	12300.00	CANTINE-20250721	\N	\N	806	1	236	brouillon	\N	\N
1700	Ecolage divers élèves	0.00	1670000.00	ECOL-20250722	\N	\N	807	1	193	brouillon	\N	\N
1701	Ecolage divers élèves	1670000.00	0.00	ECOL-20250722	\N	\N	807	1	236	brouillon	\N	\N
1702	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250725	\N	\N	808	1	238	brouillon	\N	\N
1703	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250725	\N	\N	808	1	239	brouillon	\N	\N
1704	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250725	\N	\N	808	1	240	brouillon	\N	\N
1705	Paiement salaires	0.00	580000.00	SALAIRE-20250725	\N	\N	808	1	236	brouillon	\N	\N
1706	Jirama	42500.00	0.00	JIRAMA-20250727	\N	\N	809	1	99	brouillon	\N	\N
1707	Jirama	0.00	42500.00	JIRAMA-20250727	\N	\N	809	1	236	brouillon	\N	\N
1708	Achat matériel éducatif	139000.00	0.00	FOURN-20250729	\N	\N	810	1	97	brouillon	\N	\N
1709	Achat matériel éducatif	0.00	139000.00	FOURN-20250729	\N	\N	810	1	40	brouillon	\N	\N
1710	Règlement fournisseur	139000.00	0.00	REG-FOURN-20250731	\N	\N	811	1	40	brouillon	\N	\N
1711	Règlement fournisseur	0.00	139000.00	REG-FOURN-20250731	\N	\N	811	1	236	brouillon	\N	\N
1712	Achat legumes	22500.00	0.00	CANTINE-20250801	\N	\N	812	1	241	brouillon	\N	\N
1713	Achat legumes	0.00	22500.00	CANTINE-20250801	\N	\N	812	1	236	brouillon	\N	\N
1714	Achat viande	25500.00	0.00	CANTINE-20250804	\N	\N	813	1	242	brouillon	\N	\N
1715	Achat viande	0.00	25500.00	CANTINE-20250804	\N	\N	813	1	236	brouillon	\N	\N
1716	Achat gouter	12500.00	0.00	CANTINE-20250805	\N	\N	814	1	243	brouillon	\N	\N
1717	Achat gouter	0.00	12500.00	CANTINE-20250805	\N	\N	814	1	236	brouillon	\N	\N
1718	Achat legumes	22800.00	0.00	CANTINE-20250806	\N	\N	815	1	241	brouillon	\N	\N
1719	Achat legumes	0.00	22800.00	CANTINE-20250806	\N	\N	815	1	236	brouillon	\N	\N
1720	Achat viande	25800.00	0.00	CANTINE-20250807	\N	\N	816	1	242	brouillon	\N	\N
1721	Achat viande	0.00	25800.00	CANTINE-20250807	\N	\N	816	1	236	brouillon	\N	\N
1722	Achat gouter	12700.00	0.00	CANTINE-20250808	\N	\N	817	1	243	brouillon	\N	\N
1723	Achat gouter	0.00	12700.00	CANTINE-20250808	\N	\N	817	1	236	brouillon	\N	\N
1724	Achat legumes	23100.00	0.00	CANTINE-20250811	\N	\N	818	1	241	brouillon	\N	\N
1725	Achat legumes	0.00	23100.00	CANTINE-20250811	\N	\N	818	1	236	brouillon	\N	\N
1726	Achat viande	26100.00	0.00	CANTINE-20250812	\N	\N	819	1	242	brouillon	\N	\N
1727	Achat viande	0.00	26100.00	CANTINE-20250812	\N	\N	819	1	236	brouillon	\N	\N
1728	Achat gouter	12900.00	0.00	CANTINE-20250813	\N	\N	820	1	243	brouillon	\N	\N
1729	Achat gouter	0.00	12900.00	CANTINE-20250813	\N	\N	820	1	236	brouillon	\N	\N
1730	Achat legumes	23400.00	0.00	CANTINE-20250814	\N	\N	821	1	241	brouillon	\N	\N
1731	Achat legumes	0.00	23400.00	CANTINE-20250814	\N	\N	821	1	236	brouillon	\N	\N
1732	Appro caisse via BMOI	0.00	2400000.00	APPRO-20250815	\N	\N	822	1	53	brouillon	\N	\N
1733	Appro caisse via BMOI	2400000.00	0.00	APPRO-20250815	\N	\N	822	1	236	brouillon	\N	\N
1734	Achat viande	26400.00	0.00	CANTINE-20250815	\N	\N	823	1	242	brouillon	\N	\N
1735	Achat viande	0.00	26400.00	CANTINE-20250815	\N	\N	823	1	236	brouillon	\N	\N
1736	Achat gouter	13100.00	0.00	CANTINE-20250818	\N	\N	824	1	243	brouillon	\N	\N
1737	Achat gouter	0.00	13100.00	CANTINE-20250818	\N	\N	824	1	236	brouillon	\N	\N
1738	Achat legumes	23700.00	0.00	CANTINE-20250819	\N	\N	825	1	241	brouillon	\N	\N
1739	Achat legumes	0.00	23700.00	CANTINE-20250819	\N	\N	825	1	236	brouillon	\N	\N
1740	Ecolage divers élèves	0.00	1690000.00	ECOL-20250820	\N	\N	826	1	193	brouillon	\N	\N
1741	Ecolage divers élèves	1690000.00	0.00	ECOL-20250820	\N	\N	826	1	236	brouillon	\N	\N
1742	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250825	\N	\N	827	1	238	brouillon	\N	\N
1743	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250825	\N	\N	827	1	239	brouillon	\N	\N
1744	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250825	\N	\N	827	1	240	brouillon	\N	\N
1745	Paiement salaires	0.00	580000.00	SALAIRE-20250825	\N	\N	827	1	236	brouillon	\N	\N
1746	Jirama	43800.00	0.00	JIRAMA-20250827	\N	\N	828	1	99	brouillon	\N	\N
1747	Jirama	0.00	43800.00	JIRAMA-20250827	\N	\N	828	1	236	brouillon	\N	\N
1748	Achat fournitures pédagogiques	145000.00	0.00	FOURN-20250829	\N	\N	829	1	106	brouillon	\N	\N
1749	Achat fournitures pédagogiques	0.00	145000.00	FOURN-20250829	\N	\N	829	1	40	brouillon	\N	\N
1750	Règlement fournisseur	145000.00	0.00	REG-FOURN-20250831	\N	\N	830	1	40	brouillon	\N	\N
1751	Règlement fournisseur	0.00	145000.00	REG-FOURN-20250831	\N	\N	830	1	236	brouillon	\N	\N
1752	Achat legumes	23600.00	0.00	CANTINE-20250901	\N	\N	831	1	241	brouillon	\N	\N
1753	Achat legumes	0.00	23600.00	CANTINE-20250901	\N	\N	831	1	236	brouillon	\N	\N
1754	Achat viande	26600.00	0.00	CANTINE-20250902	\N	\N	832	1	242	brouillon	\N	\N
1755	Achat viande	0.00	26600.00	CANTINE-20250902	\N	\N	832	1	236	brouillon	\N	\N
1756	Achat gouter	13300.00	0.00	CANTINE-20250903	\N	\N	833	1	243	brouillon	\N	\N
1757	Achat gouter	0.00	13300.00	CANTINE-20250903	\N	\N	833	1	236	brouillon	\N	\N
1758	Achat legumes	23900.00	0.00	CANTINE-20250904	\N	\N	834	1	241	brouillon	\N	\N
1759	Achat legumes	0.00	23900.00	CANTINE-20250904	\N	\N	834	1	236	brouillon	\N	\N
1760	Achat viande	26900.00	0.00	CANTINE-20250905	\N	\N	835	1	242	brouillon	\N	\N
1761	Achat viande	0.00	26900.00	CANTINE-20250905	\N	\N	835	1	236	brouillon	\N	\N
1762	Achat gouter	13500.00	0.00	CANTINE-20250908	\N	\N	836	1	243	brouillon	\N	\N
1763	Achat gouter	0.00	13500.00	CANTINE-20250908	\N	\N	836	1	236	brouillon	\N	\N
1764	Achat legumes	24200.00	0.00	CANTINE-20250909	\N	\N	837	1	241	brouillon	\N	\N
1765	Achat legumes	0.00	24200.00	CANTINE-20250909	\N	\N	837	1	236	brouillon	\N	\N
1766	Achat viande	27200.00	0.00	CANTINE-20250910	\N	\N	838	1	242	brouillon	\N	\N
1767	Achat viande	0.00	27200.00	CANTINE-20250910	\N	\N	838	1	236	brouillon	\N	\N
1768	Achat gouter	13700.00	0.00	CANTINE-20250911	\N	\N	839	1	243	brouillon	\N	\N
1769	Achat gouter	0.00	13700.00	CANTINE-20250911	\N	\N	839	1	236	brouillon	\N	\N
1770	Achat legumes	24500.00	0.00	CANTINE-20250912	\N	\N	840	1	241	brouillon	\N	\N
1771	Achat legumes	0.00	24500.00	CANTINE-20250912	\N	\N	840	1	236	brouillon	\N	\N
1772	Achat viande	27500.00	0.00	CANTINE-20250915	\N	\N	841	1	242	brouillon	\N	\N
1773	Achat viande	0.00	27500.00	CANTINE-20250915	\N	\N	841	1	236	brouillon	\N	\N
1774	Achat gouter	13900.00	0.00	CANTINE-20250916	\N	\N	842	1	243	brouillon	\N	\N
1775	Achat gouter	0.00	13900.00	CANTINE-20250916	\N	\N	842	1	236	brouillon	\N	\N
1776	Achat legumes	24800.00	0.00	CANTINE-20250917	\N	\N	843	1	241	brouillon	\N	\N
1777	Achat legumes	0.00	24800.00	CANTINE-20250917	\N	\N	843	1	236	brouillon	\N	\N
1778	Achat viande	27800.00	0.00	CANTINE-20250918	\N	\N	844	1	242	brouillon	\N	\N
1779	Achat viande	0.00	27800.00	CANTINE-20250918	\N	\N	844	1	236	brouillon	\N	\N
1780	Achat gouter	14100.00	0.00	CANTINE-20250919	\N	\N	845	1	243	brouillon	\N	\N
1781	Achat gouter	0.00	14100.00	CANTINE-20250919	\N	\N	845	1	236	brouillon	\N	\N
1782	Achat legumes	25100.00	0.00	CANTINE-20250922	\N	\N	846	1	241	brouillon	\N	\N
1783	Achat legumes	0.00	25100.00	CANTINE-20250922	\N	\N	846	1	236	brouillon	\N	\N
1784	Achat viande	28100.00	0.00	CANTINE-20250923	\N	\N	847	1	242	brouillon	\N	\N
1785	Achat viande	0.00	28100.00	CANTINE-20250923	\N	\N	847	1	236	brouillon	\N	\N
1786	Achat gouter	14300.00	0.00	CANTINE-20250924	\N	\N	848	1	243	brouillon	\N	\N
1787	Achat gouter	0.00	14300.00	CANTINE-20250924	\N	\N	848	1	236	brouillon	\N	\N
1788	Achat legumes	25400.00	0.00	CANTINE-20250925	\N	\N	849	1	241	brouillon	\N	\N
1789	Achat legumes	0.00	25400.00	CANTINE-20250925	\N	\N	849	1	236	brouillon	\N	\N
1790	Achat viande	28400.00	0.00	CANTINE-20250926	\N	\N	850	1	242	brouillon	\N	\N
1791	Achat viande	0.00	28400.00	CANTINE-20250926	\N	\N	850	1	236	brouillon	\N	\N
1792	Achat gouter	14500.00	0.00	CANTINE-20250929	\N	\N	851	1	243	brouillon	\N	\N
1793	Achat gouter	0.00	14500.00	CANTINE-20250929	\N	\N	851	1	236	brouillon	\N	\N
1794	Echeancier pret bancaire	1150000.00	0.00	PRET-20250930	\N	\N	852	1	244	brouillon	\N	\N
1795	Ecolage divers élèves	1150000.00	0.00	PRET-20250930	\N	\N	852	1	236	brouillon	\N	\N
1796	Ecolage divers élèves	0.00	1710000.00	ECOL-20250930	\N	\N	853	1	193	brouillon	\N	\N
1797	Ecolage divers élèves	1710000.00	0.00	ECOL-20250930	\N	\N	853	1	236	brouillon	\N	\N
1798	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20251002	\N	\N	854	1	238	brouillon	\N	\N
1799	Paiement salaire gardien	180000.00	0.00	SALAIRE-20251002	\N	\N	854	1	239	brouillon	\N	\N
1800	Paiement femme de ménage	150000.00	0.00	SALAIRE-20251002	\N	\N	854	1	240	brouillon	\N	\N
1801	Paiement salaires	0.00	580000.00	SALAIRE-20251002	\N	\N	854	1	236	brouillon	\N	\N
1802	Jirama	45200.00	0.00	JIRAMA-20251004	\N	\N	855	1	99	brouillon	\N	\N
1803	Jirama	0.00	45200.00	JIRAMA-20251004	\N	\N	855	1	236	brouillon	\N	\N
1804	Achat fournitures scolaires	148000.00	0.00	FOURN-20251006	\N	\N	856	1	79	brouillon	\N	\N
1805	Achat fournitures scolaires	0.00	148000.00	FOURN-20251006	\N	\N	856	1	40	brouillon	\N	\N
1806	Règlement fournisseur	148000.00	0.00	REG-FOURN-20251008	\N	\N	857	1	40	brouillon	\N	\N
1807	Règlement fournisseur	0.00	148000.00	REG-FOURN-20251008	\N	\N	857	1	236	brouillon	\N	\N
1808	Achat legumes	25300.00	0.00	CANTINE-20251009	\N	\N	858	1	241	brouillon	\N	\N
1809	Achat legumes	0.00	25300.00	CANTINE-20251009	\N	\N	858	1	236	brouillon	\N	\N
1810	Achat viande	28300.00	0.00	CANTINE-20251010	\N	\N	859	1	242	brouillon	\N	\N
1811	Achat viande	0.00	28300.00	CANTINE-20251010	\N	\N	859	1	236	brouillon	\N	\N
1812	Achat gouter	14700.00	0.00	CANTINE-20251013	\N	\N	860	1	243	brouillon	\N	\N
1813	Achat gouter	0.00	14700.00	CANTINE-20251013	\N	\N	860	1	236	brouillon	\N	\N
1814	Achat legumes	25600.00	0.00	CANTINE-20251014	\N	\N	861	1	241	brouillon	\N	\N
1815	Achat legumes	0.00	25600.00	CANTINE-20251014	\N	\N	861	1	236	brouillon	\N	\N
1816	Achat viande	28600.00	0.00	CANTINE-20251015	\N	\N	862	1	242	brouillon	\N	\N
1817	Achat viande	0.00	28600.00	CANTINE-20251015	\N	\N	862	1	236	brouillon	\N	\N
1818	Achat gouter	14900.00	0.00	CANTINE-20251016	\N	\N	863	1	243	brouillon	\N	\N
1819	Achat gouter	0.00	14900.00	CANTINE-20251016	\N	\N	863	1	236	brouillon	\N	\N
1820	Achat legumes	25900.00	0.00	CANTINE-20251017	\N	\N	864	1	241	brouillon	\N	\N
1821	Achat legumes	0.00	25900.00	CANTINE-20251017	\N	\N	864	1	236	brouillon	\N	\N
1822	Versement en banque BMOI	190000.00	0.00	VERS201025	\N	\N	865	1	53	brouillon	\N	\N
1823	Versement en banque BMOI	0.00	190000.00	VERS201025	\N	\N	865	1	236	brouillon	\N	\N
1824	Achat viande	28900.00	0.00	CANTINE-20251020	\N	\N	866	1	242	brouillon	\N	\N
1825	Achat viande	0.00	28900.00	CANTINE-20251020	\N	\N	866	1	236	brouillon	\N	\N
1826	Achat gouter	15100.00	0.00	CANTINE-20251021	\N	\N	867	1	243	brouillon	\N	\N
1827	Achat gouter	0.00	15100.00	CANTINE-20251021	\N	\N	867	1	236	brouillon	\N	\N
1828	Ecolage divers élèves	0.00	1730000.00	ECOL-20251022	\N	\N	868	1	193	brouillon	\N	\N
1829	Ecolage divers élèves	1730000.00	0.00	ECOL-20251022	\N	\N	868	1	236	brouillon	\N	\N
1830	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20251027	\N	\N	869	1	238	brouillon	\N	\N
1831	Paiement salaire gardien	180000.00	0.00	SALAIRE-20251027	\N	\N	869	1	239	brouillon	\N	\N
1832	Paiement femme de ménage	150000.00	0.00	SALAIRE-20251027	\N	\N	869	1	240	brouillon	\N	\N
1833	Paiement salaires	0.00	580000.00	SALAIRE-20251027	\N	\N	869	1	236	brouillon	\N	\N
1834	Jirama	46500.00	0.00	JIRAMA-20251029	\N	\N	870	1	99	brouillon	\N	\N
1835	Jirama	0.00	46500.00	JIRAMA-20251029	\N	\N	870	1	236	brouillon	\N	\N
1836	Achat fournitures bureau	152000.00	0.00	FOURN-20251031	\N	\N	871	1	105	brouillon	\N	\N
1837	Achat fournitures bureau	0.00	152000.00	FOURN-20251031	\N	\N	871	1	40	brouillon	\N	\N
1838	Règlement fournisseur	152000.00	0.00	REG-FOURN-20251102	\N	\N	872	1	40	brouillon	\N	\N
1839	Règlement fournisseur	0.00	152000.00	REG-FOURN-20251102	\N	\N	872	1	236	brouillon	\N	\N
1840	Achat legumes	26000.00	0.00	CANTINE-20251103	\N	\N	873	1	241	brouillon	\N	\N
1841	Achat legumes	0.00	26000.00	CANTINE-20251103	\N	\N	873	1	236	brouillon	\N	\N
1842	Achat viande	29000.00	0.00	CANTINE-20251104	\N	\N	874	1	242	brouillon	\N	\N
1843	Achat viande	0.00	29000.00	CANTINE-20251104	\N	\N	874	1	236	brouillon	\N	\N
1844	Achat gouter	15300.00	0.00	CANTINE-20251105	\N	\N	875	1	243	brouillon	\N	\N
1845	Achat gouter	0.00	15300.00	CANTINE-20251105	\N	\N	875	1	236	brouillon	\N	\N
1846	Achat legumes	26300.00	0.00	CANTINE-20251106	\N	\N	876	1	241	brouillon	\N	\N
1847	Achat legumes	0.00	26300.00	CANTINE-20251106	\N	\N	876	1	236	brouillon	\N	\N
1848	Achat viande	29300.00	0.00	CANTINE-20251107	\N	\N	877	1	242	brouillon	\N	\N
1849	Achat viande	0.00	29300.00	CANTINE-20251107	\N	\N	877	1	236	brouillon	\N	\N
1850	Achat gouter	15500.00	0.00	CANTINE-20251110	\N	\N	878	1	243	brouillon	\N	\N
1851	Achat gouter	0.00	15500.00	CANTINE-20251110	\N	\N	878	1	236	brouillon	\N	\N
1852	Achat legumes	26600.00	0.00	CANTINE-20251111	\N	\N	879	1	241	brouillon	\N	\N
1853	Achat legumes	0.00	26600.00	CANTINE-20251111	\N	\N	879	1	236	brouillon	\N	\N
1854	Achat viande	29600.00	0.00	CANTINE-20251112	\N	\N	880	1	242	brouillon	\N	\N
1855	Achat viande	0.00	29600.00	CANTINE-20251112	\N	\N	880	1	236	brouillon	\N	\N
1856	Achat gouter	15700.00	0.00	CANTINE-20251113	\N	\N	881	1	243	brouillon	\N	\N
1857	Achat gouter	0.00	15700.00	CANTINE-20251113	\N	\N	881	1	236	brouillon	\N	\N
1858	Achat legumes	26900.00	0.00	CANTINE-20251114	\N	\N	882	1	241	brouillon	\N	\N
1859	Achat legumes	0.00	26900.00	CANTINE-20251114	\N	\N	882	1	236	brouillon	\N	\N
1860	Appro caisse via BMOI	0.00	2600000.00	APPRO-20251115	\N	\N	883	1	53	brouillon	\N	\N
1861	Appro caisse via BMOI	2600000.00	0.00	APPRO-20251115	\N	\N	883	1	236	brouillon	\N	\N
1862	Achat viande	29900.00	0.00	CANTINE-20251117	\N	\N	884	1	242	brouillon	\N	\N
1863	Achat viande	0.00	29900.00	CANTINE-20251117	\N	\N	884	1	236	brouillon	\N	\N
1864	Achat gouter	15900.00	0.00	CANTINE-20251118	\N	\N	885	1	243	brouillon	\N	\N
1865	Achat gouter	0.00	15900.00	CANTINE-20251118	\N	\N	885	1	236	brouillon	\N	\N
1866	Achat legumes	27200.00	0.00	CANTINE-20251119	\N	\N	886	1	241	brouillon	\N	\N
1867	Achat legumes	0.00	27200.00	CANTINE-20251119	\N	\N	886	1	236	brouillon	\N	\N
1868	Ecolage divers élèves	0.00	1750000.00	ECOL-20251120	\N	\N	887	1	193	brouillon	\N	\N
1869	Ecolage divers élèves	1750000.00	0.00	ECOL-20251120	\N	\N	887	1	236	brouillon	\N	\N
1870	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20251125	\N	\N	888	1	238	brouillon	\N	\N
1871	Paiement salaire gardien	180000.00	0.00	SALAIRE-20251125	\N	\N	888	1	239	brouillon	\N	\N
1872	Paiement femme de ménage	150000.00	0.00	SALAIRE-20251125	\N	\N	888	1	240	brouillon	\N	\N
1873	Paiement salaires	0.00	580000.00	SALAIRE-20251125	\N	\N	888	1	236	brouillon	\N	\N
1874	Jirama	47800.00	0.00	JIRAMA-20251127	\N	\N	889	1	99	brouillon	\N	\N
1875	Jirama	0.00	47800.00	JIRAMA-20251127	\N	\N	889	1	236	brouillon	\N	\N
1876	Achat matériel éducatif	155000.00	0.00	FOURN-20251128	\N	\N	890	1	97	brouillon	\N	\N
1877	Achat matériel éducatif	0.00	155000.00	FOURN-20251128	\N	\N	890	1	40	brouillon	\N	\N
1878	Règlement fournisseur	155000.00	0.00	REG-FOURN-20251130	\N	\N	891	1	40	brouillon	\N	\N
1879	Règlement fournisseur	0.00	155000.00	REG-FOURN-20251130	\N	\N	891	1	236	brouillon	\N	\N
1880	Achat legumes	27100.00	0.00	CANTINE-20251201	\N	\N	892	1	241	brouillon	\N	\N
1881	Achat legumes	0.00	27100.00	CANTINE-20251201	\N	\N	892	1	236	brouillon	\N	\N
1882	Achat viande	30100.00	0.00	CANTINE-20251202	\N	\N	893	1	242	brouillon	\N	\N
1883	Achat viande	0.00	30100.00	CANTINE-20251202	\N	\N	893	1	236	brouillon	\N	\N
1884	Achat gouter	16100.00	0.00	CANTINE-20251203	\N	\N	894	1	243	brouillon	\N	\N
1885	Achat gouter	0.00	16100.00	CANTINE-20251203	\N	\N	894	1	236	brouillon	\N	\N
1886	Achat legumes	27400.00	0.00	CANTINE-20251204	\N	\N	895	1	241	brouillon	\N	\N
1887	Achat legumes	0.00	27400.00	CANTINE-20251204	\N	\N	895	1	236	brouillon	\N	\N
1888	Achat viande	30400.00	0.00	CANTINE-20251205	\N	\N	896	1	242	brouillon	\N	\N
1889	Achat viande	0.00	30400.00	CANTINE-20251205	\N	\N	896	1	236	brouillon	\N	\N
1890	Achat gouter	16300.00	0.00	CANTINE-20251208	\N	\N	897	1	243	brouillon	\N	\N
1891	Achat gouter	0.00	16300.00	CANTINE-20251208	\N	\N	897	1	236	brouillon	\N	\N
1892	Achat legumes	27700.00	0.00	CANTINE-20251209	\N	\N	898	1	241	brouillon	\N	\N
1893	Achat legumes	0.00	27700.00	CANTINE-20251209	\N	\N	898	1	236	brouillon	\N	\N
1894	Achat viande	30700.00	0.00	CANTINE-20251210	\N	\N	899	1	242	brouillon	\N	\N
1895	Achat viande	0.00	30700.00	CANTINE-20251210	\N	\N	899	1	236	brouillon	\N	\N
1896	Achat gouter	16500.00	0.00	CANTINE-20251211	\N	\N	900	1	243	brouillon	\N	\N
1897	Achat gouter	0.00	16500.00	CANTINE-20251211	\N	\N	900	1	236	brouillon	\N	\N
1898	Achat legumes	28000.00	0.00	CANTINE-20251212	\N	\N	901	1	241	brouillon	\N	\N
1899	Achat legumes	0.00	28000.00	CANTINE-20251212	\N	\N	901	1	236	brouillon	\N	\N
1900	Achat viande	31000.00	0.00	CANTINE-20251215	\N	\N	902	1	242	brouillon	\N	\N
1901	Achat viande	0.00	31000.00	CANTINE-20251215	\N	\N	902	1	236	brouillon	\N	\N
1902	Achat gouter	16700.00	0.00	CANTINE-20251216	\N	\N	903	1	243	brouillon	\N	\N
1903	Achat gouter	0.00	16700.00	CANTINE-20251216	\N	\N	903	1	236	brouillon	\N	\N
1904	Achat legumes	28300.00	0.00	CANTINE-20251217	\N	\N	904	1	241	brouillon	\N	\N
1905	Achat legumes	0.00	28300.00	CANTINE-20251217	\N	\N	904	1	236	brouillon	\N	\N
1906	Achat viande	31300.00	0.00	CANTINE-20251218	\N	\N	905	1	242	brouillon	\N	\N
1907	Achat viande	0.00	31300.00	CANTINE-20251218	\N	\N	905	1	236	brouillon	\N	\N
1908	Achat gouter	16900.00	0.00	CANTINE-20251219	\N	\N	906	1	243	brouillon	\N	\N
1909	Achat gouter	0.00	16900.00	CANTINE-20251219	\N	\N	906	1	236	brouillon	\N	\N
1910	Ecolage divers élèves	0.00	1770000.00	ECOL-20251222	\N	\N	907	1	193	brouillon	\N	\N
1911	Ecolage divers élèves	1770000.00	0.00	ECOL-20251222	\N	\N	907	1	236	brouillon	\N	\N
1912	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20251226	\N	\N	908	1	238	brouillon	\N	\N
1913	Paiement salaire gardien	180000.00	0.00	SALAIRE-20251226	\N	\N	908	1	239	brouillon	\N	\N
1914	Paiement femme de ménage	150000.00	0.00	SALAIRE-20251226	\N	\N	908	1	240	brouillon	\N	\N
1915	Paiement salaires	0.00	580000.00	SALAIRE-20251226	\N	\N	908	1	236	brouillon	\N	\N
1916	Jirama	49200.00	0.00	JIRAMA-20251228	\N	\N	909	1	99	brouillon	\N	\N
1917	Jirama	0.00	49200.00	JIRAMA-20251228	\N	\N	909	1	236	brouillon	\N	\N
1918	Achat fournitures pédagogiques	158000.00	0.00	FOURN-20251230	\N	\N	910	1	106	brouillon	\N	\N
1919	Achat fournitures pédagogiques	0.00	158000.00	FOURN-20251230	\N	\N	910	1	40	brouillon	\N	\N
1920	Règlement fournisseur	158000.00	0.00	REG-FOURN-20251231	\N	\N	911	1	40	brouillon	\N	\N
1921	Règlement fournisseur	0.00	158000.00	REG-FOURN-20251231	\N	\N	911	1	236	brouillon	\N	\N
1250	Achat legumes	0.00	23900.00	CANTINE-20250904	\N	\N	593	1	236	valide	2025-11-14 07:25:37	\N
1	Achat legumes	12000.00	0.00	CANTINE-20230103	\N	\N	1	1	241	valide	2025-11-14 07:25:37	\N
2	Achat legumes	0.00	12000.00	CANTINE-20230103	\N	\N	1	1	236	valide	2025-11-14 07:25:37	\N
3	Achat viande	15000.00	0.00	CANTINE-20230104	\N	\N	2	1	242	valide	2025-11-14 07:25:37	\N
4	Achat viande	0.00	15000.00	CANTINE-20230104	\N	\N	2	1	236	valide	2025-11-14 07:25:37	\N
5	Achat gouter	5000.00	0.00	CANTINE-20230105	\N	\N	3	1	243	valide	2025-11-14 07:25:37	\N
6	Achat gouter	0.00	5000.00	CANTINE-20230105	\N	\N	3	1	236	valide	2025-11-14 07:25:37	\N
7	Achat legumes	13000.00	0.00	CANTINE-20230106	\N	\N	4	1	241	valide	2025-11-14 07:25:37	\N
8	Achat legumes	0.00	13000.00	CANTINE-20230106	\N	\N	4	1	236	valide	2025-11-14 07:25:37	\N
9	Achat viande	16000.00	0.00	CANTINE-20230109	\N	\N	5	1	242	valide	2025-11-14 07:25:37	\N
10	Achat viande	0.00	16000.00	CANTINE-20230109	\N	\N	5	1	236	valide	2025-11-14 07:25:37	\N
11	Achat gouter	5500.00	0.00	CANTINE-20230110	\N	\N	6	1	243	valide	2025-11-14 07:25:37	\N
12	Achat gouter	0.00	5500.00	CANTINE-20230110	\N	\N	6	1	236	valide	2025-11-14 07:25:37	\N
13	Achat legumes	12500.00	0.00	CANTINE-20230111	\N	\N	7	1	241	valide	2025-11-14 07:25:37	\N
14	Achat legumes	0.00	12500.00	CANTINE-20230111	\N	\N	7	1	236	valide	2025-11-14 07:25:37	\N
15	Achat viande	15500.00	0.00	CANTINE-20230112	\N	\N	8	1	242	valide	2025-11-14 07:25:37	\N
16	Achat viande	0.00	15500.00	CANTINE-20230112	\N	\N	8	1	236	valide	2025-11-14 07:25:37	\N
17	Achat gouter	5200.00	0.00	CANTINE-20230113	\N	\N	9	1	243	valide	2025-11-14 07:25:37	\N
18	Achat gouter	0.00	5200.00	CANTINE-20230113	\N	\N	9	1	236	valide	2025-11-14 07:25:37	\N
19	Achat legumes	14000.00	0.00	CANTINE-20230116	\N	\N	10	1	241	valide	2025-11-14 07:25:37	\N
20	Achat legumes	0.00	14000.00	CANTINE-20230116	\N	\N	10	1	236	valide	2025-11-14 07:25:37	\N
21	Achat viande	16500.00	0.00	CANTINE-20230117	\N	\N	11	1	242	valide	2025-11-14 07:25:37	\N
22	Achat viande	0.00	16500.00	CANTINE-20230117	\N	\N	11	1	236	valide	2025-11-14 07:25:37	\N
23	Achat gouter	5800.00	0.00	CANTINE-20230118	\N	\N	12	1	243	valide	2025-11-14 07:25:37	\N
1375	Achat gouter	16100.00	0.00	CANTINE-20251203	\N	\N	653	1	243	valide	2025-11-14 07:25:37	\N
24	Achat gouter	0.00	5800.00	CANTINE-20230118	\N	\N	12	1	236	valide	2025-11-14 07:25:37	\N
25	Achat legumes	13500.00	0.00	CANTINE-20230119	\N	\N	13	1	241	valide	2025-11-14 07:25:37	\N
26	Achat legumes	0.00	13500.00	CANTINE-20230119	\N	\N	13	1	236	valide	2025-11-14 07:25:37	\N
27	Ecolage divers élèves	0.00	1480000.00	ECOL-20230120	\N	\N	14	1	193	valide	2025-11-14 07:25:37	\N
28	Ecolage divers élèves	1480000.00	0.00	ECOL-20230120	\N	\N	14	1	236	valide	2025-11-14 07:25:37	\N
29	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20230123	\N	\N	15	1	238	valide	2025-11-14 07:25:37	\N
30	Paiement salaire gardien	180000.00	0.00	SALAIRE-20230123	\N	\N	15	1	239	valide	2025-11-14 07:25:37	\N
31	Paiement femme de ménage	150000.00	0.00	SALAIRE-20230123	\N	\N	15	1	240	valide	2025-11-14 07:25:37	\N
32	Paiement salaires	0.00	580000.00	SALAIRE-20230123	\N	\N	15	1	236	valide	2025-11-14 07:25:37	\N
33	Jirama	28500.00	0.00	JIRAMA-20230125	\N	\N	16	1	99	valide	2025-11-14 07:25:37	\N
34	Jirama	0.00	28500.00	JIRAMA-20230125	\N	\N	16	1	236	valide	2025-11-14 07:25:37	\N
35	Achat fournitures scolaires	125000.00	0.00	FOURN-20230130	\N	\N	17	1	79	valide	2025-11-14 07:25:37	\N
36	Achat fournitures scolaires	0.00	125000.00	FOURN-20230130	\N	\N	17	1	40	valide	2025-11-14 07:25:37	\N
37	Règlement fournisseur	125000.00	0.00	REG-FOURN-20230131	\N	\N	18	1	40	valide	2025-11-14 07:25:37	\N
38	Règlement fournisseur	0.00	125000.00	REG-FOURN-20230131	\N	\N	18	1	236	valide	2025-11-14 07:25:37	\N
39	Achat legumes	12800.00	0.00	CANTINE-20230201	\N	\N	19	1	241	valide	2025-11-14 07:25:37	\N
40	Achat legumes	0.00	12800.00	CANTINE-20230201	\N	\N	19	1	236	valide	2025-11-14 07:25:37	\N
41	Achat viande	15800.00	0.00	CANTINE-20230202	\N	\N	20	1	242	valide	2025-11-14 07:25:37	\N
42	Achat viande	0.00	15800.00	CANTINE-20230202	\N	\N	20	1	236	valide	2025-11-14 07:25:37	\N
43	Achat gouter	5300.00	0.00	CANTINE-20230203	\N	\N	21	1	243	valide	2025-11-14 07:25:37	\N
44	Achat gouter	0.00	5300.00	CANTINE-20230203	\N	\N	21	1	236	valide	2025-11-14 07:25:37	\N
45	Achat legumes	13200.00	0.00	CANTINE-20230206	\N	\N	22	1	241	valide	2025-11-14 07:25:37	\N
46	Achat legumes	0.00	13200.00	CANTINE-20230206	\N	\N	22	1	236	valide	2025-11-14 07:25:37	\N
47	Achat viande	16200.00	0.00	CANTINE-20230207	\N	\N	23	1	242	valide	2025-11-14 07:25:37	\N
48	Achat viande	0.00	16200.00	CANTINE-20230207	\N	\N	23	1	236	valide	2025-11-14 07:25:37	\N
49	Achat gouter	5600.00	0.00	CANTINE-20230208	\N	\N	24	1	243	valide	2025-11-14 07:25:37	\N
50	Achat gouter	0.00	5600.00	CANTINE-20230208	\N	\N	24	1	236	valide	2025-11-14 07:25:37	\N
51	Achat legumes	13800.00	0.00	CANTINE-20230209	\N	\N	25	1	241	valide	2025-11-14 07:25:37	\N
52	Achat legumes	0.00	13800.00	CANTINE-20230209	\N	\N	25	1	236	valide	2025-11-14 07:25:37	\N
53	Achat viande	16800.00	0.00	CANTINE-20230210	\N	\N	26	1	242	valide	2025-11-14 07:25:37	\N
54	Achat viande	0.00	16800.00	CANTINE-20230210	\N	\N	26	1	236	valide	2025-11-14 07:25:37	\N
55	Achat gouter	5900.00	0.00	CANTINE-20230213	\N	\N	27	1	243	valide	2025-11-14 07:25:37	\N
56	Achat gouter	0.00	5900.00	CANTINE-20230213	\N	\N	27	1	236	valide	2025-11-14 07:25:37	\N
57	Achat legumes	14200.00	0.00	CANTINE-20230214	\N	\N	28	1	241	valide	2025-11-14 07:25:37	\N
58	Achat legumes	0.00	14200.00	CANTINE-20230214	\N	\N	28	1	236	valide	2025-11-14 07:25:37	\N
59	Achat viande	17200.00	0.00	CANTINE-20230215	\N	\N	29	1	242	valide	2025-11-14 07:25:37	\N
60	Achat viande	0.00	17200.00	CANTINE-20230215	\N	\N	29	1	236	valide	2025-11-14 07:25:37	\N
61	Achat gouter	6100.00	0.00	CANTINE-20230216	\N	\N	30	1	243	valide	2025-11-14 07:25:37	\N
62	Achat gouter	0.00	6100.00	CANTINE-20230216	\N	\N	30	1	236	valide	2025-11-14 07:25:37	\N
63	Achat legumes	14500.00	0.00	CANTINE-20230217	\N	\N	31	1	241	valide	2025-11-14 07:25:37	\N
64	Achat legumes	0.00	14500.00	CANTINE-20230217	\N	\N	31	1	236	valide	2025-11-14 07:25:37	\N
65	Ecolage divers élèves	0.00	1490000.00	ECOL-20230220	\N	\N	32	1	193	valide	2025-11-14 07:25:37	\N
66	Ecolage divers élèves	1490000.00	0.00	ECOL-20230220	\N	\N	32	1	236	valide	2025-11-14 07:25:37	\N
67	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20230223	\N	\N	33	1	238	valide	2025-11-14 07:25:37	\N
68	Paiement salaire gardien	180000.00	0.00	SALAIRE-20230223	\N	\N	33	1	239	valide	2025-11-14 07:25:37	\N
69	Paiement femme de ménage	150000.00	0.00	SALAIRE-20230223	\N	\N	33	1	240	valide	2025-11-14 07:25:37	\N
70	Paiement salaires	0.00	580000.00	SALAIRE-20230223	\N	\N	33	1	236	valide	2025-11-14 07:25:37	\N
71	Jirama	29800.00	0.00	JIRAMA-20230225	\N	\N	34	1	99	valide	2025-11-14 07:25:37	\N
72	Jirama	0.00	29800.00	JIRAMA-20230225	\N	\N	34	1	236	valide	2025-11-14 07:25:37	\N
73	Achat fournitures bureau	118000.00	0.00	FOURN-20230228	\N	\N	35	1	105	valide	2025-11-14 07:25:37	\N
74	Achat fournitures bureau	0.00	118000.00	FOURN-20230228	\N	\N	35	1	40	valide	2025-11-14 07:25:37	\N
75	Règlement fournisseur	118000.00	0.00	REG-FOURN-20230302	\N	\N	36	1	40	valide	2025-11-14 07:25:37	\N
76	Règlement fournisseur	0.00	118000.00	REG-FOURN-20230302	\N	\N	36	1	236	valide	2025-11-14 07:25:37	\N
77	Achat legumes	13500.00	0.00	CANTINE-20230301	\N	\N	37	1	241	valide	2025-11-14 07:25:37	\N
78	Achat legumes	0.00	13500.00	CANTINE-20230301	\N	\N	37	1	236	valide	2025-11-14 07:25:37	\N
79	Achat viande	16500.00	0.00	CANTINE-20230302	\N	\N	38	1	242	valide	2025-11-14 07:25:37	\N
80	Achat viande	0.00	16500.00	CANTINE-20230302	\N	\N	38	1	236	valide	2025-11-14 07:25:37	\N
81	Achat gouter	5800.00	0.00	CANTINE-20230303	\N	\N	39	1	243	valide	2025-11-14 07:25:37	\N
82	Achat gouter	0.00	5800.00	CANTINE-20230303	\N	\N	39	1	236	valide	2025-11-14 07:25:37	\N
83	Achat legumes	14000.00	0.00	CANTINE-20230306	\N	\N	40	1	241	valide	2025-11-14 07:25:37	\N
84	Achat legumes	0.00	14000.00	CANTINE-20230306	\N	\N	40	1	236	valide	2025-11-14 07:25:37	\N
85	Achat viande	17000.00	0.00	CANTINE-20230307	\N	\N	41	1	242	valide	2025-11-14 07:25:37	\N
86	Achat viande	0.00	17000.00	CANTINE-20230307	\N	\N	41	1	236	valide	2025-11-14 07:25:37	\N
87	Achat gouter	6000.00	0.00	CANTINE-20230308	\N	\N	42	1	243	valide	2025-11-14 07:25:37	\N
88	Achat gouter	0.00	6000.00	CANTINE-20230308	\N	\N	42	1	236	valide	2025-11-14 07:25:37	\N
89	Achat legumes	14500.00	0.00	CANTINE-20230309	\N	\N	43	1	241	valide	2025-11-14 07:25:37	\N
90	Achat legumes	0.00	14500.00	CANTINE-20230309	\N	\N	43	1	236	valide	2025-11-14 07:25:37	\N
91	Achat viande	17500.00	0.00	CANTINE-20230310	\N	\N	44	1	242	valide	2025-11-14 07:25:37	\N
92	Achat viande	0.00	17500.00	CANTINE-20230310	\N	\N	44	1	236	valide	2025-11-14 07:25:37	\N
93	Achat gouter	6200.00	0.00	CANTINE-20230313	\N	\N	45	1	243	valide	2025-11-14 07:25:37	\N
94	Achat gouter	0.00	6200.00	CANTINE-20230313	\N	\N	45	1	236	valide	2025-11-14 07:25:37	\N
95	Achat legumes	14800.00	0.00	CANTINE-20230314	\N	\N	46	1	241	valide	2025-11-14 07:25:37	\N
96	Achat legumes	0.00	14800.00	CANTINE-20230314	\N	\N	46	1	236	valide	2025-11-14 07:25:37	\N
97	Achat viande	17800.00	0.00	CANTINE-20230315	\N	\N	47	1	242	valide	2025-11-14 07:25:37	\N
98	Achat viande	0.00	17800.00	CANTINE-20230315	\N	\N	47	1	236	valide	2025-11-14 07:25:37	\N
99	Achat gouter	6400.00	0.00	CANTINE-20230316	\N	\N	48	1	243	valide	2025-11-14 07:25:37	\N
100	Achat gouter	0.00	6400.00	CANTINE-20230316	\N	\N	48	1	236	valide	2025-11-14 07:25:37	\N
101	Achat legumes	15000.00	0.00	CANTINE-20230317	\N	\N	49	1	241	valide	2025-11-14 07:25:37	\N
102	Achat legumes	0.00	15000.00	CANTINE-20230317	\N	\N	49	1	236	valide	2025-11-14 07:25:37	\N
103	Ecolage divers élèves	0.00	1510000.00	ECOL-20230320	\N	\N	50	1	193	valide	2025-11-14 07:25:37	\N
104	Ecolage divers élèves	1510000.00	0.00	ECOL-20230320	\N	\N	50	1	236	valide	2025-11-14 07:25:37	\N
105	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20230323	\N	\N	51	1	238	valide	2025-11-14 07:25:37	\N
106	Paiement salaire gardien	180000.00	0.00	SALAIRE-20230323	\N	\N	51	1	239	valide	2025-11-14 07:25:37	\N
107	Paiement femme de ménage	150000.00	0.00	SALAIRE-20230323	\N	\N	51	1	240	valide	2025-11-14 07:25:37	\N
108	Paiement salaires	0.00	580000.00	SALAIRE-20230323	\N	\N	51	1	236	valide	2025-11-14 07:25:37	\N
109	Jirama	31200.00	0.00	JIRAMA-20230325	\N	\N	52	1	99	valide	2025-11-14 07:25:37	\N
110	Jirama	0.00	31200.00	JIRAMA-20230325	\N	\N	52	1	236	valide	2025-11-14 07:25:37	\N
111	Achat matériel éducatif	132000.00	0.00	FOURN-20230329	\N	\N	53	1	97	valide	2025-11-14 07:25:37	\N
112	Achat matériel éducatif	0.00	132000.00	FOURN-20230329	\N	\N	53	1	40	valide	2025-11-14 07:25:37	\N
113	Règlement fournisseur	132000.00	0.00	REG-FOURN-20230331	\N	\N	54	1	40	valide	2025-11-14 07:25:37	\N
114	Règlement fournisseur	0.00	132000.00	REG-FOURN-20230331	\N	\N	54	1	236	valide	2025-11-14 07:25:37	\N
115	Achat legumes	14200.00	0.00	CANTINE-20230403	\N	\N	55	1	241	valide	2025-11-14 07:25:37	\N
116	Achat legumes	0.00	14200.00	CANTINE-20230403	\N	\N	55	1	236	valide	2025-11-14 07:25:37	\N
117	Achat viande	17200.00	0.00	CANTINE-20230404	\N	\N	56	1	242	valide	2025-11-14 07:25:37	\N
118	Achat viande	0.00	17200.00	CANTINE-20230404	\N	\N	56	1	236	valide	2025-11-14 07:25:37	\N
119	Achat gouter	6500.00	0.00	CANTINE-20230405	\N	\N	57	1	243	valide	2025-11-14 07:25:37	\N
120	Achat gouter	0.00	6500.00	CANTINE-20230405	\N	\N	57	1	236	valide	2025-11-14 07:25:37	\N
121	Achat legumes	14600.00	0.00	CANTINE-20230406	\N	\N	58	1	241	valide	2025-11-14 07:25:37	\N
122	Achat legumes	0.00	14600.00	CANTINE-20230406	\N	\N	58	1	236	valide	2025-11-14 07:25:37	\N
123	Achat viande	17600.00	0.00	CANTINE-20230407	\N	\N	59	1	242	valide	2025-11-14 07:25:37	\N
124	Achat viande	0.00	17600.00	CANTINE-20230407	\N	\N	59	1	236	valide	2025-11-14 07:25:37	\N
125	Achat gouter	6700.00	0.00	CANTINE-20230410	\N	\N	60	1	243	valide	2025-11-14 07:25:37	\N
126	Achat gouter	0.00	6700.00	CANTINE-20230410	\N	\N	60	1	236	valide	2025-11-14 07:25:37	\N
127	Achat legumes	14900.00	0.00	CANTINE-20230411	\N	\N	61	1	241	valide	2025-11-14 07:25:37	\N
128	Achat legumes	0.00	14900.00	CANTINE-20230411	\N	\N	61	1	236	valide	2025-11-14 07:25:37	\N
129	Achat viande	17900.00	0.00	CANTINE-20230412	\N	\N	62	1	242	valide	2025-11-14 07:25:37	\N
130	Achat viande	0.00	17900.00	CANTINE-20230412	\N	\N	62	1	236	valide	2025-11-14 07:25:37	\N
131	Achat gouter	6900.00	0.00	CANTINE-20230413	\N	\N	63	1	243	valide	2025-11-14 07:25:37	\N
132	Achat gouter	0.00	6900.00	CANTINE-20230413	\N	\N	63	1	236	valide	2025-11-14 07:25:37	\N
133	Achat legumes	15200.00	0.00	CANTINE-20230414	\N	\N	64	1	241	valide	2025-11-14 07:25:37	\N
134	Achat legumes	0.00	15200.00	CANTINE-20230414	\N	\N	64	1	236	valide	2025-11-14 07:25:37	\N
135	Achat viande	18200.00	0.00	CANTINE-20230417	\N	\N	65	1	242	valide	2025-11-14 07:25:37	\N
136	Achat viande	0.00	18200.00	CANTINE-20230417	\N	\N	65	1	236	valide	2025-11-14 07:25:37	\N
137	Achat gouter	7100.00	0.00	CANTINE-20230418	\N	\N	66	1	243	valide	2025-11-14 07:25:37	\N
138	Achat gouter	0.00	7100.00	CANTINE-20230418	\N	\N	66	1	236	valide	2025-11-14 07:25:37	\N
139	Ecolage divers élèves	0.00	1530000.00	ECOL-20230420	\N	\N	67	1	193	valide	2025-11-14 07:25:37	\N
140	Ecolage divers élèves	1530000.00	0.00	ECOL-20230420	\N	\N	67	1	236	valide	2025-11-14 07:25:37	\N
141	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20230424	\N	\N	68	1	238	valide	2025-11-14 07:25:37	\N
142	Paiement salaire gardien	180000.00	0.00	SALAIRE-20230424	\N	\N	68	1	239	valide	2025-11-14 07:25:37	\N
143	Paiement femme de ménage	150000.00	0.00	SALAIRE-20230424	\N	\N	68	1	240	valide	2025-11-14 07:25:37	\N
144	Paiement salaires	0.00	580000.00	SALAIRE-20230424	\N	\N	68	1	236	valide	2025-11-14 07:25:37	\N
145	Jirama	32500.00	0.00	JIRAMA-20230425	\N	\N	69	1	99	valide	2025-11-14 07:25:37	\N
146	Jirama	0.00	32500.00	JIRAMA-20230425	\N	\N	69	1	236	valide	2025-11-14 07:25:37	\N
147	Achat fournitures pédagogiques	127000.00	0.00	FOURN-20230428	\N	\N	70	1	106	valide	2025-11-14 07:25:37	\N
211	Ecolage divers élèves	0.00	1570000.00	ECOL-20230620	\N	\N	101	1	193	valide	2025-11-14 07:25:37	\N
148	Achat fournitures pédagogiques	0.00	127000.00	FOURN-20230428	\N	\N	70	1	40	valide	2025-11-14 07:25:37	\N
149	Règlement fournisseur	127000.00	0.00	REG-FOURN-20230430	\N	\N	71	1	40	valide	2025-11-14 07:25:37	\N
150	Règlement fournisseur	0.00	127000.00	REG-FOURN-20230430	\N	\N	71	1	236	valide	2025-11-14 07:25:37	\N
151	Achat legumes	14800.00	0.00	CANTINE-20230502	\N	\N	72	1	241	valide	2025-11-14 07:25:37	\N
152	Achat legumes	0.00	14800.00	CANTINE-20230502	\N	\N	72	1	236	valide	2025-11-14 07:25:37	\N
153	Achat viande	17800.00	0.00	CANTINE-20230503	\N	\N	73	1	242	valide	2025-11-14 07:25:37	\N
154	Achat viande	0.00	17800.00	CANTINE-20230503	\N	\N	73	1	236	valide	2025-11-14 07:25:37	\N
155	Achat gouter	7200.00	0.00	CANTINE-20230504	\N	\N	74	1	243	valide	2025-11-14 07:25:37	\N
156	Achat gouter	0.00	7200.00	CANTINE-20230504	\N	\N	74	1	236	valide	2025-11-14 07:25:37	\N
157	Achat legumes	15100.00	0.00	CANTINE-20230505	\N	\N	75	1	241	valide	2025-11-14 07:25:37	\N
158	Achat legumes	0.00	15100.00	CANTINE-20230505	\N	\N	75	1	236	valide	2025-11-14 07:25:37	\N
159	Achat viande	18100.00	0.00	CANTINE-20230508	\N	\N	76	1	242	valide	2025-11-14 07:25:37	\N
160	Achat viande	0.00	18100.00	CANTINE-20230508	\N	\N	76	1	236	valide	2025-11-14 07:25:37	\N
161	Achat gouter	7400.00	0.00	CANTINE-20230509	\N	\N	77	1	243	valide	2025-11-14 07:25:37	\N
162	Achat gouter	0.00	7400.00	CANTINE-20230509	\N	\N	77	1	236	valide	2025-11-14 07:25:37	\N
163	Achat legumes	15400.00	0.00	CANTINE-20230510	\N	\N	78	1	241	valide	2025-11-14 07:25:37	\N
164	Achat legumes	0.00	15400.00	CANTINE-20230510	\N	\N	78	1	236	valide	2025-11-14 07:25:37	\N
165	Achat viande	18400.00	0.00	CANTINE-20230511	\N	\N	79	1	242	valide	2025-11-14 07:25:37	\N
166	Achat viande	0.00	18400.00	CANTINE-20230511	\N	\N	79	1	236	valide	2025-11-14 07:25:37	\N
167	Achat gouter	7600.00	0.00	CANTINE-20230512	\N	\N	80	1	243	valide	2025-11-14 07:25:37	\N
168	Achat gouter	0.00	7600.00	CANTINE-20230512	\N	\N	80	1	236	valide	2025-11-14 07:25:37	\N
169	Achat legumes	15700.00	0.00	CANTINE-20230515	\N	\N	81	1	241	valide	2025-11-14 07:25:37	\N
170	Achat legumes	0.00	15700.00	CANTINE-20230515	\N	\N	81	1	236	valide	2025-11-14 07:25:37	\N
171	Achat viande	18700.00	0.00	CANTINE-20230516	\N	\N	82	1	242	valide	2025-11-14 07:25:37	\N
172	Achat viande	0.00	18700.00	CANTINE-20230516	\N	\N	82	1	236	valide	2025-11-14 07:25:37	\N
173	Achat gouter	7800.00	0.00	CANTINE-20230517	\N	\N	83	1	243	valide	2025-11-14 07:25:37	\N
174	Achat gouter	0.00	7800.00	CANTINE-20230517	\N	\N	83	1	236	valide	2025-11-14 07:25:37	\N
175	Ecolage divers élèves	0.00	1550000.00	ECOL-20230520	\N	\N	84	1	193	valide	2025-11-14 07:25:37	\N
176	Ecolage divers élèves	1550000.00	0.00	ECOL-20230520	\N	\N	84	1	236	valide	2025-11-14 07:25:37	\N
177	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20230523	\N	\N	85	1	238	valide	2025-11-14 07:25:37	\N
178	Paiement salaire gardien	180000.00	0.00	SALAIRE-20230523	\N	\N	85	1	239	valide	2025-11-14 07:25:37	\N
179	Paiement femme de ménage	150000.00	0.00	SALAIRE-20230523	\N	\N	85	1	240	valide	2025-11-14 07:25:37	\N
180	Paiement salaires	0.00	580000.00	SALAIRE-20230523	\N	\N	85	1	236	valide	2025-11-14 07:25:37	\N
181	Jirama	33800.00	0.00	JIRAMA-20230525	\N	\N	86	1	99	valide	2025-11-14 07:25:37	\N
182	Jirama	0.00	33800.00	JIRAMA-20230525	\N	\N	86	1	236	valide	2025-11-14 07:25:37	\N
183	Achat fournitures scolaires	140000.00	0.00	FOURN-20230529	\N	\N	87	1	79	valide	2025-11-14 07:25:37	\N
184	Achat fournitures scolaires	0.00	140000.00	FOURN-20230529	\N	\N	87	1	40	valide	2025-11-14 07:25:37	\N
185	Règlement fournisseur	140000.00	0.00	REG-FOURN-20230531	\N	\N	88	1	40	valide	2025-11-14 07:25:37	\N
186	Règlement fournisseur	0.00	140000.00	REG-FOURN-20230531	\N	\N	88	1	236	valide	2025-11-14 07:25:37	\N
187	Achat legumes	15500.00	0.00	CANTINE-20230601	\N	\N	89	1	241	valide	2025-11-14 07:25:37	\N
188	Achat legumes	0.00	15500.00	CANTINE-20230601	\N	\N	89	1	236	valide	2025-11-14 07:25:37	\N
189	Achat viande	18500.00	0.00	CANTINE-20230602	\N	\N	90	1	242	valide	2025-11-14 07:25:37	\N
190	Achat viande	0.00	18500.00	CANTINE-20230602	\N	\N	90	1	236	valide	2025-11-14 07:25:37	\N
191	Achat gouter	8000.00	0.00	CANTINE-20230605	\N	\N	91	1	243	valide	2025-11-14 07:25:37	\N
192	Achat gouter	0.00	8000.00	CANTINE-20230605	\N	\N	91	1	236	valide	2025-11-14 07:25:37	\N
193	Achat legumes	15800.00	0.00	CANTINE-20230606	\N	\N	92	1	241	valide	2025-11-14 07:25:37	\N
194	Achat legumes	0.00	15800.00	CANTINE-20230606	\N	\N	92	1	236	valide	2025-11-14 07:25:37	\N
195	Achat viande	18800.00	0.00	CANTINE-20230607	\N	\N	93	1	242	valide	2025-11-14 07:25:37	\N
196	Achat viande	0.00	18800.00	CANTINE-20230607	\N	\N	93	1	236	valide	2025-11-14 07:25:37	\N
197	Achat gouter	8200.00	0.00	CANTINE-20230608	\N	\N	94	1	243	valide	2025-11-14 07:25:37	\N
198	Achat gouter	0.00	8200.00	CANTINE-20230608	\N	\N	94	1	236	valide	2025-11-14 07:25:37	\N
199	Achat legumes	16100.00	0.00	CANTINE-20230609	\N	\N	95	1	241	valide	2025-11-14 07:25:37	\N
200	Achat legumes	0.00	16100.00	CANTINE-20230609	\N	\N	95	1	236	valide	2025-11-14 07:25:37	\N
201	Achat viande	19100.00	0.00	CANTINE-20230612	\N	\N	96	1	242	valide	2025-11-14 07:25:37	\N
202	Achat viande	0.00	19100.00	CANTINE-20230612	\N	\N	96	1	236	valide	2025-11-14 07:25:37	\N
203	Achat gouter	8400.00	0.00	CANTINE-20230613	\N	\N	97	1	243	valide	2025-11-14 07:25:37	\N
204	Achat gouter	0.00	8400.00	CANTINE-20230613	\N	\N	97	1	236	valide	2025-11-14 07:25:37	\N
205	Achat legumes	16400.00	0.00	CANTINE-20230614	\N	\N	98	1	241	valide	2025-11-14 07:25:37	\N
206	Achat legumes	0.00	16400.00	CANTINE-20230614	\N	\N	98	1	236	valide	2025-11-14 07:25:37	\N
207	Achat viande	19400.00	0.00	CANTINE-20230615	\N	\N	99	1	242	valide	2025-11-14 07:25:37	\N
208	Achat viande	0.00	19400.00	CANTINE-20230615	\N	\N	99	1	236	valide	2025-11-14 07:25:37	\N
209	Achat gouter	8600.00	0.00	CANTINE-20230616	\N	\N	100	1	243	valide	2025-11-14 07:25:37	\N
210	Achat gouter	0.00	8600.00	CANTINE-20230616	\N	\N	100	1	236	valide	2025-11-14 07:25:37	\N
212	Ecolage divers élèves	1570000.00	0.00	ECOL-20230620	\N	\N	101	1	236	valide	2025-11-14 07:25:37	\N
213	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20230623	\N	\N	102	1	238	valide	2025-11-14 07:25:37	\N
214	Paiement salaire gardien	180000.00	0.00	SALAIRE-20230623	\N	\N	102	1	239	valide	2025-11-14 07:25:37	\N
215	Paiement femme de ménage	150000.00	0.00	SALAIRE-20230623	\N	\N	102	1	240	valide	2025-11-14 07:25:37	\N
216	Paiement salaires	0.00	580000.00	SALAIRE-20230623	\N	\N	102	1	236	valide	2025-11-14 07:25:37	\N
217	Jirama	35200.00	0.00	JIRAMA-20230625	\N	\N	103	1	99	valide	2025-11-14 07:25:37	\N
218	Jirama	0.00	35200.00	JIRAMA-20230625	\N	\N	103	1	236	valide	2025-11-14 07:25:37	\N
219	Achat fournitures bureau	129000.00	0.00	FOURN-20230628	\N	\N	104	1	105	valide	2025-11-14 07:25:37	\N
220	Achat fournitures bureau	0.00	129000.00	FOURN-20230628	\N	\N	104	1	40	valide	2025-11-14 07:25:37	\N
221	Règlement fournisseur	129000.00	0.00	REG-FOURN-20230630	\N	\N	105	1	40	valide	2025-11-14 07:25:37	\N
222	Règlement fournisseur	0.00	129000.00	REG-FOURN-20230630	\N	\N	105	1	236	valide	2025-11-14 07:25:37	\N
223	Achat legumes	16200.00	0.00	CANTINE-20230703	\N	\N	106	1	241	valide	2025-11-14 07:25:37	\N
224	Achat legumes	0.00	16200.00	CANTINE-20230703	\N	\N	106	1	236	valide	2025-11-14 07:25:37	\N
225	Achat viande	19200.00	0.00	CANTINE-20230704	\N	\N	107	1	242	valide	2025-11-14 07:25:37	\N
226	Achat viande	0.00	19200.00	CANTINE-20230704	\N	\N	107	1	236	valide	2025-11-14 07:25:37	\N
227	Achat gouter	8800.00	0.00	CANTINE-20230705	\N	\N	108	1	243	valide	2025-11-14 07:25:37	\N
228	Achat gouter	0.00	8800.00	CANTINE-20230705	\N	\N	108	1	236	valide	2025-11-14 07:25:37	\N
229	Achat legumes	16500.00	0.00	CANTINE-20230706	\N	\N	109	1	241	valide	2025-11-14 07:25:37	\N
230	Achat legumes	0.00	16500.00	CANTINE-20230706	\N	\N	109	1	236	valide	2025-11-14 07:25:37	\N
231	Achat viande	19500.00	0.00	CANTINE-20230707	\N	\N	110	1	242	valide	2025-11-14 07:25:37	\N
232	Achat viande	0.00	19500.00	CANTINE-20230707	\N	\N	110	1	236	valide	2025-11-14 07:25:37	\N
233	Achat gouter	9000.00	0.00	CANTINE-20230710	\N	\N	111	1	243	valide	2025-11-14 07:25:37	\N
234	Achat gouter	0.00	9000.00	CANTINE-20230710	\N	\N	111	1	236	valide	2025-11-14 07:25:37	\N
235	Achat legumes	16800.00	0.00	CANTINE-20230711	\N	\N	112	1	241	valide	2025-11-14 07:25:37	\N
236	Achat legumes	0.00	16800.00	CANTINE-20230711	\N	\N	112	1	236	valide	2025-11-14 07:25:37	\N
237	Achat viande	19800.00	0.00	CANTINE-20230712	\N	\N	113	1	242	valide	2025-11-14 07:25:37	\N
238	Achat viande	0.00	19800.00	CANTINE-20230712	\N	\N	113	1	236	valide	2025-11-14 07:25:37	\N
239	Achat gouter	9200.00	0.00	CANTINE-20230713	\N	\N	114	1	243	valide	2025-11-14 07:25:37	\N
240	Achat gouter	0.00	9200.00	CANTINE-20230713	\N	\N	114	1	236	valide	2025-11-14 07:25:37	\N
241	Achat legumes	17100.00	0.00	CANTINE-20230714	\N	\N	115	1	241	valide	2025-11-14 07:25:37	\N
242	Achat legumes	0.00	17100.00	CANTINE-20230714	\N	\N	115	1	236	valide	2025-11-14 07:25:37	\N
243	Achat viande	20100.00	0.00	CANTINE-20230717	\N	\N	116	1	242	valide	2025-11-14 07:25:37	\N
244	Achat viande	0.00	20100.00	CANTINE-20230717	\N	\N	116	1	236	valide	2025-11-14 07:25:37	\N
245	Achat gouter	9400.00	0.00	CANTINE-20230718	\N	\N	117	1	243	valide	2025-11-14 07:25:37	\N
246	Achat gouter	0.00	9400.00	CANTINE-20230718	\N	\N	117	1	236	valide	2025-11-14 07:25:37	\N
247	Ecolage divers élèves	0.00	1590000.00	ECOL-20230720	\N	\N	118	1	193	valide	2025-11-14 07:25:37	\N
248	Ecolage divers élèves	1590000.00	0.00	ECOL-20230720	\N	\N	118	1	236	valide	2025-11-14 07:25:37	\N
249	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20230724	\N	\N	119	1	238	valide	2025-11-14 07:25:37	\N
250	Paiement salaire gardien	180000.00	0.00	SALAIRE-20230724	\N	\N	119	1	239	valide	2025-11-14 07:25:37	\N
251	Paiement femme de ménage	150000.00	0.00	SALAIRE-20230724	\N	\N	119	1	240	valide	2025-11-14 07:25:37	\N
252	Paiement salaires	0.00	580000.00	SALAIRE-20230724	\N	\N	119	1	236	valide	2025-11-14 07:25:37	\N
254	Jirama	0.00	36500.00	JIRAMA-20230725	\N	\N	120	1	236	valide	2025-11-14 07:25:37	\N
255	Achat matériel éducatif	135000.00	0.00	FOURN-20230728	\N	\N	121	1	97	valide	2025-11-14 07:25:37	\N
256	Achat matériel éducatif	0.00	135000.00	FOURN-20230728	\N	\N	121	1	40	valide	2025-11-14 07:25:37	\N
257	Règlement fournisseur	135000.00	0.00	REG-FOURN-20230731	\N	\N	122	1	40	valide	2025-11-14 07:25:37	\N
258	Règlement fournisseur	0.00	135000.00	REG-FOURN-20230731	\N	\N	122	1	236	valide	2025-11-14 07:25:37	\N
259	Achat legumes	17000.00	0.00	CANTINE-20230801	\N	\N	123	1	241	valide	2025-11-14 07:25:37	\N
260	Achat legumes	0.00	17000.00	CANTINE-20230801	\N	\N	123	1	236	valide	2025-11-14 07:25:37	\N
261	Achat viande	20000.00	0.00	CANTINE-20230802	\N	\N	124	1	242	valide	2025-11-14 07:25:37	\N
262	Achat viande	0.00	20000.00	CANTINE-20230802	\N	\N	124	1	236	valide	2025-11-14 07:25:37	\N
263	Achat gouter	9600.00	0.00	CANTINE-20230803	\N	\N	125	1	243	valide	2025-11-14 07:25:37	\N
264	Achat gouter	0.00	9600.00	CANTINE-20230803	\N	\N	125	1	236	valide	2025-11-14 07:25:37	\N
265	Achat legumes	17300.00	0.00	CANTINE-20230804	\N	\N	126	1	241	valide	2025-11-14 07:25:37	\N
266	Achat legumes	0.00	17300.00	CANTINE-20230804	\N	\N	126	1	236	valide	2025-11-14 07:25:37	\N
267	Achat viande	20300.00	0.00	CANTINE-20230807	\N	\N	127	1	242	valide	2025-11-14 07:25:37	\N
268	Achat viande	0.00	20300.00	CANTINE-20230807	\N	\N	127	1	236	valide	2025-11-14 07:25:37	\N
269	Achat gouter	9800.00	0.00	CANTINE-20230808	\N	\N	128	1	243	valide	2025-11-14 07:25:37	\N
270	Achat gouter	0.00	9800.00	CANTINE-20230808	\N	\N	128	1	236	valide	2025-11-14 07:25:37	\N
271	Achat legumes	17600.00	0.00	CANTINE-20230809	\N	\N	129	1	241	valide	2025-11-14 07:25:37	\N
272	Achat legumes	0.00	17600.00	CANTINE-20230809	\N	\N	129	1	236	valide	2025-11-14 07:25:37	\N
273	Achat viande	20600.00	0.00	CANTINE-20230810	\N	\N	130	1	242	valide	2025-11-14 07:25:37	\N
274	Achat viande	0.00	20600.00	CANTINE-20230810	\N	\N	130	1	236	valide	2025-11-14 07:25:37	\N
275	Achat gouter	10000.00	0.00	CANTINE-20230811	\N	\N	131	1	243	valide	2025-11-14 07:25:37	\N
276	Achat gouter	0.00	10000.00	CANTINE-20230811	\N	\N	131	1	236	valide	2025-11-14 07:25:37	\N
277	Achat legumes	17900.00	0.00	CANTINE-20230814	\N	\N	132	1	241	valide	2025-11-14 07:25:37	\N
278	Achat legumes	0.00	17900.00	CANTINE-20230814	\N	\N	132	1	236	valide	2025-11-14 07:25:37	\N
279	Achat viande	20900.00	0.00	CANTINE-20230815	\N	\N	133	1	242	valide	2025-11-14 07:25:37	\N
280	Achat viande	0.00	20900.00	CANTINE-20230815	\N	\N	133	1	236	valide	2025-11-14 07:25:37	\N
281	Achat gouter	10200.00	0.00	CANTINE-20230816	\N	\N	134	1	243	valide	2025-11-14 07:25:37	\N
282	Achat gouter	0.00	10200.00	CANTINE-20230816	\N	\N	134	1	236	valide	2025-11-14 07:25:37	\N
283	Ecolage divers élèves	0.00	1610000.00	ECOL-20230820	\N	\N	135	1	193	valide	2025-11-14 07:25:37	\N
284	Ecolage divers élèves	1610000.00	0.00	ECOL-20230820	\N	\N	135	1	236	valide	2025-11-14 07:25:37	\N
285	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20230823	\N	\N	136	1	238	valide	2025-11-14 07:25:37	\N
286	Paiement salaire gardien	180000.00	0.00	SALAIRE-20230823	\N	\N	136	1	239	valide	2025-11-14 07:25:37	\N
287	Paiement femme de ménage	150000.00	0.00	SALAIRE-20230823	\N	\N	136	1	240	valide	2025-11-14 07:25:37	\N
288	Paiement salaires	0.00	580000.00	SALAIRE-20230823	\N	\N	136	1	236	valide	2025-11-14 07:25:37	\N
289	Jirama	37800.00	0.00	JIRAMA-20230825	\N	\N	137	1	99	valide	2025-11-14 07:25:37	\N
290	Jirama	0.00	37800.00	JIRAMA-20230825	\N	\N	137	1	236	valide	2025-11-14 07:25:37	\N
291	Achat fournitures pédagogiques	142000.00	0.00	FOURN-20230829	\N	\N	138	1	106	valide	2025-11-14 07:25:37	\N
292	Achat fournitures pédagogiques	0.00	142000.00	FOURN-20230829	\N	\N	138	1	40	valide	2025-11-14 07:25:37	\N
293	Règlement fournisseur	142000.00	0.00	REG-FOURN-20230831	\N	\N	139	1	40	valide	2025-11-14 07:25:37	\N
294	Règlement fournisseur	0.00	142000.00	REG-FOURN-20230831	\N	\N	139	1	236	valide	2025-11-14 07:25:37	\N
295	Achat legumes	17800.00	0.00	CANTINE-20230901	\N	\N	140	1	241	valide	2025-11-14 07:25:37	\N
296	Achat legumes	0.00	17800.00	CANTINE-20230901	\N	\N	140	1	236	valide	2025-11-14 07:25:37	\N
297	Achat viande	20800.00	0.00	CANTINE-20230904	\N	\N	141	1	242	valide	2025-11-14 07:25:37	\N
298	Achat viande	0.00	20800.00	CANTINE-20230904	\N	\N	141	1	236	valide	2025-11-14 07:25:37	\N
299	Achat gouter	10400.00	0.00	CANTINE-20230905	\N	\N	142	1	243	valide	2025-11-14 07:25:37	\N
300	Achat gouter	0.00	10400.00	CANTINE-20230905	\N	\N	142	1	236	valide	2025-11-14 07:25:37	\N
301	Achat legumes	18100.00	0.00	CANTINE-20230906	\N	\N	143	1	241	valide	2025-11-14 07:25:37	\N
302	Achat legumes	0.00	18100.00	CANTINE-20230906	\N	\N	143	1	236	valide	2025-11-14 07:25:37	\N
303	Achat viande	21100.00	0.00	CANTINE-20230907	\N	\N	144	1	242	valide	2025-11-14 07:25:37	\N
304	Achat viande	0.00	21100.00	CANTINE-20230907	\N	\N	144	1	236	valide	2025-11-14 07:25:37	\N
305	Achat gouter	10600.00	0.00	CANTINE-20230908	\N	\N	145	1	243	valide	2025-11-14 07:25:37	\N
306	Achat gouter	0.00	10600.00	CANTINE-20230908	\N	\N	145	1	236	valide	2025-11-14 07:25:37	\N
307	Achat legumes	18400.00	0.00	CANTINE-20230911	\N	\N	146	1	241	valide	2025-11-14 07:25:37	\N
308	Achat legumes	0.00	18400.00	CANTINE-20230911	\N	\N	146	1	236	valide	2025-11-14 07:25:37	\N
309	Achat viande	21400.00	0.00	CANTINE-20230912	\N	\N	147	1	242	valide	2025-11-14 07:25:37	\N
310	Achat viande	0.00	21400.00	CANTINE-20230912	\N	\N	147	1	236	valide	2025-11-14 07:25:37	\N
311	Achat gouter	10800.00	0.00	CANTINE-20230913	\N	\N	148	1	243	valide	2025-11-14 07:25:37	\N
312	Achat gouter	0.00	10800.00	CANTINE-20230913	\N	\N	148	1	236	valide	2025-11-14 07:25:37	\N
313	Achat legumes	18700.00	0.00	CANTINE-20230914	\N	\N	149	1	241	valide	2025-11-14 07:25:37	\N
314	Achat legumes	0.00	18700.00	CANTINE-20230914	\N	\N	149	1	236	valide	2025-11-14 07:25:37	\N
315	Achat viande	21700.00	0.00	CANTINE-20230915	\N	\N	150	1	242	valide	2025-11-14 07:25:37	\N
316	Achat viande	0.00	21700.00	CANTINE-20230915	\N	\N	150	1	236	valide	2025-11-14 07:25:37	\N
317	Achat gouter	11000.00	0.00	CANTINE-20230918	\N	\N	151	1	243	valide	2025-11-14 07:25:37	\N
318	Achat gouter	0.00	11000.00	CANTINE-20230918	\N	\N	151	1	236	valide	2025-11-14 07:25:37	\N
319	Ecolage divers élèves	0.00	1630000.00	ECOL-20230920	\N	\N	152	1	193	valide	2025-11-14 07:25:37	\N
320	Ecolage divers élèves	1630000.00	0.00	ECOL-20230920	\N	\N	152	1	236	valide	2025-11-14 07:25:37	\N
321	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20230925	\N	\N	153	1	238	valide	2025-11-14 07:25:37	\N
322	Paiement salaire gardien	180000.00	0.00	SALAIRE-20230925	\N	\N	153	1	239	valide	2025-11-14 07:25:37	\N
323	Paiement femme de ménage	150000.00	0.00	SALAIRE-20230925	\N	\N	153	1	240	valide	2025-11-14 07:25:37	\N
324	Paiement salaires	0.00	580000.00	SALAIRE-20230925	\N	\N	153	1	236	valide	2025-11-14 07:25:37	\N
325	Jirama	39200.00	0.00	JIRAMA-20230926	\N	\N	154	1	99	valide	2025-11-14 07:25:37	\N
326	Jirama	0.00	39200.00	JIRAMA-20230926	\N	\N	154	1	236	valide	2025-11-14 07:25:37	\N
327	Achat fournitures scolaires	148000.00	0.00	FOURN-20230928	\N	\N	155	1	79	valide	2025-11-14 07:25:37	\N
328	Achat fournitures scolaires	0.00	148000.00	FOURN-20230928	\N	\N	155	1	40	valide	2025-11-14 07:25:37	\N
329	Règlement fournisseur	148000.00	0.00	REG-FOURN-20230930	\N	\N	156	1	40	valide	2025-11-14 07:25:37	\N
330	Règlement fournisseur	0.00	148000.00	REG-FOURN-20230930	\N	\N	156	1	236	valide	2025-11-14 07:25:37	\N
331	Achat legumes	18500.00	0.00	CANTINE-20231002	\N	\N	157	1	241	valide	2025-11-14 07:25:37	\N
332	Achat legumes	0.00	18500.00	CANTINE-20231002	\N	\N	157	1	236	valide	2025-11-14 07:25:37	\N
333	Achat viande	21500.00	0.00	CANTINE-20231003	\N	\N	158	1	242	valide	2025-11-14 07:25:37	\N
334	Achat viande	0.00	21500.00	CANTINE-20231003	\N	\N	158	1	236	valide	2025-11-14 07:25:37	\N
335	Achat gouter	11200.00	0.00	CANTINE-20231004	\N	\N	159	1	243	valide	2025-11-14 07:25:37	\N
336	Achat gouter	0.00	11200.00	CANTINE-20231004	\N	\N	159	1	236	valide	2025-11-14 07:25:37	\N
337	Achat legumes	18800.00	0.00	CANTINE-20231005	\N	\N	160	1	241	valide	2025-11-14 07:25:37	\N
338	Achat legumes	0.00	18800.00	CANTINE-20231005	\N	\N	160	1	236	valide	2025-11-14 07:25:37	\N
339	Achat viande	21800.00	0.00	CANTINE-20231006	\N	\N	161	1	242	valide	2025-11-14 07:25:37	\N
340	Achat viande	0.00	21800.00	CANTINE-20231006	\N	\N	161	1	236	valide	2025-11-14 07:25:37	\N
341	Achat gouter	11400.00	0.00	CANTINE-20231009	\N	\N	162	1	243	valide	2025-11-14 07:25:37	\N
342	Achat gouter	0.00	11400.00	CANTINE-20231009	\N	\N	162	1	236	valide	2025-11-14 07:25:37	\N
343	Achat legumes	19100.00	0.00	CANTINE-20231010	\N	\N	163	1	241	valide	2025-11-14 07:25:37	\N
344	Achat legumes	0.00	19100.00	CANTINE-20231010	\N	\N	163	1	236	valide	2025-11-14 07:25:37	\N
345	Achat viande	22100.00	0.00	CANTINE-20231011	\N	\N	164	1	242	valide	2025-11-14 07:25:37	\N
346	Achat viande	0.00	22100.00	CANTINE-20231011	\N	\N	164	1	236	valide	2025-11-14 07:25:37	\N
347	Achat gouter	11600.00	0.00	CANTINE-20231012	\N	\N	165	1	243	valide	2025-11-14 07:25:37	\N
348	Achat gouter	0.00	11600.00	CANTINE-20231012	\N	\N	165	1	236	valide	2025-11-14 07:25:37	\N
349	Achat legumes	19400.00	0.00	CANTINE-20231013	\N	\N	166	1	241	valide	2025-11-14 07:25:37	\N
350	Achat legumes	0.00	19400.00	CANTINE-20231013	\N	\N	166	1	236	valide	2025-11-14 07:25:37	\N
351	Achat viande	22400.00	0.00	CANTINE-20231016	\N	\N	167	1	242	valide	2025-11-14 07:25:37	\N
352	Achat viande	0.00	22400.00	CANTINE-20231016	\N	\N	167	1	236	valide	2025-11-14 07:25:37	\N
353	Achat gouter	11800.00	0.00	CANTINE-20231017	\N	\N	168	1	243	valide	2025-11-14 07:25:37	\N
354	Achat gouter	0.00	11800.00	CANTINE-20231017	\N	\N	168	1	236	valide	2025-11-14 07:25:37	\N
355	Ecolage divers élèves	0.00	1650000.00	ECOL-20231020	\N	\N	169	1	193	valide	2025-11-14 07:25:37	\N
356	Ecolage divers élèves	1650000.00	0.00	ECOL-20231020	\N	\N	169	1	236	valide	2025-11-14 07:25:37	\N
357	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20231024	\N	\N	170	1	238	valide	2025-11-14 07:25:37	\N
358	Paiement salaire gardien	180000.00	0.00	SALAIRE-20231024	\N	\N	170	1	239	valide	2025-11-14 07:25:37	\N
359	Paiement femme de ménage	150000.00	0.00	SALAIRE-20231024	\N	\N	170	1	240	valide	2025-11-14 07:25:37	\N
360	Paiement salaires	0.00	580000.00	SALAIRE-20231024	\N	\N	170	1	236	valide	2025-11-14 07:25:37	\N
361	Jirama	40500.00	0.00	JIRAMA-20231025	\N	\N	171	1	99	valide	2025-11-14 07:25:37	\N
362	Jirama	0.00	40500.00	JIRAMA-20231025	\N	\N	171	1	236	valide	2025-11-14 07:25:37	\N
363	Achat fournitures bureau	152000.00	0.00	FOURN-20231027	\N	\N	172	1	105	valide	2025-11-14 07:25:37	\N
364	Achat fournitures bureau	0.00	152000.00	FOURN-20231027	\N	\N	172	1	40	valide	2025-11-14 07:25:37	\N
365	Règlement fournisseur	152000.00	0.00	REG-FOURN-20231031	\N	\N	173	1	40	valide	2025-11-14 07:25:37	\N
366	Règlement fournisseur	0.00	152000.00	REG-FOURN-20231031	\N	\N	173	1	236	valide	2025-11-14 07:25:37	\N
367	Achat legumes	19200.00	0.00	CANTINE-20231101	\N	\N	174	1	241	valide	2025-11-14 07:25:37	\N
368	Achat legumes	0.00	19200.00	CANTINE-20231101	\N	\N	174	1	236	valide	2025-11-14 07:25:37	\N
369	Achat viande	22200.00	0.00	CANTINE-20231102	\N	\N	175	1	242	valide	2025-11-14 07:25:37	\N
370	Achat viande	0.00	22200.00	CANTINE-20231102	\N	\N	175	1	236	valide	2025-11-14 07:25:37	\N
371	Achat gouter	12000.00	0.00	CANTINE-20231103	\N	\N	176	1	243	valide	2025-11-14 07:25:37	\N
372	Achat gouter	0.00	12000.00	CANTINE-20231103	\N	\N	176	1	236	valide	2025-11-14 07:25:37	\N
373	Achat legumes	19500.00	0.00	CANTINE-20231106	\N	\N	177	1	241	valide	2025-11-14 07:25:37	\N
374	Achat legumes	0.00	19500.00	CANTINE-20231106	\N	\N	177	1	236	valide	2025-11-14 07:25:37	\N
375	Achat viande	22500.00	0.00	CANTINE-20231107	\N	\N	178	1	242	valide	2025-11-14 07:25:37	\N
376	Achat viande	0.00	22500.00	CANTINE-20231107	\N	\N	178	1	236	valide	2025-11-14 07:25:37	\N
377	Achat gouter	12200.00	0.00	CANTINE-20231108	\N	\N	179	1	243	valide	2025-11-14 07:25:37	\N
378	Achat gouter	0.00	12200.00	CANTINE-20231108	\N	\N	179	1	236	valide	2025-11-14 07:25:37	\N
379	Achat legumes	19800.00	0.00	CANTINE-20231109	\N	\N	180	1	241	valide	2025-11-14 07:25:37	\N
380	Achat legumes	0.00	19800.00	CANTINE-20231109	\N	\N	180	1	236	valide	2025-11-14 07:25:37	\N
381	Achat viande	22800.00	0.00	CANTINE-20231110	\N	\N	181	1	242	valide	2025-11-14 07:25:37	\N
382	Achat viande	0.00	22800.00	CANTINE-20231110	\N	\N	181	1	236	valide	2025-11-14 07:25:37	\N
383	Achat gouter	12400.00	0.00	CANTINE-20231113	\N	\N	182	1	243	valide	2025-11-14 07:25:37	\N
384	Achat gouter	0.00	12400.00	CANTINE-20231113	\N	\N	182	1	236	valide	2025-11-14 07:25:37	\N
385	Achat legumes	20100.00	0.00	CANTINE-20231114	\N	\N	183	1	241	valide	2025-11-14 07:25:37	\N
386	Achat legumes	0.00	20100.00	CANTINE-20231114	\N	\N	183	1	236	valide	2025-11-14 07:25:37	\N
387	Achat viande	23100.00	0.00	CANTINE-20231115	\N	\N	184	1	242	valide	2025-11-14 07:25:37	\N
388	Achat viande	0.00	23100.00	CANTINE-20231115	\N	\N	184	1	236	valide	2025-11-14 07:25:37	\N
389	Achat gouter	12600.00	0.00	CANTINE-20231116	\N	\N	185	1	243	valide	2025-11-14 07:25:37	\N
390	Achat gouter	0.00	12600.00	CANTINE-20231116	\N	\N	185	1	236	valide	2025-11-14 07:25:37	\N
391	Achat legumes	20400.00	0.00	CANTINE-20231117	\N	\N	186	1	241	valide	2025-11-14 07:25:37	\N
392	Achat legumes	0.00	20400.00	CANTINE-20231117	\N	\N	186	1	236	valide	2025-11-14 07:25:37	\N
393	Ecolage divers élèves	0.00	1670000.00	ECOL-20231120	\N	\N	187	1	193	valide	2025-11-14 07:25:37	\N
394	Ecolage divers élèves	1670000.00	0.00	ECOL-20231120	\N	\N	187	1	236	valide	2025-11-14 07:25:37	\N
395	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20231124	\N	\N	188	1	238	valide	2025-11-14 07:25:37	\N
396	Paiement salaire gardien	180000.00	0.00	SALAIRE-20231124	\N	\N	188	1	239	valide	2025-11-14 07:25:37	\N
397	Paiement femme de ménage	150000.00	0.00	SALAIRE-20231124	\N	\N	188	1	240	valide	2025-11-14 07:25:37	\N
398	Paiement salaires	0.00	580000.00	SALAIRE-20231124	\N	\N	188	1	236	valide	2025-11-14 07:25:37	\N
399	Jirama	41800.00	0.00	JIRAMA-20231125	\N	\N	189	1	99	valide	2025-11-14 07:25:37	\N
400	Jirama	0.00	41800.00	JIRAMA-20231125	\N	\N	189	1	236	valide	2025-11-14 07:25:37	\N
401	Achat matériel éducatif	155000.00	0.00	FOURN-20231128	\N	\N	190	1	97	valide	2025-11-14 07:25:37	\N
402	Achat matériel éducatif	0.00	155000.00	FOURN-20231128	\N	\N	190	1	40	valide	2025-11-14 07:25:37	\N
403	Règlement fournisseur	155000.00	0.00	REG-FOURN-20231130	\N	\N	191	1	40	valide	2025-11-14 07:25:37	\N
404	Règlement fournisseur	0.00	155000.00	REG-FOURN-20231130	\N	\N	191	1	236	valide	2025-11-14 07:25:37	\N
405	Achat legumes	20300.00	0.00	CANTINE-20231201	\N	\N	192	1	241	valide	2025-11-14 07:25:37	\N
406	Achat legumes	0.00	20300.00	CANTINE-20231201	\N	\N	192	1	236	valide	2025-11-14 07:25:37	\N
407	Achat viande	23300.00	0.00	CANTINE-20231204	\N	\N	193	1	242	valide	2025-11-14 07:25:37	\N
408	Achat viande	0.00	23300.00	CANTINE-20231204	\N	\N	193	1	236	valide	2025-11-14 07:25:37	\N
409	Achat gouter	12800.00	0.00	CANTINE-20231205	\N	\N	194	1	243	valide	2025-11-14 07:25:37	\N
410	Achat gouter	0.00	12800.00	CANTINE-20231205	\N	\N	194	1	236	valide	2025-11-14 07:25:37	\N
411	Achat legumes	20600.00	0.00	CANTINE-20231206	\N	\N	195	1	241	valide	2025-11-14 07:25:37	\N
412	Achat legumes	0.00	20600.00	CANTINE-20231206	\N	\N	195	1	236	valide	2025-11-14 07:25:37	\N
413	Achat viande	23600.00	0.00	CANTINE-20231207	\N	\N	196	1	242	valide	2025-11-14 07:25:37	\N
414	Achat viande	0.00	23600.00	CANTINE-20231207	\N	\N	196	1	236	valide	2025-11-14 07:25:37	\N
415	Achat gouter	13000.00	0.00	CANTINE-20231208	\N	\N	197	1	243	valide	2025-11-14 07:25:37	\N
416	Achat gouter	0.00	13000.00	CANTINE-20231208	\N	\N	197	1	236	valide	2025-11-14 07:25:37	\N
417	Achat legumes	20900.00	0.00	CANTINE-20231211	\N	\N	198	1	241	valide	2025-11-14 07:25:37	\N
418	Achat legumes	0.00	20900.00	CANTINE-20231211	\N	\N	198	1	236	valide	2025-11-14 07:25:37	\N
419	Achat viande	23900.00	0.00	CANTINE-20231212	\N	\N	199	1	242	valide	2025-11-14 07:25:37	\N
420	Achat viande	0.00	23900.00	CANTINE-20231212	\N	\N	199	1	236	valide	2025-11-14 07:25:37	\N
421	Achat gouter	13200.00	0.00	CANTINE-20231213	\N	\N	200	1	243	valide	2025-11-14 07:25:37	\N
422	Achat gouter	0.00	13200.00	CANTINE-20231213	\N	\N	200	1	236	valide	2025-11-14 07:25:37	\N
423	Achat legumes	21200.00	0.00	CANTINE-20231214	\N	\N	201	1	241	valide	2025-11-14 07:25:37	\N
424	Achat legumes	0.00	21200.00	CANTINE-20231214	\N	\N	201	1	236	valide	2025-11-14 07:25:37	\N
425	Achat viande	24200.00	0.00	CANTINE-20231215	\N	\N	202	1	242	valide	2025-11-14 07:25:37	\N
426	Achat viande	0.00	24200.00	CANTINE-20231215	\N	\N	202	1	236	valide	2025-11-14 07:25:37	\N
427	Achat gouter	13400.00	0.00	CANTINE-20231218	\N	\N	203	1	243	valide	2025-11-14 07:25:37	\N
428	Achat gouter	0.00	13400.00	CANTINE-20231218	\N	\N	203	1	236	valide	2025-11-14 07:25:37	\N
429	Ecolage divers élèves	0.00	1690000.00	ECOL-20231220	\N	\N	204	1	193	valide	2025-11-14 07:25:37	\N
430	Ecolage divers élèves	1690000.00	0.00	ECOL-20231220	\N	\N	204	1	236	valide	2025-11-14 07:25:37	\N
431	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20231223	\N	\N	205	1	238	valide	2025-11-14 07:25:37	\N
432	Paiement salaire gardien	180000.00	0.00	SALAIRE-20231223	\N	\N	205	1	239	valide	2025-11-14 07:25:37	\N
433	Paiement femme de ménage	150000.00	0.00	SALAIRE-20231223	\N	\N	205	1	240	valide	2025-11-14 07:25:37	\N
434	Paiement salaires	0.00	580000.00	SALAIRE-20231223	\N	\N	205	1	236	valide	2025-11-14 07:25:37	\N
435	Jirama	43200.00	0.00	JIRAMA-20231226	\N	\N	206	1	99	valide	2025-11-14 07:25:37	\N
436	Jirama	0.00	43200.00	JIRAMA-20231226	\N	\N	206	1	236	valide	2025-11-14 07:25:37	\N
437	Achat fournitures pédagogiques	158000.00	0.00	FOURN-20231228	\N	\N	207	1	106	valide	2025-11-14 07:25:37	\N
438	Achat fournitures pédagogiques	0.00	158000.00	FOURN-20231228	\N	\N	207	1	40	valide	2025-11-14 07:25:37	\N
439	Règlement fournisseur	158000.00	0.00	REG-FOURN-20231231	\N	\N	208	1	40	valide	2025-11-14 07:25:37	\N
440	Règlement fournisseur	0.00	158000.00	REG-FOURN-20231231	\N	\N	208	1	236	valide	2025-11-14 07:25:37	\N
441	Achat legumes	13500.00	0.00	CANTINE-20240103	\N	\N	209	1	241	valide	2025-11-14 07:25:37	\N
442	Achat legumes	0.00	13500.00	CANTINE-20240103	\N	\N	209	1	236	valide	2025-11-14 07:25:37	\N
443	Achat viande	16500.00	0.00	CANTINE-20240104	\N	\N	210	1	242	valide	2025-11-14 07:25:37	\N
444	Achat viande	0.00	16500.00	CANTINE-20240104	\N	\N	210	1	236	valide	2025-11-14 07:25:37	\N
445	Achat gouter	5800.00	0.00	CANTINE-20240105	\N	\N	211	1	243	valide	2025-11-14 07:25:37	\N
446	Achat gouter	0.00	5800.00	CANTINE-20240105	\N	\N	211	1	236	valide	2025-11-14 07:25:37	\N
447	Achat legumes	14000.00	0.00	CANTINE-20240108	\N	\N	212	1	241	valide	2025-11-14 07:25:37	\N
448	Achat legumes	0.00	14000.00	CANTINE-20240108	\N	\N	212	1	236	valide	2025-11-14 07:25:37	\N
449	Achat viande	17000.00	0.00	CANTINE-20240109	\N	\N	213	1	242	valide	2025-11-14 07:25:37	\N
450	Achat viande	0.00	17000.00	CANTINE-20240109	\N	\N	213	1	236	valide	2025-11-14 07:25:37	\N
451	Achat gouter	6000.00	0.00	CANTINE-20240110	\N	\N	214	1	243	valide	2025-11-14 07:25:37	\N
452	Achat gouter	0.00	6000.00	CANTINE-20240110	\N	\N	214	1	236	valide	2025-11-14 07:25:37	\N
453	Achat legumes	14500.00	0.00	CANTINE-20240111	\N	\N	215	1	241	valide	2025-11-14 07:25:37	\N
454	Achat legumes	0.00	14500.00	CANTINE-20240111	\N	\N	215	1	236	valide	2025-11-14 07:25:37	\N
455	Achat viande	17500.00	0.00	CANTINE-20240112	\N	\N	216	1	242	valide	2025-11-14 07:25:37	\N
456	Achat viande	0.00	17500.00	CANTINE-20240112	\N	\N	216	1	236	valide	2025-11-14 07:25:37	\N
457	Achat gouter	6200.00	0.00	CANTINE-20240115	\N	\N	217	1	243	valide	2025-11-14 07:25:37	\N
458	Achat gouter	0.00	6200.00	CANTINE-20240115	\N	\N	217	1	236	valide	2025-11-14 07:25:37	\N
459	Achat legumes	14800.00	0.00	CANTINE-20240116	\N	\N	218	1	241	valide	2025-11-14 07:25:37	\N
460	Achat legumes	0.00	14800.00	CANTINE-20240116	\N	\N	218	1	236	valide	2025-11-14 07:25:37	\N
461	Achat viande	17800.00	0.00	CANTINE-20240117	\N	\N	219	1	242	valide	2025-11-14 07:25:37	\N
462	Achat viande	0.00	17800.00	CANTINE-20240117	\N	\N	219	1	236	valide	2025-11-14 07:25:37	\N
463	Achat gouter	6400.00	0.00	CANTINE-20240118	\N	\N	220	1	243	valide	2025-11-14 07:25:37	\N
464	Achat gouter	0.00	6400.00	CANTINE-20240118	\N	\N	220	1	236	valide	2025-11-14 07:25:37	\N
465	Achat legumes	15100.00	0.00	CANTINE-20240119	\N	\N	221	1	241	valide	2025-11-14 07:25:37	\N
466	Achat legumes	0.00	15100.00	CANTINE-20240119	\N	\N	221	1	236	valide	2025-11-14 07:25:37	\N
467	Ecolage divers élèves	0.00	1520000.00	ECOL-20240122	\N	\N	222	1	193	valide	2025-11-14 07:25:37	\N
468	Ecolage divers élèves	1520000.00	0.00	ECOL-20240122	\N	\N	222	1	236	valide	2025-11-14 07:25:37	\N
469	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20240125	\N	\N	223	1	238	valide	2025-11-14 07:25:37	\N
470	Paiement salaire gardien	180000.00	0.00	SALAIRE-20240125	\N	\N	223	1	239	valide	2025-11-14 07:25:37	\N
471	Paiement femme de ménage	150000.00	0.00	SALAIRE-20240125	\N	\N	223	1	240	valide	2025-11-14 07:25:37	\N
472	Paiement salaires	0.00	580000.00	SALAIRE-20240125	\N	\N	223	1	236	valide	2025-11-14 07:25:37	\N
473	Jirama	31200.00	0.00	JIRAMA-20240127	\N	\N	224	1	99	valide	2025-11-14 07:25:37	\N
474	Jirama	0.00	31200.00	JIRAMA-20240127	\N	\N	224	1	236	valide	2025-11-14 07:25:37	\N
475	Achat fournitures scolaires	128000.00	0.00	FOURN-20240130	\N	\N	225	1	79	valide	2025-11-14 07:25:37	\N
476	Achat fournitures scolaires	0.00	128000.00	FOURN-20240130	\N	\N	225	1	40	valide	2025-11-14 07:25:37	\N
477	Règlement fournisseur	128000.00	0.00	REG-FOURN-20240131	\N	\N	226	1	40	valide	2025-11-14 07:25:37	\N
478	Règlement fournisseur	0.00	128000.00	REG-FOURN-20240131	\N	\N	226	1	236	valide	2025-11-14 07:25:37	\N
479	Achat legumes	14300.00	0.00	CANTINE-20240201	\N	\N	227	1	241	valide	2025-11-14 07:25:37	\N
480	Achat legumes	0.00	14300.00	CANTINE-20240201	\N	\N	227	1	236	valide	2025-11-14 07:25:37	\N
481	Achat viande	17300.00	0.00	CANTINE-20240202	\N	\N	228	1	242	valide	2025-11-14 07:25:37	\N
482	Achat viande	0.00	17300.00	CANTINE-20240202	\N	\N	228	1	236	valide	2025-11-14 07:25:37	\N
483	Achat gouter	6600.00	0.00	CANTINE-20240205	\N	\N	229	1	243	valide	2025-11-14 07:25:37	\N
484	Achat gouter	0.00	6600.00	CANTINE-20240205	\N	\N	229	1	236	valide	2025-11-14 07:25:37	\N
485	Achat legumes	14600.00	0.00	CANTINE-20240206	\N	\N	230	1	241	valide	2025-11-14 07:25:37	\N
486	Achat legumes	0.00	14600.00	CANTINE-20240206	\N	\N	230	1	236	valide	2025-11-14 07:25:37	\N
487	Achat viande	17600.00	0.00	CANTINE-20240207	\N	\N	231	1	242	valide	2025-11-14 07:25:37	\N
488	Achat viande	0.00	17600.00	CANTINE-20240207	\N	\N	231	1	236	valide	2025-11-14 07:25:37	\N
489	Achat gouter	6800.00	0.00	CANTINE-20240208	\N	\N	232	1	243	valide	2025-11-14 07:25:37	\N
490	Achat gouter	0.00	6800.00	CANTINE-20240208	\N	\N	232	1	236	valide	2025-11-14 07:25:37	\N
491	Achat legumes	14900.00	0.00	CANTINE-20240209	\N	\N	233	1	241	valide	2025-11-14 07:25:37	\N
492	Achat legumes	0.00	14900.00	CANTINE-20240209	\N	\N	233	1	236	valide	2025-11-14 07:25:37	\N
493	Achat viande	17900.00	0.00	CANTINE-20240212	\N	\N	234	1	242	valide	2025-11-14 07:25:37	\N
494	Achat viande	0.00	17900.00	CANTINE-20240212	\N	\N	234	1	236	valide	2025-11-14 07:25:37	\N
495	Achat gouter	7000.00	0.00	CANTINE-20240213	\N	\N	235	1	243	valide	2025-11-14 07:25:37	\N
496	Achat gouter	0.00	7000.00	CANTINE-20240213	\N	\N	235	1	236	valide	2025-11-14 07:25:37	\N
497	Achat legumes	15200.00	0.00	CANTINE-20240214	\N	\N	236	1	241	valide	2025-11-14 07:25:37	\N
498	Achat legumes	0.00	15200.00	CANTINE-20240214	\N	\N	236	1	236	valide	2025-11-14 07:25:37	\N
499	Echeancier pret bancaire	850000.00	0.00	PRET-20240215	\N	\N	237	1	244	valide	2025-11-14 07:25:37	\N
500	Echeancier pret bancaire	0.00	850000.00	PRET-20240215	\N	\N	237	1	236	valide	2025-11-14 07:25:37	\N
501	Achat viande	18200.00	0.00	CANTINE-20240215	\N	\N	238	1	242	valide	2025-11-14 07:25:37	\N
502	Achat viande	0.00	18200.00	CANTINE-20240215	\N	\N	238	1	236	valide	2025-11-14 07:25:37	\N
503	Achat gouter	7200.00	0.00	CANTINE-20240216	\N	\N	239	1	243	valide	2025-11-14 07:25:37	\N
504	Achat gouter	0.00	7200.00	CANTINE-20240216	\N	\N	239	1	236	valide	2025-11-14 07:25:37	\N
505	Achat legumes	15500.00	0.00	CANTINE-20240219	\N	\N	240	1	241	valide	2025-11-14 07:25:37	\N
506	Achat legumes	0.00	15500.00	CANTINE-20240219	\N	\N	240	1	236	valide	2025-11-14 07:25:37	\N
507	Ecolage divers élèves	0.00	1540000.00	ECOL-20240220	\N	\N	241	1	193	valide	2025-11-14 07:25:37	\N
508	Ecolage divers élèves	1540000.00	0.00	ECOL-20240220	\N	\N	241	1	236	valide	2025-11-14 07:25:37	\N
509	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20240225	\N	\N	242	1	238	valide	2025-11-14 07:25:37	\N
510	Paiement salaire gardien	180000.00	0.00	SALAIRE-20240225	\N	\N	242	1	239	valide	2025-11-14 07:25:37	\N
511	Paiement femme de ménage	150000.00	0.00	SALAIRE-20240225	\N	\N	242	1	240	valide	2025-11-14 07:25:37	\N
512	Paiement salaires	0.00	580000.00	SALAIRE-20240225	\N	\N	242	1	236	valide	2025-11-14 07:25:37	\N
513	Jirama	32800.00	0.00	JIRAMA-20240227	\N	\N	243	1	99	valide	2025-11-14 07:25:37	\N
514	Jirama	0.00	32800.00	JIRAMA-20240227	\N	\N	243	1	236	valide	2025-11-14 07:25:37	\N
515	Achat fournitures bureau	121000.00	0.00	FOURN-20240229	\N	\N	244	1	105	valide	2025-11-14 07:25:37	\N
516	Achat fournitures bureau	0.00	121000.00	FOURN-20240229	\N	\N	244	1	40	valide	2025-11-14 07:25:37	\N
517	Règlement fournisseur	121000.00	0.00	REG-FOURN-20240302	\N	\N	245	1	40	valide	2025-11-14 07:25:37	\N
518	Règlement fournisseur	0.00	121000.00	REG-FOURN-20240302	\N	\N	245	1	236	valide	2025-11-14 07:25:37	\N
519	Achat legumes	15400.00	0.00	CANTINE-20240304	\N	\N	246	1	241	valide	2025-11-14 07:25:37	\N
520	Achat legumes	0.00	15400.00	CANTINE-20240304	\N	\N	246	1	236	valide	2025-11-14 07:25:37	\N
521	Achat viande	18400.00	0.00	CANTINE-20240305	\N	\N	247	1	242	valide	2025-11-14 07:25:37	\N
522	Achat viande	0.00	18400.00	CANTINE-20240305	\N	\N	247	1	236	valide	2025-11-14 07:25:37	\N
523	Achat gouter	7400.00	0.00	CANTINE-20240306	\N	\N	248	1	243	valide	2025-11-14 07:25:37	\N
524	Achat gouter	0.00	7400.00	CANTINE-20240306	\N	\N	248	1	236	valide	2025-11-14 07:25:37	\N
525	Achat legumes	15700.00	0.00	CANTINE-20240307	\N	\N	249	1	241	valide	2025-11-14 07:25:37	\N
526	Achat legumes	0.00	15700.00	CANTINE-20240307	\N	\N	249	1	236	valide	2025-11-14 07:25:37	\N
527	Achat viande	18700.00	0.00	CANTINE-20240308	\N	\N	250	1	242	valide	2025-11-14 07:25:37	\N
528	Achat viande	0.00	18700.00	CANTINE-20240308	\N	\N	250	1	236	valide	2025-11-14 07:25:37	\N
529	Achat gouter	7600.00	0.00	CANTINE-20240311	\N	\N	251	1	243	valide	2025-11-14 07:25:37	\N
530	Achat gouter	0.00	7600.00	CANTINE-20240311	\N	\N	251	1	236	valide	2025-11-14 07:25:37	\N
531	Achat legumes	16000.00	0.00	CANTINE-20240312	\N	\N	252	1	241	valide	2025-11-14 07:25:37	\N
532	Achat legumes	0.00	16000.00	CANTINE-20240312	\N	\N	252	1	236	valide	2025-11-14 07:25:37	\N
533	Achat viande	19000.00	0.00	CANTINE-20240313	\N	\N	253	1	242	valide	2025-11-14 07:25:37	\N
534	Achat viande	0.00	19000.00	CANTINE-20240313	\N	\N	253	1	236	valide	2025-11-14 07:25:37	\N
535	Achat gouter	7800.00	0.00	CANTINE-20240314	\N	\N	254	1	243	valide	2025-11-14 07:25:37	\N
536	Achat gouter	0.00	7800.00	CANTINE-20240314	\N	\N	254	1	236	valide	2025-11-14 07:25:37	\N
537	Achat legumes	16300.00	0.00	CANTINE-20240315	\N	\N	255	1	241	valide	2025-11-14 07:25:37	\N
538	Achat legumes	0.00	16300.00	CANTINE-20240315	\N	\N	255	1	236	valide	2025-11-14 07:25:37	\N
539	Versement en banque BMOI	120000.00	0.00	VERS180324	\N	\N	256	1	53	valide	2025-11-14 07:25:37	\N
540	Versement en banque BMOI	0.00	120000.00	VERS180324	\N	\N	256	1	236	valide	2025-11-14 07:25:37	\N
541	Achat viande	19300.00	0.00	CANTINE-20240318	\N	\N	257	1	242	valide	2025-11-14 07:25:37	\N
542	Achat viande	0.00	19300.00	CANTINE-20240318	\N	\N	257	1	236	valide	2025-11-14 07:25:37	\N
543	Achat gouter	8000.00	0.00	CANTINE-20240319	\N	\N	258	1	243	valide	2025-11-14 07:25:37	\N
544	Achat gouter	0.00	8000.00	CANTINE-20240319	\N	\N	258	1	236	valide	2025-11-14 07:25:37	\N
545	Ecolage divers élèves	0.00	1560000.00	ECOL-20240320	\N	\N	259	1	193	valide	2025-11-14 07:25:37	\N
546	Ecolage divers élèves	1560000.00	0.00	ECOL-20240320	\N	\N	259	1	236	valide	2025-11-14 07:25:37	\N
547	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20240325	\N	\N	260	1	238	valide	2025-11-14 07:25:37	\N
548	Paiement salaire gardien	180000.00	0.00	SALAIRE-20240325	\N	\N	260	1	239	valide	2025-11-14 07:25:37	\N
549	Paiement femme de ménage	150000.00	0.00	SALAIRE-20240325	\N	\N	260	1	240	valide	2025-11-14 07:25:37	\N
550	Paiement salaires	0.00	580000.00	SALAIRE-20240325	\N	\N	260	1	236	valide	2025-11-14 07:25:37	\N
551	Jirama	34500.00	0.00	JIRAMA-20240327	\N	\N	261	1	99	valide	2025-11-14 07:25:37	\N
552	Jirama	0.00	34500.00	JIRAMA-20240327	\N	\N	261	1	236	valide	2025-11-14 07:25:37	\N
553	Achat matériel éducatif	134000.00	0.00	FOURN-20240329	\N	\N	262	1	97	valide	2025-11-14 07:25:37	\N
554	Achat matériel éducatif	0.00	134000.00	FOURN-20240329	\N	\N	262	1	40	valide	2025-11-14 07:25:37	\N
555	Règlement fournisseur	134000.00	0.00	REG-FOURN-20240331	\N	\N	263	1	40	valide	2025-11-14 07:25:37	\N
556	Règlement fournisseur	0.00	134000.00	REG-FOURN-20240331	\N	\N	263	1	236	valide	2025-11-14 07:25:37	\N
557	Achat legumes	16200.00	0.00	CANTINE-20240401	\N	\N	264	1	241	valide	2025-11-14 07:25:37	\N
558	Achat legumes	0.00	16200.00	CANTINE-20240401	\N	\N	264	1	236	valide	2025-11-14 07:25:37	\N
559	Achat viande	19200.00	0.00	CANTINE-20240402	\N	\N	265	1	242	valide	2025-11-14 07:25:37	\N
560	Achat viande	0.00	19200.00	CANTINE-20240402	\N	\N	265	1	236	valide	2025-11-14 07:25:37	\N
561	Achat gouter	8200.00	0.00	CANTINE-20240403	\N	\N	266	1	243	valide	2025-11-14 07:25:37	\N
562	Achat gouter	0.00	8200.00	CANTINE-20240403	\N	\N	266	1	236	valide	2025-11-14 07:25:37	\N
563	Achat legumes	16500.00	0.00	CANTINE-20240404	\N	\N	267	1	241	valide	2025-11-14 07:25:37	\N
564	Achat legumes	0.00	16500.00	CANTINE-20240404	\N	\N	267	1	236	valide	2025-11-14 07:25:37	\N
565	Achat viande	19500.00	0.00	CANTINE-20240405	\N	\N	268	1	242	valide	2025-11-14 07:25:37	\N
566	Achat viande	0.00	19500.00	CANTINE-20240405	\N	\N	268	1	236	valide	2025-11-14 07:25:37	\N
567	Achat gouter	8400.00	0.00	CANTINE-20240408	\N	\N	269	1	243	valide	2025-11-14 07:25:37	\N
568	Achat gouter	0.00	8400.00	CANTINE-20240408	\N	\N	269	1	236	valide	2025-11-14 07:25:37	\N
569	Achat legumes	16800.00	0.00	CANTINE-20240409	\N	\N	270	1	241	valide	2025-11-14 07:25:37	\N
570	Achat legumes	0.00	16800.00	CANTINE-20240409	\N	\N	270	1	236	valide	2025-11-14 07:25:37	\N
571	Appro caisse via BMOI	0.00	1800000.00	APPRO-20240410	\N	\N	271	1	53	valide	2025-11-14 07:25:37	\N
572	Appro caisse via BMOI	1800000.00	0.00	APPRO-20240410	\N	\N	271	1	236	valide	2025-11-14 07:25:37	\N
573	Achat viande	19800.00	0.00	CANTINE-20240410	\N	\N	272	1	242	valide	2025-11-14 07:25:37	\N
574	Achat viande	0.00	19800.00	CANTINE-20240410	\N	\N	272	1	236	valide	2025-11-14 07:25:37	\N
575	Achat gouter	8600.00	0.00	CANTINE-20240411	\N	\N	273	1	243	valide	2025-11-14 07:25:37	\N
576	Achat gouter	0.00	8600.00	CANTINE-20240411	\N	\N	273	1	236	valide	2025-11-14 07:25:37	\N
577	Achat legumes	17100.00	0.00	CANTINE-20240412	\N	\N	274	1	241	valide	2025-11-14 07:25:37	\N
578	Achat legumes	0.00	17100.00	CANTINE-20240412	\N	\N	274	1	236	valide	2025-11-14 07:25:37	\N
579	Achat viande	20100.00	0.00	CANTINE-20240415	\N	\N	275	1	242	valide	2025-11-14 07:25:37	\N
580	Achat viande	0.00	20100.00	CANTINE-20240415	\N	\N	275	1	236	valide	2025-11-14 07:25:37	\N
581	Achat gouter	8800.00	0.00	CANTINE-20240416	\N	\N	276	1	243	valide	2025-11-14 07:25:37	\N
582	Achat gouter	0.00	8800.00	CANTINE-20240416	\N	\N	276	1	236	valide	2025-11-14 07:25:37	\N
583	Achat legumes	17400.00	0.00	CANTINE-20240417	\N	\N	277	1	241	valide	2025-11-14 07:25:37	\N
584	Achat legumes	0.00	17400.00	CANTINE-20240417	\N	\N	277	1	236	valide	2025-11-14 07:25:37	\N
585	Achat viande	20400.00	0.00	CANTINE-20240418	\N	\N	278	1	242	valide	2025-11-14 07:25:37	\N
586	Achat viande	0.00	20400.00	CANTINE-20240418	\N	\N	278	1	236	valide	2025-11-14 07:25:37	\N
587	Achat gouter	9000.00	0.00	CANTINE-20240419	\N	\N	279	1	243	valide	2025-11-14 07:25:37	\N
588	Achat gouter	0.00	9000.00	CANTINE-20240419	\N	\N	279	1	236	valide	2025-11-14 07:25:37	\N
589	Ecolage divers élèves	0.00	1580000.00	ECOL-20240422	\N	\N	280	1	193	valide	2025-11-14 07:25:37	\N
590	Ecolage divers élèves	1580000.00	0.00	ECOL-20240422	\N	\N	280	1	236	valide	2025-11-14 07:25:37	\N
591	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20240425	\N	\N	281	1	238	valide	2025-11-14 07:25:37	\N
592	Paiement salaire gardien	180000.00	0.00	SALAIRE-20240425	\N	\N	281	1	239	valide	2025-11-14 07:25:37	\N
593	Paiement femme de ménage	150000.00	0.00	SALAIRE-20240425	\N	\N	281	1	240	valide	2025-11-14 07:25:37	\N
594	Paiement salaires	0.00	580000.00	SALAIRE-20240425	\N	\N	281	1	236	valide	2025-11-14 07:25:37	\N
595	Jirama	36200.00	0.00	JIRAMA-20240427	\N	\N	282	1	99	valide	2025-11-14 07:25:37	\N
596	Jirama	0.00	36200.00	JIRAMA-20240427	\N	\N	282	1	236	valide	2025-11-14 07:25:37	\N
597	Achat fournitures pédagogiques	130000.00	0.00	FOURN-20240429	\N	\N	283	1	106	valide	2025-11-14 07:25:37	\N
598	Achat fournitures pédagogiques	0.00	130000.00	FOURN-20240429	\N	\N	283	1	40	valide	2025-11-14 07:25:37	\N
599	Règlement fournisseur	130000.00	0.00	REG-FOURN-20240430	\N	\N	284	1	40	valide	2025-11-14 07:25:37	\N
600	Règlement fournisseur	0.00	130000.00	REG-FOURN-20240430	\N	\N	284	1	236	valide	2025-11-14 07:25:37	\N
601	Achat legumes	17300.00	0.00	CANTINE-20240502	\N	\N	285	1	241	valide	2025-11-14 07:25:37	\N
602	Achat legumes	0.00	17300.00	CANTINE-20240502	\N	\N	285	1	236	valide	2025-11-14 07:25:37	\N
603	Achat viande	20300.00	0.00	CANTINE-20240503	\N	\N	286	1	242	valide	2025-11-14 07:25:37	\N
604	Achat viande	0.00	20300.00	CANTINE-20240503	\N	\N	286	1	236	valide	2025-11-14 07:25:37	\N
605	Achat gouter	9200.00	0.00	CANTINE-20240506	\N	\N	287	1	243	valide	2025-11-14 07:25:37	\N
606	Achat gouter	0.00	9200.00	CANTINE-20240506	\N	\N	287	1	236	valide	2025-11-14 07:25:37	\N
607	Achat legumes	17600.00	0.00	CANTINE-20240507	\N	\N	288	1	241	valide	2025-11-14 07:25:37	\N
608	Achat legumes	0.00	17600.00	CANTINE-20240507	\N	\N	288	1	236	valide	2025-11-14 07:25:37	\N
609	Achat viande	20600.00	0.00	CANTINE-20240508	\N	\N	289	1	242	valide	2025-11-14 07:25:37	\N
610	Achat viande	0.00	20600.00	CANTINE-20240508	\N	\N	289	1	236	valide	2025-11-14 07:25:37	\N
611	Achat gouter	9400.00	0.00	CANTINE-20240509	\N	\N	290	1	243	valide	2025-11-14 07:25:37	\N
612	Achat gouter	0.00	9400.00	CANTINE-20240509	\N	\N	290	1	236	valide	2025-11-14 07:25:37	\N
613	Achat legumes	17900.00	0.00	CANTINE-20240510	\N	\N	291	1	241	valide	2025-11-14 07:25:37	\N
614	Achat legumes	0.00	17900.00	CANTINE-20240510	\N	\N	291	1	236	valide	2025-11-14 07:25:37	\N
615	Achat viande	20900.00	0.00	CANTINE-20240513	\N	\N	292	1	242	valide	2025-11-14 07:25:37	\N
616	Achat viande	0.00	20900.00	CANTINE-20240513	\N	\N	292	1	236	valide	2025-11-14 07:25:37	\N
617	Achat gouter	9600.00	0.00	CANTINE-20240514	\N	\N	293	1	243	valide	2025-11-14 07:25:37	\N
618	Achat gouter	0.00	9600.00	CANTINE-20240514	\N	\N	293	1	236	valide	2025-11-14 07:25:37	\N
619	Achat legumes	18200.00	0.00	CANTINE-20240515	\N	\N	294	1	241	valide	2025-11-14 07:25:37	\N
620	Achat legumes	0.00	18200.00	CANTINE-20240515	\N	\N	294	1	236	valide	2025-11-14 07:25:37	\N
621	Achat viande	21200.00	0.00	CANTINE-20240516	\N	\N	295	1	242	valide	2025-11-14 07:25:37	\N
622	Achat viande	0.00	21200.00	CANTINE-20240516	\N	\N	295	1	236	valide	2025-11-14 07:25:37	\N
623	Achat gouter	9800.00	0.00	CANTINE-20240517	\N	\N	296	1	243	valide	2025-11-14 07:25:37	\N
624	Achat gouter	0.00	9800.00	CANTINE-20240517	\N	\N	296	1	236	valide	2025-11-14 07:25:37	\N
625	Ecolage divers élèves	0.00	1600000.00	ECOL-20240520	\N	\N	297	1	193	valide	2025-11-14 07:25:37	\N
626	Ecolage divers élèves	1600000.00	0.00	ECOL-20240520	\N	\N	297	1	236	valide	2025-11-14 07:25:37	\N
627	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20240524	\N	\N	298	1	238	valide	2025-11-14 07:25:37	\N
628	Paiement salaire gardien	180000.00	0.00	SALAIRE-20240524	\N	\N	298	1	239	valide	2025-11-14 07:25:37	\N
629	Paiement femme de ménage	150000.00	0.00	SALAIRE-20240524	\N	\N	298	1	240	valide	2025-11-14 07:25:37	\N
630	Paiement salaires	0.00	580000.00	SALAIRE-20240524	\N	\N	298	1	236	valide	2025-11-14 07:25:37	\N
631	Echeancier pret bancaire	950000.00	0.00	PRET-20240525	\N	\N	299	1	244	valide	2025-11-14 07:25:37	\N
632	Echeancier pret bancaire	0.00	950000.00	PRET-20240525	\N	\N	299	1	236	valide	2025-11-14 07:25:37	\N
633	Jirama	37500.00	0.00	JIRAMA-20240526	\N	\N	300	1	99	valide	2025-11-14 07:25:37	\N
634	Jirama	0.00	37500.00	JIRAMA-20240526	\N	\N	300	1	236	valide	2025-11-14 07:25:37	\N
635	Achat fournitures scolaires	138000.00	0.00	FOURN-20240529	\N	\N	301	1	79	valide	2025-11-14 07:25:37	\N
636	Achat fournitures scolaires	0.00	138000.00	FOURN-20240529	\N	\N	301	1	40	valide	2025-11-14 07:25:37	\N
637	Règlement fournisseur	138000.00	0.00	REG-FOURN-20240531	\N	\N	302	1	40	valide	2025-11-14 07:25:37	\N
638	Règlement fournisseur	0.00	138000.00	REG-FOURN-20240531	\N	\N	302	1	236	valide	2025-11-14 07:25:37	\N
639	Achat legumes	18100.00	0.00	CANTINE-20240603	\N	\N	303	1	241	valide	2025-11-14 07:25:37	\N
640	Achat legumes	0.00	18100.00	CANTINE-20240603	\N	\N	303	1	236	valide	2025-11-14 07:25:37	\N
641	Achat viande	21100.00	0.00	CANTINE-20240604	\N	\N	304	1	242	valide	2025-11-14 07:25:37	\N
642	Achat viande	0.00	21100.00	CANTINE-20240604	\N	\N	304	1	236	valide	2025-11-14 07:25:37	\N
643	Achat gouter	10000.00	0.00	CANTINE-20240605	\N	\N	305	1	243	valide	2025-11-14 07:25:37	\N
644	Achat gouter	0.00	10000.00	CANTINE-20240605	\N	\N	305	1	236	valide	2025-11-14 07:25:37	\N
645	Achat legumes	18400.00	0.00	CANTINE-20240606	\N	\N	306	1	241	valide	2025-11-14 07:25:37	\N
646	Achat legumes	0.00	18400.00	CANTINE-20240606	\N	\N	306	1	236	valide	2025-11-14 07:25:37	\N
647	Achat viande	21400.00	0.00	CANTINE-20240607	\N	\N	307	1	242	valide	2025-11-14 07:25:37	\N
648	Achat viande	0.00	21400.00	CANTINE-20240607	\N	\N	307	1	236	valide	2025-11-14 07:25:37	\N
649	Achat gouter	10200.00	0.00	CANTINE-20240610	\N	\N	308	1	243	valide	2025-11-14 07:25:37	\N
650	Achat gouter	0.00	10200.00	CANTINE-20240610	\N	\N	308	1	236	valide	2025-11-14 07:25:37	\N
651	Achat legumes	18700.00	0.00	CANTINE-20240611	\N	\N	309	1	241	valide	2025-11-14 07:25:37	\N
652	Achat legumes	0.00	18700.00	CANTINE-20240611	\N	\N	309	1	236	valide	2025-11-14 07:25:37	\N
653	Achat viande	21700.00	0.00	CANTINE-20240612	\N	\N	310	1	242	valide	2025-11-14 07:25:37	\N
654	Achat viande	0.00	21700.00	CANTINE-20240612	\N	\N	310	1	236	valide	2025-11-14 07:25:37	\N
655	Achat gouter	10400.00	0.00	CANTINE-20240613	\N	\N	311	1	243	valide	2025-11-14 07:25:37	\N
656	Achat gouter	0.00	10400.00	CANTINE-20240613	\N	\N	311	1	236	valide	2025-11-14 07:25:37	\N
657	Achat legumes	19000.00	0.00	CANTINE-20240614	\N	\N	312	1	241	valide	2025-11-14 07:25:37	\N
658	Achat legumes	0.00	19000.00	CANTINE-20240614	\N	\N	312	1	236	valide	2025-11-14 07:25:37	\N
659	Achat viande	22000.00	0.00	CANTINE-20240617	\N	\N	313	1	242	valide	2025-11-14 07:25:37	\N
660	Achat viande	0.00	22000.00	CANTINE-20240617	\N	\N	313	1	236	valide	2025-11-14 07:25:37	\N
661	Achat gouter	10600.00	0.00	CANTINE-20240618	\N	\N	314	1	243	valide	2025-11-14 07:25:37	\N
662	Achat gouter	0.00	10600.00	CANTINE-20240618	\N	\N	314	1	236	valide	2025-11-14 07:25:37	\N
663	Ecolage divers élèves	0.00	1620000.00	ECOL-20240620	\N	\N	315	1	193	valide	2025-11-14 07:25:37	\N
664	Ecolage divers élèves	1620000.00	0.00	ECOL-20240620	\N	\N	315	1	236	valide	2025-11-14 07:25:37	\N
665	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20240625	\N	\N	316	1	238	valide	2025-11-14 07:25:37	\N
666	Paiement salaire gardien	180000.00	0.00	SALAIRE-20240625	\N	\N	316	1	239	valide	2025-11-14 07:25:37	\N
667	Paiement femme de ménage	150000.00	0.00	SALAIRE-20240625	\N	\N	316	1	240	valide	2025-11-14 07:25:37	\N
668	Paiement salaires	0.00	580000.00	SALAIRE-20240625	\N	\N	316	1	236	valide	2025-11-14 07:25:37	\N
669	Jirama	38800.00	0.00	JIRAMA-20240627	\N	\N	317	1	99	valide	2025-11-14 07:25:37	\N
670	Jirama	0.00	38800.00	JIRAMA-20240627	\N	\N	317	1	236	valide	2025-11-14 07:25:37	\N
671	Achat fournitures bureau	131000.00	0.00	FOURN-20240628	\N	\N	318	1	105	valide	2025-11-14 07:25:37	\N
672	Achat fournitures bureau	0.00	131000.00	FOURN-20240628	\N	\N	318	1	40	valide	2025-11-14 07:25:37	\N
673	Règlement fournisseur	131000.00	0.00	REG-FOURN-20240630	\N	\N	319	1	40	valide	2025-11-14 07:25:37	\N
674	Règlement fournisseur	0.00	131000.00	REG-FOURN-20240630	\N	\N	319	1	236	valide	2025-11-14 07:25:37	\N
675	Achat legumes	18900.00	0.00	CANTINE-20240701	\N	\N	320	1	241	valide	2025-11-14 07:25:37	\N
676	Achat legumes	0.00	18900.00	CANTINE-20240701	\N	\N	320	1	236	valide	2025-11-14 07:25:37	\N
677	Achat viande	21900.00	0.00	CANTINE-20240702	\N	\N	321	1	242	valide	2025-11-14 07:25:37	\N
678	Achat viande	0.00	21900.00	CANTINE-20240702	\N	\N	321	1	236	valide	2025-11-14 07:25:37	\N
679	Achat gouter	10800.00	0.00	CANTINE-20240703	\N	\N	322	1	243	valide	2025-11-14 07:25:37	\N
680	Achat gouter	0.00	10800.00	CANTINE-20240703	\N	\N	322	1	236	valide	2025-11-14 07:25:37	\N
681	Achat legumes	19200.00	0.00	CANTINE-20240704	\N	\N	323	1	241	valide	2025-11-14 07:25:37	\N
682	Achat legumes	0.00	19200.00	CANTINE-20240704	\N	\N	323	1	236	valide	2025-11-14 07:25:37	\N
683	Achat viande	22200.00	0.00	CANTINE-20240705	\N	\N	324	1	242	valide	2025-11-14 07:25:37	\N
684	Achat viande	0.00	22200.00	CANTINE-20240705	\N	\N	324	1	236	valide	2025-11-14 07:25:37	\N
685	Achat gouter	11000.00	0.00	CANTINE-20240708	\N	\N	325	1	243	valide	2025-11-14 07:25:37	\N
686	Achat gouter	0.00	11000.00	CANTINE-20240708	\N	\N	325	1	236	valide	2025-11-14 07:25:37	\N
687	Achat legumes	19500.00	0.00	CANTINE-20240709	\N	\N	326	1	241	valide	2025-11-14 07:25:37	\N
688	Achat legumes	0.00	19500.00	CANTINE-20240709	\N	\N	326	1	236	valide	2025-11-14 07:25:37	\N
689	Achat viande	22500.00	0.00	CANTINE-20240710	\N	\N	327	1	242	valide	2025-11-14 07:25:37	\N
690	Achat viande	0.00	22500.00	CANTINE-20240710	\N	\N	327	1	236	valide	2025-11-14 07:25:37	\N
691	Achat gouter	11200.00	0.00	CANTINE-20240711	\N	\N	328	1	243	valide	2025-11-14 07:25:37	\N
692	Achat gouter	0.00	11200.00	CANTINE-20240711	\N	\N	328	1	236	valide	2025-11-14 07:25:37	\N
693	Achat legumes	19800.00	0.00	CANTINE-20240712	\N	\N	329	1	241	valide	2025-11-14 07:25:37	\N
694	Achat legumes	0.00	19800.00	CANTINE-20240712	\N	\N	329	1	236	valide	2025-11-14 07:25:37	\N
695	Versement en banque BMOI	150000.00	0.00	VERS150724	\N	\N	330	1	53	valide	2025-11-14 07:25:37	\N
696	Versement en banque BMOI	0.00	150000.00	VERS150724	\N	\N	330	1	236	valide	2025-11-14 07:25:37	\N
697	Achat viande	22800.00	0.00	CANTINE-20240715	\N	\N	331	1	242	valide	2025-11-14 07:25:37	\N
698	Achat viande	0.00	22800.00	CANTINE-20240715	\N	\N	331	1	236	valide	2025-11-14 07:25:37	\N
699	Achat gouter	11400.00	0.00	CANTINE-20240716	\N	\N	332	1	243	valide	2025-11-14 07:25:37	\N
700	Achat gouter	0.00	11400.00	CANTINE-20240716	\N	\N	332	1	236	valide	2025-11-14 07:25:37	\N
701	Achat legumes	20100.00	0.00	CANTINE-20240717	\N	\N	333	1	241	valide	2025-11-14 07:25:37	\N
702	Achat legumes	0.00	20100.00	CANTINE-20240717	\N	\N	333	1	236	valide	2025-11-14 07:25:37	\N
703	Achat viande	23100.00	0.00	CANTINE-20240718	\N	\N	334	1	242	valide	2025-11-14 07:25:37	\N
704	Achat viande	0.00	23100.00	CANTINE-20240718	\N	\N	334	1	236	valide	2025-11-14 07:25:37	\N
705	Achat gouter	11600.00	0.00	CANTINE-20240719	\N	\N	335	1	243	valide	2025-11-14 07:25:37	\N
706	Achat gouter	0.00	11600.00	CANTINE-20240719	\N	\N	335	1	236	valide	2025-11-14 07:25:37	\N
707	Ecolage divers élèves	0.00	1640000.00	ECOL-20240722	\N	\N	336	1	193	valide	2025-11-14 07:25:37	\N
708	Ecolage divers élèves	1640000.00	0.00	ECOL-20240722	\N	\N	336	1	236	valide	2025-11-14 07:25:37	\N
709	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20240725	\N	\N	337	1	238	valide	2025-11-14 07:25:37	\N
710	Paiement salaire gardien	180000.00	0.00	SALAIRE-20240725	\N	\N	337	1	239	valide	2025-11-14 07:25:37	\N
711	Paiement femme de ménage	150000.00	0.00	SALAIRE-20240725	\N	\N	337	1	240	valide	2025-11-14 07:25:37	\N
712	Paiement salaires	0.00	580000.00	SALAIRE-20240725	\N	\N	337	1	236	valide	2025-11-14 07:25:37	\N
713	Jirama	40200.00	0.00	JIRAMA-20240727	\N	\N	338	1	99	valide	2025-11-14 07:25:37	\N
714	Jirama	0.00	40200.00	JIRAMA-20240727	\N	\N	338	1	236	valide	2025-11-14 07:25:37	\N
715	Achat matériel éducatif	137000.00	0.00	FOURN-20240729	\N	\N	339	1	97	valide	2025-11-14 07:25:37	\N
716	Achat matériel éducatif	0.00	137000.00	FOURN-20240729	\N	\N	339	1	40	valide	2025-11-14 07:25:37	\N
717	Règlement fournisseur	137000.00	0.00	REG-FOURN-20240731	\N	\N	340	1	40	valide	2025-11-14 07:25:37	\N
718	Règlement fournisseur	0.00	137000.00	REG-FOURN-20240731	\N	\N	340	1	236	valide	2025-11-14 07:25:37	\N
719	Achat legumes	20000.00	0.00	CANTINE-20240801	\N	\N	341	1	241	valide	2025-11-14 07:25:37	\N
720	Achat legumes	0.00	20000.00	CANTINE-20240801	\N	\N	341	1	236	valide	2025-11-14 07:25:37	\N
721	Achat viande	23000.00	0.00	CANTINE-20240802	\N	\N	342	1	242	valide	2025-11-14 07:25:37	\N
722	Achat viande	0.00	23000.00	CANTINE-20240802	\N	\N	342	1	236	valide	2025-11-14 07:25:37	\N
723	Achat gouter	11800.00	0.00	CANTINE-20240805	\N	\N	343	1	243	valide	2025-11-14 07:25:37	\N
724	Achat gouter	0.00	11800.00	CANTINE-20240805	\N	\N	343	1	236	valide	2025-11-14 07:25:37	\N
725	Achat legumes	20300.00	0.00	CANTINE-20240806	\N	\N	344	1	241	valide	2025-11-14 07:25:37	\N
726	Achat legumes	0.00	20300.00	CANTINE-20240806	\N	\N	344	1	236	valide	2025-11-14 07:25:37	\N
727	Achat viande	23300.00	0.00	CANTINE-20240807	\N	\N	345	1	242	valide	2025-11-14 07:25:37	\N
728	Achat viande	0.00	23300.00	CANTINE-20240807	\N	\N	345	1	236	valide	2025-11-14 07:25:37	\N
729	Achat gouter	12000.00	0.00	CANTINE-20240808	\N	\N	346	1	243	valide	2025-11-14 07:25:37	\N
730	Achat gouter	0.00	12000.00	CANTINE-20240808	\N	\N	346	1	236	valide	2025-11-14 07:25:37	\N
731	Achat legumes	20600.00	0.00	CANTINE-20240809	\N	\N	347	1	241	valide	2025-11-14 07:25:37	\N
732	Achat legumes	0.00	20600.00	CANTINE-20240809	\N	\N	347	1	236	valide	2025-11-14 07:25:37	\N
733	Achat viande	23600.00	0.00	CANTINE-20240812	\N	\N	348	1	242	valide	2025-11-14 07:25:37	\N
734	Achat viande	0.00	23600.00	CANTINE-20240812	\N	\N	348	1	236	valide	2025-11-14 07:25:37	\N
735	Achat gouter	12200.00	0.00	CANTINE-20240813	\N	\N	349	1	243	valide	2025-11-14 07:25:37	\N
736	Achat gouter	0.00	12200.00	CANTINE-20240813	\N	\N	349	1	236	valide	2025-11-14 07:25:37	\N
737	Achat legumes	20900.00	0.00	CANTINE-20240814	\N	\N	350	1	241	valide	2025-11-14 07:25:37	\N
738	Achat legumes	0.00	20900.00	CANTINE-20240814	\N	\N	350	1	236	valide	2025-11-14 07:25:37	\N
739	Achat viande	23900.00	0.00	CANTINE-20240815	\N	\N	351	1	242	valide	2025-11-14 07:25:37	\N
740	Achat viande	0.00	23900.00	CANTINE-20240815	\N	\N	351	1	236	valide	2025-11-14 07:25:37	\N
741	Achat gouter	12400.00	0.00	CANTINE-20240816	\N	\N	352	1	243	valide	2025-11-14 07:25:37	\N
742	Achat gouter	0.00	12400.00	CANTINE-20240816	\N	\N	352	1	236	valide	2025-11-14 07:25:37	\N
743	Achat legumes	21200.00	0.00	CANTINE-20240819	\N	\N	353	1	241	valide	2025-11-14 07:25:37	\N
744	Achat legumes	0.00	21200.00	CANTINE-20240819	\N	\N	353	1	236	valide	2025-11-14 07:25:37	\N
745	Ecolage divers élèves	0.00	1660000.00	ECOL-20240820	\N	\N	354	1	193	valide	2025-11-14 07:25:37	\N
746	Ecolage divers élèves	1660000.00	0.00	ECOL-20240820	\N	\N	354	1	236	valide	2025-11-14 07:25:37	\N
747	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20240825	\N	\N	355	1	238	valide	2025-11-14 07:25:37	\N
748	Paiement salaire gardien	180000.00	0.00	SALAIRE-20240825	\N	\N	355	1	239	valide	2025-11-14 07:25:37	\N
749	Paiement femme de ménage	150000.00	0.00	SALAIRE-20240825	\N	\N	355	1	240	valide	2025-11-14 07:25:37	\N
750	Paiement salaires	0.00	580000.00	SALAIRE-20240825	\N	\N	355	1	236	valide	2025-11-14 07:25:37	\N
751	Jirama	41500.00	0.00	JIRAMA-20240827	\N	\N	356	1	99	valide	2025-11-14 07:25:37	\N
752	Jirama	0.00	41500.00	JIRAMA-20240827	\N	\N	356	1	236	valide	2025-11-14 07:25:37	\N
753	Achat fournitures pédagogiques	142000.00	0.00	FOURN-20240829	\N	\N	357	1	106	valide	2025-11-14 07:25:37	\N
754	Achat fournitures pédagogiques	0.00	142000.00	FOURN-20240829	\N	\N	357	1	40	valide	2025-11-14 07:25:37	\N
755	Règlement fournisseur	142000.00	0.00	REG-FOURN-20240831	\N	\N	358	1	40	valide	2025-11-14 07:25:37	\N
756	Règlement fournisseur	0.00	142000.00	REG-FOURN-20240831	\N	\N	358	1	236	valide	2025-11-14 07:25:37	\N
757	Achat legumes	21100.00	0.00	CANTINE-20240902	\N	\N	359	1	241	valide	2025-11-14 07:25:37	\N
758	Achat legumes	0.00	21100.00	CANTINE-20240902	\N	\N	359	1	236	valide	2025-11-14 07:25:37	\N
759	Achat viande	24100.00	0.00	CANTINE-20240903	\N	\N	360	1	242	valide	2025-11-14 07:25:37	\N
760	Achat viande	0.00	24100.00	CANTINE-20240903	\N	\N	360	1	236	valide	2025-11-14 07:25:37	\N
761	Achat gouter	12600.00	0.00	CANTINE-20240904	\N	\N	361	1	243	valide	2025-11-14 07:25:37	\N
762	Achat gouter	0.00	12600.00	CANTINE-20240904	\N	\N	361	1	236	valide	2025-11-14 07:25:37	\N
763	Achat legumes	21400.00	0.00	CANTINE-20240905	\N	\N	362	1	241	valide	2025-11-14 07:25:37	\N
764	Achat legumes	0.00	21400.00	CANTINE-20240905	\N	\N	362	1	236	valide	2025-11-14 07:25:37	\N
765	Achat viande	24400.00	0.00	CANTINE-20240906	\N	\N	363	1	242	valide	2025-11-14 07:25:37	\N
766	Achat viande	0.00	24400.00	CANTINE-20240906	\N	\N	363	1	236	valide	2025-11-14 07:25:37	\N
767	Achat gouter	12800.00	0.00	CANTINE-20240909	\N	\N	364	1	243	valide	2025-11-14 07:25:37	\N
768	Achat gouter	0.00	12800.00	CANTINE-20240909	\N	\N	364	1	236	valide	2025-11-14 07:25:37	\N
769	Appro caisse via BMOI	0.00	2200000.00	APPRO-20240910	\N	\N	365	1	53	valide	2025-11-14 07:25:37	\N
770	Appro caisse via BMOI	2200000.00	0.00	APPRO-20240910	\N	\N	365	1	236	valide	2025-11-14 07:25:37	\N
771	Achat legumes	21700.00	0.00	CANTINE-20240910	\N	\N	366	1	241	valide	2025-11-14 07:25:37	\N
772	Achat legumes	0.00	21700.00	CANTINE-20240910	\N	\N	366	1	236	valide	2025-11-14 07:25:37	\N
773	Achat viande	24700.00	0.00	CANTINE-20240911	\N	\N	367	1	242	valide	2025-11-14 07:25:37	\N
774	Achat viande	0.00	24700.00	CANTINE-20240911	\N	\N	367	1	236	valide	2025-11-14 07:25:37	\N
775	Achat gouter	13000.00	0.00	CANTINE-20240912	\N	\N	368	1	243	valide	2025-11-14 07:25:37	\N
776	Achat gouter	0.00	13000.00	CANTINE-20240912	\N	\N	368	1	236	valide	2025-11-14 07:25:37	\N
777	Achat legumes	22000.00	0.00	CANTINE-20240913	\N	\N	369	1	241	valide	2025-11-14 07:25:37	\N
778	Achat legumes	0.00	22000.00	CANTINE-20240913	\N	\N	369	1	236	valide	2025-11-14 07:25:37	\N
779	Achat viande	25000.00	0.00	CANTINE-20240916	\N	\N	370	1	242	valide	2025-11-14 07:25:37	\N
780	Achat viande	0.00	25000.00	CANTINE-20240916	\N	\N	370	1	236	valide	2025-11-14 07:25:37	\N
781	Achat gouter	13200.00	0.00	CANTINE-20240917	\N	\N	371	1	243	valide	2025-11-14 07:25:37	\N
782	Achat gouter	0.00	13200.00	CANTINE-20240917	\N	\N	371	1	236	valide	2025-11-14 07:25:37	\N
783	Achat legumes	22300.00	0.00	CANTINE-20240918	\N	\N	372	1	241	valide	2025-11-14 07:25:37	\N
784	Achat legumes	0.00	22300.00	CANTINE-20240918	\N	\N	372	1	236	valide	2025-11-14 07:25:37	\N
785	Achat viande	25300.00	0.00	CANTINE-20240919	\N	\N	373	1	242	valide	2025-11-14 07:25:37	\N
786	Achat viande	0.00	25300.00	CANTINE-20240919	\N	\N	373	1	236	valide	2025-11-14 07:25:37	\N
787	Ecolage divers élèves	0.00	1680000.00	ECOL-20240920	\N	\N	374	1	193	valide	2025-11-14 07:25:37	\N
788	Ecolage divers élèves	1680000.00	0.00	ECOL-20240920	\N	\N	374	1	236	valide	2025-11-14 07:25:37	\N
789	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20240925	\N	\N	375	1	238	valide	2025-11-14 07:25:37	\N
790	Paiement salaire gardien	180000.00	0.00	SALAIRE-20240925	\N	\N	375	1	239	valide	2025-11-14 07:25:37	\N
791	Paiement femme de ménage	150000.00	0.00	SALAIRE-20240925	\N	\N	375	1	240	valide	2025-11-14 07:25:37	\N
792	Paiement salaires	0.00	580000.00	SALAIRE-20240925	\N	\N	375	1	236	valide	2025-11-14 07:25:37	\N
793	Jirama	42800.00	0.00	JIRAMA-20240927	\N	\N	376	1	99	valide	2025-11-14 07:25:37	\N
794	Jirama	0.00	42800.00	JIRAMA-20240927	\N	\N	376	1	236	valide	2025-11-14 07:25:37	\N
795	Achat fournitures scolaires	148000.00	0.00	FOURN-20240930	\N	\N	377	1	79	valide	2025-11-14 07:25:37	\N
796	Achat fournitures scolaires	0.00	148000.00	FOURN-20240930	\N	\N	377	1	40	valide	2025-11-14 07:25:37	\N
797	Règlement fournisseur	148000.00	0.00	REG-FOURN-20241002	\N	\N	378	1	40	valide	2025-11-14 07:25:37	\N
798	Règlement fournisseur	0.00	148000.00	REG-FOURN-20241002	\N	\N	378	1	236	valide	2025-11-14 07:25:37	\N
799	Achat legumes	22200.00	0.00	CANTINE-20241003	\N	\N	379	1	241	valide	2025-11-14 07:25:37	\N
800	Achat legumes	0.00	22200.00	CANTINE-20241003	\N	\N	379	1	236	valide	2025-11-14 07:25:37	\N
801	Achat viande	25200.00	0.00	CANTINE-20241004	\N	\N	380	1	242	valide	2025-11-14 07:25:37	\N
802	Achat viande	0.00	25200.00	CANTINE-20241004	\N	\N	380	1	236	valide	2025-11-14 07:25:37	\N
803	Achat gouter	13400.00	0.00	CANTINE-20241007	\N	\N	381	1	243	valide	2025-11-14 07:25:37	\N
804	Achat gouter	0.00	13400.00	CANTINE-20241007	\N	\N	381	1	236	valide	2025-11-14 07:25:37	\N
805	Achat legumes	22500.00	0.00	CANTINE-20241008	\N	\N	382	1	241	valide	2025-11-14 07:25:37	\N
806	Achat legumes	0.00	22500.00	CANTINE-20241008	\N	\N	382	1	236	valide	2025-11-14 07:25:37	\N
807	Achat viande	25500.00	0.00	CANTINE-20241009	\N	\N	383	1	242	valide	2025-11-14 07:25:37	\N
808	Achat viande	0.00	25500.00	CANTINE-20241009	\N	\N	383	1	236	valide	2025-11-14 07:25:37	\N
809	Achat gouter	13600.00	0.00	CANTINE-20241010	\N	\N	384	1	243	valide	2025-11-14 07:25:37	\N
810	Achat gouter	0.00	13600.00	CANTINE-20241010	\N	\N	384	1	236	valide	2025-11-14 07:25:37	\N
811	Achat legumes	22800.00	0.00	CANTINE-20241011	\N	\N	385	1	241	valide	2025-11-14 07:25:37	\N
812	Achat legumes	0.00	22800.00	CANTINE-20241011	\N	\N	385	1	236	valide	2025-11-14 07:25:37	\N
813	Achat viande	25800.00	0.00	CANTINE-20241014	\N	\N	386	1	242	valide	2025-11-14 07:25:37	\N
814	Achat viande	0.00	25800.00	CANTINE-20241014	\N	\N	386	1	236	valide	2025-11-14 07:25:37	\N
815	Achat gouter	13800.00	0.00	CANTINE-20241015	\N	\N	387	1	243	valide	2025-11-14 07:25:37	\N
816	Achat gouter	0.00	13800.00	CANTINE-20241015	\N	\N	387	1	236	valide	2025-11-14 07:25:37	\N
817	Achat legumes	23100.00	0.00	CANTINE-20241016	\N	\N	388	1	241	valide	2025-11-14 07:25:37	\N
818	Achat legumes	0.00	23100.00	CANTINE-20241016	\N	\N	388	1	236	valide	2025-11-14 07:25:37	\N
819	Achat viande	26100.00	0.00	CANTINE-20241017	\N	\N	389	1	242	valide	2025-11-14 07:25:37	\N
820	Achat viande	0.00	26100.00	CANTINE-20241017	\N	\N	389	1	236	valide	2025-11-14 07:25:37	\N
821	Achat gouter	14000.00	0.00	CANTINE-20241018	\N	\N	390	1	243	valide	2025-11-14 07:25:37	\N
822	Achat gouter	0.00	14000.00	CANTINE-20241018	\N	\N	390	1	236	valide	2025-11-14 07:25:37	\N
823	Echeancier pret bancaire	1100000.00	0.00	PRET-20241020	\N	\N	391	1	244	valide	2025-11-14 07:25:37	\N
824	Echeancier pret bancaire	0.00	1100000.00	PRET-20241020	\N	\N	391	1	236	valide	2025-11-14 07:25:37	\N
825	Ecolage divers élèves	0.00	1700000.00	ECOL-20241021	\N	\N	392	1	193	valide	2025-11-14 07:25:37	\N
826	Ecolage divers élèves	1700000.00	0.00	ECOL-20241021	\N	\N	392	1	236	valide	2025-11-14 07:25:37	\N
827	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20241025	\N	\N	393	1	238	valide	2025-11-14 07:25:37	\N
828	Paiement salaire gardien	180000.00	0.00	SALAIRE-20241025	\N	\N	393	1	239	valide	2025-11-14 07:25:37	\N
829	Paiement femme de ménage	150000.00	0.00	SALAIRE-20241025	\N	\N	393	1	240	valide	2025-11-14 07:25:37	\N
830	Paiement salaires	0.00	580000.00	SALAIRE-20241025	\N	\N	393	1	236	valide	2025-11-14 07:25:37	\N
831	Jirama	44200.00	0.00	JIRAMA-20241027	\N	\N	394	1	99	valide	2025-11-14 07:25:37	\N
832	Jirama	0.00	44200.00	JIRAMA-20241027	\N	\N	394	1	236	valide	2025-11-14 07:25:37	\N
833	Achat fournitures bureau	152000.00	0.00	FOURN-20241029	\N	\N	395	1	105	valide	2025-11-14 07:25:37	\N
834	Achat fournitures bureau	0.00	152000.00	FOURN-20241029	\N	\N	395	1	40	valide	2025-11-14 07:25:37	\N
835	Règlement fournisseur	152000.00	0.00	REG-FOURN-20241031	\N	\N	396	1	40	valide	2025-11-14 07:25:37	\N
836	Règlement fournisseur	0.00	152000.00	REG-FOURN-20241031	\N	\N	396	1	236	valide	2025-11-14 07:25:37	\N
837	Achat legumes	23000.00	0.00	CANTINE-20241101	\N	\N	397	1	241	valide	2025-11-14 07:25:37	\N
838	Achat legumes	0.00	23000.00	CANTINE-20241101	\N	\N	397	1	236	valide	2025-11-14 07:25:37	\N
839	Achat viande	26000.00	0.00	CANTINE-20241104	\N	\N	398	1	242	valide	2025-11-14 07:25:37	\N
840	Achat viande	0.00	26000.00	CANTINE-20241104	\N	\N	398	1	236	valide	2025-11-14 07:25:37	\N
841	Achat gouter	14200.00	0.00	CANTINE-20241105	\N	\N	399	1	243	valide	2025-11-14 07:25:37	\N
842	Achat gouter	0.00	14200.00	CANTINE-20241105	\N	\N	399	1	236	valide	2025-11-14 07:25:37	\N
843	Achat legumes	23300.00	0.00	CANTINE-20241106	\N	\N	400	1	241	valide	2025-11-14 07:25:37	\N
844	Achat legumes	0.00	23300.00	CANTINE-20241106	\N	\N	400	1	236	valide	2025-11-14 07:25:37	\N
845	Achat viande	26300.00	0.00	CANTINE-20241107	\N	\N	401	1	242	valide	2025-11-14 07:25:37	\N
846	Achat viande	0.00	26300.00	CANTINE-20241107	\N	\N	401	1	236	valide	2025-11-14 07:25:37	\N
847	Achat gouter	14400.00	0.00	CANTINE-20241108	\N	\N	402	1	243	valide	2025-11-14 07:25:37	\N
848	Achat gouter	0.00	14400.00	CANTINE-20241108	\N	\N	402	1	236	valide	2025-11-14 07:25:37	\N
849	Achat legumes	23600.00	0.00	CANTINE-20241111	\N	\N	403	1	241	valide	2025-11-14 07:25:37	\N
850	Achat legumes	0.00	23600.00	CANTINE-20241111	\N	\N	403	1	236	valide	2025-11-14 07:25:37	\N
851	Achat viande	26600.00	0.00	CANTINE-20241112	\N	\N	404	1	242	valide	2025-11-14 07:25:37	\N
852	Achat viande	0.00	26600.00	CANTINE-20241112	\N	\N	404	1	236	valide	2025-11-14 07:25:37	\N
853	Achat gouter	14600.00	0.00	CANTINE-20241113	\N	\N	405	1	243	valide	2025-11-14 07:25:37	\N
854	Achat gouter	0.00	14600.00	CANTINE-20241113	\N	\N	405	1	236	valide	2025-11-14 07:25:37	\N
855	Achat legumes	23900.00	0.00	CANTINE-20241114	\N	\N	406	1	241	valide	2025-11-14 07:25:37	\N
856	Achat legumes	0.00	23900.00	CANTINE-20241114	\N	\N	406	1	236	valide	2025-11-14 07:25:37	\N
857	Versement en banque BMOI	180000.00	0.00	VERS151124	\N	\N	407	1	53	valide	2025-11-14 07:25:37	\N
858	Versement en banque BMOI	0.00	180000.00	VERS151124	\N	\N	407	1	236	valide	2025-11-14 07:25:37	\N
859	Achat viande	26900.00	0.00	CANTINE-20241115	\N	\N	408	1	242	valide	2025-11-14 07:25:37	\N
860	Achat viande	0.00	26900.00	CANTINE-20241115	\N	\N	408	1	236	valide	2025-11-14 07:25:37	\N
861	Achat gouter	14800.00	0.00	CANTINE-20241118	\N	\N	409	1	243	valide	2025-11-14 07:25:37	\N
862	Achat gouter	0.00	14800.00	CANTINE-20241118	\N	\N	409	1	236	valide	2025-11-14 07:25:37	\N
863	Ecolage divers élèves	0.00	1720000.00	ECOL-20241120	\N	\N	410	1	193	valide	2025-11-14 07:25:37	\N
864	Ecolage divers élèves	1720000.00	0.00	ECOL-20241120	\N	\N	410	1	236	valide	2025-11-14 07:25:37	\N
865	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20241125	\N	\N	411	1	238	valide	2025-11-14 07:25:37	\N
866	Paiement salaire gardien	180000.00	0.00	SALAIRE-20241125	\N	\N	411	1	239	valide	2025-11-14 07:25:37	\N
867	Paiement femme de ménage	150000.00	0.00	SALAIRE-20241125	\N	\N	411	1	240	valide	2025-11-14 07:25:37	\N
868	Paiement salaires	0.00	580000.00	SALAIRE-20241125	\N	\N	411	1	236	valide	2025-11-14 07:25:37	\N
869	Jirama	45500.00	0.00	JIRAMA-20241127	\N	\N	412	1	99	valide	2025-11-14 07:25:37	\N
870	Jirama	0.00	45500.00	JIRAMA-20241127	\N	\N	412	1	236	valide	2025-11-14 07:25:37	\N
871	Achat matériel éducatif	155000.00	0.00	FOURN-20241128	\N	\N	413	1	97	valide	2025-11-14 07:25:37	\N
872	Achat matériel éducatif	0.00	155000.00	FOURN-20241128	\N	\N	413	1	40	valide	2025-11-14 07:25:37	\N
873	Règlement fournisseur	155000.00	0.00	REG-FOURN-20241130	\N	\N	414	1	40	valide	2025-11-14 07:25:37	\N
874	Règlement fournisseur	0.00	155000.00	REG-FOURN-20241130	\N	\N	414	1	236	valide	2025-11-14 07:25:37	\N
875	Achat legumes	23800.00	0.00	CANTINE-20241202	\N	\N	415	1	241	valide	2025-11-14 07:25:37	\N
876	Achat legumes	0.00	23800.00	CANTINE-20241202	\N	\N	415	1	236	valide	2025-11-14 07:25:37	\N
877	Achat viande	26800.00	0.00	CANTINE-20241203	\N	\N	416	1	242	valide	2025-11-14 07:25:37	\N
878	Achat viande	0.00	26800.00	CANTINE-20241203	\N	\N	416	1	236	valide	2025-11-14 07:25:37	\N
879	Achat gouter	15000.00	0.00	CANTINE-20241204	\N	\N	417	1	243	valide	2025-11-14 07:25:37	\N
880	Achat gouter	0.00	15000.00	CANTINE-20241204	\N	\N	417	1	236	valide	2025-11-14 07:25:37	\N
881	Achat legumes	24100.00	0.00	CANTINE-20241205	\N	\N	418	1	241	valide	2025-11-14 07:25:37	\N
882	Achat legumes	0.00	24100.00	CANTINE-20241205	\N	\N	418	1	236	valide	2025-11-14 07:25:37	\N
883	Achat viande	27100.00	0.00	CANTINE-20241206	\N	\N	419	1	242	valide	2025-11-14 07:25:37	\N
884	Achat viande	0.00	27100.00	CANTINE-20241206	\N	\N	419	1	236	valide	2025-11-14 07:25:37	\N
885	Achat gouter	15200.00	0.00	CANTINE-20241209	\N	\N	420	1	243	valide	2025-11-14 07:25:37	\N
886	Achat gouter	0.00	15200.00	CANTINE-20241209	\N	\N	420	1	236	valide	2025-11-14 07:25:37	\N
887	Achat legumes	24400.00	0.00	CANTINE-20241210	\N	\N	421	1	241	valide	2025-11-14 07:25:37	\N
888	Achat legumes	0.00	24400.00	CANTINE-20241210	\N	\N	421	1	236	valide	2025-11-14 07:25:37	\N
889	Achat viande	27400.00	0.00	CANTINE-20241211	\N	\N	422	1	242	valide	2025-11-14 07:25:37	\N
890	Achat viande	0.00	27400.00	CANTINE-20241211	\N	\N	422	1	236	valide	2025-11-14 07:25:37	\N
891	Achat gouter	15400.00	0.00	CANTINE-20241212	\N	\N	423	1	243	valide	2025-11-14 07:25:37	\N
892	Achat gouter	0.00	15400.00	CANTINE-20241212	\N	\N	423	1	236	valide	2025-11-14 07:25:37	\N
893	Achat legumes	24700.00	0.00	CANTINE-20241213	\N	\N	424	1	241	valide	2025-11-14 07:25:37	\N
894	Achat legumes	0.00	24700.00	CANTINE-20241213	\N	\N	424	1	236	valide	2025-11-14 07:25:37	\N
895	Achat viande	27700.00	0.00	CANTINE-20241216	\N	\N	425	1	242	valide	2025-11-14 07:25:37	\N
896	Achat viande	0.00	27700.00	CANTINE-20241216	\N	\N	425	1	236	valide	2025-11-14 07:25:37	\N
897	Achat gouter	15600.00	0.00	CANTINE-20241217	\N	\N	426	1	243	valide	2025-11-14 07:25:37	\N
898	Achat gouter	0.00	15600.00	CANTINE-20241217	\N	\N	426	1	236	valide	2025-11-14 07:25:37	\N
899	Achat legumes	25000.00	0.00	CANTINE-20241218	\N	\N	427	1	241	valide	2025-11-14 07:25:37	\N
900	Achat legumes	0.00	25000.00	CANTINE-20241218	\N	\N	427	1	236	valide	2025-11-14 07:25:37	\N
901	Achat viande	28000.00	0.00	CANTINE-20241219	\N	\N	428	1	242	valide	2025-11-14 07:25:37	\N
902	Achat viande	0.00	28000.00	CANTINE-20241219	\N	\N	428	1	236	valide	2025-11-14 07:25:37	\N
903	Ecolage divers élèves	0.00	1740000.00	ECOL-20241220	\N	\N	429	1	193	valide	2025-11-14 07:25:37	\N
904	Ecolage divers élèves	1740000.00	0.00	ECOL-20241220	\N	\N	429	1	236	valide	2025-11-14 07:25:37	\N
905	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20241224	\N	\N	430	1	238	valide	2025-11-14 07:25:37	\N
906	Paiement salaire gardien	180000.00	0.00	SALAIRE-20241224	\N	\N	430	1	239	valide	2025-11-14 07:25:37	\N
907	Paiement femme de ménage	150000.00	0.00	SALAIRE-20241224	\N	\N	430	1	240	valide	2025-11-14 07:25:37	\N
908	Paiement salaires	0.00	580000.00	SALAIRE-20241224	\N	\N	430	1	236	valide	2025-11-14 07:25:37	\N
909	Jirama	46800.00	0.00	JIRAMA-20241227	\N	\N	431	1	99	valide	2025-11-14 07:25:37	\N
910	Jirama	0.00	46800.00	JIRAMA-20241227	\N	\N	431	1	236	valide	2025-11-14 07:25:37	\N
911	Achat fournitures pédagogiques	158000.00	0.00	FOURN-20241230	\N	\N	432	1	106	valide	2025-11-14 07:25:37	\N
912	Achat fournitures pédagogiques	0.00	158000.00	FOURN-20241230	\N	\N	432	1	40	valide	2025-11-14 07:25:37	\N
913	Règlement fournisseur	158000.00	0.00	REG-FOURN-20241231	\N	\N	433	1	40	valide	2025-11-14 07:25:37	\N
914	Règlement fournisseur	0.00	158000.00	REG-FOURN-20241231	\N	\N	433	1	236	valide	2025-11-14 07:25:37	\N
915	Achat legumes	14800.00	0.00	CANTINE-20250102	\N	\N	434	1	241	valide	2025-11-14 07:25:37	\N
916	Achat legumes	0.00	14800.00	CANTINE-20250102	\N	\N	434	1	236	valide	2025-11-14 07:25:37	\N
917	Achat viande	17800.00	0.00	CANTINE-20250103	\N	\N	435	1	242	valide	2025-11-14 07:25:37	\N
918	Achat viande	0.00	17800.00	CANTINE-20250103	\N	\N	435	1	236	valide	2025-11-14 07:25:37	\N
919	Achat gouter	6500.00	0.00	CANTINE-20250106	\N	\N	436	1	243	valide	2025-11-14 07:25:37	\N
920	Achat gouter	0.00	6500.00	CANTINE-20250106	\N	\N	436	1	236	valide	2025-11-14 07:25:37	\N
921	Achat legumes	15100.00	0.00	CANTINE-20250107	\N	\N	437	1	241	valide	2025-11-14 07:25:37	\N
922	Achat legumes	0.00	15100.00	CANTINE-20250107	\N	\N	437	1	236	valide	2025-11-14 07:25:37	\N
923	Achat viande	18100.00	0.00	CANTINE-20250108	\N	\N	438	1	242	valide	2025-11-14 07:25:37	\N
924	Achat viande	0.00	18100.00	CANTINE-20250108	\N	\N	438	1	236	valide	2025-11-14 07:25:37	\N
925	Achat gouter	6700.00	0.00	CANTINE-20250109	\N	\N	439	1	243	valide	2025-11-14 07:25:37	\N
926	Achat gouter	0.00	6700.00	CANTINE-20250109	\N	\N	439	1	236	valide	2025-11-14 07:25:37	\N
927	Achat legumes	15400.00	0.00	CANTINE-20250110	\N	\N	440	1	241	valide	2025-11-14 07:25:37	\N
928	Achat legumes	0.00	15400.00	CANTINE-20250110	\N	\N	440	1	236	valide	2025-11-14 07:25:37	\N
929	Achat viande	18400.00	0.00	CANTINE-20250113	\N	\N	441	1	242	valide	2025-11-14 07:25:37	\N
930	Achat viande	0.00	18400.00	CANTINE-20250113	\N	\N	441	1	236	valide	2025-11-14 07:25:37	\N
931	Achat gouter	6900.00	0.00	CANTINE-20250114	\N	\N	442	1	243	valide	2025-11-14 07:25:37	\N
932	Achat gouter	0.00	6900.00	CANTINE-20250114	\N	\N	442	1	236	valide	2025-11-14 07:25:37	\N
933	Achat legumes	15700.00	0.00	CANTINE-20250115	\N	\N	443	1	241	valide	2025-11-14 07:25:37	\N
934	Achat legumes	0.00	15700.00	CANTINE-20250115	\N	\N	443	1	236	valide	2025-11-14 07:25:37	\N
935	Achat viande	18700.00	0.00	CANTINE-20250116	\N	\N	444	1	242	valide	2025-11-14 07:25:37	\N
936	Achat viande	0.00	18700.00	CANTINE-20250116	\N	\N	444	1	236	valide	2025-11-14 07:25:37	\N
937	Achat gouter	7100.00	0.00	CANTINE-20250117	\N	\N	445	1	243	valide	2025-11-14 07:25:37	\N
938	Achat gouter	0.00	7100.00	CANTINE-20250117	\N	\N	445	1	236	valide	2025-11-14 07:25:37	\N
939	Achat legumes	16000.00	0.00	CANTINE-20250120	\N	\N	446	1	241	valide	2025-11-14 07:25:37	\N
940	Achat legumes	0.00	16000.00	CANTINE-20250120	\N	\N	446	1	236	valide	2025-11-14 07:25:37	\N
941	Achat viande	19000.00	0.00	CANTINE-20250121	\N	\N	447	1	242	valide	2025-11-14 07:25:37	\N
942	Achat viande	0.00	19000.00	CANTINE-20250121	\N	\N	447	1	236	valide	2025-11-14 07:25:37	\N
943	Ecolage divers élèves	0.00	1550000.00	ECOL-20250122	\N	\N	448	1	193	valide	2025-11-14 07:25:37	\N
944	Ecolage divers élèves	1550000.00	0.00	ECOL-20250122	\N	\N	448	1	236	valide	2025-11-14 07:25:37	\N
945	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250125	\N	\N	449	1	238	valide	2025-11-14 07:25:37	\N
946	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250125	\N	\N	449	1	239	valide	2025-11-14 07:25:37	\N
947	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250125	\N	\N	449	1	240	valide	2025-11-14 07:25:37	\N
948	Paiement salaires	0.00	580000.00	SALAIRE-20250125	\N	\N	449	1	236	valide	2025-11-14 07:25:37	\N
949	Jirama	34500.00	0.00	JIRAMA-20250127	\N	\N	450	1	99	valide	2025-11-14 07:25:37	\N
950	Jirama	0.00	34500.00	JIRAMA-20250127	\N	\N	450	1	236	valide	2025-11-14 07:25:37	\N
951	Echeancier pret bancaire	900000.00	0.00	PRET-20250128	\N	\N	451	1	244	valide	2025-11-14 07:25:37	\N
952	Echeancier pret bancaire	0.00	900000.00	PRET-20250128	\N	\N	451	1	236	valide	2025-11-14 07:25:37	\N
953	Achat fournitures scolaires	130000.00	0.00	FOURN-20250130	\N	\N	452	1	79	valide	2025-11-14 07:25:37	\N
954	Achat fournitures scolaires	0.00	130000.00	FOURN-20250130	\N	\N	452	1	40	valide	2025-11-14 07:25:37	\N
955	Règlement fournisseur	130000.00	0.00	REG-FOURN-20250131	\N	\N	453	1	40	valide	2025-11-14 07:25:37	\N
956	Règlement fournisseur	0.00	130000.00	REG-FOURN-20250131	\N	\N	453	1	236	valide	2025-11-14 07:25:37	\N
957	Achat legumes	15900.00	0.00	CANTINE-20250203	\N	\N	454	1	241	valide	2025-11-14 07:25:37	\N
958	Achat legumes	0.00	15900.00	CANTINE-20250203	\N	\N	454	1	236	valide	2025-11-14 07:25:37	\N
959	Achat viande	18900.00	0.00	CANTINE-20250204	\N	\N	455	1	242	valide	2025-11-14 07:25:37	\N
960	Achat viande	0.00	18900.00	CANTINE-20250204	\N	\N	455	1	236	valide	2025-11-14 07:25:37	\N
961	Achat gouter	7300.00	0.00	CANTINE-20250205	\N	\N	456	1	243	valide	2025-11-14 07:25:37	\N
962	Achat gouter	0.00	7300.00	CANTINE-20250205	\N	\N	456	1	236	valide	2025-11-14 07:25:37	\N
963	Achat legumes	16200.00	0.00	CANTINE-20250206	\N	\N	457	1	241	valide	2025-11-14 07:25:37	\N
964	Achat legumes	0.00	16200.00	CANTINE-20250206	\N	\N	457	1	236	valide	2025-11-14 07:25:37	\N
965	Achat viande	19200.00	0.00	CANTINE-20250207	\N	\N	458	1	242	valide	2025-11-14 07:25:37	\N
966	Achat viande	0.00	19200.00	CANTINE-20250207	\N	\N	458	1	236	valide	2025-11-14 07:25:37	\N
967	Achat gouter	7500.00	0.00	CANTINE-20250210	\N	\N	459	1	243	valide	2025-11-14 07:25:37	\N
968	Achat gouter	0.00	7500.00	CANTINE-20250210	\N	\N	459	1	236	valide	2025-11-14 07:25:37	\N
969	Achat legumes	16500.00	0.00	CANTINE-20250211	\N	\N	460	1	241	valide	2025-11-14 07:25:37	\N
970	Achat legumes	0.00	16500.00	CANTINE-20250211	\N	\N	460	1	236	valide	2025-11-14 07:25:37	\N
971	Achat viande	19500.00	0.00	CANTINE-20250212	\N	\N	461	1	242	valide	2025-11-14 07:25:37	\N
972	Achat viande	0.00	19500.00	CANTINE-20250212	\N	\N	461	1	236	valide	2025-11-14 07:25:37	\N
973	Achat gouter	7700.00	0.00	CANTINE-20250213	\N	\N	462	1	243	valide	2025-11-14 07:25:37	\N
974	Achat gouter	0.00	7700.00	CANTINE-20250213	\N	\N	462	1	236	valide	2025-11-14 07:25:37	\N
975	Achat legumes	16800.00	0.00	CANTINE-20250214	\N	\N	463	1	241	valide	2025-11-14 07:25:37	\N
976	Achat legumes	0.00	16800.00	CANTINE-20250214	\N	\N	463	1	236	valide	2025-11-14 07:25:37	\N
977	Appro caisse via BMOI	0.00	2000000.00	APPRO-20250215	\N	\N	464	1	53	valide	2025-11-14 07:25:37	\N
978	Appro caisse via BMOI	2000000.00	0.00	APPRO-20250215	\N	\N	464	1	236	valide	2025-11-14 07:25:37	\N
979	Achat viande	19800.00	0.00	CANTINE-20250217	\N	\N	465	1	242	valide	2025-11-14 07:25:37	\N
980	Achat viande	0.00	19800.00	CANTINE-20250217	\N	\N	465	1	236	valide	2025-11-14 07:25:37	\N
981	Achat gouter	7900.00	0.00	CANTINE-20250218	\N	\N	466	1	243	valide	2025-11-14 07:25:37	\N
982	Achat gouter	0.00	7900.00	CANTINE-20250218	\N	\N	466	1	236	valide	2025-11-14 07:25:37	\N
983	Achat legumes	17100.00	0.00	CANTINE-20250219	\N	\N	467	1	241	valide	2025-11-14 07:25:37	\N
984	Achat legumes	0.00	17100.00	CANTINE-20250219	\N	\N	467	1	236	valide	2025-11-14 07:25:37	\N
985	Ecolage divers élèves	0.00	1570000.00	ECOL-20250220	\N	\N	468	1	193	valide	2025-11-14 07:25:37	\N
986	Ecolage divers élèves	1570000.00	0.00	ECOL-20250220	\N	\N	468	1	236	valide	2025-11-14 07:25:37	\N
987	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250225	\N	\N	469	1	238	valide	2025-11-14 07:25:37	\N
988	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250225	\N	\N	469	1	239	valide	2025-11-14 07:25:37	\N
989	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250225	\N	\N	469	1	240	valide	2025-11-14 07:25:37	\N
990	Paiement salaires	0.00	580000.00	SALAIRE-20250225	\N	\N	469	1	236	valide	2025-11-14 07:25:37	\N
991	Jirama	35800.00	0.00	JIRAMA-20250227	\N	\N	470	1	99	valide	2025-11-14 07:25:37	\N
992	Jirama	0.00	35800.00	JIRAMA-20250227	\N	\N	470	1	236	valide	2025-11-14 07:25:37	\N
993	Achat fournitures bureau	124000.00	0.00	FOURN-20250228	\N	\N	471	1	105	valide	2025-11-14 07:25:37	\N
994	Achat fournitures bureau	0.00	124000.00	FOURN-20250228	\N	\N	471	1	40	valide	2025-11-14 07:25:37	\N
995	Règlement fournisseur	124000.00	0.00	REG-FOURN-20250302	\N	\N	472	1	40	valide	2025-11-14 07:25:37	\N
996	Règlement fournisseur	0.00	124000.00	REG-FOURN-20250302	\N	\N	472	1	236	valide	2025-11-14 07:25:37	\N
997	Achat legumes	17000.00	0.00	CANTINE-20250303	\N	\N	473	1	241	valide	2025-11-14 07:25:37	\N
998	Achat legumes	0.00	17000.00	CANTINE-20250303	\N	\N	473	1	236	valide	2025-11-14 07:25:37	\N
999	Achat viande	20000.00	0.00	CANTINE-20250304	\N	\N	474	1	242	valide	2025-11-14 07:25:37	\N
1000	Achat viande	0.00	20000.00	CANTINE-20250304	\N	\N	474	1	236	valide	2025-11-14 07:25:37	\N
1001	Achat gouter	8100.00	0.00	CANTINE-20250305	\N	\N	475	1	243	valide	2025-11-14 07:25:37	\N
1002	Achat gouter	0.00	8100.00	CANTINE-20250305	\N	\N	475	1	236	valide	2025-11-14 07:25:37	\N
1003	Achat legumes	17300.00	0.00	CANTINE-20250306	\N	\N	476	1	241	valide	2025-11-14 07:25:37	\N
1004	Achat legumes	0.00	17300.00	CANTINE-20250306	\N	\N	476	1	236	valide	2025-11-14 07:25:37	\N
1005	Achat viande	20300.00	0.00	CANTINE-20250307	\N	\N	477	1	242	valide	2025-11-14 07:25:37	\N
1006	Achat viande	0.00	20300.00	CANTINE-20250307	\N	\N	477	1	236	valide	2025-11-14 07:25:37	\N
1007	Achat gouter	8300.00	0.00	CANTINE-20250310	\N	\N	478	1	243	valide	2025-11-14 07:25:37	\N
1008	Achat gouter	0.00	8300.00	CANTINE-20250310	\N	\N	478	1	236	valide	2025-11-14 07:25:37	\N
1009	Achat legumes	17600.00	0.00	CANTINE-20250311	\N	\N	479	1	241	valide	2025-11-14 07:25:37	\N
1010	Achat legumes	0.00	17600.00	CANTINE-20250311	\N	\N	479	1	236	valide	2025-11-14 07:25:37	\N
1011	Achat viande	20600.00	0.00	CANTINE-20250312	\N	\N	480	1	242	valide	2025-11-14 07:25:37	\N
1012	Achat viande	0.00	20600.00	CANTINE-20250312	\N	\N	480	1	236	valide	2025-11-14 07:25:37	\N
1013	Achat gouter	8500.00	0.00	CANTINE-20250313	\N	\N	481	1	243	valide	2025-11-14 07:25:37	\N
1014	Achat gouter	0.00	8500.00	CANTINE-20250313	\N	\N	481	1	236	valide	2025-11-14 07:25:37	\N
1015	Achat legumes	17900.00	0.00	CANTINE-20250314	\N	\N	482	1	241	valide	2025-11-14 07:25:37	\N
1016	Achat legumes	0.00	17900.00	CANTINE-20250314	\N	\N	482	1	236	valide	2025-11-14 07:25:37	\N
1017	Achat viande	20900.00	0.00	CANTINE-20250317	\N	\N	483	1	242	valide	2025-11-14 07:25:37	\N
1018	Achat viande	0.00	20900.00	CANTINE-20250317	\N	\N	483	1	236	valide	2025-11-14 07:25:37	\N
1019	Achat gouter	8700.00	0.00	CANTINE-20250318	\N	\N	484	1	243	valide	2025-11-14 07:25:37	\N
1020	Achat gouter	0.00	8700.00	CANTINE-20250318	\N	\N	484	1	236	valide	2025-11-14 07:25:37	\N
1021	Achat legumes	18200.00	0.00	CANTINE-20250319	\N	\N	485	1	241	valide	2025-11-14 07:25:37	\N
1022	Achat legumes	0.00	18200.00	CANTINE-20250319	\N	\N	485	1	236	valide	2025-11-14 07:25:37	\N
1023	Versement en banque BMOI	130000.00	0.00	VERS200325	\N	\N	486	1	53	valide	2025-11-14 07:25:37	\N
1024	Versement en banque BMOI	0.00	130000.00	VERS200325	\N	\N	486	1	236	valide	2025-11-14 07:25:37	\N
1025	Ecolage divers élèves	0.00	1590000.00	ECOL-20250320	\N	\N	487	1	193	valide	2025-11-14 07:25:37	\N
1026	Ecolage divers élèves	1590000.00	0.00	ECOL-20250320	\N	\N	487	1	236	valide	2025-11-14 07:25:37	\N
1027	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250325	\N	\N	488	1	238	valide	2025-11-14 07:25:37	\N
1028	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250325	\N	\N	488	1	239	valide	2025-11-14 07:25:37	\N
1029	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250325	\N	\N	488	1	240	valide	2025-11-14 07:25:37	\N
1030	Paiement salaires	0.00	580000.00	SALAIRE-20250325	\N	\N	488	1	236	valide	2025-11-14 07:25:37	\N
1031	Jirama	37200.00	0.00	JIRAMA-20250327	\N	\N	489	1	99	valide	2025-11-14 07:25:37	\N
1032	Jirama	0.00	37200.00	JIRAMA-20250327	\N	\N	489	1	236	valide	2025-11-14 07:25:37	\N
1033	Achat matériel éducatif	136000.00	0.00	FOURN-20250330	\N	\N	490	1	97	valide	2025-11-14 07:25:37	\N
1034	Achat matériel éducatif	0.00	136000.00	FOURN-20250330	\N	\N	490	1	40	valide	2025-11-14 07:25:37	\N
1035	Règlement fournisseur	136000.00	0.00	REG-FOURN-20250331	\N	\N	491	1	40	valide	2025-11-14 07:25:37	\N
1036	Règlement fournisseur	0.00	136000.00	REG-FOURN-20250331	\N	\N	491	1	236	valide	2025-11-14 07:25:37	\N
1037	Achat legumes	18100.00	0.00	CANTINE-20250401	\N	\N	492	1	241	valide	2025-11-14 07:25:37	\N
1038	Achat legumes	0.00	18100.00	CANTINE-20250401	\N	\N	492	1	236	valide	2025-11-14 07:25:37	\N
1039	Achat viande	21100.00	0.00	CANTINE-20250402	\N	\N	493	1	242	valide	2025-11-14 07:25:37	\N
1040	Achat viande	0.00	21100.00	CANTINE-20250402	\N	\N	493	1	236	valide	2025-11-14 07:25:37	\N
1041	Achat gouter	8900.00	0.00	CANTINE-20250403	\N	\N	494	1	243	valide	2025-11-14 07:25:37	\N
1042	Achat gouter	0.00	8900.00	CANTINE-20250403	\N	\N	494	1	236	valide	2025-11-14 07:25:37	\N
1043	Achat legumes	18400.00	0.00	CANTINE-20250404	\N	\N	495	1	241	valide	2025-11-14 07:25:37	\N
1044	Achat legumes	0.00	18400.00	CANTINE-20250404	\N	\N	495	1	236	valide	2025-11-14 07:25:37	\N
1045	Achat viande	21400.00	0.00	CANTINE-20250407	\N	\N	496	1	242	valide	2025-11-14 07:25:37	\N
1046	Achat viande	0.00	21400.00	CANTINE-20250407	\N	\N	496	1	236	valide	2025-11-14 07:25:37	\N
1047	Achat gouter	9100.00	0.00	CANTINE-20250408	\N	\N	497	1	243	valide	2025-11-14 07:25:37	\N
1048	Achat gouter	0.00	9100.00	CANTINE-20250408	\N	\N	497	1	236	valide	2025-11-14 07:25:37	\N
1049	Achat legumes	18700.00	0.00	CANTINE-20250409	\N	\N	498	1	241	valide	2025-11-14 07:25:37	\N
1050	Achat legumes	0.00	18700.00	CANTINE-20250409	\N	\N	498	1	236	valide	2025-11-14 07:25:37	\N
1051	Achat viande	21700.00	0.00	CANTINE-20250410	\N	\N	499	1	242	valide	2025-11-14 07:25:37	\N
1052	Achat viande	0.00	21700.00	CANTINE-20250410	\N	\N	499	1	236	valide	2025-11-14 07:25:37	\N
1053	Achat gouter	9300.00	0.00	CANTINE-20250411	\N	\N	500	1	243	valide	2025-11-14 07:25:37	\N
1054	Achat gouter	0.00	9300.00	CANTINE-20250411	\N	\N	500	1	236	valide	2025-11-14 07:25:37	\N
1055	Achat legumes	19000.00	0.00	CANTINE-20250414	\N	\N	501	1	241	valide	2025-11-14 07:25:37	\N
1056	Achat legumes	0.00	19000.00	CANTINE-20250414	\N	\N	501	1	236	valide	2025-11-14 07:25:37	\N
1057	Achat viande	22000.00	0.00	CANTINE-20250415	\N	\N	502	1	242	valide	2025-11-14 07:25:37	\N
1058	Achat viande	0.00	22000.00	CANTINE-20250415	\N	\N	502	1	236	valide	2025-11-14 07:25:37	\N
1059	Achat gouter	9500.00	0.00	CANTINE-20250416	\N	\N	503	1	243	valide	2025-11-14 07:25:37	\N
1060	Achat gouter	0.00	9500.00	CANTINE-20250416	\N	\N	503	1	236	valide	2025-11-14 07:25:37	\N
1061	Achat legumes	19300.00	0.00	CANTINE-20250417	\N	\N	504	1	241	valide	2025-11-14 07:25:37	\N
1062	Achat legumes	0.00	19300.00	CANTINE-20250417	\N	\N	504	1	236	valide	2025-11-14 07:25:37	\N
1063	Achat viande	22300.00	0.00	CANTINE-20250418	\N	\N	505	1	242	valide	2025-11-14 07:25:37	\N
1064	Achat viande	0.00	22300.00	CANTINE-20250418	\N	\N	505	1	236	valide	2025-11-14 07:25:37	\N
1065	Achat gouter	9700.00	0.00	CANTINE-20250421	\N	\N	506	1	243	valide	2025-11-14 07:25:37	\N
1066	Achat gouter	0.00	9700.00	CANTINE-20250421	\N	\N	506	1	236	valide	2025-11-14 07:25:37	\N
1067	Ecolage divers élèves	0.00	1610000.00	ECOL-20250422	\N	\N	507	1	193	valide	2025-11-14 07:25:37	\N
1068	Ecolage divers élèves	1610000.00	0.00	ECOL-20250422	\N	\N	507	1	236	valide	2025-11-14 07:25:37	\N
1069	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250425	\N	\N	508	1	238	valide	2025-11-14 07:25:37	\N
1070	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250425	\N	\N	508	1	239	valide	2025-11-14 07:25:37	\N
1071	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250425	\N	\N	508	1	240	valide	2025-11-14 07:25:37	\N
1072	Paiement salaires	0.00	580000.00	SALAIRE-20250425	\N	\N	508	1	236	valide	2025-11-14 07:25:37	\N
1073	Jirama	38500.00	0.00	JIRAMA-20250427	\N	\N	509	1	99	valide	2025-11-14 07:25:37	\N
1074	Jirama	0.00	38500.00	JIRAMA-20250427	\N	\N	509	1	236	valide	2025-11-14 07:25:37	\N
1075	Achat fournitures pédagogiques	133000.00	0.00	FOURN-20250429	\N	\N	510	1	106	valide	2025-11-14 07:25:37	\N
1076	Achat fournitures pédagogiques	0.00	133000.00	FOURN-20250429	\N	\N	510	1	40	valide	2025-11-14 07:25:37	\N
1077	Règlement fournisseur	133000.00	0.00	REG-FOURN-20250430	\N	\N	511	1	40	valide	2025-11-14 07:25:37	\N
1078	Règlement fournisseur	0.00	133000.00	REG-FOURN-20250430	\N	\N	511	1	236	valide	2025-11-14 07:25:37	\N
1079	Achat legumes	19200.00	0.00	CANTINE-20250502	\N	\N	512	1	241	valide	2025-11-14 07:25:37	\N
1080	Achat legumes	0.00	19200.00	CANTINE-20250502	\N	\N	512	1	236	valide	2025-11-14 07:25:37	\N
1081	Achat viande	22200.00	0.00	CANTINE-20250504	\N	\N	513	1	242	valide	2025-11-14 07:25:37	\N
1082	Achat viande	0.00	22200.00	CANTINE-20250504	\N	\N	513	1	236	valide	2025-11-14 07:25:37	\N
1083	Achat gouter	9900.00	0.00	CANTINE-20250505	\N	\N	514	1	243	valide	2025-11-14 07:25:37	\N
1084	Achat gouter	0.00	9900.00	CANTINE-20250505	\N	\N	514	1	236	valide	2025-11-14 07:25:37	\N
1085	Achat legumes	19500.00	0.00	CANTINE-20250506	\N	\N	515	1	241	valide	2025-11-14 07:25:37	\N
1086	Achat legumes	0.00	19500.00	CANTINE-20250506	\N	\N	515	1	236	valide	2025-11-14 07:25:37	\N
1087	Achat viande	22500.00	0.00	CANTINE-20250507	\N	\N	516	1	242	valide	2025-11-14 07:25:37	\N
1088	Achat viande	0.00	22500.00	CANTINE-20250507	\N	\N	516	1	236	valide	2025-11-14 07:25:37	\N
1089	Achat gouter	10100.00	0.00	CANTINE-20250508	\N	\N	517	1	243	valide	2025-11-14 07:25:37	\N
1090	Achat gouter	0.00	10100.00	CANTINE-20250508	\N	\N	517	1	236	valide	2025-11-14 07:25:37	\N
1091	Achat legumes	19800.00	0.00	CANTINE-20250509	\N	\N	518	1	241	valide	2025-11-14 07:25:37	\N
1092	Achat legumes	0.00	19800.00	CANTINE-20250509	\N	\N	518	1	236	valide	2025-11-14 07:25:37	\N
1093	Echeancier pret bancaire	1000000.00	0.00	PRET-20250510	\N	\N	519	1	244	valide	2025-11-14 07:25:37	\N
1094	Echeancier pret bancaire	0.00	1000000.00	PRET-20250510	\N	\N	519	1	236	valide	2025-11-14 07:25:37	\N
1095	Achat viande	22800.00	0.00	CANTINE-20250512	\N	\N	520	1	242	valide	2025-11-14 07:25:37	\N
1096	Achat viande	0.00	22800.00	CANTINE-20250512	\N	\N	520	1	236	valide	2025-11-14 07:25:37	\N
1097	Achat gouter	10300.00	0.00	CANTINE-20250513	\N	\N	521	1	243	valide	2025-11-14 07:25:37	\N
1098	Achat gouter	0.00	10300.00	CANTINE-20250513	\N	\N	521	1	236	valide	2025-11-14 07:25:37	\N
1099	Achat legumes	20100.00	0.00	CANTINE-20250514	\N	\N	522	1	241	valide	2025-11-14 07:25:37	\N
1100	Achat legumes	0.00	20100.00	CANTINE-20250514	\N	\N	522	1	236	valide	2025-11-14 07:25:37	\N
1101	Achat viande	23100.00	0.00	CANTINE-20250515	\N	\N	523	1	242	valide	2025-11-14 07:25:37	\N
1102	Achat viande	0.00	23100.00	CANTINE-20250515	\N	\N	523	1	236	valide	2025-11-14 07:25:37	\N
1103	Achat gouter	10500.00	0.00	CANTINE-20250516	\N	\N	524	1	243	valide	2025-11-14 07:25:37	\N
1104	Achat gouter	0.00	10500.00	CANTINE-20250516	\N	\N	524	1	236	valide	2025-11-14 07:25:37	\N
1105	Achat legumes	20400.00	0.00	CANTINE-20250519	\N	\N	525	1	241	valide	2025-11-14 07:25:37	\N
1106	Achat legumes	0.00	20400.00	CANTINE-20250519	\N	\N	525	1	236	valide	2025-11-14 07:25:37	\N
1107	Ecolage divers élèves	0.00	1630000.00	ECOL-20250520	\N	\N	526	1	193	valide	2025-11-14 07:25:37	\N
1108	Ecolage divers élèves	1630000.00	0.00	ECOL-20250520	\N	\N	526	1	236	valide	2025-11-14 07:25:37	\N
1109	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250525	\N	\N	527	1	238	valide	2025-11-14 07:25:37	\N
1110	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250525	\N	\N	527	1	239	valide	2025-11-14 07:25:37	\N
1111	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250525	\N	\N	527	1	240	valide	2025-11-14 07:25:37	\N
1112	Paiement salaires	0.00	580000.00	SALAIRE-20250525	\N	\N	527	1	236	valide	2025-11-14 07:25:37	\N
1113	Jirama	39800.00	0.00	JIRAMA-20250527	\N	\N	528	1	99	valide	2025-11-14 07:25:37	\N
1114	Jirama	0.00	39800.00	JIRAMA-20250527	\N	\N	528	1	236	valide	2025-11-14 07:25:37	\N
1115	Achat fournitures scolaires	142000.00	0.00	FOURN-20250529	\N	\N	529	1	79	valide	2025-11-14 07:25:37	\N
1116	Achat fournitures scolaires	0.00	142000.00	FOURN-20250529	\N	\N	529	1	40	valide	2025-11-14 07:25:37	\N
1117	Règlement fournisseur	142000.00	0.00	REG-FOURN-20250531	\N	\N	530	1	40	valide	2025-11-14 07:25:37	\N
1118	Règlement fournisseur	0.00	142000.00	REG-FOURN-20250531	\N	\N	530	1	236	valide	2025-11-14 07:25:37	\N
1119	Achat legumes	20300.00	0.00	CANTINE-20250602	\N	\N	531	1	241	valide	2025-11-14 07:25:37	\N
1120	Achat legumes	0.00	20300.00	CANTINE-20250602	\N	\N	531	1	236	valide	2025-11-14 07:25:37	\N
1121	Achat viande	23300.00	0.00	CANTINE-20250603	\N	\N	532	1	242	valide	2025-11-14 07:25:37	\N
1122	Achat viande	0.00	23300.00	CANTINE-20250603	\N	\N	532	1	236	valide	2025-11-14 07:25:37	\N
1123	Achat gouter	10700.00	0.00	CANTINE-20250604	\N	\N	533	1	243	valide	2025-11-14 07:25:37	\N
1124	Achat gouter	0.00	10700.00	CANTINE-20250604	\N	\N	533	1	236	valide	2025-11-14 07:25:37	\N
1125	Achat legumes	20600.00	0.00	CANTINE-20250605	\N	\N	534	1	241	valide	2025-11-14 07:25:37	\N
1126	Achat legumes	0.00	20600.00	CANTINE-20250605	\N	\N	534	1	236	valide	2025-11-14 07:25:37	\N
1127	Achat viande	23600.00	0.00	CANTINE-20250606	\N	\N	535	1	242	valide	2025-11-14 07:25:37	\N
1128	Achat viande	0.00	23600.00	CANTINE-20250606	\N	\N	535	1	236	valide	2025-11-14 07:25:37	\N
1129	Achat gouter	10900.00	0.00	CANTINE-20250609	\N	\N	536	1	243	valide	2025-11-14 07:25:37	\N
1130	Achat gouter	0.00	10900.00	CANTINE-20250609	\N	\N	536	1	236	valide	2025-11-14 07:25:37	\N
1131	Achat legumes	20900.00	0.00	CANTINE-20250610	\N	\N	537	1	241	valide	2025-11-14 07:25:37	\N
1132	Achat legumes	0.00	20900.00	CANTINE-20250610	\N	\N	537	1	236	valide	2025-11-14 07:25:37	\N
1133	Achat viande	23900.00	0.00	CANTINE-20250611	\N	\N	538	1	242	valide	2025-11-14 07:25:37	\N
1134	Achat viande	0.00	23900.00	CANTINE-20250611	\N	\N	538	1	236	valide	2025-11-14 07:25:37	\N
1135	Achat gouter	11100.00	0.00	CANTINE-20250612	\N	\N	539	1	243	valide	2025-11-14 07:25:37	\N
1136	Achat gouter	0.00	11100.00	CANTINE-20250612	\N	\N	539	1	236	valide	2025-11-14 07:25:37	\N
1137	Achat legumes	21200.00	0.00	CANTINE-20250613	\N	\N	540	1	241	valide	2025-11-14 07:25:37	\N
1138	Achat legumes	0.00	21200.00	CANTINE-20250613	\N	\N	540	1	236	valide	2025-11-14 07:25:37	\N
1139	Achat viande	24200.00	0.00	CANTINE-20250616	\N	\N	541	1	242	valide	2025-11-14 07:25:37	\N
1140	Achat viande	0.00	24200.00	CANTINE-20250616	\N	\N	541	1	236	valide	2025-11-14 07:25:37	\N
1141	Achat gouter	11300.00	0.00	CANTINE-20250617	\N	\N	542	1	243	valide	2025-11-14 07:25:37	\N
1142	Achat gouter	0.00	11300.00	CANTINE-20250617	\N	\N	542	1	236	valide	2025-11-14 07:25:37	\N
1143	Achat legumes	21500.00	0.00	CANTINE-20250618	\N	\N	543	1	241	valide	2025-11-14 07:25:37	\N
1144	Achat legumes	0.00	21500.00	CANTINE-20250618	\N	\N	543	1	236	valide	2025-11-14 07:25:37	\N
1145	Achat viande	24500.00	0.00	CANTINE-20250619	\N	\N	544	1	242	valide	2025-11-14 07:25:37	\N
1146	Achat viande	0.00	24500.00	CANTINE-20250619	\N	\N	544	1	236	valide	2025-11-14 07:25:37	\N
1147	Ecolage divers élèves	0.00	1650000.00	ECOL-20250620	\N	\N	545	1	193	valide	2025-11-14 07:25:37	\N
1148	Ecolage divers élèves	1650000.00	0.00	ECOL-20250620	\N	\N	545	1	236	valide	2025-11-14 07:25:37	\N
1149	Versement en banque BMOI	160000.00	0.00	VERS250625	\N	\N	546	1	53	valide	2025-11-14 07:25:37	\N
1150	Versement en banque BMOI	0.00	160000.00	VERS250625	\N	\N	546	1	236	valide	2025-11-14 07:25:37	\N
1151	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250625	\N	\N	547	1	238	valide	2025-11-14 07:25:37	\N
1152	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250625	\N	\N	547	1	239	valide	2025-11-14 07:25:37	\N
1153	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250625	\N	\N	547	1	240	valide	2025-11-14 07:25:37	\N
1154	Paiement salaires	0.00	580000.00	SALAIRE-20250625	\N	\N	547	1	236	valide	2025-11-14 07:25:37	\N
1155	Jirama	41200.00	0.00	JIRAMA-20250627	\N	\N	548	1	99	valide	2025-11-14 07:25:37	\N
1156	Jirama	0.00	41200.00	JIRAMA-20250627	\N	\N	548	1	236	valide	2025-11-14 07:25:37	\N
1157	Achat fournitures bureau	135000.00	0.00	FOURN-20250628	\N	\N	549	1	105	valide	2025-11-14 07:25:37	\N
1158	Achat fournitures bureau	0.00	135000.00	FOURN-20250628	\N	\N	549	1	40	valide	2025-11-14 07:25:37	\N
1159	Règlement fournisseur	135000.00	0.00	REG-FOURN-20250630	\N	\N	550	1	40	valide	2025-11-14 07:25:37	\N
1160	Règlement fournisseur	0.00	135000.00	REG-FOURN-20250630	\N	\N	550	1	236	valide	2025-11-14 07:25:37	\N
1161	Achat legumes	21400.00	0.00	CANTINE-20250701	\N	\N	551	1	241	valide	2025-11-14 07:25:37	\N
1162	Achat legumes	0.00	21400.00	CANTINE-20250701	\N	\N	551	1	236	valide	2025-11-14 07:25:37	\N
1163	Achat viande	24400.00	0.00	CANTINE-20250702	\N	\N	552	1	242	valide	2025-11-14 07:25:37	\N
1164	Achat viande	0.00	24400.00	CANTINE-20250702	\N	\N	552	1	236	valide	2025-11-14 07:25:37	\N
1165	Achat gouter	11500.00	0.00	CANTINE-20250703	\N	\N	553	1	243	valide	2025-11-14 07:25:37	\N
1166	Achat gouter	0.00	11500.00	CANTINE-20250703	\N	\N	553	1	236	valide	2025-11-14 07:25:37	\N
1167	Achat legumes	21700.00	0.00	CANTINE-20250704	\N	\N	554	1	241	valide	2025-11-14 07:25:37	\N
1168	Achat legumes	0.00	21700.00	CANTINE-20250704	\N	\N	554	1	236	valide	2025-11-14 07:25:37	\N
1169	Achat viande	24700.00	0.00	CANTINE-20250707	\N	\N	555	1	242	valide	2025-11-14 07:25:37	\N
1170	Achat viande	0.00	24700.00	CANTINE-20250707	\N	\N	555	1	236	valide	2025-11-14 07:25:37	\N
1171	Achat gouter	11700.00	0.00	CANTINE-20250708	\N	\N	556	1	243	valide	2025-11-14 07:25:37	\N
1172	Achat gouter	0.00	11700.00	CANTINE-20250708	\N	\N	556	1	236	valide	2025-11-14 07:25:37	\N
1173	Achat legumes	22000.00	0.00	CANTINE-20250709	\N	\N	557	1	241	valide	2025-11-14 07:25:37	\N
1174	Achat legumes	0.00	22000.00	CANTINE-20250709	\N	\N	557	1	236	valide	2025-11-14 07:25:37	\N
1175	Achat viande	25000.00	0.00	CANTINE-20250710	\N	\N	558	1	242	valide	2025-11-14 07:25:37	\N
1176	Achat viande	0.00	25000.00	CANTINE-20250710	\N	\N	558	1	236	valide	2025-11-14 07:25:37	\N
1177	Achat gouter	11900.00	0.00	CANTINE-20250711	\N	\N	559	1	243	valide	2025-11-14 07:25:37	\N
1178	Achat gouter	0.00	11900.00	CANTINE-20250711	\N	\N	559	1	236	valide	2025-11-14 07:25:37	\N
1179	Achat legumes	22300.00	0.00	CANTINE-20250714	\N	\N	560	1	241	valide	2025-11-14 07:25:37	\N
1180	Achat legumes	0.00	22300.00	CANTINE-20250714	\N	\N	560	1	236	valide	2025-11-14 07:25:37	\N
1181	Achat viande	25300.00	0.00	CANTINE-20250715	\N	\N	561	1	242	valide	2025-11-14 07:25:37	\N
1182	Achat viande	0.00	25300.00	CANTINE-20250715	\N	\N	561	1	236	valide	2025-11-14 07:25:37	\N
1183	Achat gouter	12100.00	0.00	CANTINE-20250716	\N	\N	562	1	243	valide	2025-11-14 07:25:37	\N
1184	Achat gouter	0.00	12100.00	CANTINE-20250716	\N	\N	562	1	236	valide	2025-11-14 07:25:37	\N
1185	Achat legumes	22600.00	0.00	CANTINE-20250717	\N	\N	563	1	241	valide	2025-11-14 07:25:37	\N
1186	Achat legumes	0.00	22600.00	CANTINE-20250717	\N	\N	563	1	236	valide	2025-11-14 07:25:37	\N
1187	Achat viande	25600.00	0.00	CANTINE-20250718	\N	\N	564	1	242	valide	2025-11-14 07:25:37	\N
1188	Achat viande	0.00	25600.00	CANTINE-20250718	\N	\N	564	1	236	valide	2025-11-14 07:25:37	\N
1189	Achat gouter	12300.00	0.00	CANTINE-20250721	\N	\N	565	1	243	valide	2025-11-14 07:25:37	\N
1190	Achat gouter	0.00	12300.00	CANTINE-20250721	\N	\N	565	1	236	valide	2025-11-14 07:25:37	\N
1191	Ecolage divers élèves	0.00	1670000.00	ECOL-20250722	\N	\N	566	1	193	valide	2025-11-14 07:25:37	\N
1192	Ecolage divers élèves	1670000.00	0.00	ECOL-20250722	\N	\N	566	1	236	valide	2025-11-14 07:25:37	\N
1193	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250725	\N	\N	567	1	238	valide	2025-11-14 07:25:37	\N
1194	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250725	\N	\N	567	1	239	valide	2025-11-14 07:25:37	\N
1195	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250725	\N	\N	567	1	240	valide	2025-11-14 07:25:37	\N
1196	Paiement salaires	0.00	580000.00	SALAIRE-20250725	\N	\N	567	1	236	valide	2025-11-14 07:25:37	\N
1197	Jirama	42500.00	0.00	JIRAMA-20250727	\N	\N	568	1	99	valide	2025-11-14 07:25:37	\N
1198	Jirama	0.00	42500.00	JIRAMA-20250727	\N	\N	568	1	236	valide	2025-11-14 07:25:37	\N
1199	Achat matériel éducatif	139000.00	0.00	FOURN-20250729	\N	\N	569	1	97	valide	2025-11-14 07:25:37	\N
1200	Achat matériel éducatif	0.00	139000.00	FOURN-20250729	\N	\N	569	1	40	valide	2025-11-14 07:25:37	\N
1201	Règlement fournisseur	139000.00	0.00	REG-FOURN-20250731	\N	\N	570	1	40	valide	2025-11-14 07:25:37	\N
1202	Règlement fournisseur	0.00	139000.00	REG-FOURN-20250731	\N	\N	570	1	236	valide	2025-11-14 07:25:37	\N
1203	Achat legumes	22500.00	0.00	CANTINE-20250801	\N	\N	571	1	241	valide	2025-11-14 07:25:37	\N
1204	Achat legumes	0.00	22500.00	CANTINE-20250801	\N	\N	571	1	236	valide	2025-11-14 07:25:37	\N
1205	Achat viande	25500.00	0.00	CANTINE-20250804	\N	\N	572	1	242	valide	2025-11-14 07:25:37	\N
1206	Achat viande	0.00	25500.00	CANTINE-20250804	\N	\N	572	1	236	valide	2025-11-14 07:25:37	\N
1207	Achat gouter	12500.00	0.00	CANTINE-20250805	\N	\N	573	1	243	valide	2025-11-14 07:25:37	\N
1208	Achat gouter	0.00	12500.00	CANTINE-20250805	\N	\N	573	1	236	valide	2025-11-14 07:25:37	\N
1209	Achat legumes	22800.00	0.00	CANTINE-20250806	\N	\N	574	1	241	valide	2025-11-14 07:25:37	\N
1210	Achat legumes	0.00	22800.00	CANTINE-20250806	\N	\N	574	1	236	valide	2025-11-14 07:25:37	\N
1211	Achat viande	25800.00	0.00	CANTINE-20250807	\N	\N	575	1	242	valide	2025-11-14 07:25:37	\N
1212	Achat viande	0.00	25800.00	CANTINE-20250807	\N	\N	575	1	236	valide	2025-11-14 07:25:37	\N
1213	Achat gouter	12700.00	0.00	CANTINE-20250808	\N	\N	576	1	243	valide	2025-11-14 07:25:37	\N
1214	Achat gouter	0.00	12700.00	CANTINE-20250808	\N	\N	576	1	236	valide	2025-11-14 07:25:37	\N
1215	Achat legumes	23100.00	0.00	CANTINE-20250811	\N	\N	577	1	241	valide	2025-11-14 07:25:37	\N
1216	Achat legumes	0.00	23100.00	CANTINE-20250811	\N	\N	577	1	236	valide	2025-11-14 07:25:37	\N
1217	Achat viande	26100.00	0.00	CANTINE-20250812	\N	\N	578	1	242	valide	2025-11-14 07:25:37	\N
1218	Achat viande	0.00	26100.00	CANTINE-20250812	\N	\N	578	1	236	valide	2025-11-14 07:25:37	\N
1219	Achat gouter	12900.00	0.00	CANTINE-20250813	\N	\N	579	1	243	valide	2025-11-14 07:25:37	\N
1220	Achat gouter	0.00	12900.00	CANTINE-20250813	\N	\N	579	1	236	valide	2025-11-14 07:25:37	\N
1221	Achat legumes	23400.00	0.00	CANTINE-20250814	\N	\N	580	1	241	valide	2025-11-14 07:25:37	\N
1222	Achat legumes	0.00	23400.00	CANTINE-20250814	\N	\N	580	1	236	valide	2025-11-14 07:25:37	\N
1223	Appro caisse via BMOI	0.00	2400000.00	APPRO-20250815	\N	\N	581	1	53	valide	2025-11-14 07:25:37	\N
1224	Appro caisse via BMOI	2400000.00	0.00	APPRO-20250815	\N	\N	581	1	236	valide	2025-11-14 07:25:37	\N
1225	Achat viande	26400.00	0.00	CANTINE-20250815	\N	\N	582	1	242	valide	2025-11-14 07:25:37	\N
1226	Achat viande	0.00	26400.00	CANTINE-20250815	\N	\N	582	1	236	valide	2025-11-14 07:25:37	\N
1227	Achat gouter	13100.00	0.00	CANTINE-20250818	\N	\N	583	1	243	valide	2025-11-14 07:25:37	\N
1228	Achat gouter	0.00	13100.00	CANTINE-20250818	\N	\N	583	1	236	valide	2025-11-14 07:25:37	\N
1229	Achat legumes	23700.00	0.00	CANTINE-20250819	\N	\N	584	1	241	valide	2025-11-14 07:25:37	\N
1230	Achat legumes	0.00	23700.00	CANTINE-20250819	\N	\N	584	1	236	valide	2025-11-14 07:25:37	\N
1231	Ecolage divers élèves	0.00	1690000.00	ECOL-20250820	\N	\N	585	1	193	valide	2025-11-14 07:25:37	\N
1232	Ecolage divers élèves	1690000.00	0.00	ECOL-20250820	\N	\N	585	1	236	valide	2025-11-14 07:25:37	\N
1233	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20250825	\N	\N	586	1	238	valide	2025-11-14 07:25:37	\N
1234	Paiement salaire gardien	180000.00	0.00	SALAIRE-20250825	\N	\N	586	1	239	valide	2025-11-14 07:25:37	\N
1235	Paiement femme de ménage	150000.00	0.00	SALAIRE-20250825	\N	\N	586	1	240	valide	2025-11-14 07:25:37	\N
1236	Paiement salaires	0.00	580000.00	SALAIRE-20250825	\N	\N	586	1	236	valide	2025-11-14 07:25:37	\N
1237	Jirama	43800.00	0.00	JIRAMA-20250827	\N	\N	587	1	99	valide	2025-11-14 07:25:37	\N
1238	Jirama	0.00	43800.00	JIRAMA-20250827	\N	\N	587	1	236	valide	2025-11-14 07:25:37	\N
1239	Achat fournitures pédagogiques	145000.00	0.00	FOURN-20250829	\N	\N	588	1	106	valide	2025-11-14 07:25:37	\N
1240	Achat fournitures pédagogiques	0.00	145000.00	FOURN-20250829	\N	\N	588	1	40	valide	2025-11-14 07:25:37	\N
1241	Règlement fournisseur	145000.00	0.00	REG-FOURN-20250831	\N	\N	589	1	40	valide	2025-11-14 07:25:37	\N
1242	Règlement fournisseur	0.00	145000.00	REG-FOURN-20250831	\N	\N	589	1	236	valide	2025-11-14 07:25:37	\N
1243	Achat legumes	23600.00	0.00	CANTINE-20250901	\N	\N	590	1	241	valide	2025-11-14 07:25:37	\N
1244	Achat legumes	0.00	23600.00	CANTINE-20250901	\N	\N	590	1	236	valide	2025-11-14 07:25:37	\N
1245	Achat viande	26600.00	0.00	CANTINE-20250902	\N	\N	591	1	242	valide	2025-11-14 07:25:37	\N
1246	Achat viande	0.00	26600.00	CANTINE-20250902	\N	\N	591	1	236	valide	2025-11-14 07:25:37	\N
1247	Achat gouter	13300.00	0.00	CANTINE-20250903	\N	\N	592	1	243	valide	2025-11-14 07:25:37	\N
1248	Achat gouter	0.00	13300.00	CANTINE-20250903	\N	\N	592	1	236	valide	2025-11-14 07:25:37	\N
1249	Achat legumes	23900.00	0.00	CANTINE-20250904	\N	\N	593	1	241	valide	2025-11-14 07:25:37	\N
1251	Achat viande	26900.00	0.00	CANTINE-20250905	\N	\N	594	1	242	valide	2025-11-14 07:25:37	\N
1252	Achat viande	0.00	26900.00	CANTINE-20250905	\N	\N	594	1	236	valide	2025-11-14 07:25:37	\N
1253	Achat gouter	13500.00	0.00	CANTINE-20250908	\N	\N	595	1	243	valide	2025-11-14 07:25:37	\N
1254	Achat gouter	0.00	13500.00	CANTINE-20250908	\N	\N	595	1	236	valide	2025-11-14 07:25:37	\N
1255	Achat legumes	24200.00	0.00	CANTINE-20250909	\N	\N	596	1	241	valide	2025-11-14 07:25:37	\N
1256	Achat legumes	0.00	24200.00	CANTINE-20250909	\N	\N	596	1	236	valide	2025-11-14 07:25:37	\N
1257	Achat viande	27200.00	0.00	CANTINE-20250910	\N	\N	597	1	242	valide	2025-11-14 07:25:37	\N
1258	Achat viande	0.00	27200.00	CANTINE-20250910	\N	\N	597	1	236	valide	2025-11-14 07:25:37	\N
1259	Achat gouter	13700.00	0.00	CANTINE-20250911	\N	\N	598	1	243	valide	2025-11-14 07:25:37	\N
1260	Achat gouter	0.00	13700.00	CANTINE-20250911	\N	\N	598	1	236	valide	2025-11-14 07:25:37	\N
1261	Achat legumes	24500.00	0.00	CANTINE-20250912	\N	\N	599	1	241	valide	2025-11-14 07:25:37	\N
1262	Achat legumes	0.00	24500.00	CANTINE-20250912	\N	\N	599	1	236	valide	2025-11-14 07:25:37	\N
1263	Achat viande	27500.00	0.00	CANTINE-20250915	\N	\N	600	1	242	valide	2025-11-14 07:25:37	\N
1264	Achat viande	0.00	27500.00	CANTINE-20250915	\N	\N	600	1	236	valide	2025-11-14 07:25:37	\N
1265	Achat gouter	13900.00	0.00	CANTINE-20250916	\N	\N	601	1	243	valide	2025-11-14 07:25:37	\N
1266	Achat gouter	0.00	13900.00	CANTINE-20250916	\N	\N	601	1	236	valide	2025-11-14 07:25:37	\N
1267	Achat legumes	24800.00	0.00	CANTINE-20250917	\N	\N	602	1	241	valide	2025-11-14 07:25:37	\N
1268	Achat legumes	0.00	24800.00	CANTINE-20250917	\N	\N	602	1	236	valide	2025-11-14 07:25:37	\N
1269	Achat viande	27800.00	0.00	CANTINE-20250918	\N	\N	603	1	242	valide	2025-11-14 07:25:37	\N
1270	Achat viande	0.00	27800.00	CANTINE-20250918	\N	\N	603	1	236	valide	2025-11-14 07:25:37	\N
1271	Achat gouter	14100.00	0.00	CANTINE-20250919	\N	\N	604	1	243	valide	2025-11-14 07:25:37	\N
1272	Achat gouter	0.00	14100.00	CANTINE-20250919	\N	\N	604	1	236	valide	2025-11-14 07:25:37	\N
1273	Achat legumes	25100.00	0.00	CANTINE-20250922	\N	\N	605	1	241	valide	2025-11-14 07:25:37	\N
1274	Achat legumes	0.00	25100.00	CANTINE-20250922	\N	\N	605	1	236	valide	2025-11-14 07:25:37	\N
1275	Achat viande	28100.00	0.00	CANTINE-20250923	\N	\N	606	1	242	valide	2025-11-14 07:25:37	\N
1276	Achat viande	0.00	28100.00	CANTINE-20250923	\N	\N	606	1	236	valide	2025-11-14 07:25:37	\N
1277	Achat gouter	14300.00	0.00	CANTINE-20250924	\N	\N	607	1	243	valide	2025-11-14 07:25:37	\N
1278	Achat gouter	0.00	14300.00	CANTINE-20250924	\N	\N	607	1	236	valide	2025-11-14 07:25:37	\N
1279	Achat legumes	25400.00	0.00	CANTINE-20250925	\N	\N	608	1	241	valide	2025-11-14 07:25:37	\N
1280	Achat legumes	0.00	25400.00	CANTINE-20250925	\N	\N	608	1	236	valide	2025-11-14 07:25:37	\N
1281	Achat viande	28400.00	0.00	CANTINE-20250926	\N	\N	609	1	242	valide	2025-11-14 07:25:37	\N
1282	Achat viande	0.00	28400.00	CANTINE-20250926	\N	\N	609	1	236	valide	2025-11-14 07:25:37	\N
1283	Achat gouter	14500.00	0.00	CANTINE-20250929	\N	\N	610	1	243	valide	2025-11-14 07:25:37	\N
1284	Achat gouter	0.00	14500.00	CANTINE-20250929	\N	\N	610	1	236	valide	2025-11-14 07:25:37	\N
1285	Echeancier pret bancaire	1150000.00	0.00	PRET-20250930	\N	\N	611	1	244	valide	2025-11-14 07:25:37	\N
1287	Ecolage divers élèves	0.00	1710000.00	ECOL-20250930	\N	\N	612	1	193	valide	2025-11-14 07:25:37	\N
1288	Ecolage divers élèves	1710000.00	0.00	ECOL-20250930	\N	\N	612	1	236	valide	2025-11-14 07:25:37	\N
1289	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20251002	\N	\N	613	1	238	valide	2025-11-14 07:25:37	\N
1290	Paiement salaire gardien	180000.00	0.00	SALAIRE-20251002	\N	\N	613	1	239	valide	2025-11-14 07:25:37	\N
1291	Paiement femme de ménage	150000.00	0.00	SALAIRE-20251002	\N	\N	613	1	240	valide	2025-11-14 07:25:37	\N
1292	Paiement salaires	0.00	580000.00	SALAIRE-20251002	\N	\N	613	1	236	valide	2025-11-14 07:25:37	\N
1293	Jirama	45200.00	0.00	JIRAMA-20251004	\N	\N	614	1	99	valide	2025-11-14 07:25:37	\N
1294	Jirama	0.00	45200.00	JIRAMA-20251004	\N	\N	614	1	236	valide	2025-11-14 07:25:37	\N
1295	Achat fournitures scolaires	148000.00	0.00	FOURN-20251006	\N	\N	615	1	79	valide	2025-11-14 07:25:37	\N
1296	Achat fournitures scolaires	0.00	148000.00	FOURN-20251006	\N	\N	615	1	40	valide	2025-11-14 07:25:37	\N
1297	Règlement fournisseur	148000.00	0.00	REG-FOURN-20251008	\N	\N	616	1	40	valide	2025-11-14 07:25:37	\N
1298	Règlement fournisseur	0.00	148000.00	REG-FOURN-20251008	\N	\N	616	1	236	valide	2025-11-14 07:25:37	\N
1299	Achat legumes	25300.00	0.00	CANTINE-20251009	\N	\N	617	1	241	valide	2025-11-14 07:25:37	\N
1300	Achat legumes	0.00	25300.00	CANTINE-20251009	\N	\N	617	1	236	valide	2025-11-14 07:25:37	\N
1301	Achat viande	28300.00	0.00	CANTINE-20251010	\N	\N	618	1	242	valide	2025-11-14 07:25:37	\N
1302	Achat viande	0.00	28300.00	CANTINE-20251010	\N	\N	618	1	236	valide	2025-11-14 07:25:37	\N
1303	Achat gouter	14700.00	0.00	CANTINE-20251013	\N	\N	619	1	243	valide	2025-11-14 07:25:37	\N
1304	Achat gouter	0.00	14700.00	CANTINE-20251013	\N	\N	619	1	236	valide	2025-11-14 07:25:37	\N
1305	Achat legumes	25600.00	0.00	CANTINE-20251014	\N	\N	620	1	241	valide	2025-11-14 07:25:37	\N
1306	Achat legumes	0.00	25600.00	CANTINE-20251014	\N	\N	620	1	236	valide	2025-11-14 07:25:37	\N
1307	Achat viande	28600.00	0.00	CANTINE-20251015	\N	\N	621	1	242	valide	2025-11-14 07:25:37	\N
1308	Achat viande	0.00	28600.00	CANTINE-20251015	\N	\N	621	1	236	valide	2025-11-14 07:25:37	\N
1309	Achat gouter	14900.00	0.00	CANTINE-20251016	\N	\N	622	1	243	valide	2025-11-14 07:25:37	\N
1310	Achat gouter	0.00	14900.00	CANTINE-20251016	\N	\N	622	1	236	valide	2025-11-14 07:25:37	\N
1311	Achat legumes	25900.00	0.00	CANTINE-20251017	\N	\N	623	1	241	valide	2025-11-14 07:25:37	\N
1312	Achat legumes	0.00	25900.00	CANTINE-20251017	\N	\N	623	1	236	valide	2025-11-14 07:25:37	\N
1313	Versement en banque BMOI	190000.00	0.00	VERS201025	\N	\N	624	1	53	valide	2025-11-14 07:25:37	\N
1314	Versement en banque BMOI	0.00	190000.00	VERS201025	\N	\N	624	1	236	valide	2025-11-14 07:25:37	\N
1315	Achat viande	28900.00	0.00	CANTINE-20251020	\N	\N	625	1	242	valide	2025-11-14 07:25:37	\N
1316	Achat viande	0.00	28900.00	CANTINE-20251020	\N	\N	625	1	236	valide	2025-11-14 07:25:37	\N
1317	Achat gouter	15100.00	0.00	CANTINE-20251021	\N	\N	626	1	243	valide	2025-11-14 07:25:37	\N
1318	Achat gouter	0.00	15100.00	CANTINE-20251021	\N	\N	626	1	236	valide	2025-11-14 07:25:37	\N
1319	Ecolage divers élèves	0.00	1730000.00	ECOL-20251022	\N	\N	627	1	193	valide	2025-11-14 07:25:37	\N
1320	Ecolage divers élèves	1730000.00	0.00	ECOL-20251022	\N	\N	627	1	236	valide	2025-11-14 07:25:37	\N
1321	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20251027	\N	\N	628	1	238	valide	2025-11-14 07:25:37	\N
1322	Paiement salaire gardien	180000.00	0.00	SALAIRE-20251027	\N	\N	628	1	239	valide	2025-11-14 07:25:37	\N
1323	Paiement femme de ménage	150000.00	0.00	SALAIRE-20251027	\N	\N	628	1	240	valide	2025-11-14 07:25:37	\N
1324	Paiement salaires	0.00	580000.00	SALAIRE-20251027	\N	\N	628	1	236	valide	2025-11-14 07:25:37	\N
1325	Jirama	46500.00	0.00	JIRAMA-20251029	\N	\N	629	1	99	valide	2025-11-14 07:25:37	\N
1326	Jirama	0.00	46500.00	JIRAMA-20251029	\N	\N	629	1	236	valide	2025-11-14 07:25:37	\N
1327	Achat fournitures bureau	152000.00	0.00	FOURN-20251031	\N	\N	630	1	105	valide	2025-11-14 07:25:37	\N
1328	Achat fournitures bureau	0.00	152000.00	FOURN-20251031	\N	\N	630	1	40	valide	2025-11-14 07:25:37	\N
1329	Règlement fournisseur	152000.00	0.00	REG-FOURN-20251102	\N	\N	631	1	40	valide	2025-11-14 07:25:37	\N
1330	Règlement fournisseur	0.00	152000.00	REG-FOURN-20251102	\N	\N	631	1	236	valide	2025-11-14 07:25:37	\N
1331	Achat legumes	26000.00	0.00	CANTINE-20251103	\N	\N	632	1	241	valide	2025-11-14 07:25:37	\N
1332	Achat legumes	0.00	26000.00	CANTINE-20251103	\N	\N	632	1	236	valide	2025-11-14 07:25:37	\N
1333	Achat viande	29000.00	0.00	CANTINE-20251104	\N	\N	633	1	242	valide	2025-11-14 07:25:37	\N
1334	Achat viande	0.00	29000.00	CANTINE-20251104	\N	\N	633	1	236	valide	2025-11-14 07:25:37	\N
1335	Achat gouter	15300.00	0.00	CANTINE-20251105	\N	\N	634	1	243	valide	2025-11-14 07:25:37	\N
1336	Achat gouter	0.00	15300.00	CANTINE-20251105	\N	\N	634	1	236	valide	2025-11-14 07:25:37	\N
1337	Achat legumes	26300.00	0.00	CANTINE-20251106	\N	\N	635	1	241	valide	2025-11-14 07:25:37	\N
1338	Achat legumes	0.00	26300.00	CANTINE-20251106	\N	\N	635	1	236	valide	2025-11-14 07:25:37	\N
1339	Achat viande	29300.00	0.00	CANTINE-20251107	\N	\N	636	1	242	valide	2025-11-14 07:25:37	\N
1340	Achat viande	0.00	29300.00	CANTINE-20251107	\N	\N	636	1	236	valide	2025-11-14 07:25:37	\N
1341	Achat gouter	15500.00	0.00	CANTINE-20251110	\N	\N	637	1	243	valide	2025-11-14 07:25:37	\N
1342	Achat gouter	0.00	15500.00	CANTINE-20251110	\N	\N	637	1	236	valide	2025-11-14 07:25:37	\N
1343	Achat legumes	26600.00	0.00	CANTINE-20251111	\N	\N	638	1	241	valide	2025-11-14 07:25:37	\N
1344	Achat legumes	0.00	26600.00	CANTINE-20251111	\N	\N	638	1	236	valide	2025-11-14 07:25:37	\N
1345	Achat viande	29600.00	0.00	CANTINE-20251112	\N	\N	639	1	242	valide	2025-11-14 07:25:37	\N
1346	Achat viande	0.00	29600.00	CANTINE-20251112	\N	\N	639	1	236	valide	2025-11-14 07:25:37	\N
1347	Achat gouter	15700.00	0.00	CANTINE-20251113	\N	\N	640	1	243	valide	2025-11-14 07:25:37	\N
1348	Achat gouter	0.00	15700.00	CANTINE-20251113	\N	\N	640	1	236	valide	2025-11-14 07:25:37	\N
1349	Achat legumes	26900.00	0.00	CANTINE-20251114	\N	\N	641	1	241	valide	2025-11-14 07:25:37	\N
1350	Achat legumes	0.00	26900.00	CANTINE-20251114	\N	\N	641	1	236	valide	2025-11-14 07:25:37	\N
1351	Appro caisse via BMOI	0.00	2600000.00	APPRO-20251115	\N	\N	642	1	53	valide	2025-11-14 07:25:37	\N
1352	Appro caisse via BMOI	2600000.00	0.00	APPRO-20251115	\N	\N	642	1	236	valide	2025-11-14 07:25:37	\N
1353	Achat viande	29900.00	0.00	CANTINE-20251117	\N	\N	643	1	242	valide	2025-11-14 07:25:37	\N
1354	Achat viande	0.00	29900.00	CANTINE-20251117	\N	\N	643	1	236	valide	2025-11-14 07:25:37	\N
1355	Achat gouter	15900.00	0.00	CANTINE-20251118	\N	\N	644	1	243	valide	2025-11-14 07:25:37	\N
1356	Achat gouter	0.00	15900.00	CANTINE-20251118	\N	\N	644	1	236	valide	2025-11-14 07:25:37	\N
1357	Achat legumes	27200.00	0.00	CANTINE-20251119	\N	\N	645	1	241	valide	2025-11-14 07:25:37	\N
1358	Achat legumes	0.00	27200.00	CANTINE-20251119	\N	\N	645	1	236	valide	2025-11-14 07:25:37	\N
1359	Ecolage divers élèves	0.00	1750000.00	ECOL-20251120	\N	\N	646	1	193	valide	2025-11-14 07:25:37	\N
1360	Ecolage divers élèves	1750000.00	0.00	ECOL-20251120	\N	\N	646	1	236	valide	2025-11-14 07:25:37	\N
1361	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20251125	\N	\N	647	1	238	valide	2025-11-14 07:25:37	\N
1362	Paiement salaire gardien	180000.00	0.00	SALAIRE-20251125	\N	\N	647	1	239	valide	2025-11-14 07:25:37	\N
1363	Paiement femme de ménage	150000.00	0.00	SALAIRE-20251125	\N	\N	647	1	240	valide	2025-11-14 07:25:37	\N
1364	Paiement salaires	0.00	580000.00	SALAIRE-20251125	\N	\N	647	1	236	valide	2025-11-14 07:25:37	\N
1365	Jirama	47800.00	0.00	JIRAMA-20251127	\N	\N	648	1	99	valide	2025-11-14 07:25:37	\N
1366	Jirama	0.00	47800.00	JIRAMA-20251127	\N	\N	648	1	236	valide	2025-11-14 07:25:37	\N
1367	Achat matériel éducatif	155000.00	0.00	FOURN-20251128	\N	\N	649	1	97	valide	2025-11-14 07:25:37	\N
1368	Achat matériel éducatif	0.00	155000.00	FOURN-20251128	\N	\N	649	1	40	valide	2025-11-14 07:25:37	\N
1369	Règlement fournisseur	155000.00	0.00	REG-FOURN-20251130	\N	\N	650	1	40	valide	2025-11-14 07:25:37	\N
1370	Règlement fournisseur	0.00	155000.00	REG-FOURN-20251130	\N	\N	650	1	236	valide	2025-11-14 07:25:37	\N
1371	Achat legumes	27100.00	0.00	CANTINE-20251201	\N	\N	651	1	241	valide	2025-11-14 07:25:37	\N
1372	Achat legumes	0.00	27100.00	CANTINE-20251201	\N	\N	651	1	236	valide	2025-11-14 07:25:37	\N
1373	Achat viande	30100.00	0.00	CANTINE-20251202	\N	\N	652	1	242	valide	2025-11-14 07:25:37	\N
1374	Achat viande	0.00	30100.00	CANTINE-20251202	\N	\N	652	1	236	valide	2025-11-14 07:25:37	\N
1376	Achat gouter	0.00	16100.00	CANTINE-20251203	\N	\N	653	1	236	valide	2025-11-14 07:25:37	\N
1377	Achat legumes	27400.00	0.00	CANTINE-20251204	\N	\N	654	1	241	valide	2025-11-14 07:25:37	\N
1378	Achat legumes	0.00	27400.00	CANTINE-20251204	\N	\N	654	1	236	valide	2025-11-14 07:25:37	\N
1379	Achat viande	30400.00	0.00	CANTINE-20251205	\N	\N	655	1	242	valide	2025-11-14 07:25:37	\N
1380	Achat viande	0.00	30400.00	CANTINE-20251205	\N	\N	655	1	236	valide	2025-11-14 07:25:37	\N
1381	Achat gouter	16300.00	0.00	CANTINE-20251208	\N	\N	656	1	243	valide	2025-11-14 07:25:37	\N
1382	Achat gouter	0.00	16300.00	CANTINE-20251208	\N	\N	656	1	236	valide	2025-11-14 07:25:37	\N
1383	Achat legumes	27700.00	0.00	CANTINE-20251209	\N	\N	657	1	241	valide	2025-11-14 07:25:37	\N
1384	Achat legumes	0.00	27700.00	CANTINE-20251209	\N	\N	657	1	236	valide	2025-11-14 07:25:37	\N
1385	Achat viande	30700.00	0.00	CANTINE-20251210	\N	\N	658	1	242	valide	2025-11-14 07:25:37	\N
1386	Achat viande	0.00	30700.00	CANTINE-20251210	\N	\N	658	1	236	valide	2025-11-14 07:25:37	\N
1387	Achat gouter	16500.00	0.00	CANTINE-20251211	\N	\N	659	1	243	valide	2025-11-14 07:25:37	\N
1388	Achat gouter	0.00	16500.00	CANTINE-20251211	\N	\N	659	1	236	valide	2025-11-14 07:25:37	\N
1389	Achat legumes	28000.00	0.00	CANTINE-20251212	\N	\N	660	1	241	valide	2025-11-14 07:25:37	\N
1390	Achat legumes	0.00	28000.00	CANTINE-20251212	\N	\N	660	1	236	valide	2025-11-14 07:25:37	\N
1391	Achat viande	31000.00	0.00	CANTINE-20251215	\N	\N	661	1	242	valide	2025-11-14 07:25:37	\N
1392	Achat viande	0.00	31000.00	CANTINE-20251215	\N	\N	661	1	236	valide	2025-11-14 07:25:37	\N
1393	Achat gouter	16700.00	0.00	CANTINE-20251216	\N	\N	662	1	243	valide	2025-11-14 07:25:37	\N
1394	Achat gouter	0.00	16700.00	CANTINE-20251216	\N	\N	662	1	236	valide	2025-11-14 07:25:37	\N
1395	Achat legumes	28300.00	0.00	CANTINE-20251217	\N	\N	663	1	241	valide	2025-11-14 07:25:37	\N
1396	Achat legumes	0.00	28300.00	CANTINE-20251217	\N	\N	663	1	236	valide	2025-11-14 07:25:37	\N
1397	Achat viande	31300.00	0.00	CANTINE-20251218	\N	\N	664	1	242	valide	2025-11-14 07:25:37	\N
1398	Achat viande	0.00	31300.00	CANTINE-20251218	\N	\N	664	1	236	valide	2025-11-14 07:25:37	\N
1399	Achat gouter	16900.00	0.00	CANTINE-20251219	\N	\N	665	1	243	valide	2025-11-14 07:25:37	\N
1400	Achat gouter	0.00	16900.00	CANTINE-20251219	\N	\N	665	1	236	valide	2025-11-14 07:25:37	\N
1401	Ecolage divers élèves	0.00	1770000.00	ECOL-20251222	\N	\N	666	1	193	valide	2025-11-14 07:25:37	\N
1402	Ecolage divers élèves	1770000.00	0.00	ECOL-20251222	\N	\N	666	1	236	valide	2025-11-14 07:25:37	\N
1403	Paiement salaire maitresse	250000.00	0.00	SALAIRE-20251226	\N	\N	667	1	238	valide	2025-11-14 07:25:37	\N
1404	Paiement salaire gardien	180000.00	0.00	SALAIRE-20251226	\N	\N	667	1	239	valide	2025-11-14 07:25:37	\N
1405	Paiement femme de ménage	150000.00	0.00	SALAIRE-20251226	\N	\N	667	1	240	valide	2025-11-14 07:25:37	\N
1406	Paiement salaires	0.00	580000.00	SALAIRE-20251226	\N	\N	667	1	236	valide	2025-11-14 07:25:37	\N
1407	Jirama	49200.00	0.00	JIRAMA-20251228	\N	\N	668	1	99	valide	2025-11-14 07:25:37	\N
1408	Jirama	0.00	49200.00	JIRAMA-20251228	\N	\N	668	1	236	valide	2025-11-14 07:25:37	\N
1409	Achat fournitures pédagogiques	158000.00	0.00	FOURN-20251230	\N	\N	669	1	106	valide	2025-11-14 07:25:37	\N
1410	Achat fournitures pédagogiques	0.00	158000.00	FOURN-20251230	\N	\N	669	1	40	valide	2025-11-14 07:25:37	\N
1411	Règlement fournisseur	158000.00	0.00	REG-FOURN-20251231	\N	\N	670	1	40	valide	2025-11-14 07:25:37	\N
1412	Règlement fournisseur	0.00	158000.00	REG-FOURN-20251231	\N	\N	670	1	236	valide	2025-11-14 07:25:37	\N
1413	Echeancier pret bancaire	0.00	1150000.00	\N	1	\N	611	1	53	valide	2025-11-14 07:25:37	\N
\.


--
-- Data for Name: migrations; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.migrations (id, migration, batch) FROM stdin;
12	0001_01_01_000000_create_users_table	1
13	0001_01_01_000001_create_cache_table	1
14	0001_01_01_000002_create_jobs_table	1
15	2025_09_08_075701_create_password_resets_table	1
16	2025_09_08_115513_create_email_verifications_table	1
17	2025_09_09_094927_create_personal_access_tokens_table	1
18	2025_09_11_082029_create_errors_table	1
19	2025_09_18_071646_create_classes_table	1
20	2025_09_18_071805_create_rubriques_table	1
21	2025_09_18_071835_create_comptes_table	1
22	2025_09_18_071840_create_sous_comptes_table	1
23	2025_09_23_084431_create_type_journals_table	2
24	2025_09_23_084539_create_mode_paiements_table	2
25	2025_09_23_084545_create_journals_table	2
26	2025_09_23_084553_create_mouvement_ecritures_table	2
27	2025_09_23_084559_create_ligne_ecritures_table	2
28	2025_09_23_105218_create_devises_table	3
29	2025_09_24_092427_create_typecentre_table	3
30	2025_09_24_092619_create_axesanalytique_table	3
31	2025_09_24_092855_create_centreanalytique_table	3
32	2025_09_24_093302_create_affectationanalytique_table	3
33	2025_09_23_084601_create_mouvement_ecritures_table	4
34	2025_09_23_084602_create_ligne_ecritures_table	4
35	2025_09_30_135057_add_validation_fields_to_ligne_ecriture_table	5
36	2025_10_07_052322_update_affectationanalytique_add_taux_and_drop_unique	6
37	2025_10_11_145106_add_id_type_to_affectation_analytique	7
38	2025_10_11_145148_remove_id_type_from_centre_analytique	7
39	2025_10_13_182649_create_exercice_comptable_table	8
40	2025_10_14_071048_create_nature_comptables_table	9
41	2025_10_14_071048_create_type_categories_table	9
42	2025_10_14_071048_create_durees_table	10
43	2025_10_14_071049_create_fonction_economiques_table	11
44	2025_10_14_071049_create_categorie_fonctionelles_table	12
45	2025_10_14_071050_create_compte_categories_table	13
46	2025_10_14_101149_create_categorie_fonctionelles_table	14
47	2025_10_21_171026_create_import_histories_table	15
48	2025_10_23_070932_create_indicateurs_analytique_table	16
49	2025_10_23_071019_create_niveau_alerte_table	17
50	2025_10_23_071026_create_interpretation_indicateur_table	18
51	2025_10_28_183111_create_taux_amortissement_table	19
53	2025_10_28_173608_create_amortissements_table	20
54	2025_10_30_074406_create_chat_messages_table	21
55	2025_11_01_164841_create_code_analytique_table	22
56	2025_11_01_165105_add_id_code_to_affectationanalytique_table	23
57	2025_11_02_104707_create_niveaux_urgence_table	24
58	2025_11_02_104707_create_types_evenement_table	25
59	2025_11_02_104708_create_evenements_table	26
60	2025_11_02_104712_create_notifications_table	27
\.


--
-- Data for Name: mode_paiements; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mode_paiements ("Id_Mode_paiement", "Libelle", "Abr") FROM stdin;
1	Cheque	CQ
\.


--
-- Data for Name: mouvement_ecritures; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.mouvement_ecritures ("Id_Mouvement_ecriture", "Date_mouvement", "Numero_piece", "Id_Journal") FROM stdin;
1	2023-01-03	BNI2023-0001	1
2	2023-01-04	BNI2023-0002	1
3	2023-01-05	BNI2023-0003	1
4	2023-01-06	BNI2023-0004	1
5	2023-01-09	BNI2023-0005	1
6	2023-01-10	BNI2023-0006	1
7	2023-01-11	BNI2023-0007	1
8	2023-01-12	BNI2023-0008	1
9	2023-01-13	BNI2023-0009	1
10	2023-01-16	BNI2023-0010	1
11	2023-01-17	BNI2023-0011	1
12	2023-01-18	BNI2023-0012	1
13	2023-01-19	BNI2023-0013	1
14	2023-01-20	BNI2023-0014	1
15	2023-01-23	BNI2023-0015	1
16	2023-01-25	BNI2023-0016	1
17	2023-01-30	BNI2023-0017	1
18	2023-01-31	BNI2023-0018	1
19	2023-02-01	BNI2023-0019	1
20	2023-02-02	BNI2023-0020	1
21	2023-02-03	BNI2023-0021	1
22	2023-02-06	BNI2023-0022	1
23	2023-02-07	BNI2023-0023	1
24	2023-02-08	BNI2023-0024	1
25	2023-02-09	BNI2023-0025	1
26	2023-02-10	BNI2023-0026	1
27	2023-02-13	BNI2023-0027	1
28	2023-02-14	BNI2023-0028	1
29	2023-02-15	BNI2023-0029	1
30	2023-02-16	BNI2023-0030	1
31	2023-02-17	BNI2023-0031	1
32	2023-02-20	BNI2023-0032	1
33	2023-02-23	BNI2023-0033	1
34	2023-02-25	BNI2023-0034	1
35	2023-02-28	BNI2023-0035	1
36	2023-03-02	BNI2023-0036	1
37	2023-03-01	BNI2023-0037	1
38	2023-03-02	BNI2023-0038	1
39	2023-03-03	BNI2023-0039	1
40	2023-03-06	BNI2023-0040	1
41	2023-03-07	BNI2023-0041	1
42	2023-03-08	BNI2023-0042	1
43	2023-03-09	BNI2023-0043	1
44	2023-03-10	BNI2023-0044	1
45	2023-03-13	BNI2023-0045	1
46	2023-03-14	BNI2023-0046	1
47	2023-03-15	BNI2023-0047	1
48	2023-03-16	BNI2023-0048	1
49	2023-03-17	BNI2023-0049	1
50	2023-03-20	BNI2023-0050	1
51	2023-03-23	BNI2023-0051	1
52	2023-03-25	BNI2023-0052	1
53	2023-03-29	BNI2023-0053	1
54	2023-03-31	BNI2023-0054	1
55	2023-04-03	BNI2023-0055	1
56	2023-04-04	BNI2023-0056	1
57	2023-04-05	BNI2023-0057	1
58	2023-04-06	BNI2023-0058	1
59	2023-04-07	BNI2023-0059	1
60	2023-04-10	BNI2023-0060	1
61	2023-04-11	BNI2023-0061	1
62	2023-04-12	BNI2023-0062	1
63	2023-04-13	BNI2023-0063	1
64	2023-04-14	BNI2023-0064	1
65	2023-04-17	BNI2023-0065	1
66	2023-04-18	BNI2023-0066	1
67	2023-04-20	BNI2023-0067	1
68	2023-04-24	BNI2023-0068	1
69	2023-04-25	BNI2023-0069	1
70	2023-04-28	BNI2023-0070	1
71	2023-04-30	BNI2023-0071	1
72	2023-05-02	BNI2023-0072	1
73	2023-05-03	BNI2023-0073	1
74	2023-05-04	BNI2023-0074	1
75	2023-05-05	BNI2023-0075	1
76	2023-05-08	BNI2023-0076	1
77	2023-05-09	BNI2023-0077	1
78	2023-05-10	BNI2023-0078	1
79	2023-05-11	BNI2023-0079	1
80	2023-05-12	BNI2023-0080	1
81	2023-05-15	BNI2023-0081	1
82	2023-05-16	BNI2023-0082	1
83	2023-05-17	BNI2023-0083	1
84	2023-05-20	BNI2023-0084	1
85	2023-05-23	BNI2023-0085	1
86	2023-05-25	BNI2023-0086	1
87	2023-05-29	BNI2023-0087	1
88	2023-05-31	BNI2023-0088	1
89	2023-06-01	BNI2023-0089	1
90	2023-06-02	BNI2023-0090	1
91	2023-06-05	BNI2023-0091	1
92	2023-06-06	BNI2023-0092	1
93	2023-06-07	BNI2023-0093	1
94	2023-06-08	BNI2023-0094	1
95	2023-06-09	BNI2023-0095	1
96	2023-06-12	BNI2023-0096	1
97	2023-06-13	BNI2023-0097	1
98	2023-06-14	BNI2023-0098	1
99	2023-06-15	BNI2023-0099	1
100	2023-06-16	BNI2023-0100	1
101	2023-06-20	BNI2023-0101	1
102	2023-06-23	BNI2023-0102	1
103	2023-06-25	BNI2023-0103	1
104	2023-06-28	BNI2023-0104	1
105	2023-06-30	BNI2023-0105	1
106	2023-07-03	BNI2023-0106	1
107	2023-07-04	BNI2023-0107	1
108	2023-07-05	BNI2023-0108	1
109	2023-07-06	BNI2023-0109	1
110	2023-07-07	BNI2023-0110	1
111	2023-07-10	BNI2023-0111	1
112	2023-07-11	BNI2023-0112	1
113	2023-07-12	BNI2023-0113	1
114	2023-07-13	BNI2023-0114	1
115	2023-07-14	BNI2023-0115	1
116	2023-07-17	BNI2023-0116	1
117	2023-07-18	BNI2023-0117	1
118	2023-07-20	BNI2023-0118	1
119	2023-07-24	BNI2023-0119	1
120	2023-07-25	BNI2023-0120	1
121	2023-07-28	BNI2023-0121	1
122	2023-07-31	BNI2023-0122	1
123	2023-08-01	BNI2023-0123	1
124	2023-08-02	BNI2023-0124	1
125	2023-08-03	BNI2023-0125	1
126	2023-08-04	BNI2023-0126	1
127	2023-08-07	BNI2023-0127	1
128	2023-08-08	BNI2023-0128	1
129	2023-08-09	BNI2023-0129	1
130	2023-08-10	BNI2023-0130	1
131	2023-08-11	BNI2023-0131	1
132	2023-08-14	BNI2023-0132	1
133	2023-08-15	BNI2023-0133	1
134	2023-08-16	BNI2023-0134	1
135	2023-08-20	BNI2023-0135	1
136	2023-08-23	BNI2023-0136	1
137	2023-08-25	BNI2023-0137	1
138	2023-08-29	BNI2023-0138	1
139	2023-08-31	BNI2023-0139	1
140	2023-09-01	BNI2023-0140	1
141	2023-09-04	BNI2023-0141	1
142	2023-09-05	BNI2023-0142	1
143	2023-09-06	BNI2023-0143	1
144	2023-09-07	BNI2023-0144	1
145	2023-09-08	BNI2023-0145	1
146	2023-09-11	BNI2023-0146	1
147	2023-09-12	BNI2023-0147	1
148	2023-09-13	BNI2023-0148	1
149	2023-09-14	BNI2023-0149	1
150	2023-09-15	BNI2023-0150	1
151	2023-09-18	BNI2023-0151	1
152	2023-09-20	BNI2023-0152	1
153	2023-09-25	BNI2023-0153	1
154	2023-09-26	BNI2023-0154	1
155	2023-09-28	BNI2023-0155	1
156	2023-09-30	BNI2023-0156	1
157	2023-10-02	BNI2023-0157	1
158	2023-10-03	BNI2023-0158	1
159	2023-10-04	BNI2023-0159	1
160	2023-10-05	BNI2023-0160	1
161	2023-10-06	BNI2023-0161	1
162	2023-10-09	BNI2023-0162	1
163	2023-10-10	BNI2023-0163	1
164	2023-10-11	BNI2023-0164	1
165	2023-10-12	BNI2023-0165	1
166	2023-10-13	BNI2023-0166	1
167	2023-10-16	BNI2023-0167	1
168	2023-10-17	BNI2023-0168	1
169	2023-10-20	BNI2023-0169	1
170	2023-10-24	BNI2023-0170	1
171	2023-10-25	BNI2023-0171	1
172	2023-10-27	BNI2023-0172	1
173	2023-10-31	BNI2023-0173	1
174	2023-11-01	BNI2023-0174	1
175	2023-11-02	BNI2023-0175	1
176	2023-11-03	BNI2023-0176	1
177	2023-11-06	BNI2023-0177	1
178	2023-11-07	BNI2023-0178	1
179	2023-11-08	BNI2023-0179	1
180	2023-11-09	BNI2023-0180	1
181	2023-11-10	BNI2023-0181	1
182	2023-11-13	BNI2023-0182	1
183	2023-11-14	BNI2023-0183	1
184	2023-11-15	BNI2023-0184	1
185	2023-11-16	BNI2023-0185	1
186	2023-11-17	BNI2023-0186	1
187	2023-11-20	BNI2023-0187	1
188	2023-11-24	BNI2023-0188	1
189	2023-11-25	BNI2023-0189	1
190	2023-11-28	BNI2023-0190	1
191	2023-11-30	BNI2023-0191	1
192	2023-12-01	BNI2023-0192	1
193	2023-12-04	BNI2023-0193	1
194	2023-12-05	BNI2023-0194	1
195	2023-12-06	BNI2023-0195	1
196	2023-12-07	BNI2023-0196	1
197	2023-12-08	BNI2023-0197	1
198	2023-12-11	BNI2023-0198	1
199	2023-12-12	BNI2023-0199	1
200	2023-12-13	BNI2023-0200	1
201	2023-12-14	BNI2023-0201	1
202	2023-12-15	BNI2023-0202	1
203	2023-12-18	BNI2023-0203	1
204	2023-12-20	BNI2023-0204	1
205	2023-12-23	BNI2023-0205	1
206	2023-12-26	BNI2023-0206	1
207	2023-12-28	BNI2023-0207	1
208	2023-12-31	BNI2023-0208	1
209	2024-01-03	BNI2024-0001	1
210	2024-01-04	BNI2024-0210	1
211	2024-01-05	BNI2024-0211	1
212	2024-01-08	BNI2024-0212	1
213	2024-01-09	BNI2024-0213	1
214	2024-01-10	BNI2024-0214	1
215	2024-01-11	BNI2024-0215	1
216	2024-01-12	BNI2024-0216	1
217	2024-01-15	BNI2024-0217	1
218	2024-01-16	BNI2024-0218	1
219	2024-01-17	BNI2024-0219	1
220	2024-01-18	BNI2024-0220	1
221	2024-01-19	BNI2024-0221	1
222	2024-01-22	BNI2024-0222	1
223	2024-01-25	BNI2024-0223	1
224	2024-01-27	BNI2024-0224	1
225	2024-01-30	BNI2024-0225	1
226	2024-01-31	BNI2024-0226	1
227	2024-02-01	BNI2024-0227	1
228	2024-02-02	BNI2024-0228	1
229	2024-02-05	BNI2024-0229	1
230	2024-02-06	BNI2024-0230	1
231	2024-02-07	BNI2024-0231	1
232	2024-02-08	BNI2024-0232	1
233	2024-02-09	BNI2024-0233	1
234	2024-02-12	BNI2024-0234	1
235	2024-02-13	BNI2024-0235	1
236	2024-02-14	BNI2024-0236	1
237	2024-02-15	BNI2024-0237	1
238	2024-02-15	BNI2024-0238	1
239	2024-02-16	BNI2024-0239	1
240	2024-02-19	BNI2024-0240	1
241	2024-02-20	BNI2024-0241	1
242	2024-02-25	BNI2024-0242	1
243	2024-02-27	BNI2024-0243	1
244	2024-02-29	BNI2024-0244	1
245	2024-03-02	BNI2024-0245	1
246	2024-03-04	BNI2024-0246	1
247	2024-03-05	BNI2024-0247	1
248	2024-03-06	BNI2024-0248	1
249	2024-03-07	BNI2024-0249	1
250	2024-03-08	BNI2024-0250	1
251	2024-03-11	BNI2024-0251	1
252	2024-03-12	BNI2024-0252	1
253	2024-03-13	BNI2024-0253	1
254	2024-03-14	BNI2024-0254	1
255	2024-03-15	BNI2024-0255	1
256	2024-03-18	BNI2024-0256	1
257	2024-03-18	BNI2024-0257	1
258	2024-03-19	BNI2024-0258	1
259	2024-03-20	BNI2024-0259	1
260	2024-03-25	BNI2024-0260	1
261	2024-03-27	BNI2024-0261	1
262	2024-03-29	BNI2024-0262	1
263	2024-03-31	BNI2024-0263	1
264	2024-04-01	BNI2024-0264	1
265	2024-04-02	BNI2024-0265	1
266	2024-04-03	BNI2024-0266	1
267	2024-04-04	BNI2024-0267	1
268	2024-04-05	BNI2024-0268	1
269	2024-04-08	BNI2024-0269	1
270	2024-04-09	BNI2024-0270	1
271	2024-04-10	BNI2024-0271	1
272	2024-04-10	BNI2024-0272	1
273	2024-04-11	BNI2024-0273	1
274	2024-04-12	BNI2024-0274	1
275	2024-04-15	BNI2024-0275	1
276	2024-04-16	BNI2024-0276	1
277	2024-04-17	BNI2024-0277	1
278	2024-04-18	BNI2024-0278	1
279	2024-04-19	BNI2024-0279	1
280	2024-04-22	BNI2024-0280	1
281	2024-04-25	BNI2024-0281	1
282	2024-04-27	BNI2024-0282	1
283	2024-04-29	BNI2024-0283	1
284	2024-04-30	BNI2024-0284	1
285	2024-05-02	BNI2024-0285	1
286	2024-05-03	BNI2024-0286	1
287	2024-05-06	BNI2024-0287	1
288	2024-05-07	BNI2024-0288	1
289	2024-05-08	BNI2024-0289	1
290	2024-05-09	BNI2024-0290	1
291	2024-05-10	BNI2024-0291	1
292	2024-05-13	BNI2024-0292	1
293	2024-05-14	BNI2024-0293	1
294	2024-05-15	BNI2024-0294	1
295	2024-05-16	BNI2024-0295	1
296	2024-05-17	BNI2024-0296	1
297	2024-05-20	BNI2024-0297	1
298	2024-05-24	BNI2024-0298	1
299	2024-05-25	BNI2024-0299	1
300	2024-05-26	BNI2024-0300	1
301	2024-05-29	BNI2024-0301	1
302	2024-05-31	BNI2024-0302	1
303	2024-06-03	BNI2024-0303	1
304	2024-06-04	BNI2024-0304	1
305	2024-06-05	BNI2024-0305	1
306	2024-06-06	BNI2024-0306	1
307	2024-06-07	BNI2024-0307	1
308	2024-06-10	BNI2024-0308	1
309	2024-06-11	BNI2024-0309	1
310	2024-06-12	BNI2024-0310	1
311	2024-06-13	BNI2024-0311	1
312	2024-06-14	BNI2024-0312	1
313	2024-06-17	BNI2024-0313	1
314	2024-06-18	BNI2024-0314	1
315	2024-06-20	BNI2024-0315	1
316	2024-06-25	BNI2024-0316	1
317	2024-06-27	BNI2024-0317	1
318	2024-06-28	BNI2024-0318	1
319	2024-06-30	BNI2024-0319	1
320	2024-07-01	BNI2024-0320	1
321	2024-07-02	BNI2024-0321	1
322	2024-07-03	BNI2024-0322	1
323	2024-07-04	BNI2024-0323	1
324	2024-07-05	BNI2024-0324	1
325	2024-07-08	BNI2024-0325	1
326	2024-07-09	BNI2024-0326	1
327	2024-07-10	BNI2024-0327	1
328	2024-07-11	BNI2024-0328	1
329	2024-07-12	BNI2024-0329	1
330	2024-07-15	BNI2024-0330	1
331	2024-07-15	BNI2024-0331	1
332	2024-07-16	BNI2024-0332	1
333	2024-07-17	BNI2024-0333	1
334	2024-07-18	BNI2024-0334	1
335	2024-07-19	BNI2024-0335	1
336	2024-07-22	BNI2024-0336	1
337	2024-07-25	BNI2024-0337	1
338	2024-07-27	BNI2024-0338	1
339	2024-07-29	BNI2024-0339	1
340	2024-07-31	BNI2024-0340	1
341	2024-08-01	BNI2024-0341	1
342	2024-08-02	BNI2024-0342	1
343	2024-08-05	BNI2024-0343	1
344	2024-08-06	BNI2024-0344	1
345	2024-08-07	BNI2024-0345	1
346	2024-08-08	BNI2024-0346	1
347	2024-08-09	BNI2024-0347	1
348	2024-08-12	BNI2024-0348	1
349	2024-08-13	BNI2024-0349	1
350	2024-08-14	BNI2024-0350	1
351	2024-08-15	BNI2024-0351	1
352	2024-08-16	BNI2024-0352	1
353	2024-08-19	BNI2024-0353	1
354	2024-08-20	BNI2024-0354	1
355	2024-08-25	BNI2024-0355	1
356	2024-08-27	BNI2024-0356	1
357	2024-08-29	BNI2024-0357	1
358	2024-08-31	BNI2024-0358	1
359	2024-09-02	BNI2024-0359	1
360	2024-09-03	BNI2024-0360	1
361	2024-09-04	BNI2024-0361	1
362	2024-09-05	BNI2024-0362	1
363	2024-09-06	BNI2024-0363	1
364	2024-09-09	BNI2024-0364	1
365	2024-09-10	BNI2024-0365	1
366	2024-09-10	BNI2024-0366	1
367	2024-09-11	BNI2024-0367	1
368	2024-09-12	BNI2024-0368	1
369	2024-09-13	BNI2024-0369	1
370	2024-09-16	BNI2024-0370	1
371	2024-09-17	BNI2024-0371	1
372	2024-09-18	BNI2024-0372	1
373	2024-09-19	BNI2024-0373	1
374	2024-09-20	BNI2024-0374	1
375	2024-09-25	BNI2024-0375	1
376	2024-09-27	BNI2024-0376	1
377	2024-09-30	BNI2024-0377	1
378	2024-10-02	BNI2024-0378	1
379	2024-10-03	BNI2024-0379	1
380	2024-10-04	BNI2024-0380	1
381	2024-10-07	BNI2024-0381	1
382	2024-10-08	BNI2024-0382	1
383	2024-10-09	BNI2024-0383	1
384	2024-10-10	BNI2024-0384	1
385	2024-10-11	BNI2024-0385	1
386	2024-10-14	BNI2024-0386	1
387	2024-10-15	BNI2024-0387	1
388	2024-10-16	BNI2024-0388	1
389	2024-10-17	BNI2024-0389	1
390	2024-10-18	BNI2024-0390	1
391	2024-10-20	BNI2024-0391	1
392	2024-10-21	BNI2024-0392	1
393	2024-10-25	BNI2024-0393	1
394	2024-10-27	BNI2024-0394	1
395	2024-10-29	BNI2024-0395	1
396	2024-10-31	BNI2024-0396	1
397	2024-11-01	BNI2024-0397	1
398	2024-11-04	BNI2024-0398	1
399	2024-11-05	BNI2024-0399	1
400	2024-11-06	BNI2024-0400	1
401	2024-11-07	BNI2024-0401	1
402	2024-11-08	BNI2024-0402	1
403	2024-11-11	BNI2024-0403	1
404	2024-11-12	BNI2024-0404	1
405	2024-11-13	BNI2024-0405	1
406	2024-11-14	BNI2024-0406	1
407	2024-11-15	BNI2024-0407	1
408	2024-11-15	BNI2024-0408	1
409	2024-11-18	BNI2024-0409	1
410	2024-11-20	BNI2024-0410	1
411	2024-11-25	BNI2024-0411	1
412	2024-11-27	BNI2024-0412	1
413	2024-11-28	BNI2024-0413	1
414	2024-11-30	BNI2024-0414	1
415	2024-12-02	BNI2024-0415	1
416	2024-12-03	BNI2024-0416	1
417	2024-12-04	BNI2024-0417	1
418	2024-12-05	BNI2024-0418	1
419	2024-12-06	BNI2024-0419	1
420	2024-12-09	BNI2024-0420	1
421	2024-12-10	BNI2024-0421	1
422	2024-12-11	BNI2024-0422	1
423	2024-12-12	BNI2024-0423	1
424	2024-12-13	BNI2024-0424	1
425	2024-12-16	BNI2024-0425	1
426	2024-12-17	BNI2024-0426	1
427	2024-12-18	BNI2024-0427	1
428	2024-12-19	BNI2024-0428	1
429	2024-12-20	BNI2024-0429	1
430	2024-12-24	BNI2024-0430	1
431	2024-12-27	BNI2024-0431	1
432	2024-12-30	BNI2024-0432	1
433	2024-12-31	BNI2024-0433	1
434	2025-01-02	BNI2025-0001	1
435	2025-01-03	BNI2025-0435	1
436	2025-01-06	BNI2025-0436	1
437	2025-01-07	BNI2025-0437	1
438	2025-01-08	BNI2025-0438	1
439	2025-01-09	BNI2025-0439	1
440	2025-01-10	BNI2025-0440	1
441	2025-01-13	BNI2025-0441	1
442	2025-01-14	BNI2025-0442	1
443	2025-01-15	BNI2025-0443	1
444	2025-01-16	BNI2025-0444	1
445	2025-01-17	BNI2025-0445	1
446	2025-01-20	BNI2025-0446	1
447	2025-01-21	BNI2025-0447	1
448	2025-01-22	BNI2025-0448	1
449	2025-01-25	BNI2025-0449	1
450	2025-01-27	BNI2025-0450	1
451	2025-01-28	BNI2025-0451	1
452	2025-01-30	BNI2025-0452	1
453	2025-01-31	BNI2025-0453	1
454	2025-02-03	BNI2025-0454	1
455	2025-02-04	BNI2025-0455	1
456	2025-02-05	BNI2025-0456	1
457	2025-02-06	BNI2025-0457	1
458	2025-02-07	BNI2025-0458	1
459	2025-02-10	BNI2025-0459	1
460	2025-02-11	BNI2025-0460	1
461	2025-02-12	BNI2025-0461	1
462	2025-02-13	BNI2025-0462	1
463	2025-02-14	BNI2025-0463	1
464	2025-02-15	BNI2025-0464	1
465	2025-02-17	BNI2025-0465	1
466	2025-02-18	BNI2025-0466	1
467	2025-02-19	BNI2025-0467	1
468	2025-02-20	BNI2025-0468	1
469	2025-02-25	BNI2025-0469	1
470	2025-02-27	BNI2025-0470	1
471	2025-02-28	BNI2025-0471	1
472	2025-03-02	BNI2025-0472	1
473	2025-03-03	BNI2025-0473	1
474	2025-03-04	BNI2025-0474	1
475	2025-03-05	BNI2025-0475	1
476	2025-03-06	BNI2025-0476	1
477	2025-03-07	BNI2025-0477	1
478	2025-03-10	BNI2025-0478	1
479	2025-03-11	BNI2025-0479	1
480	2025-03-12	BNI2025-0480	1
481	2025-03-13	BNI2025-0481	1
482	2025-03-14	BNI2025-0482	1
483	2025-03-17	BNI2025-0483	1
484	2025-03-18	BNI2025-0484	1
485	2025-03-19	BNI2025-0485	1
486	2025-03-20	BNI2025-0486	1
487	2025-03-20	BNI2025-0487	1
488	2025-03-25	BNI2025-0488	1
489	2025-03-27	BNI2025-0489	1
490	2025-03-30	BNI2025-0490	1
491	2025-03-31	BNI2025-0491	1
492	2025-04-01	BNI2025-0492	1
493	2025-04-02	BNI2025-0493	1
494	2025-04-03	BNI2025-0494	1
495	2025-04-04	BNI2025-0495	1
496	2025-04-07	BNI2025-0496	1
497	2025-04-08	BNI2025-0497	1
498	2025-04-09	BNI2025-0498	1
499	2025-04-10	BNI2025-0499	1
500	2025-04-11	BNI2025-0500	1
501	2025-04-14	BNI2025-0501	1
502	2025-04-15	BNI2025-0502	1
503	2025-04-16	BNI2025-0503	1
504	2025-04-17	BNI2025-0504	1
505	2025-04-18	BNI2025-0505	1
506	2025-04-21	BNI2025-0506	1
507	2025-04-22	BNI2025-0507	1
508	2025-04-25	BNI2025-0508	1
509	2025-04-27	BNI2025-0509	1
510	2025-04-29	BNI2025-0510	1
511	2025-04-30	BNI2025-0511	1
512	2025-05-02	BNI2025-0512	1
513	2025-05-04	BNI2025-0513	1
514	2025-05-05	BNI2025-0514	1
515	2025-05-06	BNI2025-0515	1
516	2025-05-07	BNI2025-0516	1
517	2025-05-08	BNI2025-0517	1
518	2025-05-09	BNI2025-0518	1
519	2025-05-10	BNI2025-0519	1
520	2025-05-12	BNI2025-0520	1
521	2025-05-13	BNI2025-0521	1
522	2025-05-14	BNI2025-0522	1
523	2025-05-15	BNI2025-0523	1
524	2025-05-16	BNI2025-0524	1
525	2025-05-19	BNI2025-0525	1
526	2025-05-20	BNI2025-0526	1
527	2025-05-25	BNI2025-0527	1
528	2025-05-27	BNI2025-0528	1
529	2025-05-29	BNI2025-0529	1
530	2025-05-31	BNI2025-0530	1
531	2025-06-02	BNI2025-0531	1
532	2025-06-03	BNI2025-0532	1
533	2025-06-04	BNI2025-0533	1
534	2025-06-05	BNI2025-0534	1
535	2025-06-06	BNI2025-0535	1
536	2025-06-09	BNI2025-0536	1
537	2025-06-10	BNI2025-0537	1
538	2025-06-11	BNI2025-0538	1
539	2025-06-12	BNI2025-0539	1
540	2025-06-13	BNI2025-0540	1
541	2025-06-16	BNI2025-0541	1
542	2025-06-17	BNI2025-0542	1
543	2025-06-18	BNI2025-0543	1
544	2025-06-19	BNI2025-0544	1
545	2025-06-20	BNI2025-0545	1
546	2025-06-25	BNI2025-0546	1
547	2025-06-25	BNI2025-0547	1
548	2025-06-27	BNI2025-0548	1
549	2025-06-28	BNI2025-0549	1
550	2025-06-30	BNI2025-0550	1
551	2025-07-01	BNI2025-0551	1
552	2025-07-02	BNI2025-0552	1
553	2025-07-03	BNI2025-0553	1
554	2025-07-04	BNI2025-0554	1
555	2025-07-07	BNI2025-0555	1
556	2025-07-08	BNI2025-0556	1
557	2025-07-09	BNI2025-0557	1
558	2025-07-10	BNI2025-0558	1
559	2025-07-11	BNI2025-0559	1
560	2025-07-14	BNI2025-0560	1
561	2025-07-15	BNI2025-0561	1
562	2025-07-16	BNI2025-0562	1
563	2025-07-17	BNI2025-0563	1
564	2025-07-18	BNI2025-0564	1
565	2025-07-21	BNI2025-0565	1
566	2025-07-22	BNI2025-0566	1
567	2025-07-25	BNI2025-0567	1
568	2025-07-27	BNI2025-0568	1
569	2025-07-29	BNI2025-0569	1
570	2025-07-31	BNI2025-0570	1
571	2025-08-01	BNI2025-0571	1
572	2025-08-04	BNI2025-0572	1
573	2025-08-05	BNI2025-0573	1
574	2025-08-06	BNI2025-0574	1
575	2025-08-07	BNI2025-0575	1
576	2025-08-08	BNI2025-0576	1
577	2025-08-11	BNI2025-0577	1
578	2025-08-12	BNI2025-0578	1
579	2025-08-13	BNI2025-0579	1
580	2025-08-14	BNI2025-0580	1
581	2025-08-15	BNI2025-0581	1
582	2025-08-15	BNI2025-0582	1
583	2025-08-18	BNI2025-0583	1
584	2025-08-19	BNI2025-0584	1
585	2025-08-20	BNI2025-0585	1
586	2025-08-25	BNI2025-0586	1
587	2025-08-27	BNI2025-0587	1
588	2025-08-29	BNI2025-0588	1
589	2025-08-31	BNI2025-0589	1
590	2025-09-01	BNI2025-0590	1
591	2025-09-02	BNI2025-0591	1
592	2025-09-03	BNI2025-0592	1
593	2025-09-04	BNI2025-0593	1
594	2025-09-05	BNI2025-0594	1
595	2025-09-08	BNI2025-0595	1
596	2025-09-09	BNI2025-0596	1
597	2025-09-10	BNI2025-0597	1
598	2025-09-11	BNI2025-0598	1
599	2025-09-12	BNI2025-0599	1
600	2025-09-15	BNI2025-0600	1
601	2025-09-16	BNI2025-0601	1
602	2025-09-17	BNI2025-0602	1
603	2025-09-18	BNI2025-0603	1
604	2025-09-19	BNI2025-0604	1
605	2025-09-22	BNI2025-0605	1
606	2025-09-23	BNI2025-0606	1
607	2025-09-24	BNI2025-0607	1
608	2025-09-25	BNI2025-0608	1
609	2025-09-26	BNI2025-0609	1
610	2025-09-29	BNI2025-0610	1
611	2025-09-30	BNI2025-0611	1
612	2025-09-30	BNI2025-0612	1
613	2025-10-02	BNI2025-0613	1
614	2025-10-04	BNI2025-0614	1
615	2025-10-06	BNI2025-0615	1
616	2025-10-08	BNI2025-0616	1
617	2025-10-09	BNI2025-0617	1
618	2025-10-10	BNI2025-0618	1
619	2025-10-13	BNI2025-0619	1
620	2025-10-14	BNI2025-0620	1
621	2025-10-15	BNI2025-0621	1
622	2025-10-16	BNI2025-0622	1
623	2025-10-17	BNI2025-0623	1
624	2025-10-20	BNI2025-0624	1
625	2025-10-20	BNI2025-0625	1
626	2025-10-21	BNI2025-0626	1
627	2025-10-22	BNI2025-0627	1
628	2025-10-27	BNI2025-0628	1
629	2025-10-29	BNI2025-0629	1
630	2025-10-31	BNI2025-0630	1
631	2025-11-02	BNI2025-0631	1
632	2025-11-03	BNI2025-0632	1
633	2025-11-04	BNI2025-0633	1
634	2025-11-05	BNI2025-0634	1
635	2025-11-06	BNI2025-0635	1
636	2025-11-07	BNI2025-0636	1
637	2025-11-10	BNI2025-0637	1
638	2025-11-11	BNI2025-0638	1
639	2025-11-12	BNI2025-0639	1
640	2025-11-13	BNI2025-0640	1
641	2025-11-14	BNI2025-0641	1
642	2025-11-15	BNI2025-0642	1
643	2025-11-17	BNI2025-0643	1
644	2025-11-18	BNI2025-0644	1
645	2025-11-19	BNI2025-0645	1
646	2025-11-20	BNI2025-0646	1
647	2025-11-25	BNI2025-0647	1
648	2025-11-27	BNI2025-0648	1
649	2025-11-28	BNI2025-0649	1
650	2025-11-30	BNI2025-0650	1
651	2025-12-01	BNI2025-0651	1
652	2025-12-02	BNI2025-0652	1
653	2025-12-03	BNI2025-0653	1
654	2025-12-04	BNI2025-0654	1
655	2025-12-05	BNI2025-0655	1
656	2025-12-08	BNI2025-0656	1
657	2025-12-09	BNI2025-0657	1
658	2025-12-10	BNI2025-0658	1
659	2025-12-11	BNI2025-0659	1
660	2025-12-12	BNI2025-0660	1
661	2025-12-15	BNI2025-0661	1
662	2025-12-16	BNI2025-0662	1
663	2025-12-17	BNI2025-0663	1
664	2025-12-18	BNI2025-0664	1
665	2025-12-19	BNI2025-0665	1
666	2025-12-22	BNI2025-0666	1
667	2025-12-26	BNI2025-0667	1
668	2025-12-28	BNI2025-0668	1
669	2025-12-30	BNI2025-0669	1
670	2025-12-31	BNI2025-0670	1
673	2025-11-14	BNI2025-0673	1
674	2025-11-15	BNI2025-0674	1
675	2025-01-02	BNI2025-0675	1
676	2025-01-03	BNI2025-0676	1
677	2025-01-06	BNI2025-0677	1
678	2025-01-07	BNI2025-0678	1
679	2025-01-08	BNI2025-0679	1
680	2025-01-09	BNI2025-0680	1
681	2025-01-10	BNI2025-0681	1
682	2025-01-13	BNI2025-0682	1
683	2025-01-14	BNI2025-0683	1
684	2025-01-15	BNI2025-0684	1
685	2025-01-16	BNI2025-0685	1
686	2025-01-17	BNI2025-0686	1
687	2025-01-20	BNI2025-0687	1
688	2025-01-21	BNI2025-0688	1
689	2025-01-22	BNI2025-0689	1
690	2025-01-25	BNI2025-0690	1
691	2025-01-27	BNI2025-0691	1
692	2025-01-28	BNI2025-0692	1
693	2025-01-30	BNI2025-0693	1
694	2025-01-31	BNI2025-0694	1
695	2025-02-03	BNI2025-0695	1
696	2025-02-04	BNI2025-0696	1
697	2025-02-05	BNI2025-0697	1
698	2025-02-06	BNI2025-0698	1
699	2025-02-07	BNI2025-0699	1
700	2025-02-10	BNI2025-0700	1
701	2025-02-11	BNI2025-0701	1
702	2025-02-12	BNI2025-0702	1
703	2025-02-13	BNI2025-0703	1
704	2025-02-14	BNI2025-0704	1
705	2025-02-15	BNI2025-0705	1
706	2025-02-17	BNI2025-0706	1
707	2025-02-18	BNI2025-0707	1
708	2025-02-19	BNI2025-0708	1
709	2025-02-20	BNI2025-0709	1
710	2025-02-25	BNI2025-0710	1
711	2025-02-27	BNI2025-0711	1
712	2025-02-28	BNI2025-0712	1
713	2025-03-02	BNI2025-0713	1
714	2025-03-03	BNI2025-0714	1
715	2025-03-04	BNI2025-0715	1
716	2025-03-05	BNI2025-0716	1
717	2025-03-06	BNI2025-0717	1
718	2025-03-07	BNI2025-0718	1
719	2025-03-10	BNI2025-0719	1
720	2025-03-11	BNI2025-0720	1
721	2025-03-12	BNI2025-0721	1
722	2025-03-13	BNI2025-0722	1
723	2025-03-14	BNI2025-0723	1
724	2025-03-17	BNI2025-0724	1
725	2025-03-18	BNI2025-0725	1
726	2025-03-19	BNI2025-0726	1
727	2025-03-20	BNI2025-0727	1
728	2025-03-20	BNI2025-0728	1
729	2025-03-25	BNI2025-0729	1
730	2025-03-27	BNI2025-0730	1
731	2025-03-30	BNI2025-0731	1
732	2025-03-31	BNI2025-0732	1
733	2025-04-01	BNI2025-0733	1
734	2025-04-02	BNI2025-0734	1
735	2025-04-03	BNI2025-0735	1
736	2025-04-04	BNI2025-0736	1
737	2025-04-07	BNI2025-0737	1
738	2025-04-08	BNI2025-0738	1
739	2025-04-09	BNI2025-0739	1
740	2025-04-10	BNI2025-0740	1
741	2025-04-11	BNI2025-0741	1
742	2025-04-14	BNI2025-0742	1
743	2025-04-15	BNI2025-0743	1
744	2025-04-16	BNI2025-0744	1
745	2025-04-17	BNI2025-0745	1
746	2025-04-18	BNI2025-0746	1
747	2025-04-21	BNI2025-0747	1
748	2025-04-22	BNI2025-0748	1
749	2025-04-25	BNI2025-0749	1
750	2025-04-27	BNI2025-0750	1
751	2025-04-29	BNI2025-0751	1
752	2025-04-30	BNI2025-0752	1
753	2025-05-02	BNI2025-0753	1
754	2025-05-04	BNI2025-0754	1
755	2025-05-05	BNI2025-0755	1
756	2025-05-06	BNI2025-0756	1
757	2025-05-07	BNI2025-0757	1
758	2025-05-08	BNI2025-0758	1
759	2025-05-09	BNI2025-0759	1
760	2025-05-10	BNI2025-0760	1
761	2025-05-12	BNI2025-0761	1
762	2025-05-13	BNI2025-0762	1
763	2025-05-14	BNI2025-0763	1
764	2025-05-15	BNI2025-0764	1
765	2025-05-16	BNI2025-0765	1
766	2025-05-19	BNI2025-0766	1
767	2025-05-20	BNI2025-0767	1
768	2025-05-25	BNI2025-0768	1
769	2025-05-27	BNI2025-0769	1
770	2025-05-29	BNI2025-0770	1
771	2025-05-31	BNI2025-0771	1
772	2025-06-02	BNI2025-0772	1
773	2025-06-03	BNI2025-0773	1
774	2025-06-04	BNI2025-0774	1
775	2025-06-05	BNI2025-0775	1
776	2025-06-06	BNI2025-0776	1
777	2025-06-09	BNI2025-0777	1
778	2025-06-10	BNI2025-0778	1
779	2025-06-11	BNI2025-0779	1
780	2025-06-12	BNI2025-0780	1
781	2025-06-13	BNI2025-0781	1
782	2025-06-16	BNI2025-0782	1
783	2025-06-17	BNI2025-0783	1
784	2025-06-18	BNI2025-0784	1
785	2025-06-19	BNI2025-0785	1
786	2025-06-20	BNI2025-0786	1
787	2025-06-25	BNI2025-0787	1
788	2025-06-25	BNI2025-0788	1
789	2025-06-27	BNI2025-0789	1
790	2025-06-28	BNI2025-0790	1
791	2025-06-30	BNI2025-0791	1
792	2025-07-01	BNI2025-0792	1
793	2025-07-02	BNI2025-0793	1
794	2025-07-03	BNI2025-0794	1
795	2025-07-04	BNI2025-0795	1
796	2025-07-07	BNI2025-0796	1
797	2025-07-08	BNI2025-0797	1
798	2025-07-09	BNI2025-0798	1
799	2025-07-10	BNI2025-0799	1
800	2025-07-11	BNI2025-0800	1
801	2025-07-14	BNI2025-0801	1
802	2025-07-15	BNI2025-0802	1
803	2025-07-16	BNI2025-0803	1
804	2025-07-17	BNI2025-0804	1
805	2025-07-18	BNI2025-0805	1
806	2025-07-21	BNI2025-0806	1
807	2025-07-22	BNI2025-0807	1
808	2025-07-25	BNI2025-0808	1
809	2025-07-27	BNI2025-0809	1
810	2025-07-29	BNI2025-0810	1
811	2025-07-31	BNI2025-0811	1
812	2025-08-01	BNI2025-0812	1
813	2025-08-04	BNI2025-0813	1
814	2025-08-05	BNI2025-0814	1
815	2025-08-06	BNI2025-0815	1
816	2025-08-07	BNI2025-0816	1
817	2025-08-08	BNI2025-0817	1
818	2025-08-11	BNI2025-0818	1
819	2025-08-12	BNI2025-0819	1
820	2025-08-13	BNI2025-0820	1
821	2025-08-14	BNI2025-0821	1
822	2025-08-15	BNI2025-0822	1
823	2025-08-15	BNI2025-0823	1
824	2025-08-18	BNI2025-0824	1
825	2025-08-19	BNI2025-0825	1
826	2025-08-20	BNI2025-0826	1
827	2025-08-25	BNI2025-0827	1
828	2025-08-27	BNI2025-0828	1
829	2025-08-29	BNI2025-0829	1
830	2025-08-31	BNI2025-0830	1
831	2025-09-01	BNI2025-0831	1
832	2025-09-02	BNI2025-0832	1
833	2025-09-03	BNI2025-0833	1
834	2025-09-04	BNI2025-0834	1
835	2025-09-05	BNI2025-0835	1
836	2025-09-08	BNI2025-0836	1
837	2025-09-09	BNI2025-0837	1
838	2025-09-10	BNI2025-0838	1
839	2025-09-11	BNI2025-0839	1
840	2025-09-12	BNI2025-0840	1
841	2025-09-15	BNI2025-0841	1
842	2025-09-16	BNI2025-0842	1
843	2025-09-17	BNI2025-0843	1
844	2025-09-18	BNI2025-0844	1
845	2025-09-19	BNI2025-0845	1
846	2025-09-22	BNI2025-0846	1
847	2025-09-23	BNI2025-0847	1
848	2025-09-24	BNI2025-0848	1
849	2025-09-25	BNI2025-0849	1
850	2025-09-26	BNI2025-0850	1
851	2025-09-29	BNI2025-0851	1
852	2025-09-30	BNI2025-0852	1
853	2025-09-30	BNI2025-0853	1
854	2025-10-02	BNI2025-0854	1
855	2025-10-04	BNI2025-0855	1
856	2025-10-06	BNI2025-0856	1
857	2025-10-08	BNI2025-0857	1
858	2025-10-09	BNI2025-0858	1
859	2025-10-10	BNI2025-0859	1
860	2025-10-13	BNI2025-0860	1
861	2025-10-14	BNI2025-0861	1
862	2025-10-15	BNI2025-0862	1
863	2025-10-16	BNI2025-0863	1
864	2025-10-17	BNI2025-0864	1
865	2025-10-20	BNI2025-0865	1
866	2025-10-20	BNI2025-0866	1
867	2025-10-21	BNI2025-0867	1
868	2025-10-22	BNI2025-0868	1
869	2025-10-27	BNI2025-0869	1
870	2025-10-29	BNI2025-0870	1
871	2025-10-31	BNI2025-0871	1
872	2025-11-02	BNI2025-0872	1
873	2025-11-03	BNI2025-0873	1
874	2025-11-04	BNI2025-0874	1
875	2025-11-05	BNI2025-0875	1
876	2025-11-06	BNI2025-0876	1
877	2025-11-07	BNI2025-0877	1
878	2025-11-10	BNI2025-0878	1
879	2025-11-11	BNI2025-0879	1
880	2025-11-12	BNI2025-0880	1
881	2025-11-13	BNI2025-0881	1
882	2025-11-14	BNI2025-0882	1
883	2025-11-15	BNI2025-0883	1
884	2025-11-17	BNI2025-0884	1
885	2025-11-18	BNI2025-0885	1
886	2025-11-19	BNI2025-0886	1
887	2025-11-20	BNI2025-0887	1
888	2025-11-25	BNI2025-0888	1
889	2025-11-27	BNI2025-0889	1
890	2025-11-28	BNI2025-0890	1
891	2025-11-30	BNI2025-0891	1
892	2025-12-01	BNI2025-0892	1
893	2025-12-02	BNI2025-0893	1
894	2025-12-03	BNI2025-0894	1
895	2025-12-04	BNI2025-0895	1
896	2025-12-05	BNI2025-0896	1
897	2025-12-08	BNI2025-0897	1
898	2025-12-09	BNI2025-0898	1
899	2025-12-10	BNI2025-0899	1
900	2025-12-11	BNI2025-0900	1
901	2025-12-12	BNI2025-0901	1
902	2025-12-15	BNI2025-0902	1
903	2025-12-16	BNI2025-0903	1
904	2025-12-17	BNI2025-0904	1
905	2025-12-18	BNI2025-0905	1
906	2025-12-19	BNI2025-0906	1
907	2025-12-22	BNI2025-0907	1
908	2025-12-26	BNI2025-0908	1
909	2025-12-28	BNI2025-0909	1
910	2025-12-30	BNI2025-0910	1
911	2025-12-31	BNI2025-0911	1
\.


--
-- Data for Name: nature_comptables; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.nature_comptables (id_nature_comptable, code_nature, libelle, created_at, updated_at) FROM stdin;
1	ACTIF	Actif	2025-10-14 08:54:54	2025-10-14 08:54:54
2	PASSIF	Passif	2025-10-14 08:54:54	2025-10-14 08:54:54
3	CHARGE	Charge	2025-10-14 08:54:54	2025-10-14 08:54:54
4	PRODUIT	Produit	2025-10-14 08:54:54	2025-10-14 08:54:54
5	CP	Capitaux propres	2025-10-14 08:54:54	2025-10-14 08:54:54
\.


--
-- Data for Name: niveau_alerte; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.niveau_alerte (id_niveau_alerte, libelle, couleur) FROM stdin;
1	Mauvais	#FE0000
2	Moyen	#F89400
3	Bon	#01CC00
\.


--
-- Data for Name: niveaux_urgence; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.niveaux_urgence (id, code, nom, icone, couleur, ordre) FROM stdin;
1	info	Information	bi bi-bell-fill	#01CC00	1
2	avertissement	Avertissement	bi bi-exclamation-circle-fill	#F89400	2
3	urgent	Urgent	bi bi-x-circle-fill	#FE0000	3
\.


--
-- Data for Name: notifications; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.notifications (id, evenement_id, niveau_urgence_id, titre, message, statut, lu_a, created_at, updated_at) FROM stdin;
1	1	1	Importation réussie	Le fichier 'Ecriture 2025.csv' a été importé avec succès : 237 mouvements, 498 lignes.	lu	2025-11-16 17:44:46	2025-11-16 17:44:33	2025-11-16 17:44:46
2	2	1	Clôture exercice comptable imminente	L'exercice 2025 sera clôturé dans un mois (31/12/2025). 498 écriture(s) à valider.	lu	2025-11-16 18:07:18	2025-11-16 18:06:38	2025-11-16 18:07:18
\.


--
-- Data for Name: password_reset_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_reset_tokens (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: password_resets; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.password_resets (email, token, created_at) FROM stdin;
\.


--
-- Data for Name: personal_access_tokens; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.personal_access_tokens (id, tokenable_type, tokenable_id, name, token, abilities, last_used_at, expires_at, created_at, updated_at) FROM stdin;
10	App\\Models\\User	1	app-token	412e483d4c90ffe54e49ff405250170e58a3f4d8b55b6a8e8dbdb65f3b52d623	["*"]	2025-09-24 11:23:47	\N	2025-09-24 11:23:46	2025-09-24 11:23:47
11	App\\Models\\User	1	app-token	b62ce3dbcaf78cccaf75a5bfa101891f73e0917f91c49b072085abedc7baf7b8	["*"]	2025-09-24 11:24:15	\N	2025-09-24 11:24:14	2025-09-24 11:24:15
12	App\\Models\\User	1	app-token	3c119fb770a136c8436774c783a4a122f3cda14bf1acb29ac9b77cb390e0f315	["*"]	2025-09-24 11:40:37	\N	2025-09-24 11:40:36	2025-09-24 11:40:37
33	App\\Models\\User	1	app-token	c15c9fe27881d84fd14e84382c49dd1e9fece01a81e4fcb9fd2c5f1ae416d24f	["*"]	2025-10-07 05:59:30	\N	2025-10-07 05:58:37	2025-10-07 05:59:30
17	App\\Models\\User	1	app-token	359727f3da82eaa8ad5be49bf189381509e4633c61516f96e14d8f1c1f9241e4	["*"]	2025-09-25 07:15:57	\N	2025-09-24 19:00:00	2025-09-25 07:15:57
13	App\\Models\\User	1	app-token	22196891bd6bc47a5cc8e9ffaca1fe43ca48f7dba38011df4369dbe6c64f7d74	["*"]	2025-09-24 11:47:11	\N	2025-09-24 11:46:53	2025-09-24 11:47:11
18	App\\Models\\User	1	app-token	e9e96cf4f6ee2724813cfdc8f9e01bc2c364d39da9278201f52cf6d7eea39957	["*"]	2025-09-28 15:27:42	\N	2025-09-25 07:16:46	2025-09-28 15:27:42
14	App\\Models\\User	1	app-token	a09d3a5713331c33b579a3adb4ff929260de26900d0113a6ce4926011d3dc4fd	["*"]	2025-09-24 12:29:46	\N	2025-09-24 11:55:01	2025-09-24 12:29:46
1	App\\Models\\User	1	app-token	a0cb3326726d942734b56c7b8627e7eef293ea2b9d61499c4bb778af6a6aecab	["*"]	2025-09-18 11:41:17	\N	2025-09-18 11:05:51	2025-09-18 11:41:17
2	App\\Models\\User	1	app-token	dd710528963f69e84acd8d3fa7843afa94a74ba2cd4989a167d566268d4e402c	["*"]	2025-09-22 08:10:06	\N	2025-09-18 11:41:24	2025-09-22 08:10:06
3	App\\Models\\User	1	app-token	539f07d8f03e650ae75efe7f742bf3dc0528e1a5c735e124f4fff799b1533398	["*"]	2025-09-22 11:29:37	\N	2025-09-22 08:10:15	2025-09-22 11:29:37
20	App\\Models\\User	1	app-token	2ee8ad52bf702ce66fc15f1f1b6a72bc8ec1556d9c97e531eec572092c10b718	["*"]	2025-09-28 15:30:50	\N	2025-09-28 15:29:29	2025-09-28 15:30:50
29	App\\Models\\User	1	app-token	444f3a0e72d8f4cd19a4d8e6f013b38b76ae14817fae429379ffa3e1e5b420ed	["*"]	2025-10-05 14:58:06	\N	2025-10-04 07:51:43	2025-10-05 14:58:06
5	App\\Models\\User	2	app-token	40ee8698e43f817fb74257cb965eb457620d46dfd0bd0afae37930dfdcc72493	["*"]	2025-09-23 09:20:48	\N	2025-09-22 17:02:44	2025-09-23 09:20:48
6	App\\Models\\User	1	app-token	f60aecd975b1a56391b1a455ea35a905952b7df2aa15ace10ea166b83e9a5dd6	["*"]	2025-09-24 10:57:44	\N	2025-09-23 09:21:04	2025-09-24 10:57:44
39	App\\Models\\User	1	app-token	96cd9b9be623e60f0c3c6862d52c5e6266cb3cafd5d8e6c3603742a12ae4a920	["*"]	2025-10-16 11:03:17	\N	2025-10-14 10:50:24	2025-10-16 11:03:17
22	App\\Models\\User	1	app-token	f48a47b0b3ca64561546d93ac097849e6f704162e5b3ad4c996cbb44266f2619	["*"]	2025-09-29 08:49:28	\N	2025-09-28 16:22:09	2025-09-29 08:49:28
4	App\\Models\\User	1	app-token	7b36c064fac76daa03413e28fd2657cbf1c4cef2e40583615a27b9d599bb87c0	["*"]	2025-09-28 08:11:28	\N	2025-09-22 11:29:45	2025-09-28 08:11:28
7	App\\Models\\User	1	app-token	10217e2f6d626021462a382e6c6e48de2f0a580155df84a647daf014f31dc6c1	["*"]	2025-09-24 11:00:49	\N	2025-09-24 10:57:56	2025-09-24 11:00:49
8	App\\Models\\User	1	app-token	bfbe1d447599a560c5829e206db8fcc5a8d87f1ac512eedfe654c259af78f073	["*"]	2025-09-24 11:06:16	\N	2025-09-24 11:06:15	2025-09-24 11:06:16
9	App\\Models\\User	1	app-token	b47d125064abe114d3095b2b133f00e354f82a27f1e57acd0a5ea43d847b052b	["*"]	2025-09-24 11:23:08	\N	2025-09-24 11:23:08	2025-09-24 11:23:08
15	App\\Models\\User	1	app-token	96ff3176834ec1561a0fd4ee3bf91c7f4fcf21dc9046d103000571c9fdf818ce	["*"]	2025-09-24 18:44:10	\N	2025-09-24 12:42:08	2025-09-24 18:44:10
16	App\\Models\\User	1	app-token	b9bee7c2731a29c62294d4707a8ca01d2ae630f188b056fca8e39d76d0be137c	["*"]	2025-09-24 18:59:34	\N	2025-09-24 18:58:22	2025-09-24 18:59:34
30	App\\Models\\User	1	app-token	6f7a1d668d396fe09d16ae37f69dcbbce5aac9b1981ae6b130f0492d22dd2db0	["*"]	2025-10-05 17:06:46	\N	2025-10-05 14:58:24	2025-10-05 17:06:46
23	App\\Models\\User	1	app-token	5f7eca90c76ac7e8d4fa138c51aeb57d38c7624950a3decf42756d27bfe5bd72	["*"]	2025-09-29 15:39:56	\N	2025-09-29 08:53:53	2025-09-29 15:39:56
27	App\\Models\\User	1	app-token	58e05a82e0e4ee2c5c309511001740899bb32547bab216668afa94ca114bc4ae	["*"]	2025-10-02 07:03:21	\N	2025-10-02 05:50:55	2025-10-02 07:03:21
21	App\\Models\\User	1	app-token	b1f30a7e0109569afdf9043241a46759fbfe7ee039c91c087b6130e3e28ef2bc	["*"]	2025-09-28 16:21:56	\N	2025-09-28 15:45:18	2025-09-28 16:21:56
19	App\\Models\\User	1	app-token	3a73fd6b64cbaa5e8732f84a157a03667701453b6b23fe66738ed8b73bdbd2ca	["*"]	2025-09-28 08:13:32	\N	2025-09-28 08:11:36	2025-09-28 08:13:32
24	App\\Models\\User	1	app-token	6348179c5b4482263339405315dfa96d53c4c45d4aaecf9549c168c43499cf12	["*"]	2025-09-29 16:21:56	\N	2025-09-29 15:40:09	2025-09-29 16:21:56
25	App\\Models\\User	1	app-token	52b730559cea8436e81a1a7d80feaa39d6f6437eae6bcf6ed02ae57a1fe7d9d4	["*"]	2025-10-01 07:08:47	\N	2025-09-29 16:22:18	2025-10-01 07:08:47
36	App\\Models\\User	1	app-token	249199bc0acb6b84f6de8abb5e78d46bb738b98463211af534b7a67aea5e84d0	["*"]	2025-10-10 11:19:26	\N	2025-10-10 11:15:32	2025-10-10 11:19:26
26	App\\Models\\User	1	app-token	d9cb789bc29f6e612641e8a65c0810eccbbe3459dfd47f1ffaeee9bc11b3258e	["*"]	2025-10-01 20:54:28	\N	2025-10-01 07:09:11	2025-10-01 20:54:28
28	App\\Models\\User	1	app-token	801ec8f0042b1ad77c03dbbb5b2f3b880f8e005e49e734719ac7dafdc6637564	["*"]	2025-10-04 07:51:19	\N	2025-10-02 07:06:45	2025-10-04 07:51:19
31	App\\Models\\User	1	app-token	1a6b29d0c90cc7cf32e450ec7b308fcc5751a529c09548e15a249c33169a1794	["*"]	2025-10-05 17:34:04	\N	2025-10-05 17:07:11	2025-10-05 17:34:04
34	App\\Models\\User	1	app-token	a7fdd25e8d6b9b9493124fb29063bf2a58f6b57f9840148b13c61da045bef36f	["*"]	2025-10-08 17:26:11	\N	2025-10-07 05:59:43	2025-10-08 17:26:11
32	App\\Models\\User	1	app-token	a639f1e6fb9df907c7bb5207637dd0aec007a1d8ed09ad79123e684263f7fcd0	["*"]	2025-10-07 05:58:24	\N	2025-10-06 07:26:53	2025-10-07 05:58:24
35	App\\Models\\User	1	app-token	f731f2dca67a54060812f070bf1da0aa1c143ea08a412f73ece61ed75515ee14	["*"]	2025-10-08 17:27:07	\N	2025-10-08 17:26:26	2025-10-08 17:27:07
37	App\\Models\\User	1	app-token	3ef318885f5a441db6b6a67c1290e497cec8eaaf27ef8d9bfa01894e62c1beff	["*"]	2025-10-13 06:42:26	\N	2025-10-10 11:34:10	2025-10-13 06:42:26
38	App\\Models\\User	1	app-token	c27aa8ec59fb76e3e7ee8eb81b2ee82385ff07e2384eb5b625d6e2aeb872f698	["*"]	\N	\N	2025-10-14 06:35:15	2025-10-14 06:35:15
41	App\\Models\\User	1	app-token	764a196fcdda7aeb31e2fc6c72cc69eed32cf595fa91415cf4a5d0426f57c774	["*"]	2025-10-17 19:42:32	\N	2025-10-17 19:42:30	2025-10-17 19:42:32
40	App\\Models\\User	1	app-token	1e6055e2bd21b2a8f4d1ef22d69f9ee02ad266574144fcfa183f44363fb8113a	["*"]	2025-10-17 19:41:37	\N	2025-10-16 11:03:30	2025-10-17 19:41:37
42	App\\Models\\User	1	app-token	8cb677f8ff5e45f2b7e17b1eab7946c0692ba3f5a0be03a343df0cb7b9c5d02b	["*"]	2025-10-17 19:47:55	\N	2025-10-17 19:47:52	2025-10-17 19:47:55
43	App\\Models\\User	1	app-token	ddd21971b9e95743e8c163910afea2182c46389f7c83e408384809ca61fab645	["*"]	2025-10-18 15:28:06	\N	2025-10-17 19:49:27	2025-10-18 15:28:06
73	App\\Models\\User	1	app-token	5cae32b49b71afdf25b89404d95076a028a83cac73c53588b2216c8dfffa6123	["*"]	2025-10-25 15:11:27	\N	2025-10-25 13:15:32	2025-10-25 15:11:27
54	App\\Models\\User	1	app-token	3a8cc20bfae09a7f6ae1191f1d92aabe51d01788e534a873062f2fe60f3a83c0	["*"]	2025-10-20 19:16:15	\N	2025-10-20 17:49:13	2025-10-20 19:16:15
44	App\\Models\\User	1	app-token	f6999523a7ea7d365bd4128e11234524d24c1fbbc46e579ddd39a208365eb2d5	["*"]	2025-10-18 18:33:06	\N	2025-10-18 15:28:23	2025-10-18 18:33:06
65	App\\Models\\User	1	app-token	8ab11e6ff9d0c7db52e95412374c7d7eea01717c2a080c6c594d98054de66036	["*"]	2025-10-23 16:17:07	\N	2025-10-23 16:12:33	2025-10-23 16:17:07
62	App\\Models\\User	1	app-token	f5ccae6cd6247a8da0380f004179abca5d74cf4917b0ef0e69dea3e8c00427c4	["*"]	2025-10-23 07:54:20	\N	2025-10-23 07:52:43	2025-10-23 07:54:20
45	App\\Models\\User	1	app-token	d9a0b9a46098a68e8a026be5f1f81ceac9787d05a5d01ca210cf41b3fda8b0ad	["*"]	2025-10-20 11:51:49	\N	2025-10-20 10:29:53	2025-10-20 11:51:49
46	App\\Models\\User	1	app-token	50f7087737c952ac0757f73953cbf7b95510bf450a13cd8090bd54b05b32245d	["*"]	\N	\N	2025-10-20 11:52:06	2025-10-20 11:52:06
47	App\\Models\\User	1	app-token	07d40db888e45cf1943031d6aa4cb9f65ba3bb3dddcabbee8ee5527b248ec036	["*"]	2025-10-20 11:55:15	\N	2025-10-20 11:55:11	2025-10-20 11:55:15
48	App\\Models\\User	1	app-token	62abeee159b20dfba72f66e189d2e64c1c1529c28c0fbc987a40a976b4a36059	["*"]	2025-10-20 16:34:52	\N	2025-10-20 16:34:49	2025-10-20 16:34:52
49	App\\Models\\User	1	app-token	25ef4897cee0ed8ef9aeef45f66da56ce78d764f716ad8ed4c46e614b506c4cb	["*"]	2025-10-20 16:51:01	\N	2025-10-20 16:35:09	2025-10-20 16:51:01
50	App\\Models\\User	1	app-token	2abbf8000978a7f52f2d5d608f638927326f75d450f762f4612c61b1b8f5be1e	["*"]	2025-10-20 16:54:29	\N	2025-10-20 16:51:38	2025-10-20 16:54:29
51	App\\Models\\User	1	app-token	3bf452f9cfed7eac34dded53a3ddb67b764cda92ccfc9b1078f83cbea645868a	["*"]	2025-10-20 17:08:22	\N	2025-10-20 17:08:20	2025-10-20 17:08:22
52	App\\Models\\User	1	app-token	93db3ab66ec0b93ddaff506e59f7700eb26fc4b06a4ca245bcc4524313fde92d	["*"]	2025-10-20 17:11:41	\N	2025-10-20 17:11:38	2025-10-20 17:11:41
66	App\\Models\\User	1	app-token	19e124c4fb2aec835f72562bc0793e7dc83066ef8d7e0e498e3b2134e42f3686	["*"]	2025-10-23 16:17:45	\N	2025-10-23 16:17:41	2025-10-23 16:17:45
53	App\\Models\\User	1	app-token	da0e07229b06652f2530be7319a5686ca89094bdcd900953953e67d73d7b8f2b	["*"]	2025-10-20 17:18:59	\N	2025-10-20 17:12:26	2025-10-20 17:18:59
81	App\\Models\\User	1	app-token	9aad5e5c6a810ab6945e6cecca201ec7fd51fd957667feb15018ecebfa342b31	["*"]	2025-10-30 06:35:41	\N	2025-10-29 18:18:41	2025-10-30 06:35:41
67	App\\Models\\User	1	app-token	1bc536272e6ad2c98f05de7a3ca58619b307fed57e0eab852e9c874072f69b7f	["*"]	2025-10-23 16:42:08	\N	2025-10-23 16:42:01	2025-10-23 16:42:08
58	App\\Models\\User	1	app-token	83814d2bb641a83b82eb84e8ab2b2a93999f3c9d8b194dd355bb86a462e7493b	["*"]	2025-10-22 17:53:25	\N	2025-10-22 06:55:34	2025-10-22 17:53:25
72	App\\Models\\User	1	app-token	323f67e86764230d460e209d374427773690e0582bceebfe6f1bad5e33529ddb	["*"]	2025-10-24 11:41:40	\N	2025-10-24 07:06:13	2025-10-24 11:41:40
55	App\\Models\\User	1	app-token	54fc94de22bf47e87781593ae275d44af8d81de8b46740c77d8651281df20ab1	["*"]	2025-10-20 19:29:37	\N	2025-10-20 19:18:27	2025-10-20 19:29:37
68	App\\Models\\User	1	app-token	4ae1b41b226186962b51891913b00e043afb457b072925726e334a96e538167e	["*"]	2025-10-23 17:19:23	\N	2025-10-23 16:49:26	2025-10-23 17:19:23
63	App\\Models\\User	1	app-token	b84f71af9582b4ccaa24591941fb83d73ff438affb3f6d1111212d1de731ace5	["*"]	2025-10-23 16:05:03	\N	2025-10-23 15:54:03	2025-10-23 16:05:03
60	App\\Models\\User	1	app-token	5096bb3a4da270a7ad2da03fd3076522df7bdc9cd5609ad558ab8c0c638a74dd	["*"]	2025-10-22 18:46:11	\N	2025-10-22 18:02:03	2025-10-22 18:46:11
61	App\\Models\\User	1	app-token	08a0ff20cc0d0b65c853eaefe49d5bbc2d572965d4e568cd0d2d6f18976fac2d	["*"]	\N	\N	2025-10-22 18:47:44	2025-10-22 18:47:44
57	App\\Models\\User	1	app-token	c94e07df94e35f39c21477f082d0e0206ff1a6b654fda22952558dfc038c0650	["*"]	2025-10-22 06:55:00	\N	2025-10-21 18:09:05	2025-10-22 06:55:00
69	App\\Models\\User	1	app-token	b8ed80eafc3311a4c06bc8d6990d931c844e29d8aa91419562a280b20c43ac47	["*"]	\N	\N	2025-10-23 17:23:49	2025-10-23 17:23:49
56	App\\Models\\User	1	app-token	053afd6122856e9b049dd328338292ea4fe049ef8e52044f0eaee25d6fc57531	["*"]	2025-10-21 16:18:21	\N	2025-10-21 15:20:42	2025-10-21 16:18:21
59	App\\Models\\User	1	app-token	de6778a819f4e9528eabd09ea4f8e486e532669a6182dec82cb1face28cdd12a	["*"]	2025-10-22 18:01:49	\N	2025-10-22 17:55:12	2025-10-22 18:01:49
64	App\\Models\\User	1	app-token	1f27d383d4f8a6869894ae0dda27312493699386b665b4837a575aac06d59115	["*"]	2025-10-23 16:12:16	\N	2025-10-23 16:05:26	2025-10-23 16:12:16
70	App\\Models\\User	1	app-token	c483351c1efd0aea6d69d07e93cb20f1f862d84b6c89834bbd8bbdf73d382b49	["*"]	2025-10-24 06:54:00	\N	2025-10-24 06:53:53	2025-10-24 06:54:00
76	App\\Models\\User	1	app-token	7e3f50645566ed81894f666eb19e6bbbeb84555c18d3b98dd650f54a677959e6	["*"]	2025-10-28 06:18:23	\N	2025-10-28 06:00:20	2025-10-28 06:18:23
71	App\\Models\\User	1	app-token	3e924386bc83d2ba2cab888e9cda771ea20bf2a721f371d1e1c092329546df2c	["*"]	\N	\N	2025-10-24 06:56:51	2025-10-24 06:56:51
77	App\\Models\\User	1	app-token	806968f5e96677ade2070eb01e29b45712494a5b9e65ef7ada81d899ebaee3e7	["*"]	2025-10-28 18:23:48	\N	2025-10-28 06:18:34	2025-10-28 18:23:48
80	App\\Models\\User	1	app-token	087112ea69492ef8d4e37fcaff78eff8df9cee3026183090af6b96fd9e51eee0	["*"]	2025-10-29 18:18:01	\N	2025-10-29 17:56:43	2025-10-29 18:18:01
74	App\\Models\\User	1	app-token	f45d1da4f79de9a18be9faf4877acf46e62ff09b568483d1cbdc27e05eee5393	["*"]	2025-10-26 19:04:05	\N	2025-10-26 18:28:31	2025-10-26 19:04:05
75	App\\Models\\User	1	app-token	9768787f7de6c0fc72ab02f3e8d00352a93a4ea89f5a1bd4b1d8fd21747b3295	["*"]	2025-10-27 18:12:30	\N	2025-10-27 16:26:30	2025-10-27 18:12:30
79	App\\Models\\User	1	app-token	5ceb0b616c341db3d582264c2b7b1c77f3c32458d6ab9f202a3c9d2294a93ad3	["*"]	2025-10-28 20:10:00	\N	2025-10-28 20:01:59	2025-10-28 20:10:00
78	App\\Models\\User	1	app-token	4a592b962bb82b556635e62ed758a36f95c15eab5199141129ed3d4f890c3138	["*"]	2025-10-28 19:56:50	\N	2025-10-28 18:24:06	2025-10-28 19:56:50
85	App\\Models\\User	1	app-token	1a049919517cd9019629c195202eee044ee436c08045bf19b545fc6c950a4a99	["*"]	2025-11-01 13:29:46	\N	2025-11-01 13:27:55	2025-11-01 13:29:46
82	App\\Models\\User	1	app-token	c341147d20207b88284e09e74f63720f1bfd68ff750946b5d09bf5c9a80d48d9	["*"]	2025-10-30 19:30:56	\N	2025-10-30 06:36:55	2025-10-30 19:30:56
83	App\\Models\\User	1	app-token	e093d9b5f5476e1d5ab3d898c8dbb49d04ab87e1800f71a7b0079ea6dfa6f55e	["*"]	2025-10-30 19:48:25	\N	2025-10-30 19:39:42	2025-10-30 19:48:25
84	App\\Models\\User	1	app-token	a6534a68ddf437bb47c88e32a46dac793aadf3f21e78219c7aa8deb0c3083286	["*"]	2025-11-01 11:18:46	\N	2025-10-30 20:10:44	2025-11-01 11:18:46
86	App\\Models\\User	1	app-token	e5f51f3a6b66a72ead89e4b171f8390bbf463c51c3f40131f209e2716a0fb811	["*"]	2025-11-02 14:27:18	\N	2025-11-01 13:49:43	2025-11-02 14:27:18
94	App\\Models\\User	1	app-token	381865221cbff5d9c0c53688050cd48045da98fef78f2ef6eec6db27ed3eb1f6	["*"]	2025-11-13 13:27:28	\N	2025-11-12 18:31:52	2025-11-13 13:27:28
95	App\\Models\\User	1	app-token	31b7cd34092a0e2d1639a8ef5f95f88e37cb0ed307fffbc9eded438c72c5aafc	["*"]	2025-11-14 15:42:51	\N	2025-11-13 16:33:35	2025-11-14 15:42:51
96	App\\Models\\User	1	app-token	0dc84e4f36c74de2a74cdb270c1ebfa715ee7a6956555e9fd412513199b40eb4	["*"]	2025-11-15 18:08:39	\N	2025-11-15 15:53:53	2025-11-15 18:08:39
89	App\\Models\\User	1	app-token	6b969c1d3105e5693a41506ddd7ea310fdc20bc6d5e5c230b9fe546e57697a78	["*"]	2025-11-05 10:33:23	\N	2025-11-03 17:35:32	2025-11-05 10:33:23
90	App\\Models\\User	1	app-token	b34b4d1e198d1107f792dbdd622d9e01bdee09d6198863986e3bc7833e3d45c3	["*"]	2025-11-05 16:07:28	\N	2025-11-05 15:20:35	2025-11-05 16:07:28
91	App\\Models\\User	1	app-token	e05484e411bb257a200a26352c87754092500d512ec808aa4611d472754de4b2	["*"]	2025-11-05 16:33:55	\N	2025-11-05 16:27:19	2025-11-05 16:33:55
87	App\\Models\\User	1	app-token	bb032030f4da1b8f7f10441ca60c6e429269bf459eb280b356cd414b07bd1cc6	["*"]	2025-11-03 16:24:00	\N	2025-11-02 14:27:32	2025-11-03 16:24:00
88	App\\Models\\User	1	app-token	a7ec48f7ccc8711ea78606a91b01e5b9c1f3f1931bac895b3bb51433a823cc04	["*"]	2025-11-03 17:35:14	\N	2025-11-03 17:32:03	2025-11-03 17:35:14
97	App\\Models\\User	1	app-token	7b3cc90e76c30edfd1bfd0e00c32562713fe8bca72a0c39aaf91bdf598a44250	["*"]	2025-11-16 18:12:03	\N	2025-11-16 16:39:50	2025-11-16 18:12:03
92	App\\Models\\User	1	app-token	3125b05e9a9835f3c2d74f79f058d55b19ffca3a625f6f9cd6b5e9eb49bc088a	["*"]	2025-11-12 18:21:59	\N	2025-11-06 16:02:43	2025-11-12 18:21:59
93	App\\Models\\User	1	app-token	a0efb10c7cad0bf69121ed2edfe8634a3024bad03b5e6418435ee76609190122	["*"]	2025-11-12 18:27:58	\N	2025-11-12 18:27:27	2025-11-12 18:27:58
\.


--
-- Data for Name: rubriques; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.rubriques ("Id_Rubrique", "Code_rubrique", "Libelle", "Id_Classe") FROM stdin;
1	10	Capital, reserves et assimiles	1
2	11	Report a nouveau	1
3	12	Resultat de lexercice	1
4	13	Produits et charges differes - hors cycle dexploitation	1
5	14	(Disponible)	1
6	15	Provisions pour charges - passifs non courants	1
7	16	Emprunts et dettes assimiles	1
8	17	Dettes rattachees a des participations	1
9	18	Comptes de liaison des etablissements et societes en participation	1
10	19	(Disponible)	1
11	20	Immobilisations incorporelles	2
12	21	Immobilisations corporelles	2
13	22	Immobilisations mises en concession	2
14	23	Immobilisations en cours	2
15	24	(Disponible)	2
16	25	(Disponible)	2
17	26	Participations et creances rattachees a des participations	2
18	27	Autres immobilisations financieres	2
19	28	Amortissements des immobilisations	2
20	29	Pertes de valeur sur immobilisations	2
21	31	Stocks de matieres premieres et fournitures	3
22	32	Stocks dautres approvisionnements	3
23	33	En-cours de production de biens	3
24	34	En-cours de production de services	3
25	35	Produits intermediaires et finis	3
26	36	(Disponible)	3
27	37	Stocks de marchandises	3
28	38	Stocks à lextérieur (en cours de route, en dépôt ou en\nconsignation)	3
29	39	Pertes de valeur sur stocks et en-cours	3
30	40	Fournisseurs et comptes rattaches	4
31	41	Clients et comptes rattaches	4
32	42	Personnel et comptes rattaches	4
33	43	Organismes sociaux et comptes rattaches	4
34	44	Etat, collectivites publiques, organismes internationaux	4
35	45	Groupe et Associes	4
36	46	Debiteurs divers et crediteurs divers	4
37	47	Comptes transitoires ou d attente	4
38	48	Charges ou produits constates d avance et provisions	4
39	49	Pertes de valeur sur comptes de tiers	4
40	50	Valeurs mobilieres de placement	5
41	51	Banques, etablissements financiers et assimiles	5
42	52	Instruments de tresorerie	5
43	53	Caisse	5
44	54	Regies d avances et accredtitifs	5
45	55	(Disponible)	5
46	56	(Disponible)	5
47	57	(Disponible)	5
48	58	Virements internes	5
49	59	Pertes de valeur sur comptes financiers	5
50	60	Achats consommés	6
51	61	Services extérieurs	6
52	62	Autres services extérieurs	6
53	63	Impôts, taxes et versements assimilés	6
54	64	Charges de personnel	6
55	65	Autres charges des activités ordinaires	6
56	66	Charges financières	6
57	67	Éléments extraordinaires (charges)	6
58	68	Dotations aux amortissements, provisions et pertes de valeur	6
59	69	Impôts sur les bénéfices	6
60	70	Ventes de produits fabriques, marchandises, prestations	7
61	71	Production stockee (ou destockage)	7
62	72	Production immobilisee	7
63	74	Subventions dexploitation	7
64	75	Autres produits operationnels	7
65	76	Produits financiers	7
66	77	Elements extraordinaires (produits)	7
67	78	Reprises sur provisions et pertes de valeur	7
\.


--
-- Data for Name: sessions; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sessions (id, user_id, ip_address, user_agent, payload, last_activity) FROM stdin;
XJyXoDtGFwnKHjoi397xWCRMrOBJFWciOLmSMNKW	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiNXgwQXBrSG5tbGNNaTV2WU4ycGJXQ1NxdHU5TzJjVGZNNnNaTVFMYyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763057800
IDj7NlGxImnhD48k3eKFpEMnjXHKXafdVfZYNm2Z	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiOVpNYjdEdW9rN3BBbHcwT3dueDZMMWE4U3RFTW51OXFYZ2MycHRaMCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763058460
91TA2RMJEbXQ3vLZROfR1c5wGEulEuaPMR1lf3qk	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoid1J1cm53V21peEh6WTFBZnlKZ1R3aFBLaUNydUhCd2RXalRuRTM1RSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763058580
3Wc7CvmTUV1n67aatAnlo85TQFftp0mzOwuqJdMA	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiTlA0VnBBYnVLWTVOTmRIMXliaGRoZHJySFdBRWJFcWFpYzBIQ1NBTiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763058648
uzpw2fpV41TAaBNViO7WtGbEGk0ANogbcWYOOXLu	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiMnUxYkJPVnVQanAzaVdHMTNNdVpJWDZhM1drcXFPQ3UzMVk4ZE5CbiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763058724
Q2BnXBllPeEkZ8joxY8HBAt4KHtbZsqoJm31FRPl	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiS2dkRmg2UVl0VGQ3VTloVHdxcDVxSDk3c0JVc0pFelVRTms0NXNZeSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763058731
VEfCoGABlG9cN72ne9xcWokLJfdoApMacczhNNre	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoidURkbm1wdmNtbmJheTlOVXRldjJtS3oxSHFkcTBQc1M3SmZzb3ltNiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763058796
m4AMd8Jz9wexFrQkeV3WULpMkVfPlAw5MX5tDf1A	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiTkVkWmVXQjFnQ280NkptMEFwUTA2WDlBTFZWTXk4eDNGN0E3WmZJRiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763058917
h26a8ZgrIpuvpBFuNFaC2jUbah8UJZWg4fiYhpdS	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiUmR0WEtlNmJSRHJzQVlHclduMWpCV2F6UU9OYlMzMFRQYVBzZnBhTiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763059164
8f88korGyxE3WlFNyaunEVdF9zArXKZT7kr3JXuH	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiMmlXNk1tSm1SQlkyREFRRjZpYmJaeUVkZ1ZiNHNkWDlubWZJbk5wayI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763059184
9HDtcLkh08LHHMjIY8pf0hmCvwU6K7IxNAwG1vxy	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiWDgxSURJRURQdmlUbVhmUk5SU0F5MnhSdFo5c3RDMzFySE1reTREaiI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763059278
qkI5mPpyZ4TzxzC55NBzvsc9yEuLARUWoC6DTfeK	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiRTZwTUhsRVRkSGtwbjNReXN2TTB3bEx0ZGwxbkJpVndnS3FaMm12YSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763059296
1HuSpvGsXNsjta6ZjrMrVpS6HFUTuKntyDLOfo4j	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiektZT3BCa2lJTTNuaWhUV01GbXpUSmRuWEJka01QbGloS1c1SzJWUyI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763059299
RZrnTBZFZpsj5hi0gcpje9IL6DFzLJHUJD6G9XTL	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiZmV4WDNBUVBJWm85N1N2eGxWenFhS2E0cmNjMG5lSFBxYjhpeFhDQSI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763059395
dBmJXzkkZBWqCJubFmMSonnfDbDDdUMnkQVYNkSY	\N	127.0.0.1	Mozilla/5.0 (Windows NT 6.1; Trident/7.0; rv:11.0) like Gecko	YTozOntzOjY6Il90b2tlbiI7czo0MDoiT1dBMnVKYWVhbTJNeW82SVRtcHZzN2djcDJ5OVExQlVzRGxOWGQxNCI7czo5OiJfcHJldmlvdXMiO2E6MTp7czozOiJ1cmwiO3M6MjE6Imh0dHA6Ly9sb2NhbGhvc3Q6ODAwMCI7fXM6NjoiX2ZsYXNoIjthOjI6e3M6Mzoib2xkIjthOjA6e31zOjM6Im5ldyI7YTowOnt9fX0=	1763133396
\.


--
-- Data for Name: sous_comptes; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.sous_comptes ("Id_Sous_compte", "Code_sous_compte", "Libelle", "Id_Compte") FROM stdin;
1	101001	Capital verse par l Etat	1
2	101002	Capital apporte par les fondateurs prives	1
3	106001	Reserve legale	4
4	106002	Autres reserves (fonds scolaires)	4
5	108001	Compte du directeur detablissement	6
6	211001	Terrains du campus	39
7	213001	Constructions - Batiments administratifs	41
8	213002	Constructions - Salles de classe	41
9	213003	Constructions - Bibliotheque et laboratoires	41
10	215001	Materiel informatique	42
11	215002	Materiel pedagogique	42
12	218001	Mobilier scolaire	43
13	218002	Vehicules de transport scolaire	43
14	321001	Matiere consommables - produits chimiques labo	77
15	321002	Matiere consommables - materiel pedagogique	77
16	322001	Fournitures de bureau	78
17	322002	Fournitures scolaires (cahiers, stylos)	78
18	326001	Emballages de cantine	79
19	326002	Emballages labo	79
20	331001	Travaux pratiques en-cours	80
21	331002	Projets scolaires en-cours	80
22	335001	Travaux de construction en-cours	81
23	335002	Travaux de maintenance en-cours	81
24	341001	Etudes administratives en-cours	82
25	341002	Etudes scientifiques en-cours	82
26	345001	Services de formation en-cours	83
27	345002	Services parascolaires en-cours	83
28	351001	Produits pedagogiques intermediaires	84
29	355001	Manuels scolaires imprimes	85
30	355002	Uniformes scolaires finis	85
31	358001	Dechets recyclables	86
32	358002	Materiel de recuperation	86
33	391001	Perte valeur fournitures perimees	87
34	392001	Perte valeur autres approvisionnements	88
35	393001	Perte valeur en-cours biens	89
36	394001	Perte valeur en-cours services	90
37	395001	Perte valeur produits finis	91
38	397001	Perte valeur stocks approvisionnements	92
39	398001	Perte valeur stocks immobilisations	93
40	401001	Fournisseurs de fournitures scolaires	94
41	401002	Fournisseurs de services (maintenance, securite)	94
42	411001	Eleves - scolarite a encaisser	100
43	411002	Parents - creances diverses	100
44	416001	Eleves douteux - scolarite impayee	102
45	421001	Personnel enseignant - salaires dus	106
46	421002	Personnel administratif - salaires dus	106
47	425001	Avances sur salaires	108
48	431001	CNAPS	112
49	445001	Etat - TVA a decaisser	119
50	445002	Etat - Impot sur les salaires	119
51	515001	Caisse centrale - Ariary	148
52	515002	Caisse cantine	148
53	512001	BNI - compte courant	147
54	512002	BMOI - compte courant	147
55	581001	Virement Banque vers Caisse	152
79	601001	Papier, cahiers et copies	156
80	601002	Encres, craies et peintures	156
81	601003	Matériel scientifique et technique	156
82	601004	Fournitures artistiques	156
83	602001	Fournitures de bureau	157
84	602002	Cartouches et toners	157
85	602003	Stylos, crayons et gommes	157
86	602004	Classeurs, dossiers et archives	157
87	602005	Livres et manuels scolaires	157
88	602006	Matériel pédagogique divers	157
89	603001	Papeterie administrative	158
90	603002	Cartouches et toners	158
91	603003	Classeurs dossiers et archives	158
92	604001	Conception pédagogique externe	159
93	604002	Services de formation continue du personnel	159
94	604003	Maintenance informatique	159
95	604004	Achats études techniques	159
96	605001	Tables et chaises scolaires	160
97	605002	Tableaux et équipement pédagogiques	160
98	605003	Matériel informatique de base	160
99	605004	Factures électricité	160
100	605005	Factures eau	160
101	605006	Factures gaz	160
102	606001	Produits de nettoyage classes	161
103	606002	Produits hygiène toilettes	161
104	606003	Matériel de nettoyage (balais, serpillières)	161
105	607001	Uniformes et tenues scolaires	162
106	607002	Équipements sportifs	162
107	607003	Matériel pour activités culturelles	162
108	608001	Frais de transport des fournitures	163
109	608002	Frais de douane	163
110	609001	Remises fournisseurs de papeterie	164
111	611001	Loyer des salles de classe	165
112	611002	Loyer des bureaux administratifs	165
113	611003	Charges eau et électricité bâtiments	165
114	613001	Assurance responsabilité civile	166
115	613002	Assurance scolaire élèves	166
116	613003	Assurance du personnel	166
117	614001	Charges copropriété écoles	167
118	615001	Réparation bâtiments scolaires	168
119	615002	Réparation matériel scolaire	168
120	615003	Réparation bus scolaire	168
121	616001	Assurance bâtiments	169
122	616002	Assurance véhicules scolaires	169
123	617001	Salaires agents sécurité	170
124	617002	Fournitures pour gardiennage	170
125	617003	Contrat entreprise de sécurité	170
126	618001	Abonnement revues professionnelles	171
127	619001	Remises sur entretien et gardiennage	172
128	621001	Salaires enseignants primaire	173
129	621002	Salaires enseignants secondaire	173
130	622001	Salaires personnel administratif	174
131	622002	Indemnités personnel administratif	174
132	623001	Publicité institutionnelle	175
133	624001	Transport élèves et enseignants	176
134	624002	Transport matériel scolaire	176
135	625001	Cotisations CNAPS	177
136	625002	Cotisations OSTIE	177
137	625003	Autres charges sociales obligatoires	177
138	625004	Déplacements professionnels	177
139	625005	Réceptions et événements	177
140	626001	Frais envois postaux	178
141	626002	Abonnement téléphonique et internet	178
142	627001	Commissions bancaires	179
143	628001	Cotisation associations pédagogiques	180
144	629001	Remises prestations services	181
145	631001	IRSA enseignants	182
146	631002	IRSA personnel administratif	182
147	635001	Taxe foncière	183
148	635002	Taxe professionnelle	183
149	635003	TVA non déductible	183
150	641001	Vacations et contractuels	184
151	644001	Rémunération direction établissement	185
152	645001	Cotisations retraites	186
153	646001	Cotisations sociales dirigeants	187
154	647001	Autres charges sociales	188
155	648001	Primes et gratifications	189
156	651001	Licences logiciels éducatifs	190
157	651002	Abonnements plateformes pédagogiques	190
158	652001	Moins-value mobilier scolaire	191
159	653001	Jetons de présence AG	192
160	654001	Pertes sur créances parents	193
161	655001	Quote-part activités communes	194
162	656001	Amendes administratives	195
163	656002	Subventions accordées	195
164	656003	Dons	195
165	657001	Dépenses urgentes	196
166	658001	Autres dépenses courantes	197
167	661001	Intérêts prêt bancaire	198
168	661002	Intérêts crédit bus scolaire	198
169	664001	Pertes sur partenariats	199
170	665001	Moins-value titres placements	200
171	666001	Pertes de change opération bancaire	201
172	667001	Moins-value financière	202
173	668001	Frais bancaires divers	203
174	681001	Amortissement mobilier scolaire	204
175	681002	Amortissement matériel informatique	204
176	681003	Amortissement bâtiments	204
177	681004	Amortissement véhicules	204
178	685001	Provisions pour risques	205
179	692001	Impôts différés actifs	206
180	693001	Impôts différés passifs	207
181	695001	Impôts bénéfices courants	208
182	698001	Autres impôts sur bénéfices	209
183	701001	Ventes de manuels scolaires produits en interne	210
184	701002	Ventes de cahiers personnalises ecole	210
185	701003	Ventes de uniformes scolaires fabriques	210
186	702001	Vente de polycopies	211
187	702002	Vente de fascicules de cours	211
188	703001	Vente de materiels scolaires usagers	212
189	703002	Vente de livres anciens ou surplus	212
190	704001	Travaux realises par eleves (expos, projets)	213
191	704002	Travaux pratiques vendus	213
192	705001	Etudes ou recherches pedagogiques	214
193	706001	Frais de scolarite	215
194	706002	Frais dinscription	215
195	706003	Frais de transport scolaire	215
196	706004	Frais de cantine	215
197	706005	Frais de garderie	215
198	707001	Vente de fournitures scolaires	216
199	707002	Vente de uniformes scolaires	216
200	707003	Vente de articles divers (snack, boissons)	216
201	708001	Location salles ou materiels	217
202	708002	Organisation fetes et evenements	217
203	708003	Club parascolaire (sport musique art)	217
204	709001	Remises frais de scolarite	218
205	709002	Rabais sur ventes de fournitures	218
206	713001	Variation stock fournitures	219
207	713002	Variation stock uniformes	219
208	714001	Variation stock livres	220
209	714002	Variation stock marchandises annexes	220
210	721001	Developpement logiciel pedagogique	221
211	722001	Amenagements classes ou laboratoires	222
212	741001	Subvention de lEtat	223
213	741002	Subvention dautorites locales	223
214	748001	Subvention ONG et associations	224
215	748002	Subvention entreprises privees	224
216	751001	Location logiciels pedagogiques	225
217	751002	Utilisation brevets pedagogiques	225
218	752001	Cession anciens ordinateurs	226
219	752002	Cession anciens vehicules scolaires	226
220	753001	Remuneration conseil administration	227
221	754001	Subventions constructions batiments	228
222	756001	Dons de materiels scolaires	230
223	756002	Dons financiers	230
224	757001	Produits exceptionnels sur gestion	231
225	758001	Revenus divers non specifies	232
226	761001	Revenus participation associations scolaires	233
227	763001	Revenus creances sur parents	235
228	764001	Revenus placement court terme	236
229	766001	Gains sur operations devises	237
230	768001	Produits financiers divers	239
231	781001	Reprise sur batiments	240
232	781002	Reprise sur materiels	240
233	785001	Reprise sur stocks	241
234	786001	Reprise sur emprunts	242
235	786002	Reprise sur creances douteuses	242
236	531001	Caisse école	243
237	168001	Echéance prêt bancaire	26
238	641002	Paiement salaire maitresse	184
239	641004	Salaire gardien	184
240	641005	Salaire femme de ménage	184
241	601006	Achat legumes	156
242	601008	Achat viande	156
243	601009	Achat goûter	156
244	164001	Prêt bancaire	23
245	281001	Amortissement mobilier scolaire	69
\.


--
-- Data for Name: taux_amortissement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.taux_amortissement (id, intitule, taux, duree, unite_duree, created_at, updated_at) FROM stdin;
1	Matériel informatique	20.00	5	ans	2025-10-28 18:40:15	2025-10-28 18:40:15
2	Immobilier	2.50	40	ans	2025-10-28 18:40:15	2025-10-28 18:40:15
3	Mobilier de bureau	10.00	10	ans	2025-10-28 18:40:15	2025-10-28 18:40:15
\.


--
-- Data for Name: type_categories; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_categories (id_type_categorie, code_type, libelle, created_at, updated_at) FROM stdin;
1	BILAN	Comptes de bilan	2025-10-14 08:55:11	2025-10-14 08:55:11
2	GESTION	Comptes de gestion	2025-10-14 08:55:11	2025-10-14 08:55:11
\.


--
-- Data for Name: type_journals; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.type_journals ("Id_Type_Journal", "Type") FROM stdin;
1	Tresoreries
\.


--
-- Data for Name: typecentre; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.typecentre (id_type, code, libelle) FROM stdin;
1	Cout	cout
2	Profit	profit
\.


--
-- Data for Name: types_evenement; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.types_evenement (id, code, nom, description, est_actif) FROM stdin;
1	ERREUR_IMPORT	Erreur Import	Erreur lors de l'import de fichiers	t
2	SUCCES_IMPORT	Succès Import	Import terminé avec succès	t
3	ALERTE_SYSTEME	Alerte Système	Alerte système critique	t
4	NOTIFICATION_METIER	Notification Métier	Notification concernant le métier	t
5	CLOTURE_EXERCICE_PROCHE	Clôture Exercice Proche	Alerte à l'approche de la clôture de l'exercice comptable	t
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.users (id, name, email, email_verified_at, password, remember_token, created_at, updated_at) FROM stdin;
1	Cedric	rtctianasoacedric@gmail.com	\N	$2y$12$pd8uFSSasnwNJeByqFEIYuTqaAM7g3W0AFN934BoPrBIhBopXeX2K	\N	2025-09-18 11:05:41	2025-09-18 11:05:41
2	Karen	karenrazaf.28@gmail.com	\N	$2y$12$qeA1T0tvn0S5ZjEjieECJ.WAD45.HofXqdPmvVbIvNXC2vzvstAqq	\N	2025-09-22 17:02:24	2025-09-22 17:02:24
\.


--
-- Name: affectationanalytique_id_affectation_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.affectationanalytique_id_affectation_seq', 1, false);


--
-- Name: axesanalytique_id_axe_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.axesanalytique_id_axe_seq', 3, true);


--
-- Name: categorie_fonctionelles_id_categorie_fonctionelle_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.categorie_fonctionelles_id_categorie_fonctionelle_seq', 57, true);


--
-- Name: centreanalytique_id_centre_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.centreanalytique_id_centre_seq', 13, true);


--
-- Name: chat_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.chat_messages_id_seq', 89, true);


--
-- Name: classes_Id_Classe_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."classes_Id_Classe_seq"', 7, true);


--
-- Name: code_analytique_id_code_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.code_analytique_id_code_seq', 1, false);


--
-- Name: compte_categories_id_compte_categorie_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.compte_categories_id_compte_categorie_seq', 356, true);


--
-- Name: comptes_Id_Compte_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."comptes_Id_Compte_seq"', 243, true);


--
-- Name: devises_Id_Devise_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."devises_Id_Devise_seq"', 1, true);


--
-- Name: durees_id_duree_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.durees_id_duree_seq', 3, true);


--
-- Name: email_verifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.email_verifications_id_seq', 1, false);


--
-- Name: errors_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.errors_id_seq', 1, false);


--
-- Name: evenements_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.evenements_id_seq', 2, true);


--
-- Name: exercice_comptable_Id_Exercice_comptable_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."exercice_comptable_Id_Exercice_comptable_seq"', 21, true);


--
-- Name: failed_jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.failed_jobs_id_seq', 1, false);


--
-- Name: fonction_economiques_id_fonction_economique_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.fonction_economiques_id_fonction_economique_seq', 5, true);


--
-- Name: immobilisations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.immobilisations_id_seq', 5, true);


--
-- Name: import_histories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.import_histories_id_seq', 28, true);


--
-- Name: indicateurs_analytique_id_indicateur_analytique_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.indicateurs_analytique_id_indicateur_analytique_seq', 16, true);


--
-- Name: interpretation_indicateur_id_interpretation_indicateur_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.interpretation_indicateur_id_interpretation_indicateur_seq', 49, true);


--
-- Name: intervalle_comptes_categorie_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.intervalle_comptes_categorie_id_seq', 44, true);


--
-- Name: jobs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.jobs_id_seq', 20, true);


--
-- Name: journals_Id_Journal_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."journals_Id_Journal_seq"', 1, true);


--
-- Name: ligne_ecritures_Id_Ligne_ecriture_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."ligne_ecritures_Id_Ligne_ecriture_seq"', 1921, true);


--
-- Name: migrations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.migrations_id_seq', 60, true);


--
-- Name: mode_paiements_Id_Mode_paiement_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."mode_paiements_Id_Mode_paiement_seq"', 1, true);


--
-- Name: mouvement_ecritures_Id_Mouvement_ecriture_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."mouvement_ecritures_Id_Mouvement_ecriture_seq"', 911, true);


--
-- Name: nature_comptables_id_nature_comptable_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.nature_comptables_id_nature_comptable_seq', 5, true);


--
-- Name: niveau_alerte_id_niveau_alerte_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.niveau_alerte_id_niveau_alerte_seq', 3, true);


--
-- Name: niveaux_urgence_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.niveaux_urgence_id_seq', 3, true);


--
-- Name: notifications_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.notifications_id_seq', 2, true);


--
-- Name: personal_access_tokens_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.personal_access_tokens_id_seq', 97, true);


--
-- Name: rubriques_Id_Rubrique_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."rubriques_Id_Rubrique_seq"', 67, true);


--
-- Name: sous_comptes_Id_Sous_compte_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."sous_comptes_Id_Sous_compte_seq"', 245, true);


--
-- Name: taux_amortissement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.taux_amortissement_id_seq', 3, true);


--
-- Name: type_categories_id_type_categorie_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.type_categories_id_type_categorie_seq', 2, true);


--
-- Name: type_journals_Id_Type_Journal_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public."type_journals_Id_Type_Journal_seq"', 3, true);


--
-- Name: typecentre_id_type_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.typecentre_id_type_seq', 2, true);


--
-- Name: types_evenement_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.types_evenement_id_seq', 5, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: affectationanalytique affectationanalytique_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affectationanalytique
    ADD CONSTRAINT affectationanalytique_pkey PRIMARY KEY (id_affectation);


--
-- Name: axesanalytique axesanalytique_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.axesanalytique
    ADD CONSTRAINT axesanalytique_pkey PRIMARY KEY (id_axe);


--
-- Name: cache_locks cache_locks_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache_locks
    ADD CONSTRAINT cache_locks_pkey PRIMARY KEY (key);


--
-- Name: cache cache_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.cache
    ADD CONSTRAINT cache_pkey PRIMARY KEY (key);


--
-- Name: categorie_fonctionelles categorie_fonctionelles_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie_fonctionelles
    ADD CONSTRAINT categorie_fonctionelles_code_unique UNIQUE (code);


--
-- Name: categorie_fonctionelles categorie_fonctionelles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie_fonctionelles
    ADD CONSTRAINT categorie_fonctionelles_pkey PRIMARY KEY (id_categorie_fonctionelle);


--
-- Name: centreanalytique centreanalytique_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.centreanalytique
    ADD CONSTRAINT centreanalytique_pkey PRIMARY KEY (id_centre);


--
-- Name: chat_messages chat_messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_pkey PRIMARY KEY (id);


--
-- Name: classes classes_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_code_unique UNIQUE ("Code");


--
-- Name: classes classes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.classes
    ADD CONSTRAINT classes_pkey PRIMARY KEY ("Id_Classe");


--
-- Name: code_analytique code_analytique_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.code_analytique
    ADD CONSTRAINT code_analytique_code_unique UNIQUE (code);


--
-- Name: code_analytique code_analytique_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.code_analytique
    ADD CONSTRAINT code_analytique_pkey PRIMARY KEY (id_code);


--
-- Name: compte_categories compte_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compte_categories
    ADD CONSTRAINT compte_categories_pkey PRIMARY KEY (id_compte_categorie);


--
-- Name: comptes comptes_code_compte_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comptes
    ADD CONSTRAINT comptes_code_compte_unique UNIQUE ("Code_compte");


--
-- Name: comptes comptes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comptes
    ADD CONSTRAINT comptes_pkey PRIMARY KEY ("Id_Compte");


--
-- Name: devises devises_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devises
    ADD CONSTRAINT devises_code_unique UNIQUE ("Code");


--
-- Name: devises devises_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devises
    ADD CONSTRAINT devises_pkey PRIMARY KEY ("Id_Devise");


--
-- Name: devises devises_sigle_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.devises
    ADD CONSTRAINT devises_sigle_unique UNIQUE ("Sigle");


--
-- Name: durees durees_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.durees
    ADD CONSTRAINT durees_code_unique UNIQUE (code);


--
-- Name: durees durees_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.durees
    ADD CONSTRAINT durees_pkey PRIMARY KEY (id_duree);


--
-- Name: email_verifications email_verifications_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_email_unique UNIQUE (email);


--
-- Name: email_verifications email_verifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.email_verifications
    ADD CONSTRAINT email_verifications_pkey PRIMARY KEY (id);


--
-- Name: errors errors_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.errors
    ADD CONSTRAINT errors_pkey PRIMARY KEY (id);


--
-- Name: evenements evenements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evenements
    ADD CONSTRAINT evenements_pkey PRIMARY KEY (id);


--
-- Name: exercice_comptable exercice_comptable_date_debut_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercice_comptable
    ADD CONSTRAINT exercice_comptable_date_debut_unique UNIQUE ("Date_debut");


--
-- Name: exercice_comptable exercice_comptable_date_fin_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercice_comptable
    ADD CONSTRAINT exercice_comptable_date_fin_unique UNIQUE ("Date_fin");


--
-- Name: exercice_comptable exercice_comptable_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.exercice_comptable
    ADD CONSTRAINT exercice_comptable_pkey PRIMARY KEY ("Id_Exercice_comptable");


--
-- Name: failed_jobs failed_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_pkey PRIMARY KEY (id);


--
-- Name: failed_jobs failed_jobs_uuid_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.failed_jobs
    ADD CONSTRAINT failed_jobs_uuid_unique UNIQUE (uuid);


--
-- Name: fonction_economiques fonction_economiques_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fonction_economiques
    ADD CONSTRAINT fonction_economiques_code_unique UNIQUE (code);


--
-- Name: fonction_economiques fonction_economiques_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.fonction_economiques
    ADD CONSTRAINT fonction_economiques_pkey PRIMARY KEY (id_fonction_economique);


--
-- Name: immobilisations immobilisations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.immobilisations
    ADD CONSTRAINT immobilisations_pkey PRIMARY KEY (id);


--
-- Name: import_histories import_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.import_histories
    ADD CONSTRAINT import_histories_pkey PRIMARY KEY (id);


--
-- Name: indicateurs_analytique indicateurs_analytique_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.indicateurs_analytique
    ADD CONSTRAINT indicateurs_analytique_pkey PRIMARY KEY (id_indicateur_analytique);


--
-- Name: interpretation_indicateur interpretation_indicateur_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interpretation_indicateur
    ADD CONSTRAINT interpretation_indicateur_pkey PRIMARY KEY (id_interpretation_indicateur);


--
-- Name: intervalle_comptes_categorie intervalle_comptes_categorie_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intervalle_comptes_categorie
    ADD CONSTRAINT intervalle_comptes_categorie_pkey PRIMARY KEY (id);


--
-- Name: job_batches job_batches_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.job_batches
    ADD CONSTRAINT job_batches_pkey PRIMARY KEY (id);


--
-- Name: jobs jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (id);


--
-- Name: journals journals_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journals
    ADD CONSTRAINT journals_code_unique UNIQUE ("Code");


--
-- Name: journals journals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journals
    ADD CONSTRAINT journals_pkey PRIMARY KEY ("Id_Journal");


--
-- Name: ligne_ecritures ligne_ecritures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ligne_ecritures
    ADD CONSTRAINT ligne_ecritures_pkey PRIMARY KEY ("Id_Ligne_ecriture");


--
-- Name: migrations migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.migrations
    ADD CONSTRAINT migrations_pkey PRIMARY KEY (id);


--
-- Name: mode_paiements mode_paiements_abr_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mode_paiements
    ADD CONSTRAINT mode_paiements_abr_unique UNIQUE ("Abr");


--
-- Name: mode_paiements mode_paiements_libelle_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mode_paiements
    ADD CONSTRAINT mode_paiements_libelle_unique UNIQUE ("Libelle");


--
-- Name: mode_paiements mode_paiements_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mode_paiements
    ADD CONSTRAINT mode_paiements_pkey PRIMARY KEY ("Id_Mode_paiement");


--
-- Name: mouvement_ecritures mouvement_ecritures_numero_piece_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mouvement_ecritures
    ADD CONSTRAINT mouvement_ecritures_numero_piece_unique UNIQUE ("Numero_piece");


--
-- Name: mouvement_ecritures mouvement_ecritures_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mouvement_ecritures
    ADD CONSTRAINT mouvement_ecritures_pkey PRIMARY KEY ("Id_Mouvement_ecriture");


--
-- Name: nature_comptables nature_comptables_code_nature_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nature_comptables
    ADD CONSTRAINT nature_comptables_code_nature_unique UNIQUE (code_nature);


--
-- Name: nature_comptables nature_comptables_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.nature_comptables
    ADD CONSTRAINT nature_comptables_pkey PRIMARY KEY (id_nature_comptable);


--
-- Name: niveau_alerte niveau_alerte_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.niveau_alerte
    ADD CONSTRAINT niveau_alerte_pkey PRIMARY KEY (id_niveau_alerte);


--
-- Name: niveaux_urgence niveaux_urgence_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.niveaux_urgence
    ADD CONSTRAINT niveaux_urgence_code_unique UNIQUE (code);


--
-- Name: niveaux_urgence niveaux_urgence_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.niveaux_urgence
    ADD CONSTRAINT niveaux_urgence_pkey PRIMARY KEY (id);


--
-- Name: notifications notifications_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);


--
-- Name: password_reset_tokens password_reset_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.password_reset_tokens
    ADD CONSTRAINT password_reset_tokens_pkey PRIMARY KEY (email);


--
-- Name: personal_access_tokens personal_access_tokens_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_pkey PRIMARY KEY (id);


--
-- Name: personal_access_tokens personal_access_tokens_token_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.personal_access_tokens
    ADD CONSTRAINT personal_access_tokens_token_unique UNIQUE (token);


--
-- Name: rubriques rubriques_code_rubrique_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rubriques
    ADD CONSTRAINT rubriques_code_rubrique_unique UNIQUE ("Code_rubrique");


--
-- Name: rubriques rubriques_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rubriques
    ADD CONSTRAINT rubriques_pkey PRIMARY KEY ("Id_Rubrique");


--
-- Name: sessions sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (id);


--
-- Name: sous_comptes sous_comptes_code_sous_compte_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sous_comptes
    ADD CONSTRAINT sous_comptes_code_sous_compte_unique UNIQUE ("Code_sous_compte");


--
-- Name: sous_comptes sous_comptes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sous_comptes
    ADD CONSTRAINT sous_comptes_pkey PRIMARY KEY ("Id_Sous_compte");


--
-- Name: taux_amortissement taux_amortissement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.taux_amortissement
    ADD CONSTRAINT taux_amortissement_pkey PRIMARY KEY (id);


--
-- Name: type_categories type_categories_code_type_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_categories
    ADD CONSTRAINT type_categories_code_type_unique UNIQUE (code_type);


--
-- Name: type_categories type_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_categories
    ADD CONSTRAINT type_categories_pkey PRIMARY KEY (id_type_categorie);


--
-- Name: type_journals type_journals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_journals
    ADD CONSTRAINT type_journals_pkey PRIMARY KEY ("Id_Type_Journal");


--
-- Name: type_journals type_journals_type_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.type_journals
    ADD CONSTRAINT type_journals_type_unique UNIQUE ("Type");


--
-- Name: typecentre typecentre_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typecentre
    ADD CONSTRAINT typecentre_code_unique UNIQUE (code);


--
-- Name: typecentre typecentre_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.typecentre
    ADD CONSTRAINT typecentre_pkey PRIMARY KEY (id_type);


--
-- Name: types_evenement types_evenement_code_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_evenement
    ADD CONSTRAINT types_evenement_code_unique UNIQUE (code);


--
-- Name: types_evenement types_evenement_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.types_evenement
    ADD CONSTRAINT types_evenement_pkey PRIMARY KEY (id);


--
-- Name: users users_email_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_email_unique UNIQUE (email);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: chat_messages_session_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_messages_session_id_index ON public.chat_messages USING btree (session_id);


--
-- Name: chat_messages_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX chat_messages_user_id_index ON public.chat_messages USING btree (user_id);


--
-- Name: exercice_comptable_annee_fiscale_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX exercice_comptable_annee_fiscale_index ON public.exercice_comptable USING btree ("Annee_fiscale");


--
-- Name: exercice_comptable_statut_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX exercice_comptable_statut_index ON public.exercice_comptable USING btree ("Statut");


--
-- Name: idx_mv_12mois_centre; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_12mois_centre ON public.mv_evolution_12_mois USING btree (id_centre);


--
-- Name: idx_mv_12mois_mois; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_12mois_mois ON public.mv_evolution_12_mois USING btree (mois);


--
-- Name: idx_mv_12mois_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_12mois_type ON public.mv_evolution_12_mois USING btree (id_type);


--
-- Name: idx_mv_12mois_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_12mois_unique ON public.mv_evolution_12_mois USING btree (mois, id_centre, id_type);


--
-- Name: idx_mv_annuelle_annee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_annuelle_annee ON public.mv_comparaison_annuelle USING btree (annee);


--
-- Name: idx_mv_annuelle_centre; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_annuelle_centre ON public.mv_comparaison_annuelle USING btree (id_centre);


--
-- Name: idx_mv_annuelle_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_annuelle_type ON public.mv_comparaison_annuelle USING btree (id_type);


--
-- Name: idx_mv_annuelle_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_annuelle_unique ON public.mv_comparaison_annuelle USING btree (annee, id_centre, id_type);


--
-- Name: idx_mv_cout_profit_annee_mois; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_cout_profit_annee_mois ON public.mv_comparaison_cout_profit USING btree (annee, mois);


--
-- Name: idx_mv_cout_profit_periode; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_cout_profit_periode ON public.mv_comparaison_cout_profit USING btree (nom_periode);


--
-- Name: idx_mv_cout_profit_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_cout_profit_type ON public.mv_comparaison_cout_profit USING btree (id_type);


--
-- Name: idx_mv_cout_profit_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_cout_profit_unique ON public.mv_comparaison_cout_profit USING btree (annee, mois, id_type);


--
-- Name: idx_mv_mensuelle_annee_mois; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_mensuelle_annee_mois ON public.mv_analyse_mensuelle USING btree (annee, mois);


--
-- Name: idx_mv_mensuelle_centre; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_mensuelle_centre ON public.mv_analyse_mensuelle USING btree (id_centre);


--
-- Name: idx_mv_mensuelle_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_mensuelle_type ON public.mv_analyse_mensuelle USING btree (id_type);


--
-- Name: idx_mv_mensuelle_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_mensuelle_unique ON public.mv_analyse_mensuelle USING btree (annee, mois, id_centre, id_type);


--
-- Name: idx_mv_stats_type_annee_trimestre; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_stats_type_annee_trimestre ON public.mv_stats_globales_temporelles USING btree (type_analyse, annee, trimestre);


--
-- Name: idx_mv_stats_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_stats_unique ON public.mv_stats_globales_temporelles USING btree (id_unique);


--
-- Name: idx_mv_trimestrielle_annee; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_trimestrielle_annee ON public.mv_analyse_trimestrielle USING btree (annee);


--
-- Name: idx_mv_trimestrielle_annee_trimestre; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_trimestrielle_annee_trimestre ON public.mv_analyse_trimestrielle USING btree (annee, trimestre);


--
-- Name: idx_mv_trimestrielle_centre; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_trimestrielle_centre ON public.mv_analyse_trimestrielle USING btree (id_centre);


--
-- Name: idx_mv_trimestrielle_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_mv_trimestrielle_type ON public.mv_analyse_trimestrielle USING btree (id_type);


--
-- Name: idx_mv_trimestrielle_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_mv_trimestrielle_unique ON public.mv_analyse_trimestrielle USING btree (annee, trimestre, id_centre, id_type);


--
-- Name: jobs_queue_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX jobs_queue_index ON public.jobs USING btree (queue);


--
-- Name: password_resets_email_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX password_resets_email_index ON public.password_resets USING btree (email);


--
-- Name: personal_access_tokens_expires_at_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_expires_at_index ON public.personal_access_tokens USING btree (expires_at);


--
-- Name: personal_access_tokens_tokenable_type_tokenable_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX personal_access_tokens_tokenable_type_tokenable_id_index ON public.personal_access_tokens USING btree (tokenable_type, tokenable_id);


--
-- Name: sessions_last_activity_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_last_activity_index ON public.sessions USING btree (last_activity);


--
-- Name: sessions_user_id_index; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX sessions_user_id_index ON public.sessions USING btree (user_id);


--
-- Name: affectationanalytique affectationanalytique_id_centre_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affectationanalytique
    ADD CONSTRAINT affectationanalytique_id_centre_foreign FOREIGN KEY (id_centre) REFERENCES public.centreanalytique(id_centre) ON DELETE CASCADE;


--
-- Name: affectationanalytique affectationanalytique_id_code_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affectationanalytique
    ADD CONSTRAINT affectationanalytique_id_code_foreign FOREIGN KEY (id_code) REFERENCES public.code_analytique(id_code) ON DELETE CASCADE;


--
-- Name: affectationanalytique affectationanalytique_id_sous_compte_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affectationanalytique
    ADD CONSTRAINT affectationanalytique_id_sous_compte_foreign FOREIGN KEY ("Id_Sous_compte") REFERENCES public.sous_comptes("Id_Sous_compte") ON DELETE CASCADE;


--
-- Name: affectationanalytique affectationanalytique_id_type_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.affectationanalytique
    ADD CONSTRAINT affectationanalytique_id_type_foreign FOREIGN KEY (id_type) REFERENCES public.typecentre(id_type);


--
-- Name: categorie_fonctionelles categorie_fonctionelles_id_duree_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie_fonctionelles
    ADD CONSTRAINT categorie_fonctionelles_id_duree_foreign FOREIGN KEY (id_duree) REFERENCES public.durees(id_duree);


--
-- Name: categorie_fonctionelles categorie_fonctionelles_id_fonction_economique_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie_fonctionelles
    ADD CONSTRAINT categorie_fonctionelles_id_fonction_economique_foreign FOREIGN KEY (id_fonction_economique) REFERENCES public.fonction_economiques(id_fonction_economique);


--
-- Name: categorie_fonctionelles categorie_fonctionelles_id_nature_comptable_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie_fonctionelles
    ADD CONSTRAINT categorie_fonctionelles_id_nature_comptable_foreign FOREIGN KEY (id_nature_comptable) REFERENCES public.nature_comptables(id_nature_comptable);


--
-- Name: categorie_fonctionelles categorie_fonctionelles_id_type_categorie_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.categorie_fonctionelles
    ADD CONSTRAINT categorie_fonctionelles_id_type_categorie_foreign FOREIGN KEY (id_type_categorie) REFERENCES public.type_categories(id_type_categorie);


--
-- Name: centreanalytique centreanalytique_id_axe_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.centreanalytique
    ADD CONSTRAINT centreanalytique_id_axe_foreign FOREIGN KEY (id_axe) REFERENCES public.axesanalytique(id_axe) ON DELETE CASCADE;


--
-- Name: chat_messages chat_messages_user_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.chat_messages
    ADD CONSTRAINT chat_messages_user_id_foreign FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;


--
-- Name: compte_categories compte_categories_id_sous_compte_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.compte_categories
    ADD CONSTRAINT compte_categories_id_sous_compte_foreign FOREIGN KEY (id_sous_compte) REFERENCES public.sous_comptes("Id_Sous_compte");


--
-- Name: comptes comptes_id_rubrique_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.comptes
    ADD CONSTRAINT comptes_id_rubrique_foreign FOREIGN KEY ("Id_Rubrique") REFERENCES public.rubriques("Id_Rubrique") ON DELETE CASCADE;


--
-- Name: evenements evenements_type_evenement_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.evenements
    ADD CONSTRAINT evenements_type_evenement_id_foreign FOREIGN KEY (type_evenement_id) REFERENCES public.types_evenement(id);


--
-- Name: immobilisations immobilisations_id_sous_compte_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.immobilisations
    ADD CONSTRAINT immobilisations_id_sous_compte_foreign FOREIGN KEY ("Id_Sous_compte") REFERENCES public.sous_comptes("Id_Sous_compte") ON DELETE CASCADE;


--
-- Name: immobilisations immobilisations_taux_amortissement_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.immobilisations
    ADD CONSTRAINT immobilisations_taux_amortissement_id_foreign FOREIGN KEY (taux_amortissement_id) REFERENCES public.taux_amortissement(id) ON DELETE RESTRICT;


--
-- Name: interpretation_indicateur interpretation_indicateur_id_indicateur_analytique_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interpretation_indicateur
    ADD CONSTRAINT interpretation_indicateur_id_indicateur_analytique_foreign FOREIGN KEY (id_indicateur_analytique) REFERENCES public.indicateurs_analytique(id_indicateur_analytique) ON DELETE CASCADE;


--
-- Name: interpretation_indicateur interpretation_indicateur_id_niveau_alerte_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.interpretation_indicateur
    ADD CONSTRAINT interpretation_indicateur_id_niveau_alerte_foreign FOREIGN KEY (id_niveau_alerte) REFERENCES public.niveau_alerte(id_niveau_alerte) ON DELETE CASCADE;


--
-- Name: intervalle_comptes_categorie intervalle_comptes_categorie_id_categorie_fonctionelle_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.intervalle_comptes_categorie
    ADD CONSTRAINT intervalle_comptes_categorie_id_categorie_fonctionelle_fkey FOREIGN KEY (id_categorie_fonctionelle) REFERENCES public.categorie_fonctionelles(id_categorie_fonctionelle);


--
-- Name: journals journals_id_sous_compte_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journals
    ADD CONSTRAINT journals_id_sous_compte_foreign FOREIGN KEY ("Id_Sous_compte") REFERENCES public.sous_comptes("Id_Sous_compte");


--
-- Name: journals journals_id_type_journal_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.journals
    ADD CONSTRAINT journals_id_type_journal_foreign FOREIGN KEY ("Id_Type_Journal") REFERENCES public.type_journals("Id_Type_Journal");


--
-- Name: ligne_ecritures ligne_ecritures_id_journal_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ligne_ecritures
    ADD CONSTRAINT ligne_ecritures_id_journal_foreign FOREIGN KEY ("Id_Journal") REFERENCES public.journals("Id_Journal");


--
-- Name: ligne_ecritures ligne_ecritures_id_mode_paiement_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ligne_ecritures
    ADD CONSTRAINT ligne_ecritures_id_mode_paiement_foreign FOREIGN KEY ("Id_Mode_paiement") REFERENCES public.mode_paiements("Id_Mode_paiement");


--
-- Name: ligne_ecritures ligne_ecritures_id_mouvement_ecriture_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ligne_ecritures
    ADD CONSTRAINT ligne_ecritures_id_mouvement_ecriture_foreign FOREIGN KEY ("Id_Mouvement_ecriture") REFERENCES public.mouvement_ecritures("Id_Mouvement_ecriture");


--
-- Name: ligne_ecritures ligne_ecritures_id_sous_compte_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ligne_ecritures
    ADD CONSTRAINT ligne_ecritures_id_sous_compte_foreign FOREIGN KEY ("Id_Sous_compte") REFERENCES public.sous_comptes("Id_Sous_compte");


--
-- Name: ligne_ecritures ligne_ecritures_valide_par_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.ligne_ecritures
    ADD CONSTRAINT ligne_ecritures_valide_par_foreign FOREIGN KEY (valide_par) REFERENCES public.users(id) ON DELETE SET NULL;


--
-- Name: mouvement_ecritures mouvement_ecritures_id_journal_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.mouvement_ecritures
    ADD CONSTRAINT mouvement_ecritures_id_journal_foreign FOREIGN KEY ("Id_Journal") REFERENCES public.journals("Id_Journal");


--
-- Name: notifications notifications_evenement_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_evenement_id_foreign FOREIGN KEY (evenement_id) REFERENCES public.evenements(id);


--
-- Name: notifications notifications_niveau_urgence_id_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_niveau_urgence_id_foreign FOREIGN KEY (niveau_urgence_id) REFERENCES public.niveaux_urgence(id);


--
-- Name: rubriques rubriques_id_classe_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.rubriques
    ADD CONSTRAINT rubriques_id_classe_foreign FOREIGN KEY ("Id_Classe") REFERENCES public.classes("Id_Classe") ON DELETE CASCADE;


--
-- Name: sous_comptes sous_comptes_id_compte_foreign; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.sous_comptes
    ADD CONSTRAINT sous_comptes_id_compte_foreign FOREIGN KEY ("Id_Compte") REFERENCES public.comptes("Id_Compte") ON DELETE CASCADE;


--
-- Name: mv_analyse_mensuelle; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_analyse_mensuelle;


--
-- Name: mv_analyse_trimestrielle; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_analyse_trimestrielle;


--
-- Name: mv_comparaison_annuelle; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_comparaison_annuelle;


--
-- Name: mv_comparaison_cout_profit; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_comparaison_cout_profit;


--
-- Name: mv_evolution_12_mois; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_evolution_12_mois;


--
-- Name: mv_stats_globales_temporelles; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: postgres
--

REFRESH MATERIALIZED VIEW public.mv_stats_globales_temporelles;


--
-- PostgreSQL database dump complete
--

