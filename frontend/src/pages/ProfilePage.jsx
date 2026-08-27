import { useState, useEffect } from 'react'
import axios from 'axios'
import { User, Phone, MapPin, Store, Hotel, Save, CheckCircle } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

export default function ProfilePage({ token, user, onProfileUpdate }) {
  const [phone, setPhone] = useState('')
  const [location, setLocation] = useState('')
  const [market, setMarket] = useState('')
  const [hotelName, setHotelName] = useState('')
  const [saving, setSaving] = useState(false)
  const [success, setSuccess] = useState(false)

  const isFisherman = user?.role === 'fisherman'

  useEffect(() => {
    if (user) {
      setPhone(user.phone || '')
      setLocation(user.location || '')
      setMarket(user.market || '')
      setHotelName(user.hotel_name || '')
    }
  }, [user])

  const handleSave = async (e) => {
    e.preventDefault()
    setSaving(true)
    setSuccess(false)
    try {
      const body = { phone, location }
      if (isFisherman) body.market = market
      else body.hotel_name = hotelName

      const res = await axios.patch(`${API}/profile/update/`, body, {
        headers: { Authorization: `Bearer ${token}` }
      })
      onProfileUpdate(res.data)
      setSuccess(true)
      setTimeout(() => setSuccess(false), 3000)
    } catch (e) {
      alert('Failed to save profile')
    }
    setSaving(false)
  }

  return (
    <div className="max-w-2xl mx-auto px-6 py-8">
      {/* Profile Card */}
      <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-8 mb-6">
        <div className="flex items-center gap-4 mb-6">
          <div className="w-16 h-16 rounded-2xl bg-gradient-to-br from-blue-600 to-cyan-500 flex items-center justify-center shadow-lg shadow-blue-500/20">
            <span className="text-2xl font-black text-white">
              {(user?.username || '?')[0].toUpperCase()}
            </span>
          </div>
          <div>
            <h2 className="text-xl font-bold text-white">{user?.username}</h2>
            <p className="text-gray-400 text-sm">
              {isFisherman ? '🎣 Fisherman' : '🏨 Hotel Buyer'}
            </p>
          </div>
        </div>

        <form onSubmit={handleSave} className="space-y-5">
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider flex items-center gap-1.5 mb-2">
              <Phone size={12} /> Phone Number
            </label>
            <input
              type="text"
              value={phone}
              onChange={e => setPhone(e.target.value)}
              className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:ring-2 focus:ring-cyan-400/20 focus:border-cyan-400/50 transition-all"
              placeholder="e.g. 0771234567"
            />
          </div>

          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider flex items-center gap-1.5 mb-2">
              <MapPin size={12} /> Location / Area
            </label>
            <input
              type="text"
              value={location}
              onChange={e => setLocation(e.target.value)}
              className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:ring-2 focus:ring-cyan-400/20 focus:border-cyan-400/50 transition-all"
              placeholder="e.g. Stone Town, Zanzibar"
            />
          </div>

          {isFisherman ? (
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider flex items-center gap-1.5 mb-2">
                <Store size={12} /> Market
              </label>
              <input
                type="text"
                value={market}
                onChange={e => setMarket(e.target.value)}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:ring-2 focus:ring-cyan-400/20 focus:border-cyan-400/50 transition-all"
                placeholder="e.g. Malindi Market"
              />
            </div>
          ) : (
            <div>
              <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider flex items-center gap-1.5 mb-2">
                <Hotel size={12} /> Hotel Name
              </label>
              <input
                type="text"
                value={hotelName}
                onChange={e => setHotelName(e.target.value)}
                className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-white placeholder-gray-600 focus:outline-none focus:ring-2 focus:ring-cyan-400/20 focus:border-cyan-400/50 transition-all"
                placeholder="e.g. Zanzibar Beach Resort"
              />
            </div>
          )}

          {success && (
            <div className="bg-emerald-500/10 border border-emerald-500/20 rounded-xl p-3 flex items-center gap-2">
              <CheckCircle size={16} className="text-emerald-400" />
              <span className="text-emerald-400 text-sm">Profile updated successfully!</span>
            </div>
          )}

          <button
            type="submit"
            disabled={saving}
            className="w-full bg-gradient-to-r from-blue-600 to-cyan-500 text-white py-3.5 rounded-xl font-semibold shadow-lg shadow-blue-500/20 hover:shadow-blue-500/40 hover:scale-[1.01] active:scale-[0.99] transition-all duration-300 flex items-center justify-center gap-2 disabled:opacity-50"
          >
            <Save size={18} />
            {saving ? 'Saving...' : 'Save Profile'}
          </button>
        </form>
      </div>
    </div>
  )
}
