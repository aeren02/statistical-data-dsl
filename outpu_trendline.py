import csv


employee_data = []
with open("data.csv", newline="") as f:
    reader = csv.DictReader(f)
    for row in reader:
        employee_data.append(row)

# X and Y values
xValues=[]
yValues=[]
for _row in employee_data:
    yValues.append(_row['Income'])
    xs=[]
    for xVal in ["Weight","Age"]:
        xs.append(_row[xVal])
    xValues.append(xs)
# Intercept term
X = sm.add_constant(xValues)
# OLS model
model = sm.OLS(yValues, xValues).fit()
# Print summary
print(model.summary())
