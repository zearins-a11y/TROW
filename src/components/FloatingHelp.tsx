import { useState } from 'react'
import { motion, AnimatePresence } from 'motion/react'
import { HelpCircle, X, Rocket, BookOpen, MessageCircle, Sparkles } from 'lucide-react'

interface GuideItem {
  icon: React.ReactNode
  title: string
  description: string
  link?: { hash: string; label: string }
}

const guides: GuideItem[] = [
  {
    icon: <Rocket size={18} />,
    title: 'Comece criando um projeto',
    description: 'Vá em Workspace, crie ou selecione um projeto, e adicione tarefas para a equipe.',
    link: { hash: '#workspace-settings', label: 'Ir para Workspace' }
  },
  {
    icon: <BookOpen size={18} />,
    title: 'Convide sua equipe',
    description: 'Em Times você pode adicionar membros com permissões específicas (gestor, membro, viewer).',
    link: { hash: '#team-management', label: 'Gerenciar Times' }
  },
  {
    icon: <Sparkles size={18} />,
    title: 'Configure permissões',
    description: 'No Editor de Papéis você define quem pode aprovar, criar, editar ou apenas visualizar cada módulo.',
    link: { hash: '#role-editor', label: 'Abrir Permissões' }
  },
  {
    icon: <MessageCircle size={18} />,
    title: 'Acompanhe a auditoria',
    description: 'Todos os eventos do sistema ficam registrados em Logs de Auditoria — quem fez o quê e quando.',
    link: { hash: '#audit-logs', label: 'Ver Auditoria' }
  },
]

export function FloatingHelp() {
  const [open, setOpen] = useState(false)
  const [seen, setSeen] = useState(() => {
    if (typeof window === 'undefined') return false
    return !!localStorage.getItem('aios-help-seen')
  })

  function handleClose() {
    setOpen(false)
    localStorage.setItem('aios-help-seen', '1')
    setSeen(true)
  }

  return (
    <>
      {/* Floating button */}
      <motion.button
        initial={{ scale: 0 }}
        animate={{ scale: 1 }}
        onClick={() => setOpen(true)}
        className={`fixed bottom-6 right-6 z-50 w-14 h-14 rounded-full bg-gradient-to-br from-blue-500 to-indigo-600 text-white shadow-lg hover:shadow-xl transition-shadow flex items-center justify-center ${
          seen ? '' : 'animate-pulse ring-4 ring-blue-300 ring-offset-2'
        }`}
        title="Ajuda"
      >
        <HelpCircle size={24} />
      </motion.button>

      {/* Panel */}
      <AnimatePresence>
        {open && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={handleClose}
              className="fixed inset-0 bg-black/40 z-50"
            />
            <motion.div
              initial={{ opacity: 0, y: 20, scale: 0.95 }}
              animate={{ opacity: 1, y: 0, scale: 1 }}
              exit={{ opacity: 0, y: 20, scale: 0.95 }}
              className="fixed bottom-24 right-6 z-50 w-96 max-w-[calc(100vw-3rem)] bg-white dark:bg-gray-800 rounded-2xl shadow-2xl border border-gray-200 dark:border-gray-700 overflow-hidden"
            >
              <div className="bg-gradient-to-r from-blue-600 to-indigo-600 p-4 text-white">
                <div className="flex items-center justify-between mb-1">
                  <h3 className="font-bold text-lg">Olá! 👋 Bem-vindo ao AIOS</h3>
                  <button
                    onClick={handleClose}
                    className="text-white/80 hover:text-white"
                  >
                    <X size={20} />
                  </button>
                </div>
                <p className="text-sm text-white/90">
                  Vamos te ajudar a configurar tudo em 4 passos simples.
                </p>
              </div>

              <div className="p-2 max-h-96 overflow-y-auto">
                {guides.map((g, idx) => (
                  <a
                    key={idx}
                    href={g.link?.hash || '#'}
                    onClick={handleClose}
                    className="flex items-start gap-3 p-3 rounded-lg hover:bg-gray-50 dark:hover:bg-gray-700 transition-colors"
                  >
                    <div className="w-9 h-9 rounded-lg bg-blue-50 dark:bg-blue-900/30 text-blue-600 dark:text-blue-300 flex items-center justify-center shrink-0">
                      {g.icon}
                    </div>
                    <div className="flex-1 min-w-0">
                      <p className="font-medium text-sm text-gray-900 dark:text-white">{g.title}</p>
                      <p className="text-xs text-gray-500 dark:text-gray-400 mt-0.5">{g.description}</p>
                      {g.link && (
                        <p className="text-xs text-blue-600 dark:text-blue-400 mt-1.5 font-medium">
                          {g.link.label} →
                        </p>
                      )}
                    </div>
                  </a>
                ))}
              </div>

              <div className="border-t border-gray-200 dark:border-gray-700 p-3 bg-gray-50 dark:bg-gray-900/50 flex items-center justify-between gap-3">
                <p className="text-xs text-gray-500 dark:text-gray-400">
                  Dúvidas? Fale com o suporte.
                </p>
                <a
                  href="mailto:suporte@aios.app?subject=Ajuda%20AIOS%20Command"
                  onClick={handleClose}
                  className="text-xs font-medium text-blue-600 dark:text-blue-400 hover:underline"
                >
                  suporte@aios.app →
                </a>
              </div>
            </motion.div>
          </>
        )}
      </AnimatePresence>
    </>
  )
}

export default FloatingHelp
