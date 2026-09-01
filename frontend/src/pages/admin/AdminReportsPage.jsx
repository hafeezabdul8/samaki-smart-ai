import { useState, useEffect } from 'react'
import axios from 'axios'
import { FileText, Download, Printer, Filter, Calendar, TrendingUp, DollarSign, CheckCircle, Clock, XCircle, FileSpreadsheet } from 'lucide-react'

const API = 'https://samaki-smart-ai.onrender.com/api/auth'

export default function AdminReportsPage({ token }) {
  const [report, setReport] = useState(null)
  const [loading, setLoading] = useState(false)
  const [statusFilter, setStatusFilter] = useState('all')
  const [periodFilter, setPeriodFilter] = useState('7days')
  const [reportType, setReportType] = useState('orders')

  const fetchReport = async () => {
    setLoading(true)
    try {
      const res = await axios.get(`${API}/admin/reports/`, {
        headers: { Authorization: `Bearer ${token}` },
        params: { type: reportType, status: statusFilter, period: periodFilter }
      })
      setReport(res.data)
    } catch (e) {
      alert('Failed to generate report')
    }
    setLoading(false)
  }

  useEffect(() => {
    fetchReport()
  }, [statusFilter, periodFilter, reportType])

  const exportCSV = () => {
    if (!report) return
    const rows = [
      ['Order #', 'Date', 'Time', 'Buyer', 'Buyer Phone', 'Seller', 'Seller Phone', 'Species', 'Qty (kg)', 'Price/kg', 'Total', 'Status'],
      ...report.orders.map(o => [o.id, o.date, o.time, o.buyer_name, o.buyer_phone, o.seller_name, o.seller_phone, o.species, o.quantity_kg, o.price_tzs, o.total_value, o.status])
    ]
    const csv = rows.map(r => r.join(',')).join('\n')
    const blob = new Blob([csv], { type: 'text/csv' })
    const url = URL.createObjectURL(blob)
    const a = document.createElement('a')
    a.href = url
    a.download = `samaki-report-${Date.now()}.csv`
    a.click()
  }

  const printReport = () => {
    window.print()
  }

  return (
    <div className="max-w-7xl mx-auto px-4 sm:px-6 py-6">
      <div className="mb-6">
        <h1 className="text-2xl font-bold text-white">📊 Reports</h1>
        <p className="text-gray-400 text-sm mt-1">Generate, export, and print official reports</p>
      </div>

      {/* Filters */}
      <div className="bg-[#111827] rounded-2xl border border-white/[0.05] p-5 mb-6">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-4">
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase mb-2 block">Report Type</label>
            <select value={reportType} onChange={e => setReportType(e.target.value)}
              className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-2.5 text-sm text-white">
              <option value="orders">Orders Report</option>
              <option value="transactions">Transaction Report</option>
              <option value="logs">System Logs</option>
            </select>
          </div>
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase mb-2 block">Status</label>
            <select value={statusFilter} onChange={e => setStatusFilter(e.target.value)}
              className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-2.5 text-sm text-white">
              <option value="all">All Statuses</option>
              <option value="pending">Pending</option>
              <option value="accepted">Accepted</option>
              <option value="fulfilled">Fulfilled</option>
              <option value="cancelled">Cancelled</option>
            </select>
          </div>
          <div>
            <label className="text-xs font-semibold text-gray-500 uppercase mb-2 block">Period</label>
            <select value={periodFilter} onChange={e => setPeriodFilter(e.target.value)}
              className="w-full bg-[#0d1321] border border-white/[0.08] rounded-xl px-4 py-2.5 text-sm text-white">
              <option value="2hours">Last 2 Hours</option>
              <option value="today">Last 24 Hours</option>
              <option value="2days">Last 2 Days</option>
              <option value="7days">Last 7 Days</option>
              <option value="30days">Last 30 Days</option>
              <option value="monthly">This Month</option>
              <option value="yearly">This Year</option>
              <option value="all">All Time</option>
            </select>
          </div>
          <div className="flex items-end gap-2">
            <button onClick={exportCSV} className="flex-1 px-4 py-2.5 bg-emerald-600 hover:bg-emerald-700 rounded-xl text-white text-sm font-semibold transition-all flex items-center justify-center gap-2">
              <FileSpreadsheet size={16} /> Export
            </button>
            <button onClick={printReport} className="flex-1 px-4 py-2.5 bg-blue-600 hover:bg-blue-700 rounded-xl text-white text-sm font-semibold transition-all flex items-center justify-center gap-2">
              <Printer size={16} /> Print
            </button>
          </div>
        </div>
      </div>

      {/* Report Preview */}
      {loading ? (
        <div className="flex justify-center py-20">
          <div className="animate-spin w-8 h-8 border-2 border-cyan-400 border-t-transparent rounded-full" />
        </div>
      ) : report ? (
        <div className="bg-white rounded-2xl shadow-xl overflow-hidden" id="report-section">
          {/* Report Header */}
          <div className="bg-gradient-to-r from-blue-700 to-cyan-600 p-6 text-white">
            <div className="flex items-center justify-between">
              <div>
                <h2 className="text-xl font-bold">SAMAKI SMART AI — OFFICIAL REPORT</h2>
                <p className="text-sm opacity-80">{report.report_type?.toUpperCase()} REPORT</p>
              </div>
              <div className="text-right text-sm">
                <p>Generated: {report.generated_at}</p>
                <p>By: {report.generated_by}</p>
              </div>
            </div>
          </div>

          {/* Summary */}
          <div className="p-6 border-b border-gray-200">
            <h3 className="font-bold text-gray-800 mb-3">SUMMARY</h3>
            <div className="grid grid-cols-2 md:grid-cols-6 gap-3">
              {[
                { label: 'Total Orders', value: report.summary.total_orders, color: 'text-blue-600' },
                { label: 'Pending', value: report.summary.pending, color: 'text-amber-600' },
                { label: 'Accepted', value: report.summary.accepted, color: 'text-blue-600' },
                { label: 'Fulfilled', value: report.summary.fulfilled, color: 'text-emerald-600' },
                { label: 'Cancelled', value: report.summary.cancelled, color: 'text-red-600' },
                { label: 'Total Value', value: `TZS ${report.summary.total_value_tzs.toLocaleString()}`, color: 'text-cyan-600' },
              ].map((stat, i) => (
                <div key={i} className="bg-gray-50 rounded-xl p-3 text-center">
                  <p className={`text-lg font-bold ${stat.color}`}>{stat.value}</p>
                  <p className="text-xs text-gray-500">{stat.label}</p>
                </div>
              ))}
            </div>
          </div>

          {/* Orders Table */}
          <div className="p-6">
            <h3 className="font-bold text-gray-800 mb-3">ORDER DETAILS</h3>
            <div className="overflow-x-auto">
              <table className="w-full text-sm">
                <thead className="bg-gray-100">
                  <tr>
                    <th className="py-2 px-3 text-left">Order #</th>
                    <th className="py-2 px-3 text-left">Date</th>
                    <th className="py-2 px-3 text-left">Buyer</th>
                    <th className="py-2 px-3 text-left">Seller</th>
                    <th className="py-2 px-3 text-left">Species</th>
                    <th className="py-2 px-3 text-right">Qty</th>
                    <th className="py-2 px-3 text-right">Price/kg</th>
                    <th className="py-2 px-3 text-right">Total</th>
                    <th className="py-2 px-3 text-center">Status</th>
                  </tr>
                </thead>
                <tbody>
                  {report.orders.map(o => (
                    <tr key={o.id} className="border-b border-gray-100 hover:bg-gray-50">
                      <td className="py-2 px-3 font-semibold">#{o.id}</td>
                      <td className="py-2 px-3">{o.date} {o.time}</td>
                      <td className="py-2 px-3">
                        <p className="font-medium">{o.buyer_name}</p>
                        <p className="text-xs text-gray-500">{o.buyer_phone}</p>
                      </td>
                      <td className="py-2 px-3">
                        <p className="font-medium">{o.seller_name}</p>
                        <p className="text-xs text-gray-500">{o.seller_phone}</p>
                      </td>
                      <td className="py-2 px-3">{o.species}</td>
                      <td className="py-2 px-3 text-right">{o.quantity_kg}</td>
                      <td className="py-2 px-3 text-right">{o.price_tzs.toLocaleString()}</td>
                      <td className="py-2 px-3 text-right font-semibold">{o.total_value.toLocaleString()}</td>
                      <td className="py-2 px-3 text-center">
                        <span className={`text-xs font-bold px-2 py-1 rounded-full ${
                          o.status === 'fulfilled' ? 'bg-emerald-100 text-emerald-700' :
                          o.status === 'accepted' ? 'bg-blue-100 text-blue-700' :
                          o.status === 'pending' ? 'bg-amber-100 text-amber-700' : 'bg-red-100 text-red-700'
                        }`}>
                          {o.status}
                        </span>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
              {report.orders.length === 0 && (
                <p className="text-center text-gray-500 py-8">No orders found for this filter</p>
              )}
            </div>
          </div>

          {/* Footer */}
          <div className="p-4 bg-gray-50 border-t border-gray-200 text-center text-xs text-gray-500">
            <p>© 2026 Samaki Smart AI • State University of Zanzibar • Official Report</p>
          </div>
        </div>
      ) : null}
    </div>
  )
}