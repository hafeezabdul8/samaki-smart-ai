import { Eye, Database } from 'lucide-react'

const statusConfig = {
  red: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/20', label: 'RESTRICTED', dot: 'bg-red-500', glow: 'shadow-red-500/10' },
  amber: { bg: 'bg-amber-500/10', text: 'text-amber-400', border: 'border-amber-500/20', label: 'CAUTION', dot: 'bg-amber-500', glow: 'shadow-amber-500/10' },
  green: { bg: 'bg-emerald-500/10', text: 'text-emerald-400', border: 'border-emerald-500/20', label: 'SUSTAINABLE', dot: 'bg-emerald-500', glow: 'shadow-emerald-500/10' },
}

const orderStatusConfig = {
  pending: { bg: 'bg-amber-500/10', text: 'text-amber-400', border: 'border-amber-500/20' },
  accepted: { bg: 'bg-blue-500/10', text: 'text-blue-400', border: 'border-blue-500/20' },
  fulfilled: { bg: 'bg-emerald-500/10', text: 'text-emerald-400', border: 'border-emerald-500/20' },
  cancelled: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/20' },
}

const speciesIcons = { Jodari: '🐟', Pono: '🐠', Changu: '🐡', Dagaa: '🐟', Nguru: '🦈', Pweza: '🐙', Tasi: '🐠', Kamba: '🦐' }
const getIcon = (name) => { for (const [k, v] of Object.entries(speciesIcons)) if (name?.includes(k)) return v; return '🐟' }

export default function AdminPage({ tab, adminOrders, alerts }) {
  if (tab === 'species') return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-6">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-emerald-500/20 to-green-500/20 border border-emerald-400/20 flex items-center justify-center">
              <Database size={18} className="text-emerald-400" />
            </div>
            <div><h2 className="font-bold text-white">Species Registry</h2><p className="text-xs text-gray-500">{alerts.length} species tracked</p></div>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-4">
          {alerts.map(a => {
            const s = statusConfig[a.status]
            return (
              <div key={a.id} className={`group p-5 rounded-xl border ${s.border} ${s.bg} ${s.glow} hover:shadow-lg transition-all duration-300`}>
                <div className="flex items-center justify-between mb-3">
                  <div className="flex items-center gap-2">
                    <span className="text-2xl">{getIcon(a.name_en)}</span>
                    <div>
                      <p className="font-bold text-white">{a.name_en.replace(/ *\([^)]*\)/g, '')}</p>
                      <p className="text-xs text-gray-500 italic">{a.scientific_name}</p>
                    </div>
                  </div>
                  <span className={`text-[9px] font-bold px-2.5 py-1 rounded-full ${s.bg} ${s.text} border ${s.border} tracking-wider`}>{s.label}</span>
                </div>
                <p className="text-xs text-gray-500 mb-2">🇹🇿 {a.name_sw}</p>
                <p className="text-xs text-gray-600 leading-relaxed">{a.note}</p>
              </div>
            )
          })}
        </div>
      </div>
    </div>
  )

  return (
    <div className="max-w-7xl mx-auto px-6 py-8">
      <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-6">
        <div className="flex items-center justify-between mb-6">
          <div className="flex items-center gap-3">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500/20 to-cyan-500/20 border border-blue-400/20 flex items-center justify-center">
              <Eye size={18} className="text-cyan-400" />
            </div>
            <div><h2 className="font-bold text-white">All Orders</h2><p className="text-xs text-gray-500">System-wide overview • {adminOrders.length} total</p></div>
          </div>
        </div>
        <div className="overflow-x-auto">
          <table className="w-full">
            <thead>
              <tr className="text-left text-[11px] font-semibold text-gray-600 uppercase tracking-wider">
                <th className="pb-4 pr-4">#</th><th className="pb-4 pr-4">Buyer</th><th className="pb-4 pr-4">Species</th>
                <th className="pb-4 pr-4">Qty</th><th className="pb-4 pr-4">Delivery</th><th className="pb-4 pr-4">Price</th><th className="pb-4">Status</th>
              </tr>
            </thead>
            <tbody className="text-sm">
              {adminOrders.map(o => {
                const s = orderStatusConfig[o.status]
                return (
                  <tr key={o.id} className="border-t border-white/[0.03] hover:bg-white/[0.02] transition-colors">
                    <td className="py-3.5 pr-4 font-semibold text-gray-600">#{o.id}</td>
                    <td className="py-3.5 pr-4 font-medium text-gray-300">{o.buyer_name || '—'}</td>
                    <td className="py-3.5 pr-4 text-gray-300">{o.species_name}</td>
                    <td className="py-3.5 pr-4 text-gray-500">{o.quantity_kg} kg</td>
                    <td className="py-3.5 pr-4 text-gray-500">{o.delivery_date}</td>
                    <td className="py-3.5 pr-4 text-gray-500">{o.max_price_tzs ? `TZS ${Number(o.max_price_tzs).toLocaleString()}` : '—'}</td>
                    <td className="py-3.5">
                      <span className={`text-[10px] font-bold px-2.5 py-1 rounded-full ${s.bg} ${s.text} border ${s.border} tracking-wider uppercase`}>{o.status}</span>
                    </td>
                  </tr>
                )
              })}
              {adminOrders.length === 0 && (
                <tr><td colSpan="7" className="py-16 text-center text-gray-600">No orders in the system</td></tr>
              )}
            </tbody>
          </table>
        </div>
      </div>
    </div>
  )
}