# Traffic Analytics & Processing Data Pipeline

## Project Structure
- `pipeline.py`: Handles raw CSV data loading, schema validation, duplicate cleaning, and grouped outlier imputations.
- `feature_engineering.py`: Computes cyclical time features, weather category encoders, standardized continuous variables, and quantile-based data-driven traffic congestion targets.
- `visualizations.py`: Generates analytics figures on traffic behavior over hours, weekends vs. weekdays, and weather classes.
- `app.py`: CLI tool for querying records, comparing statistics, and parsing thresholds.
- `pipeline.log`: Historical tracing logs containing debugging, status info, warning, and error events.

## Setup and Usage
Run the analytical CLI with commands such as:
```bash
python capstone_part2/app.py weekday-vs-weekend
python capstone_part2/app.py query-datetime --dt "2012-10-02 09:00:00"
python capstone_part2/app.py high-traffic --threshold 5000
