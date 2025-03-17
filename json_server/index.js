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

function updateStatistics(db, order) {
  const today = new Date().toISOString().split('T')[0];
  let stats = db.get('statistics').find({ date: today }).value();
  if (!stats) {
    stats = {
      id: `stats-${today}`,
      date: today,
      totalOrders: 0,
      totalRevenue: 0,
      paymentMethodSummary: { cash: 0, 'online payment': 0 },
      ordersByHour: Array(24).fill(0),
      bestSellingItems: {},
      averageRating: 0,
      totalComments: 0,
    };
    db.get('statistics').push(stats).write();
  }
  stats.totalOrders += 1;
  let orderTotal = 0;
  order.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    orderTotal += menuItem.price * item.quantity;
  });
  stats.totalRevenue += orderTotal;
  stats.paymentMethodSummary[order.paymentMethod] =
    (stats.paymentMethodSummary[order.paymentMethod] || 0) + 1;
  const hour = new Date(order.completedAt).getHours();
  if (!stats.ordersByHour) {
    stats.ordersByHour = Array(24).fill(0);
  }
  stats.ordersByHour[hour] = (stats.ordersByHour[hour] || 0) + 1;
  order.orderItems.forEach((item) => {
    const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
    if (menuItem) {
      const name = menuItem.name;
      stats.bestSellingItems[name] = (stats.bestSellingItems[name] || 0) + item.quantity;
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
      bestSellingItems: {},
    };

    lastMonthStats.forEach((stat) => {
      for (const method in stat.paymentMethodSummary) {
        aggregatedStatsLastMonth.paymentMethodSummary[method] =
          (aggregatedStatsLastMonth.paymentMethodSummary[method] || 0) +
          stat.paymentMethodSummary[method];
      }
      for (const item in stat.bestSellingItems) {
        aggregatedStatsLastMonth.bestSellingItems[item] =
          (aggregatedStatsLastMonth.bestSellingItems[item] || 0) + stat.bestSellingItems[item];
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
      bestSellingItems: {},
    };
    currentMonthStats.forEach((stat) => {
      for (const method in stat.paymentMethodSummary) {
        aggregatedStatsCurrentMonth.paymentMethodSummary[method] =
          (aggregatedStatsCurrentMonth.paymentMethodSummary[method] || 0) +
          stat.paymentMethodSummary[method];
      }
      for (const item in stat.bestSellingItems) {
        aggregatedStatsCurrentMonth.bestSellingItems[item] =
          (aggregatedStatsCurrentMonth.bestSellingItems[item] || 0) + stat.bestSellingItems[item];
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
    res.json({ user: { id: user.id, username: user.username, role: user.role } });
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
    '/areaTables',
    '/tables',
    '/areas-with-tables',
    '/feedback',
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

server.use(['/categories', '/subCategories', '/menuItems'], (req, res, next) => {
  if (req.method !== 'GET' && !isAdmin(req)) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  next();
});

server.use(['/areaTables', '/tables'], (req, res, next) => {
  if (req.method !== 'GET' && !isAdmin(req)) {
    return res.status(403).json({ message: 'Forbidden' });
  }
  next();
});

// --- Areas with Tables (Enhanced) ---
server.get('/areas-with-tables', (req, res) => {
  const db = router.db;
  const areas = db.get('areaTables').value();

  const areasWithTables = areas.map((area) => {
    const tables = db
      .get('tables')
      .filter({ areaId: area.id })
      .value()
      .map((table) => {
        const currentOrder = db
          .get('orders')
          .find({ tableId: table.id, orderStatus: { $ne: 'completed' } })
          .value(); // Find non-completed

        let orderData = null;
        if (currentOrder) {
          let orderTotal = 0;
          currentOrder.orderItems.forEach((item) => {
            const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
            if (menuItem) {
              orderTotal += menuItem.price * item.quantity;
            }
          });

          orderData = {
            id: currentOrder.id,
            // Include essential order details.  Crucially, createdAt is here.
            createdAt: currentOrder.createdAt,
            orderItems: currentOrder.orderItems.map((item) => ({
              menuItemId: item.menuItemId,
              quantity: item.quantity,
            })),
            totalPrice: parseFloat(orderTotal.toFixed(2)),
            //Include more if need
          };
        }

        return {
          ...table,
          order: orderData, // This is the embedded order (or null)
        };
      });

    return {
      ...area,
      tables: tables,
    };
  });

  res.json(areasWithTables);
});

// --- Orders ---
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

  // --- Simplified Check and Aggregation ---
  const existingOrder = db
    .get('orders')
    .find({ tableId: newOrder.tableId }) // Removed id check
    .value();

  const aggregatedOrderItems = [];
  const itemMap = new Map();

  // Add existing order items to the map *if* an order exists
  if (existingOrder) {
    existingOrder.orderItems.forEach((item) => {
      itemMap.set(item.menuItemId, item.quantity);
    });
  }

  // Aggregate quantities from the *current* request
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

  // --- Simplified Create/Update ---
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
    // Update existing order
    db.get('orders')
      .find({ id: existingOrder.id })
      .assign({ ...existingOrder, ...newOrder, id: existingOrder.id })
      .write();
    newOrder.id = existingOrder.id; // Keep the original ID for the response.
  } else {
    // Create new order
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

  io.emit('order_created', newOrder); // Keep 'order_created' for simplicity
  io.emit('table_status_updated', {
    tableId: newOrder.tableId,
    status: 'pending',
    order: orderData,
  });
  res.status(201).json(newOrder);
});

// Get today's orders - Filter by table status
server.get('/orders', (req, res) => {
  const db = router.db;
  const today = moment().startOf('day').toISOString();
  const orders = db
    .get('orders')
    .filter((order) => {
      const table = db.get('tables').find({ id: order.tableId }).value();
      return moment(order.timestamp).isSameOrAfter(today) && table && table.status !== 'completed';
    })
    .value();
  res.json(orders);
});

// Update order (Serve and Complete)
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
  const updatedOrder = req.body; // In this case, sent table status

  if (hasRole(req, ['serve', 'admin']) && updatedOrder.status === 'served') {
    order.servedBy = userId;
    order.servedAt = new Date().toISOString();

    // --- Calculate total price ---
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
      servedBy: order.servedBy, // Include
      servedAt: order.servedAt,
    };

    // --- Update table: status AND the embedded order ---
    db.get('tables')
      .find({ id: order.tableId })
      .assign({ status: 'served', order: orderData }) // Update the order
      .write();
    db.get('orders').find({ id: req.params.id }).assign(order).write(); // Important: Also update the actual order!

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
      paymentMethod: updatedOrder.paymentMethod, // Include paymentMethod
    };

    db.get('orderHistory').push(completedOrder).write();
    db.get('orders').remove({ id: req.params.id }).write();

    db.get('tables')
      .find({ id: completedOrder.tableId })
      .assign({ status: 'completed', order: null }) // Set order to null
      .write();
    updateStatistics(db, completedOrder);
    performMonthlyRollover();

    io.emit('order_completed', completedOrder);
    io.emit('table_status_updated', {
      tableId: completedOrder.tableId,
      status: 'completed',
      order: null,
    }); // order: null

    return res.json(completedOrder);
  } else {
    return res.status(403).json({ message: 'Forbidden' });
  }
});

// --- Merge Orders ---
server.post('/orders/merge-request', (req, res) => {
  const db = router.db;
  const userId = req.headers.userid;

  if (!hasRole(req, ['serve', 'admin'])) {
    return res.status(403).json({ message: 'Forbidden' });
  }

  const { sourceTableId, targetTableId, splitItemIds } = req.body; // Include splitItemIds

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
    splitItemIds, // Store the selected item IDs
    status: 'pending',
    requestedBy: userId,
    requestedAt: new Date().toISOString(),
  };

  db.get('mergeRequests').push(mergeRequest).write();

  const currentMergedTableCount = targetTable.mergedTable || 1;
  db.get('tables')
    .find({ id: targetTableId })
    .assign({ mergedTable: currentMergedTableCount + 1 })
    .write(); // Only increment mergedTable

  io.emit('merge_request_created', mergeRequest);
  // No table_status_updated for target table

  res.status(201).json(mergeRequest);
});

// Endpoint for approving a merge (Cashier)
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

  // Find orders
  const sourceOrder = db.get('orders').find({ tableId: mergeRequest.sourceTableId }).value();
  let targetOrder = db.get('orders').find({ tableId: mergeRequest.targetTableId }).value(); // Make targetOrder mutable
  const sourceTable = db.get('tables').find({ id: mergeRequest.sourceTableId }).value();
  const targetTable = db.get('tables').find({ id: mergeRequest.targetTableId }).value();

  if (sourceOrder) {
    // Only proceed if sourceOrder exists
    // Filter out the items to be moved
    const itemsToMove = sourceOrder.orderItems.filter((item) =>
      mergeRequest.splitItemIds.includes(item.id),
    );

    // Remove items from the source order
    sourceOrder.orderItems = sourceOrder.orderItems.filter(
      (item) => !mergeRequest.splitItemIds.includes(item.id),
    );

    if (targetOrder) {
      // Add the items to the target order with updated orderId
      targetOrder.orderItems = [
        ...targetOrder.orderItems,
        ...itemsToMove.map((item) => ({
          ...item,
          orderId: targetOrder.id,
          id: `orderItem-${targetOrder.id}-${item.menuItemId}`,
        })),
      ];
    } else {
      //If target not have any order
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

      // Update table status and totalPrice
      db.get('tables')
        .find({ id: targetOrder.tableId })
        .assign({ status: 'pending' }) // Assign the order
        .write();
    }

    // Save changes to both orders
    db.get('orders').find({ id: sourceOrder.id }).assign(sourceOrder).write();
    db.get('orders').find({ id: targetOrder.id }).assign(targetOrder).write();

    io.emit('order_updated', sourceOrder); // Emit for both
    io.emit('order_updated', targetOrder);
  }

  // --- Calculate total price ---
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
    servedBy: sourceOrder.servedBy, // Include
    servedAt: sourceOrder.servedAt,
  };

  // --- Calculate total price ---
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
    servedBy: targetOrder.servedBy, // Include
    servedAt: targetOrder.servedAt,
  };

  //Decrese merge table
  db.get('tables')
    .find({ id: mergeRequest.targetTableId })
    .assign({ mergedTable: targetTable.mergedTable > 1 ? targetTable.mergedTable - 1 : 1 })
    .write();
  // Remove merge request
  db.get('mergeRequests').remove({ id: mergeRequestId }).write();

  // Update table status, if source order item = 0, set to complete
  if (sourceOrder && sourceOrder.orderItems.length === 0) {
    //No have any order item, should move it to history
    db.get('orderHistory')
      .push({
        ...sourceOrder, // Copy existing order data
        completedAt: new Date().toISOString(),
        cashierId: userId,
        totalPrice: sourceTotalPrice,
        paymentMethod: null, // Since it's a merge, payment method not apply direct
      })
      .write();
    db.get('orders').remove({ id: sourceOrder.id }).write(); //remove it
    db.get('tables')
      .find({ id: mergeRequest.sourceTableId })
      .assign({ status: 'completed', order: null }) //Set null for order
      .write();
    io.emit('table_status_updated', {
      tableId: mergeRequest.sourceTableId,
      status: 'completed',
      order: null, // Send null since the order is removed
    });
  } else {
    db.get('tables')
      .find({ id: mergeRequest.sourceTableId })
      .assign({ order: sourceOrderData })
      .write();
  }

  //If source table status is served, target should served
  if (sourceTable.status == 'served') {
    db.get('tables')
      .find({ id: mergeRequest.targetTableId })
      .assign({ status: 'served', order: targetOrderData }) // Update the order
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

// --- Split Order ---
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

    db.get('tables').find({ id: targetTableId }).assign({ status: 'pending' }).write(); //Set pending
    io.emit('table_status_updated', { tableId: targetTableId, status: 'pending' }); //new table is pending
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

  // --- Calculate total price ---
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
    servedBy: sourceOrder.servedBy, // Include
    servedAt: sourceOrder.servedAt,
  };

  // --- Calculate total price ---
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
    servedBy: targetOrder.servedBy, // Include
    servedAt: targetOrder.servedAt,
  };

  db.get('tables').find({ id: sourceTableId }).assign({ order: sourceOrderData }).write(); //Update source
  db.get('tables').find({ id: targetTableId }).assign({ order: targetOrderData }).write(); // Update target

  io.emit('order_updated', sourceOrder);
  io.emit('order_updated', targetOrder);
  io.emit('order_splitted', {
    // new event for split
    sourceTableId,
    targetTableId,
  });

  //If source after split no order item, it should move to history, set status to complete
  if (sourceOrder.orderItems.length === 0) {
    //No have any order item, should move it to history
    db.get('orderHistory')
      .push({
        ...sourceOrder, // Copy existing order data
        completedAt: new Date().toISOString(),
        cashierId: userId, // Could be null if not applicable
        totalPrice: sourceTotalPrice,
        paymentMethod: null, //Payment method not apply direct
      })
      .write();
    db.get('orders').remove({ id: sourceOrder.id }).write(); //remove it
    db.get('tables')
      .find({ id: sourceOrder.tableId }) // Corrected: Use sourceTableId
      .assign({ status: 'completed', order: null }) //remove order
      .write();
    io.emit('table_status_updated', {
      tableId: sourceOrder.tableId, // Corrected: Use sourceTableId
      status: 'completed',
      order: null, //set order to null
    });
  }

  res.status(200).json({
    message: 'Order split successfully',
    sourceOrder: sourceOrder,
    targetOrder: targetOrder,
  });
});

server.post('/feedback', (req, res) => {
  const db = router.db;
  const newFeedback = {
    ...req.body,
    id: faker.datatype.uuid(),
    timestamp: new Date().toISOString(),
    createdAt: new Date().toISOString(),
    updatedAt: new Date().toISOString(),
  };
  db.get('feedback').push(newFeedback).write();
  res.status(201).json(newFeedback);
});

server.get('/statistics', (req, res) => {
  const db = router.db;
  const currentMonth = moment().format('YYYY-MM');
  const stats = db
    .get('statistics')
    .filter((stat) => moment(stat.date).format('YYYY-MM') === currentMonth)
    .value();
  res.json(stats);
});

server.get('/statistics/today', (req, res) => {
  const db = router.db;
  const today = moment().format('YYYY-MM-DD');
  const stats = db.get('statistics').find({ date: today }).value();
  if (!stats) {
    return res.status(404).json({ message: 'Statistics not found for today.' });
  }
  res.json(stats);
});

server.get('/statistics/this-week', (req, res) => {
  const db = router.db;
  const today = moment();
  const weekStats = [];
  for (let i = 0; i < 7; i++) {
    const date = today.clone().subtract(i, 'days').format('YYYY-MM-DD');
    const stats = db.get('statistics').find({ date: date }).value();
    if (stats) {
      weekStats.push(stats);
    }
  }
  res.json(weekStats);
});

server.get('/aggregatedStatistics', (req, res) => {
  const db = router.db;
  const monthlyStats = db.get('aggregatedStatistics').value();
  if (!monthlyStats || !Array.isArray(monthlyStats)) {
    return res.json([]);
  }
  res.json(monthlyStats);
});

// --- index.js continued ---
server.get('/statisticsYears', (req, res) => {
  const db = router.db;
  const monthlyStats = db.get('aggregatedStatistics').value();
  if (!monthlyStats || monthlyStats.length === 0) {
    return res.json([]); // Return an empty array for consistency
  }
  const yearlyData = {};

  monthlyStats.forEach((month) => {
    if (month.month != null) {
      const year = month.year.toString();
      if (!yearlyData[year]) {
        yearlyData[year] = {
          id: year,
          year: parseInt(year),
          month: null, // To match AggregatedStatisticsModel structure
          totalOrders: 0,
          totalRevenue: 0,
          paymentMethodSummary: {},
          averageRating: [], // Store as an array to calculate later
          totalComments: 0,
          bestSellingItems: {},
        };
      }
      yearlyData[year].totalOrders += month.totalOrders;
      yearlyData[year].totalRevenue += month.totalRevenue;
      yearlyData[year].totalComments += month.totalComments;
      // Aggregate payment methods
      for (const method in month.paymentMethodSummary) {
        yearlyData[year].paymentMethodSummary[method] =
          (yearlyData[year].paymentMethodSummary[method] || 0) + month.paymentMethodSummary[method];
      }

      // Aggregate best selling items
      for (const item in month.bestSellingItems) {
        yearlyData[year].bestSellingItems[item] =
          (yearlyData[year].bestSellingItems[item] || 0) + month.bestSellingItems[item];
      }
      // Push to an array to calculate
      if (month.averageRating > 0) {
        yearlyData[year].averageRating.push(month.averageRating);
      }
    }
  });

  // Calculate the average rating for each year.
  for (const year in yearlyData) {
    if (yearlyData[year].averageRating.length > 0) {
      const sum = yearlyData[year].averageRating.reduce((a, b) => a + b, 0);
      yearlyData[year].averageRating = parseFloat(
        (sum / yearlyData[year].averageRating.length).toFixed(1),
      );
    } else {
      yearlyData[year].averageRating = 0; // Default to 0 if no ratings
    }
  }

  const yearlyArray = Object.values(yearlyData);
  res.json(yearlyArray);
});

server.get('/orderHistory', (req, res) => {
  const db = router.db;
  const orderHistory = db.get('orderHistory').value();

  const historyWithItems = orderHistory.map((order) => {
    // --- Expand orderItems to include menuItem details ---
    const expandedOrderItems = order.orderItems.map((item) => {
      const menuItem = db.get('menuItems').find({ id: item.menuItemId }).value();
      if (!menuItem) {
        return { ...item }; // Return original item if menu item is missing
      }
      return {
        ...item,
        menuItem: menuItem, // Add the full menuItem object
      };
    });

    // --- Get table information ---
    const table = db.get('tables').find({ id: order.tableId }).value();
    const tableInfo = table
      ? { id: table.id, tableName: table.tableName, areaId: table.areaId }
      : null;

    return {
      ...order,
      orderItems: expandedOrderItems, // Use the expanded order items
      table: tableInfo, //Add table info
    };
  });

  res.json(historyWithItems);
});
// --- Default Routes (CRUD) ---
server.use(router);

// Start the HTTP server (which includes Socket.IO)
const PORT = 3000;
httpServer.listen(PORT, () => {
  console.log(`JSON Server with Socket.IO is running on port ${PORT}`);
});
