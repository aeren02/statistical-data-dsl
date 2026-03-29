import csv

from tabulate import tabulate
import matplotlib
matplotlib.use('Agg')
import matplotlib.pyplot as plt
import glob
import os

cwd = os.getcwd()
defaultPath = glob.glob(cwd+'/*.csv')[0]
defaultName = []
with open(defaultPath, newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        defaultName.append(row)
    
# visualise defaultName as table
if defaultName:
    _headers = list(defaultName[0].keys())
    _rows = [list(row.values()) for row in defaultName]
    print(tabulate(_rows, headers=_headers, tablefmt='grid'))
else:
    print('No data to display for defaultName.')

# visualise defaultName on Pets using pieChart
if defaultName:
    _counts = {}
    for _row in defaultName:
        _val = _row.get('Pets', 'Unknown')
        _counts[_val] = _counts.get(_val, 0) + 1
    
    _labels = list(_counts.keys())
    _sizes = list(_counts.values())
    
    plt.figure(figsize=(8, 8))
    plt.pie(_sizes, labels=_labels, autopct='%1.1f%%', startangle=140)
    plt.title('Pie Chart of Pets in defaultName', fontsize=16, pad=20)
    plt.axis('equal')
    plt.tight_layout()
    plt.savefig('defaultName_Pets_pie.png', dpi=150)
    plt.close()
    print('Pie chart saved to defaultName_Pets_pie.png')
else:
    print('No data to display for defaultName.')

# visualise defaultName on Employment_status using barChart
if defaultName:
    _counts = {}
    for _row in defaultName:
        _val = _row.get('Employment_status', 'Unknown')
        _counts[_val] = _counts.get(_val, 0) + 1
    
    _labels = list(_counts.keys())
    _values = list(_counts.values())
    
    plt.figure(figsize=(10, 6))
    plt.bar(_labels, _values, color='skyblue', edgecolor='black')
    plt.title('Bar Chart of Employment_status in defaultName', fontsize=16, pad=20)
    plt.xlabel('Employment_status', fontsize=12)
    plt.ylabel('Count', fontsize=12)
    plt.xticks(rotation=45, ha='right')
    plt.tight_layout()
    plt.savefig('defaultName_Employment_status_bar.png', dpi=150)
    plt.close()
    print('Bar chart saved to defaultName_Employment_status_bar.png')
else:
    print('No data to display for defaultName.')
