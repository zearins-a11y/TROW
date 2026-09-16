import { Building2, Users, Shield, FileText, LogOut } from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'
import { Button } from './ui'

/**
 * Global navigation bar - shown on every page for logged-in users.
 * Provides quick access to admin pages and logout.
 */
export function GlobalNav() {
  const { user, signOut } = useAuth()

  const handleSignOut = async () => {
    await signOut()
    window.location.hash = 'login'
  }

  const menuItems = [
    { hash: '#dashboard', label: 'Dashboard', icon: null },
    { hash: '#workspace-settings', label: 'Workspace', icon: Building2 },
    { hash: '#team-management', label: 'Times', icon: Users },
    { hash: '#role-editor', label: 'Permissões', icon: Shield },
    { hash: '#audit-logs', label: 'Auditoria', icon: FileText },
  ]

  const currentHash = window.location.hash || '#dashboard'

  return (
    <header className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 sticky top-0 z-40">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-14">
          <a href="#dashboard" className="flex items-center gap-3">
            <div className="w-9 h-9 rounded-lg bg-gradient-to-br from-primary to-secondary flex items-center justify-center">
              <span className="text-white font-bold">⚡</span>
            </div>
            <h1 className="text-base font-bold text-gray-900 dark:text-white">
              AIOS <span className="text-blue-600">Command</span> Center
            </h1>
          </a>

          {user && (
            <div className="flex items-center gap-3">
              <span className="text-sm text-gray-600 dark:text-gray-300 hidden sm:inline">
                {user.email}
              </span>
              <Button variant="ghost" size="sm" onClick={handleSignOut} title="Sair">
                <LogOut size={16} />
              </Button>
            </div>
          )}
        </div>

        <nav className="flex gap-1 pb-2 overflow-x-auto">
          {menuItems.map((item) => {
            const Icon = item.icon
            const isActive = currentHash === item.hash || (item.hash === '#dashboard' && currentHash === '')
            return (
              <a
                key={item.hash}
                href={item.hash}
                className={`flex items-center gap-2 px-3 py-1.5 rounded-md text-sm font-medium transition-colors whitespace-nowrap ${
                  isActive
                    ? 'bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300'
                    : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100 dark:text-gray-300 dark:hover:text-white dark:hover:bg-gray-700'
                }`}
              >
                {Icon && <Icon size={14} />}
                {item.label}
              </a>
            )
          })}
        </nav>
      </div>
    </header>
  )
}

export default GlobalNav
