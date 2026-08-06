import { useState } from 'react'
import axios from 'axios'
import { Fish, Anchor, Sparkles, ChevronRight, Activity, UserPlus, Phone, Key, Shield, Eye, EyeOff } from 'lucide-react'

const API = 'http://10.139.233.239:8000/api/auth'

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
  const [loading, setLoading] = useState(false)
  const [regError, setRegError] = useState('')
  const [regSuccess, setRegSuccess] = useState('')

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
      await axios.post(`${API}/register/`, { username: regUsername, phone: regPhone, password: regPassword, role: regRole })
      setRegSuccess('Registration successful! You can now sign in.')
      setRegUsername(''); setRegPhone(''); setRegPassword('')
      setTimeout(() => setMode('login'), 2000)
    } catch (e) {
      const errors = e.response?.data
      setRegError(errors ? Object.values(errors).flat().join(', ') : 'Registration failed.')
    }
    setLoading(false)
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
                    <button type="submit" disabled={loading} className="w-full bg-gradient-to-r from-blue-600 to-cyan-500 text-white py-3.5 rounded-xl font-semibold shadow-lg shadow-blue-500/20 hover:shadow-blue-500/40 hover:scale-[1.01] active:scale-[0.99] transition-all duration-300 flex items-center justify-center gap-2 group disabled:opacity-50">{loading ? <Activity size={18} className="animate-spin" /> : <>Sign In <ChevronRight size={18} className="group-hover:translate-x-1 transition-transform" /></>}</button>
                  </form>
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
                      <input type="text" value={regUsername} onChange={e => setRegUsername(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-violet-400/50 focus:ring-2 focus:ring-violet-400/10 transition-all duration-300" placeholder="Choose a username" required />
                    </div>
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider flex items-center gap-1.5"><Phone size={12} /> Phone Number</label>
                      <input type="text" value={regPhone} onChange={e => setRegPhone(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white placeholder-gray-600 focus:outline-none focus:border-violet-400/50 focus:ring-2 focus:ring-violet-400/10 transition-all duration-300" placeholder="e.g. 0771234567" />
                    </div>
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider flex items-center gap-1.5"><Key size={12} /> Password</label>
                      <div className="relative">
                        <input type={showRegPassword ? "text" : "password"} value={regPassword} onChange={e => setRegPassword(e.target.value)} className="w-full bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-3.5 pr-12 text-white placeholder-gray-600 focus:outline-none focus:border-violet-400/50 focus:ring-2 focus:ring-violet-400/10 transition-all duration-300" placeholder="Min 6 characters" required />
                        <button type="button" onClick={() => setShowRegPassword(!showRegPassword)} className="absolute right-3 top-1/2 -translate-y-1/2 text-gray-500 hover:text-gray-300 transition-colors">
                          {showRegPassword ? <EyeOff size={18} /> : <Eye size={18} />}
                        </button>
                      </div>
                    </div>
                    <div className="space-y-2">
                      <label className="text-gray-400 text-xs font-semibold uppercase tracking-wider">Account Type</label>
                      <select value={regRole} onChange={e => setRegRole(e.target.value)} className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3.5 text-white focus:outline-none focus:border-violet-400/50 focus:ring-2 focus:ring-violet-400/10 transition-all">
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