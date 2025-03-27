// --- FILE index.js ---
const jsonServer = require('@wll8/json-server');
const moment = require('moment');
const { faker } = require('@faker-js/faker');
const server = jsonServer.create();
const router = jsonServer.router('db.json');
const middlewares = jsonServer.defaults();
const http = require('http');
const { Server } = require('socket.io');

const httpServer = http.createServer(server);
const io = new Server(httpServer, {
  cors: {
    origin: '*',
    methods: ['GET', 'POST'],
  },
});

server.use(middlewares);
server.use(jsonServer.bodyParser);

io.on('connection', (socket) => {
  console.log('a user connected:', socket.id);
  socket.on('disconnect', () => {
    console.log('user disconnected:', socket.id);
  });
});

function isAdmin(req) {
  const db = router.db;
  const userId = req.headers.userid;
  if (!userId) return false;
  const user = db.get('users').find({ id: userId }).value();
  return user && user.role === 'admin';
}

function hasRole(req, roles) {
  const db = router.db;
  const userId = req.headers.userid;
  if (!userId) return false;
  const user = db.get('users').find({ id: userId }).value();
  return user && roles.includes(user.role);
}

async function updateStatistics(db, order) {
  const today = new Date().toISOString().split('T')[0];
  let stats = db.get('statistics').find({ date: today }).value();

  if (!stats) {
    stats = {
      id: `stats-${today}`,
      date: today,
      totalOrders: 0,
      totalRevenue: 0,
      paymentMethodSummary: {},
      ordersByHour: Array(24).fill(0),
      soldItems: {},
      averageRating: 0,
      totalComments: 0,
    };
    db.get('statistics').push(stats).write();
  }

  stats.totalOrders += 1;
  let orderTotal = 0;
  order.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      orderTotal += menuItem.price * item.quantity;
    }
  });
  stats.totalRevenue += orderTotal;

  const paymentMethodName = order.paymentMethod;
  let paymentMethod = db.get('payments').find({ name: paymentMethodName }).value();

  if (!paymentMethod) {
    paymentMethod = {
      id: faker.database.mongodbObjectId(),
      name: paymentMethodName,
      isActive: true,
    };
    db.get('payments').push(paymentMethod).write();
  }

  const paymentMethodId = paymentMethod.id;

  if (!stats.paymentMethodSummary[paymentMethodId]) {
    stats.paymentMethodSummary[paymentMethodId] = {
      paymentId: paymentMethodId,
      count: 0,
      totalAmount: 0.0,
    };
  }
  stats.paymentMethodSummary[paymentMethodId].count += 1;
  stats.paymentMethodSummary[paymentMethodId].totalAmount += orderTotal;

  const hour = new Date(order.completedAt).getHours();
  if (!stats.ordersByHour) {
    stats.ordersByHour = Array(24).fill(0);
  }
  stats.ordersByHour[hour] = (stats.ordersByHour[hour] || 0) + 1;

  order.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      const name = menuItem.name;
      stats.soldItems[name] = (stats.soldItems[name] || 0) + item.quantity;
    }
  });

  db.get('statistics').find({ date: today }).assign(stats).write();
}
function performMonthlyRollover() {
  const db = router.db;
  const now = moment();
  const currentMonth = now.format('YYYY-MM');
  const lastMonth = now.clone().subtract(1, 'month').format('YYYY-MM');

  const lastMonthStats = db
    .get('statistics')
    .filter((stat) => moment(stat.date).format('YYYY-MM') === lastMonth)
    .value();

  if (lastMonthStats.length > 0) {
    const aggregatedStatsLastMonth = {
      id: lastMonth,
      year: parseInt(lastMonth.split('-')[0]),
      month: parseInt(lastMonth.split('-')[1]),
      totalOrders: lastMonthStats.reduce((sum, s) => sum + s.totalOrders, 0),
      totalRevenue: lastMonthStats.reduce((sum, s) => sum + s.totalRevenue, 0),
      paymentMethodSummary: {},
      averageRating: 0,
      totalComments: lastMonthStats.reduce((sum, s) => sum + s.totalComments, 0),
      soldItems: {},
    };

    lastMonthStats.forEach((stat) => {
      for (const paymentId in stat.paymentMethodSummary) {
        if (stat.paymentMethodSummary.hasOwnProperty(paymentId)) {
          const paymentData = stat.paymentMethodSummary[paymentId];
          if (!aggregatedStatsLastMonth.paymentMethodSummary[paymentId]) {
            aggregatedStatsLastMonth.paymentMethodSummary[paymentId] = {
              paymentId: paymentId,
              count: 0,
              totalAmount: 0.0,
            };
          }
          aggregatedStatsLastMonth.paymentMethodSummary[paymentId].count += paymentData.count;
          aggregatedStatsLastMonth.paymentMethodSummary[paymentId].totalAmount +=
            paymentData.totalAmount;
        }
      }

      for (const item in stat.soldItems) {
        aggregatedStatsLastMonth.soldItems[item] =
          (aggregatedStatsLastMonth.soldItems[item] || 0) + stat.soldItems[item];
      }
    });

    const allRatings = lastMonthStats
      .map((stat) => stat.averageRating)
      .filter((rating) => rating > 0);
    if (allRatings.length > 0) {
      aggregatedStatsLastMonth.averageRating =
        allRatings.reduce((sum, r) => sum + r, 0) / allRatings.length;
    }

    db.get('aggregatedStatistics').push(aggregatedStatsLastMonth).write();
    const currentMonthStats = db
      .get('statistics')
      .filter((stat) => moment(stat.date).format('YYYY-MM') === currentMonth)
      .value();

    db.set('statistics', currentMonthStats).write();
  }

  const currentMonthStats = db
    .get('statistics')
    .filter((stat) => moment(stat.date).format('YYYY-MM') === currentMonth)
    .value();

  if (currentMonthStats.length > 0) {
    const aggregatedStatsCurrentMonth = {
      id: currentMonth,
      year: parseInt(currentMonth.split('-')[0]),
      month: parseInt(currentMonth.split('-')[1]),
      totalOrders: currentMonthStats.reduce((sum, s) => sum + s.totalOrders, 0),
      totalRevenue: currentMonthStats.reduce((sum, s) => sum + s.totalRevenue, 0),
      paymentMethodSummary: {},
      averageRating: 0,
      totalComments: currentMonthStats.reduce((sum, s) => sum + s.totalComments, 0),
      soldItems: {},
    };
    currentMonthStats.forEach((stat) => {
      for (const paymentId in stat.paymentMethodSummary) {
        if (stat.paymentMethodSummary.hasOwnProperty(paymentId)) {
          const paymentData = stat.paymentMethodSummary[paymentId];
          if (!aggregatedStatsCurrentMonth.paymentMethodSummary[paymentId]) {
            aggregatedStatsCurrentMonth.paymentMethodSummary[paymentId] = {
              paymentId: paymentId,
              count: 0,
              totalAmount: 0.0,
            };
          }
          aggregatedStatsCurrentMonth.paymentMethodSummary[paymentId].count += paymentData.count;
          aggregatedStatsCurrentMonth.paymentMethodSummary[paymentId].totalAmount +=
            paymentData.totalAmount;
        }
      }

      for (const item in stat.soldItems) {
        aggregatedStatsCurrentMonth.soldItems[item] =
          (aggregatedStatsCurrentMonth.soldItems[item] || 0) + stat.soldItems[item];
      }
    });
    const allRatings = currentMonthStats
      .map((stat) => stat.averageRating)
      .filter((rating) => rating > 0);
    if (allRatings.length > 0) {
      aggregatedStatsCurrentMonth.averageRating =
        allRatings.reduce((sum, r) => sum + r, 0) / allRatings.length;
    }
    const existingCurrentMonthEntry = db
      .get('aggregatedStatistics')
      .find({ id: currentMonth })
      .value();
    if (existingCurrentMonthEntry) {
      db.get('aggregatedStatistics')
        .find({ id: currentMonth })
        .assign(aggregatedStatsCurrentMonth)
        .write();
    } else {
      db.get('aggregatedStatistics').push(aggregatedStatsCurrentMonth).write();
    }
  }
}

server.post('/login', (req, res) => {
  const db = router.db;
  const { username, password } = req.body;
  const user = db.get('users').find({ username, password }).value();
  if (user) {
    const { password, ...userWithoutPassword } = user;
    res.json({ user: userWithoutPassword });
  } else {
    res.status(401).json({ message: 'Invalid credentials' });
  }
});

server.use((req, res, next) => {
  const excludedPaths = ['/login', '/feedback'];
  const isExcluded = excludedPaths.some(
    (path) =>
      (req.path.startsWith(path) && req.method === 'POST') ||
      (req.path === path && req.method === 'GET'),
  );
  if (isExcluded) {
    next();
    return;
  }
  const publicGetPaths = [
    '/categories',
    '/subCategories',
    '/menuItems',
    '/areas',
    '/tables',
    '/areas-with-tables',
    '/feedback',
    '/payments',
  ];
  const isPublicGet = publicGetPaths.some(
    (path) =>
      (req.path.startsWith(path) && req.method === 'GET') ||
      (req.path === path && req.method === 'GET'),
  );
  if (isPublicGet) {
    next();
    return;
  }

  if (req.headers.userid) {
    next();
  } else {
    res.status(401).json({ message: 'Unauthorized' });
  }
});

server.use('/users', (req, res, next) => {
  if (req.method !== 'GET' && !isAdmin(req)) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  next();
});

server.get('/users', (req, res) => {
  const db = router.db;
  let users = db.get('users');

  users = users.filter((user) => user.role !== 'admin');

  const userData = users.value().map((user) => {
    const { password, ...userWithoutPassword } = user;
    return userWithoutPassword;
  });

  res.json(userData);
});

server.use(['/categories', '/subCategories', '/menuItems'], (req, res, next) => {
  if (req.method !== 'GET' && !isAdmin(req)) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  next();
});

server.use(['/areas', '/tables'], (req, res, next) => {
  if (req.method !== 'GET' && !isAdmin(req)) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  next();
});

server.get('/areas-with-tables', (req, res) => {
  const db = router.db;
  const areas = db.get('areas').value();
  const tables = db.get('tables').value();
  const activeOrders = db.get('orders').value();

  const areasWithTables = areas.map((area) => {
    const tablesInArea = tables.filter((table) => table.areaId === area.id);

    const tablesWithOrders = tablesInArea.map((table) => {
      const currentOrder = activeOrders.find((order) => order.tableId === table.id);

      let orderData = null;
      if (currentOrder) {
        let orderTotal = 0;
        const orderItems = currentOrder.orderItems
          .map((item) => {
            const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
            if (!menuItem) {
              console.warn(`Menu item not found for ID: ${item.menuItemId}`);
              return null; // Handle missing menu item
            }
            orderTotal += menuItem.price * item.quantity;
            return {
              id: item.id,
              orderId: currentOrder.id,
              menuItem: menuItem,
              quantity: item.quantity,
              price: menuItem.price,
            };
          })
          .filter((item) => item !== null);

        orderData = {
          id: currentOrder.id,
          tableId: currentOrder.tableId,
          timestamp: currentOrder.timestamp,
          orderItems: orderItems,
          totalPrice: parseFloat(orderTotal.toFixed(2)),
          createdBy: currentOrder.createdBy,
          createdAt: currentOrder.createdAt,
          servedBy: currentOrder.servedBy,
          servedAt: currentOrder.servedAt,
        };
      }

      return {
        ...table,
        order: orderData,
      };
    });

    return {
      ...area,
      tables: tablesWithOrders,
    };
  });

  res.json(areasWithTables);
});

server.post('/orders', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['serve', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const { tableId, orderItems } = req.body;
  console.log(req.body);

  if (!tableId) {
    return res.status(400).json({ message: 'tableId is required' });
  }
  if (!orderItems || !Array.isArray(orderItems)) {
    return res.status(400).json({ message: 'orderItems must be an array' });
  }

  const table = db.get('tables').find({ id: tableId }).value();
  if (!table) {
    return res.status(400).json({ message: 'Invalid table ID' });
  }

  // --- Simplified POST:  Always create a NEW order ---
  let newOrder = {
    id: faker.database.mongodbObjectId(), // Generate a new ID
    tableId: tableId,
    timestamp: new Date().toISOString(),
    createdBy: userId,
    createdAt: new Date().toISOString(),
    orderItems: [], // Start empty, will be populated below
  };

  // Aggregate quantities from the *request* only.
  for (const item of orderItems) {
    const menuItem = db.get('menuItems').find({ id: item.id }).value(); // Use item.menuItem
    if (!menuItem) {
      console.log(`Invalid menu item ID: ${item.id}`);
      return res.status(400).json({ message: `Invalid menu item ID: ${item.id}` });
    }
    // Create the final orderItems array with correct IDs and quantities
    newOrder.orderItems.push({
      id: `orderItem-${newOrder.id}-${item.id}`, // Server-generated ID
      orderId: newOrder.id,
      menuItemId: item.id, // Correct field
      quantity: item.quantity,
    });
  }

  // Calculate total price
  let totalPrice = 0;
  newOrder.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      totalPrice += menuItem.price * item.quantity;
    }
  });

  newOrder.totalPrice = parseFloat(totalPrice.toFixed(2));

  db.get('orders').push(newOrder).write(); // Always PUSH a new order

  const orderData = {
    id: newOrder.id,
    createdAt: newOrder.createdAt,
    orderItems: newOrder.orderItems.map((item) => ({
      menuItemId: item.menuItemId,
      quantity: item.quantity,
    })),
    totalPrice: newOrder.totalPrice,
  };

  db.get('tables').find({ id: tableId }).assign({ status: 'pending', order: orderData }).write();

  io.emit('order_updated');

  res.status(201).json(newOrder);
});

server.patch('/orders/:id', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;
  const order = db.get('orders').find({ id: req.params.id }).value();
  if (!order) {
    return res.status(404).json({ message: 'Order not found' });
  }
  const table = db.get('tables').find({ id: order.tableId }).value();
  if (!table) {
    return res.status(404).json({ message: 'Table not found' });
  }
  if (!userId) {
    return res.status(401).json({ message: 'Unauthorized' });
  }
  const user = db.get('users').find({ id: userId }).value();
  const updatedOrder = req.body;

  if (hasRole(req, ['serve', 'cashier']) && updatedOrder.status === 'served') {
    order.servedBy = userId;
    order.servedAt = new Date().toISOString();

    let totalPrice = 0;
    order.orderItems.forEach((item) => {
      const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
      if (menuItem) {
        totalPrice += menuItem.price * item.quantity;
      }
    });

    const orderData = {
      id: order.id,
      createdAt: order.createdAt,
      orderItems: order.orderItems.map((item) => ({
        menuItemId: item.menuItemId,
        quantity: item.quantity,
      })),
      totalPrice: parseFloat(totalPrice.toFixed(2)),
      servedBy: order.servedBy,
      servedAt: order.servedAt,
    };

    db.get('tables')
      .find({ id: order.tableId })
      .assign({ status: 'served', order: orderData })
      .write();
    db.get('orders').find({ id: req.params.id }).assign(order).write();

    io.emit('order_updated');

    return res.json(order);
  } else if (hasRole(req, ['cashier']) && updatedOrder.status === 'completed') {
    const allowedPaymentMethods = db
      .get('payments')
      .value()
      .map((payment) => payment.name);

    if (
      !updatedOrder.paymentMethod ||
      !allowedPaymentMethods.includes(updatedOrder.paymentMethod)
    ) {
      return res.status(400).json({ message: 'Invalid payment method' });
    }

    let totalPrice = 0;
    order.orderItems.forEach((item) => {
      const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
      totalPrice += menuItem.price * item.quantity;
    });

    const completedOrder = {
      ...order,
      completedAt: new Date().toISOString(),
      cashierId: userId,
      totalPrice: parseFloat(totalPrice.toFixed(2)),
      paymentMethod: updatedOrder.paymentMethod,
    };

    db.get('orderHistory').push(completedOrder).write();
    db.get('orders').remove({ id: req.params.id }).write();

    db.get('tables')
      .find({ id: completedOrder.tableId })
      .assign({ status: 'completed', order: null })
      .write();
    updateStatistics(db, completedOrder);
    performMonthlyRollover();

    io.emit('order_updated');

    return res.json(completedOrder);
  } else if (hasRole(req, ['serve'])) {
    // Add this condition
    // Handle order item updates (additions, quantity changes)
    if (updatedOrder.orderItems) {
      const itemMap = new Map();

      // Aggregate quantities from existing order
      order.orderItems.forEach((item) => {
        itemMap.set(item.menuItemId, (itemMap.get(item.menuItemId) || 0) + item.quantity);
      });

      // Aggregate quantities from the update request
      updatedOrder.orderItems.forEach((item) => {
        const exitItem = itemMap.get(item.menuItem);
        if (exitItem) {
          itemMap.set(item.menuItem, (itemMap.get(item.menuItem) || 0) + item.quantity);
        } else {
          itemMap.set(item.menuItem, item.quantity);
        }
      });

      // Create the final orderItems array
      order.orderItems = Array.from(itemMap.entries()).map(([menuItemId, quantity]) => ({
        id: `orderItem-${order.id}-${menuItemId}`, // Consistent ID format
        orderId: order.id,
        menuItemId: menuItemId,
        quantity: quantity,
      }));

      // Recalculate total price
      let totalPrice = 0;
      order.orderItems.forEach((item) => {
        const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
        if (menuItem) {
          totalPrice += menuItem.price * item.quantity;
        }
      });
      order.totalPrice = parseFloat(totalPrice.toFixed(2));
    }

    db.get('orders').find({ id: req.params.id }).assign(order).write();

    const orderData = {
      id: order.id,
      createdAt: order.createdAt,
      orderItems: order.orderItems.map((item) => ({
        menuItemId: item.menuItemId,
        quantity: item.quantity,
      })),
      totalPrice: order.totalPrice,
      servedBy: order.servedBy,
      servedAt: order.servedAt,
    };

    db.get('tables').find({ id: order.tableId }).assign({ order: orderData }).write();

    io.emit('order_updated');

    return res.json(order);
  }
});
// --- FILE index.js ---
// --- FILE index.js ---
// --- FILE index.js ---

// --- FILE index.js ---
server.post('/orders/merge-request', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['serve', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const { sourceTableId, targetTableId, splitItemIds } = req.body;

  if (!sourceTableId || !targetTableId || !splitItemIds) {
    print(6);
    return res
      .status(400)
      .json({ message: 'sourceTableId, targetTableId, and splitItemIds are required.' });
  }

  const sourceTable = db.get('tables').find({ id: sourceTableId }).value();
  const targetTable = db.get('tables').find({ id: targetTableId }).value();

  if (!sourceTable || !targetTable) {
    return res.status(404).json({ message: 'One or both tables not found.' });
  }

  if (sourceTableId === targetTableId) {
    return res.status(400).json({ message: 'Target cannot be the same as source.' });
  }

  let sourceOrder = db.get('orders').find({ tableId: sourceTableId }).value();
  let targetOrder = db.get('orders').find({ tableId: targetTableId }).value();

  if (!sourceOrder) {
    return res.status(404).json({ message: 'Source has no active order.' });
  }
  if (!targetOrder) {
    //If target no order, create
    targetOrder = {
      id: faker.database.mongodbObjectId(),
      tableId: targetTableId,
      timestamp: new Date().toISOString(),
      createdBy: userId,
      createdAt: new Date().toISOString(),
      orderItems: [],
    };
    db.get('orders').push(targetOrder).write();
  }

  // Input validation (ensure quantities are valid and don't exceed available)
  for (const menuItemId in splitItemIds) {
    if (splitItemIds.hasOwnProperty(menuItemId)) {
      const quantityToMove = splitItemIds[menuItemId];

      if (quantityToMove === 0) continue;

      if (!Number.isInteger(quantityToMove) || quantityToMove <= 0) {
        console.log(4, `Invalid quantity for menuItemId: ${menuItemId}`, quantityToMove);
        return res.status(400).json({ message: `Invalid quantity for menuItemId: ${menuItemId}` });
      }

      const sourceItem = sourceOrder.orderItems.find((item) => item.menuItemId === menuItemId);

      if (!sourceItem) {
        console.log(3);
        return res.status(400).json({ message: 'Menu item not found in source order.' });
      }

      if (quantityToMove > sourceItem.quantity) {
        console.log(2);
        return res.status(400).json({
          message: `Cannot move ${quantityToMove} of ${menuItemId}. Only ${sourceItem.quantity} available.`,
        });
      }
    }
  }

  // Store the ORIGINAL state for potential rollback (DEEP COPIES)
  const originalMergedTable = targetTable.mergedTable || 1;
  const originalSourceOrderItems = JSON.parse(JSON.stringify(sourceOrder.orderItems));
  const originalTargetOrderItems = JSON.parse(JSON.stringify(targetOrder.orderItems));

  // --- Prepare for potential empty source order ---
  const sourceOrderForHistory = {
    ...sourceOrder, // Copy *before* any further modifications
    completedAt: new Date().toISOString(),
    cashierId: null, // No cashier involved in merge request completion
    totalPrice: sourceOrder.totalPrice, // This might be 0, but that's OK
    paymentMethod: null, // No payment
  };
  // Create a map to track changes to source order items.  Key is menuItemId, value is quantity change.
  const sourceItemChanges = {};

  // --- Modify orders directly ---
  Object.keys(splitItemIds).forEach((menuItemId) => {
    const quantityToMove = splitItemIds[menuItemId];

    // Find and update/add to target order
    const existingTargetItemIndex = targetOrder.orderItems.findIndex(
      (item) => item.menuItemId === menuItemId,
    );
    if (existingTargetItemIndex !== -1) {
      const id = targetOrder.orderItems[existingTargetItemIndex].id;
      targetOrder.orderItems.push({
        id: faker.string.uuid(), // NEW ID
        orderId: targetOrder.id,
        menuItemId: menuItemId,
        quantity: quantityToMove,
      });
    } else {
      const sourceItem = sourceOrder.orderItems.find((item) => item.menuItemId === menuItemId);
      targetOrder.orderItems.push({
        id: faker.string.uuid(), // NEW ID
        orderId: targetOrder.id,
        menuItemId: menuItemId,
        quantity: quantityToMove,
      });
    }

    // 2. Track changes to the source order.
    sourceItemChanges[menuItemId] = (sourceItemChanges[menuItemId] || 0) + quantityToMove;
  });

  // 3. Apply changes to the source order, iterating safely.
  for (let i = sourceOrder.orderItems.length - 1; i >= 0; i--) {
    const item = sourceOrder.orderItems[i];
    if (sourceItemChanges[item.menuItemId]) {
      item.quantity -= sourceItemChanges[item.menuItemId];
      if (item.quantity <= 0) {
        sourceOrder.orderItems.splice(i, 1);
      }
    }
  }

  // Recalculate total prices
  sourceOrder.totalPrice = sourceOrder.orderItems.reduce((total, item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    return total + (menuItem ? menuItem.price * item.quantity : 0);
  }, 0);
  sourceOrder.totalPrice = parseFloat(sourceOrder.totalPrice.toFixed(2));

  targetOrder.totalPrice = targetOrder.orderItems.reduce((total, item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    return total + (menuItem ? menuItem.price * item.quantity : 0);
  }, 0);
  targetOrder.totalPrice = parseFloat(targetOrder.totalPrice.toFixed(2));

  // Update the 'mergedTable' count on the target table
  db.get('tables')
    .find({ id: targetTableId })
    .assign({ mergedTable: originalMergedTable + 1 })
    .write();

  // Create the merge request record
  const mergeRequest = {
    id: faker.database.mongodbObjectId(),
    sourceTableId,
    targetTableId,
    originalMergedTable,
    originalSourceOrderItems,
    originalTargetOrderItems,
    status: 'pending',
    requestedBy: userId,
    requestedAt: new Date().toISOString(),
  };

  db.get('mergeRequests').push(mergeRequest).write();

  // --- Update the orders in the database ---
  db.get('orders').find({ id: sourceOrder.id }).assign(sourceOrder).write();
  db.get('orders').find({ id: targetOrder.id }).assign(targetOrder).write();

  // --- Check and handle empty source order ---  // Moved BEFORE emitting updates
  if (sourceOrder.orderItems.length === 0) {
    // db.get('orderHistory').push(sourceOrderForHistory).write(); // Use the copy!
    db.get('orders').remove({ id: sourceOrder.id }).write();

    db.get('tables')
      .find({ id: sourceTableId })
      .assign({ status: 'completed', order: null })
      .write();
  }

  // Prepare data for emitting to clients (source order)
  const sourceOrderData = {
    id: sourceOrder.id,
    createdAt: sourceOrder.createdAt,
    orderItems: sourceOrder.orderItems.map((item) => ({
      menuItemId: item.menuItemId,
      quantity: item.quantity,
    })),
    totalPrice: sourceOrder.totalPrice,
    servedBy: sourceOrder.servedBy,
    servedAt: sourceOrder.servedAt,
  };

  // Prepare data for emitting to clients (target order)
  const targetOrderData = {
    id: targetOrder.id,
    createdAt: targetOrder.createdAt,
    orderItems: targetOrder.orderItems.map((item) => ({
      menuItemId: item.menuItemId,
      quantity: item.quantity,
    })),
    totalPrice: targetOrder.totalPrice,
    servedBy: targetOrder.servedBy,
    servedAt: targetOrder.servedAt,
  };

  // update status table
  if (sourceOrder.orderItems.length != 0) {
    db.get('tables').find({ id: sourceTableId }).assign({ order: sourceOrderData }).write();
  }

  db.get('tables').find({ id: targetTableId }).assign({ order: targetOrderData }).write();
  io.emit('order_updated');

  res.status(201).json(mergeRequest);
});

server.post('/orders/merge-approve', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['cashier', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const { tableId } = req.body; // Now expecting tableId

  if (!tableId) {
    return res.status(400).json({ message: 'tableId is required.' });
  }

  // Find the *pending* merge request associated with this target table.
  const mergeRequest = db
    .get('mergeRequests')
    .find({ targetTableId: tableId, status: 'pending' })
    .value(); // Find by targetTableId AND status

  if (!mergeRequest) {
    return res.status(404).json({ message: 'Merge request not found for this table.' });
  }
  // --- Set mergedTable to 1---
  db.get('tables').find({ id: mergeRequest.targetTableId }).assign({ mergedTable: 1 }).write();

  // --- Cleanup ---
  db.get('mergeRequests').remove({ id: mergeRequest.id }).write(); // Remove by ID

  // --- Emit & Respond ---
  io.emit('order_updated');
  res.status(200).json({ message: 'Merge request approved.' });
});

server.post('/orders/merge-reject', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['cashier', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const { tableId } = req.body;

  if (!tableId) {
    return res.status(400).json({ message: 'tableId is required.' });
  }

  const mergeRequest = db
    .get('mergeRequests')
    .find({ targetTableId: tableId, status: 'pending' })
    .value();

  if (!mergeRequest) {
    return res.status(404).json({ message: 'No pending merge request found for this table.' });
  }

  console.log('Merge Request Found:', mergeRequest);

  // --- 1. Restore 'mergedTable' on the target table ---
  db.get('tables')
    .find({ id: mergeRequest.targetTableId })
    .assign({ mergedTable: mergeRequest.originalMergedTable })
    .write();

  // --- 2. Restore orders ---  SIMPLIFIED!
  const sourceOrder = db.get('orders').find({ tableId: mergeRequest.sourceTableId }).value();
  if (sourceOrder) {
    db.get('orders')
      .find({ tableId: mergeRequest.sourceTableId })
      .assign({
        orderItems: mergeRequest.originalSourceOrderItems,
        totalPrice: getTotalPrice(mergeRequest.originalSourceOrderItems, db),
      })
      .write();
  } else {
    const newSourceOrder = {
      id: mergeRequest.sourceTableId,
      tableId: mergeRequest.sourceTableId,
      timestamp: mergeRequest.requestedAt,
      createdAt: mergeRequest.requestedAt,
      createdBy: mergeRequest.requestedBy,
      orderItems: JSON.parse(JSON.stringify(mergeRequest.originalSourceOrderItems)),
      totalPrice: getTotalPrice(mergeRequest.originalSourceOrderItems, db),
    };
    db.get('orders').push(newSourceOrder).write();
  }

  const targetOrder = db
    .get('orders')
    .find({ id: mergeRequest.originalTargetOrderItems[0]?.orderId })
    .value();
  if (targetOrder) {
    db.get('orders')
      .find({ id: mergeRequest.originalTargetOrderItems[0]?.orderId })
      .assign({
        orderItems: mergeRequest.originalTargetOrderItems,
        totalPrice: getTotalPrice(mergeRequest.originalTargetOrderItems, db),
      })
      .write();
  }

  const sourceOrderData = sourceOrder
    ? {
        id: sourceOrder.id,
        createdAt: sourceOrder.createdAt,
        orderItems: sourceOrder.orderItems.map((item) => ({
          menuItemId: item.menuItemId,
          quantity: item.quantity,
        })),
        totalPrice: sourceOrder.totalPrice,
        servedBy: sourceOrder.servedBy,
        servedAt: sourceOrder.servedAt,
      }
    : null;

  const targetOrderData = targetOrder
    ? {
        id: targetOrder.id,
        createdAt: targetOrder.createdAt,
        orderItems: targetOrder.orderItems.map((item) => ({
          menuItemId: item.menuItemId,
          quantity: item.quantity,
        })),
        totalPrice: targetOrder.totalPrice,
        servedBy: targetOrder.servedBy,
        servedAt: targetOrder.servedAt,
      }
    : null;
  //update table
  if (sourceOrder) {
    db.get('tables')
      .find({ id: mergeRequest.sourceTableId })
      .assign({ order: sourceOrderData })
      .write();
  }
  if (targetOrder) {
    db.get('tables')
      .find({ id: mergeRequest.targetTableId })
      .assign({ order: targetOrderData })
      .write();
  }

  // --- 3. Remove the merge request ---
  db.get('mergeRequests').remove({ id: mergeRequest.id }).write();

  // --- 4. Emit rejection ---
  io.emit('order_updated');
  res.status(200).json({ message: 'Merge request rejected successfully.' });
});

function getTotalPrice(orderItems, db) {
  let totalPrice = 0;
  orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      totalPrice += menuItem.price * item.quantity;
    }
  });

  return parseFloat(totalPrice.toFixed(2));
}
// --- FILE index.js ---
server.post('/orders/split', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['serve', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const { sourceTableId, targetTableId, splitItemIds } = req.body;

  if (!sourceTableId || !targetTableId || !splitItemIds) {
    return res.status(400).json({ message: 'Missing or invalid parameters' });
  }

  const sourceOrder = db.get('orders').find({ tableId: sourceTableId }).value();
  const sourceTable = db.get('tables').find({ id: sourceTableId }).value();

  if (!sourceOrder) {
    return res.status(404).json({ message: 'Source table not found or has no active order' });
  }

  const targetTable = db.get('tables').find({ id: targetTableId }).value();
  if (!targetTable) {
    return res.status(404).json({ message: 'Target table not found' });
  }

  // Target table MUST be empty
  if (targetTable.status !== 'completed') {
    return res.status(400).json({ message: 'Target table is not empty' });
  }

  // Prevent splitting to the same table
  if (sourceTableId === targetTableId) {
    return res.status(400).json({ message: 'Target cannot be the same as the source' });
  }

  // Validate splitItemIds (menuItemId: quantity)
  const validSplitItems = Object.keys(splitItemIds).every((menuItemId) => {
    const quantity = splitItemIds[menuItemId];

    // Skip items with quantity 0
    if (quantity === 0) {
      return true; // Skip, not invalid
    }

    const sourceOrderItems = sourceOrder.orderItems.filter(
      (item) => item.menuItemId === menuItemId,
    );

    if (sourceOrderItems.length === 0) {
      return false; // Item not found
    }

    if (!Number.isInteger(quantity) || quantity < 0) {
      return false; // Invalid quantity
    }

    const totalQuantity = sourceOrderItems.reduce((acc, item) => acc + item.quantity, 0);
    return quantity <= totalQuantity;
  });

  if (!validSplitItems) {
    console.log(4);
    return res.status(400).json({ message: 'One or more split item IDs are invalid' });
  }

  // --- Create a NEW target order ---
  const newTargetOrderId = faker.database.mongodbObjectId();
  const itemsToMove = [];

  // Process splitItemIds
  Object.keys(splitItemIds).forEach((menuItemId) => {
    const quantityToMoveTotal = splitItemIds[menuItemId];
    let quantityMoved = 0;

    const sourceOrderItems = sourceOrder.orderItems.filter(
      (item) => item.menuItemId === menuItemId,
    );

    for (const item of sourceOrderItems) {
      if (quantityMoved >= quantityToMoveTotal) break; // Moved enough

      const quantityToMoveFromThisItem = Math.min(
        item.quantity,
        quantityToMoveTotal - quantityMoved,
      );

      itemsToMove.push({
        ...item, // Copy existing orderItem data
        id: `orderItem-${newTargetOrderId}-${item.menuItemId}`, // New unique ID
        orderId: newTargetOrderId,
        quantity: quantityToMoveFromThisItem,
      });

      quantityMoved += quantityToMoveFromThisItem;
    }
  });

  // Deduct moved quantities from source order
  sourceOrder.orderItems.forEach((item) => {
    const movedItem = itemsToMove.find((moveItem) => moveItem.menuItemId === item.menuItemId);
    if (movedItem) {
      item.quantity -= movedItem.quantity; // Reduce quantity
    }
  });
  sourceOrder.orderItems = sourceOrder.orderItems.filter((item) => item.quantity > 0);

  const newTargetOrder = {
    id: newTargetOrderId,
    tableId: targetTableId,
    timestamp: sourceOrder.timestamp, // Use source order's timestamp
    createdAt: sourceOrder.createdAt, // Use source order's createdAt
    createdBy: sourceOrder.createdBy, // Or use userId
    orderItems: itemsToMove,
  };

  // --- Prepare for potential empty source order ---
  const sourceOrderForHistory = {
    ...sourceOrder, // Copy *before* any further modifications
    completedAt: new Date().toISOString(),
    cashierId: userId,
    totalPrice: sourceOrder.totalPrice, // Capture original price
    paymentMethod: null, // No payment
  };

  // --- Update Database ---
  db.get('orders').push(newTargetOrder).write();
  db.get('orders').find({ id: sourceOrder.id }).assign(sourceOrder).write();
  db.get('tables').find({ id: targetTableId }).assign({ status: 'pending' }).write();

  let sourceTotalPrice = 0;
  sourceOrder.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      sourceTotalPrice += menuItem.price * item.quantity;
    }
  });

  const sourceOrderData = {
    id: sourceOrder.id,
    createdAt: sourceOrder.createdAt,
    orderItems: sourceOrder.orderItems.map((item) => ({
      menuItemId: item.menuItemId,
      quantity: item.quantity,
    })),
    totalPrice: parseFloat(sourceTotalPrice.toFixed(2)),
    servedBy: sourceOrder.servedBy,
    servedAt: sourceOrder.servedAt,
  };

  let targetTotalPrice = 0;
  newTargetOrder.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      targetTotalPrice += menuItem.price * item.quantity;
    }
  });

  const targetOrderData = {
    id: newTargetOrder.id,
    createdAt: newTargetOrder.createdAt,
    orderItems: newTargetOrder.orderItems.map((item) => ({
      menuItemId: item.menuItemId,
      quantity: item.quantity,
    })),
    totalPrice: parseFloat(targetTotalPrice.toFixed(2)),
    servedBy: newTargetOrder.servedBy,
    servedAt: newTargetOrder.servedAt,
  };

  // --- Check and handle empty source order ---
  if (sourceOrder.orderItems.length === 0) {
    // db.get('orderHistory').push(sourceOrderForHistory).write(); // Use the copy!
    db.get('orders').remove({ id: sourceOrder.id }).write();

    db.get('tables')
      .find({ id: sourceTableId })
      .assign({ status: 'completed', order: null })
      .write();
  } else {
    db.get('tables').find({ id: sourceTableId }).assign({ order: sourceOrderData }).write();
  }

  // Target Table
  io.emit('order_updated');

  // --- Response ---
  res.status(200).json({
    message: 'Order split successfully',
    sourceOrder: sourceOrder, // Updated source order
    targetOrder: newTargetOrder, // New target order
  });
});

server.post('/feedback', (req, res) => {
  const db = router.db;
  const newFeedback = {
    ...req.body,
    id: faker.string.uuid(),
    timestamp: new Date().toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  db.get('feedback').push(newFeedback).write();
  res.status(201).json(newFeedback);
});

server.get('/statistics/today', (req, res) => {
  const db = router.db;
  const today = moment().format('YYYY-MM-DD');
  let stats = db.get('statistics').find({ date: today }).value();
  if (!stats) {
    stats = {
      id: `stats-${today}`,
      date: today,
      totalOrders: 0,
      totalRevenue: 0,
      paymentMethodSummary: {},
      ordersByHour: {},
      averageRating: 0,
      totalComments: 0,
      soldItems: {},
    };
  }

  const paymentSummary = {};
  for (const paymentId in stats.paymentMethodSummary) {
    if (stats.paymentMethodSummary.hasOwnProperty(paymentId)) {
      const payment = db.get('payments').find({ id: paymentId }).value();
      if (payment) {
        paymentSummary[payment.name] = {
          name: payment.name,
          count: stats.paymentMethodSummary[paymentId].count,
          totalAmount: stats.paymentMethodSummary[paymentId].totalAmount,
        };
      } else {
        paymentSummary[paymentId] = {
          name: paymentId,
          count: stats.paymentMethodSummary[paymentId].count,
          totalAmount: stats.paymentMethodSummary[paymentId].totalAmount,
        };
      }
    }
  }
  stats = { ...stats, paymentMethodSummary: paymentSummary };

  res.json(stats);
});

server.get('/statistics/this-week', (req, res) => {
  const db = router.db;
  const today = moment();
  const weekStats = [];
  for (let i = 0; i < 6; i++) {
    const date = today.clone().subtract(i, 'days').format('YYYY-MM-DD');
    let stats = db.get('statistics').find({ date: date }).value();
    if (stats) {
      const paymentSummary = {};
      for (const paymentId in stats.paymentMethodSummary) {
        if (stats.paymentMethodSummary.hasOwnProperty(paymentId)) {
          const payment = db.get('payments').find({ id: paymentId }).value();
          if (payment) {
            paymentSummary[payment.name] = {
              name: payment.name,
              count: stats.paymentMethodSummary[paymentId].count,
              totalAmount: stats.paymentMethodSummary[paymentId].totalAmount,
            };
          } else {
            paymentSummary[paymentId] = {
              name: paymentId,
              count: stats.paymentMethodSummary[paymentId].count,
              totalAmount: stats.paymentMethodSummary[paymentId].totalAmount,
            };
          }
        }
      }
      stats = { ...stats, paymentMethodSummary: paymentSummary };
      weekStats.push(stats);
    }
  }
  res.json(weekStats.reverse());
});

server.get('/aggregated-statistics', (req, res) => {
  const db = router.db;
  let monthlyStats = db.get('aggregatedStatistics').value();
  if (!monthlyStats || !Array.isArray(monthlyStats)) {
    return res.json([]);
  }

  const statsWithPaymentNames = monthlyStats.map((stat) => {
    const paymentSummary = {};
    for (const paymentId in stat.paymentMethodSummary) {
      if (stat.paymentMethodSummary.hasOwnProperty(paymentId)) {
        const payment = db.get('payments').find({ id: paymentId }).value();
        if (payment) {
          paymentSummary[payment.name] = {
            name: payment.name,
            count: stat.paymentMethodSummary[paymentId].count,
            totalAmount: stat.paymentMethodSummary[paymentId].totalAmount,
          };
        } else {
          paymentSummary[paymentId] = {
            name: paymentId,
            count: stat.paymentMethodSummary[paymentId].count,
            totalAmount: stat.paymentMethodSummary[paymentId].totalAmount,
          };
        }
      }
    }
    return {
      ...stat,
      paymentMethodSummary: paymentSummary,
    };
  });

  res.json(statsWithPaymentNames);
});

server.post('/categories', (req, res) => {
  const db = router.db;
  const newCategory = {
    ...req.body,
    id: faker.string.uuid(),
    isActive: req.body.isActive === undefined ? true : req.body.isActive,
  };
  const existingCategory = db.get('categories').find({ name: newCategory.name }).value();
  if (existingCategory) {
    return res.status(400).json({ message: 'Category name must be unique.' });
  }

  db.get('categories').push(newCategory).write();
  res.status(201).json(newCategory);
});

server.patch('/categories/:id', (req, res) => {
  const db = router.db;
  const category = db.get('categories').find({ id: req.params.id }).value();
  if (!category) {
    return res.status(404).json({ message: 'Category not found' });
  }

  const updatedCategory = {
    ...category,
    ...req.body,
    id: category.id,
  };

  const existingCategory = db.get('categories').find({ name: updatedCategory.name }).value();
  if (existingCategory && existingCategory.id !== req.params.id) {
    return res.status(400).json({ message: 'Category name must be unique.' });
  }

  db.get('categories').find({ id: req.params.id }).assign(updatedCategory).write();
  res.json(updatedCategory);
});
server.get('/categories', (req, res) => {
  const db = router.db;
  const isActiveFilter = req.query.isActive;
  if (isActiveFilter !== undefined) {
    const isActive = isActiveFilter === 'true';
    const categories = db.get('categories').filter({ isActive }).value();
    res.json(categories);
  } else {
    const categories = db.get('categories').value();
    res.json(categories);
  }
});

server.post('/subCategories', (req, res) => {
  const db = router.db;
  const newSubCategory = {
    ...req.body,
    id: faker.string.uuid(),
    isActive: req.body.isActive === undefined ? true : req.body.isActive,
  };
  const existingSubCategory = db.get('subCategories').find({ name: newSubCategory.name }).value();
  if (existingSubCategory) {
    return res.status(400).json({ message: 'SubCategory name must be unique.' });
  }
  db.get('subCategories').push(newSubCategory).write();
  res.status(201).json(newSubCategory);
});

server.patch('/subCategories/:id', (req, res) => {
  const db = router.db;
  const subCategory = db.get('subCategories').find({ id: req.params.id }).value();
  if (!subCategory) {
    return res.status(404).json({ message: 'SubCategory not found' });
  }
  const updatedSubCategory = {
    ...subCategory,
    ...req.body,
    id: subCategory.id,
  };
  const existingSubCategory = db
    .get('subCategories')
    .find({ name: updatedSubCategory.name })
    .value();
  if (existingSubCategory && existingSubCategory.id !== req.params.id) {
    return res.status(400).json({ message: 'SubCategory name must be unique.' });
  }
  db.get('subCategories').find({ id: req.params.id }).assign(updatedSubCategory).write();
  res.json(updatedSubCategory);
});

server.get('/subCategories', (req, res) => {
  const db = router.db;
  const isActiveFilter = req.query.isActive;
  if (isActiveFilter !== undefined) {
    const isActive = isActiveFilter === 'true';
    const subCategories = db.get('subCategories').filter({ isActive }).value();
    res.json(subCategories);
  } else {
    const subCategories = db.get('subCategories').value();
    res.json(subCategories);
  }
});

server.post('/menuItems', (req, res) => {
  const db = router.db;
  const newMenuItem = {
    ...req.body,
    id: faker.string.uuid(),
    isActive: req.body.isActive === undefined ? true : req.body.isActive,
  };
  const existingMenuItem = db.get('menuItems').find({ name: newMenuItem.name }).value();
  if (existingMenuItem) {
    return res.status(400).json({ message: 'MenuItem name must be unique.' });
  }
  db.get('menuItems').push(newMenuItem).write();
  res.status(201).json(newMenuItem);
});

server.patch('/menuItems/:id', (req, res) => {
  const db = router.db;
  const menuItem = db.get('menuItems').find({ id: req.params.id }).value();
  if (!menuItem) {
    return res.status(404).json({ message: 'MenuItem not found' });
  }
  const updatedMenuItem = {
    ...menuItem,
    ...req.body,
    id: menuItem.id,
  };
  const existingMenuItem = db.get('menuItems').find({ name: updatedMenuItem.name }).value();
  if (existingMenuItem && existingMenuItem.id !== req.params.id) {
    return res.status(400).json({ message: 'MenuItem name must be unique.' });
  }
  db.get('menuItems').find({ id: req.params.id }).assign(updatedMenuItem).write();
  res.json(updatedMenuItem);
});
server.get('/menuItems', (req, res) => {
  const db = router.db;
  const isActiveFilter = req.query.isActive;
  if (isActiveFilter !== undefined) {
    const isActive = isActiveFilter === 'true';
    const menuItems = db.get('menuItems').filter({ isActive }).value();
    res.json(menuItems);
  } else {
    const menuItems = db.get('menuItems').value();
    res.json(menuItems);
  }
});

server.post('/areas', (req, res) => {
  const db = router.db;
  const newArea = {
    ...req.body,
    id: faker.string.uuid(),
    tables: [],
  };

  const existingArea = db.get('areas').find({ name: newArea.name }).value();
  if (existingArea) {
    return res.status(400).json({ message: 'Area name must be unique.' });
  }

  db.get('areas').push(newArea).write();
  res.status(201).json(newArea);
});

server.patch('/areas/:id', (req, res) => {
  const db = router.db;
  const area = db.get('areas').find({ id: req.params.id }).value();
  if (!area) {
    return res.status(404).json({ message: 'Area not found' });
  }

  const updatedArea = {
    ...area,
    ...req.body,
    id: area.id,
  };
  const existingArea = db.get('areas').find({ name: updatedArea.name }).value();
  if (existingArea && existingArea.id !== req.params.id) {
    return res.status(400).json({ message: 'Area name must be unique.' });
  }

  db.get('areas').find({ id: req.params.id }).assign(updatedArea).write();
  res.json(updatedArea);
});

server.post('/tables', (req, res) => {
  const db = router.db;
  const newTable = {
    ...req.body,
    id: faker.string.uuid(),
  };
  const existingTable = db.get('tables').find({ name: newTable.name }).value();
  if (existingTable) {
    return res.status(400).json({ message: 'Table name must be unique.' });
  }
  db.get('tables').push(newTable).write();
  res.status(201).json(newTable);
});

server.patch('/tables/:id', (req, res) => {
  const db = router.db;
  const table = db.get('tables').find({ id: req.params.id }).value();
  if (!table) {
    return res.status(404).json({ message: 'Table not found' });
  }

  const updatedTable = {
    ...table,
    ...req.body,
    id: table.id,
  };
  const existingTable = db.get('tables').find({ name: updatedTable.name }).value();
  if (existingTable && existingTable.id !== req.params.id) {
    return res.status(400).json({ message: 'Table name must be unique.' });
  }
  db.get('tables').find({ id: req.params.id }).assign(updatedTable).write();
  res.json(updatedTable);
});

server.post('/payments', (req, res) => {
  if (!isAdmin(req)) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  const db = router.db;
  const newPayment = {
    ...req.body,
    id: faker.database.mongodbObjectId(),
    isActive: req.body.isActive === undefined ? true : req.body.isActive,
  };

  const existingPayment = db.get('payments').find({ name: newPayment.name }).value();
  if (existingPayment) {
    return res.status(400).json({ message: 'Payment name must be unique.' });
  }

  db.get('payments').push(newPayment).write();
  res.status(201).json(newPayment);
});

server.get('/payments', (req, res) => {
  const db = router.db;
  const isActiveFilter = req.query.isActive;
  if (isActiveFilter !== undefined) {
    const isActive = isActiveFilter === 'true';
    const payments = db.get('payments').filter({ isActive }).value();
    res.json(payments);
  } else {
    const payments = db.get('payments').value();
    res.json(payments);
  }
});

server.patch('/payments/:id', (req, res) => {
  if (!isAdmin(req)) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  const db = router.db;
  const payment = db.get('payments').find({ id: req.params.id }).value();
  if (!payment) {
    return res.status(404).json({ message: 'Payment method not found' });
  }
  const updatedPayment = {
    ...payment,
    ...req.body,
    id: payment.id,
  };

  const existingPayment = db.get('payments').find({ name: updatedPayment.name }).value();
  if (existingPayment && existingPayment.id !== req.params.id) {
    return res.status(400).json({ message: 'Payment name must be unique.' });
  }

  db.get('payments').find({ id: req.params.id }).assign(updatedPayment).write();
  res.json(updatedPayment);
});

server.delete('/payments/:id', (req, res) => {
  if (!isAdmin(req)) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  const db = router.db;
  const payment = db.get('payments').find({ id: req.params.id }).value();
  if (!payment) {
    return res.status(404).json({ message: 'Payment method not found' });
  }
  db.get('statistics')
    .value()
    .forEach((statistic) => {
      if (statistic.paymentMethodSummary && statistic.paymentMethodSummary[req.params.id]) {
        delete statistic.paymentMethodSummary[req.params.id];
        db.get('statistics').find({ id: statistic.id }).assign(statistic).write();
      }
    });

  db.get('aggregatedStatistics')
    .value()
    .forEach((aggregatedStatistic) => {
      if (
        aggregatedStatistic.paymentMethodSummary &&
        aggregatedStatistic.paymentMethodSummary[req.params.id]
      ) {
        delete aggregatedStatistic.paymentMethodSummary[req.params.id];
        db.get('aggregatedStatistics')
          .find({ id: aggregatedStatistic.id })
          .assign(aggregatedStatistic)
          .write();
      }
    });

  db.get('payments').remove({ id: req.params.id }).write();
  res.status(204).send();
});

server.get('/feedback', (req, res) => {
  const db = router.db;
  let { rating, startDate, endDate, page, limit } = req.query;

  const pageNum = parseInt(page) || 1; // Default to page 1
  const perPage = parseInt(limit) || 40; // Default limit
  const startIndex = (pageNum - 1) * perPage;

  rating = rating ? parseInt(rating) : null;
  startDate = startDate ? moment(startDate) : null;
  endDate = endDate ? moment(endDate) : null;

  let feedback = db.get('feedback');

  if (rating) {
    feedback = feedback.filter({ rating });
  }
  if (startDate) {
    feedback = feedback.filter((item) => moment(item.timestamp).isSameOrAfter(startDate));
  }
  if (endDate) {
    endDate = endDate.add(1, 'days');
    feedback = feedback.filter((item) => moment(item.timestamp).isSameOrBefore(endDate));
  }

  feedback = feedback.sortBy('timestamp').value(); // Correct sorting
  feedback.reverse(); // Descending order

  const totalItems = feedback.length;
  const hasMore = startIndex + perPage < totalItems;
  const paginated = feedback.slice(startIndex, startIndex + perPage);

  res.json({ data: paginated, hasMore: hasMore, page: pageNum });
});

server.get('/orderHistory', (req, res) => {
  const db = router.db;
  let { paymentMethod, startDate, endDate, page, limit } = req.query;

  const pageNum = parseInt(page) || 1;
  const perPage = parseInt(limit) || 40;
  const startIndex = (pageNum - 1) * perPage;

  startDate = startDate ? moment(startDate) : null;
  endDate = endDate ? moment(endDate) : null;

  let orderHistory = db.get('orderHistory');

  // Filtering (as before)
  if (paymentMethod) {
    orderHistory = orderHistory.filter({ paymentMethod });
  }
  if (startDate) {
    orderHistory = orderHistory.filter((item) => moment(item.createdAt).isSameOrAfter(startDate));
  }
  if (endDate) {
    orderHistory = orderHistory.filter((item) => moment(item.createdAt).isSameOrBefore(endDate));
  }

  // Sorting (as before)
  orderHistory = orderHistory.sortBy('completedAt').value();
  orderHistory.reverse(); // Descending (newest first)

  // Pagination (now using slice with page and limit)
  const totalItems = orderHistory.length;
  const hasMore = startIndex + perPage < totalItems;
  const paginatedOrders = orderHistory.slice(startIndex, startIndex + perPage);

  // Expand related data (same as before, but cleaner)
  const historyWithItems = paginatedOrders.map((order) => {
    const expandedOrderItems = order.orderItems.map((item) => {
      const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value() || { ...item };
      return { ...item, menuItem };
    });

    const table = db.get('tables').find({ id: order.tableId }).value();
    const tableName = table ? table.name : null;

    const cashier = db.get('users').find({ id: order.cashierId }).value();
    const cashierName = cashier ? cashier.fullname : null;

    const payment = db.get('payments').find({ name: order.paymentMethod }).value(); //or find id
    const paymentInfo = payment
      ? { id: payment.id, name: payment.name }
      : { id: null, name: order.paymentMethod };

    return {
      ...order,
      orderItems: expandedOrderItems,
      tableName: tableName,
      cashierName: cashierName,
      paymentMethod: paymentInfo.name,
    };
  });

  res.json({ data: historyWithItems, hasMore: hasMore, page: pageNum });
});

server.get('/menu', (req, res) => {
  const db = router.db;
  const categories = db.get('categories').value();
  const subCategories = db.get('subCategories').value();
  const menuItems = db.get('menuItems').value();

  return res.json({
    categories,
    subCategories,
    menuItems,
  });
});

server.use(router);

const PORT = 3000;
httpServer.listen(PORT, () => {
  console.log(`JSON Server with Socket.IO is running on port ${PORT}`);
});
