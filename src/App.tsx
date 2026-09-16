import { useEffect, useRef, useState } from 'react';
import { Portfolio, ProjectDashboard, Governance, AgentEvaluation, StrikeSystem, ThresholdSystem, Appeals, FeedbackLoop, Council, PublicExceptions, RegionalAdaptation, HealthMetrics } from './pages';
import { ToastContainer } from './components/ui';
import { GlobalNav } from './components/GlobalNav';
import { FloatingHelp } from './components/FloatingHelp';
import { useStore } from './stores/useStore';
import { useAuth } from './contexts/AuthContext';
import Login from './pages/Login';
import Signup from './pages/Signup';
import AcceptInvite from './pages/AcceptInvite';
import TeamManagement from './pages/admin/TeamManagement';
import AuditLogs from './pages/admin/AuditLogs';
import WorkspaceSettings from './pages/admin/WorkspaceSettings';
import RoleEditor from './pages/admin/RoleEditor';

function App() {
  const { currentPage, setCurrentPage } = useStore();
  const { user, initialized } = useAuth();
  const isInitialMount = useRef(true);
  const [forceLoaded, setForceLoaded] = useState(false);

  // Force finish loading after 3 seconds to prevent infinite spinner
  useEffect(() => {
    const timer = setTimeout(() => setForceLoaded(true), 3000);
    return () => clearTimeout(timer);
  }, []);

  // Check if we're on an auth page based on URL hash
  const hash = window.location.hash.replace('#', '');
  const isAuthPage = hash === 'login' || hash === 'signup' || hash === 'accept-invite';

  // Sync URL hash with current page (on first load and hash change)
  useEffect(() => {
    const syncFromHash = () => {
      const newHash = window.location.hash.replace('#', '');
      // Strip query params from hash (Supabase OAuth callback may include them)
      const cleanHash = newHash.split('?')[0];
      if (cleanHash && ['portfolio', 'dashboard', 'governance', 'agent-evaluation', 'strike-system', 'threshold-system', 'appeals', 'feedback-loop', 'council', 'public-exceptions', 'regional-adaptation', 'health-metrics'].includes(cleanHash)) {
        if (cleanHash !== currentPage) {
          setCurrentPage(cleanHash as any);
        }
      }
    };

    // Initial sync
    if (isInitialMount.current) {
      syncFromHash();
      isInitialMount.current = false;
    }

    // Listen for hash changes
    window.addEventListener('hashchange', syncFromHash);
    return () => window.removeEventListener('hashchange', syncFromHash);
  }, [setCurrentPage]);

  // Detect OAuth callback in URL and clean it up
  useEffect(() => {
    const hash = window.location.hash;
    if (hash.includes('access_token') || hash.includes('error_description')) {
      // Clean the hash and go to dashboard
      window.location.hash = 'dashboard';
    }
  }, []);

  // If not on auth page and not authenticated, redirect to login
  useEffect(() => {
    const isReady = initialized || forceLoaded;
    if (isReady && !user && !isAuthPage) {
      window.location.hash = 'login';
    }
  }, [initialized, user, isAuthPage, forceLoaded]);

  // Auth pages
  if (isAuthPage) {
    if (hash === 'login') return <Login />;
    if (hash === 'signup') return <Signup />;
    if (hash === 'accept-invite') return <AcceptInvite />;
  }

  // Show loading only briefly while auth initializes
  const isReady = initialized || forceLoaded;
  if (!isReady) {
    return (
      <div className="min-h-screen flex items-center justify-center bg-gray-50 dark:bg-gray-900">
        <div className="flex flex-col items-center gap-4">
          <div className="w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full animate-spin"></div>
          <p className="text-sm text-gray-500 dark:text-gray-400">Carregando...</p>
        </div>
      </div>
    );
  }

  // If user is not authenticated and not on auth page, don't render protected content
  if (!user) {
    return null; // redirect will happen via useEffect
  }

  // Admin pages
  if (hash === 'team-management') return <><TeamManagement /><FloatingHelp /></>;
  if (hash === 'audit-logs') return <><AuditLogs /><FloatingHelp /></>;
  if (hash === 'workspace-settings') return <><WorkspaceSettings /><FloatingHelp /></>;
  if (hash === 'role-editor') return <><RoleEditor /><FloatingHelp /></>;

  // Standalone pages
  if (currentPage === 'governance') {
    return (
      <>
        <GlobalNav />
        <Governance />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  if (currentPage === 'agent-evaluation') {
    return (
      <>
        <GlobalNav />
        <AgentEvaluation />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  if (currentPage === 'strike-system') {
    return (
      <>
        <GlobalNav />
        <StrikeSystem />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  if (currentPage === 'threshold-system') {
    return (
      <>
        <GlobalNav />
        <ThresholdSystem />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  if (currentPage === 'appeals') {
    return (
      <>
        <GlobalNav />
        <Appeals />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  if (currentPage === 'feedback-loop') {
    return (
      <>
        <GlobalNav />
        <FeedbackLoop />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  if (currentPage === 'council') {
    return (
      <>
        <GlobalNav />
        <Council />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  if (currentPage === 'public-exceptions') {
    return (
      <>
        <GlobalNav />
        <PublicExceptions />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  if (currentPage === 'regional-adaptation') {
    return (
      <>
        <GlobalNav />
        <RegionalAdaptation />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  if (currentPage === 'health-metrics') {
    return (
      <>
        <GlobalNav />
        <HealthMetrics />
        <ToastContainer />
        <FloatingHelp />
      </>
    );
  }

  return (
    <>
      <GlobalNav />
      {currentPage === 'portfolio' ? <Portfolio /> : <ProjectDashboard />}
      <ToastContainer />
      <FloatingHelp />
    </>
  );
}

export default App;
