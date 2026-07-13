import { useState, useEffect } from 'react';
import { useNavigate } from 'react-router-dom';
import { db } from './Database';
import type { Customer } from './Database';

export default function GiveLoan() {
  const navigate = useNavigate();
  const [customers, setCustomers] = useState<Customer[]>([]);
  const [selectedCustomerId, setSelectedCustomerId] = useState('');
  const [amount, setAmount] = useState('');
  const [interest, setInterest] = useState('');
  const [dueDate, setDueDate] = useState(() => {
    const d = new Date();
    d.setDate(d.getDate() + 30); // Default to 30 days
    return d.toISOString().split('T')[0];
  });
  const [isSubmitting, setIsSubmitting] = useState(false);

  useEffect(() => {
    db.getCustomers().then(setCustomers);
  }, []);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!selectedCustomerId || !amount) return;
    
    setIsSubmitting(true);
    await db.addLoan({
      customerId: selectedCustomerId,
      amount: parseFloat(amount),
      interestAmount: interest ? parseFloat(interest) : 0,
      date: new Date().toISOString(),
      dueDate: dueDate,
    });
    setIsSubmitting(false);
    navigate('/');
  };

  return (
    <div style={{ padding: '1.5rem', paddingBottom: '100px' }}>
      <div className="flex-between" style={{ marginBottom: '2rem' }}>
        <button onClick={() => navigate(-1)} className="btn-secondary" style={{ padding: '0.5rem 1rem', borderRadius: '8px' }}>Back</button>
        <h1 style={{ fontSize: '1.25rem' }}>Give Loan</h1>
        <div style={{ width: '60px' }}></div>
      </div>

      <form onSubmit={handleSubmit} className="animate-fade-in stagger-1">
        <div className="input-group">
          <label className="input-label">Select Customer</label>
          <select 
            className="input-field" 
            value={selectedCustomerId}
            onChange={(e) => setSelectedCustomerId(e.target.value)}
            required
            style={{ appearance: 'none', background: 'var(--background)' }}
          >
            <option value="" disabled>Choose a customer...</option>
            {customers.map(c => (
              <option key={c.id} value={c.id}>{c.name}</option>
            ))}
          </select>
          {customers.length === 0 && (
            <p style={{ fontSize: '0.75rem', color: 'var(--danger)', marginTop: '4px' }}>
              No customers found. Please add a customer first.
            </p>
          )}
        </div>

        <div className="input-group">
          <label className="input-label">Loan Amount (₹)</label>
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

        <div className="input-group">
          <label className="input-label">Interest Amount (₹)</label>
          <input 
            type="number" 
            className="input-field" 
            placeholder="e.g. 50"
            value={interest}
            onChange={(e) => setInterest(e.target.value)}
            min="0"
          />
        </div>

        <div className="input-group">
          <label className="input-label">Repayment Due Date</label>
          <input 
            type="date" 
            className="input-field" 
            value={dueDate}
            onChange={(e) => setDueDate(e.target.value)}
            required
          />
        </div>

        <button 
          type="submit" 
          className="btn btn-primary" 
          style={{ width: '100%', marginTop: '2rem' }}
          disabled={isSubmitting || customers.length === 0}
        >
          {isSubmitting ? 'Processing...' : 'Confirm Loan'}
        </button>
      </form>
    </div>
  );
}
