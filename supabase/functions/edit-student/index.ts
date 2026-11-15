import { withSupabase } from 'npm:@supabase/server@1'

// A função só atua em alunos da professora autenticada. A chave administrativa
// permanece no servidor do Supabase e nunca é enviada ao navegador.
export default {
  fetch: withSupabase({ auth: 'user' }, async (req, ctx) => {
    if (req.method !== 'POST') return Response.json({ error: 'Método não permitido.' }, { status: 405 })
    const reply = (error: string, status = 400) => Response.json({ error }, { status })
    let input: { student_id?: string; name?: string; email?: string; email_verified_by_teacher?: boolean }
    try { input = await req.json() } catch { return reply('Dados inválidos.') }
    const studentId = String(input.student_id || '')
    const name = String(input.name || '').trim()
    const email = String(input.email || '').trim().toLowerCase()
    if (!/^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i.test(studentId) || !name || name.length > 120 || email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) return reply('Informe nome e e-mail válidos.')
    const { supabase, supabaseAdmin } = ctx
    const { data: profile, error: permissionError } = await supabase.rpc('impulso', { op: 'load', data: {} })
    if (permissionError || profile?.role !== 'professor') return reply('Acesso restrito ao professor.', 403)
    const student = (profile.students || []).find((s: { id: string }) => s.id === studentId)
    if (!student) return reply('Aluno não encontrado.', 404)
    const changingEmail = String(student.email || '').toLowerCase() !== email
    if (changingEmail && input.email_verified_by_teacher !== true) return reply('Confirme que verificou o novo e-mail do aluno por outro meio.')
    const { data: prepared, error: prepareError } = await supabase.rpc('impulso_prepare_edit', { p_student_id: studentId, p_name: name, p_email: email })
    if (prepareError) return reply(prepareError.message || 'Não foi possível preparar a alteração.')
    if (prepared?.status === 'done') return Response.json({ ok: true })
    if (prepared?.status !== 'pending' || !prepared.job_id || !prepared.user_id) return reply('Não foi possível preparar a alteração.')
    const job = prepared.job_id
    let current = await supabaseAdmin.auth.admin.getUserById(prepared.user_id)
    if (current.error || !current.data.user?.email) return reply('Não foi possível consultar a conta. Repita a alteração com os mesmos dados.')
    let currentEmail = current.data.user.email.toLowerCase()
    if (currentEmail === prepared.old_email) {
      // A professora confirma a identidade por um canal externo: não há e-mail
      // de confirmação automático nesse fluxo administrativo.
      const updated = await supabaseAdmin.auth.admin.updateUserById(prepared.user_id, { email: prepared.target_email, email_confirm: true })
      if (updated.error) {
        // A resposta pode falhar após a alteração já ter sido efetivada.
        current = await supabaseAdmin.auth.admin.getUserById(prepared.user_id)
        if (current.error || !current.data.user?.email) return reply('Não foi possível confirmar a atualização. Repita com os mesmos dados.')
        currentEmail = current.data.user.email.toLowerCase()
        if (currentEmail === prepared.old_email) {
          await supabase.rpc('impulso_cancel_edit', { p_job_id: job })
          return reply('Não foi possível alterar o e-mail de login. Verifique se ele já está em uso ou se o Supabase permite a alteração.')
        }
      } else currentEmail = String(updated.data.user?.email || '').toLowerCase()
    }
    if (currentEmail !== prepared.target_email) return reply('A conta está com um e-mail diferente do esperado. Solicite suporte antes de tentar outro endereço.')
    const { error: finishError } = await supabase.rpc('impulso_finish_edit', { p_job_id: job })
    if (finishError) return reply('A conta pode ter sido atualizada, mas o cadastro não foi concluído. Repita com os mesmos dados para concluir.')
    return Response.json({ ok: true })
  }),
}
