import { useState } from 'react';
import { useNavigate } from 'react-router-dom';
import { db } from './Database';

export default function AddCustomer() {
  const navigate = useNavigate();
  const [name, setName] = useState('');
  const [phone, setPhone] = useState('');
  const [isSubmitting, setIsSubmitting] = useState(false);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setIsSubmitting(true);
    await db.addCustomer({ name, phone });
    setIsSubmitting(false);
    navigate(-1);
  };

  return (
    <div style={{ padding: '1.5rem', paddingBottom: '100px' }}>
      <div className="flex-between" style={{ marginBottom: '2rem' }}>
        <button onClick={() => navigate(-1)} className="btn-secondary" style={{ padding: '0.5rem 1rem', borderRadius: '8px' }}>Back</button>
        <h1 style={{ fontSize: '1.25rem' }}>Add Customer</h1>
        <div style={{ width: '60px' }}></div>
      </div>

      <form onSubmit={handleSubmit} className="animate-fade-in stagger-1">
        <div className="input-group">
          <label className="input-label">Full Name</label>
          <input 
            type="text" 
            className="input-field" 
            placeholder="John Doe"
            value={name}
            onChange={(e) => setName(e.target.value)}
            required
          />
        </div>

        <div className="input-group">
          <label className="input-label">Phone Number</label>
          <input 
            type="tel" 
            className="input-field" 
            placeholder="+1 234 567 8900"
            value={phone}
            onChange={(e) => setPhone(e.target.value)}
            required
          />
        </div>

        <button 
          type="submit" 
          className="btn btn-primary" 
          style={{ width: '100%', marginTop: '2rem' }}
          disabled={isSubmitting}
        >
          {isSubmitting ? 'Saving...' : 'Save Customer'}
        </button>
      </form>
    </div>
  );
}
