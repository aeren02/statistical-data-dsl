import csv

import statsmodels.api as sm
import glob
import os

cwd = os.getcwd()
defaultPath = glob.glob(cwd+'/*.csv')[0]
defaultName = []
with open(defaultPath, newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        defaultName.append(row)
    
# X and Y values
xValues=[]
yValues=[]
for _row in defaultName:
    yValues.append( float(_row['Income']) if (_row['Income']!="" ) else 0.0 )
    xs=[]
    for xVal in ["Weight","Age"]:
        xs.append(float(_row[xVal]) if (_row[xVal]!="") else 0.0)
    xValues.append(xs)
# Intercept term
X = sm.add_constant(xValues)
# OLS model
model = sm.OLS(yValues, xValues).fit()
# Print summary
print(model.summary())
