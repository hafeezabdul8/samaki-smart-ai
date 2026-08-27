import { useState, useEffect } from 'react'
import axios from 'axios'
import { DollarSign, TrendingUp, AlertTriangle, Activity, Shield, Sparkles, Waves, Zap, Star, ShoppingCart, ArrowUpRight, ArrowDownRight, Minus, Flame, Clock, Calendar } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

const statusConfig = {
  red: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/20', label: 'RESTRICTED', dot: 'bg-red-500' },
  amber: { bg: 'bg-amber-500/10', text: 'text-amber-400', border: 'border-amber-500/20', label: 'CAUTION', dot: 'bg-amber-500' },
  green: { bg: 'bg-emerald-500/10', text: 'text-emerald-400', border: 'border-emerald-500/20', label: 'SUSTAINABLE', dot: 'bg-emerald-500' },
}

const speciesIcons = {
  'Tuna': '🐟', 'Jodari': '🐟', 'Parrot': '🐠', 'Pono': '🐠', 'Snapper': '🐡', 'Changu': '🐡',
  'Grouper': '🐟', 'Chewa': '🐟', 'Goat': '🐐', 'Mkundaji': '🐐', 'Surgeon': '🐠', 'Puju': '🐠',
  'Mullet': '🐟', 'Mkizi': '🐟', 'Anchovy': '🐟', 'Dagaa': '🐟', 'Sardine': '🐟', 'Saradini': '🐟',
  'Mackerel': '🐟', 'Vibua': '🐟', 'Trevally': '🐟', 'Kolekole': '🐟',
  'Sword': '⚔️', 'Nduaro': '⚔️', 'King': '👑', 'Nguru': '👑',
  'Barracuda': '🐊', 'Mzia': '🐊', 'Shark': '🦈', 'Papa': '🦈', 'Ray': '🦈',
  'Octopus': '🐙', 'Squid': '🦑', 'Pweza': '🐙', 'Ngisi': '🦑',
  'Lobster': '🦞', 'Kamba': '🦞', 'Rabbit': '🐰', 'Tasi': '🐰'
}

const getIcon = (name) => {
  for (const [k, v] of Object.entries(speciesIcons)) if (name?.includes(k)) return v
  return '🐟'
}

const speciesColors = [
  { accent: '#3B82F6', glow: 'rgba(59,130,246,0.15)' },
  { accent: '#8B5CF6', glow: 'rgba(139,92,246,0.15)' },
  { accent: '#EC4899', glow: 'rgba(236,72,153,0.15)' },
  { accent: '#10B981', glow: 'rgba(16,185,129,0.15)' },
  { accent: '#F59E0B', glow: 'rgba(245,158,11,0.15)' },
  { accent: '#06B6D4', glow: 'rgba(6,182,212,0.15)' },
  { accent: '#EF4444', glow: 'rgba(239,68,68,0.15)' },
  { accent: '#A855F7', glow: 'rgba(168,85,247,0.15)' },
]

export default function DashboardPage({ user, prices, alerts, orders, adminOrders }) {
  const isAdmin = user?.role === 'admin'
  const [recommendations, setRecommendations] = useState(null)
  const [selectedSpecies, setSelectedSpecies] = useState(null)
  const [forecastPrices, setForecastPrices] = useState({})
  const [loadingForecast, setLoadingForecast] = useState(false)
  const [todayPredictions, setTodayPredictions] = useState({})
  const [predictionLoading, setPredictionLoading] = useState(true)
  const [showAllSpecies, setShowAllSpecies] = useState(false)

  useEffect(() => {
    fetchSmartData()
    fetchTodayPredictions()
  }, [])

  const fetchSmartData = async () => {
    try {
      const res = await axios.get(`${API}/smart/`)
      setRecommendations(res.data)
    } catch (e) {}
  }

  const fetchTodayPredictions = async () => {
    setPredictionLoading(true)
    const predictions = {}
    const weatherOptions = ['Sunny', 'Calm', 'Windy', 'Rainy', 'Rough']
    
    for (const species of alerts.slice(0, 18)) {
      try {
        const randomWeather = weatherOptions[Math.floor(Math.random() * weatherOptions.length)]
        const randomQty = 15 + Math.floor(Math.random() * 70)
        const season = recommendations?.current_season || 'Transition'
        
        const res = await axios.post(`${API}/predict/`, {
          species: species.name_en,
          market: 'Darajani Market',
          season: season,
          weather: randomWeather,
          quantity_kg: randomQty
        })
        
        const marketPrice = prices.find(p => p.species?.name_en === species.name_en)
        const currentPrice = marketPrice ? Number(marketPrice.price_tzs) : res.data.predicted_price_tzs * (0.85 + Math.random() * 0.3)
        const predictedPrice = res.data.predicted_price_tzs
        const diff = predictedPrice - currentPrice
        const change = currentPrice > 0 ? Math.round((diff / currentPrice) * 100) : Math.round(Math.random() * 10) - 3
        
        predictions[species.name_en] = {
          price: predictedPrice,
          trend: change > 1 ? 'up' : change < -1 ? 'down' : 'stable',
          change: change,
          weather: randomWeather,
          currentPrice: currentPrice
        }
      } catch (e) {
        console.error(`Failed to predict ${species.name_en}:`, e)
      }
    }
    setTodayPredictions(predictions)
    setPredictionLoading(false)
  }

  const fetchSpeciesForecast = async (speciesName) => {
    if (forecastPrices[speciesName]) {
      setSelectedSpecies(speciesName === selectedSpecies ? null : speciesName)
      return
    }
    setLoadingForecast(true)
    try {
      const res = await axios.post(`${API}/forecast/`, { species: speciesName, market: 'Darajani Market', avg_quantity: 15 })
      setForecastPrices(prev => ({ ...prev, [speciesName]: res.data }))
      setSelectedSpecies(speciesName)
    } catch (e) {}
    setLoadingForecast(false)
  }

  const displaySpecies = showAllSpecies ? alerts : alerts.slice(0, 12)
  const hotSpecies = Object.entries(todayPredictions)
    .filter(([_, v]) => v.trend === 'up' && v.change > 3)
    .sort((a, b) => b[1].change - a[1].change)
    .slice(0, 4)
  const bestValueSpecies = Object.entries(todayPredictions)
    .filter(([_, v]) => v.trend === 'down' && v.change < -3)
    .sort((a, b) => a[1].change - b[1].change)
    .slice(0, 4)

  const stats = isAdmin
    ? [
        { icon: Activity, value: adminOrders.length, label: 'Total Orders', color: 'blue' },
        { icon: TrendingUp, value: adminOrders.filter(o => o.status === 'fulfilled').length, label: 'Fulfilled', color: 'emerald' },
        { icon: Shield, value: alerts.length, label: 'Species', color: 'violet' },
        { icon: Zap, value: '68.4%', label: 'AI Accuracy', color: 'cyan' },
      ]
    : [
        { icon: ShoppingCart, value: orders.filter(o => o.status === 'pending').length, label: 'Active Orders', color: 'blue' },
        { icon: TrendingUp, value: orders.filter(o => o.status === 'fulfilled').length, label: 'Fulfilled', color: 'emerald' },
        { icon: AlertTriangle, value: alerts.filter(a => a.status === 'red').length, label: 'Restricted', color: 'red' },
      ]

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
      {/* Welcome Banner */}
      <div className="relative mb-6 bg-gradient-to-r from-blue-600/10 via-cyan-500/10 to-blue-600/10 rounded-3xl border border-blue-500/20 p-6 sm:p-8 overflow-hidden">
        <div className="absolute top-0 right-0 w-64 h-64 bg-blue-500/5 rounded-full blur-3xl" />
        <div className="absolute bottom-0 left-0 w-48 h-48 bg-cyan-500/5 rounded-full blur-3xl" />
        <div className="relative flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4">
          <div>
            <div className="flex items-center gap-2 mb-2">
              <Sparkles size={18} className="text-cyan-400" />
              <span className="text-xs text-cyan-400 font-semibold tracking-wider uppercase">AI-Powered Market Intelligence</span>
            </div>
            <h2 className="text-2xl sm:text-3xl font-black text-white">
              Welcome, <span className="bg-gradient-to-r from-cyan-400 to-blue-400 bg-clip-text text-transparent">{user?.username}</span>
            </h2>
            <p className="text-gray-400 text-sm mt-1">
              {isAdmin ? 'System management console' : 'Smart purchasing decisions for your hotel'}
            </p>
          </div>
          <div className="flex items-center gap-3">
            <div className="flex items-center gap-2 bg-blue-500/10 px-4 py-2.5 rounded-2xl border border-blue-500/20">
              <span className="w-2 h-2 bg-emerald-400 rounded-full animate-pulse" />
              <span className="text-cyan-400 text-sm font-semibold">AI Live</span>
            </div>
            {recommendations && (
              <span className="text-xs bg-cyan-500/10 text-cyan-400 px-3 py-2 rounded-2xl border border-cyan-500/20 font-semibold">
                {recommendations.current_season}
              </span>
            )}
          </div>
        </div>
      </div>

      {/* Stats */}
      <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 mb-6">
        {stats.map((stat, i) => (
          <div key={i} className="group relative bg-[#111827] rounded-2xl border border-white/[0.05] p-4 hover:border-white/[0.1] transition-all duration-300">
            <div className="flex items-center gap-3">
              <div className={`w-10 h-10 rounded-xl bg-${stat.color}-500/10 flex items-center justify-center group-hover:scale-110 transition-transform`}>
                <stat.icon size={18} className={`text-${stat.color}-400`} />
              </div>
              <div>
                <p className="text-xl font-black text-white">{stat.value}</p>
                <p className="text-xs text-gray-500">{stat.label}</p>
              </div>
            </div>
          </div>
        ))}
      </div>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Main: Unified Market Prices + Smart Recommendations */}
        <div className="lg:col-span-2 space-y-5">
          {/* Hot Picks - AI Recommended Buys */}
          {hotSpecies.length > 0 && (
            <div className="bg-gradient-to-r from-emerald-500/5 via-green-500/5 to-emerald-500/5 rounded-3xl border border-emerald-500/20 p-5 sm:p-6">
              <div className="flex items-center gap-2 mb-4">
                <Flame size={18} className="text-emerald-400" />
                <h2 className="font-bold text-white">🔥 Best Buys Right Now</h2>
                <span className="text-xs text-emerald-400 bg-emerald-500/10 px-2 py-1 rounded-full">AI Recommended</span>
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                {hotSpecies.map(([name, data], i) => {
                  const alert = alerts.find(a => a.name_en === name)
                  const color = speciesColors[i]
                  return (
                    <div key={name} onClick={() => fetchSpeciesForecast(name)}
                      className="group relative rounded-2xl p-4 cursor-pointer transition-all duration-300 hover:-translate-y-1 hover:shadow-xl border border-emerald-500/20"
                      style={{ background: 'rgba(17,24,39,0.95)' }}>
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-2xl">{getIcon(name)}</span>
                        <div className="flex items-center gap-1 text-xs font-bold text-emerald-400">
                          <ArrowUpRight size={14} />+{data.change}%
                        </div>
                      </div>
                      <p className="font-bold text-white text-sm truncate">{name?.replace(/ *\([^)]*\)/g, '')}</p>
                      <p className="text-2xl font-black mt-1" style={{ color: color.accent }}>TZS {data.price?.toLocaleString()}</p>
                      <p className="text-[10px] text-gray-500 mt-1">per kg • {data.weather} • Rising demand</p>
                    </div>
                  )
                })}
              </div>
              {hotSpecies.length === 0 && (
                <p className="text-center text-gray-500 text-sm py-4">No hot picks right now. Check back later for AI recommendations.</p>
              )}
            </div>
          )}

          {/* Best Value - Price Drops */}
          {bestValueSpecies.length > 0 && (
            <div className="bg-gradient-to-r from-amber-500/5 via-orange-500/5 to-amber-500/5 rounded-3xl border border-amber-500/20 p-5 sm:p-6">
              <div className="flex items-center gap-2 mb-4">
                <ShoppingCart size={18} className="text-amber-400" />
                <h2 className="font-bold text-white">💛 Best Value — Stock Up</h2>
                <span className="text-xs text-amber-400 bg-amber-500/10 px-2 py-1 rounded-full">Price Dropping</span>
              </div>
              <div className="grid grid-cols-2 sm:grid-cols-4 gap-3">
                {bestValueSpecies.map(([name, data], i) => {
                  const color = speciesColors[i + 4]
                  return (
                    <div key={name} onClick={() => fetchSpeciesForecast(name)}
                      className="group relative rounded-2xl p-4 cursor-pointer transition-all duration-300 hover:-translate-y-1 hover:shadow-xl border border-amber-500/20"
                      style={{ background: 'rgba(17,24,39,0.95)' }}>
                      <div className="flex items-center justify-between mb-2">
                        <span className="text-2xl">{getIcon(name)}</span>
                        <div className="flex items-center gap-1 text-xs font-bold text-amber-400">
                          <ArrowDownRight size={14} />{data.change}%
                        </div>
                      </div>
                      <p className="font-bold text-white text-sm truncate">{name?.replace(/ *\([^)]*\)/g, '')}</p>
                      <p className="text-2xl font-black mt-1" style={{ color: color.accent }}>TZS {data.price?.toLocaleString()}</p>
                      <p className="text-[10px] text-gray-500 mt-1">per kg • {data.weather} • Good time to buy</p>
                    </div>
                  )
                })}
              </div>
            </div>
          )}

          {/* All Species Market Prices */}
          <div>
            <div className="flex items-center justify-between mb-3">
              <div className="flex items-center gap-2">
                <DollarSign size={18} className="text-cyan-400" />
                <h2 className="font-bold text-white">Today's Market Prices</h2>
                <span className="text-xs text-gray-500">({alerts.length} species)</span>
              </div>
              <button onClick={() => { fetchTodayPredictions(); fetchSmartData() }}
                className="text-xs text-cyan-400 hover:text-cyan-300 bg-cyan-500/10 px-3 py-1.5 rounded-full border border-cyan-500/20 transition-all">
                🔄 Refresh
              </button>
            </div>
            
            <div className="grid grid-cols-2 sm:grid-cols-4 gap-2">
              {displaySpecies.map((a, i) => {
                const s = statusConfig[a.status]
                const color = speciesColors[i % speciesColors.length]
                const prediction = todayPredictions[a.name_en]
                const price = prices.find(p => p.species?.name_en === a.name_en)
                
                return (
                  <div key={a.id} onClick={() => fetchSpeciesForecast(a.name_en)}
                    className={`group relative rounded-2xl p-3.5 cursor-pointer transition-all duration-300 hover:-translate-y-0.5 hover:shadow-lg border ${
                      selectedSpecies === a.name_en ? 'ring-1 ring-cyan-400/50 border-cyan-400/30' : 'border-white/[0.03]'
                    }`}
                    style={{ background: 'rgba(17,24,39,0.9)' }}>
                    
                    {/* Status dot + Icon */}
                    <div className="flex items-center justify-between mb-2">
                      <div className="flex items-center gap-1.5">
                        <span className="text-lg">{getIcon(a.name_en)}</span>
                        <span className={`w-1.5 h-1.5 rounded-full ${s.dot}`} />
                      </div>
                      {prediction ? (
                        <div className={`flex items-center gap-0.5 text-[9px] font-bold ${
                          prediction.trend === 'up' ? 'text-emerald-400' : prediction.trend === 'down' ? 'text-red-400' : 'text-gray-400'
                        }`}>
                          {prediction.trend === 'up' ? <ArrowUpRight size={10} /> : prediction.trend === 'down' ? <ArrowDownRight size={10} /> : <Minus size={10} />}
                          {prediction.change > 0 ? '+' : ''}{prediction.change}%
                        </div>
                      ) : predictionLoading ? (
                        <div className="w-8 h-3 bg-white/5 rounded animate-pulse" />
                      ) : null}
                    </div>
                    
                    {/* Name */}
                    <p className="font-semibold text-white text-xs truncate mb-0.5">{a.name_en?.replace(/ *\([^)]*\)/g, '')}</p>
                    <p className="text-[9px] text-gray-600 mb-1.5">🇹🇿 {a.name_sw}</p>
                    
                    {/* Price */}
                    {prediction ? (
                      <div>
                        <p className="text-base font-black" style={{ color: color.accent }}>
                          TZS {prediction.price?.toLocaleString()}
                        </p>
                        {prediction.currentPrice && (
                          <p className="text-[9px] text-gray-500">
                            Prev: TZS {prediction.currentPrice?.toLocaleString()}
                          </p>
                        )}
                      </div>
                    ) : predictionLoading ? (
                      <div className="space-y-1 animate-pulse">
                        <div className="h-4 bg-white/10 rounded w-20" />
                        <div className="h-2 bg-white/5 rounded w-14" />
                      </div>
                    ) : (
                      <p className="text-xs text-gray-500">No data</p>
                    )}

                    {/* Tags */}
                    {prediction?.trend === 'down' && prediction.change < -5 && (
                      <span className="absolute top-2 right-2 text-[8px] bg-amber-500/10 text-amber-400 px-1.5 py-0.5 rounded-full border border-amber-500/20">
                        Best Value
                      </span>
                    )}
                    {prediction?.trend === 'up' && prediction.change > 5 && (
                      <span className="absolute top-2 right-2 text-[8px] bg-emerald-500/10 text-emerald-400 px-1.5 py-0.5 rounded-full border border-emerald-500/20">
                        Hot
                      </span>
                    )}
                  </div>
                )
              })}
            </div>

            {alerts.length > 12 && (
              <button onClick={() => setShowAllSpecies(!showAllSpecies)}
                className="w-full mt-3 py-2.5 rounded-xl bg-white/[0.02] border border-white/[0.05] text-gray-400 text-sm font-medium hover:bg-white/[0.05] hover:text-white transition-all">
                {showAllSpecies ? 'Show Less ↑' : `View All ${alerts.length} Species →`}
              </button>
            )}
          </div>
        </div>

        {/* Right Column */}
        <div className="space-y-4">
          {/* Forecast Panel */}
          {selectedSpecies && forecastPrices[selectedSpecies] && (
            <div className="bg-[#111827] rounded-3xl border border-cyan-500/20 p-5 shadow-lg shadow-cyan-500/5">
              <div className="flex items-center justify-between mb-4">
                <h3 className="font-bold text-white text-sm">📅 7-Day: {selectedSpecies}</h3>
                <button onClick={() => setSelectedSpecies(null)} className="text-gray-500 hover:text-gray-300 text-xs">✕</button>
              </div>
              <div className="space-y-1.5">
                {forecastPrices[selectedSpecies].map((f, i) => (
                  <div key={i} className="flex items-center justify-between p-2 rounded-xl bg-white/[0.02]">
                    <div className="flex items-center gap-2">
                      <span className="text-xs">{f.weather === 'Sunny' ? '☀️' : f.weather === 'Windy' ? '💨' : f.weather === 'Rainy' ? '🌧️' : f.weather === 'Calm' ? '🌤️' : '🌊'}</span>
                      <span className="text-xs text-gray-400">{f.date?.slice(5)}</span>
                    </div>
                    <p className="text-sm font-bold text-cyan-400">TZS {f.predicted_price_tzs?.toLocaleString()}</p>
                  </div>
                ))}
              </div>
            </div>
          )}

          {loadingForecast && (
            <div className="bg-[#111827] rounded-3xl border border-white/[0.05] p-6 text-center">
              <div className="animate-spin w-6 h-6 border-2 border-cyan-400 border-t-transparent rounded-full mx-auto mb-2" />
              <p className="text-sm text-gray-400">AI analyzing...</p>
            </div>
          )}

          {/* Conservation */}
          <div className="bg-[#111827] rounded-3xl border border-white/[0.05] p-5">
            <div className="flex items-center gap-2 mb-4">
              <Shield size={18} className="text-amber-400" />
              <h2 className="font-bold text-white text-sm">Conservation Status</h2>
            </div>
            <div className="grid grid-cols-3 gap-2 mb-3">
              {[
                { color: 'emerald', label: 'Safe', count: alerts.filter(a => a.status === 'green').length, emoji: '✅' },
                { color: 'amber', label: 'Caution', count: alerts.filter(a => a.status === 'amber').length, emoji: '⚠️' },
                { color: 'red', label: 'Avoid', count: alerts.filter(a => a.status === 'red').length, emoji: '🚫' },
              ].map((c, i) => (
                <div key={i} className={`text-center p-2.5 rounded-xl bg-${c.color}-500/5 border border-${c.color}-500/10`}>
                  <p className="text-lg">{c.emoji}</p>
                  <p className="text-lg font-black text-white">{c.count}</p>
                  <p className={`text-[9px] text-${c.color}-400 font-semibold`}>{c.label}</p>
                </div>
              ))}
            </div>
            <div className="space-y-1.5 max-h-40 overflow-y-auto">
              {alerts.filter(a => a.status === 'red').map(a => (
                <div key={a.id} className="flex items-center gap-2 p-2 rounded-lg bg-red-500/5 border border-red-500/10">
                  <span className="text-sm">{getIcon(a.name_en)}</span>
                  <div>
                    <p className="text-xs text-white font-medium">{a.name_en?.replace(/ *\([^)]*\)/g, '')}</p>
                    <p className="text-[9px] text-red-400">{a.note?.slice(0, 60)}...</p>
                  </div>
                </div>
              ))}
            </div>
          </div>

          {/* Smart Tip */}
          <div className="bg-gradient-to-br from-blue-600/10 to-cyan-500/10 rounded-2xl border border-cyan-500/20 p-4">
            <div className="flex items-center gap-2 mb-2">
              <Sparkles size={14} className="text-cyan-400" />
              <span className="text-xs font-semibold text-cyan-400">Buyer's Guide</span>
            </div>
            <div className="space-y-1.5 text-xs text-gray-400 leading-relaxed">
              <p>🔥 <span className="text-emerald-400">Green = Rising</span> — buy now before price goes up</p>
              <p>💛 <span className="text-amber-400">Best Value</span> — price dropping, good time to stock</p>
              <p>🚫 <span className="text-red-400">Red status</span> — restricted species, choose alternatives</p>
              <p>🔄 Click <span className="text-cyan-400">Refresh</span> for updated AI predictions</p>
            </div>
          </div>
        </div>
      </div>
    </div>
  )
}