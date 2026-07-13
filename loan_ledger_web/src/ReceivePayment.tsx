import React, { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { db } from './Database';
import type { Loan, Customer } from './Database';

export default function ReceivePayment() {
  const navigate = useNavigate();
  const [loans, setLoans] = useState<(Loan & { customerName: string })[]>([]);
  const [selectedLoanId, setSelectedLoanId] = useState('');
  const [amount, setAmount] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    Promise.all([db.getLoans(), db.getCustomers()]).then(([l, c]) => {
      const activeLoans = l.filter(loan => loan.status === 'active').map(loan => {
        const customer = c.find(cust => cust.id === loan.customerId);
        return {
          ...loan,
          customerName: customer ? customer.name : 'Unknown Customer'
        };
      });
      setLoans(activeLoans);
    });
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedLoanId || !amount) return;
    
    setIsSubmitting(true);
    await db.addPayment({
      loanId: selectedLoanId,
      amount: parseFloat(amount),
      date: new Date().toISOString(),
    });
    setIsSubmitting(false);
    navigate('/');
  };

  return (
    <div style={{ padding: '1.5rem', paddingBottom: '100px' }}>
      <div className="flex-between" style={{ marginBottom: '2rem' }}>
        <button onClick={() => navigate(-1)} className="btn-secondary" style={{ padding: '0.5rem 1rem', borderRadius: '8px' }}>Back</button>
        <h1 style={{ fontSize: '1.25rem' }}>Receive Payment</h1>
        <div style={{ width: '60px' }}></div>
      </div>

      <form onSubmit={handleSubmit} className="animate-fade-in stagger-1">
        <div className="input-group">
          <label className="input-label">Select Active Loan</label>
          <select 
            className="input-field" 
            value={selectedLoanId}
            onChange={(e) => setSelectedLoanId(e.target.value)}
            required
            style={{ appearance: 'none', background: 'var(--background)' }}
          >
            <option value="" disabled>Choose a loan...</option>
            {loans.map(l => (
              <option key={l.id} value={l.id}>{l.customerName} - ₹{l.amount}</option>
            ))}
          </select>
          {loans.length === 0 && (
            <p style={{ fontSize: '0.75rem', color: 'var(--danger)', marginTop: '4px' }}>
              No active loans found.
            </p>
          )}
        </div>

        <div className="input-group">
          <label className="input-label">Payment Amount (₹)</label>
          <input 
            type="number" 
            className="input-field" 
            placeholder="e.g. 500"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            required
            min="1"
          />
        </div>

        <button 
          type="submit" 
          className="btn btn-primary" 
          style={{ width: '100%', marginTop: '2rem', background: 'var(--success)' }}
          disabled={isSubmitting || loans.length === 0}
        >
          {isSubmitting ? 'Processing...' : 'Confirm Payment'}
        </button>
      </form>
    </div>
  );
}
