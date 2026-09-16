import React from 'react';
import ReactDOM from 'react-dom/client';
import App from './App';
import './index.css';
import { PersistenceInit } from './components/PersistenceInit';
import { ConflictModal } from './components/SyncButton';
import { AuthProvider } from './contexts/AuthContext';
import { PermissionsProvider } from './contexts/PermissionsContext';

// Unregister any stale Service Workers (they interfere with OAuth callback)
if ('serviceWorker' in navigator) {
  navigator.serviceWorker.getRegistrations().then((registrations) => {
    registrations.forEach((registration) => {
      registration.unregister().catch(() => {})
    })
  })
  // Also clear caches from old SW
  if ('caches' in window) {
    caches.keys().then((keys) => {
      keys.forEach((key) => {
        if (key.includes('workbox') || key.includes('pwa')) {
          caches.delete(key).catch(() => {})
        }
      })
    })
  }
}

ReactDOM.createRoot(document.getElementById('root')!).render(
  <React.StrictMode>
    <AuthProvider>
      <PermissionsProvider>
        <PersistenceInit>
          <App />
          <ConflictModal />
        </PersistenceInit>
      </PermissionsProvider>
    </AuthProvider>
  </React.StrictMode>
);
