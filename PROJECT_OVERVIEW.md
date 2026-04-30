# 🌍 TripGenie — Smart Travel Planner App

A Flutter-based intelligent travel planner that generates personalized itineraries, optimizes travel routes using algorithms, and helps users plan complete trips in a structured and efficient way.

---

# ✨ Project Overview

TripGenie is a smart travel planning application that allows users to:

- Enter travel preferences (destination, budget, interests, days)
- Automatically generate day-wise itineraries
- Optimize travel routes using algorithms
- View trips on interactive maps
- Save and manage travel plans

The goal of this project is to reduce manual effort in trip planning and provide a **smart, automated travel experience**.

---

# 🎯 Key Objectives

- Build a real-world Flutter application
- Integrate APIs and backend services
- Implement route optimization algorithm
- Learn scalable app architecture
- Create a portfolio-level project

---

# 🧠 Core Feature System

## 1. Trip Planning System
Users input:
- Destination
- Number of days
- Budget type (low, medium, high)
- Interests (adventure, food, culture, etc.)

---

## 2. Itinerary Generator
Automatically generates:
- Day-wise schedule
- Time-based activities
- Organized travel plan

---

## 3. Route Optimization Engine
Uses:

👉 Travelling Salesman Problem (TSP - Nearest Neighbor approach)

Features:
- Finds optimal visiting order of places
- Reduces travel distance and time
- Improves trip efficiency

---

## 4. Map Visualization
- Displays all places on map
- Shows optimized route
- Interactive markers and navigation view

---

## 5. Weather & Context Awareness
- Shows real-time weather
- Suggests travel adjustments based on conditions

---

## 6. Trip Management
- Save trips
- Edit trips
- Delete trips
- View history

---

# 🧱 Tech Stack

## Frontend
- Flutter (Dart)

## State Management
- Riverpod

## Networking
- Dio

## Backend
- Supabase (Auth + PostgreSQL Database)

## APIs
- Google Places API
- Google Maps API
- OpenWeatherMap API

## Local Storage
- Hive

---

# 🗄️ Database Structure (Supabase)

## Users
Handled by Supabase Auth

---

## Trips Table
- id
- user_id
- destination
- start_date
- end_date
- budget_type
- interests

---

## Itinerary Table
- id
- trip_id
- day_number
- title
- description
- time_slot
- location_name
- latitude
- longitude

---

## Places Table (Optional Cache)
- id
- name
- description
- lat
- lng
- image_url
- category

---

# 🧭 App Screens

## 🔐 Authentication
1. Splash Screen  
2. Login / Register Screen  

---

## 🏠 Main App (Bottom Navigation)
3. Home Dashboard Screen  
4. Explore / Search Screen  
5. Saved Trips Screen  
6. Profile Screen  

---

## ✈️ Core Feature Screens

7. Trip Setup Screen  
   - Destination input  
   - Days selection  
   - Budget selection  
   - Interest selection  
   - Generate Plan button  

---

8. Itinerary Screen  
   - Day-wise travel plan  
   - Timeline / cards  
   - Activities with time slots  
   - View Map button  

---

9. Route Optimization Screen  
   - Ordered list of places  
   - Distance between stops  
   - Optimized route indicator  

---

10. Map Screen  
   - Full-screen Google Map  
   - Markers for places  
   - Route polyline  
   - Navigation actions  

---

11. Place Details Screen  
   - Image header  
   - Description  
   - Location info  
   - Add to trip button  
   - Reviews/highlights  

---

# 🔄 App Flow

```text
Splash Screen
   ↓
Login / Register
   ↓
Home Dashboard (Main App)
   ↓
Trip Setup Screen
   ↓
Itinerary Screen
   ↓
Route Optimization Screen
   ↓
Map Screen (optional from multiple screens)
   ↓
Place Details Screen
