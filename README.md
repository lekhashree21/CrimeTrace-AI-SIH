#  CrimeTrace AI — Cybercrime Prediction System

> **Smart India Hackathon (SIH) 2024 Project**
> AI/ML based Cybercrime Cash Withdrawal Prediction System with **90%+ Accuracy**

---

##  About The Project

CrimeTrace AI is a machine learning-powered system designed to assist law enforcement in predicting cybercrime cash withdrawal locations in real-time,this system uses a Random Forest ML model trained on cybercrime data to generate accurate predictions and send instant alerts to police via a Flutter mobile app.

---

##  Key Features

-  **90%+ Prediction Accuracy** using Random Forest ML algorithm
-  **Real-time Location Prediction** of cybercrime cash withdrawals
-  **Instant Police Alerts** via Flutter mobile application
-  **REST API Backend** built with Flask for seamless integration
-  **Data Preprocessing Pipeline** for clean, reliable predictions

---

## 🛠️ Tech Stack

| Layer | Technology |
|---|---|
| ML Model | Python, Random Forest, Scikit-learn |
| Backend API | Flask, REST API |
| Mobile App | Flutter (Dart) |
| Data Processing | Pandas, NumPy |
| Version Control | Git, GitHub |

---

## Project Structure

```
CrimeTrace-AI-SIH/
├── model/
│   ├── train_model.py        # ML model training
│   ├── predict.py            # Prediction logic
│   └── crime_model.pkl       # Trained Random Forest model
├── api/
│   ├── app.py                # Flask REST API
│   └── requirements.txt      # Python dependencies
├── flutter_app/              # Mobile app source
├── data/
│   └── crime_data.csv        # Training dataset
└── README.md
```

---

##  How To Run

### Backend (Flask API)
```bash
# Clone the repository
git clone https://github.com/lekhashree21/CrimeTrace-AI-SIH.git
cd CrimeTrace-AI-SIH

# Install dependencies
pip install -r requirements.txt

# Run the API
python api/app.py
```

### ML Model Training
```bash
python model/train_model.py
```

---

## Model Performance

| Metric | Score |
|---|---|
| Accuracy | 90%+ |
| Algorithm | Random Forest |
| Dataset | Cybercrime transaction data |

---

##  Developer

**Lekhashree B** — [LinkedIn](https://linkedin.com/in/lekhashree-b) | [GitHub](https://github.com/lekhashree21)
