import pandas as pd



df = pd.read_csv(r'C:\Users\MAHIN BUTUL\OneDrive\Desktop\ChurnAnalysis\customer_churn_1M.csv')

print(df.head())
print(len(df))

df['num_complaints'] = df['num_complaints'].fillna(0)
df['avg_monthly_gb'] = df['avg_monthly_gb'].fillna(df['avg_monthly_gb'].median())
df['customer_satisfaction'] = df['customer_satisfaction'].fillna(df['customer_satisfaction'].mode()[0])
df['annual_income'] = df['annual_income'].fillna(df['annual_income'].median())
df['credit_score'] = df['credit_score'].fillna(df['credit_score'].median())

print(df.isnull().sum())  # should all show 0 now

print(df.isnull().sum())
numeric_cols = ['age', 'annual_income', 'tenure', 'monthlycharges', 'totalcharges',
                 'num_services', 'customer_satisfaction', 'num_complaints', 
                 'num_service_calls', 'late_payments', 'avg_monthly_gb', 
                 'days_since_last_interaction', 'credit_score']

for col in numeric_cols:
    print(f"{col}: min = {df[col].min()}, max = {df[col].max()}")


print(df.groupby('contract')['churn'].mean())

print(df.groupby('payment_method')['churn'].mean())

print(df.groupby('customer_satisfaction')['churn'].mean())

print(df.groupby('num_complaints')['churn'].mean())

print(df.groupby('has_tech_support')['churn'].mean())
print(df.groupby('has_online_security')['churn'].mean())

skip_cols = ['customer_id', 'signup_date', 'churn']

categorical_cols = ['gender', 'education', 'marital_status', 'contract', 
                     'payment_method', 'paperless_billing', 'senior_citizen',
                     'has_phone_service', 'has_internet_service', 'has_online_security',
                     'has_online_backup', 'has_device_protection', 'has_tech_support',
                     'has_streaming_tv', 'has_streaming_movies']

numeric_cols = ['age', 'annual_income', 'dependents', 'tenure', 'monthlycharges', 
                'totalcharges', 'num_services', 'customer_satisfaction', 
                'num_complaints', 'num_service_calls', 'late_payments', 
                'avg_monthly_gb', 'days_since_last_interaction', 'credit_score']

print("=== CATEGORICAL COLUMNS vs CHURN ===\n")
for col in categorical_cols:
    print(f"--- {col} ---")
    print(df.groupby(col)['churn'].mean())
    print()

print("=== NUMERIC COLUMNS vs CHURN (correlation) ===\n")
for col in numeric_cols:
    corr = df[col].corr(df['churn'])
    print(f"{col}: correlation with churn = {corr:.4f}")

df.to_csv(r'C:\Users\MAHIN BUTUL\OneDrive\Desktop\ChurnAnalysis\customer_churn_cleaned.csv', index=False)
print("Cleaned file saved!")    