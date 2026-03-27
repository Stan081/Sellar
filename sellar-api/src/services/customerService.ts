import { CustomerRepository } from '../repositories/customerRepository';

const repo = new CustomerRepository();

export class CustomerService {
  async listCustomers(vendorId: string) {
    const customers = await repo.findAllByVendor(vendorId);

    return customers.map((c: any) => ({
      id: c.id,
      name: c.name,
      email: c.email,
      phone: c.phone,
      billingAddress: c.billingAddress,
      currency: c.currency,
      totalSpent: c.totalSpent,
      purchaseCount: c._count?.transactions ?? c.totalOrders ?? 0,
      createdAt: c.createdAt ?? c.firstSeenAt,
      lastPurchaseAt: c.lastPurchaseAt ?? c.lastSeenAt,
    }));
  }

  async getCustomer(id: string, vendorId: string) {
    const customer = await repo.findOneByVendor(id, vendorId);
    if (!customer) throw new Error('Customer not found');

    const c = customer as any;
    return {
      id: c.id,
      name: c.name,
      email: c.email,
      phone: c.phone,
      billingAddress: c.billingAddress,
      currency: c.currency,
      totalSpent: c.totalSpent,
      purchaseCount: c._count?.transactions ?? c.totalOrders ?? 0,
      createdAt: c.createdAt ?? c.firstSeenAt,
      lastPurchaseAt: c.lastPurchaseAt ?? c.lastSeenAt,
      transactions: (c.transactions ?? []).map((t: any) => ({
        id: t.id,
        productId: t.paymentLink?.product?.id ?? null,
        productName: t.paymentLink?.product?.name ?? null,
        amount: t.amount,
        currency: t.currency,
        status: t.status,
        createdAt: t.createdAt,
        linkId: t.paymentLinkId,
      })),
    };
  }

  async findOrCreateCustomer(vendorId: string, data: {
    email?: string;
    phone?: string;
    name?: string;
    billingAddress?: string;
    currency?: string;
  }) {
    const contact = data.email || data.phone;
    if (!contact) throw new Error('Email or phone is required to identify customer');

    const existing = await repo.findByContact(vendorId, contact);
    if (existing) {
      // Update name/billing if provided and changed
      if (data.name || data.billingAddress) {
        await repo.update(existing.id, {
          ...(data.name && { name: data.name }),
          ...(data.billingAddress && { billingAddress: data.billingAddress }),
        });
      }
      return existing;
    }

    return repo.create({
      vendorId,
      name: data.name,
      email: data.email,
      phone: data.phone,
      billingAddress: data.billingAddress,
      currency: data.currency ?? 'USD',
      uniqueContact: contact,
    });
  }

  async recordPurchase(customerId: string, amount: number) {
    return repo.updateAfterPurchase(customerId, amount);
  }
}
