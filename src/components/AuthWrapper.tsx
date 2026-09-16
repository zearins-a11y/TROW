import { useEffect } from 'react'
import { useAuth } from '../contexts/AuthContext'
import { Loader2 } from 'lucide-react'

interface AuthWrapperProps {
  children: React.ReactNode
}

/**
 * Wraps protected content - redirects to login if not authenticated
 * Uses a 3-second timeout to avoid infinite loading on Supabase issues
 */
export function AuthWrapper({ children }: AuthWrapperProps) {
  const { user, initialized } = useAuth()

  useEffect(() => {
    // Force initialized after 3s if Supabase is slow
    const timeout = setTimeout(() => {
      if (!initialized) {
        console.warn('Auth taking too long, redirecting anyway')
        window.location.hash = 'login'
      }
    }, 3000)
    return () => clearTimeout(timeout)
  }, [initialized])

  if (!initialized) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="flex flex-col items-center gap-4">
          <Loader2 className="w-8 h-8 text-blue-600 animate-spin" />
          <p className="text-sm text-gray-500 dark:text-gray-400">Carregando...</p>
        </div>
      </div>
    )
  }

  if (!user) {
    // Redirect to login
    window.location.hash = 'login'
    return null
  }

  return <>{children}</>
}

export default AuthWrapper
