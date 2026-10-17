import sys
import os
import logging
import pandas as pd

# Setup logger to write logs and user output separately
logger = logging.getLogger('cli_app')

def init_logging(debug_mode=False):
    log_level = logging.DEBUG if debug_mode else logging.INFO
    formatter = logging.Formatter('%(asctime)s [%(levelname)s] %(name)s: %(message)s')
    
    # Console Handler
    console_handler = logging.StreamHandler(sys.stderr) # Logging details to stderr
    console_handler.setFormatter(formatter)
    console_handler.setLevel(log_level)
    
    # File Handler
    file_handler = logging.FileHandler('pipeline.log', mode='a')
    file_handler.setFormatter(formatter)
    file_handler.setLevel(log_level)
    
    root_logger = logging.getLogger()
    root_logger.setLevel(log_level)
    root_logger.addHandler(console_handler)
    root_logger.addHandler(file_handler)

def load_processed_data():
    data_path = 'capstone_part2/featured_traffic_data.csv'
    if not os.path.exists(data_path):
        raise FileNotFoundError(f"Processed dataset not found at {data_path}. Please run the pipeline first.")
    return pd.read_csv(data_path)

def main():
    import argparse
    parser = argparse.ArgumentParser(description="Mini Traffic Analytics CLI Application")
    parser.add_argument('--debug', action='store_true', help="Enable debug logging mode")
    
    subparsers = parser.add_subparsers(dest='command', help='CLI command options')
    
    # Command 1: query-datetime
    parser_query = subparsers.add_parser('query-datetime', help='Query traffic details for a specific datetime.')
    parser_query.add_argument('--dt', required=True, help='Datetime to search for (YYYY-MM-DD HH:MM:S)')
    
    # Command 2: high-traffic
    parser_high = subparsers.add_parser('high-traffic', help='Retrieve time windows exceeding a congestion threshold.')
    parser_high.add_argument('--threshold', type=int, default=5000, help='Volume threshold (default: 5000)')
    
    # Command 3: weekday-vs-weekend
    subparsers.add_parser('weekday-vs-weekend', help='Compare and contrast average traffic volume.')

    args = parser.parse_args()
    
    # Initialise logging based on user preference
    init_logging(debug_mode=args.debug)
    
    if not args.command:
        parser.print_help()
        sys.exit(0)
        
    logger.info("Command invoked: %s with arguments: %s", args.command, {k: v for k, v in vars(args).items() if k != 'command'})
    
    try:
        df = load_processed_data()
    except Exception as e:
        logger.error("Unable to launch CLI due to file access error: %s", str(e))
        print(f"[ERROR] Codebase or data issue: {e}", file=sys.stderr)
        sys.exit(1)

    if args.command == 'query-datetime':
        try:
            target_dt = pd.to_datetime(args.dt)
            # Query matching hour
            df['date_time_dt'] = pd.to_datetime(df['date_time'])
            match = df[df['date_time_dt'] == target_dt]
            if match.empty:
                print(f"No records found matching date and time: {args.dt}")
            else:
                row = match.iloc[0]
                print("\n--- Query Result ---")
                print(f"Datetime:        {row['date_time']}")
                print(f"Traffic Volume:  {row['traffic_volume']}")
                print(f"Congestion Level:{row['congestion_category']}")
                print(f"Weather:         {row['weather_main']} ({row['weather_description']})")
                print(f"Temperature:     {row['temp']} K")
        except Exception as e:
            logger.error("Invalid datetime input format supplied: %s. Exception: %s", args.dt, str(e))
            print(f"[ERROR] Invalid argument format: '{args.dt}'. Please use YYYY-MM-DD HH:MM:SS format.", file=sys.stderr)
            sys.exit(1)
            
    elif args.command == 'high-traffic':
        try:
            threshold = int(args.threshold)
            subset = df[df['traffic_volume'] >= threshold]
            print(f"\n--- Found {len(subset)} records exceeding volume threshold of {threshold} ---")
            if not subset.empty:
                display_cols = ['date_time', 'traffic_volume', 'congestion_category', 'weather_main']
                print(subset[display_cols].head(15).to_string(index=False))
        except Exception as e:
            logger.error("Invalid threshold argument format supplied: %s. Exception: %s", args.threshold, str(e))
            print(f"[ERROR] Invalid threshold argument: '{args.threshold}' must be an integer.", file=sys.stderr)
            sys.exit(1)

    elif args.command == 'weekday-vs-weekend':
        stats = df.groupby('is_weekend')['traffic_volume'].agg(['mean', 'median', 'max', 'min'])
        print("\n--- Traffic comparison Weekdays (0) vs Weekends (1) ---")
        print(stats.to_string())

if __name__ == '__main__':
    main()
