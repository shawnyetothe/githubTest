const { describe, it } = require('node:test');
const assert = require('node:assert');
const { Startup } = require('../src/models/startup');

describe('Startup Model', () => {
  it('should create a new startup', async () => {
    const data = {
      name: 'Test Startup',
      industry: 'Technology',
      stage: 'Seed',
      founded: 2024
    };

    const startup = await Startup.create(data);

    assert.ok(startup.id);
    assert.strictEqual(startup.name, 'Test Startup');
    assert.strictEqual(startup.industry, 'Technology');
    assert.ok(startup.createdAt);
  });

  it('should find startup by id', async () => {
    const data = { name: 'Findable Startup', industry: 'Fintech' };
    const created = await Startup.create(data);

    const found = await Startup.findById(created.id);

    assert.strictEqual(found.id, created.id);
    assert.strictEqual(found.name, 'Findable Startup');
  });

  it('should return null for non-existent startup', async () => {
    const found = await Startup.findById('non_existent_id');
    assert.strictEqual(found, null);
  });
});
