import { useState, useEffect } from 'react'
import axios from 'axios'
import { ArrowLeft, Phone, MapPin, Store, Hotel, Shield, Clock, Activity, AlertTriangle, Key, Lock, Unlock } from 'lucide-react'

const API = 'http://10.28.92.239:8000/api/auth'

export default function AdminUserDetailPage({ token, userId, onBack }) {
  const [user, setUser] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchUser = async () => {
      try {
        const res = await axios.get(`${API}/admin/users/${userId}/`, {
          headers: { Authorization: `Bearer ${token}` }
        })
        setUser(res.data)
      } catch (e) {}
      setLoading(false)
    }
    fetchUser()
  }, [token, userId])

  const toggleStatus = async () => {
    try {
      const res = await axios.post(`${API}/admin/users/${userId}/toggle-status/`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setUser(prev => ({ ...prev, is_active: res.data.is_active }))
    } catch (e) {}
  }

  const resetPassword = async () => {
    if (!confirm('Reset this user\'s password?')) return
    try {
      const res = await axios.post(`${API}/admin/users/${userId}/reset-password/`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      })
      alert(`New password: ${res.data.new_password}`)
    } catch (e) {}
  }

  if (loading) return (
    <div className="flex justify-center py-20">
      <div className="animate-spin w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full" />
    </div>
  )

  if (!user) return (
    <div className="text-center py-20 text-gray-500">User not found</div>
  )

  return (
    <div className="max-w-4xl mx-auto px-6 py-8">
      <button onClick={onBack} className="flex items-center gap-2 text-gray-400 hover:text-white mb-6 transition-colors">
        <ArrowLeft size={16} /> Back to Users
      </button>

      {/* Profile Header */}
      <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-8 mb-6">
        <div className="flex items-start gap-6">
          <div className="w-20 h-20 rounded-2xl bg-gradient-to-br from-blue-600 to-cyan-500 flex items-center justify-center text-3xl font-black text-white shadow-lg shadow-blue-500/20">
            {user.username?.[0]?.toUpperCase()}
          </div>
          <div className="flex-1">
            <div className="flex items-center gap-3 mb-2">
              <h2 className="text-2xl font-bold text-white">{user.username}</h2>
              <span className={`text-[10px] font-bold px-3 py-1 rounded-full ${
                user.is_active
                  ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                  : 'bg-red-500/10 text-red-400 border border-red-500/20'
              }`}>
                {user.is_active ? 'Active' : 'Locked'}
              </span>
            </div>
            <p className="text-gray-400 capitalize">
              {user.role === 'fisherman' ? '🎣 Fisherman' : user.role === 'hotel_buyer' ? '🏨 Hotel Buyer' : '🛡️ Admin'}
            </p>
            <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mt-4">
              <div className="flex items-center gap-2 text-sm text-gray-400">
                <Phone size={14} className="text-gray-500" /> {user.phone || '—'}
              </div>
              <div className="flex items-center gap-2 text-sm text-gray-400">
                <MapPin size={14} className="text-gray-500" /> {user.location || '—'}
              </div>
              {user.market && (
                <div className="flex items-center gap-2 text-sm text-gray-400">
                  <Store size={14} className="text-gray-500" /> {user.market}
                </div>
              )}
              {user.hotel_name && (
                <div className="flex items-center gap-2 text-sm text-gray-400">
                  <Hotel size={14} className="text-gray-500" /> {user.hotel_name}
                </div>
              )}
            </div>
          </div>
          <div className="flex gap-2">
            <button onClick={resetPassword} className="px-4 py-2 bg-amber-500/10 border border-amber-500/20 rounded-xl text-amber-400 text-sm font-semibold hover:bg-amber-500/20 transition-all flex items-center gap-2">
              <Key size={14} /> Reset Password
            </button>
            <button onClick={toggleStatus} className={`px-4 py-2 rounded-xl text-sm font-semibold transition-all flex items-center gap-2 ${
              user.is_active
                ? 'bg-red-500/10 border border-red-500/20 text-red-400 hover:bg-red-500/20'
                : 'bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 hover:bg-emerald-500/20'
            }`}>
              {user.is_active ? <Lock size={14} /> : <Unlock size={14} />}
              {user.is_active ? 'Lock' : 'Unlock'}
            </button>
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-3 gap-4 mb-6">
        <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-5 text-center">
          <p className="text-3xl font-black text-white">{user.total_orders}</p>
          <p className="text-xs text-gray-500 mt-1">Total Orders</p>
        </div>
        <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-5 text-center">
          <p className="text-sm text-gray-400">{user.last_login_ip || '—'}</p>
          <p className="text-xs text-gray-500 mt-1">Last IP</p>
        </div>
        <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-5 text-center">
          <p className="text-sm text-gray-400">{user.failed_login_attempts}</p>
          <p className="text-xs text-gray-500 mt-1">Failed Logins</p>
        </div>
      </div>

      {/* Recent Activity */}
      <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-6">
        <h3 className="font-bold text-white mb-4 flex items-center gap-2">
          <Activity size={16} className="text-cyan-400" /> Recent Activity
        </h3>
        <div className="space-y-2">
          {user.recent_activity?.map((log, i) => (
            <div key={i} className="flex items-center justify-between p-3 rounded-xl bg-white/[0.02]">
              <div className="flex items-center gap-3">
                <div className="w-2 h-2 rounded-full bg-cyan-400" />
                <span className="text-sm text-gray-300">{log.action}</span>
                <span className="text-xs text-gray-600">on {log.table}</span>
              </div>
              <span className="text-xs text-gray-500">
                {new Date(log.time).toLocaleString()}
              </span>
            </div>
          ))}
          {(!user.recent_activity || user.recent_activity.length === 0) && (
            <p className="text-gray-600 text-sm text-center py-4">No recent activity</p>
          )}
        </div>
      </div>
    </div>
  )
}