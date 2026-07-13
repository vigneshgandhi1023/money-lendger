// Simple Local Storage Database to simulate Cloud Backend for demonstration

export type Customer = {
  id: string;
  name: string;
  phone: string;
};

export type Loan = {
  id: string;
  customerId: string;
  amount: number;
  interestAmount?: number;
  date: string;
  dueDate: string;
  status: 'active' | 'closed';
};

export type Payment = {
  id: string;
  loanId: string;
  amount: number;
  date: string;
};

const delay = (ms: number) => new Promise(res => setTimeout(res, ms));

export const db = {
  async getCustomers(): Promise<Customer[]> {
    await delay(300);
    const data = localStorage.getItem('ll_customers');
    return data ? JSON.parse(data) : [];
  },

  async addCustomer(customer: Omit<Customer, 'id'>): Promise<Customer> {
    await delay(500);
    const customers = await this.getCustomers();
    const newCustomer = { ...customer, id: Math.random().toString(36).substring(7) };
    customers.push(newCustomer);
    localStorage.setItem('ll_customers', JSON.stringify(customers));
    return newCustomer;
  },

  async getLoans(): Promise<Loan[]> {
    await delay(300);
    const data = localStorage.getItem('ll_loans');
    return data ? JSON.parse(data) : [];
  },

  async addLoan(loan: Omit<Loan, 'id' | 'status'>): Promise<Loan> {
    await delay(500);
    const loans = await this.getLoans();
    const newLoan = { ...loan, id: Math.random().toString(36).substring(7), status: 'active' as const };
    loans.push(newLoan);
    localStorage.setItem('ll_loans', JSON.stringify(loans));
    return newLoan;
  },

  async getPayments(): Promise<Payment[]> {
    const data = localStorage.getItem('ll_payments');
    return data ? JSON.parse(data) : [];
  },

  async addPayment(payment: Omit<Payment, 'id'>): Promise<Payment> {
    await delay(500);
    const payments = await this.getPayments();
    const newPayment = { ...payment, id: Math.random().toString(36).substring(7) };
    payments.push(newPayment);
    localStorage.setItem('ll_payments', JSON.stringify(payments));
    return newPayment;
  }
};
