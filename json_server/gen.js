// --- FILE gen.js ---
const { faker } = require('@faker-js/faker');
const fs = require('fs');

function generateData() {
  const data = {
    users: [],
    categories: [],
    subCategories: [],
    menuItems: [],
    areas: [],
    tables: [],
    orders: [],
    orderHistory: [],
    mergeRequests: [],
    feedback: [],
    statistics: [],
    aggregatedStatistics: [],
    payments: [],
  };

  data.users = [
    {
      id: 'user1',
      username: 'admin1',
      fullname: 'Admin User',
      role: 'admin',
      password: '123456',
      email: faker.internet.email(),
      phoneNumber: faker.phone.number(),
      isActive: true,
      createdAt: faker.date.past().toISOString(),
      updatedAt: faker.date.recent().toISOString(),
    },
    {
      id: 'user2',
      username: 'cashier',
      fullname: 'Cashier User',
      role: 'cashier',
      password: '123456',
      email: faker.internet.email(),
      phoneNumber: faker.phone.number(),
      isActive: true,
      createdAt: faker.date.past().toISOString(),
      updatedAt: faker.date.recent().toISOString(),
    },
    {
      id: 'user3',
      username: 'server',
      fullname: 'Server User',
      role: 'serve',
      password: '123456',
      email: faker.internet.email(),
      phoneNumber: faker.phone.number(),
      isActive: true,
      createdAt: faker.date.past().toISOString(),
      updatedAt: faker.date.recent().toISOString(),
    },
  ];

  data.categories = [
    { id: 'cat1', name: 'Drinks', isActive: true },
    { id: 'cat2', name: 'Food', isActive: true },
  ];

  const drinkSubCategories = ['Coffee', 'Tea', 'Juice', 'Smoothies', 'Soft Drinks', 'Water'];
  const foodSubCategories = ['Pastries', 'Sandwiches', 'Salads', 'Soups', 'Snacks', 'Desserts'];
  let subCategoryId = 1;
  let menuItemId = 1;

  [...drinkSubCategories, ...foodSubCategories].forEach((subCategoryName) => {
    const items = Array.from({ length: faker.number.int({ min: 3, max: 7 }) }, () =>
      String(menuItemId++),
    );
    data.subCategories.push({
      id: String(subCategoryId++),
      name: subCategoryName,
      category: drinkSubCategories.includes(subCategoryName) ? 'cat1' : 'cat2',
      items,
      isActive: true,
    });
  });

  for (let i = 1; i < menuItemId; i++) {
    const subCategory = data.subCategories.find((sc) => sc.items.includes(String(i)));
    if (subCategory) {
      data.menuItems.push({
        id: String(i),
        name: faker.commerce.productName(),
        price: parseFloat(faker.commerce.price({ min: 2, max: 20, dec: 2 })),
        subCategory: subCategory.id,
        isActive: true,
      });
    }
  }

  const areas = ['Main Room', 'Patio', 'Bar', 'Garden', 'VIP Lounge'];
  let tableId = 1;
  areas.forEach((areaName, areaIndex) => {
    const tableIds = Array.from({ length: faker.number.int({ min: 15, max: 25 }) }, () =>
      String(tableId++),
    );
    data.areas.push({ id: String(areaIndex + 1), name: areaName, tables: tableIds });
  });

  data.tables = Array.from({ length: tableId - 1 }, (_, i) => {
    const area = data.areas.find((a) => a.tables.includes(String(i + 1)));
    return {
      id: String(i + 1),
      name: `${area.name.replace(/\s+/g, '')}${i + 1}`,
      status: 'completed',
      areaId: area.id,
      mergedTable: 1,
    };
  });

  const paymentMethods = ['cash', 'online payment', 'Credit Card', 'Debit Card', 'Gift Card'];
  paymentMethods.forEach((paymentMethodName) => {
    data.payments.push({
      id: faker.database.mongodbObjectId(),
      name: paymentMethodName,
      isActive: true,
    });
  });

  let orderIdCounter = 1;
  const now = new Date();
  const twoDaysAgo = new Date(now);
  twoDaysAgo.setDate(now.getDate() - 2);

  for (let i = 0; i < 50; i++) {
    const tableIdForOrder = String(faker.number.int({ min: 1, max: tableId - 1 }));
    const table = data.tables.find((t) => t.id === tableIdForOrder);
    if (!table) continue;

    const orderItems = Array.from({ length: faker.number.int({ min: 1, max: 6 }) }, () => {
      const randomMenuItemId = String(faker.number.int({ min: 1, max: menuItemId - 1 }));
      const menuItem = data.menuItems.find((item) => item.id === randomMenuItemId);
      if (!menuItem) return null;

      return {
        id: `orderItem-${orderIdCounter}-${faker.string.uuid()}`,
        orderId: `order${orderIdCounter}`,
        menuItemId: randomMenuItemId,
        quantity: faker.number.int({ min: 1, max: 4 }),
        price: menuItem.price,
      };
    }).filter((item) => item !== null);

    if (orderItems.length === 0) continue;

    let totalPrice = orderItems.reduce((sum, item) => {
      const menuItem = data.menuItems.find((mi) => mi.id === item.menuItemId);
      return sum + (menuItem ? menuItem.price * item.quantity : 0);
    }, 0);

    const orderFate = faker.helpers.arrayElement(['pending', 'served', 'history']);
    let servedBy = null;
    let servedAt = null;
    let createdBy = faker.helpers.arrayElement(
      data.users.filter((u) => u.role === 'serve').map((u) => u.id),
    );
    let timestamp = faker.date.between({ from: twoDaysAgo, to: now });

    if (orderFate === 'served') {
      servedBy = faker.helpers.arrayElement(
        data.users.filter((u) => u.role === 'serve').map((u) => u.id),
      );
      servedAt = faker.date.between({ from: twoDaysAgo, to: now }).toISOString();
    }

    if (orderFate !== 'history') {
      data.orders.push({
        id: `order${orderIdCounter}`,
        tableId: tableIdForOrder,
        timestamp: timestamp.toISOString(),
        orderItems,
        createdBy,
        servedBy,
        servedAt,
      });
    }

    if (orderFate === 'history') {
      const completedAt = faker.date.between({ from: twoDaysAgo, to: now }).toISOString();
      const cashierId = faker.helpers.arrayElement(
        data.users.filter((u) => u.role === 'cashier').map((u) => u.id),
      );
      const paymentMethodName = faker.helpers.arrayElement(paymentMethods);
      data.orderHistory.push({
        id: `history${orderIdCounter}`,
        orderId: `order${orderIdCounter}`,
        tableId: tableIdForOrder,
        paymentMethod: paymentMethodName,
        createdAt: timestamp.toISOString(),
        servedAt: servedAt,
        completedAt,
        orderItems,
        cashierId,
        totalPrice: parseFloat(totalPrice.toFixed(2)),
      });
    }

    orderIdCounter++;
  }

  for (let i = 0; i < 10; i++) {
    const allTableIds = data.tables.map((t) => t.id);
    const sourceTableId = faker.helpers.arrayElement(allTableIds);
    const targetTableId = faker.helpers.arrayElement(
      allTableIds.filter((id) => id !== sourceTableId),
    );

    const sourceOrder = data.orders.find((o) => o.tableId === sourceTableId);
    const splitItemIds = sourceOrder
      ? faker.helpers.arrayElements(
          sourceOrder.orderItems.map((item) => item.id),
          faker.number.int({ min: 0, max: sourceOrder.orderItems.length }),
        )
      : [];

    if (sourceTableId !== targetTableId && sourceOrder) {
      data.mergeRequests.push({
        id: faker.database.mongodbObjectId(),
        sourceTableId,
        targetTableId,
        splitItemIds,
        status: 'pending',
        requestedBy: faker.helpers.arrayElement(
          data.users.filter((u) => u.role === 'serve').map((u) => u.id),
        ),
        requestedAt: faker.date.recent({ days: 1 }).toISOString(),
      });

      const targetTable = data.tables.find((t) => t.id === targetTableId);
      if (targetTable) {
        targetTable.mergedTable = (targetTable.mergedTable || 1) + 1;
      }
    }
  }

  const startDate = new Date();
  startDate.setDate(startDate.getDate() - 90);
  const endDate = new Date();
  let historyIdCounter = 1;
  for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
    for (let i = 0; i < faker.number.int({ min: 5, max: 15 }); i++) {
      const orderItems = Array.from({ length: faker.number.int({ min: 1, max: 7 }) }, () => {
        const randomMenuItemId = String(faker.number.int({ min: 1, max: menuItemId - 1 }));
        const menuItem = data.menuItems.find((item) => item.id === randomMenuItemId);
        if (!menuItem) return null;

        return {
          id: `historyItem-${historyIdCounter}-${faker.string.uuid()}`,
          orderId: `history${historyIdCounter}`,
          menuItemId: randomMenuItemId,
          quantity: faker.number.int({ min: 1, max: 5 }),
          price: menuItem.price,
        };
      }).filter((item) => item !== null);

      if (orderItems.length === 0) continue;

      const createdAt = faker.date.between({
        from: d,
        to: new Date(d.getFullYear(), d.getMonth(), d.getDate(), 23, 59, 59),
      });
      const servedAt = faker.date
        .between({ from: createdAt, to: new Date(createdAt.getTime() + 60 * 60000) })
        .toISOString();
      const completedAt = faker.date
        .between({ from: servedAt, to: new Date(createdAt.getTime() + 180 * 60000) })
        .toISOString();
      const cashierId = faker.helpers.arrayElement(
        data.users.filter((u) => u.role === 'cashier').map((u) => u.id),
      );
      let totalPrice = orderItems.reduce((sum, item) => {
        const menuItem = data.menuItems.find((mi) => mi.id === item.menuItemId);
        return sum + (menuItem ? menuItem.price * item.quantity : 0);
      }, 0);

      const paymentMethodName = faker.helpers.arrayElement(paymentMethods);
      data.orderHistory.push({
        id: `history${historyIdCounter}`,
        orderId: `history${historyIdCounter}`,
        tableId: String(faker.number.int({ min: 1, max: tableId - 1 })),
        paymentMethod: paymentMethodName,
        createdAt: createdAt.toISOString(),
        servedAt,
        completedAt,
        orderItems,
        cashierId,
        totalPrice: parseFloat(totalPrice.toFixed(2)),
      });
      historyIdCounter++;
    }
  }

  for (let i = 0; i < 100; i++) {
    const rating = faker.number.int({ min: 1, max: 5 });
    const comment =
      rating > 3
        ? faker.lorem.sentences()
        : faker.datatype.boolean()
        ? faker.lorem.sentences()
        : '';
    data.feedback.push({
      id: faker.string.uuid(),
      rating,
      comment,
      timestamp: faker.date.recent({ days: 60 }).toISOString(),
      createdAt: faker.date.recent({ days: 60 }).toISOString(),
      updatedAt: faker.date.recent({ days: 60 }).toISOString(),
    });
  }

  for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
    const dateString = d.toISOString().split('T')[0];
    let totalOrders = 0;
    let totalRevenue = 0;
    let paymentMethodSummary = {};
    let ordersByHour = {};
    let soldItems = {};

    data.orderHistory
      .filter((order) => order.createdAt && order.createdAt.startsWith(dateString))
      .forEach((order) => {
        totalOrders++;
        totalRevenue += order.totalPrice;

        order.orderItems.forEach((item) => {
          const menuItem = data.menuItems.find((mi) => mi.id === item.menuItemId);
          if (menuItem) {
            soldItems[menuItem.name] = (soldItems[menuItem.name] || 0) + item.quantity;
          }
        });

        const paymentMethodName = order.paymentMethod;
        const paymentMethod = data.payments.find((p) => p.name === paymentMethodName);
        const paymentMethodId = paymentMethod ? paymentMethod.id : null;

        if (paymentMethodId) {
          if (!paymentMethodSummary[paymentMethodId]) {
            paymentMethodSummary[paymentMethodId] = {
              paymentId: paymentMethodId,
              count: 0,
              totalAmount: 0.0,
            };
          }
          paymentMethodSummary[paymentMethodId].count += 1;
          paymentMethodSummary[paymentMethodId].totalAmount += order.totalPrice;
        }

        const hour = new Date(order.createdAt).getHours();
        ordersByHour[hour] = (ordersByHour[hour] || 0) + 1;
      });

    data.orders
      .filter((order) => order.timestamp && order.timestamp.startsWith(dateString))
      .forEach((order) => {
        totalOrders++;
        totalRevenue += order.orderItems.reduce((sum, item) => {
          const menuItem = data.menuItems.find((mi) => mi.id === item.menuItemId);
          return sum + (menuItem ? menuItem.price * item.quantity : 0);
        }, 0);

        order.orderItems.forEach((item) => {
          const menuItem = data.menuItems.find((mi) => mi.id === item.menuItemId);
          if (menuItem) {
            soldItems[menuItem.name] = (soldItems[menuItem.name] || 0) + item.quantity;
          }
        });

        const hour = new Date(order.timestamp).getHours();
        ordersByHour[hour] = (ordersByHour[hour] || 0) + 1;
      });

    const ratings = data.feedback
      .filter((f) => f.createdAt && f.createdAt.startsWith(dateString))
      .map((f) => f.rating);
    const averageRating =
      ratings.length > 0
        ? parseFloat((ratings.reduce((sum, r) => sum + r, 0) / ratings.length).toFixed(2))
        : 0;
    const totalComments = data.feedback.filter(
      (f) => f.createdAt && f.createdAt.startsWith(dateString) && f.comment !== '',
    ).length;

    data.statistics.push({
      id: `stats-${dateString}`,
      date: dateString,
      totalOrders,
      totalRevenue: parseFloat(totalRevenue.toFixed(2)),
      paymentMethodSummary,
      ordersByHour,
      averageRating,
      totalComments,
      soldItems,
    });
  }

  const startMonth = new Date(startDate.getFullYear(), startDate.getMonth(), 1);
  for (let d = new Date(startMonth); d <= endDate; d.setMonth(d.getMonth() + 1)) {
    const yearMonth = d.toISOString().substring(0, 7);
    const monthlyStats = data.statistics.filter((s) => s.date.startsWith(yearMonth));

    if (monthlyStats.length > 0) {
      const aggregated = monthlyStats.reduce(
        (acc, curr) => {
          acc.totalOrders += curr.totalOrders;
          acc.totalRevenue += curr.totalRevenue;
          acc.totalComments += curr.totalComments;

          for (const paymentId in curr.paymentMethodSummary) {
            if (curr.paymentMethodSummary.hasOwnProperty(paymentId)) {
              if (!acc.paymentMethodSummary[paymentId]) {
                acc.paymentMethodSummary[paymentId] = {
                  paymentId: paymentId,
                  count: 0,
                  totalAmount: 0.0,
                };
              }
              acc.paymentMethodSummary[paymentId].count +=
                curr.paymentMethodSummary[paymentId].count;
              acc.paymentMethodSummary[paymentId].totalAmount +=
                curr.paymentMethodSummary[paymentId].totalAmount;
            }
          }

          for (const item in curr.soldItems) {
            acc.soldItems[item] = (acc.soldItems[item] || 0) + curr.soldItems[item];
          }

          if (curr.averageRating > 0) {
            acc.averageRating.push(curr.averageRating);
          }
          return acc;
        },
        {
          totalOrders: 0,
          totalRevenue: 0,
          totalComments: 0,
          paymentMethodSummary: {},
          soldItems: {},
          averageRating: [],
        },
      );

      let finalAverageRating = 0;
      if (aggregated.averageRating.length > 0) {
        const sum = aggregated.averageRating.reduce((a, b) => a + b, 0);
        finalAverageRating = parseFloat((sum / aggregated.averageRating.length).toFixed(1));
      }

      data.aggregatedStatistics.push({
        id: yearMonth,
        year: d.getFullYear(),
        month: d.getMonth() + 1,
        totalOrders: aggregated.totalOrders,
        totalRevenue: parseFloat(aggregated.totalRevenue.toFixed(2)),
        paymentMethodSummary: aggregated.paymentMethodSummary,
        averageRating: finalAverageRating,
        totalComments: aggregated.totalComments,
        soldItems: aggregated.soldItems,
      });
    }
  }

  return data;
}

const jsonData = generateData();
fs.writeFileSync('db.json', JSON.stringify(jsonData, null, 2));
console.log('Generated db.json');
