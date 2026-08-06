import pandas as pd
import numpy as np
import joblib
from sklearn.model_selection import train_test_split, cross_val_score
from sklearn.ensemble import RandomForestRegressor, GradientBoostingRegressor
from sklearn.preprocessing import LabelEncoder
from sklearn.metrics import mean_absolute_error, r2_score
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent.parent
MODEL_DIR = BASE_DIR / 'core' / 'ml' / 'models'
MODEL_DIR.mkdir(exist_ok=True)

def train_models():
    df = pd.read_csv(BASE_DIR / 'samaki_real_data.csv')
    
    # Feature engineering
    df['date'] = pd.to_datetime(df['date'])
    df['month'] = df['date'].dt.month
    df['day_of_week'] = df['date'].dt.dayofweek
    
    # Encode
    le_species = LabelEncoder()
    le_market = LabelEncoder()
    le_season = LabelEncoder()
    le_weather = LabelEncoder()
    
    df['species_enc'] = le_species.fit_transform(df['species'])
    df['market_enc'] = le_market.fit_transform(df['market'])
    df['season_enc'] = le_season.fit_transform(df['season'])
    df['weather_enc'] = le_weather.fit_transform(df['weather'])
    
    # Features for price prediction
    price_features = ['species_enc', 'market_enc', 'season_enc', 'weather_enc', 'quantity_kg', 'month']
    X_price = df[price_features]
    y_price = df['price_per_kg_tzs']
    
    # Train price model
    X_train, X_test, y_train, y_test = train_test_split(X_price, y_price, test_size=0.2, random_state=42)
    
    price_model = RandomForestRegressor(n_estimators=200, max_depth=12, random_state=42, n_jobs=-1)
    price_model.fit(X_train, y_train)
    
    price_score = price_model.score(X_test, y_test)
    price_mae = mean_absolute_error(y_test, price_model.predict(X_test))
    
    print(f'Price Model R²: {price_score:.4f}')
    print(f'Price MAE: TZS {price_mae:.0f}')
    
    # Feature importance for explainability
    importances = price_model.feature_importances_
    for feat, imp in zip(price_features, importances):
        print(f'  {feat}: {imp:.4f}')
    
    # Train demand model (predict quantity based on season, weather, species)
    demand_features = ['species_enc', 'market_enc', 'season_enc', 'weather_enc', 'month']
    X_demand = df[demand_features]
    y_demand = df['quantity_kg']
    
    Xd_train, Xd_test, yd_train, yd_test = train_test_split(X_demand, y_demand, test_size=0.2, random_state=42)
    
    demand_model = RandomForestRegressor(n_estimators=150, max_depth=10, random_state=42, n_jobs=-1)
    demand_model.fit(Xd_train, yd_train)
    
    demand_score = demand_model.score(Xd_test, yd_test)
    print(f'\nDemand Model R²: {demand_score:.4f}')
    
    # Save models
    joblib.dump(price_model, MODEL_DIR / 'price_model_real.joblib')
    joblib.dump(demand_model, MODEL_DIR / 'demand_model.joblib')
    joblib.dump(le_species, MODEL_DIR / 'le_species_real.joblib')
    joblib.dump(le_market, MODEL_DIR / 'le_market_real.joblib')
    joblib.dump(le_season, MODEL_DIR / 'le_season_real.joblib')
    joblib.dump(le_weather, MODEL_DIR / 'le_weather_real.joblib')
    
    print('\nModels saved successfully!')
    
    # Demonstrate seasonal intelligence
    print('\n=== Seasonal Price Intelligence ===')
    for season in ['Kaskazi', 'Kusi', 'Transition']:
        se = le_season.transform([season])[0]
        sample = pd.DataFrame([[le_species.transform(['Yellowfin Tuna'])[0], 
                               le_market.transform(['Malindi Market'])[0],
                               se, le_weather.transform(['Sunny'])[0], 50, 6]],
                             columns=price_features)
        pred = price_model.predict(sample)[0]
        print(f'{season}: TZS {pred:,.0f}/kg for Tuna')
    
    # Trend recommendation
    print('\n=== Smart Recommendations ===')
    for species in ['Octopus/Squid', 'Lobster', 'Yellowfin Tuna', 'Anchovy']:
        se = le_species.transform([species])[0]
        kaskazi_sample = pd.DataFrame([[se, le_market.transform(['Malindi Market'])[0],
                                       le_season.transform(['Kaskazi'])[0], 
                                       le_weather.transform(['Calm'])[0], 30, 1]],
                                     columns=price_features)
        kusi_sample = pd.DataFrame([[se, le_market.transform(['Malindi Market'])[0],
                                    le_season.transform(['Kusi'])[0], 
                                    le_weather.transform(['Windy'])[0], 30, 7]],
                                   columns=price_features)
        k_price = price_model.predict(kaskazi_sample)[0]
        ku_price = price_model.predict(kusi_sample)[0]
        diff = ((ku_price - k_price) / k_price) * 100
        print(f'{species}: Kaskazi=TZS {k_price:,.0f}, Kusi=TZS {ku_price:,.0f} (+{diff:.0f}%)')

if __name__ == '__main__':
    train_models()
