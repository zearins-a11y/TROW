import { useState, useEffect } from 'react'
import { motion } from 'motion/react'
import { Mail, Copy, Check, X } from 'lucide-react'
import { Button, Input } from './ui'
import { supabase, isSupabaseConfigured } from '../lib/supabase'
import { auth } from '../lib/auth'
import { logAudit } from '../lib/audit'

interface InviteModalProps {
  open: boolean
  onClose: () => void
  teamId: string
  teamName: string
  onSent?: () => void
}

interface Role {
  id: string
  name: string
  description: string
}

/**
 * InviteModal - Send email or generate a shareable link to invite members to a team.
 * Auto-generates a token that expires in 7 days.
 */
export function InviteModal({ open, onClose, teamId, teamName, onSent }: InviteModalProps) {
  const [email, setEmail] = useState('')
  const [roleId, setRoleId] = useState('')
  const [roles, setRoles] = useState<Role[]>([])
  const [saving, setSaving] = useState(false)
  const [generatedLink, setGeneratedLink] = useState<string | null>(null)
  const [copied, setCopied] = useState(false)
  const [error, setError] = useState<string | null>(null)

  useEffect(() => {
    if (!open) return
    loadRoles()
  }, [open])

  async function loadRoles() {
    if (!isSupabaseConfigured || !supabase) return
    const { data } = await supabase.from('roles').select('*').eq('is_system', true).order('name')
    if (data && data.length > 0) {
      setRoles(data)
      if (!roleId) setRoleId(data[0].id)
    }
  }

  function generateToken(): string {
    return Array.from(crypto.getRandomValues(new Uint8Array(24)))
      .map((b) => b.toString(16).padStart(2, '0'))
      .join('')
  }

  async function handleGenerate() {
    setError(null)

    if (!isSupabaseConfigured || !supabase) {
      setError('Supabase não configurado')
      return
    }

    if (!email.trim()) {
      setError('Informe um email válido')
      return
    }

    if (!roleId) {
      setError('Selecione um papel para o convidado')
      return
    }

    setSaving(true)
    try {
      const user = await auth.getUser()
      if (!user) throw new Error('Usuário não autenticado')

      const token = generateToken()
      const expiresAt = new Date(Date.now() + 7 * 24 * 60 * 60 * 1000).toISOString()

      const { data, error: insertError } = await supabase
        .from('invitations')
        .insert({
          team_id: teamId,
          email: email.trim().toLowerCase(),
          role_id: roleId,
          invited_by: user.id,
          token,
          status: 'pending',
          expires_at: expiresAt,
        })
        .select()
        .single()

      if (insertError) {
        console.error('[InviteModal] insert error:', insertError)
        throw new Error(`Falha ao criar convite: ${insertError.message}`)
      }

      // Audit log: separate try/catch so a failing log doesn't block the invite UX
      try {
        await logAudit({
          action: 'create',
          module: 'team',
          resourceType: 'invitation',
          resourceId: data.id,
          newValue: { email: data.email, role_id: data.role_id, team_id: data.team_id },
        })
      } catch (auditErr: any) {
        console.warn('[InviteModal] audit failed but invite was created:', auditErr)
      }

      const link = `${window.location.origin}/#accept-invite?token=${data.token}`
      setGeneratedLink(link)
      onSent?.()
    } catch (err: any) {
      console.error('[InviteModal] generate failed:', err)
      setError(err.message || 'Erro ao gerar convite')
    } finally {
      setSaving(false)
    }
  }

  async function copyLink() {
    if (!generatedLink) return
    await navigator.clipboard.writeText(generatedLink)
    setCopied(true)
    setTimeout(() => setCopied(false), 2000)
  }

  function handleClose() {
    setEmail('')
    setError(null)
    setGeneratedLink(null)
    setCopied(false)
    onClose()
  }

  if (!open) return null

  return (
    <div className="fixed inset-0 z-50 flex items-center justify-center p-4 bg-black/40">
      <motion.div
        initial={{ opacity: 0, scale: 0.95 }}
        animate={{ opacity: 1, scale: 1 }}
        className="bg-white dark:bg-gray-800 rounded-2xl shadow-2xl max-w-md w-full overflow-hidden"
      >
        <div className="bg-gradient-to-r from-blue-600 to-indigo-600 p-5 text-white">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-full bg-white/20 flex items-center justify-center">
                <Mail size={20} />
              </div>
              <div>
                <h3 className="font-bold text-lg">Convidar membro</h3>
                <p className="text-sm text-white/80">{teamName}</p>
              </div>
            </div>
            <button onClick={handleClose} className="text-white/80 hover:text-white">
              <X size={20} />
            </button>
          </div>
        </div>

        <div className="p-6 space-y-4">
          {!generatedLink ? (
            <>
              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Email do convidado
                </label>
                <Input
                  type="email"
                  placeholder="colega@empresa.com"
                  value={email}
                  onChange={(e) => setEmail(e.target.value)}
                  autoFocus
                />
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Papel
                </label>
                <select
                  value={roleId}
                  onChange={(e) => setRoleId(e.target.value)}
                  className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg dark:bg-gray-700 dark:text-white"
                >
                  {roles.map((r) => (
                    <option key={r.id} value={r.id}>
                      {r.name.replace('_', ' ')} — {r.description}
                    </option>
                  ))}
                </select>
              </div>

              {error && (
                <div className="text-sm text-red-600 dark:text-red-400 bg-red-50 dark:bg-red-900/20 p-3 rounded-lg">
                  {error}
                </div>
              )}

              <div className="flex gap-2">
                <Button variant="secondary" onClick={handleClose} className="flex-1">
                  Cancelar
                </Button>
                <Button onClick={handleGenerate} disabled={saving} className="flex-1">
                  {saving ? 'Gerando...' : 'Gerar convite'}
                </Button>
              </div>

              <p className="text-xs text-gray-500 text-center">
                O convite expira em 7 dias. Compartilhe o link gerado com segurança.
              </p>
            </>
          ) : (
            <motion.div
              initial={{ opacity: 0, y: 10 }}
              animate={{ opacity: 1, y: 0 }}
              className="space-y-4"
            >
              <div className="bg-green-50 dark:bg-green-900/20 border border-green-200 dark:border-green-800 rounded-lg p-4">
                <p className="text-sm font-medium text-green-800 dark:text-green-200 mb-1">
                  ✓ Convite criado!
                </p>
                <p className="text-xs text-green-700 dark:text-green-300">
                  Envie o link abaixo para <strong>{email}</strong> entrar em <strong>{teamName}</strong>.
                </p>
              </div>

              <div>
                <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
                  Link de convite
                </label>
                <div className="flex gap-2">
                  <Input
                    value={generatedLink}
                    readOnly
                    onClick={(e) => e.currentTarget.select()}
                    className="text-xs font-mono"
                  />
                  <Button onClick={copyLink} variant="secondary" size="sm">
                    {copied ? <Check size={16} className="text-green-600" /> : <Copy size={16} />}
                  </Button>
                </div>
              </div>

              <Button onClick={handleClose} className="w-full">
                Concluído
              </Button>
            </motion.div>
          )}
        </div>
      </motion.div>
    </div>
  )
}

export default InviteModal
