const { Startup } = require('../models/startup');

class StartupService {
  static async findAll(filters = {}) {
    return Startup.findAll(filters);
  }

  static async findById(id) {
    return Startup.findById(id);
  }

  static async create(data) {
    return Startup.create(data);
  }

  static async update(id, data) {
    return Startup.update(id, data);
  }

  static async delete(id) {
    return Startup.delete(id);
  }

  static async search(query) {
    return Startup.search(query);
  }
}

module.exports = { StartupService };
