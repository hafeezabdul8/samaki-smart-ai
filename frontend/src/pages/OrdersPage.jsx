import { useState, useEffect } from 'react'
import axios from 'axios'
import { Calendar, ShoppingCart, Clock, Phone, MapPin, User, CheckCircle, MessageCircle, Send, X, Image as ImageIcon, History, Package, CreditCard, Upload, Check, Truck } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

const orderStatusConfig = {
  pending: { bg: 'bg-amber-500/10', text: 'text-amber-400', border: 'border-amber-500/20', label: 'PENDING' },
  accepted: { bg: 'bg-blue-500/10', text: 'text-blue-400', border: 'border-blue-500/20', label: 'ACCEPTED' },
  fulfilled: { bg: 'bg-emerald-500/10', text: 'text-emerald-400', border: 'border-emerald-500/20', label: 'FULFILLED' },
  cancelled: { bg: 'bg-red-500/10', text: 'text-red-400', border: 'border-red-500/20', label: 'CANCELLED' },
}

export default function OrdersPage({ token, alerts, orders, onOrderCreated, onForecast, user }) {
  const [form, setForm] = useState({ species: '', quantity_kg: '', delivery_date: '', max_price_tzs: '' })
  const [chatOrderId, setChatOrderId] = useState(null)
  const [chatMessages, setChatMessages] = useState([])
  const [chatMedia, setChatMedia] = useState([])
  const [chatInput, setChatInput] = useState('')
  const [chatOtherParty, setChatOtherParty] = useState('')
  const [uploading, setUploading] = useState(false)
  const [showHistory, setShowHistory] = useState(false)
  const [historyOrders, setHistoryOrders] = useState([])
  const [historyPeriod, setHistoryPeriod] = useState('all')
  const [showPreOrderForm, setShowPreOrderForm] = useState(false)
  const [paymentOrderId, setPaymentOrderId] = useState(null)
  const [payment, setPayment] = useState(null)
  const [delivery, setDelivery] = useState(null)
  const [paymentOrder, setPaymentOrder] = useState(null)
  const [uploadingReceipt, setUploadingReceipt] = useState(false)

  const isBuyer = user?.role === 'hotel_buyer'

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

  useEffect(() => {
    if (showHistory) fetchHistory()
  }, [showHistory, historyPeriod])

  const fetchHistory = async () => {
    try {
      const res = await axios.get(`${API}/orders/history/?period=${historyPeriod}`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setHistoryOrders(res.data.results || res.data || [])
    } catch (e) {}
  }

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
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'multipart/form-data' }
      })
      const res = await axios.get(`${API}/chat/orders/${chatOrderId}/messages/`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setChatMessages(res.data.messages || [])
      setChatMedia(res.data.media || [])
    } catch (e) { alert('Image upload failed') }
    setUploading(false)
  }

  // Payment functions
  const openPayment = async (order) => {
    setPaymentOrderId(order.id)
    setPaymentOrder(order)
    try {
      const res = await axios.get(`${API}/orders/${order.id}/details/`, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setPayment(res.data.payment || null)
      setDelivery(res.data.delivery || null)
    } catch (e) {}
  }

  const generatePayment = async () => {
    try {
      const res = await axios.post(`${API}/orders/${paymentOrderId}/payment/`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setPayment(res.data)
    } catch (e) { alert('Failed to generate payment') }
  }

  const uploadReceipt = async (e) => {
    const file = e.target.files[0]
    if (!file) return
    setUploadingReceipt(true)
    try {
      const formData = new FormData()
      formData.append('file', file)
      const res = await axios.post(`${API}/orders/${paymentOrderId}/payment/receipt/`, formData, {
        headers: { Authorization: `Bearer ${token}`, 'Content-Type': 'multipart/form-data' }
      })
      setPayment(res.data)
      alert('Receipt uploaded successfully!')
    } catch (e) { alert('Upload failed') }
    setUploadingReceipt(false)
  }

  const approvePayment = async () => {
    try {
      const res = await axios.post(`${API}/orders/${paymentOrderId}/payment/approve/`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setPayment(res.data)
      alert('Payment approved!')
    } catch (e) { alert('Failed to approve') }
  }

  const rejectPayment = async () => {
    try {
      const res = await axios.post(`${API}/orders/${paymentOrderId}/payment/reject/`, {}, {
        headers: { Authorization: `Bearer ${token}` }
      })
      setPayment(res.data)
      alert('Payment rejected')
    } catch (e) { alert('Failed to reject') }
  }

  const combinedItems = [
    ...chatMedia.map(m => ({ ...m, itemType: 'media' })),
    ...chatMessages.map(m => ({ ...m, itemType: 'message' })),
  ].sort((a, b) => new Date(a.created_at) - new Date(b.created_at))

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

  const displayOrders = showHistory ? historyOrders : orders

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
      <div className="mb-6 flex items-center justify-between flex-wrap gap-3">
        <div>
          <h1 className="text-2xl font-bold text-white">{showHistory ? '📜 Order History' : '📋 My Orders'}</h1>
          <p className="text-gray-400 text-sm mt-1">{showHistory ? `${historyOrders.length} past orders` : `${orders.length} active orders`}</p>
        </div>
        <div className="flex gap-2">
          {showHistory && (
            <select value={historyPeriod} onChange={e => setHistoryPeriod(e.target.value)}
              className="bg-[#111827] border border-white/[0.08] rounded-xl px-3 py-2 text-sm text-white">
              <option value="all">All Time</option>
              <option value="daily">Daily</option>
              <option value="monthly">Monthly</option>
              <option value="yearly">Yearly</option>
            </select>
          )}
          <button onClick={() => setShowHistory(!showHistory)}
            className="px-4 py-2 bg-cyan-500/10 border border-cyan-500/20 rounded-xl text-cyan-400 text-sm font-semibold hover:bg-cyan-500/20 transition-all flex items-center gap-2">
            <History size={16} /> {showHistory ? 'View Active' : 'History'}
          </button>
          {!showHistory && (
            <button onClick={() => setShowPreOrderForm(!showPreOrderForm)}
              className="px-4 py-2 bg-violet-600 hover:bg-violet-700 rounded-xl text-white text-sm font-semibold transition-all flex items-center gap-2">
              <Package size={16} /> Custom Order
            </button>
          )}
        </div>
      </div>

      {showPreOrderForm && !showHistory && (
        <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-6 mb-6">
          <h2 className="font-bold text-white mb-4">Custom Pre-Order</h2>
          <form onSubmit={createOrder} className="grid grid-cols-1 md:grid-cols-4 gap-4">
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase mb-2 block">Species</label>
              <select value={form.species} onChange={e => setForm({...form, species: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white" required>
                <option value="">Select species...</option>
                {alerts.filter(a => a.status !== 'red').map(a => <option key={a.id} value={a.id}>{a.name_en?.replace(/ *\([^)]*\)/g, '')}</option>)}
              </select>
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase mb-2 block">Quantity (kg)</label>
              <input type="number" value={form.quantity_kg} onChange={e => setForm({...form, quantity_kg: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white" placeholder="Min 1 kg" required />
            </div>
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase mb-2 block">Delivery Date</label>
              <input type="date" value={form.delivery_date} onChange={e => setForm({...form, delivery_date: e.target.value})}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-sm text-white" required />
            </div>
            <div className="flex items-end">
              <button type="submit" className="w-full bg-gradient-to-r from-violet-600 to-purple-600 text-white py-3 rounded-xl font-semibold">Place Order</button>
            </div>
          </form>
        </div>
      )}

      <div className="space-y-4">
        {displayOrders.map(o => {
          const s = orderStatusConfig[o.status] || orderStatusConfig.pending
          const hasAccepted = o.accepted_by_name != null
          const otherParty = isBuyer ? (o.accepted_by_name || 'Fisherman') : (o.buyer_name || 'Buyer')

          return (
            <div key={o.id} className="bg-[#111827] rounded-2xl border border-white/[0.05] p-5 hover:border-white/[0.1] transition-all">
              <div className="flex items-center justify-between mb-4">
                <div className="flex items-center gap-3">
                  <span className="text-2xl">{getSpeciesIcon(o.species_name)}</span>
                  <div>
                    <p className="font-bold text-white">Order #{o.id} - {o.species_name}</p>
                    <p className="text-xs text-gray-500">{o.quantity_kg} kg • Delivery: {o.delivery_date}</p>
                  </div>
                </div>
                <span className={`text-[10px] font-bold px-3 py-1.5 rounded-full ${s.bg} ${s.text} border ${s.border} uppercase`}>{s.label}</span>
              </div>

              <div className="grid grid-cols-3 gap-3 mb-4">
                <div className="bg-white/[0.03] rounded-xl p-3 text-center">
                  <p className="text-xs text-gray-500">Quantity</p>
                  <p className="font-bold text-white">{o.quantity_kg} kg</p>
                </div>
                <div className="bg-white/[0.03] rounded-xl p-3 text-center">
                  <p className="text-xs text-gray-500">Price</p>
                  <p className="font-bold text-white">{o.max_price_tzs ? `TZS ${Number(o.max_price_tzs).toLocaleString()}` : 'Market'}</p>
                </div>
                <div className="bg-white/[0.03] rounded-xl p-3 text-center">
                  <p className="text-xs text-gray-500">Delivery</p>
                  <p className="font-bold text-white text-sm">{o.delivery_date}</p>
                </div>
              </div>

              {hasAccepted && !showHistory && (
                <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-xl p-4 mb-3">
                  <div className="grid grid-cols-1 sm:grid-cols-3 gap-3">
                    <div className="flex items-center gap-2">
                      <User size={14} className="text-emerald-400" />
                      <div><p className="text-[10px] text-gray-500">Name</p><p className="text-sm text-white font-medium">{otherParty}</p></div>
                    </div>
                    <div className="flex items-center gap-2">
                      <Phone size={14} className="text-emerald-400" />
                      <div><p className="text-[10px] text-gray-500">Contact</p><p className="text-sm text-white font-medium">{isBuyer ? (o.accepted_by_phone || '—') : (o.buyer_phone || '—')}</p></div>
                    </div>
                    <div className="flex items-center gap-2">
                      <MapPin size={14} className="text-emerald-400" />
                      <div><p className="text-[10px] text-gray-500">Location</p><p className="text-sm text-white font-medium">{isBuyer ? (o.accepted_by_market || '—') : (o.buyer_location || '—')}</p></div>
                    </div>
                  </div>
                </div>
              )}

              {!showHistory && o.status === 'accepted' && hasAccepted && (
                <div className="flex flex-col sm:flex-row gap-2 mt-3">
                  <button onClick={() => openPayment(o)}
                    className="flex-1 py-2.5 bg-amber-500/10 border border-amber-500/20 rounded-xl text-amber-400 text-sm font-semibold hover:bg-amber-500/20 transition-all flex items-center justify-center gap-2">
                    <CreditCard size={16} /> {isBuyer ? 'Pay Now' : 'Payment & Delivery'}
                  </button>
                  <button onClick={() => openChat(o)}
                    className="flex-1 py-2.5 bg-cyan-500/10 border border-cyan-500/20 rounded-xl text-cyan-400 text-sm font-semibold hover:bg-cyan-500/20 transition-all flex items-center justify-center gap-2">
                    <MessageCircle size={16} /> Chat
                  </button>
                </div>
              )}

              {o.status === 'fulfilled' && (
                <div className="bg-emerald-500/5 border border-emerald-500/20 rounded-xl p-3 flex items-center justify-center gap-2">
                  <CheckCircle size={16} className="text-emerald-400" />
                  <span className="text-emerald-400 text-sm font-semibold">Delivery Completed</span>
                </div>
              )}
            </div>
          )
        })}
        {displayOrders.length === 0 && (
          <div className="text-center py-16 text-gray-600">
            <p className="text-5xl mb-4">{showHistory ? '📜' : '📋'}</p>
            <p className="font-medium">{showHistory ? 'No order history' : 'No active orders'}</p>
          </div>
        )}
      </div>

      {/* Chat Modal */}
      {chatOrderId && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#111827] rounded-2xl border border-white/[0.08] w-full max-w-md h-[550px] flex flex-col">
            <div className="flex items-center justify-between p-4 border-b border-white/[0.05]">
              <div className="flex items-center gap-2">
                <div className="w-8 h-8 rounded-full bg-gradient-to-br from-blue-600 to-cyan-500 flex items-center justify-center text-sm font-bold text-white">{chatOtherParty[0]?.toUpperCase()}</div>
                <div><p className="font-semibold text-white text-sm">{chatOtherParty}</p><p className="text-xs text-gray-500">Order #{chatOrderId}</p></div>
              </div>
              <button onClick={() => setChatOrderId(null)} className="text-gray-500 hover:text-white"><X size={18} /></button>
            </div>
            <div className="flex-1 overflow-y-auto p-4 space-y-3">
              {combinedItems.map((item, i) => {
                if (item.itemType === 'media') {
                  const isMe = item.uploader_name === user?.username || item.uploader === user?.id
                  return (
                    <div key={`media-${i}`} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
                      <div className={`max-w-[70%] rounded-2xl p-2 ${isMe ? 'bg-gradient-to-r from-blue-600 to-cyan-500' : 'bg-white/[0.05]'}`}>
                        <img src={item.file_url} alt="Fish" className="rounded-xl max-w-full max-h-48 object-cover" />
                      </div>
                    </div>
                  )
                }
                const isMe = item.sender_name === user?.username || item.sender === user?.id
                return (
                  <div key={`msg-${i}`} className={`flex ${isMe ? 'justify-end' : 'justify-start'}`}>
                    <div className={`max-w-[70%] px-4 py-2 rounded-2xl ${isMe ? 'bg-gradient-to-r from-blue-600 to-cyan-500' : 'bg-white/[0.05]'}`}>
                      <p className="text-sm text-white">{item.message}</p>
                      <p className={`text-[9px] mt-1 ${isMe ? 'text-white/70' : 'text-gray-500'}`}>{item.sender_name || (isMe ? 'You' : 'Other')} • {new Date(item.created_at).toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' })}</p>
                    </div>
                  </div>
                )
              })}
              {combinedItems.length === 0 && <p className="text-center text-gray-600 text-sm">No messages yet. Say hello!</p>}
            </div>
            <div className="p-3 border-t border-white/[0.05] flex gap-2">
              <label className="cursor-pointer">
                <input type="file" accept="image/*" className="hidden" onChange={handleImageUpload} disabled={uploading} />
                <div className="w-10 h-10 bg-white/[0.03] border border-white/[0.08] rounded-xl flex items-center justify-center hover:bg-white/[0.08] transition-all">
                  {uploading ? <div className="w-4 h-4 border-2 border-cyan-400 border-t-transparent rounded-full animate-spin" /> : <ImageIcon size={18} className="text-gray-400" />}
                </div>
              </label>
              <input type="text" value={chatInput} onChange={e => setChatInput(e.target.value)} onKeyPress={e => e.key === 'Enter' && sendChatMessage()} placeholder="Type a message..." className="flex-1 bg-white/[0.03] border border-white/[0.08] rounded-xl px-4 py-2.5 text-sm text-white placeholder-gray-600" />
              <button onClick={sendChatMessage} className="px-4 py-2.5 bg-gradient-to-r from-blue-600 to-cyan-500 rounded-xl text-white"><Send size={16} /></button>
            </div>
          </div>
        </div>
      )}

      {/* Payment Modal */}
      {paymentOrderId && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#111827] rounded-2xl border border-white/[0.08] w-full max-w-md max-h-[80vh] overflow-y-auto">
            <div className="flex items-center justify-between p-4 border-b border-white/[0.05]">
              <h3 className="font-bold text-white">💳 Payment</h3>
              <button onClick={() => setPaymentOrderId(null)} className="text-gray-500 hover:text-white"><X size={18} /></button>
            </div>
            <div className="p-4 space-y-4">
              <div className="bg-white/[0.03] rounded-xl p-3">
                <p className="text-sm text-gray-400">Order #{paymentOrderId} • {paymentOrder?.species_name}</p>
                <p className="text-xl font-bold text-white mt-1">TZS {(paymentOrder?.quantity_kg || 0) * (paymentOrder?.max_price_tzs || 0)}</p>
              </div>

              {!payment && isBuyer && (
                <button onClick={generatePayment} className="w-full py-3 bg-gradient-to-r from-blue-600 to-cyan-500 rounded-xl text-white font-semibold">
                  Generate Control Number
                </button>
              )}

              {payment && (
                <>
                  <div className="bg-blue-500/10 border border-blue-500/20 rounded-xl p-4">
                    <p className="text-xs text-gray-400">Control Number</p>
                    <p className="text-lg font-black text-blue-400 tracking-wider">{payment.control_number}</p>
                    <p className="text-xs text-gray-400 mt-2">Amount: <span className="text-white font-bold">TZS {Number(payment.amount_tzs).toLocaleString()}</span></p>
                    <p className="text-xs text-gray-400 mt-1">Status: <span className="font-bold uppercase">{payment.status}</span></p>
                  </div>

                  {payment.receipt_url && (
                    <div>
                      <p className="text-xs text-gray-400 mb-2">Receipt:</p>
                      <img src={payment.receipt_url} alt="Receipt" className="rounded-xl max-w-full max-h-48 object-cover" />
                    </div>
                  )}

                  {isBuyer && payment.status === 'pending' && (
                    <label className="w-full py-3 bg-cyan-600 rounded-xl text-white font-semibold text-center cursor-pointer block">
                      <Upload size={16} className="inline mr-2" /> Upload Receipt
                      <input type="file" accept="image/*" className="hidden" onChange={uploadReceipt} disabled={uploadingReceipt} />
                    </label>
                  )}

                  {!isBuyer && payment.status === 'paid' && (
                    <div className="flex gap-2">
                      <button onClick={approvePayment} className="flex-1 py-3 bg-emerald-600 rounded-xl text-white font-semibold flex items-center justify-center gap-2">
                        <Check size={16} /> Approve
                      </button>
                      <button onClick={rejectPayment} className="flex-1 py-3 bg-red-600 rounded-xl text-white font-semibold">
                        Reject
                      </button>
                    </div>
                  )}

                  {payment.status === 'approved' && (
                    <div className="bg-emerald-500/10 border border-emerald-500/20 rounded-xl p-3 text-center">
                      <p className="text-emerald-400 font-bold">✅ Payment Approved</p>
                    </div>
                  )}
                </>
              )}

              {delivery && (
                <div className="bg-white/[0.03] rounded-xl p-4">
                  <h4 className="font-bold text-white mb-2">🚚 Delivery Details</h4>
                  <p className="text-sm text-gray-400">👤 {delivery.delivery_person_name}</p>
                  <p className="text-sm text-gray-400">📞 {delivery.delivery_person_phone}</p>
                  <p className="text-sm text-gray-400">⏰ {delivery.estimated_time}</p>
                  <p className="text-sm text-gray-400">📍 {delivery.meeting_area}</p>
                </div>
              )}
            </div>
          </div>
        </div>
      )}
    </div>
  )
}