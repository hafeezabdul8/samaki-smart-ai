import { useState, useEffect } from 'react'
import axios from 'axios'
import { ScrollText, Search, Filter } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

export default function AdminAuditLogPage({ token }) {
  const [logs, setLogs] = useState([])
  const [loading, setLoading] = useState(true)
  const [search, setSearch] = useState('')
  const [actionFilter, setActionFilter] = useState('all')

  useEffect(() => {
    const fetchLogs = async () => {
      try {
        const res = await axios.get(`${API}/admin/audit-logs/`, {
          headers: { Authorization: `Bearer ${token}` }
        })
        setLogs(res.data.results || res.data)
      } catch (e) {}
      setLoading(false)
    }
    fetchLogs()
  }, [token])

  const actionTypes = ['all', ...new Set(logs.map(l => l.action))]

  const filteredLogs = logs.filter(l => {
    if (actionFilter !== 'all' && l.action !== actionFilter) return false
    if (search && !l.username?.toLowerCase().includes(search.toLowerCase()) &&
        !l.action?.toLowerCase().includes(search.toLowerCase()) &&
        !l.table_name?.toLowerCase().includes(search.toLowerCase())) return false
    return true
  })

  const actionColors = {
    'LOGIN': 'text-emerald-400 bg-emerald-500/10',
    'LOGOUT': 'text-gray-400 bg-gray-500/10',
    'CREATE': 'text-blue-400 bg-blue-500/10',
    'UPDATE': 'text-amber-400 bg-amber-500/10',
    'DELETE': 'text-red-400 bg-red-500/10',
    'ACCEPT': 'text-cyan-400 bg-cyan-500/10',
    'FULFILL': 'text-emerald-400 bg-emerald-500/10',
  }

  return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-2xl font-bold text-white">Audit Log</h1>
          <p className="text-gray-500 text-sm mt-1">{logs.length} total entries</p>
        </div>
        <div className="flex items-center gap-3">
          <div className="relative">
            <Search size={14} className="absolute left-3 top-1/2 -translate-y-1/2 text-gray-500" />
            <input
              type="text"
              value={search}
              onChange={e => setSearch(e.target.value)}
              placeholder="Search logs..."
              className="bg-[#111827] border border-white/[0.08] rounded-xl pl-9 pr-4 py-2.5 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-cyan-400/50 w-48"
            />
          </div>
          <select
            value={actionFilter}
            onChange={e => setActionFilter(e.target.value)}
            className="bg-[#111827] border border-white/[0.08] rounded-xl px-3 py-2.5 text-sm text-white focus:outline-none"
          >
            <option value="all">All Actions</option>
            {actionTypes.filter(a => a !== 'all').map(a => (
              <option key={a} value={a}>{a}</option>
            ))}
          </select>
        </div>
      </div>

      <div className="bg-[#111827] rounded-2xl border border-white/[0.05] overflow-hidden">
        <table className="w-full">
          <thead>
            <tr className="text-left text-[11px] font-semibold text-gray-500 uppercase tracking-wider border-b border-white/[0.05]">
              <th className="py-4 px-4">Time</th>
              <th className="py-4 px-4">User</th>
              <th className="py-4 px-4">Action</th>
              <th className="py-4 px-4">Table</th>
              <th className="py-4 px-4">Record ID</th>
            </tr>
          </thead>
          <tbody className="text-sm">
            {filteredLogs.map((log, i) => (
              <tr key={i} className="border-b border-white/[0.02] hover:bg-white/[0.02] transition-colors">
                <td className="py-3 px-4 text-gray-500 text-xs">
                  {new Date(log.timestamp).toLocaleString()}
                </td>
                <td className="py-3 px-4 font-medium text-gray-300">{log.username}</td>
                <td className="py-3 px-4">
                  <span className={`text-[10px] font-bold px-2.5 py-1 rounded-full ${
                    actionColors[log.action] || 'text-gray-400 bg-gray-500/10'
                  }`}>
                    {log.action}
                  </span>
                </td>
                <td className="py-3 px-4 text-gray-400">{log.table_name}</td>
                <td className="py-3 px-4 text-gray-600 font-mono text-xs">#{log.record_id}</td>
              </tr>
            ))}
          </tbody>
        </table>
        {filteredLogs.length === 0 && (
          <p className="text-center text-gray-600 py-16">No audit logs found</p>
        )}
      </div>
    </div>
  )
}