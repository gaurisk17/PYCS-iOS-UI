# PYCS – Predict Your Crop Score (iOS Application)

PYCS (Predict Your Crop Score) is an iOS application designed to analyze and predict crop yields using machine learning models. The app integrates a SwiftUI-based frontend with a Flask backend and XGBoost models, enabling users to upload datasets, train models dynamically, generate predictions, and visualize results through interactive charts and metrics.

---

## 📱 Application Overview

The PYCS iOS app provides an end-to-end workflow for crop yield analysis, including:

- Secure user authentication (Login & Signup)
- Dataset upload and file management
- Dynamic training of machine learning models
- Yield prediction and evaluation
- Interactive visualizations and charts

The application focuses on usability, clarity of insights, and seamless interaction between the iOS UI and backend ML services.

---

## 🚀 Core Features

### 🔐 Authentication
- Login and Signup screens implemented using SwiftUI  
- User credentials managed using local Swift storage for simplicity and reliability  

### 📊 Dashboard
After successful login, users are presented with a dashboard offering:
- **Analyze Crop Data**: Upload datasets and dynamically train new XGBoost models, generating timestamped pickle (`.pkl`) files
- **Test Prediction**: Run forecasts using newly generated or existing models

### 📁 Data Management
- **CSV Files** for dataset uploads  
- **Pickle (`.pkl`) Files** for serialized ML models  
- File selection handled using iOS `DocumentPicker`  
- Files accessible through iOS File Manager and iCloud Drive (Simulator)

### 🤖 Model Training & Prediction
- Backend powered by Flask APIs
- Automatic retraining of XGBoost models on new data uploads
- Endpoints:
  - `/upload` – Train models and generate pickle files
  - `/predict` – Generate predictions and evaluation metrics
- Performance metrics include:
  - MAE
  - RMSE
  - MAPE
  - SMAPE
  - Correlation Score

### 📈 Visualization
- Actual vs Predicted Yield charts
- Feature Importance visualization
- Metric dashboards for performance evaluation
- Horizontally scrollable and color-coded graphs for better readability

### ❓ Help & UX Enhancements
- Integrated **Help** view explaining evaluation metrics
- Clean, minimal UI with consistent color themes
- Designed for ease of understanding even for non-technical users

---

## 🛠 Utilities & Technologies Used

### iOS / Frontend
- **SwiftUI**
- **MVVM Architecture**
- **iOS DocumentPicker**
- **FileManager & iCloud integration**
- **Charts & Custom Visualizations**

### Backend / Machine Learning
- **Python**
- **Flask**
- **XGBoost**
- **Joblib** (model serialization)
- **REST APIs (JSON-based communication)**

---

## 📄 UI & Implementation Details

A detailed document containing:
- UI screenshots
- Screen-by-screen explanations
- User flows
- Backend interaction details

has been uploaded directly to this repository.

👉 **Please refer to the PDF documentation in this repository for complete UI implementation details and screenshots.**

---

## 📌 Notes
- The application demonstrates full-stack integration of iOS UI with ML-powered backend services.
- Designed as a research and academic project with practical, real-world applicability.
- Suitable for demonstrating skills in **SwiftUI**, **Machine Learning integration**, and **iOS app architecture**.

---

## 👩‍💻 Author
Gauri Sachin Kulkarni
