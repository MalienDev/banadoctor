# Frontend Web BanaDoctor

Ce projet est construit avec [Next.js](https://nextjs.org/) 14+ en utilisant l'App Router.

## 🚀 Démarrage rapide

### Prérequis

- Node.js 18+
- npm 9+ ou yarn 1.22+
- Accès à l'API BanaDoctor

### Installation

1. **Cloner le dépôt**
   ```bash
   git clone https://github.com/votre-org/banadoctor.git
   cd banadoctor/frontend-web
   ```

2. **Installer les dépendances**
   ```bash
   npm install
   # ou
   yarn install
   ```

3. **Configurer l'environnement**
   Créer un fichier `.env.local` à la racine du projet :
   ```env
   NEXT_PUBLIC_API_URL=http://localhost:8000/api
   NEXT_PUBLIC_APP_URL=http://localhost:3000
   NEXTAUTH_SECRET=your-secret-key
   NEXTAUTH_URL=http://localhost:3000
   ```

4. **Démarrer le serveur de développement**
   ```bash
   npm run dev
   # ou
   yarn dev
   ```

   L'application sera disponible à l'adresse [http://localhost:3000](http://localhost:3000)

## 🏗 Structure du projet

```
frontend-web/
├── app/                    # Dossier principal de l'application
│   ├── (auth)/             # Routes d'authentification
│   ├── (dashboard)/        # Tableau de bord utilisateur
│   ├── api/                # Routes API (serverless functions)
│   ├── favicon.ico
│   ├── globals.css         # Styles globaux
│   └── layout.tsx          # Layout racine
├── components/             # Composants partagés
│   ├── ui/                 # Composants UI réutilisables
│   ├── forms/              # Composants de formulaire
│   └── ...
├── lib/                   # Utilitaires et helpers
│   ├── api/               # Clients API
│   └── utils/             # Fonctions utilitaires
├── public/                # Fichiers statiques
├── styles/                # Fichiers SCSS/CSS
└── types/                 # Définitions de types TypeScript
```

## 🛠 Scripts disponibles

- `dev` - Démarrer le serveur de développement
- `build` - Compiler pour la production
- `start` - Démarrer le serveur de production
- `lint` - Exécuter ESLint
- `type-check` - Vérifier les types TypeScript
- `test` - Exécuter les tests
- `test:watch` - Exécuter les tests en mode watch
- `test:coverage` - Générer un rapport de couverture de test

## 🔌 Configuration

### Variables d'environnement

| Variable | Description | Valeur par défaut |
|----------|-------------|-------------------|
| `NEXT_PUBLIC_API_URL` | URL de l'API BanaDoctor | `http://localhost:8000/api` |
| `NEXT_PUBLIC_APP_URL` | URL de l'application | `http://localhost:3000` |
| `NEXTAUTH_SECRET` | Clé secrète pour l'authentification | |
| `NEXTAUTH_URL` | URL de base pour NextAuth | `http://localhost:3000` |

## 🎨 Thème et styles

L'application utilise [Tailwind CSS](https://tailwindcss.com/) pour le styling et [Shadcn/UI](https://ui.shadcn.com/) pour les composants UI.

### Personnalisation du thème

1. Modifier les couleurs dans `app/globals.css`
2. Mettre à jour la configuration de Tailwind dans `tailwind.config.js`

## 🔒 Authentification

L'authentification est gérée avec NextAuth.js et utilise JWT pour la session.

### Configuration requise

1. Configurer les fournisseurs d'authentification dans `app/api/auth/[...nextauth]/route.ts`
2. Définir les variables d'environnement nécessaires

## 📱 Responsive Design

L'application est conçue pour fonctionner sur tous les appareils. Les breakpoints par défaut de Tailwind sont utilisés :

- `sm`: 640px
- `md`: 768px
- `lg`: 1024px
- `xl`: 1280px
- `2xl`: 1536px

## 🧪 Tests

### Exécuter les tests

```bash
# Tous les tests
npm test

# Tests en mode watch
npm test -- --watch

# Couverture de code
npm run test:coverage
```

## 🚀 Déploiement

### Préparation pour la production

1. Construire l'application :
   ```bash
   npm run build
   ```

2. Vérifier la production localement :
   ```bash
   npm start
   ```

### Déploiement sur Vercel

1. Pousser le code sur votre dépôt Git
2. Connecter le dépôt à Vercel
3. Configurer les variables d'environnement dans les paramètres du projet Vercel
4. Déclencher un nouveau déploiement

## 🛠 Débogage

### Mode développement

```bash
# Activer les logs détaillés
DEBUG=next:* npm run dev
```

### Outils de développement

- [React Developer Tools](https://react.dev/learn/react-developer-tools)
- [Next.js DevTools](https://nextjs.org/blog/next-13-4#nextjs-turbopack-runtime-inspector)

## 🤝 Contribution

1. Créer une branche : `git checkout -b feature/nouvelle-fonctionnalite`
2. Faire un commit : `git commit -m 'Ajouter une nouvelle fonctionnalité'`
3. Pousser : `git push origin feature/nouvelle-fonctionnalite`
4. Créer une Pull Request

## 📄 Licence

[LICENSE](LICENSE)
