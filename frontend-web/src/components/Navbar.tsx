'use client';

import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useAuth } from '@/contexts/AuthContext';
import { useState, useEffect, useRef } from 'react';
import { BellIcon } from '@heroicons/react/24/outline';
import api from '@/lib/api';

// Notification type
type Notification = {
  id: number;
  recipient: number;
  message: string;
  notification_type: string;
  is_read: boolean;
  created_at: string;
};

// Define navigation links with roles
const navLinks = [
  { href: '/dashboard', label: 'Tableau de bord', roles: ['patient'] },
  { href: '/appointments', label: 'Mes rendez-vous', roles: ['patient'] },
  { href: '/doctors', label: 'Trouver un médecin', roles: ['patient'] },
  
  // Professional (doctor) links
  { href: '/pro/dashboard', label: 'Tableau de bord', roles: ['doctor'] },
  { href: '/pro/appointments', label: 'Mes consultations', roles: ['doctor'] },
  // Add other professional links here, e.g.:
  // { href: '/pro/schedule', label: 'Mon agenda', roles: ['doctor'] },
];

const Navbar = () => {
  const { user, logout, isAuthenticated } = useAuth();
  const pathname = usePathname();
  const [isDropdownOpen, setIsDropdownOpen] = useState(false);
  const [notifications, setNotifications] = useState<Notification[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);
  const dropdownRef = useRef<HTMLDivElement>(null);

  const fetchNotifications = async () => {
    if (!isAuthenticated) return;
    try {
      const res = await api.get('/notifications/');
      setNotifications(res.data.results);
      const unread = res.data.results.filter((n: Notification) => !n.is_read).length;
      setUnreadCount(unread);
    } catch (error) {
      console.error('Failed to fetch notifications:', error);
    }
  };

  useEffect(() => {
    fetchNotifications();
    const interval = setInterval(fetchNotifications, 30000); // Poll every 30 seconds
    return () => clearInterval(interval);
  }, [isAuthenticated]);

  useEffect(() => {
    const handleClickOutside = (event: MouseEvent) => {
      if (dropdownRef.current && !dropdownRef.current.contains(event.target as Node)) {
        setIsDropdownOpen(false);
      }
    };
    document.addEventListener('mousedown', handleClickOutside);
    return () => document.removeEventListener('mousedown', handleClickOutside);
  }, []);

  const markAsRead = async (id: number) => {
    try {
      await api.post(`/notifications/${id}/mark-as-read/`);
      fetchNotifications(); // Refresh list
    } catch (error) {
      console.error('Failed to mark notification as read:', error);
    }
  };

  const markAllAsRead = async () => {
    try {
      await api.post('/notifications/mark-all-as-read/');
      fetchNotifications(); // Refresh list
      setIsDropdownOpen(false);
    } catch (error) {
      console.error('Failed to mark all notifications as read:', error);
    }
  };

  const isActive = (path: string) => {
    return pathname === path ? 'bg-gray-900 text-white' : 'text-gray-300 hover:bg-gray-700 hover:text-white';
  };

  if (!isAuthenticated || !user) {
    return null;
  }

  // Filter links based on user role
  const visibleLinks = navLinks.filter(link => link.roles.includes(user.user_type));

  return (
    <nav className="bg-gray-800">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          <div className="flex items-center">
            <div className="flex-shrink-0">
              <Link href={user.user_type === 'doctor' ? '/pro/dashboard' : '/dashboard'} className="text-white font-bold">
                BanaDoctor
              </Link>
            </div>
            <div className="hidden md:block">
              <div className="ml-10 flex items-baseline space-x-4">
                {visibleLinks.map((link) => (
                  <Link
                    key={link.href}
                    href={link.href}
                    className={`px-3 py-2 rounded-md text-sm font-medium ${isActive(link.href)}`}
                  >
                    {link.label}
                  </Link>
                ))}
              </div>
            </div>
          </div>
          <div className="hidden md:block">
            <div className="ml-4 flex items-center md:ml-6">
              {/* Notification dropdown */}
              <div className="relative" ref={dropdownRef}>
                <button 
                  onClick={() => setIsDropdownOpen(!isDropdownOpen)}
                  className="p-1 rounded-full text-gray-400 hover:text-white focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-white"
                >
                  <span className="sr-only">View notifications</span>
                  <BellIcon className="h-6 w-6" aria-hidden="true" />
                  {unreadCount > 0 && (
                    <span className="absolute top-0 right-0 block h-2 w-2 rounded-full bg-red-500 ring-2 ring-white" />
                  )}
                </button>
                {isDropdownOpen && (
                  <div className="origin-top-right absolute right-0 mt-2 w-80 rounded-md shadow-lg py-1 bg-white ring-1 ring-black ring-opacity-5 z-50">
                    <div className="px-4 py-2 text-sm text-gray-700 font-bold flex justify-between items-center">
                      <span>Notifications</span>
                      {notifications.length > 0 && <button onClick={markAllAsRead} className='text-xs text-blue-500 hover:underline'>Tout marquer comme lu</button>}
                    </div>
                    <div className="divide-y divide-gray-100 max-h-96 overflow-y-auto">
                      {notifications.length > 0 ? notifications.map(n => (
                        <div key={n.id} className={`p-4 text-sm ${!n.is_read ? 'bg-blue-50' : ''}`}>
                          <p className='text-gray-800'>{n.message}</p>
                          <div className="flex justify-between items-center mt-2">
                            <span className='text-xs text-gray-500'>{new Date(n.created_at).toLocaleString()}</span>
                            {!n.is_read && <button onClick={() => markAsRead(n.id)} className='text-xs text-blue-500 hover:underline'>Marquer comme lu</button>}
                          </div>
                        </div>
                      )) : (
                        <p className="text-center text-gray-500 py-4">Aucune notification.</p>
                      )}
                    </div>
                  </div>
                )}
              </div>

              <div className="ml-3 relative">
                <div className="flex items-center">
                  <span className="text-white mr-4">
                    {user.first_name} {user.last_name}
                  </span>
                  <button
                    onClick={logout}
                    className="bg-red-600 hover:bg-red-700 text-white px-4 py-2 rounded-md text-sm font-medium"
                  >
                    Déconnexion
                  </button>
                </div>
              </div>
            </div>
          </div>
          <div className="-mr-2 flex md:hidden">
            {/* Mobile menu button */}
            <button
              type="button"
              className="bg-gray-800 inline-flex items-center justify-center p-2 rounded-md text-gray-400 hover:text-white hover:bg-gray-700 focus:outline-none focus:ring-2 focus:ring-offset-2 focus:ring-offset-gray-800 focus:ring-white"
              aria-controls="mobile-menu"
              aria-expanded="false"
            >
              <span className="sr-only">Open main menu</span>
              {/* Icon when menu is closed */}
              <svg
                className="block h-6 w-6"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M4 6h16M4 12h16M4 18h16"
                />
              </svg>
              {/* Icon when menu is open */}
              <svg
                className="hidden h-6 w-6"
                xmlns="http://www.w3.org/2000/svg"
                fill="none"
                viewBox="0 0 24 24"
                stroke="currentColor"
                aria-hidden="true"
              >
                <path
                  strokeLinecap="round"
                  strokeLinejoin="round"
                  strokeWidth={2}
                  d="M6 18L18 6M6 6l12 12"
                />
              </svg>
            </button>
          </div>
        </div>
      </div>

      {/* Mobile menu, show/hide based on menu state */}
      <div className="md:hidden hidden" id="mobile-menu">
        <div className="px-2 pt-2 pb-3 space-y-1 sm:px-3">
          {visibleLinks.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className={`block px-3 py-2 rounded-md text-base font-medium ${isActive(link.href)}`}
            >
              {link.label}
            </Link>
          ))}
        </div>
        <div className="pt-4 pb-3 border-t border-gray-700">
          <div className="flex items-center px-5">
            <div className="ml-3">
              <div className="text-base font-medium text-white">
                {user.first_name} {user.last_name}
              </div>
              <div className="text-sm font-medium text-gray-400">
                {user.email}
              </div>
            </div>
          </div>
          <div className="mt-3 px-2 space-y-1">
            <button
              onClick={logout}
              className="block w-full text-left px-3 py-2 rounded-md text-base font-medium text-gray-400 hover:text-white hover:bg-gray-700"
            >
              Déconnexion
            </button>
          </div>
        </div>
      </div>
    </nav>
  );
};

export default Navbar;
