import pandas as pd
import numpy as np
from faker import Faker
import random

fake = Faker('en_IN')
np.random.seed(42)

atm_clusters = [
    (12.9716, 77.5946),
    (12.9352, 77.6245),
    (13.0012, 77.5800),
    (12.9100, 77.6100),
    (12.9600, 77.7000),
]

records = []
for i in range(2000):
    complaint_hour = random.choice([9,10,11,14,15,16,20,21,22])
    fraud_amount = random.choice([5000,10000,15000,20000,50000,100000])
    fraud_type = random.choice(['UPI','NetBanking','CreditCard','Debit'])
    victim_district = random.choice(['Bangalore','Mysore','Hubli','Mangalore'])
    cluster = random.choices(atm_clusters, weights=[0.4,0.2,0.2,0.1,0.1])[0]
    noise_lat = np.random.normal(0, 0.01)
    noise_lon = np.random.normal(0, 0.01)
    withdrawal_lat = cluster[0] + noise_lat
    withdrawal_lon = cluster[1] + noise_lon
    hours_to_withdrawal = random.uniform(0.5, 4.0)
    risk_score = min(100, (fraud_amount/1000) + (complaint_hour > 18)*20)
    records.append({
        'complaint_hour': complaint_hour,
        'fraud_amount': fraud_amount,
        'fraud_type': fraud_type,
        'victim_district': victim_district,
        'withdrawal_lat': round(withdrawal_lat, 4),
        'withdrawal_lon': round(withdrawal_lon, 4),
        'hours_to_withdrawal': round(hours_to_withdrawal, 2),
        'risk_score': round(risk_score, 1),
        'cluster_id': atm_clusters.index(cluster)
    })

df = pd.DataFrame(records)
df.to_csv('cybercrime_data.csv', index=False)
print(f'Dataset created: {len(df)} records')
print(df.head())
