// Deal model - placeholder for database integration

const deals = [];

const DEAL_STAGES = [
  'initial_contact',
  'screening',
  'due_diligence',
  'term_sheet',
  'negotiation',
  'closed_won',
  'closed_lost'
];

class Deal {
  static async findAll(filters = {}) {
    let result = [...deals];

    if (filters.stage) {
      result = result.filter(d => d.stage === filters.stage);
    }
    if (filters.startupId) {
      result = result.filter(d => d.startupId === filters.startupId);
    }

    return result;
  }

  static async findById(id) {
    return deals.find(d => d.id === id) || null;
  }

  static async create(data) {
    const deal = {
      id: `deal_${Date.now()}`,
      stage: 'initial_contact',
      notes: [],
      ...data,
      createdAt: new Date().toISOString()
    };
    deals.push(deal);
    return deal;
  }

  static async update(id, data) {
    const index = deals.findIndex(d => d.id === id);
    if (index === -1) return null;
    deals[index] = { ...deals[index], ...data, updatedAt: new Date().toISOString() };
    return deals[index];
  }

  static async delete(id) {
    const index = deals.findIndex(d => d.id === id);
    if (index === -1) return false;
    deals.splice(index, 1);
    return true;
  }

  static getStages() {
    return DEAL_STAGES;
  }
}

module.exports = { Deal, DEAL_STAGES };
