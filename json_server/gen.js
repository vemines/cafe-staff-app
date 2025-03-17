// --- FILE gen.js ---
const { faker } = require('@faker-js/faker');
const fs = require('fs');

function generateData() {
  const data = {
    users: [],
    categories: [],
    subCategories: [],
    menuItems: [],
    areaTables: [],
    tables: [],
    orders: [],
    orderHistory: [],
    mergeRequests: [], // Add mergeRequests
    feedback: [],
    statistics: [],
    aggregatedStatistics: [],
  };

  // --- Users ---
  data.users = [
    {
      id: 'user1',
      username: 'admin_user',
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
      username: 'cashier_user',
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
      username: 'server_user',
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

  // --- Categories and Subcategories ---
  data.categories = [
    { id: 'cat1', name: 'Drinks' },
    { id: 'cat2', name: 'Food' },
  ];

  const drinkSubCategories = ['Coffee', 'Tea', 'Juice', 'Smoothies'];
  const foodSubCategories = ['Pastries', 'Sandwiches', 'Salads'];
  let subCategoryId = 1;
  let menuItemId = 1;

  [...drinkSubCategories, ...foodSubCategories].forEach((subCategoryName) => {
    const items = Array.from({ length: faker.number.int({ min: 2, max: 5 }) }, () =>
      // More items
      String(menuItemId++),
    );
    data.subCategories.push({
      id: String(subCategoryId++),
      name: subCategoryName,
      category: drinkSubCategories.includes(subCategoryName) ? 'cat1' : 'cat2',
      items,
    });
  });

  // --- Menu Items ---
  for (let i = 1; i < menuItemId; i++) {
    const subCategory = data.subCategories.find((sc) => sc.items.includes(String(i)));
    if (subCategory) {
      data.menuItems.push({
        id: String(i),
        name: faker.commerce.productName(),
        price: parseFloat(faker.commerce.price({ min: 2, max: 15, dec: 2 })),
        subCategory: subCategory.id,
        isAvailable: true,
      });
    }
  }

  // --- Areas and Tables ---
  const areas = ['Main Room', 'Patio', 'Bar']; // More areas
  let tableId = 1;
  areas.forEach((areaName, areaIndex) => {
    const tableIds = Array.from({ length: faker.number.int({ min: 3, max: 6 }) }, () =>
      // More tables
      String(tableId++),
    );
    data.areaTables.push({ id: String(areaIndex + 1), name: areaName, tables: tableIds });
  });

  data.tables = Array.from({ length: tableId - 1 }, (_, i) => {
    const area = data.areaTables.find((a) => a.tables.includes(String(i + 1)));
    return {
      id: String(i + 1),
      tableName: `${area.name.replace(/\s+/g, '')}${i + 1}`, // Use tableName
      status: 'completed', // Initialize all tables as 'completed'
      areaId: area.id,
      //totalPrice: 0, // Initialize to 0 remove
      mergedTable: 1, // Initialize to 1
      order: null,
    };
  });

  // --- Orders (Create some initial pending/served orders) ---
  let orderIdCounter = 1;
  for (let i = 0; i < faker.number.int({ min: 2, max: 5 }); i++) {
    // Fewer initial orders
    const tableIdForOrder = String(faker.number.int({ min: 1, max: tableId - 1 }));
    const table = data.tables.find((t) => t.id === tableIdForOrder);
    if (!table) continue;

    const orderItems = Array.from({ length: faker.number.int({ min: 1, max: 4 }) }, () => {
      // More items
      const randomMenuItemId = String(faker.number.int({ min: 1, max: menuItemId - 1 }));
      const menuItem = data.menuItems.find((item) => item.id === randomMenuItemId);
      if (!menuItem) return null;
      return {
        id: `orderItem-${orderIdCounter}-${faker.string.uuid()}`, // Unique item IDs
        orderId: `order${orderIdCounter}`,
        menuItemId: randomMenuItemId,
        quantity: faker.number.int({ min: 1, max: 3 }),
        price: menuItem.price, // Include price for history consistency
      };
    }).filter((item) => item !== null);

    if (orderItems.length === 0) continue; // Skip if no items

    let totalPrice = 0;
    orderItems.forEach((item) => {
      const menuItem = data.menuItems.find((mi) => mi.id === item.menuItemId);
      if (menuItem) {
        totalPrice += menuItem.price * item.quantity;
      }
    });

    const orderStatus = faker.helpers.arrayElement(['pending', 'served']); // Initial status
    const orderData = {
      id: `order${orderIdCounter}`,
      createdAt: faker.date.recent({ days: 1 }).toISOString(),
      orderItems: orderItems.map((item) => ({
        menuItemId: item.menuItemId,
        quantity: item.quantity,
      })),
      totalPrice: parseFloat(totalPrice.toFixed(2)),
    };
    data.orders.push({
      id: `order${orderIdCounter}`,
      tableId: tableIdForOrder,
      timestamp: faker.date.recent({ days: 1 }).toISOString(), // Recent orders
      orderItems,
      //totalPrice: parseFloat(totalPrice.toFixed(2)),
      createdBy: faker.helpers.arrayElement(
        data.users.filter((u) => u.role === 'serve').map((u) => u.id),
      ),
      servedBy:
        orderStatus === 'served'
          ? faker.helpers.arrayElement(
              data.users.filter((u) => u.role === 'serve').map((u) => u.id),
            )
          : null,
      servedAt: orderStatus === 'served' ? faker.date.recent({ days: 1 }).toISOString() : null,
    });

    // Update table status and totalPrice
    table.status = orderStatus;
    //table.totalPrice = totalPrice;
    table.order = orderData;

    orderIdCounter++;
  }

  // --- Merge Requests (Create a few pending merge requests) ---
  for (let i = 0; i < faker.number.int({ min: 0, max: 2 }); i++) {
    //0-2
    const allTableIds = data.tables.map((t) => t.id);
    const sourceTableId = faker.helpers.arrayElement(allTableIds);
    const targetTableId = faker.helpers.arrayElement(
      allTableIds.filter((id) => id !== sourceTableId),
    );

    const sourceOrder = data.orders.find((o) => o.tableId === sourceTableId);
    const splitItemIds = sourceOrder
      ? faker.helpers.arrayElements(
          sourceOrder.orderItems.map((item) => item.id),
          faker.number.int({ min: 0, max: 1 }),
        )
      : [];

    if (sourceTableId !== targetTableId) {
      // Ensure different tables
      data.mergeRequests.push({
        id: faker.database.mongodbObjectId(),
        sourceTableId,
        targetTableId,
        splitItemIds,
        status: 'pending',
        requestedBy: faker.helpers.arrayElement(
          data.users.filter((u) => u.role === 'serve').map((u) => u.id),
        ),
        requestedAt: faker.date.recent({ days: 1 }).toISOString(), // Recent requests
      });

      //Increment target merge table
      const targetTable = data.tables.find((t) => t.id === targetTableId);
      if (targetTable) {
        targetTable.mergedTable = (targetTable.mergedTable || 1) + 1;
      }
    }
  }

  // --- Order History (Generate more historical data) ---
  const startDate = new Date();
  startDate.setDate(startDate.getDate() - 30); // Go back 30 days
  const endDate = new Date();
  let historyIdCounter = 1;

  for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
    for (let i = 0; i < faker.number.int({ min: 1, max: 6 }); i++) {
      // More historical orders
      const orderItems = Array.from({ length: faker.number.int({ min: 1, max: 5 }) }, () => {
        // More items
        const randomMenuItemId = String(faker.number.int({ min: 1, max: menuItemId - 1 }));
        const menuItem = data.menuItems.find((item) => item.id === randomMenuItemId);
        if (!menuItem) return null;
        return {
          id: `historyItem-${historyIdCounter}-${faker.string.uuid()}`, // Unique IDs
          orderId: `history${historyIdCounter}`,
          menuItemId: randomMenuItemId,
          quantity: faker.number.int({ min: 1, max: 3 }),
          price: menuItem.price, // Include price
        };
      }).filter((item) => item !== null);

      if (orderItems.length === 0) continue;

      const createdAt = faker.date.between({
        from: d,
        to: new Date(d.getFullYear(), d.getMonth(), d.getDate(), 23, 59, 59),
      });
      const servedAt = faker.date
        .between({ from: createdAt, to: new Date(createdAt.getTime() + 30 * 60000) })
        .toISOString();
      const completedAt = faker.date
        .between({ from: servedAt, to: new Date(createdAt.getTime() + 120 * 60000) })
        .toISOString();
      const cashierId = faker.helpers.arrayElement(
        data.users.filter((u) => u.role === 'cashier').map((u) => u.id),
      );

      let totalPrice = 0;
      orderItems.forEach((item) => {
        const menuItem = data.menuItems.find((mi) => mi.id === item.menuItemId);
        if (menuItem) {
          totalPrice += menuItem.price * item.quantity;
        }
      });

      data.orderHistory.push({
        id: `history${historyIdCounter}`,
        orderId: `history${historyIdCounter}`,
        tableId: String(faker.number.int({ min: 1, max: tableId - 1 })),
        paymentMethod: faker.helpers.arrayElement(['cash', 'online payment']),
        createdAt: createdAt.toISOString(),
        servedAt,
        completedAt,
        orderItems,
        cashierId,
        totalPrice: parseFloat(totalPrice.toFixed(2)), // Use calculated totalPrice
      });
      historyIdCounter++;
    }
  }

  // --- Feedback ---
  for (let i = 0; i < 30; i++) {
    // More feedback
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
      timestamp: faker.date.recent({ days: 30 }).toISOString(), // Feedback within 30 days
      createdAt: faker.date.recent({ days: 30 }).toISOString(),
      updatedAt: faker.date.recent({ days: 30 }).toISOString(),
    });
  }

  // --- Statistics ---
  for (let d = new Date(startDate); d <= endDate; d.setDate(d.getDate() + 1)) {
    const dateString = d.toISOString().split('T')[0];
    let totalOrders = 0;
    let totalRevenue = 0;
    let paymentMethodSummary = {};
    let ordersByHour = {};
    let bestSellingItems = {};

    // Aggregate from orderHistory
    data.orderHistory
      .filter((order) => order.createdAt.startsWith(dateString))
      .forEach((order) => {
        totalOrders++;
        totalRevenue += order.totalPrice;
        order.orderItems.forEach((item) => {
          const menuItem = data.menuItems.find((mi) => mi.id === item.menuItemId);
          if (menuItem) {
            bestSellingItems[menuItem.name] =
              (bestSellingItems[menuItem.name] || 0) + item.quantity;
          }
        });
        if (order.paymentMethod) {
          paymentMethodSummary[order.paymentMethod] =
            (paymentMethodSummary[order.paymentMethod] || 0) + 1;
        }
        const hour = new Date(order.createdAt).getHours(); // Use getHours()
        ordersByHour[hour] = (ordersByHour[hour] || 0) + 1;
      });

    //Aggregate from orders
    data.orders
      .filter((order) => order.createdAt.startsWith(dateString))
      .forEach((order) => {
        const table = data.tables.find((t) => t.id === order.tableId);
        if (table && table.status != 'completed') {
          totalOrders++;
          totalRevenue += order.totalPrice; //from order total price
          order.orderItems.forEach((item) => {
            const menuItem = data.menuItems.find((mi) => mi.id === item.menuItemId);
            if (menuItem) {
              bestSellingItems[menuItem.name] =
                (bestSellingItems[menuItem.name] || 0) + item.quantity;
            }
          });
          const hour = new Date(order.createdAt).getHours(); // Use getHours()
          ordersByHour[hour] = (ordersByHour[hour] || 0) + 1;
        }
      });

    const sortedBestSellingItems = Object.entries(bestSellingItems)
      .sort(([, qA], [, qB]) => qB - qA)
      .slice(0, 5)
      .reduce((obj, [name, quantity]) => ((obj[name] = quantity), obj), {});

    const ratings = data.feedback
      .filter((f) => f.createdAt.startsWith(dateString))
      .map((f) => f.rating);
    const averageRating =
      ratings.length > 0
        ? parseFloat((ratings.reduce((sum, r) => sum + r, 0) / ratings.length).toFixed(2))
        : 0;
    const totalComments = data.feedback.filter(
      (f) => f.createdAt.startsWith(dateString) && f.comment !== '',
    ).length;

    data.statistics.push({
      id: `stats-${dateString}`,
      date: dateString,
      totalOrders,
      totalRevenue: parseFloat(totalRevenue.toFixed(2)), // Ensure revenue is a number
      paymentMethodSummary,
      ordersByHour,
      averageRating,
      totalComments,
      bestSellingItems: sortedBestSellingItems,
    });
  }

  // --- Aggregated Statistics (Monthly) ---
  const startMonth = new Date(startDate.getFullYear(), startDate.getMonth(), 1);
  for (let d = new Date(startMonth); d <= endDate; d.setMonth(d.getMonth() + 1)) {
    const yearMonth = d.toISOString().substring(0, 7); // YYYY-MM
    const monthlyStats = data.statistics.filter((s) => s.date.startsWith(yearMonth));

    if (monthlyStats.length > 0) {
      const aggregated = monthlyStats.reduce(
        (acc, curr) => {
          acc.totalOrders += curr.totalOrders;
          acc.totalRevenue += curr.totalRevenue;
          acc.totalComments += curr.totalComments;

          for (const method in curr.paymentMethodSummary) {
            acc.paymentMethodSummary[method] =
              (acc.paymentMethodSummary[method] || 0) + curr.paymentMethodSummary[method];
          }
          for (const item in curr.bestSellingItems) {
            acc.bestSellingItems[item] =
              (acc.bestSellingItems[item] || 0) + curr.bestSellingItems[item];
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
          bestSellingItems: {},
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
        month: d.getMonth() + 1, // Month is 0-indexed
        totalOrders: aggregated.totalOrders,
        totalRevenue: parseFloat(aggregated.totalRevenue.toFixed(2)),
        paymentMethodSummary: aggregated.paymentMethodSummary,
        averageRating: finalAverageRating,
        totalComments: aggregated.totalComments,
        bestSellingItems: aggregated.bestSellingItems,
      });
    }
  }

  return data;
}

const jsonData = generateData();
fs.writeFileSync('db.json', JSON.stringify(jsonData, null, 2));
console.log('Generated db.json');
