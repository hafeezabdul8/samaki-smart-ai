import { useState, useEffect } from 'react'
import axios from 'axios'
import LoginPage from './pages/LoginPage'
import DashboardPage from './pages/DashboardPage'
import OrdersPage from './pages/OrdersPage'
import ForecastPage from './pages/ForecastPage'
import AdminPage from './pages/AdminPage'
import ProfilePage from './pages/ProfilePage'
import AdminDashboardPage from './pages/admin/AdminDashboardPage'
import AdminUsersPage from './pages/admin/AdminUsersPage'
import AdminUserDetailPage from './pages/admin/AdminUserDetailPage'
import AdminAuditLogPage from './pages/admin/AdminAuditLogPage'
import Navbar from './components/Navbar'
import './index.css'

const API = 'http://10.139.233.239:8000/api/auth'

export default function App() {
  const [token, setToken] = useState(localStorage.getItem('token') || '')
  const [user, setUser] = useState(null)
  const [prices, setPrices] = useState([])
  const [alerts, setAlerts] = useState([])
  const [orders, setOrders] = useState([])
  const [adminOrders, setAdminOrders] = useState([])
  const [forecast, setForecast] = useState([])
  const [activeTab, setActiveTab] = useState('dashboard')
  const [viewingUserId, setViewingUserId] = useState(null)

  const fetchProfile = async (tok) => {
    try {
      const res = await axios.get(`${API}/profile/`, { headers: { Authorization: `Bearer ${tok}` } })
      setUser(res.data)
    } catch (e) { logout() }
  }

  const handleLogin = (tok) => {
    setToken(tok)
    fetchProfile(tok)
  }

  const handleProfileUpdate = (updatedUser) => setUser(updatedUser)

  const logout = () => { setToken(''); setUser(null); localStorage.removeItem('token') }

  const handleTabChange = (tab) => {
    setActiveTab(tab)
    setViewingUserId(null)
    if (tab === 'orders' && user?.role === 'admin') fetchAdminOrders()
  }

  useEffect(() => {
    if (token && user) {
      fetchPrices()
      fetchAlerts()
      if (user.role === 'admin') fetchAdminOrders()
      else fetchOrders()
    }
  }, [token, user])

  const fetchPrices = async () => { try { const r = await axios.get(`${API}/prices/`); setPrices(r.data.results.slice(0, 8)) } catch (e) {} }
  const fetchAlerts = async () => { try { const r = await axios.get(`${API}/alerts/`); setAlerts(r.data.results) } catch (e) {} }
  const fetchOrders = async () => {
    try { const r = await axios.get(`${API}/orders/`, { headers: { Authorization: `Bearer ${token}` } }); setOrders(r.data.results) } catch (e) {}
  }
  const fetchAdminOrders = async () => {
    try { const r = await axios.get(`${API}/admin/orders/`, { headers: { Authorization: `Bearer ${token}` } }); setAdminOrders(r.data.results) } catch (e) {}
  }

  const getForecast = async (species, market) => {
    try { const r = await axios.post(`${API}/forecast/`, { species, market, avg_quantity: 15 }); setForecast(r.data); setActiveTab('forecast') } catch (e) {}
  }

  if (!token || !user) return <LoginPage onLogin={handleLogin} />

  const isAdmin = user.role === 'admin'

  // Admin user detail view
  if (isAdmin && viewingUserId) {
    return (
      <div className="min-h-screen bg-[#0a0f1e]">
        <Navbar user={user} activeTab="users" setActiveTab={handleTabChange} onLogout={logout} />
        <AdminUserDetailPage token={token} userId={viewingUserId} onBack={() => setViewingUserId(null)} />
      </div>
    )
  }

  return (
    <div className="min-h-screen bg-[#0a0f1e]">
      <Navbar user={user} activeTab={activeTab} setActiveTab={handleTabChange} onLogout={logout} />
      {activeTab === 'dashboard' && !isAdmin && <DashboardPage user={user} prices={prices} alerts={alerts} orders={orders} adminOrders={adminOrders} />}
      {activeTab === 'dashboard' && isAdmin && <AdminDashboardPage token={token} />}
      {activeTab === 'users' && isAdmin && <AdminUsersPage token={token} onViewUser={(id) => setViewingUserId(id)} />}
      {activeTab === 'orders' && !isAdmin && <OrdersPage token={token} alerts={alerts} orders={orders} onOrderCreated={fetchOrders} onForecast={getForecast} />}
      {activeTab === 'orders' && isAdmin && <AdminPage tab="orders" adminOrders={adminOrders} alerts={alerts} />}
      {activeTab === 'species' && isAdmin && <AdminPage tab="species" adminOrders={adminOrders} alerts={alerts} />}
      {activeTab === 'audit' && isAdmin && <AdminAuditLogPage token={token} />}
      {activeTab === 'forecast' && !isAdmin && <ForecastPage forecast={forecast} />}
      {activeTab === 'profile' && !isAdmin && <ProfilePage token={token} user={user} onProfileUpdate={handleProfileUpdate} />}
    </div>
  )
}