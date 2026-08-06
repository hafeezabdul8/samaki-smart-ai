import { useState } from 'react'
import axios from 'axios'
import { TrendingUp, MapPin, Sparkles, Calendar, Cloud, Wind, Droplets } from 'lucide-react'
import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from 'recharts'

const API = 'http://10.139.233.239:8000/api/auth'

const speciesList = [
  'Yellowfin Tuna', 'Octopus/Squid', 'Lobster', 'Kingfish', 'Snapper',
  'Swordfish', 'Barracuda', 'Anchovy', 'Sardine', 'Mackerel',
  'Rabbitfish', 'Parrotfish', 'Grouper', 'Goatfish', 'Mullet',
  'Shark/Ray', 'Surgeonfish', 'Trevally'
]

const marketList = ['Malindi Market', 'Darajani Market', 'Mkokotoni Market', 'Nungwi Market', 'Mahonda Market']

const weatherIcons = {
  'Sunny': '☀️', 'Calm': '🌤️', 'Windy': '💨', 'Rainy': '🌧️', 'Rough': '🌊'
}

export default function ForecastPage({ forecast }) {
  const [species, setSpecies] = useState('Yellowfin Tuna')
  const [market, setMarket] = useState('Darajani Market')
  const [loading, setLoading] = useState(false)
  const [aiForecast, setAiForecast] = useState(forecast || [])
  const [seasonInfo, setSeasonInfo] = useState(null)

  const fetchForecast = async () => {
    setLoading(true)
    try {
      const res = await axios.post(`${API}/forecast/`, { species, market, avg_quantity: 15 })
      setAiForecast(res.data)
    } catch (e) {}
    setLoading(false)
  }

  const chartData = aiForecast.map(f => ({
    date: f.date?.slice(5),
    price: f.predicted_price_tzs,
    weather: f.weather,
    season: f.season,
    confidence: f.confidence
  }))

  const avgPrice = chartData.length > 0 ? Math.round(chartData.reduce((s, d) => s + d.price, 0) / chartData.length) : 0
  const priceMin = chartData.length > 0 ? Math.min(...chartData.map(d => d.price)) : 0
  const priceMax = chartData.length > 0 ? Math.max(...chartData.map(d => d.price)) : 0

  return (
    <div className="max-w-7xl mx-auto px-6 py-8 space-y-6">
      {/* Input Card */}
      <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-6">
        <div className="flex items-center gap-3 mb-6">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-cyan-500/20 to-blue-500/20 border border-cyan-400/20 flex items-center justify-center">
            <TrendingUp size={18} className="text-cyan-400" />
          </div>
          <div>
            <h2 className="font-bold text-white">7-Day AI Forecast</h2>
            <p className="text-xs text-gray-500">Select species and market to predict</p>
          </div>
        </div>
        <div className="grid grid-cols-1 md:grid-cols-3 gap-4">
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Species</label>
            <select value={species} onChange={e => setSpecies(e.target.value)}
              className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:ring-2 focus:ring-cyan-400/20">
              {speciesList.map(s => <option key={s} value={s}>{s}</option>)}
            </select>
          </div>
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Market</label>
            <select value={market} onChange={e => setMarket(e.target.value)}
              className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:ring-2 focus:ring-cyan-400/20">
              {marketList.map(m => <option key={m} value={m}>{m}</option>)}
            </select>
          </div>
          <div className="flex items-end">
            <button onClick={fetchForecast} disabled={loading}
              className="w-full bg-gradient-to-r from-cyan-600 to-blue-600 text-white py-3 rounded-xl font-semibold shadow-lg hover:shadow-xl transition-all flex items-center justify-center gap-2 disabled:opacity-50">
              {loading ? 'Predicting...' : <>Get Forecast <Sparkles size={16} /></>}
            </button>
          </div>
        </div>
      </div>

      {aiForecast.length > 0 && (
        <>
          {/* Summary Cards */}
          <div className="grid grid-cols-2 md:grid-cols-4 gap-4">
            <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-4 text-center">
              <p className="text-xs text-gray-500 mb-1">Avg Price</p>
              <p className="text-2xl font-black text-cyan-400">TZS {avgPrice.toLocaleString()}</p>
            </div>
            <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-4 text-center">
              <p className="text-xs text-gray-500 mb-1">Price Range</p>
              <p className="text-lg font-bold text-white">TZS {priceMin.toLocaleString()} - {priceMax.toLocaleString()}</p>
            </div>
            <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-4 text-center">
              <p className="text-xs text-gray-500 mb-1">AI Confidence</p>
              <p className="text-2xl font-black text-emerald-400">{Math.round((chartData[0]?.confidence || 0.85) * 100)}%</p>
            </div>
            <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-4 text-center">
              <p className="text-xs text-gray-500 mb-1">Season</p>
              <p className="text-lg font-bold text-amber-400">{chartData[0]?.season}</p>
            </div>
          </div>

          {/* Chart */}
          <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-6">
            <h2 className="font-bold text-white mb-4">📈 Price Trend</h2>
            <div className="h-80">
              <ResponsiveContainer width="100%" height="100%">
                <AreaChart data={chartData}>
                  <defs>
                    <linearGradient id="colorPrice" x1="0" y1="0" x2="0" y2="1">
                      <stop offset="5%" stopColor="#06b6d4" stopOpacity={0.3} />
                      <stop offset="95%" stopColor="#06b6d4" stopOpacity={0} />
                    </linearGradient>
                  </defs>
                  <CartesianGrid strokeDasharray="3 3" stroke="rgba(255,255,255,0.03)" />
                  <XAxis dataKey="date" stroke="#4b5563" fontSize={12} tickLine={false} />
                  <YAxis stroke="#4b5563" fontSize={12} tickLine={false} />
                  <Tooltip
                    contentStyle={{
                      backgroundColor: '#111827',
                      borderRadius: '16px',
                      border: '1px solid rgba(255,255,255,0.08)',
                      boxShadow: '0 20px 60px rgba(0,0,0,0.5)',
                      color: '#fff'
                    }}
                    formatter={(value, name, props) => [`TZS ${value?.toLocaleString()}`, 'Price']}
                    labelFormatter={(label) => `Date: ${label}`}
                  />
                  <Area type="monotone" dataKey="price" stroke="#06b6d4" strokeWidth={3} fill="url(#colorPrice)" />
                </AreaChart>
              </ResponsiveContainer>
            </div>
          </div>

          {/* Daily Cards */}
          <div className="grid grid-cols-2 md:grid-cols-4 lg:grid-cols-7 gap-3">
            {aiForecast.map((f, i) => (
              <div key={i} className="bg-[#111827] rounded-2xl border border-white/[0.05] p-4 text-center hover:border-cyan-500/30 hover:shadow-lg hover:shadow-cyan-500/5 hover:-translate-y-1 transition-all duration-300">
                <p className="text-[10px] font-semibold text-gray-500 uppercase tracking-wider mb-1">
                  {new Date(f.date).toLocaleDateString('en-US', { weekday: 'short' })}
                </p>
                <p className="text-xs text-gray-600 mb-2">
                  {new Date(f.date).toLocaleDateString('en-US', { month: 'short', day: 'numeric' })}
                </p>
                <p className="text-lg mb-1">{weatherIcons[f.weather] || '🌤️'}</p>
                <p className="text-xs text-gray-500 mb-2">{f.weather}</p>
                <p className="text-2xl font-black text-cyan-400">{f.predicted_price_tzs?.toLocaleString()}</p>
                <p className="text-[10px] text-gray-600 mt-1">TZS/kg</p>
                <div className="mt-3 pt-3 border-t border-white/[0.05]">
                  <p className="text-[10px] text-gray-600">{f.season}</p>
                  <p className="text-[9px] text-emerald-500 mt-1">{Math.round(f.confidence * 100)}% confidence</p>
                </div>
              </div>
            ))}
          </div>
        </>
      )}
    </div>
  )
}
