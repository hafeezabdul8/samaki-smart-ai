import { useState, useEffect } from 'react'
import axios from 'axios'
import { Calendar, ShoppingCart, Clock, Phone, MapPin, Hotel, User, CheckCircle, MessageCircle, Send, X } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

const orderStatusConfig = {
  pending: { bg: 'bg-amber-500/10', text: 'text-amber-400', border: 'border-amber-500/20' },
  accepted: { bg: 'bg-blue-500/10', text: 'text-blue-400', border: 'border-blue-500/20' },
  fulfilled: { bg: 'bg-emerald-500/10', text: 'text-emerald-400', border: 'border-emerald-500/20' },
  cancelled: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/20' },
}

export default function OrdersPage({ token, alerts, orders, onOrderCreated, onForecast, user }) {
  const [form, setForm] = useState({ species: '', quantity_kg: '', delivery_date: '', max_price_tzs: '' })
  const [chatOrderId, setChatOrderId] = useState(null)
  const [chatMessages, setChatMessages] = useState([])
  const [chatInput, setChatInput] = useState('')
  const [chatOtherParty, setChatOtherParty] = useState('')

  useEffect(() => {
    if (chatOrderId) {
      const fetchMessages = async () => {
        try {
          const res = await axios.get(`${API}/chat/orders/${chatOrderId}/messages/`, {
            headers: { Authorization: `Bearer ${token}` }
          })
          setChatMessages(res.data.messages || [])
        } catch (e) {}
      }
      fetchMessages()
      const interval = setInterval(fetchMessages, 4000)
      return () => clearInterval(interval)
    }
  }, [chatOrderId, token])

  const createOrder = async (e) => {
    e.preventDefault()
    try {
      await axios.post(`${API}/orders/`, form, { headers: { Authorization: `Bearer ${token}` } })
      setForm({ species: '', quantity_kg: '', delivery_date: '', max_price_tzs: '' })
      onOrderCreated()
    } catch (e) { alert('Order failed') }
  }

  const openChat = async (order) => {
    setChatOrderId(order.id)
    setChatOtherParty(order.accepted_by_name || 'Fisherman')
    try {
      const res = await axios.get(`${API}/chat/orders/${order.id}/messages/`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setChatMessages(res.data.messages || [])
    } catch (e) {}
  }

  const sendChatMessage = async () => {
    if (!chatInput.trim()) return
    try {
      await axios.post(`${API}/chat/orders/${chatOrderId}/send/`,
        { message: chatInput },
        { headers: { Authorization: `Bearer ${token}` } }
      )
      setChatInput('')
      const res = await axios.get(`${API}/chat/orders/${chatOrderId}/messages/`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setChatMessages(res.data.messages || [])
    } catch (e) {}
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        {/* Order Form */}
        <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-5 sm:p-6">
          <div className="flex items-center gap-3 mb-6">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-violet-500/20 to-purple-500/20 border border-violet-400/20 flex items-center justify-center">
              <Calendar size={18} className="text-violet-400" />
            </div>
            <div><h2 className="font-bold text-white">New Pre-Order</h2><p className="text-xs text-gray-500">Request fish supply</p></div>
          </div>
          <form onSubmit={createOrder} className="space-y-4">
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Species</label>
              <select value={form.species} onChange={e => setForm({...form, species: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-500/50 transition-all" required>
                <option value="">Select species...</option>
                {alerts.filter(a => a.status !== 'red').map(a => <option key={a.id} value={a.id}>{a.name_en?.replace(/ *\([^)]*\)/g, '')}</option>)}
              </select>
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Quantity (kg)</label>
              <input type="number" value={form.quantity_kg} onChange={e => setForm({...form, quantity_kg: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white placeholder-gray-600 focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-500/50 transition-all" placeholder="Min 1 kg" min="1" required />
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Delivery Date</label>
              <input type="date" value={form.delivery_date} onChange={e => setForm({...form, delivery_date: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-500/50 transition-all" required />
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Max Price (TZS) <span className="text-gray-700 font-normal normal-case">— Optional</span></label>
              <input type="number" value={form.max_price_tzs} onChange={e => setForm({...form, max_price_tzs: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white placeholder-gray-600 focus:outline-none focus:ring-2 focus:ring-violet-500/20 focus:border-violet-500/50 transition-all" placeholder="Market price if empty" />
            </div>
            <button type="submit" className="w-full bg-gradient-to-r from-violet-600 to-purple-600 text-white py-3.5 rounded-xl font-semibold shadow-lg shadow-violet-500/20 hover:shadow-violet-500/40 hover:scale-[1.01] active:scale-[0.99] transition-all duration-300 flex items-center justify-center gap-2">
              <ShoppingCart size={18} /> Place Order
            </button>
          </form>
        </div>

        {/* Orders List */}
        <div className="lg:col-span-2 bg-[#111827] rounded-2xl border border-white/[0.05] p-5 sm:p-6">
          <div className="flex items-center justify-between mb-6">
            <div className="flex items-center gap-3">
              <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-500/20 to-cyan-500/20 border border-blue-400/20 flex items-center justify-center">
                <Clock size={18} className="text-blue-400" />
              </div>
              <div><h2 className="font-bold text-white">My Orders</h2><p className="text-xs text-gray-500">{orders.length} total orders</p></div>
            </div>
          </div>
          <div className="space-y-4">
            {orders.map(o => {
              const s = orderStatusConfig[o.status]
              const hasAccepted = o.accepted_by_name != null
              return (
                <div key={o.id} className="border border-white/[0.05] rounded-2xl p-5 bg-white/[0.02] hover:bg-white/[0.04] transition-all">
                  <div className="flex items-center justify-between mb-4">
                    <div className="flex items-center gap-3">
                      <span className="text-2xl">
                        {o.species_name?.includes('Octopus') ? '🐙' :
                         o.species_name?.includes('Tuna') ? '🐟' :
                         o.species_name?.includes('Snapper') ? '🐡' :
                         o.species_name?.includes('King') ? '👑' :
                         o.species_name?.includes('Lobster') ? '🦞' :
                         o.species_name?.includes('Sardine') ? '🐟' :
                         o.species_name?.includes('Shrimp') ? '🦐' :
                         o.species_name?.includes('Parrot') ? '🐠' :
                         o.species_name?.includes('Rabbit') ? '🐰' :
                         o.species_name?.includes('Grouper') ? '🐟' :
                         o.species_name?.includes('Sword') ? '⚔️' :
                         o.species_name?.includes('Barracuda') ? '🐊' :
                         o.species_name?.includes('Shark') ? '🦈' :
                         o.species_name?.includes('Anchovy') ? '🐟' :
                         o.species_name?.includes('Mackerel') ? '🐟' : '🐟'}
                      </span>
                      <div>
                        <p className="font-bold text-white">Order #{o.id} - {o.species_name}</p>
                        <p className="text-xs text-gray-500">{o.quantity_kg} kg • Delivery: {o.delivery_date}</p>
                      </div>
                    </div>
                    <span className={`text-[10px] font-bold px-3 py-1.5 rounded-full ${s.bg} ${s.text} border ${s.border} uppercase tracking-wider`}>
                      {o.status}
                    </span>
                  </div>

                  <div className="grid grid-cols-3 gap-3 mb-4">
                    <div className="bg-white/[0.03] rounded-xl p-3 text-center">
                      <p className="text-xs text-gray-500 mb-1">Quantity</p>
                      <p className="font-bold text-white">{o.quantity_kg} kg</p>
                    </div>
                    <div className="bg-white/[0.03] rounded-xl p-3 text-center">
                      <p className="text-xs text-gray-500 mb-1">Max Price</p>
                      <p className="font-bold text-white">{o.max_price_tzs ? `TZS ${Number(o.max_price_tzs).toLocaleString()}` : 'Market'}</p>
                    </div>
                    <div className="bg-white/[0.03] rounded-xl p-3 text-center">
                      <p className="text-xs text-gray-500 mb-1">Delivery</p>
                      <p className="font-bold text-white text-sm">{o.delivery_date}</p>
                    </div>
                  </div>

                  {hasAccepted && (
                    <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-xl p-4 mb-3">
                      <p className="text-xs font-semibold text-emerald-400 uppercase tracking-wider mb-3">🎣 Accepted By</p>
                      <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                        <div className="flex items-center gap-2">
                          <User size={14} className="text-emerald-400" />
                          <div>
                            <p className="text-[10px] text-gray-500">Fisherman</p>
                            <p className="text-sm text-white font-medium">{o.accepted_by_name}</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <Phone size={14} className="text-emerald-400" />
                          <div>
                            <p className="text-[10px] text-gray-500">Contact</p>
                            <p className="text-sm text-white font-medium">{o.accepted_by_phone || '—'}</p>
                          </div>
                        </div>
                        <div className="flex items-center gap-2">
                          <MapPin size={14} className="text-emerald-400" />
                          <div>
                            <p className="text-[10px] text-gray-500">Market</p>
                            <p className="text-sm text-white font-medium">{o.accepted_by_market || '—'}</p>
                          </div>
                        </div>
                      </div>
                    </div>
                  )}

                  {o.status === 'fulfilled' && (
                    <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-xl p-3 flex items-center justify-center gap-2">
                      <CheckCircle size={16} className="text-emerald-400" />
                      <span className="text-emerald-400 text-sm font-semibold">Delivery Completed</span>
                    </div>
                  )}

                  {(o.status === 'accepted' || o.status === 'fulfilled') && hasAccepted && (
                    <button
                      onClick={() => openChat(o)}
                      className="w-full py-2.5 bg-cyan-500/10 border border-cyan-500/20 rounded-xl text-cyan-400 text-sm font-semibold hover:bg-cyan-500/20 transition-all flex items-center justify-center gap-2 mt-3"
                    >
                      <MessageCircle size={16} />
                      Chat with {o.accepted_by_name || 'Fisherman'}
                    </button>
                  )}

                  <div className="flex justify-end mt-3">
                    <button onClick={() => onForecast(o.species_name, 'Darajani Market')}
                      className="text-xs font-semibold text-cyan-400 hover:text-cyan-300 bg-cyan-500/10 hover:bg-cyan-500/20 px-3 py-1.5 rounded-lg transition-all border border-cyan-500/20">
                      View Forecast
                    </button>
                  </div>
                </div>
              )
            })}
            {orders.length === 0 && (
              <div className="flex flex-col items-center justify-center py-16 text-gray-600">
                <ShoppingCart size={48} className="mb-4 opacity-30" />
                <p className="font-medium">No orders yet</p>
                <p className="text-sm">Create your first pre-order to get started</p>
              </div>
            )}
          </div>
        </div>
      </div>

      {/* Chat Modal */}
      {chatOrderId && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#111827] rounded-2xl border border-white/[0.08] w-full max-w-md h-[500px] flex flex-col">
            <div className="flex items-center justify-between p-4 border-b border-white/[0.05]">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-600 to-cyan-500 flex items-center justify-center text-sm font-bold text-white">
                  {chatOtherParty[0]?.toUpperCase()}
                </div>
                <div>
                  <p className="font-semibold text-white text-sm">{chatOtherParty}</p>
                  <p className="text-xs text-gray-500">Order #{chatOrderId}</p>
                </div>
              </div>
              <button onClick={() => setChatOrderId(null)} className="text-gray-500 hover:text-white">
                <X size={18} />
              </button>
            </div>

            <div className="flex-1 overflow-y-auto p-4 space-y-3">
              {chatMessages.map((msg, i) => {
                const isMe = msg.sender_name === user?.username
                return (
                  <div key={i} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
                    <div className={`max-w-[70%] px-4 py-2 rounded-2xl ${
                      isMe
                        ? 'bg-gradient-to-r from-blue-600 to-cyan-500'
                        : 'bg-white/[0.05]'
                    }`}>
                      <p className="text-sm text-white">{msg.message}</p>
                      <p className={`text-[9px] mt-1 ${isMe ? 'text-white/70' : 'text-gray-500'}`}>
                        {new Date(msg.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </p>
                    </div>
                  </div>
                )
              })}
              {chatMessages.length === 0 && (
                <p className="text-center text-gray-600 text-sm">No messages yet. Say hello!</p>
              )}
            </div>

            <div className="p-3 border-t border-white/[0.05] flex gap-2">
              <input
                type="text"
                value={chatInput}
                onChange={e => setChatInput(e.target.value)}
                onKeyPress={e => e.key === 'Enter' && sendChatMessage()}
                placeholder="Type a message..."
                className="flex-1 bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-2.5 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-cyan-400/50"
              />
              <button
                onClick={sendChatMessage}
                className="px-4 py-2.5 bg-gradient-to-r from-blue-600 to-cyan-500 rounded-xl text-white"
              >
                <Send size={16} />
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}