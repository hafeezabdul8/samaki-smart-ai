import { useState, useEffect } from 'react'
import axios from 'axios'
import { Users, Search, Lock, Unlock, Key, Eye, Phone, MapPin, Store, Hotel, Shield, ChevronRight } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

export default function AdminUsersPage({ token, onViewUser }) {
  const [users, setUsers] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [filter, setFilter] = useState('all')

  const fetchUsers = async () => {
    try {
      const res = await axios.get(`${API}/admin/users/`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setUsers(res.data.results || res.data)
    } catch (e) {}
    setLoading(false)
  }

  useEffect(() => { fetchUsers() }, [token])

  const toggleStatus = async (userId) => {
    try {
      await axios.post(`${API}/admin/users/${userId}/toggle-status/`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      })
      fetchUsers()
    } catch (e) {}
  }

  const resetPassword = async (userId) => {
    if (!confirm('Reset this user\'s password?')) return
    try {
      const res = await axios.post(`${API}/admin/users/${userId}/reset-password/`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      })
      alert(`New password: ${res.data.new_password}`)
    } catch (e) {}
  }

  const roleIcons = {
    fisherman: '🎣',
    hotel_buyer: '🏨',
    admin: '🛡️'
  }

  const filteredUsers = users.filter(u => {
    if (filter !== 'all' && u.role !== filter) return false
    if (search && !u.username?.toLowerCase().includes(search.toLowerCase()) &&
        !u.phone?.includes(search) && !u.location?.toLowerCase().includes(search.toLowerCase())) return false
    return true
  })

  if (loading) return (
    <div className="flex justify-center py-20">
      <div className="animate-spin w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full" />
    </div>
  )

  return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-white">User Management</h1>
          <p className="text-gray-500 text-sm mt-1">{users.length} total users</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="relative">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" />
            <input
              type="text"
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder="Search users..."
              className="bg-[#111827] border border-white/[0.08] rounded-xl pl-9 pr-4 py-2.5 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-cyan-400/50 w-48"
            />
          </div>
          <select
            value={filter}
            onChange={e => setFilter(e.target.value)}
            className="bg-[#111827] border border-white/[0.08] rounded-xl px-3 py-2.5 text-sm text-white focus:outline-none"
          >
            <option value="all">All Roles</option>
            <option value="fisherman">🎣 Fishermen</option>
            <option value="hotel_buyer">🏨 Hotel Buyers</option>
            <option value="admin">🛡️ Admins</option>
          </select>
        </div>
      </div>

      <div className="bg-[#111827] rounded-2xl border border-white/[0.05] overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="text-left text-[11px] font-semibold text-gray-500 uppercase tracking-wider border-b border-white/[0.05]">
              <th className="py-4 px-4">User</th>
              <th className="py-4 px-4">Contact</th>
              <th className="py-4 px-4">Location</th>
              <th className="py-4 px-4">Last Login</th>
              <th className="py-4 px-4">Status</th>
              <th className="py-4 px-4">Actions</th>
            </tr>
          </thead>
          <tbody className="text-sm">
            {filteredUsers.map(u => (
              <tr key={u.id} className="border-b border-white/[0.02] hover:bg-white/[0.02] transition-colors">
                <td className="py-3.5 px-4">
                  <div className="flex items-center gap-3">
                    <div className="w-9 h-9 rounded-xl bg-gradient-to-br from-blue-500/20 to-cyan-500/20 flex items-center justify-center text-lg">
                      {roleIcons[u.role] || '👤'}
                    </div>
                    <div>
                      <p className="font-semibold text-white">{u.username}</p>
                      <p className="text-[10px] text-gray-500">{u.role}</p>
                    </div>
                  </div>
                </td>
                <td className="py-3.5 px-4">
                  <div className="flex items-center gap-1.5 text-gray-400">
                    <Phone size={12} />
                    <span>{u.phone || '—'}</span>
                  </div>
                </td>
                <td className="py-3.5 px-4 text-gray-400 text-xs">
                  {u.market || u.location || u.hotel_name || '—'}
                </td>
                <td className="py-3.5 px-4 text-gray-500 text-xs">
                  {u.last_login ? new Date(u.last_login).toLocaleDateString() : 'Never'}
                </td>
                <td className="py-3.5 px-4">
                  <span className={`text-[10px] font-bold px-2.5 py-1 rounded-full ${
                    u.is_active
                      ? 'bg-emerald-500/10 text-emerald-400 border border-emerald-500/20'
                      : 'bg-red-500/10 text-red-400 border border-red-500/20'
                  }`}>
                    {u.is_active ? 'Active' : 'Locked'}
                  </span>
                </td>
                <td className="py-3.5 px-4">
                  <div className="flex items-center gap-1">
                    <button
                      onClick={() => onViewUser(u.id)}
                      className="p-2 rounded-lg hover:bg-white/[0.05] text-gray-400 hover:text-cyan-400 transition-all"
                      title="View Details"
                    >
                      <Eye size={14} />
                    </button>
                    <button
                      onClick={() => resetPassword(u.id)}
                      className="p-2 rounded-lg hover:bg-white/[0.05] text-gray-400 hover:text-amber-400 transition-all"
                      title="Reset Password"
                    >
                      <Key size={14} />
                    </button>
                    <button
                      onClick={() => toggleStatus(u.id)}
                      className={`p-2 rounded-lg hover:bg-white/[0.05] transition-all ${
                        u.is_active ? 'text-gray-400 hover:text-red-400' : 'text-gray-400 hover:text-emerald-400'
                      }`}
                      title={u.is_active ? 'Lock Account' : 'Unlock Account'}
                    >
                      {u.is_active ? <Lock size={14} /> : <Unlock size={14} />}
                    </button>
                    <button
                      onClick={() => onViewUser(u.id)}
                      className="p-2 rounded-lg hover:bg-white/[0.05] text-gray-400 hover:text-white transition-all"
                    >
                      <ChevronRight size={14} />
                    </button>
                  </div>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  )
}