import { Fish, LogOut } from 'lucide-react'

export default function Navbar({ user, activeTab, setActiveTab, onLogout }) {
  const isAdmin = user?.role === 'admin'

  const tabs = isAdmin
    ? [
        { id: 'dashboard', label: 'Overview' },
        { id: 'users', label: 'Users' },
        { id: 'orders', label: 'All Orders' },
        { id: 'species', label: 'Species' },
        { id: 'audit', label: 'Audit Log' },
      ]
    : [
        { id: 'dashboard', label: 'Dashboard' },
        { id: 'marketplace', label: 'Marketplace' },
        { id: 'orders', label: 'Orders' },
        { id: 'forecast', label: 'Forecast' },
        { id: 'profile', label: 'Profile' },
      ]

  return (
    <nav className="sticky top-0 z-50 bg-[#0d1321]/80 backdrop-blur-2xl border-b border-white/[0.05]">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 py-3 flex items-center justify-between gap-2">
        <div className="flex items-center gap-3 shrink-0">
          <div className="w-10 h-10 rounded-xl bg-gradient-to-br from-blue-600 to-cyan-500 flex items-center justify-center shadow-lg shadow-blue-500/20">
            <Fish size={22} className="text-white" />
          </div>
          <div className="hidden sm:block">
            <h1 className="text-lg font-bold text-white">Samaki <span className="text-cyan-400">Smart AI</span></h1>
            <p className="text-[10px] text-gray-500 font-medium tracking-wider uppercase">
              {isAdmin ? 'Admin Console' : 'Hotel Buyer Portal'}
            </p>
          </div>
        </div>
        <div className="flex items-center gap-1 bg-white/[0.03] p-1 rounded-2xl border border-white/[0.05] overflow-x-auto">
          {tabs.map(tab => (
            <button key={tab.id} onClick={() => setActiveTab(tab.id)}
              className={`px-3 sm:px-4 py-2 rounded-xl text-xs sm:text-sm font-medium transition-all duration-300 whitespace-nowrap ${
                activeTab === tab.id
                  ? 'bg-blue-600 text-white shadow-lg shadow-blue-500/20'
                  : 'text-gray-400 hover:text-white hover:bg-white/[0.05]'
              }`}>
              {tab.label}
            </button>
          ))}
          <span className="hidden md:inline text-gray-600 text-xs px-3 py-1 bg-white/[0.02] rounded-lg border border-white/[0.05] whitespace-nowrap">
            {user?.username} <span className="text-gray-500">({user?.role})</span>
          </span>
          <button onClick={onLogout} className="flex items-center gap-2 px-3 sm:px-4 py-2 rounded-xl text-sm font-medium text-red-400 hover:text-red-300 hover:bg-red-500/10 transition-all duration-300 whitespace-nowrap">
            <LogOut size={16} />
          </button>
        </div>
      </div>
    </nav>
  )
}