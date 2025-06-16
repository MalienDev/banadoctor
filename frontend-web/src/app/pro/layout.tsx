import { Metadata } from 'next';
import { Inter } from 'next/font/google';
import Link from 'next/link';
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
              <li><Link href="/pro/dashboard">Tableau de bord</Link></li>
              <li><Link href="/pro/agenda">Agenda</Link></li>
              <li><Link href="/pro/rendez-vous">Rendez-vous</Link></li>
              <li><Link href="/pro/teleconsultation">Téléconsultation</Link></li>
              <li><Link href="/pro/messagerie">Messagerie</Link></li>
              <li><Link href="/pro/parametres">Paramètres</Link></li>
            </ul>
          </nav>
          <main className="pro-content">
            {children}
          </main>
        </div>
      </body>
    </html>
  );
}
