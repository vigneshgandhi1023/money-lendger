import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { db } from './Database';
import type { Customer, Loan, Payment } from './Database';
import { User, ChevronRight } from 'lucide-react';

export default function CustomersList() {
  const navigate = useNavigate();
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [loans, setLoans] = useState<Loan[]>([]);
  const [payments, setPayments] = useState<Payment[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    Promise.all([db.getCustomers(), db.getLoans(), db.getPayments()]).then(([c, l, p]) => {
      setCustomers(c);
      setLoans(l);
      setPayments(p);
      setLoading(false);
    });
  }, []);

  const getCustomerStats = (customerId: string) => {
    const customerLoans = loans.filter(l => l.customerId === customerId);
    const customerPayments = payments.filter(p => customerLoans.some(l => l.id === p.loanId));
    
    const totalBorrowed = customerLoans.reduce((sum, l) => sum + l.amount, 0);
    const totalInterest = customerLoans.reduce((sum, l) => sum + (l.interestAmount || 0), 0);
    const totalPaid = customerPayments.reduce((sum, p) => sum + p.amount, 0);
    const outstanding = Math.max(0, totalBorrowed + totalInterest - totalPaid);
    
    const activeLoans = customerLoans.filter(l => l.status === 'active').length;

    return { totalBorrowed, outstanding, activeLoans };
  };

  return (
    <div style={{ padding: '1.5rem', paddingBottom: '100px' }}>
      <div className="flex-between" style={{ marginBottom: '2rem' }}>
        <button onClick={() => navigate(-1)} className="btn-secondary" style={{ padding: '0.5rem 1rem', borderRadius: '8px' }}>Back</button>
        <h1 style={{ fontSize: '1.25rem' }}>Customers</h1>
        <button onClick={() => navigate('/add-customer')} className="btn-secondary" style={{ padding: '0.5rem', borderRadius: '8px', color: 'var(--primary)' }}>
          + Add
        </button>
      </div>

      {loading ? (
        <div style={{ textAlign: 'center', marginTop: '2rem' }}>Loading customers...</div>
      ) : customers.length === 0 ? (
        <div style={{ textAlign: 'center', marginTop: '2rem', color: 'var(--text-muted)' }}>
          No customers found. Add your first customer!
        </div>
      ) : (
        <div className="animate-fade-in stagger-1" style={{ display: 'flex', flexDirection: 'column', gap: '1rem' }}>
          {customers.map(customer => {
            const stats = getCustomerStats(customer.id);
            return (
              <div key={customer.id} className="card" style={{ padding: '1rem', cursor: 'pointer' }} onClick={() => alert('Customer detail coming soon!')}>
                <div className="flex-between">
                  <div style={{ display: 'flex', alignItems: 'center', gap: '1rem' }}>
                    <div style={{ background: 'var(--primary-light)', padding: '12px', borderRadius: '50%', color: 'white' }}>
                      <User size={24} />
                    </div>
                    <div>
                      <h3 style={{ fontSize: '1rem', fontWeight: 600, color: 'var(--text-main)', marginBottom: '2px' }}>{customer.name}</h3>
                      <p style={{ fontSize: '0.75rem', color: 'var(--text-muted)' }}>{customer.phone}</p>
                    </div>
                  </div>
                  <ChevronRight size={20} color="var(--text-muted)" />
                </div>
                
                <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '1rem', borderTop: '1px solid var(--border)', paddingTop: '0.75rem', marginTop: '0.75rem' }}>
                  <div>
                    <p style={{ color: 'var(--text-muted)', fontSize: '0.75rem', marginBottom: '2px' }}>Outstanding</p>
                    <p style={{ fontWeight: 600, color: stats.outstanding > 0 ? 'var(--danger)' : 'var(--success)' }}>
                      ₹{stats.outstanding.toFixed(2)}
                    </p>
                  </div>
                  <div>
                    <p style={{ color: 'var(--text-muted)', fontSize: '0.75rem', marginBottom: '2px' }}>Active Loans</p>
                    <p style={{ fontWeight: 600 }}>{stats.activeLoans}</p>
                  </div>
                </div>
              </div>
            );
          })}
        </div>
      )}
    </div>
  );
}
