const dbcreds = require('./DbConfig');
const mysql = require('mysql');

const con = mysql.createConnection({
    host: dbcreds.host,
    user: dbcreds.user,
    password: dbcreds.password,
    database: dbcreds.database,
    port: dbcreds.port
});

con.connect(function(err) {
    if (err) {
        console.log("DB connection error:", err);
        return;
    }
    console.log("MySQL Connected");
});

function addTransaction(amount, desc, callback) {
    const sql = "INSERT INTO transactions (amount, description) VALUES (?, ?)";
    con.query(sql, [amount, desc], function(err, result) {
        if (err) return callback(err, null);
        return callback(null, result);
    });
}

function getAllTransactions(callback) {
    const sql = "SELECT * FROM transactions";
    con.query(sql, function(err, result) {
        if (err) return callback(err, null);
        return callback(null, result);
    });
}

function findTransactionById(id, callback) {
    const sql = "SELECT * FROM transactions WHERE id = ?";
    con.query(sql, [id], function(err, result) {
        if (err) return callback(err, null);
        return callback(null, result);
    });
}

function deleteAllTransactions(callback) {
    const sql = "DELETE FROM transactions";
    con.query(sql, function(err, result) {
        if (err) return callback(err, null);
        return callback(null, result);
    });
}

function deleteTransactionById(id, callback) {
    const sql = "DELETE FROM transactions WHERE id = ?";
    con.query(sql, [id], function(err, result) {
        if (err) return callback(err, null);
        return callback(null, result);
    });
}

module.exports = {
    addTransaction,
    getAllTransactions,
    deleteAllTransactions,
    findTransactionById,
    deleteTransactionById
};
