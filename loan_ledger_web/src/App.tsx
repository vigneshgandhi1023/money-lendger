import { BrowserRouter, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider, useAuth } from './AuthContext';
import Login from './Login';
import Dashboard from './Dashboard';
import AddCustomer from './AddCustomer';
import GiveLoan from './GiveLoan';
import ReceivePayment from './ReceivePayment';
import CustomersList from './CustomersList';
import { Home, Users, BarChart3, Settings } from 'lucide-react';

import type { ReactNode } from 'react';

function ProtectedRoute({ children }: { children: ReactNode }) {
  const { user, loading } = useAuth();

  if (loading) return <div style={{ height: '100vh', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>Loading...</div>;
  if (!user) return <Navigate to="/login" replace />;

  return (
    <>
      {children}
      
      {/* Bottom Navigation for Web App (Mobile First) */}
      <div style={{
        position: 'fixed',
        bottom: 0,
        left: 0,
        right: 0,
        backgroundColor: 'var(--surface)',
        borderTop: '1px solid var(--border)',
        display: 'flex',
        justifyContent: 'space-around',
        padding: '0.75rem 0',
        paddingBottom: 'calc(0.75rem + env(safe-area-inset-bottom))',
        zIndex: 50,
      }}>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px', color: 'var(--primary)' }}>
          <Home size={24} />
          <span style={{ fontSize: '10px', fontWeight: 600 }}>Home</span>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px', color: 'var(--text-muted)' }}>
          <Users size={24} />
          <span style={{ fontSize: '10px', fontWeight: 600 }}>Clients</span>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px', color: 'var(--text-muted)' }}>
          <BarChart3 size={24} />
          <span style={{ fontSize: '10px', fontWeight: 600 }}>Reports</span>
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: '4px', color: 'var(--text-muted)' }}>
          <Settings size={24} />
          <span style={{ fontSize: '10px', fontWeight: 600 }}>Settings</span>
        </div>
      </div>
    </>
  );
}

function AppRoutes() {
  return (
    <Routes>
      <Route path="/login" element={<Login />} />
      <Route path="/" element={
        <ProtectedRoute>
          <Dashboard />
        </ProtectedRoute>
      } />
      <Route path="/add-customer" element={
        <ProtectedRoute>
          <AddCustomer />
        </ProtectedRoute>
      } />
      <Route path="/give-loan" element={
        <ProtectedRoute>
          <GiveLoan />
        </ProtectedRoute>
      } />
      <Route path="/receive-payment" element={
        <ProtectedRoute>
          <ReceivePayment />
        </ProtectedRoute>
      } />
      <Route path="/customers" element={
        <ProtectedRoute>
          <CustomersList />
        </ProtectedRoute>
      } />
    </Routes>
  );
}

export default function App() {
  return (
    <AuthProvider>
      <BrowserRouter>
        <AppRoutes />
      </BrowserRouter>
    </AuthProvider>
  );
}
