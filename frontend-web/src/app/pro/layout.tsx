import { Metadata } from 'next';
import { Inter } from 'next/font/google';
import './pro-layout.css';

const inter = Inter({ subsets: ['latin'] });

export const metadata: Metadata = {
  title: 'BanaDoctor Pro - Espace Professionnel',
  description: 'Espace professionnel pour les médecins de BanaDoctor',
};

export default function ProLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <html lang="fr">
      <body className={`${inter.className} antialiased`}>
        <div className="pro-layout">
          <nav className="pro-sidebar">
            <div className="logo">BanaDoctor Pro</div>
            <ul>
              <li><a href="/pro/dashboard">Tableau de bord</a></li>
              <li><a href="/pro/agenda">Agenda</a></li>
              <li><a href="/pro/rendez-vous">Rendez-vous</a></li>
              <li><a href="/pro/teleconsultation">Téléconsultation</a></li>
              <li><a href="/pro/messagerie">Messagerie</a></li>
              <li><a href="/pro/parametres">Paramètres</a></li>
            </ul>
          </nav>
          <main className="pro-content">
            <header className="pro-header">
              <div className="user-info">
                <span>Dr. Nom Prénom</span>
                <button>Déconnexion</button>
              </div>
            </header>
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
