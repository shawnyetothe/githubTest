// Startup model - placeholder for database integration

const startups = [];

class Startup {
  static async findAll(filters = {}) {
    // TODO: Implement database query with filters
    return startups;
  }

  static async findById(id) {
    return startups.find(s => s.id === id) || null;
  }

  static async create(data) {
    const startup = {
      id: `startup_${Date.now()}`,
      ...data,
      createdAt: new Date().toISOString()
    };
    startups.push(startup);
    return startup;
  }

  static async update(id, data) {
    const index = startups.findIndex(s => s.id === id);
    if (index === -1) return null;
    startups[index] = { ...startups[index], ...data };
    return startups[index];
  }

  static async delete(id) {
    const index = startups.findIndex(s => s.id === id);
    if (index === -1) return false;
    startups.splice(index, 1);
    return true;
  }

  static async search(query) {
    return startups.filter(s =>
      s.name?.toLowerCase().includes(query.toLowerCase()) ||
      s.industry?.toLowerCase().includes(query.toLowerCase())
    );
  }
}

module.exports = { Startup };
