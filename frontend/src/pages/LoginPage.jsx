import { useState } from 'react'
import axios from 'axios'
import { Fish, Anchor, Sparkles, ChevronRight, Activity, UserPlus, Phone, Key, Shield, Eye, EyeOff, HelpCircle, Lock } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

export default function LoginPage({ onLogin }) {
  const [mode, setMode] = useState('login')
  const [username, setUsername] = useState('')
  const [password, setPassword] = useState('')
  const [showPassword, setShowPassword] = useState(false)
  const [regUsername, setRegUsername] = useState('')
  const [regPhone, setRegPhone] = useState('')
  const [regPassword, setRegPassword] = useState('')
  const [showRegPassword, setShowRegPassword] = useState(false)
  const [regRole, setRegRole] = useState('hotel_buyer')
  const [regSecurityQuestion, setRegSecurityQuestion] = useState('')
  const [regSecurityAnswer, setRegSecurityAnswer] = useState('')
  const [loading, setLoading] = useState(false)
  const [regError, setRegError] = useState('')
  const [regSuccess, setRegSuccess] = useState('')

  // Forgot password states
  const [forgotStep, setForgotStep] = useState(0) // 0=username, 1=question, 2=success
  const [forgotUsername, setForgotUsername] = useState('')
  const [securityQuestion, setSecurityQuestion] = useState('')
  const [securityAnswer, setSecurityAnswer] = useState('')
  const [newPassword, setNewPassword] = useState('')
  const [forgotError, setForgotError] = useState('')
  const [forgotLoading, setForgotLoading] = useState(false)

  const login = async (e) => {
    e.preventDefault()
    setLoading(true)
    try {
      const res = await axios.post(`${API}/login/`, { username, password })
      localStorage.setItem('token', res.data.access)
      onLogin(res.data.access)
    } catch (e) { alert('Invalid credentials') }
    setLoading(false)
  }

  const register = async (e) => {
    e.preventDefault()
    setLoading(true)
    setRegError('')
    setRegSuccess('')
    try {
      await axios.post(`${API}/register/`, {
        username: regUsername,
        phone: regPhone,
        password: regPassword,
        role: regRole,
        security_question: regSecurityQuestion,
        security_answer: regSecurityAnswer,
      })
      setRegSuccess('Registration successful! You can now sign in.')
      setRegUsername(''); setRegPhone(''); setRegPassword('')
      setRegSecurityQuestion(''); setRegSecurityAnswer('')
      setTimeout(() => setMode('login'), 2000)
    } catch (e) {
      const errors = e.response?.data
      setRegError(errors ? Object.values(errors).flat().join(', ') : 'Registration failed.')
    }
    setLoading(false)
  }

  const handleForgotUsername = async (e) => {
    e.preventDefault()
    setForgotLoading(true)
    setForgotError('')
    try {
      const res = await axios.post(`${API}/forgot-password/`, { username: forgotUsername })
      setSecurityQuestion(res.data.security_question)
      setForgotStep(1)
    } catch (e) {
      setForgotError(e.response?.data?.error || 'User not found')
    }
    setForgotLoading(false)
  }

  const handleResetPassword = async (e) => {
    e.preventDefault()
    setForgotLoading(true)
    setForgotError('')
    try {
      await axios.post(`${API}/reset-password/`, {
        username: forgotUsername,
        answer: securityAnswer,
        new_password: newPassword,
      })
      setForgotStep(2)
    } catch (e) {
      setForgotError(e.response?.data?.error || 'Reset failed')
    }
    setForgotLoading(false)
  }

  const closeForgot = () => {
    setForgotStep(0)
    setForgotUsername('')
    setSecurityQuestion('')
    setSecurityAnswer('')
    setNewPassword('')
    setForgotError('')
  }

  return (
    <div className="min-h-screen relative overflow-hidden bg-[#0a0f1e]">
      <div className="absolute inset-0">
        <div className="absolute top-0 left-0 w-[500px] h-[500px] bg-blue-600/20 rounded-full blur-[120px] animate-pulse" />
        <div className="absolute bottom-0 right-0 w-[600px] h-[600px] bg-cyan-500/10 rounded-full blur-[120px] animate-pulse delay-1000" />
        <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[800px] h-[800px] bg-indigo-500/5 rounded-full blur-[150px]" />
        <div className="absolute inset-0 opacity-[0.03]" style={{ backgroundImage: 'linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px), linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)', backgroundSize: '60px 60px' }} />
      </div>
      <div className="absolute inset-0 overflow-hidden pointer-events-none">
        {[...Array(20)].map((_, i) => (
          <div key={i} className="absolute animate-float opacity-10"
            style={{ left: `${Math.random() * 90}%`, top: `${Math.random() * 90}%`, animationDelay: `${i * 0.7}s`, animationDuration: `${8 + Math.random() * 6}s`, fontSize: `${24 + Math.random() * 32}px` }}>
            {['🐟','🐠','🐡','🦈','🐙','🦐','🐋','🦀'][Math.floor(Math.random()*8)]}
          </div>
        ))}
      </div>
      <div className="relative z-10 min-h-screen flex items-center justify-center p-4">
        <div className="w-full max-w-[460px]">
          <div className="text-center mb-8">
            <div className="inline-flex items-center justify-center w-24 h-24 rounded-[2rem] bg-gradient-to-br from-blue-600 via-blue-500 to-cyan-400 shadow-[0_0_60px_rgba(59,130,246,0.3)] mb-6 animate-glow group">
              <div className="relative">
                <Fish size={42} className="text-white group-hover:scale-110 transition-transform duration-500" />
                <Sparkles size={14} className="text-yellow-300 absolute -top-1 -right-1 animate-pulse" />
              </div>
            </div>
            <h1 className="text-5xl font-black text-transparent bg-clip-text bg-gradient-to-r from-white via-blue-100 to-cyan-200 mb-2 tracking-tight">Samaki Smart AI</h1>
            <p className="text-blue-300/50 text-sm font-light tracking-wide">Premium Fishery Intelligence Platform</p>
          </div>
          <div className="relative group">
            <div className="absolute inset-0 bg-gradient-to-r from-blue-600/20 to-cyan-500/20 rounded-3xl blur-xl group-hover:blur-2xl transition-all duration-500" />
            <div className="relative bg-[#111827]/80 backdrop-blur-2xl rounded-3xl border border-white/[0.08] shadow-2xl p-8">
              <div className="flex bg-white/[0.03] rounded-2xl p-1 mb-8 border border-white/[0.05]">
                <button onClick={() => setMode('login')} className={`flex-1 py-2.5 rounded-xl text-sm font-semibold transition-all duration-300 ${mode === 'login' ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20' : 'text-gray-500 hover:text-gray-300'}`}>Sign In</button>
                <button onClick={() => { setMode('register'); setRegError(''); setRegSuccess('') }} className={`flex-1 py-2.5 rounded-xl text-sm font-semibold transition-all duration-300 ${mode === 'register' ? 'bg-violet-600 text-white shadow-lg shadow-violet-500/20' : 'text-gray-500 hover:text-gray-300'}`}>Register</button>
              </div>
              {mode === 'login' ? (
                <>
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500/20 to-cyan-500/20 border border-blue-400/20 flex items-center justify-center"><Anchor size={20} className="text-cyan-400" /></div>
                    <div><h2 className="text-white font-bold">Welcome Back</h2><p className="text-gray-500 text-xs">Sign in to your account</p></div>
                  </div>
                  <form onSubmit={login} className="space-y-4">
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider">Username</label>
                      <input type="text" value={username} onChange={e => setUsername(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-cyan-400/50 focus:ring-2 focus:ring-cyan-400/10 transition-all duration-300" placeholder="Enter your username" required />
                    </div>
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider">Password</label>
                      <div className="relative">
                        <input type={showPassword ? "text" : "password"} value={password} onChange={e => setPassword(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 pr-12 text-white placeholder-gray-600 focus:outline-none focus:border-cyan-400/50 focus:ring-2 focus:ring-cyan-400/10 transition-all duration-300" placeholder="Enter your password" required />
                        <button type="button" onClick={() => setShowPassword(!showPassword)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-300 transition-colors">
                          {showPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                        </button>
                      </div>
                    </div>
                    <div className="text-right">
                      <button type="button" onClick={() => { closeForgot(); setMode('forgot'); }} className="text-xs text-cyan-400 hover:text-cyan-300 transition-colors">
                        Forgot Password?
                      </button>
                    </div>
                    <button type="submit" disabled={loading} className="w-full bg-gradient-to-r from-blue-600 to-cyan-500 text-white py-3.5 rounded-xl font-semibold shadow-lg shadow-blue-500/20 hover:shadow-blue-500/40 hover:scale-[1.01] active:scale-[0.99] transition-all duration-300 flex items-center justify-center gap-2 group disabled:opacity-50">{loading ? <Activity size={18} className="animate-spin" /> : <>Sign In <ChevronRight size={18} className="group-hover:translate-x-1 transition-transform" /></>}</button>
                  </form>
                </>
              ) : mode === 'forgot' ? (
                <>
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-amber-500/20 to-orange-500/20 border border-amber-400/20 flex items-center justify-center"><Lock size={20} className="text-amber-400" /></div>
                    <div><h2 className="text-white font-bold">Reset Password</h2><p className="text-gray-500 text-xs">Verify your identity</p></div>
                  </div>

                  {forgotError && <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-3 mb-4"><p className="text-red-400 text-xs">{forgotError}</p></div>}

                  {forgotStep === 0 && (
                    <form onSubmit={handleForgotUsername} className="space-y-4">
                      <div className="space-y-2">
                        <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider">Username</label>
                        <input type="text" value={forgotUsername} onChange={e => setForgotUsername(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-amber-400/50 transition-all" placeholder="Enter your username" required />
                      </div>
                      <button type="submit" disabled={forgotLoading} className="w-full bg-gradient-to-r from-amber-600 to-orange-500 text-white py-3.5 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all flex items-center justify-center gap-2 disabled:opacity-50">
                        {forgotLoading ? <Activity size={18} className="animate-spin" /> : <>Next <ChevronRight size={18} /></>}
                      </button>
                      <button type="button" onClick={() => setMode('login')} className="w-full text-gray-500 text-xs hover:text-gray-300 transition-colors">← Back to Login</button>
                    </form>
                  )}

                  {forgotStep === 1 && (
                    <form onSubmit={handleResetPassword} className="space-y-4">
                      <div className="bg-amber-500/5 border border-amber-500/20 rounded-xl p-4">
                        <p className="text-sm text-amber-400 flex items-center gap-2">
                          <HelpCircle size={16} /> {securityQuestion}
                        </p>
                      </div>
                      <div className="space-y-2">
                        <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider">Your Answer</label>
                        <input type="text" value={securityAnswer} onChange={e => setSecurityAnswer(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-amber-400/50 transition-all" placeholder="Enter your answer" required />
                      </div>
                      <div className="space-y-2">
                        <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider">New Password</label>
                        <input type="password" value={newPassword} onChange={e => setNewPassword(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-amber-400/50 transition-all" placeholder="Min 6 characters" required />
                      </div>
                      <button type="submit" disabled={forgotLoading} className="w-full bg-gradient-to-r from-amber-600 to-orange-500 text-white py-3.5 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all flex items-center justify-center gap-2 disabled:opacity-50">
                        {forgotLoading ? <Activity size={18} className="animate-spin" /> : <>Reset Password</>}
                      </button>
                    </form>
                  )}

                  {forgotStep === 2 && (
                    <div className="text-center py-6">
                      <p className="text-5xl mb-4">✅</p>
                      <h3 className="text-white font-bold text-lg mb-2">Password Reset!</h3>
                      <p className="text-gray-400 text-sm mb-4">Your password has been changed successfully.</p>
                      <button onClick={() => { closeForgot(); setMode('login'); }} className="w-full bg-gradient-to-r from-blue-600 to-cyan-500 text-white py-3.5 rounded-xl font-semibold shadow-lg transition-all">
                        Back to Login
                      </button>
                    </div>
                  )}
                </>
              ) : (
                <>
                  <div className="flex items-center gap-3 mb-6">
                    <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-violet-500/20 to-purple-500/20 border border-violet-400/20 flex items-center justify-center"><UserPlus size={20} className="text-violet-400" /></div>
                    <div><h2 className="text-white font-bold">Create Account</h2><p className="text-gray-500 text-xs">Join Samaki Smart AI</p></div>
                  </div>
                  {regError && <div className="bg-red-500/10 border border-red-500/20 rounded-xl p-3 mb-4"><p className="text-red-400 text-xs">{regError}</p></div>}
                  {regSuccess && <div className="bg-emerald-500/10 border border-emerald-500/20 rounded-xl p-3 mb-4"><p className="text-emerald-400 text-xs">{regSuccess}</p></div>}
                  <form onSubmit={register} className="space-y-4">
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider flex items-center gap-1.5"><UserPlus size={12} /> Username</label>
                      <input type="text" value={regUsername} onChange={e => setRegUsername(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-violet-400/50 transition-all" placeholder="Choose a username" required />
                    </div>
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider flex items-center gap-1.5"><Phone size={12} /> Phone Number</label>
                      <input type="text" value={regPhone} onChange={e => setRegPhone(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-violet-400/50 transition-all" placeholder="e.g. 0771234567" />
                    </div>
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider flex items-center gap-1.5"><Key size={12} /> Password</label>
                      <div className="relative">
                        <input type={showRegPassword ? "text" : "password"} value={regPassword} onChange={e => setRegPassword(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 pr-12 text-white placeholder-gray-600 focus:outline-none focus:border-violet-400/50 transition-all" placeholder="Min 6 characters" required />
                        <button type="button" onClick={() => setShowRegPassword(!showRegPassword)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-300 transition-colors">
                          {showRegPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                        </button>
                      </div>
                    </div>
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider">Security Question</label>
                      <input type="text" value={regSecurityQuestion} onChange={e => setRegSecurityQuestion(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-violet-400/50 transition-all" placeholder="e.g. Mother's maiden name" />
                    </div>
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider">Security Answer</label>
                      <input type="text" value={regSecurityAnswer} onChange={e => setRegSecurityAnswer(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-violet-400/50 transition-all" placeholder="Your answer" />
                    </div>
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider">Account Type</label>
                      <select value={regRole} onChange={e => setRegRole(e.target.value)} className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white focus:outline-none focus:border-violet-400/50 transition-all">
                        <option value="hotel_buyer">🏨 Hotel Buyer</option>
                        <option value="fisherman">🎣 Fisherman</option>
                      </select>
                    </div>
                    <button type="submit" disabled={loading} className="w-full bg-gradient-to-r from-violet-600 to-purple-600 text-white py-3.5 rounded-xl font-semibold shadow-lg shadow-violet-500/20 hover:shadow-violet-500/40 hover:scale-[1.01] active:scale-[0.99] transition-all duration-300 flex items-center justify-center gap-2 group disabled:opacity-50">{loading ? <Activity size={18} className="animate-spin" /> : <>Create Account <ChevronRight size={18} className="group-hover:translate-x-1 transition-transform" /></>}</button>
                  </form>
                </>
              )}
              <div className="mt-6 pt-6 border-t border-white/[0.06]">
                <div className="flex items-center justify-center gap-2 text-xs text-gray-600"><Shield size={12} /><span>Enterprise-grade encryption</span><span className="text-gray-700">•</span><span>TLS 1.2+</span></div>
              </div>
            </div>
          </div>
          <p className="text-center text-gray-700 text-xs mt-6">© 2026 Samaki Smart AI • State University of Zanzibar</p>
        </div>
      </div>
    </div>
  )
}