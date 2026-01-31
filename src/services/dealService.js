const { Deal } = require('../models/deal');

class DealService {
  static async findAll(filters = {}) {
    return Deal.findAll(filters);
  }

  static async findById(id) {
    return Deal.findById(id);
  }

  static async create(data) {
    return Deal.create({
      ...data,
      stage: data.stage || 'initial_contact',
      createdAt: new Date().toISOString()
    });
  }

  static async updateStage(id, stage) {
    return Deal.update(id, { stage, updatedAt: new Date().toISOString() });
  }

  static async addNote(id, note) {
    const deal = await Deal.findById(id);
    const notes = deal.notes || [];
    notes.push({ content: note, createdAt: new Date().toISOString() });
    return Deal.update(id, { notes });
  }
}

module.exports = { DealService };
