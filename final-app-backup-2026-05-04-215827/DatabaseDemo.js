import React, { Component } from 'react';
import './DatabaseDemo.css';

class DatabaseDemo extends Component {
  constructor(props) {
    super(props);
    this.handleTextChange = this.handleTextChange.bind(this);
    this.handleButtonClick = this.handleButtonClick.bind(this);
    this.handleButtonClickDel = this.handleButtonClickDel.bind(this);
    this.state = {
      transactions: [],
      text_amt: "",
      text_desc: ""
    };
  }

  componentDidMount() {
    this.populateData();
  }

  populateData() {
    this.fetch_retry('/api/transaction', 3)
      .then(res => res.json())
      .then((data) => {
        this.setState({ transactions: data.result || [] });
      })
      .catch(console.log);
  }

  async fetch_retry(url, n) {
    try {
      return await fetch(url);
    } catch (err) {
      if (n === 1) throw err;
      await new Promise(resolve => setTimeout(resolve, 1000));
      return await this.fetch_retry(url, n - 1);
    }
  }

  renderTableData() {
    return this.state.transactions.map((transaction) => {
      const { id, amount, description } = transaction;
      return (
        <tr key={id}>
          <td>{id}</td>
          <td>{amount}</td>
          <td>{description}</td>
        </tr>
      );
    });
  }

  handleButtonClickDel() {
    const requestOptions = {
      method: 'DELETE'
    };

    fetch('/api/transaction', requestOptions)
      .then(response => response.json())
      .then(() => {
        this.setState({ text_amt: "", text_desc: "", transactions: [] });
        this.populateData();
      })
      .catch(console.log);
  }

  handleButtonClick() {
    const requestOptions = {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        amount: this.state.text_amt,
        description: this.state.text_desc
      })
    };

    fetch('/api/transaction', requestOptions)
      .then(response => response.json())
      .then(() => {
        this.setState({ text_amt: "", text_desc: "" });
        this.populateData();
      })
      .catch(console.log);
  }

  handleTextChange(e) {
    this.setState({ [e.target.name]: e.target.value });
  }

  render() {
    return (
      <div>
        <h1 id='title' style={{ paddingRight: "1em" }}>Aurora Database Demo Page 1 </h1>
        <input
          style={{ float: "right", marginBottom: "1em" }}
          type="button"
          value="DEL"
          onClick={this.handleButtonClickDel}
        />
        <table id='transactions'>
          <tbody>
            <tr>
              <td>ID</td>
              <td>AMOUNT</td>
              <td>DESC</td>
            </tr>
            <tr>
              <td><input type="button" value="ADD" onClick={this.handleButtonClick} /></td>
              <td><input type="text" name="text_amt" value={this.state.text_amt} onChange={this.handleTextChange} /></td>
              <td><input type="text" name="text_desc" value={this.state.text_desc} onChange={this.handleTextChange} /></td>
            </tr>
            {this.renderTableData()}
          </tbody>
        </table>
      </div>
    );
  }
}

export default DatabaseDemo;
