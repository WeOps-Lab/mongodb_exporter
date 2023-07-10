use admin;
db.auth('root', 'Weops#@$123');
use weops;
db.createUser({
  user: 'weops',
  pwd: 'Weops#@$123',
  roles: [{ role: 'read', db: 'weops' }]
});
db.grantRolesToUser('weops', [{ role: 'clusterMonitor', db: 'admin' }]);