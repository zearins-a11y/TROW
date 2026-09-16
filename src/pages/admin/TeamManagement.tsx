import { useState, useEffect } from 'react'
import { motion } from 'motion/react'
import { Users, Plus, Trash2, Shield, Mail, MoreVertical } from 'lucide-react'
import { Button, Input, Modal, Badge } from '../../components/ui'
import { AdminLayout } from '../../components/AdminLayout'
import { InviteModal } from '../../components/InviteModal'
import { usePermissions } from '../../contexts/PermissionsContext'
import { supabase, isSupabaseConfigured } from '../../lib/supabase'

interface Team {
  id: string
  name: string
  description: string
  project_id: string
  member_count: number
}

interface TeamMember {
  id: string
  user_id: string
  user_email: string
  user_name: string
  role_name: string
  role_id: string
}

export default function TeamManagement() {
  const { permissions, loading: permissionsLoading, checkGestor } = usePermissions()
  const [teams, setTeams] = useState<Team[]>([])
  const [loading, setLoading] = useState(true)
  const [selectedTeam, setSelectedTeam] = useState<Team | null>(null)
  const [members, setMembers] = useState<TeamMember[]>([])
  const [showCreateTeam, setShowCreateTeam] = useState(false)
  const [showInviteModal, setShowInviteModal] = useState(false)
  const [newTeamName, setNewTeamName] = useState('')
  const [newTeamDesc, setNewTeamDesc] = useState('')
  const [saving, setSaving] = useState(false)

  const isGestor = checkGestor()

  // Load all teams the user can see (filtered by workspace for non-admins, all for super_admin)
  useEffect(() => {
    if (!isSupabaseConfigured || !permissions?.workspaceId) return
    loadTeams()
  }, [permissions?.workspaceId, permissions?.projectId])

  async function loadTeams() {
    if (!isSupabaseConfigured || !supabase) return

    setLoading(true)
    try {
      // For super_admin (no project_id), fetch teams across all projects in workspace
      // For regular users, filter by their project_id
      let query = supabase.from('teams').select('*')

      if (permissions?.projectId) {
        query = query.eq('project_id', permissions.projectId)
      } else if (permissions?.workspaceId) {
        // Get projects in workspace first, then filter teams by those project_ids
        const { data: projects } = await supabase
          .from('projects')
          .select('id')
          .eq('workspace_id', permissions.workspaceId)

        const projectIds = projects?.map((p) => p.id) || []
        if (projectIds.length === 0) {
          setTeams([])
          setLoading(false)
          return
        }
        query = query.in('project_id', projectIds)
      }

      const { data, error } = await query

      if (!error && data) {
        // Get member counts for each team
        const teamsWithCounts = await Promise.all(
          data.map(async (team) => {
            const { count } = await supabase!
              .from('team_members')
              .select('*', { count: 'exact', head: true })
              .eq('team_id', team.id)

            return { ...team, member_count: count || 0 }
          })
        )
        setTeams(teamsWithCounts)
      } else {
        console.error('[TeamManagement] loadTeams error:', error)
      }
    } catch (error) {
      console.error('[TeamManagement] loadTeams failed:', error)
    } finally {
      setLoading(false)
    }
  }

  async function loadTeamMembers(teamId: string) {
    if (!isSupabaseConfigured || !supabase) return

    const { data, error } = await supabase
      .from('team_members')
      .select(`
        id,
        user_id,
        roles:role_id (name),
        user_profiles:user_id (email, full_name)
      `)
      .eq('team_id', teamId)

    if (!error && data) {
      setMembers(
        data.map((m) => ({
          id: m.id,
          user_id: m.user_id,
          user_email: (m.user_profiles as any)?.email || '',
          user_name: (m.user_profiles as any)?.full_name || (m.user_profiles as any)?.email?.split('@')[0] || '',
          role_name: (m.roles as any)?.name || '',
          role_id: (m as any).role_id,
        }))
      )
    }
  }

  function handleSelectTeam(team: Team) {
    setSelectedTeam(team)
    loadTeamMembers(team.id)
  }

  async function handleCreateTeam() {
    if (!isSupabaseConfigured || !supabase || !permissions?.projectId || !newTeamName.trim()) return

    setSaving(true)
    try {
      const { error } = await supabase.from('teams').insert({
        project_id: permissions.projectId,
        name: newTeamName.trim(),
        description: newTeamDesc.trim(),
      })

      if (!error) {
        setShowCreateTeam(false)
        setNewTeamName('')
        setNewTeamDesc('')
        loadTeams()
      }
    } catch (error) {
      console.error('Failed to create team:', error)
    } finally {
      setSaving(false)
    }
  }

  async function handleRemoveMember(memberId: string) {
    if (!isSupabaseConfigured || !supabase) return

    const { error } = await supabase.from('team_members').delete().eq('id', memberId)
    if (!error && selectedTeam) {
      loadTeamMembers(selectedTeam.id)
      loadTeams()
    }
  }

  if (permissionsLoading) {
    return (
      <AdminLayout title="Gerenciar Equipes" subtitle="Crie equipes e convide membros para colaborar">
        <div className="flex items-center justify-center h-64">
          <div className="animate-spin w-8 h-8 border-4 border-blue-500 border-t-transparent rounded-full" />
        </div>
      </AdminLayout>
    )
  }

  if (!isGestor) {
    return (
      <AdminLayout title="Gerenciar Equipes">
        <div className="bg-yellow-50 dark:bg-yellow-900/20 border border-yellow-200 dark:border-yellow-800 rounded-lg p-4">
          <p className="text-yellow-800 dark:text-yellow-200">
            Você precisa ser gestor ou superior para gerenciar equipes.
          </p>
        </div>
      </AdminLayout>
    )
  }

  return (
    <AdminLayout
      title="Gerenciar Equipes"
      subtitle="Crie equipes e convide membros para colaborar"
    >
      {/* Header */}
      <div className="flex items-center justify-end mb-6">
        <Button onClick={() => setShowCreateTeam(true)} icon={<Plus size={18} />}>
          Nova Equipe
        </Button>
      </div>

      {/* Teams Grid */}
      <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
        {teams.map((team) => (
          <motion.div
            key={team.id}
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            className={`bg-white dark:bg-gray-800 rounded-xl border p-4 cursor-pointer transition-all hover:shadow-md ${
              selectedTeam?.id === team.id
                ? 'border-blue-500 ring-2 ring-blue-500/20'
                : 'border-gray-200 dark:border-gray-700'
            }`}
            onClick={() => handleSelectTeam(team)}
          >
            <div className="flex items-start justify-between">
              <div className="flex items-center gap-3">
                <div className="w-10 h-10 rounded-lg bg-blue-100 dark:bg-blue-900/30 flex items-center justify-center">
                  <Users className="w-5 h-5 text-blue-600" />
                </div>
                <div>
                  <h3 className="font-semibold text-gray-900 dark:text-white">{team.name}</h3>
                  <p className="text-sm text-gray-500 dark:text-gray-400">
                    {team.member_count} membro(s)
                  </p>
                </div>
              </div>
              <button className="p-1 hover:bg-gray-100 dark:hover:bg-gray-700 rounded">
                <MoreVertical className="w-4 h-4 text-gray-400" />
              </button>
            </div>
            {team.description && (
              <p className="mt-3 text-sm text-gray-500 dark:text-gray-400 line-clamp-2">
                {team.description}
              </p>
            )}
          </motion.div>
        ))}

        {teams.length === 0 && !loading && (
          <div className="col-span-full text-center py-12">
            <Users className="w-12 h-12 text-gray-300 mx-auto mb-3" />
            <p className="text-gray-500 dark:text-gray-400">
              Nenhuma equipe ainda. Crie a primeira!
            </p>
          </div>
        )}
      </div>

      {/* Selected Team Members */}
      {selectedTeam && (
        <div className="mt-8">
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-semibold text-gray-900 dark:text-white">
              Membros de {selectedTeam.name}
            </h2>
            <Button
              size="sm"
              onClick={() => setShowInviteModal(true)}
              icon={<Mail size={16} />}
            >
              Convidar
            </Button>
          </div>

          <div className="bg-white dark:bg-gray-800 rounded-xl border border-gray-200 dark:border-gray-700 overflow-hidden">
            {members.map((member, index) => (
              <div
                key={member.id}
                className={`flex items-center justify-between p-4 ${
                  index !== members.length - 1
                    ? 'border-b border-gray-200 dark:border-gray-700'
                    : ''
                }`}
              >
                <div className="flex items-center gap-3">
                  <div className="w-10 h-10 rounded-full bg-gray-200 dark:bg-gray-700 flex items-center justify-center text-gray-600 dark:text-gray-300 font-medium">
                    {member.user_name.charAt(0).toUpperCase()}
                  </div>
                  <div>
                    <p className="font-medium text-gray-900 dark:text-white">{member.user_name}</p>
                    <p className="text-sm text-gray-500">{member.user_email}</p>
                  </div>
                </div>
                <div className="flex items-center gap-3">
                  <Badge variant="gray">
                    <Shield className="w-3 h-3 mr-1" />
                    {member.role_name}
                  </Badge>
                  {member.user_id !== (permissions?.permissions as any)?.role && (
                    <button
                      onClick={() => handleRemoveMember(member.id)}
                      className="p-2 text-red-500 hover:bg-red-50 dark:hover:bg-red-900/20 rounded-lg"
                    >
                      <Trash2 className="w-4 h-4" />
                    </button>
                  )}
                </div>
              </div>
            ))}

            {members.length === 0 && (
              <div className="p-8 text-center">
                <Users className="w-8 h-8 text-gray-300 mx-auto mb-2" />
                <p className="text-gray-500 dark:text-gray-400">Nenhum membro ainda</p>
              </div>
            )}
          </div>
        </div>
      )}

      {/* Create Team Modal */}
      <Modal
        isOpen={showCreateTeam}
        onClose={() => setShowCreateTeam(false)}
        title="Criar Nova Equipe"
      >
        <div className="space-y-4">
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Nome da Equipe
            </label>
            <Input
              value={newTeamName}
              onChange={(e) => setNewTeamName(e.target.value)}
              placeholder="Ex: Time de Vendas"
            />
          </div>
          <div>
            <label className="block text-sm font-medium text-gray-700 dark:text-gray-300 mb-1">
              Descrição
            </label>
            <textarea
              value={newTeamDesc}
              onChange={(e) => setNewTeamDesc(e.target.value)}
              placeholder="Descreva o propósito desta equipe..."
              className="w-full px-3 py-2 border border-gray-300 dark:border-gray-600 rounded-lg dark:bg-gray-800 dark:text-white"
              rows={3}
            />
          </div>
          <div className="flex justify-end gap-3 pt-4">
            <Button variant="ghost" onClick={() => setShowCreateTeam(false)}>
              Cancelar
            </Button>
            <Button onClick={handleCreateTeam} disabled={saving || !newTeamName.trim()}>
              {saving ? 'Criando...' : 'Criar Equipe'}
            </Button>
          </div>
        </div>
      </Modal>

      {/* Invite Modal - improved UX */}
      <InviteModal
        open={showInviteModal}
        onClose={() => setShowInviteModal(false)}
        teamId={selectedTeam?.id || ''}
        teamName={selectedTeam?.name || ''}
        onSent={() => {
          // refresh stats if needed
        }}
      />
    </AdminLayout>
  )
}
