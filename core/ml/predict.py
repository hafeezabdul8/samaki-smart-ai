import joblib
import pandas as pd
import numpy as np
from pathlib import Path
from datetime import date

MODEL_DIR = Path(__file__).resolve().parent / 'models'

# Load real models
price_model = joblib.load(MODEL_DIR / 'price_model_real.joblib')
demand_model = joblib.load(MODEL_DIR / 'demand_model.joblib')
le_species = joblib.load(MODEL_DIR / 'le_species_real.joblib')
le_market = joblib.load(MODEL_DIR / 'le_market_real.joblib')
le_season = joblib.load(MODEL_DIR / 'le_season_real.joblib')
le_weather = joblib.load(MODEL_DIR / 'le_weather_real.joblib')

def get_season(month):
    if month in [12, 1, 2, 3]: return 'Kaskazi'
    elif month in [6, 7, 8, 9]: return 'Kusi'
    else: return 'Transition'

def predict_price(species, market, season, weather, quantity_kg):
    try:
        se = le_species.transform([species])[0]
        me = le_market.transform([market])[0]
        sse = le_season.transform([season])[0]
        we = le_weather.transform([weather])[0]
    except ValueError as e:
        raise ValueError(f'Unknown category: {e}')
    
    month = date.today().month
    X = pd.DataFrame([[se, me, sse, we, quantity_kg, month]],
                     columns=['species_enc', 'market_enc', 'season_enc', 'weather_enc', 'quantity_kg', 'month'])
    return round(float(price_model.predict(X)[0]), 2)

def predict_demand(species, market, season, weather):
    try:
        se = le_species.transform([species])[0]
        me = le_market.transform([market])[0]
        sse = le_season.transform([season])[0]
        we = le_weather.transform([weather])[0]
    except ValueError as e:
        raise ValueError(f'Unknown category: {e}')
    
    month = date.today().month
    X = pd.DataFrame([[se, me, sse, we, month]],
                     columns=['species_enc', 'market_enc', 'season_enc', 'weather_enc', 'month'])
    return round(float(demand_model.predict(X)[0]), 2)

def get_smart_recommendations():
    """Return AI recommendations based on current conditions"""
    today = date.today()
    current_season = get_season(today.month)
    
    recommendations = []
    species_list = le_species.classes_.tolist()
    
    for species in species_list[:6]:  # Top 6 species
        try:
            k_price = predict_price(species, 'Malindi Market', 'Kaskazi', 'Calm', 50)
            ku_price = predict_price(species, 'Malindi Market', 'Kusi', 'Windy', 50)
            t_price = predict_price(species, 'Malindi Market', current_season, 'Sunny', 50)
            demand = predict_demand(species, 'Malindi Market', current_season, 'Sunny')
            
            price_trend = 'rising' if ku_price > k_price else 'stable'
            pct_change = round(((ku_price - k_price) / k_price) * 100, 1)
            
            recommendations.append({
                'species': species,
                'current_price': t_price,
                'kaskazi_price': k_price,
                'kusi_price': ku_price,
                'price_trend': price_trend,
                'pct_change': pct_change,
                'predicted_demand_kg': demand,
                'recommendation': 'High value in Kusi' if pct_change > 5 else 'Stable year-round' if abs(pct_change) < 5 else 'Better in Kaskazi'
            })
        except:
            pass
    
    return recommendations
