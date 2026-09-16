import { Building2, Users, Shield, FileText, LogOut } from 'lucide-react'
import { useAuth } from '../contexts/AuthContext'
import { Button } from './ui'

interface AdminLayoutProps {
  children: React.ReactNode
  title: string
  subtitle?: string
}

export function AdminLayout({ children, title, subtitle }: AdminLayoutProps) {
  const { user, signOut } = useAuth()

  const menuItems = [
    { hash: '#dashboard', label: 'Dashboard', icon: null },
    { hash: '#workspace-settings', label: 'Workspace', icon: Building2 },
    { hash: '#team-management', label: 'Times', icon: Users },
    { hash: '#role-editor', label: 'Permissões', icon: Shield },
    { hash: '#audit-logs', label: 'Auditoria', icon: FileText },
  ]

  const handleSignOut = async () => {
    await signOut()
    window.location.hash = 'login'
  }

  return (
    <div className="min-h-screen bg-gray-50 dark:bg-gray-900">
      {/* Top Header */}
      <header className="bg-white dark:bg-gray-800 border-b border-gray-200 dark:border-gray-700 sticky top-0 z-40">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="flex items-center justify-between h-16">
            <div className="flex items-center gap-3">
              <a href="#dashboard" className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-gradient-to-br from-primary to-secondary flex items-center justify-center">
                  <span className="text-white font-bold text-lg">⚡</span>
                </div>
                <h1 className="text-lg font-bold text-gray-900 dark:text-white">
                  AIOS <span className="text-blue-600">Command</span> Center
                </h1>
              </a>
            </div>

            {user && (
              <div className="flex items-center gap-3">
                <span className="text-sm text-gray-600 dark:text-gray-300">
                  {user.email}
                </span>
                <Button variant="ghost" size="sm" onClick={handleSignOut}>
                  <LogOut size={18} />
                </Button>
              </div>
            )}
          </div>

          {/* Admin Nav */}
          <nav className="flex gap-1 pb-3 overflow-x-auto">
            {menuItems.map((item) => {
              const Icon = item.icon
              const currentHash = window.location.hash
              const isActive = currentHash === item.hash
              return (
                <a
                  key={item.hash}
                  href={item.hash}
                  className={`flex items-center gap-2 px-3 py-2 rounded-lg text-sm font-medium transition-colors whitespace-nowrap ${
                    isActive
                      ? 'bg-blue-50 text-blue-700 dark:bg-blue-900/30 dark:text-blue-300'
                      : 'text-gray-600 hover:text-gray-900 hover:bg-gray-100 dark:text-gray-300 dark:hover:text-white dark:hover:bg-gray-700'
                  }`}
                >
                  {Icon && <Icon size={16} />}
                  {item.label}
                </a>
              )
            })}
          </nav>
        </div>
      </header>

      {/* Main Content */}
      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="mb-6">
          <h2 className="text-2xl font-bold text-gray-900 dark:text-white">{title}</h2>
          {subtitle && <p className="text-gray-500 dark:text-gray-400 mt-1">{subtitle}</p>}
        </div>
        {children}
      </main>
    </div>
  )
}

export default AdminLayout
