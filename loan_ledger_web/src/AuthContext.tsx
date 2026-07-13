import { createContext, useContext, useState, useEffect } from 'react';
import type { ReactNode } from 'react';

// Simplified Mock Auth Context to focus on UI.
// In a real app, you would use Firebase Auth (e.g., onAuthStateChanged).

type User = {
  uid: string;
  email: string;
};

interface AuthContextType {
  user: User | null;
  loading: boolean;
  signIn: (email: string) => Promise<void>;
  signOut: () => Promise<void>;
}

const AuthContext = createContext<AuthContextType | undefined>(undefined);

export function AuthProvider({ children }: { children: ReactNode }) {
  const [user, setUser] = useState<User | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    // Simulate checking auth state on load
    const storedUser = localStorage.getItem('loan_ledger_user');
    if (storedUser) {
      setUser(JSON.parse(storedUser));
    }
    setLoading(false);
  }, []);

  const signIn = async (email: string) => {
    // Simulate network request
    await new Promise(resolve => setTimeout(resolve, 1000));
    const newUser = { uid: 'user_123', email };
    setUser(newUser);
    localStorage.setItem('loan_ledger_user', JSON.stringify(newUser));
  };

  const signOut = async () => {
    await new Promise(resolve => setTimeout(resolve, 500));
    setUser(null);
    localStorage.removeItem('loan_ledger_user');
  };

  return (
    <AuthContext.Provider value={{ user, loading, signIn, signOut }}>
      {children}
    </AuthContext.Provider>
  );
}

export function useAuth() {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
}
