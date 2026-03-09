import pandas as pd
import numpy as np
from sklearn.ensemble import RandomForestClassifier, RandomForestRegressor
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import accuracy_score, mean_absolute_error
import pickle

df = pd.read_csv('cybercrime_data.csv')
print("Data loaded:", len(df), "records")

le_fraud = LabelEncoder()
le_district = LabelEncoder()
df['fraud_type_enc'] = le_fraud.fit_transform(df['fraud_type'])
df['district_enc'] = le_district.fit_transform(df['victim_district'])

# Added withdrawal_lat and withdrawal_lon as features
features = ['complaint_hour', 'fraud_amount', 'fraud_type_enc',
            'district_enc', 'hours_to_withdrawal', 'risk_score',
            'withdrawal_lat', 'withdrawal_lon']
X = df[features]

y_cluster = df['cluster_id']
y_risk = df['risk_score']

X_train, X_test, y_train, y_test = train_test_split(
    X, y_cluster, test_size=0.2, random_state=42)

print("Training model... please wait...")
cluster_model = RandomForestClassifier(
    n_estimators=200, random_state=42, max_depth=10)
cluster_model.fit(X_train, y_train)
acc = accuracy_score(y_test, cluster_model.predict(X_test))
print(f'Cluster Prediction Accuracy: {acc*100:.2f}%')

X_train2, X_test2, y_train2, y_test2 = train_test_split(
    X, y_risk, test_size=0.2, random_state=42)
risk_model = RandomForestRegressor(
    n_estimators=200, random_state=42)
risk_model.fit(X_train2, y_train2)
mae = mean_absolute_error(y_test2, risk_model.predict(X_test2))
print(f'Risk Score MAE: {mae:.2f}')

with open('cluster_model.pkl', 'wb') as f: pickle.dump(cluster_model, f)
with open('risk_model.pkl', 'wb') as f: pickle.dump(risk_model, f)
with open('le_fraud.pkl', 'wb') as f: pickle.dump(le_fraud, f)
with open('le_district.pkl', 'wb') as f: pickle.dump(le_district, f)

print("All models saved successfully!")
print("You are ready for Day 2!")
