import os
import logging
import matplotlib.pyplot as plt
import seaborn as sns

logger = logging.getLogger(__name__)

def generate_and_save_plots(df, output_dir='capstone_part2'):
    """Creates and saves three key visualizations highlighting traffic trends."""
    os.makedirs(output_dir, exist_ok=True)
    sns.set_theme(style="whitegrid")
    
    # Plot 1: Traffic Demand by Hour of Day
    plt.figure(figsize=(10, 6))
    sns.lineplot(data=df, x='hour', y='traffic_volume', errorbar=None, marker='o', color='royalblue')
    plt.title('Traffic Volume patterns by Hour of Day', fontsize=14)
    plt.xlabel('Hour of Day', fontsize=12)
    plt.ylabel('Average Traffic Volume', fontsize=12)
    plot_1_path = os.path.join(output_dir, 'traffic_by_hour.png')
    plt.tight_layout()
    plt.savefig(plot_1_path, dpi=300)
    plt.close()
    logger.info("Successfully saved figure: %s", plot_1_path)

    # Plot 2: Weekday vs Weekend average traffic
    plt.figure(figsize=(8, 6))
    sns.barplot(data=df, x='is_weekend', y='traffic_volume', palette='muted')
    plt.title('Average Traffic Volume: Weekdays (0) vs Weekends (1)', fontsize=14)
    plt.xlabel('Weekend Indicator', fontsize=12)
    plt.ylabel('Average Traffic Volume', fontsize=12)
    plot_2_path = os.path.join(output_dir, 'weekday_vs_weekend.png')
    plt.tight_layout()
    plt.savefig(plot_2_path, dpi=300)
    plt.close()
    logger.info("Successfully saved figure: %s", plot_2_path)

    # Plot 3: Traffic Volume Distribution across Weather Conditions
    plt.figure(figsize=(12, 6))
    order = df.groupby('weather_main')['traffic_volume'].median().sort_values(ascending=False).index
    sns.boxplot(data=df, x='weather_main', y='traffic_volume', order=order, palette='Set2')
    plt.title('Traffic Volume Distribution Across Weather Conditions', fontsize=14)
    plt.xticks(rotation=45)
    plt.xlabel('Weather Condition', fontsize=12)
    plt.ylabel('Traffic Volume', fontsize=12)
    plot_3_path = os.path.join(output_dir, 'traffic_by_weather.png')
    plt.tight_layout()
    plt.savefig(plot_3_path, dpi=300)
    plt.close()
    logger.info("Successfully saved figure: %s", plot_3_path)
