import { useState, useEffect } from 'react'
import axios from 'axios'
import { Calendar, ShoppingCart, Clock, Phone, MapPin, User, CheckCircle, MessageCircle, Send, X, Image as ImageIcon, Package, Truck } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

const orderStatusConfig = {
  pending: { bg: 'bg-amber-500/10', text: 'text-amber-400', border: 'border-amber-500/20', label: 'PENDING', icon: Clock },
  accepted: { bg: 'bg-blue-500/10', text: 'text-blue-400', border: 'border-blue-500/20', label: 'ACCEPTED', icon: CheckCircle },
  fulfilled: { bg: 'bg-emerald-500/10', text: 'text-emerald-400', border: 'border-emerald-500/20', label: 'FULFILLED', icon: Truck },
  cancelled: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/20', label: 'CANCELLED', icon: X },
}

export default function OrdersPage({ token, alerts, orders, onOrderCreated, onForecast, user }) {
  const [form, setForm] = useState({ species: '', quantity_kg: '', delivery_date: '', max_price_tzs: '' })
  const [chatOrderId, setChatOrderId] = useState(null)
  const [chatMessages, setChatMessages] = useState([])
  const [chatMedia, setChatMedia] = useState([])
  const [chatInput, setChatInput] = useState('')
  const [chatOtherParty, setChatOtherParty] = useState('')
  const [uploading, setUploading] = useState(false)
  const [showPreOrderForm, setShowPreOrderForm] = useState(false)

  useEffect(() => {
    if (chatOrderId) {
      const fetchMessages = async () => {
        try {
          const res = await axios.get(`${API}/chat/orders/${chatOrderId}/messages/`, {
            headers: { Authorization: `Bearer ${token}` }
          })
          setChatMessages(res.data.messages || [])
          setChatMedia(res.data.media || [])
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
      setShowPreOrderForm(false)
      onOrderCreated()
    } catch (e) { alert('Order failed') }
  }

  const openChat = async (order) => {
    setChatOrderId(order.id)
    setChatOtherParty(order.accepted_by_name || order.buyer_name || 'Fisherman')
    try {
      const res = await axios.get(`${API}/chat/orders/${order.id}/messages/`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setChatMessages(res.data.messages || [])
      setChatMedia(res.data.media || [])
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
      setChatMedia(res.data.media || [])
    } catch (e) {}
  }

  const handleImageUpload = async (e) => {
    const file = e.target.files[0]
    if (!file) return
    
    setUploading(true)
    try {
      const formData = new FormData()
      formData.append('file', file)
      formData.append('media_type', 'image')
      
      await axios.post(`${API}/chat/orders/${chatOrderId}/media/`, formData, {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'multipart/form-data',
        }
      })
      
      const res = await axios.get(`${API}/chat/orders/${chatOrderId}/messages/`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setChatMessages(res.data.messages || [])
      setChatMedia(res.data.media || [])
    } catch (e) {
      alert('Image upload failed')
    }
    setUploading(false)
  }

  const combinedItems = [
    ...chatMedia.map(m => ({ ...m, itemType: 'media' })),
    ...chatMessages.map(m => ({ ...m, itemType: 'message' })),
  ].sort((a, b) => new Date(a.created_at) - new Date(b.created_at))

  const pendingOrders = orders.filter(o => o.status === 'pending')
  const acceptedOrders = orders.filter(o => o.status === 'accepted')
  const fulfilledOrders = orders.filter(o => o.status === 'fulfilled')

  const getSpeciesIcon = (name) => {
    if (name?.includes('Octopus')) return '🐙'
    if (name?.includes('Tuna')) return '🐟'
    if (name?.includes('Snapper')) return '🐡'
    if (name?.includes('King')) return '👑'
    if (name?.includes('Lobster')) return '🦞'
    if (name?.includes('Sardine')) return '🐟'
    if (name?.includes('Shrimp')) return '🦐'
    if (name?.includes('Parrot')) return '🐠'
    if (name?.includes('Rabbit')) return '🐰'
    if (name?.includes('Grouper')) return '🐟'
    if (name?.includes('Sword')) return '⚔️'
    if (name?.includes('Barracuda')) return '🐊'
    if (name?.includes('Shark')) return '🦈'
    if (name?.includes('Anchovy')) return '🐟'
    if (name?.includes('Mackerel')) return '🐟'
    return '🐟'
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
      {/* Header */}
      <div className="mb-6 flex items-center justify-between">
        <div>
          <h1 className="text-2xl font-bold text-white">📋 My Orders</h1>
          <p className="text-gray-400 text-sm mt-1">
            {pendingOrders.length} pending • {acceptedOrders.length} accepted • {fulfilledOrders.length} fulfilled
          </p>
        </div>
        <button
          onClick={() => setShowPreOrderForm(!showPreOrderForm)}
          className="px-4 py-2.5 bg-violet-600 hover:bg-violet-700 rounded-xl text-white text-sm font-semibold transition-all flex items-center gap-2"
        >
          <Package size={16} /> {showPreOrderForm ? 'Close' : 'Custom Pre-Order'}
        </button>
      </div>

      {/* Custom Pre-Order Form */}
      {showPreOrderForm && (
        <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-6 mb-6">
          <div className="flex items-center gap-3 mb-4">
            <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-violet-500/20 to-purple-500/20 border border-violet-400/20 flex items-center justify-center">
              <Calendar size={18} className="text-violet-400" />
            </div>
            <h2 className="font-bold text-white">Custom Pre-Order</h2>
          </div>
          <form onSubmit={createOrder} className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Species</label>
              <select value={form.species} onChange={e => setForm({...form, species: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white focus:outline-none focus:ring-2 focus:ring-violet-500/20" required>
                <option value="">Select species...</option>
                {alerts.filter(a => a.status !== 'red').map(a => <option key={a.id} value={a.id}>{a.name_en?.replace(/ *\([^)]*\)/g, '')}</option>)}
              </select>
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Quantity (kg)</label>
              <input type="number" value={form.quantity_kg} onChange={e => setForm({...form, quantity_kg: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white placeholder-gray-600" placeholder="Min 1 kg" min="1" required />
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Delivery Date</label>
              <input type="date" value={form.delivery_date} onChange={e => setForm({...form, delivery_date: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white" required />
            </div>
            <div className="flex items-end">
              <button type="submit" className="w-full bg-gradient-to-r from-violet-600 to-purple-600 text-white py-3 rounded-xl font-semibold hover:shadow-lg transition-all flex items-center justify-center gap-2">
                <ShoppingCart size={16} /> Place
              </button>
            </div>
          </form>
        </div>
      )}

      {/* Orders List */}
      <div className="space-y-4">
        {orders.map(o => {
          const s = orderStatusConfig[o.status] || orderStatusConfig.pending
          const StatusIcon = s.icon
          const hasAccepted = o.accepted_by_name != null
          const isBuyer = user?.role === 'hotel_buyer'
          const otherParty = isBuyer ? (o.accepted_by_name || 'Fisherman') : (o.buyer_name || 'Buyer')

          return (
            <div key={o.id} className="bg-[#111827] rounded-2xl border border-white/[0.05] p-5 hover:border-white/[0.1] transition-all">
              {/* Header */}
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{getSpeciesIcon(o.species_name)}</span>
                  <div>
                    <p className="font-bold text-white">Order #{o.id} - {o.species_name}</p>
                    <p className="text-xs text-gray-500">{o.quantity_kg} kg • Delivery: {o.delivery_date}</p>
                  </div>
                </div>
                <span className={`text-[10px] font-bold px-3 py-1.5 rounded-full ${s.bg} ${s.text} border ${s.border} uppercase tracking-wider flex items-center gap-1`}>
                  <StatusIcon size={10} /> {s.label}
                </span>
              </div>

              {/* Order Details */}
              <div className="grid grid-cols-3 gap-3 mb-4">
                <div className="bg-white/[0.03] rounded-xl p-3 text-center">
                  <p className="text-xs text-gray-500 mb-1">Quantity</p>
                  <p className="font-bold text-white">{o.quantity_kg} kg</p>
                </div>
                <div className="bg-white/[0.03] rounded-xl p-3 text-center">
                  <p className="text-xs text-gray-500 mb-1">Price</p>
                  <p className="font-bold text-white">{o.max_price_tzs ? `TZS ${Number(o.max_price_tzs).toLocaleString()}` : 'Market'}</p>
                </div>
                <div className="bg-white/[0.03] rounded-xl p-3 text-center">
                  <p className="text-xs text-gray-500 mb-1">Delivery</p>
                  <p className="font-bold text-white text-sm">{o.delivery_date}</p>
                </div>
              </div>

              {/* Party Info */}
              {hasAccepted && (
                <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-xl p-4 mb-3">
                  <p className="text-xs font-semibold text-emerald-400 uppercase tracking-wider mb-3">
                    {isBuyer ? '🎣 Fisherman' : '🏨 Buyer'}
                  </p>
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div className="flex items-center gap-2">
                      <User size={14} className="text-emerald-400" />
                      <div>
                        <p className="text-[10px] text-gray-500">Name</p>
                        <p className="text-sm text-white font-medium">{otherParty}</p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Phone size={14} className="text-emerald-400" />
                      <div>
                        <p className="text-[10px] text-gray-500">Contact</p>
                        <p className="text-sm text-white font-medium">
                          {isBuyer ? (o.accepted_by_phone || '—') : (o.buyer_phone || '—')}
                        </p>
                      </div>
                    </div>
                    <div className="flex items-center gap-2">
                      <MapPin size={14} className="text-emerald-400" />
                      <div>
                        <p className="text-[10px] text-gray-500">Location</p>
                        <p className="text-sm text-white font-medium">
                          {isBuyer ? (o.accepted_by_market || '—') : (o.buyer_location || '—')}
                        </p>
                      </div>
                    </div>
                  </div>
                </div>
              )}

              {/* Fulfilled Badge */}
              {o.status === 'fulfilled' && (
                <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-xl p-3 flex items-center justify-center gap-2">
                  <CheckCircle size={16} className="text-emerald-400" />
                  <span className="text-emerald-400 text-sm font-semibold">Delivery Completed</span>
                </div>
              )}

              {/* Actions */}
              <div className="flex gap-2 mt-3">
                {(o.status === 'accepted' || o.status === 'fulfilled') && hasAccepted && (
                  <button
                    onClick={() => openChat(o)}
                    className="flex-1 py-2.5 bg-cyan-500/10 border border-cyan-500/20 rounded-xl text-cyan-400 text-sm font-semibold hover:bg-cyan-500/20 transition-all flex items-center justify-center gap-2"
                  >
                    <MessageCircle size={16} /> Chat
                  </button>
                )}
                <button
                  onClick={() => onForecast(o.species_name, 'Darajani Market')}
                  className="px-4 py-2.5 text-xs font-semibold text-cyan-400 hover:text-cyan-300 bg-cyan-500/10 hover:bg-cyan-500/20 rounded-lg transition-all border border-cyan-500/20"
                >
                  Forecast
                </button>
              </div>
            </div>
          )
        })}

        {orders.length === 0 && (
          <div className="text-center py-16 text-gray-600">
            <ShoppingCart size={48} className="mb-4 opacity-30 mx-auto" />
            <p className="font-medium">No orders yet</p>
            <p className="text-sm">Browse the Marketplace to order fresh fish</p>
          </div>
        )}
      </div>

      {/* Chat Modal */}
      {chatOrderId && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#111827] rounded-2xl border border-white/[0.08] w-full max-w-md h-[550px] flex flex-col">
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
              {combinedItems.map((item, i) => {
                if (item.itemType === 'media') {
                  const isMe = item.uploader_name === user?.username
                  return (
                    <div key={`media-${i}`} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
                      <div className="max-w-[70%] bg-white/[0.05] rounded-2xl p-2">
                        <img src={item.file_url} alt="Fish" className="rounded-xl max-w-full max-h-48 object-cover" />
                        <p className={`text-[9px] mt-1 ${isMe ? 'text-right' : 'text-left'} text-gray-500`}>
                          {new Date(item.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                        </p>
                      </div>
                    </div>
                  )
                }
                const isMe = item.sender_name === user?.username
                return (
                  <div key={`msg-${i}`} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
                    <div className={`max-w-[70%] px-4 py-2 rounded-2xl ${isMe ? 'bg-gradient-to-r from-blue-600 to-cyan-500' : 'bg-white/[0.05]'}`}>
                      <p className="text-sm text-white">{item.message}</p>
                      <p className={`text-[9px] mt-1 ${isMe ? 'text-white/70' : 'text-gray-500'}`}>
                        {new Date(item.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}
                      </p>
                    </div>
                  </div>
                )
              })}
              {combinedItems.length === 0 && (
                <p className="text-center text-gray-600 text-sm">No messages yet. Say hello!</p>
              )}
            </div>

            <div className="p-3 border-t border-white/[0.05] flex gap-2">
              <label className="cursor-pointer">
                <input type="file" accept="image/*" className="hidden" onChange={handleImageUpload} disabled={uploading} />
                <div className="w-10 h-10 bg-white/[0.03] border border-white/[0.08] rounded-xl flex items-center justify-center hover:bg-white/[0.08] transition-all">
                  {uploading ? <div className="w-4 h-4 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" /> : <ImageIcon size={18} className="text-gray-400" />}
                </div>
              </label>
              <input
                type="text"
                value={chatInput}
                onChange={e => setChatInput(e.target.value)}
                onKeyPress={e => e.key === 'Enter' && sendChatMessage()}
                placeholder="Type a message..."
                className="flex-1 bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-2.5 text-sm text-white placeholder-gray-600 focus:outline-none focus:border-cyan-400/50"
              />
              <button onClick={sendChatMessage} className="px-4 py-2.5 bg-gradient-to-r from-blue-600 to-cyan-500 rounded-xl text-white">
                <Send size={16} />
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}