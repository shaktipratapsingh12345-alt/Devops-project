const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');
const transactionService = require('./TransactionService');

const app = express();
const port = 4000;

app.use(cors());
app.use(bodyParser.json());
app.use(bodyParser.urlencoded({ extended: true }));

app.get('/transaction', (req, res) => {
    transactionService.getAllTransactions(function(err, results) {
        if (err) {
            console.log("GET /transaction error:", err);
            return res.status(500).json({
                error: "Database error",
                details: err.sqlMessage || err.message
            });
        }

        const transactionList = [];
        for (const row of results) {
            transactionList.push({
                id: row.id,
                amount: row.amount,
                description: row.description
            });
        }

        return res.status(200).json({ result: transactionList });
    });
});

app.post('/transaction', (req, res) => {
    const amount = req.body.amount;
    const description = req.body.description || req.body.desc;

    if (!amount || !description) {
        return res.status(400).json({
            error: "amount and description are required"
        });
    }

    transactionService.addTransaction(amount, description, function(err, result) {
        if (err) {
            console.log("POST /transaction error:", err);
            return res.status(500).json({
                error: "Database insert error",
                details: err.sqlMessage || err.message
            });
        }

        return res.status(200).json({
            message: "Transaction added successfully",
            result: result
        });
    });
});

app.delete('/transaction', (req, res) => {
    transactionService.deleteAllTransactions(function(err, result) {
        if (err) {
            console.log("DELETE /transaction error:", err);
            return res.status(500).json({
                error: "Database delete error",
                details: err.sqlMessage || err.message
            });
        }

        return res.status(200).json({
            message: "All transactions deleted successfully",
            result: result
        });
    });
});

app.listen(port, () => {
    console.log(`AB3 backend app listening at http://localhost:${port}`);
});
