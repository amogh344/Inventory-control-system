# 🧾 Inventory Control System

A **Full-Stack Inventory Management Web Application** built using **Django REST Framework (Backend)** and **React.js (Frontend)**.  
It helps businesses manage products, suppliers, purchase and sales orders, and track inventory transactions in real-time — with role-based authentication and detailed dashboards.

---

## 🚀 Features

### 🏢 Core Modules
- **Product Management:** Add, update, or remove products with stock and pricing details.  
- **Supplier Management:** Maintain supplier contact and relationship data.  
- **Purchase Orders:** Create, approve, and mark orders as received — automatically update stock quantities.  
- **Sales Orders:** Manage customer sales and track outgoing inventory.  
- **Inventory Tracking:** Real-time stock updates via transaction logs.  
- **Audit Logs:** Every change is tracked for accountability.  
- **Dashboard Analytics:** Quick view of total products, low stock alerts, recent transactions, etc.

### 🔐 Authentication & Security
- Role-based access control (Admin / Manager / Staff).  
- JWT-based authentication.  
- Password reset and change functionality.  
- Input validation and ORM protection from SQL injection.  

---

## 🧰 Tech Stack

| Layer | Technology |
|-------|-------------|
| **Frontend** | React.js, Axios, React Router |
| **Backend** | Django, Django REST Framework, JWT Authentication |
| **Database** | MySQL / SQLite (local) |
| **Deployment** | Vercel (Serverless ASGI) |
| **Tools & Libraries** | Django Filter, CORS Headers, DRF SimpleJWT |

---

## ⚙️ Installation & Setup (Local)

### 1️⃣ Clone the Repository
```bash
git clone https://github.com/amogh344/Inventory-control-system.git
cd Inventory-control-system
