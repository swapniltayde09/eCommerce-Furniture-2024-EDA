# 🪑 Furniture Sales Analysis (End-to-End Data Analytics Project)

## 📌 Project Overview

This project analyzes a dataset of 2,000 furniture products scraped from AliExpress to uncover insights related to pricing, discounts, shipping strategies, and sales performance.

The goal is to simulate a real-world data analyst workflow—from raw data cleaning to SQL analysis and dashboard visualization.

---

## 🎯 Objectives

* Understand factors influencing product sales
* Analyze the impact of pricing, discounting, and shipping
* Identify top-performing products and revenue drivers
* Provide actionable business insights

---

## 🧰 Tools & Technologies

* **Excel** → Data Cleaning & Preprocessing
* **MySQL** → Data Analysis (EDA & Feature Engineering)
* **Power BI** → Dashboard & Visualization

---

## 🗂️ Project Workflow

### Phase 1: Database Setup

* Created MySQL database and schema
* Imported cleaned dataset

### Phase 2: Data Understanding

* Checked null values, distributions, and data types

### Phase 3: Feature Engineering

* Created derived columns:

  * `discount_amount`
  * `total_cost`
  * `price_bucket`
  * `sales_bucket`
  * `shipping_bucket`

### Phase 4: Univariate Analysis

* Analyzed individual variables (price, sales, discount, shipping)

### Phase 5: Bivariate Analysis

* Explored relationships:

  * Price vs Sales
  * Discount vs Sales
  * Shipping vs Sales

### Phase 6: Performance Analysis

* Identified top-performing products
* Evaluated revenue drivers
* Detected inefficiencies (high discount, low sales)

### Phase 7: Business Insights

* Derived actionable insights and recommendations

### Phase 8: Export Pipeline

* Exported aggregated datasets for Power BI

---

## 🧹 Data Cleaning Summary

* Handled missing `original_price` using **median discount (~49%)**
* Extracted `shipping_cost` from mixed text column
* Standardized categorical values (free shipping, paid shipping, no tag)
* Removed inconsistencies and ensured logical constraints

---

## 📊 Key Insights

### 🔹 Pricing Strategy

* Medium-priced products generate the highest sales and revenue
* Low-priced products dominate volume but not revenue

### 🔹 Discount Strategy

* High discounts do not guarantee higher sales
* Evidence of diminishing returns at extreme discount levels

### 🔹 Shipping Strategy

* Free shipping significantly increases product demand
* High shipping costs negatively impact sales

### 🔹 Revenue Distribution

* Revenue is concentrated in mid-range products
* Clear long-tail distribution of sales

### 🔹 Product Performance

* A small number of products contribute the majority of revenue
* Some products perform well even with low discounts (strong product-market fit)

---

## 📈 Power BI Dashboard

### Dashboard Sections:

* Top Products Analysis
* Price vs Sales
* Shipping Impact
* Discount Impact
* Revenue Distribution

### KPIs:

* Total Revenue
* Average Revenue per Product
* Top Performing Segment

---

## 📁 Project Structure

```
furniture-sales-analysis/
│
├── data/
│   ├── raw/
│   │   └── furniture_raw.csv
│   ├── cleaned/
│   │   └── furniture_sales_cleaned.csv
│   └── exports/
│       ├── top_products.csv
│       ├── price_vs_sales.csv
│       ├── shipping_impact.csv
│       ├── discount_impact.csv
│       └── revenue_distribution.csv
│
├── sql/
│   ├── schema.sql
│   ├── data_import.sql
│   ├── feature_engineering.sql
│   ├── univariate_analysis.sql
│   ├── bivariate_analysis.sql
│   ├── performance_analysis.sql
│   └── export_queries.sql
│
├── dashboard/
│   ├── furniture_dashboard.pbix
│   └── Furniture_Viz.pdf
│
├── README.md
└── requirements.txt
```

---

## 🚀 How to Run This Project

1. Clone the repository
2. Import dataset into MySQL
3. Run SQL scripts in order:

   * schema
   * feature engineering
   * analysis queries
4. Export datasets
5. Open Power BI dashboard

---

## 💡 Key Learning Outcomes

* Data cleaning and preprocessing
* SQL-based exploratory data analysis
* Feature engineering techniques
* Business-oriented data storytelling
* Dashboard development in Power BI

---

## 📌 Conclusion

This project demonstrates how data-driven insights can improve pricing, shipping, and discount strategies in e-commerce. By focusing on total cost and optimal pricing segments, businesses can maximize both sales and revenue.

---
