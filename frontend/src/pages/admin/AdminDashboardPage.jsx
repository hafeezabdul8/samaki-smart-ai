import { useState, useEffect } from 'react'
import axios from 'axios'
import { Users, ShoppingCart, Fish, Activity, Cpu, Shield, Clock } from 'lucide-react'

const API = 'http://10.139.233.239:8000/api/auth'

export default function AdminDashboardPage({ token }) {
  const [stats, setStats] = useState(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    const fetchStats = async () => {
      try {
        const res = await axios.get(`${API}/admin/dashboard/`, {
          headers: { Authorization: `Bearer ${token}` }
        })
        setStats(res.data)
      } catch (e) {}
      setLoading(false)
    }
    fetchStats()
  }, [token])

  if (loading) return <div className="flex justify-center py-20"><div className="animate-spin w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full" /></div>

  return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      <h1 className="text-2xl font-bold text-white mb-6">Admin Dashboard</h1>
      
      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        {[
          { icon: Users, label: 'Total Users', value: stats?.total_users, color: 'blue' },
          { icon: Fish, label: 'Fishermen', value: stats?.total_fishermen, color: 'cyan' },
          { icon: ShoppingCart, label: 'Buyers', value: stats?.total_buyers, color: 'violet' },
          { icon: Activity, label: 'Active Sessions', value: stats?.active_sessions, color: 'emerald' },
        ].map((s, i) => (
          <div key={i} className="bg-[#111827] rounded-2xl border border-white/[0.05] p-5">
            <div className="flex items-center gap-3">
              <div className={`w-10 h-10 rounded-xl bg-${s.color}-500/10 flex items-center justify-center`}>
                <s.icon size={20} className={`text-${s.color}-400`} />
              </div>
              <div>
                <p className="text-2xl font-black text-white">{s.value}</p>
                <p className="text-xs text-gray-500">{s.label}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-2 md:grid-cols-4 gap-4 mb-8">
        {[
          { icon: ShoppingCart, label: 'Total Orders', value: stats?.total_orders, color: 'amber' },
          { icon: Clock, label: 'Pending Orders', value: stats?.pending_orders, color: 'red' },
          { icon: Cpu, label: 'AI Price Accuracy', value: `${stats?.ai_accuracy_price}%`, color: 'cyan' },
          { icon: Cpu, label: 'AI Demand Accuracy', value: `${stats?.ai_accuracy_demand}%`, color: 'emerald' },
        ].map((s, i) => (
          <div key={i} className="bg-[#111827] rounded-2xl border border-white/[0.05] p-5">
            <div className="flex items-center gap-3">
              <div className={`w-10 h-10 rounded-xl bg-${s.color}-500/10 flex items-center justify-center`}>
                <s.icon size={20} className={`text-${s.color}-400`} />
              </div>
              <div>
                <p className="text-2xl font-black text-white">{s.value}</p>
                <p className="text-xs text-gray-500">{s.label}</p>
              </div>
            </div>
          </div>
        ))}
      </div>
    </div>
  )
}