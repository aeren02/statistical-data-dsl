import csv

import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import numpy as np
import glob
import os

cwd = os.getcwd()
defaultPath = glob.glob(cwd+'/*.csv')[0]
defaultName = []
with open(defaultPath, newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        defaultName.append(row)
    
target_filters = ["Income", "Age"]
target = []
for row in defaultName:
    if (
      str(row["Income"]).strip() != ''
    ):
        filtered_row = {col:row[col] for col in target_filters}
        target.append(filtered_row)
defaultName = target

# visualise defaultName on Age vs Income using trendLine
if defaultName:
    try:
        _x = [float(_row.get('Age', 0)) for _row in defaultName]
        _y = [float(_row.get('Income', 0)) for _row in defaultName]
        
        plt.figure(figsize=(10, 6))
        plt.scatter(_x, _y, color='blue', alpha=0.5, label='Data Points')
        
        _m, _b = np.polyfit(_x, _y, 1)
        _trend_y = [_m * xi + _b for xi in _x]
        plt.plot(_x, _trend_y, color='red', linewidth=2, label='Trend Line (OLS)')
        
        plt.title('Scatter Plot with Trend Line: Age vs Income', fontsize=16, pad=20)
        plt.xlabel('Age', fontsize=12)
        plt.ylabel('Income', fontsize=12)
        plt.legend()
        plt.tight_layout()
        plt.savefig('defaultName_Age_vs_Income_trend.png', dpi=150)
        plt.close()
        print(f'Trend line plot saved to defaultName_Age_vs_Income_trend.png')
    except Exception as e:
        print(f'Could not plot trendline for Age vs Income. Make sure both columns contain numeric data! Error: {e}')
else:
    print('No data to display for defaultName.')
