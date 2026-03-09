from flask import Flask, request, jsonify
from flask_cors import CORS
import pickle
import numpy as np
import folium

app = Flask(__name__)
CORS(app, origins="*")

# Load all models
print("Loading models...")
with open('cluster_model.pkl', 'rb') as f:
    cluster_model = pickle.load(f)
with open('risk_model.pkl', 'rb') as f:
    risk_model = pickle.load(f)
with open('le_fraud.pkl', 'rb') as f:
    le_fraud = pickle.load(f)
with open('le_district.pkl', 'rb') as f:
    le_district = pickle.load(f)
print("All models loaded!")

# ATM Clusters
ATM_CLUSTERS = [
    {'lat': 12.9716, 'lon': 77.5946, 'name': 'City Center', 'atms': 45},
    {'lat': 12.9352, 'lon': 77.6245, 'name': 'East Zone',   'atms': 32},
    {'lat': 13.0012, 'lon': 77.5800, 'name': 'North Zone',  'atms': 28},
    {'lat': 12.9100, 'lon': 77.6100, 'name': 'South Zone',  'atms': 19},
    {'lat': 12.9600, 'lon': 77.7000, 'name': 'West Zone',   'atms': 22},
]

@app.route('/', methods=['GET'])
def home():
    return jsonify({
        'message': 'Cybercrime Predictor API',
        'endpoints': {
            'health': '/health',
            'predict': '/predict (POST)',
            'heatmap': '/heatmap'
        }
    })

@app.route('/health', methods=['GET'])
def health():
    return jsonify({
        'status': 'API is Running!',
        'models': 'Loaded Successfully'
    })

@app.route('/predict', methods=['POST'])
def predict():
    data = request.json

    try:
        fraud_type_enc = le_fraud.transform([data['fraud_type']])[0]
    except:
        fraud_type_enc = 0
    try:
        district_enc = le_district.transform([data['district']])[0]
    except:
        district_enc = 0

    features = [[
        int(data['complaint_hour']),
        float(data['fraud_amount']),
        fraud_type_enc,
        district_enc,
        2.0,
        min(100, float(data['fraud_amount']) / 1000),
        12.9716,
        77.5946
    ]]

    cluster_id = int(cluster_model.predict(features)[0])
    risk_score = float(risk_model.predict(features)[0])
    cluster = ATM_CLUSTERS[cluster_id]

    if risk_score > 70:
        alert = "HIGH RISK"
        action = "Deploy patrol immediately!"
        color = "red"
    elif risk_score > 40:
        alert = "MEDIUM RISK"
        action = "Monitor closely"
        color = "orange"
    else:
        alert = "LOW RISK"
        action = "Log and observe"
        color = "green"

    return jsonify({
        'predicted_cluster': cluster['name'],
        'latitude': cluster['lat'],
        'longitude': cluster['lon'],
        'risk_score': round(risk_score, 1),
        'atm_count': cluster['atms'],
        'alert': alert,
        'action': action,
        'color': color
    })

@app.route('/heatmap', methods=['GET'])
def heatmap():
    m = folium.Map(location=[12.9716, 77.5946], zoom_start=12)
    for c in ATM_CLUSTERS:
        folium.CircleMarker(
            location=[c['lat'], c['lon']],
            radius=25,
            color='red',
            fill=True,
            fill_opacity=0.5,
            popup=f"{c['name']} — {c['atms']} ATMs"
        ).add_to(m)
        folium.Marker(
            location=[c['lat'], c['lon']],
            popup=c['name'],
            icon=folium.Icon(color='red', icon='info-sign')
        ).add_to(m)
    m.save('heatmap.html')
    return jsonify({'message': 'Heatmap saved! Open heatmap.html in browser'})

if __name__ == '__main__':
    print("Starting API on http://localhost:5000")
    app.run(debug=True, host='0.0.0.0', port=5000)
