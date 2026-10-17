import logging
import numpy as np
import pandas as pd

logger = logging.getLogger(__name__)

def create_features(df):
    """Generates high-quality ML-ready features from cleaned data."""
    logger.info("Shape of dataset BEFORE feature engineering: %s", df.shape)
    df = df.copy()
    
    # 1. Time Features
    logger.info("Generating time features (Hour, Day of week, Weekend indicator, Cyclical encoding)")
    df['hour'] = df['date_time'].dt.hour
    df['day_of_week'] = df['date_time'].dt.dayofweek
    df['is_weekend'] = (df['day_of_week'] >= 5).astype(int)
    
    # Cyclical hour encoding
    df['hour_sin'] = np.sin(2 * np.pi * df['hour'] / 24.0)
    df['hour_cos'] = np.cos(2 * np.pi * df['hour'] / 24.0)
    
    # 2. Weather features
    logger.info("Generating weather-related features")
    # One-hot encode the categorical 'weather_main' variable
    weather_dummies = pd.get_dummies(df['weather_main'], prefix='weather', drop_first=True)
    df = pd.concat([df, weather_dummies], axis=1)
    
    # Derived indicator: Is bad weather (Rainy or Snowy or extreme conditions)
    bad_weather_keywords = ['Rain', 'Snow', 'Thunderstorm', 'Squall']
    df['is_bad_weather'] = df['weather_main'].isin(bad_weather_keywords).astype(int)

    # 3. Numerical Features (Scaled versions of temp and clouds_all)
    logger.info("Scaling continuous variables (temp, clouds_all)")
    # Mean-variance scaling (Standardization)
    for col in ['temp', 'clouds_all']:
        col_mean = df[col].mean()
        col_std = df[col].std()
        logger.debug("Calculating scaling factors for %s: mean=%.2f, std=%.2f", col, col_mean, col_std)
        df[f'{col}_scaled'] = (df[col] - col_mean) / (col_std if col_std != 0 else 1.0)

    # 4. Traffic target: congestion category
    # Let's calculate the quartile thresholds and log them at DEBUG level
    q1 = df['traffic_volume'].quantile(0.25)
    q2 = df['traffic_volume'].quantile(0.50)
    q3 = df['traffic_volume'].quantile(0.75)
    logger.debug("Quartile thresholds for traffic volume: Q1=%.1f, Q2=%.1f, Q3=%.1f", q1, q2, q3)
    
    def get_congestion_category(volume):
        if volume <= q1:
            return 'Low'
        elif volume <= q2:
            return 'Moderate'
        elif volume <= q3:
            return 'Heavy'
        else:
            return 'Severe'
            
    df['congestion_category'] = df['traffic_volume'].apply(get_congestion_category)
    logger.info("Successfully created congestion_category based on data-driven quartiles.")
    
    logger.info("Shape of dataset AFTER feature engineering: %s", df.shape)
    return df
