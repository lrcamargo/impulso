import { withSupabase } from 'npm:@supabase/server@1'

// Apenas sessão de usuário autenticado; verifica papel de professor pelo RPC do
// próprio usuário antes de usar o cliente administrativo do servidor.
export default {
  fetch: withSupabase({ auth: 'user' }, async (req, ctx) => {
    if (req.method !== 'POST') return Response.json({ error: 'Método não permitido.' }, { status: 405 })
    const { supabase, supabaseAdmin } = ctx
    const reply = (error: string, status = 400) => Response.json({ error }, { status })
    let input: { name?: string; email?: string; password?: string; request_id?: string }
    try { input = await req.json() } catch { return reply('Dados inválidos.') }
    const name = String(input.name || '').trim()
    const email = String(input.email || '').trim().toLowerCase()
    const password = String(input.password || '')
    const request_id = input.request_id || null
    if (!name || name.length > 120 || email.length > 254 || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email) || password.length < 8 || new TextEncoder().encode(password).length > 72) {
      return reply('Informe nome, e-mail e senha inicial de 8 a 72 caracteres.')
    }
    const { data: current, error: permissionError } = await supabase.rpc('impulso', { op: 'load', data: {} })
    if (permissionError || current?.role !== 'professor') return reply('Acesso restrito ao professor.', 403)
    const { data: pending, error: prepareError } = await supabase.rpc('impulso_begin_student', { student_name: name, student_email: email, request_id })
    if (prepareError || !pending?.student_id) return reply('Não foi possível iniciar o cadastro. Verifique se esse e-mail já está cadastrado.')
    const studentId = pending.student_id
    // email_confirm=true é administrativo: a professora deve conferir a
    // identidade/endereço e entregar a senha por canal individual.
    const { data: created, error: createError } = await supabaseAdmin.auth.admin.createUser({ email, password, email_confirm: true })
    if (createError || !created.user) {
      await supabase.rpc('impulso_cancel_student', { student_id: studentId })
      return reply('Não foi possível criar a conta. Verifique se o e-mail já possui uma conta no Supabase.')
    }
    const { error: finishError } = await supabase.rpc('impulso_finish_student', { student_id: studentId, new_user_id: created.user.id })
    if (finishError) {
      // Best-effort compensation. Never delete an account unless this call
      // created it. A crash can leave an incomplete account for admin cleanup.
      await supabaseAdmin.auth.admin.deleteUser(created.user.id)
      await supabase.rpc('impulso_cancel_student', { student_id: studentId })
      return reply('Não foi possível concluir o cadastro. Verifique o painel do Supabase antes de tentar novamente.')
    }
    return Response.json({ ok: true })
  }),
}
