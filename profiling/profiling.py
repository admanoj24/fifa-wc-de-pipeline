import pandas as pd

df = pd.read_csv("data/raw/fifa_wc_mens_match_dataset_1970_2022.csv")
df.columns = [c.strip().lower() for c in df.columns]

print("=" * 60)
print("1. SHAPE")
print("=" * 60)
print(f"Rows: {df.shape[0]}, Columns: {df.shape[1]}")

print("\n" + "=" * 60)
print("2. DATA TYPES")
print("=" * 60)
print(df.dtypes)

print("\n" + "=" * 60)
print("3. MISSING VALUES")
print("=" * 60)
missing = df.isnull().sum()
print(missing[missing > 0])

print("\n" + "=" * 60)
print("4. MISSING PERCENTAGE")
print("=" * 60)
miss_pct = (df.isnull().sum() / len(df) * 100).round(2)
print(miss_pct[miss_pct > 0])

print("\n" + "=" * 60)
print("5. DUPLICATE ROWS")
print("=" * 60)
print(f"Duplicates: {df.duplicated().sum()}")

print("\n" + "=" * 60)
print("6. BASIC STATISTICS")
print("=" * 60)
print(df.describe())

print("\n" + "=" * 60)
print("7. UNIQUE VALUES PER COLUMN")
print("=" * 60)
for col in df.columns:
    print(f"  {col}: {df[col].nunique()} unique values")

print("\n" + "=" * 60)
print("8. TOURNAMENT YEARS")
print("=" * 60)
print(df["tournament_name"].unique())

print("\n" + "=" * 60)
print("9. MATCH OUTCOMES")
print("=" * 60)
print(df["outcome"].value_counts())

print("\n" + "=" * 60)
print("10. RESULT VALUES")
print("=" * 60)
print(df["result"].value_counts())