import { useState, useEffect } from 'react';
import { Link } from 'react-router-dom';
import { useAuth } from './AuthContext';
import { LogOut, ArrowUpRight, ArrowDownRight, Users, CreditCard, PlusCircle } from 'lucide-react';
import { db } from './Database';
import type { Loan, Payment, Customer } from './Database';

export default function Dashboard() {
  const { user, signOut } = useAuth();

  const [loading, setLoading] = useState(true);
  const [loans, setLoans] = useState<Loan[]>([]);
  const [payments, setPayments] = useState<Payment[]>([]);
  const [customers, setCustomers] = useState<Customer[]>([]);

  useEffect(() => {
    Promise.all([
      db.getLoans(),
      db.getPayments(),
      db.getCustomers()
    ]).then(([l, p, c]) => {
      setLoans(l);
      setPayments(p);
      setCustomers(c);
      setLoading(false);
    });
  }, []);

  if (loading) {
    return <div style={{ height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>Loading dashboard...</div>;
  }

  const totalLent = loans.reduce((sum, l) => sum + l.amount, 0);
  const totalInterest = loans.reduce((sum, l) => sum + (l.interestAmount || 0), 0);
  const totalPaid = payments.reduce((sum, p) => sum + p.amount, 0);
  const totalOutstanding = Math.max(0, totalLent + totalInterest - totalPaid);
  
  const today = new Date().toISOString().split('T')[0];
  const collectedToday = payments
    .filter(p => p.date.startsWith(today))
    .reduce((sum, p) => sum + p.amount, 0);

  const activeLoans = loans.filter(l => l.status === 'active');
  
  const overdueLoans = activeLoans.filter(l => {
    if (!l.dueDate) return false;
    const due = new Date(l.dueDate);
    const now = new Date();
    due.setHours(0, 0, 0, 0);
    now.setHours(0, 0, 0, 0);
    return due < now;
  });

  const todayLoans = loans.filter(l => l.date.startsWith(today));

  const upcomingLoans = activeLoans.filter(l => {
    if (!l.dueDate) return false;
    const due = new Date(l.dueDate);
    const now = new Date();
    due.setHours(0, 0, 0, 0);
    now.setHours(0, 0, 0, 0);
    return due >= now;
  });

  const getCustomerName = (id: string) => customers.find(c => c.id === id)?.name || 'Unknown';
  const getPaid = (loanId: string) => payments.filter(p => p.loanId === loanId).reduce((s, p) => s + p.amount, 0);

  return (
    <div style={{ padding: '1.5rem', paddingBottom: '100px' }}>
      
      {/* App Bar */}
      <div className="flex-between animate-fade-in stagger-1" style={{ marginBottom: '2rem' }}>
        <div>
          <h1 style={{ fontSize: '1.5rem', marginBottom: '-4px' }}>Loan Ledger</h1>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>Welcome back, {user?.email.split('@')[0]}</p>
        </div>
        <button onClick={signOut} className="btn-icon" style={{ background: 'var(--danger-light)', color: 'var(--danger)', border: 'none' }}>
          <LogOut size={20} />
        </button>
      </div>

      {/* Main KPI Card */}
      <div className="card animate-fade-in stagger-2" style={{ background: 'linear-gradient(135deg, var(--primary), var(--primary-dark))', color: 'white', border: 'none', marginBottom: '1rem' }}>
        <p style={{ color: 'rgba(255,255,255,0.7)', fontSize: '0.875rem', fontWeight: 500, marginBottom: '0.5rem' }}>Total Outstanding</p>
        <h2 style={{ fontSize: '2.5rem', marginBottom: '0', color: 'white' }}>₹{totalOutstanding.toFixed(2)}</h2>
      </div>

      {/* Secondary KPIs */}
      <div className="animate-fade-in stagger-2" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '1.5rem' }}>
        <div className="card" style={{ padding: '1rem', background: 'var(--surface)' }}>
          <p style={{ color: 'var(--text-muted)', fontSize: '0.75rem', marginBottom: '4px', fontWeight: 500 }}>Total Lent</p>
          <p style={{ fontWeight: 600, color: 'var(--text-main)', fontSize: '1.125rem' }}>₹{totalLent.toFixed(2)}</p>
        </div>
        <div className="card" style={{ padding: '1rem', background: 'var(--success-light)', border: '1px solid var(--success)' }}>
          <p style={{ color: 'var(--success)', fontSize: '0.75rem', marginBottom: '4px', fontWeight: 600 }}>Collected Today</p>
          <p style={{ fontWeight: 700, color: 'var(--success)', fontSize: '1.125rem' }}>₹{collectedToday.toFixed(2)}</p>
        </div>
      </div>

      <h3 className="animate-fade-in stagger-3" style={{ marginBottom: '1rem', fontSize: '1.125rem' }}>Quick Actions</h3>
      
      {/* Quick Actions Grid */}
      <div className="animate-fade-in stagger-3" style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', marginBottom: '2rem' }}>
        <Link to="/give-loan" className="card" style={{ textDecoration: 'none', display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: '0.5rem', border: 'none', background: 'var(--primary-light)', color: 'white' }}>
          <div style={{ background: 'rgba(255,255,255,0.2)', padding: '8px', borderRadius: '50%' }}>
            <ArrowUpRight size={24} />
          </div>
          <span style={{ fontWeight: 600 }}>Give Loan</span>
        </Link>

        <Link to="/receive-payment" className="card" style={{ textDecoration: 'none', display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: '0.5rem', border: 'none', background: 'var(--success)', color: 'white' }}>
          <div style={{ background: 'rgba(255,255,255,0.2)', padding: '8px', borderRadius: '50%' }}>
            <ArrowDownRight size={24} />
          </div>
          <span style={{ fontWeight: 600 }}>Receive Payment</span>
        </Link>
        
        <Link to="/add-customer" className="card" style={{ textDecoration: 'none', gridColumn: '1 / -1', display: 'flex', flexDirection: 'row', alignItems: 'center', justifyContent: 'center', gap: '0.5rem', border: '2px dashed var(--border)', background: 'var(--background)' }}>
          <PlusCircle size={20} color="var(--text-muted)" />
          <span style={{ fontWeight: 600, color: 'var(--text-muted)' }}>Add New Customer</span>
        </Link>
      </div>

      <h3 className="animate-fade-in stagger-4" style={{ marginBottom: '1rem', fontSize: '1.125rem' }}>Overview</h3>
      
      {/* Stats list */}
      <div className="animate-fade-in stagger-4" style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
        
        <Link to="/customers" className="card flex-between" style={{ padding: '1rem', textDecoration: 'none' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <div style={{ background: 'var(--background)', padding: '10px', borderRadius: '12px' }}>
              <Users size={20} color="var(--primary)" />
            </div>
            <div>
              <p style={{ fontWeight: 600, color: 'var(--text-main)' }}>Active Customers</p>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{customers.length} people</p>
            </div>
          </div>
          <span style={{ fontWeight: 600, color: 'var(--text-main)' }}>{customers.length}</span>
        </Link>

        <div className="card flex-between" style={{ padding: '1rem' }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
            <div style={{ background: 'var(--primary-light)', padding: '10px', borderRadius: '12px', color: 'white' }}>
              <CreditCard size={20} />
            </div>
            <div>
              <p style={{ fontWeight: 600, color: 'var(--text-main)' }}>Active Loans</p>
              <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Outstanding</p>
            </div>
          </div>
          <span className="chip chip-warning">{activeLoans.length} Active</span>
        </div>

        {overdueLoans.length > 0 && (
          <div className="card" style={{ padding: '1rem', borderLeft: '4px solid var(--danger)' }}>
            <div className="flex-between">
              <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                <div style={{ background: 'var(--danger-light)', padding: '10px', borderRadius: '12px', color: 'var(--danger)' }}>
                  <CreditCard size={20} />
                </div>
                <div>
                  <p style={{ fontWeight: 600, color: 'var(--text-main)' }}>Overdue Loans</p>
                  <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>Immediate action required</p>
                </div>
              </div>
              <span className="chip chip-danger">{overdueLoans.length} Overdue</span>
            </div>
          </div>
        )}

      </div>

      <h3 className="animate-fade-in stagger-4" style={{ marginBottom: '1rem', marginTop: '2.5rem', fontSize: '1.125rem' }}>Loans Given Today</h3>
      <div className="animate-fade-in stagger-4" style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
        {todayLoans.length === 0 ? (
          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>No loans issued today.</p>
        ) : (
          todayLoans.map(loan => {
            const totalDue = loan.amount + (loan.interestAmount || 0);
            const paid = getPaid(loan.id);
            const pending = Math.max(0, totalDue - paid);
            return (
              <div key={loan.id} className="card" style={{ padding: '1rem' }}>
                <div className="flex-between" style={{ marginBottom: '0.5rem' }}>
                  <span style={{ fontWeight: 600, color: 'var(--text-main)' }}>{getCustomerName(loan.customerId)}</span>
                  <span className="chip chip-success">Today</span>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem', fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                  <div>Amount: <span style={{ color: 'var(--text-main)', fontWeight: 500 }}>₹{loan.amount}</span></div>
                  <div>Interest: <span style={{ color: 'var(--text-main)', fontWeight: 500 }}>₹{loan.interestAmount || 0}</span></div>
                  <div>Paid: <span style={{ color: 'var(--success)', fontWeight: 500 }}>₹{paid}</span></div>
                  <div>Pending: <span style={{ color: 'var(--danger)', fontWeight: 600 }}>₹{pending}</span></div>
                </div>
              </div>
            );
          })
        )}
      </div>

      <h3 className="animate-fade-in stagger-4" style={{ marginBottom: '1rem', marginTop: '2.5rem', fontSize: '1.125rem' }}>Upcoming Dues</h3>
      <div className="animate-fade-in stagger-4" style={{ display: 'flex', flexDirection: 'column', gap: '0.75rem' }}>
        {upcomingLoans.length === 0 ? (
          <p style={{ color: 'var(--text-muted)', fontSize: '0.875rem' }}>No upcoming dues.</p>
        ) : (
          upcomingLoans.map(loan => {
            const totalDue = loan.amount + (loan.interestAmount || 0);
            const paid = getPaid(loan.id);
            const pending = Math.max(0, totalDue - paid);
            return (
              <div key={loan.id} className="card" style={{ padding: '1rem' }}>
                <div className="flex-between" style={{ marginBottom: '0.5rem' }}>
                  <span style={{ fontWeight: 600, color: 'var(--text-main)' }}>{getCustomerName(loan.customerId)}</span>
                  <span className="chip chip-warning">Due: {loan.dueDate}</span>
                </div>
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '0.5rem', fontSize: '0.75rem', color: 'var(--text-muted)' }}>
                  <div>Amount: <span style={{ color: 'var(--text-main)', fontWeight: 500 }}>₹{loan.amount}</span></div>
                  <div>Interest: <span style={{ color: 'var(--text-main)', fontWeight: 500 }}>₹{loan.interestAmount || 0}</span></div>
                  <div>Paid: <span style={{ color: 'var(--success)', fontWeight: 500 }}>₹{paid}</span></div>
                  <div>Pending: <span style={{ color: 'var(--danger)', fontWeight: 600 }}>₹{pending}</span></div>
                </div>
              </div>
            );
          })
        )}
      </div>

    </div>
  );
}
