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
  const newOrder = req.body;

  const table = db.get('tables').find({ id: newOrder.tableId }).value();
  if (!table) {
    return res.status(400).json({ message: 'Invalid table ID' });
  }

  const existingOrder = db.get('orders').find({ tableId: newOrder.tableId }).value();

  const aggregatedOrderItems = [];
  const itemMap = new Map();

  if (existingOrder) {
    existingOrder.orderItems.forEach((item) => {
      itemMap.set(item.menuItemId, item.quantity);
    });
  }

  for (const item of newOrder.orderItems) {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (!menuItem) {
      return res.status(400).json({ message: `Invalid menu item ID: ${item.menuItemId}` });
    }

    if (itemMap.has(item.menuItemId)) {
      itemMap.set(item.menuItemId, itemMap.get(item.menuItemId) + item.quantity);
    } else {
      itemMap.set(item.menuItemId, item.quantity);
    }
  }

  itemMap.forEach((quantity, menuItemId) => {
    aggregatedOrderItems.push({
      menuItemId: menuItemId,
      quantity: quantity,
    });
  });

  newOrder.id = faker.database.mongodbObjectId();
  newOrder.timestamp = new Date().toISOString();
  newOrder.createdBy = userId;
  newOrder.createdAt = new Date().toISOString();
  newOrder.orderItems = aggregatedOrderItems.map((item) => ({
    ...item,
    id: `orderItem-${newOrder.id}-${item.menuItemId}`,
    orderId: newOrder.id,
  }));

  let totalPrice = 0;
  newOrder.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      totalPrice += menuItem.price * item.quantity;
    }
  });

  if (existingOrder) {
    db.get('orders')
      .find({ id: existingOrder.id })
      .assign({ ...existingOrder, ...newOrder, id: existingOrder.id })
      .write();
    newOrder.id = existingOrder.id;
  } else {
    db.get('orders').push(newOrder).write();
  }

  const orderData = {
    id: newOrder.id,
    createdAt: newOrder.createdAt,
    orderItems: newOrder.orderItems.map((item) => ({
      menuItemId: item.menuItemId,
      quantity: item.quantity,
    })),
    totalPrice: parseFloat(totalPrice.toFixed(2)),
  };

  db.get('tables')
    .find({ id: newOrder.tableId })
    .assign({ status: 'pending', order: orderData })
    .write();

  io.emit('order_created', newOrder);
  io.emit('table_status_updated', {
    tableId: newOrder.tableId,
    status: 'pending',
    order: orderData,
  });
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

  if (hasRole(req, ['serve', 'admin']) && updatedOrder.status === 'served') {
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

    io.emit('order_updated', order);
    io.emit('table_status_updated', { tableId: order.tableId, status: 'served', order: orderData });

    return res.json(order);
  } else if (hasRole(req, ['cashier', 'admin']) && updatedOrder.status === 'completed') {
    if (
      !updatedOrder.paymentMethod ||
      !['cash', 'online payment'].includes(updatedOrder.paymentMethod)
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

    io.emit('order_completed', completedOrder);
    io.emit('table_status_updated', {
      tableId: completedOrder.tableId,
      status: 'completed',
      order: null,
    });

    return res.json(completedOrder);
  } else {
    return res.status(403).json({ message: 'Forbidden' });
  }
});

server.post('/orders/merge-request', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['serve', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const { sourceTableId, targetTableId, splitItemIds } = req.body;

  if (!sourceTableId || !targetTableId || !splitItemIds) {
    return res.status(400).json({
      message: 'sourceTableId, targetTableId, and splitItemIds are required.',
    });
  }

  const sourceTable = db.get('tables').find({ id: sourceTableId }).value();
  const targetTable = db.get('tables').find({ id: targetTableId }).value();

  if (!sourceTable || !targetTable) {
    return res.status(404).json({ message: 'One or both tables not found.' });
  }
  const existingRequest = db
    .get('mergeRequests')
    .find({
      $or: [
        { sourceTableId: sourceTableId, targetTableId: targetTableId },
        { sourceTableId: targetTableId, targetTableId: sourceTableId },
      ],
    })
    .value();
  if (existingRequest) {
    return res.status(409).json({ message: 'A merge request already exists for these tables.' });
  }

  const mergeRequest = {
    id: faker.database.mongodbObjectId(),
    sourceTableId,
    targetTableId,
    splitItemIds,
    status: 'pending',
    requestedBy: userId,
    requestedAt: new Date().toISOString(),
  };

  db.get('mergeRequests').push(mergeRequest).write();

  const currentMergedTableCount = targetTable.mergedTable || 1;
  db.get('tables')
    .find({ id: targetTableId })
    .assign({ mergedTable: currentMergedTableCount + 1 })
    .write();

  io.emit('merge_request_created', mergeRequest);

  res.status(201).json(mergeRequest);
});

server.post('/orders/merge-approve', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['cashier', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const { mergeRequestId } = req.body;

  if (!mergeRequestId) {
    return res.status(400).json({ message: 'mergeRequestId is required.' });
  }

  const mergeRequest = db.get('mergeRequests').find({ id: mergeRequestId }).value();

  if (!mergeRequest) {
    return res.status(404).json({ message: 'Merge request not found.' });
  }

  if (mergeRequest.status !== 'pending') {
    return res.status(400).json({ message: 'Merge request is not pending.' });
  }

  const sourceOrder = db.get('orders').find({ tableId: mergeRequest.sourceTableId }).value();
  let targetOrder = db.get('orders').find({ tableId: mergeRequest.targetTableId }).value();
  const sourceTable = db.get('tables').find({ id: mergeRequest.sourceTableId }).value();
  const targetTable = db.get('tables').find({ id: mergeRequest.targetTableId }).value();

  if (sourceOrder) {
    const itemsToMove = sourceOrder.orderItems.filter((item) =>
      mergeRequest.splitItemIds.includes(item.id),
    );

    sourceOrder.orderItems = sourceOrder.orderItems.filter(
      (item) => !mergeRequest.splitItemIds.includes(item.id),
    );

    if (targetOrder) {
      targetOrder.orderItems = [
        ...targetOrder.orderItems,
        ...itemsToMove.map((item) => ({
          ...item,
          orderId: targetOrder.id,
          id: `orderItem-${targetOrder.id}-${item.menuItemId}`,
        })),
      ];
    } else {
      targetOrder = {
        id: faker.database.mongodbObjectId(),
        tableId: mergeRequest.targetTableId,
        timestamp: new Date().toISOString(),
        orderItems: [
          ...itemsToMove.map((item) => ({
            ...item,
            orderId: faker.database.mongodbObjectId(),
            id: `orderItem-${faker.database.mongodbObjectId()}-${item.menuItemId}`,
          })),
        ],
        createdBy: userId,
        createdAt: new Date().toISOString(),
      };
      db.get('orders').push(targetOrder).write();

      db.get('tables').find({ id: targetOrder.tableId }).assign({ status: 'pending' }).write();
    }

    db.get('orders').find({ id: sourceOrder.id }).assign(sourceOrder).write();
    db.get('orders').find({ id: targetOrder.id }).assign(targetOrder).write();

    io.emit('order_updated', sourceOrder);
    io.emit('order_updated', targetOrder);
  }

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
  targetOrder.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      targetTotalPrice += menuItem.price * item.quantity;
    }
  });

  const targetOrderData = {
    id: targetOrder.id,
    createdAt: targetOrder.createdAt,
    orderItems: targetOrder.orderItems.map((item) => ({
      menuItemId: item.menuItemId,
      quantity: item.quantity,
    })),
    totalPrice: parseFloat(targetTotalPrice.toFixed(2)),
    servedBy: targetOrder.servedBy,
    servedAt: targetOrder.servedAt,
  };

  db.get('tables')
    .find({ id: mergeRequest.targetTableId })
    .assign({ mergedTable: targetTable.mergedTable > 1 ? targetTable.mergedTable - 1 : 1 })
    .write();
  db.get('mergeRequests').remove({ id: mergeRequestId }).write();

  if (sourceOrder && sourceOrder.orderItems.length === 0) {
    db.get('orderHistory')
      .push({
        ...sourceOrder,
        completedAt: new Date().toISOString(),
        cashierId: userId,
        totalPrice: sourceTotalPrice,
        paymentMethod: null,
      })
      .write();
    db.get('orders').remove({ id: sourceOrder.id }).write();
    db.get('tables')
      .find({ id: mergeRequest.sourceTableId })
      .assign({ status: 'completed', order: null })
      .write();
    io.emit('table_status_updated', {
      tableId: mergeRequest.sourceTableId,
      status: 'completed',
      order: null,
    });
  } else {
    db.get('tables')
      .find({ id: mergeRequest.sourceTableId })
      .assign({ order: sourceOrderData })
      .write();
  }

  if (sourceTable.status == 'served') {
    db.get('tables')
      .find({ id: mergeRequest.targetTableId })
      .assign({ status: 'served', order: targetOrderData })
      .write();
    io.emit('table_status_updated', {
      tableId: mergeRequest.targetTableId,
      status: 'served',
      order: targetOrderData,
    });
  } else {
    db.get('tables')
      .find({ id: mergeRequest.targetTableId })
      .assign({ order: targetOrderData })
      .write();
  }
  io.emit('merge_request_approved', {
    sourceTableId: sourceTable.id,
    targetTableId: targetTable.id,
  });
  res.status(200).json({ message: 'Orders merged successfully.' });
});

server.post('/orders/split', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['serve', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  const { sourceTableId, targetTableId, splitItemIds } = req.body;
  if (!sourceTableId || !targetTableId || !splitItemIds || !Array.isArray(splitItemIds)) {
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

  const sourceOrderItems = sourceOrder.orderItems;
  const validSplitItems = splitItemIds.every((itemId) =>
    sourceOrderItems.some((item) => item.id === itemId),
  );

  if (!validSplitItems) {
    return res.status(400).json({ message: 'One or more split item IDs are invalid' });
  }

  if (sourceTableId === targetTableId) {
    return res.status(400).json({ message: 'Target can not the same Source' });
  }

  let targetOrder = db.get('orders').find({ tableId: targetTableId }).value();

  const newOrderId = faker.database.mongodbObjectId();
  if (!targetOrder) {
    targetOrder = {
      id: newOrderId,
      tableId: targetTableId,
      timestamp: new Date().toISOString(),
      orderItems: [],
      createdBy: userId,
      createdAt: new Date().toISOString(),
    };
    db.get('orders').push(targetOrder).write();

    db.get('tables').find({ id: targetTableId }).assign({ status: 'pending' }).write();
    io.emit('table_status_updated', { tableId: targetTableId, status: 'pending' });
  }

  const itemsToMove = sourceOrder.orderItems.filter((item) => splitItemIds.includes(item.id));

  sourceOrder.orderItems = sourceOrder.orderItems.filter((item) => !splitItemIds.includes(item.id));

  targetOrder.orderItems = [
    ...targetOrder.orderItems,
    ...itemsToMove.map((item) => ({
      ...item,
      orderId: targetOrder.id,
      id: `orderItem-${targetOrder.id}-${item.menuItemId}`,
    })),
  ];

  db.get('orders').find({ id: sourceOrder.id }).assign(sourceOrder).write();
  db.get('orders').find({ id: targetOrder.id }).assign(targetOrder).write();

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
  targetOrder.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      targetTotalPrice += menuItem.price * item.quantity;
    }
  });

  const targetOrderData = {
    id: targetOrder.id,
    createdAt: targetOrder.createdAt,
    orderItems: targetOrder.orderItems.map((item) => ({
      menuItemId: item.menuItemId,
      quantity: item.quantity,
    })),
    totalPrice: parseFloat(targetTotalPrice.toFixed(2)),
    servedBy: targetOrder.servedBy,
    servedAt: targetOrder.servedAt,
  };

  db.get('tables').find({ id: sourceTableId }).assign({ order: sourceOrderData }).write();
  db.get('tables').find({ id: targetTableId }).assign({ order: targetOrderData }).write();

  io.emit('order_updated', sourceOrder);
  io.emit('order_updated', targetOrder);
  io.emit('order_splitted', {
    sourceTableId,
    targetTableId,
  });

  if (sourceOrder.orderItems.length === 0) {
    db.get('orderHistory')
      .push({
        ...sourceOrder,
        completedAt: new Date().toISOString(),
        cashierId: userId,
        totalPrice: sourceTotalPrice,
        paymentMethod: null,
      })
      .write();
    db.get('orders').remove({ id: sourceOrder.id }).write();
    db.get('tables')
      .find({ id: sourceOrder.tableId })
      .assign({ status: 'completed', order: null })
      .write();
    io.emit('table_status_updated', {
      tableId: sourceOrder.tableId,
      status: 'completed',
      order: null,
    });
  }

  res.status(200).json({
    message: 'Order split successfully',
    sourceOrder: sourceOrder,
    targetOrder: targetOrder,
  });
});

server.post('/orders/merge-reject', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['cashier', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const { mergeRequestId } = req.body;

  if (!mergeRequestId) {
    return res.status(400).json({ message: 'mergeRequestId is required.' });
  }

  const mergeRequest = db.get('mergeRequests').find({ id: mergeRequestId }).value();

  if (!mergeRequest) {
    return res.status(404).json({ message: 'Merge request not found.' });
  }

  if (mergeRequest.status !== 'pending') {
    return res.status(400).json({ message: 'Merge request is not pending.' });
  }
  const targetTable = db.get('tables').find({ id: mergeRequest.targetTableId }).value();
  db.get('tables')
    .find({ id: mergeRequest.targetTableId })
    .assign({ mergedTable: targetTable.mergedTable > 1 ? targetTable.mergedTable - 1 : 1 })
    .write();

  db.get('mergeRequests').remove({ id: mergeRequestId }).write();
  io.emit('merge_request_rejected', { mergeRequestId });

  res.status(200).json({ message: 'Merge request rejected.' });
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
    const cashierName = cashier ? cashier.username : null;

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
