import { useState, useEffect } from 'react'
import axios from 'axios'
import { ShoppingCart, MapPin, Phone, User, Sparkles, DollarSign, Scale, MessageCircle } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

export default function MarketplacePage({ token, user, onOrderPlaced }) {
  const [products, setProducts] = useState([])
  const [loading, setLoading] = useState(true)
  const [selectedProduct, setSelectedProduct] = useState(null)
  const [orderQty, setOrderQty] = useState('')

  useEffect(() => {
    fetchProducts()
  }, [])

  const fetchProducts = async () => {
    try {
      const res = await axios.get(`${API}/products/`)
      setProducts(res.data.results || res.data)
    } catch (e) {}
    setLoading(false)
  }

  const placeOrder = async (product) => {
    if (!orderQty || parseFloat(orderQty) <= 0) {
      alert('Please enter quantity')
      return
    }
    try {
      await axios.post(`${API}/products/${product.id}/order/`,
        { quantity_kg: parseFloat(orderQty), delivery_date: new Date(Date.now() + 86400000).toISOString().split('T')[0] },
        { headers: { Authorization: `Bearer ${token}` } }
      )
      alert('Order placed successfully! 🎉')
      setSelectedProduct(null)
      setOrderQty('')
      fetchProducts()
      if (onOrderPlaced) onOrderPlaced()
    } catch (e) {
      alert('Order failed. Please try again.')
    }
  }

  const speciesIcons = {
    'Tuna': '🐟', 'Parrot': '🐠', 'Snapper': '🐡', 'King': '👑',
    'Octopus': '🐙', 'Squid': '🦑', 'Lobster': '🦞', 'Rabbit': '🐰',
    'Grouper': '🐟', 'Sword': '⚔️', 'Barracuda': '🐊', 'Shark': '🦈',
    'Anchovy': '🐟', 'Mackerel': '🐟', 'Sardine': '🐟', 'Goat': '🐐',
  }

  const getIcon = (name) => {
    for (const [k, v] of Object.entries(speciesIcons)) {
      if (name?.includes(k)) return v
    }
    return '🐟'
  }

  if (loading) {
    return (
      <div className="flex justify-center py-20">
        <div className="animate-spin w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full" />
      </div>
    )
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
      {/* Header */}
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white">🛒 Today's Fish Market</h1>
        <p className="text-gray-400 text-sm mt-1">Fresh catches from fishermen • {products.length} products available</p>
      </div>

      {/* Products Grid */}
      <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-3 gap-4">
        {products.map(product => (
          <div key={product.id} className="bg-[#111827] rounded-2xl border border-white/[0.05] overflow-hidden hover:border-cyan-500/30 hover:shadow-lg hover:shadow-cyan-500/5 transition-all">
            {/* Product Image */}
            <div className="relative h-48 bg-gray-800">
              <img
                src={product.photo_url}
                alt={product.species_name}
                className="w-full h-full object-cover"
                onError={(e) => { e.target.src = 'https://via.placeholder.com/400x300?text=No+Image' }}
              />
              <div className="absolute top-3 left-3 bg-black/60 backdrop-blur-sm rounded-xl px-3 py-1.5">
                <span className="text-white text-sm font-bold">{getIcon(product.species_name)} {product.species_name}</span>
              </div>
              <div className="absolute top-3 right-3 bg-emerald-500/20 backdrop-blur-sm rounded-xl px-3 py-1.5 border border-emerald-500/30">
                <span className="text-emerald-400 text-xs font-bold">{product.status?.toUpperCase()}</span>
              </div>
            </div>

            {/* Product Details */}
            <div className="p-4">
              <div className="flex items-center justify-between mb-3">
                <div>
                  <p className="font-bold text-white text-lg">TZS {Number(product.price_per_kg).toLocaleString()}/kg</p>
                  {product.ai_suggested_price && (
                    <p className="text-xs text-gray-500 flex items-center gap-1">
                      <Sparkles size={10} className="text-cyan-400" />
                      AI suggested: TZS {Number(product.ai_suggested_price).toLocaleString()}/kg
                    </p>
                  )}
                </div>
                <div className="text-right">
                  <p className="text-sm text-white font-bold">{product.quantity_kg} kg</p>
                  <p className="text-xs text-gray-500">Available</p>
                </div>
              </div>

              <div className="space-y-2 mb-3">
                <p className="text-xs text-gray-400 flex items-center gap-2">
                  <User size={12} className="text-gray-500" /> {product.fisherman_name}
                </p>
                <p className="text-xs text-gray-400 flex items-center gap-2">
                  <MapPin size={12} className="text-gray-500" /> {product.market}
                </p>
                {product.fisherman_phone && (
                  <p className="text-xs text-gray-400 flex items-center gap-2">
                    <Phone size={12} className="text-gray-500" /> {product.fisherman_phone}
                  </p>
                )}
              </div>

              {product.description && (
                <p className="text-xs text-gray-500 mb-3">{product.description}</p>
              )}

              <button
                onClick={() => { setSelectedProduct(product); setOrderQty(product.quantity_kg) }}
                className="w-full py-2.5 bg-gradient-to-r from-blue-600 to-cyan-500 rounded-xl text-white font-semibold hover:shadow-lg transition-all flex items-center justify-center gap-2"
              >
                <ShoppingCart size={16} /> Order Now
              </button>
            </div>
          </div>
        ))}
      </div>

      {products.length === 0 && (
        <div className="text-center py-20">
          <p className="text-5xl mb-4">🐟</p>
          <p className="text-gray-500 font-medium">No products available today</p>
          <p className="text-gray-600 text-sm">Check back later or place a custom order</p>
        </div>
      )}

      {/* Order Modal */}
      {selectedProduct && (
        <div className="fixed inset-0 bg-black/60 backdrop-blur-sm z-50 flex items-center justify-center p-4">
          <div className="bg-[#111827] rounded-2xl border border-white/[0.08] w-full max-w-md p-6">
            <div className="flex items-center justify-between mb-4">
              <h3 className="font-bold text-white text-lg">Place Order</h3>
              <button onClick={() => setSelectedProduct(null)} className="text-gray-500 hover:text-white text-xl">✕</button>
            </div>

            <div className="flex items-center gap-3 mb-4">
              <img src={selectedProduct.photo_url} alt="" className="w-16 h-16 rounded-xl object-cover" />
              <div>
                <p className="font-bold text-white">{selectedProduct.species_name}</p>
                <p className="text-sm text-cyan-400 font-bold">TZS {Number(selectedProduct.price_per_kg).toLocaleString()}/kg</p>
              </div>
            </div>

            <div className="space-y-4">
              <div>
                <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Quantity (kg)</label>
                <input
                  type="number"
                  value={orderQty}
                  onChange={e => setOrderQty(e.target.value)}
                  max={selectedProduct.quantity_kg}
                  className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-cyan-400/50"
                />
                <p className="text-xs text-gray-600 mt-1">Max: {selectedProduct.quantity_kg} kg available</p>
              </div>

              <div>
                <label className="text-xs font-semibold text-gray-500 uppercase tracking-wider mb-2 block">Delivery Date</label>
                <input
                  type="date"
                  value={new Date(Date.now() + 86400000).toISOString().split('T')[0]}
                  className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-3 text-white focus:outline-none focus:border-cyan-400/50"
                />
              </div>

              <div className="bg-blue-500/10 border border-blue-500/20 rounded-xl p-3">
                <p className="text-xs text-gray-400">
                  Total: <span className="text-white font-bold">TZS {(Number(selectedProduct.price_per_kg) * (parseFloat(orderQty) || 0)).toLocaleString()}</span>
                </p>
              </div>

              <button
                onClick={() => placeOrder(selectedProduct)}
                className="w-full py-3 bg-gradient-to-r from-blue-600 to-cyan-500 rounded-xl text-white font-semibold hover:shadow-lg transition-all"
              >
                Confirm Order
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  )
}