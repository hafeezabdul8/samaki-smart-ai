import pandas as pd
import joblib
from sklearn.model_selection import train_test_split
from sklearn.ensemble import RandomForestRegressor
from sklearn.preprocessing import LabelEncoder
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent
MODEL_DIR = BASE_DIR / 'core' / 'ml' / 'models'
MODEL_DIR.mkdir(exist_ok=True)

def train():
    # Load data
    df = pd.read_csv(BASE_DIR / 'samaki_smart_ai_dataset.csv')
    
    # Encode categorical columns
    le_species = LabelEncoder()
    le_market = LabelEncoder()
    le_season = LabelEncoder()
    le_weather = LabelEncoder()
    
    df['species_enc'] = le_species.fit_transform(df['species'])
    df['market_enc'] = le_market.fit_transform(df['market'])
    df['season_enc'] = le_season.fit_transform(df['season'])
    df['weather_enc'] = le_weather.fit_transform(df['weather'])
    
    # Features and target
    features = ['species_enc', 'market_enc', 'season_enc', 'weather_enc', 'quantity_kg']
    X = df[features]
    y = df['price_per_kg_tzs']
    
    # Train/test split
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)
    
    # Train model
    model = RandomForestRegressor(n_estimators=100, random_state=42, n_jobs=-1)
    model.fit(X_train, y_train)
    
    # Score
    score = model.score(X_test, y_test)
    print(f'Model R² score: {score:.4f}')
    
    # Save model and encoders
    joblib.dump(model, MODEL_DIR / 'price_model.joblib')
    joblib.dump(le_species, MODEL_DIR / 'le_species.joblib')
    joblib.dump(le_market, MODEL_DIR / 'le_market.joblib')
    joblib.dump(le_season, MODEL_DIR / 'le_season.joblib')
    joblib.dump(le_weather, MODEL_DIR / 'le_weather.joblib')
    
    print('Model and encoders saved.')

if __name__ == '__main__':
    train()
