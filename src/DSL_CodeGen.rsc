module DSL_CodeGen

import DSL_AST;
import DSL_Transformation;
import String;
import List;
import util::Maybe;

str generate(ASTProgram program) {
    str code = "import csv\n\n";
    bool needsTabulate = false;
    bool needsMatplotlib = false;
    bool needsNumpy = false;
    bool needsSm = false;
    bool needsLoading = true;
    for (cmd <- program.commands) {
        if (cmd is visualise) {
            needsTabulate = true;
        }
        if (cmd is visualiseUsing) {
            str vt = cmd.vizType;
            if (vt == "table") needsTabulate = true;
            if (vt == "table_image") needsMatplotlib = true;
        }
        if (cmd is visualisePie) {
            needsMatplotlib = true;
        }
        if (cmd is visualiseBar) {
            needsMatplotlib = true;
        }
        if (cmd is visualiseTrend) {
            needsMatplotlib = true;
            needsNumpy = true;
        }
        if ((cmd is linReg) && (cmd is multiLinReg)) {
            needsSm = true;
        }
        if (cmd is visualiseTrend) {
            needsMatplotlib = true;
            needsNumpy = true;
        }
        if (cmd is load) {
            needsLoading = false;
        }
    }
    
    if (needsTabulate) code += "from tabulate import tabulate\n";
    if (needsSm) code += "import statsmodels.api as sm\n";
    if (needsMatplotlib) {
        code += "import matplotlib\n";
        code += "matplotlib.use(\'Agg\')\n";
        code += "import matplotlib.pyplot as plt\n";
    }
    if (needsNumpy) {
        code += "import numpy as np\n";
    }
    if (needsLoading){
        code += 
        "import glob
import os

cwd = os.getcwd()
defaultPath = glob.glob(cwd+\'/*.csv\')[0]
defaultName = []
with open(defaultPath, newline=\"\") as f:
    reader = csv.DictReader(f)
    for row in reader:
        defaultName.append(row)
    ";
    } 


    for (cmd <- program.commands) {
        code += genCommand(cmd);
    }

    return code;
}

str genCommand(ASTCommand command) {
    switch (command) {
        case load(path, name): {
            return genLoad(path, name);
        }
        case constrain(source, target, conditions): {
            return genConstrain(source, target, conditions);
        }
        case linReg(source, yVal, xVals): {
            return genLinReg(source, yVal, xVals);
        }
        case multiLinReg(source, yVal, xVals): {
            return genLinReg(source, yVal, xVals);
        }
        case visualise(name): {
            return genVisualise(name, "default");
        }
        case visualiseUsing(name, vizType): {
            return genVisualise(name, vizType);            
        }
        case visualisePie(name, col): {
            return genVisualisePie(name, col);
        }
        case visualiseBar(name, col): {
            return genVisualiseBar(name, col);
        }
        case visualiseTrend(name, xCol, yCol): {
            return genVisualiseTrend(name, xCol, yCol);
        }
        case rename(source, oldCol, newCol): {
            return genRename(source, oldCol, newCol);
        }
        case sortAsc(source, col, t): {
            return genSort(source, col, t, false);
        }
        case sortDesc(source, col, t): {
            return genSort(source, col, t, true);
        }
        case groupByCount(source, groupCol): {
            return genGroupByCount(source, groupCol);
        }
        case groupByAgg(source, groupCol, aggType, valueCol, valType): {
            return genGroupByAgg(source, groupCol, aggType, valueCol, valType);
        }
        default: throw "Unknown command when generating code";
    }
}
str genLinReg(str source,str yVal, list[str]  xVals) {
    return "
# X and Y values
xValues=[]
yValues=[]
for _row in <source>:
    yValues.append(_row[\'<yVal>\'])
    xs=[]
    for xVal in <xVals>:
        xs.append(_row[xVal])
    xValues.append(xs)
# Intercept term
X = sm.add_constant(xValues)
# OLS model
model = sm.OLS(yValues, xValues).fit()
# Print summary
print(model.summary())
";
}

str genLoad(str path, str name) {
    return "
<name> = []
with open(\"<path>\", newline=\"\") as f:
    reader = csv.DictReader(f)
    for row in reader:
        <name>.append(row)
";
}

str genConstrain(str source, str target, list[ASTCondition] conditions) {
    str rows = genRowsConstrain(conditions);
    list[str] condList = [s | just(s) <- [genCondition(c) | c <- conditions]];
    str conds = intercalate(
        " and\n",
        ["      " + cond | cond <- condList]
    );

    return "
<target>_filters = <rows>
<target> = []
for row in <source>:
    if (
<conds>
    ):
        filtered_row = {col:row[col] for col in <target>_filters}
        <target>.append(filtered_row)
";
}

// placeholder "default" for when user does not specify type. Feel free to change
str genVisualise(str dataName, str vizType) {
    if (vizType == "table_image") return genVisualiseTableImage(dataName);
    return genVisualiseTable(dataName);
}

str genVisualiseTable(str dataName) {
    return
    
"
# visualise <dataName> as table
if <dataName>:
    _headers = list(<dataName>[0].keys())
    _rows = [list(row.values()) for row in <dataName>]
    print(tabulate(_rows, headers=_headers, tablefmt=\'grid\'))
else:
    print(\'No data to display for <dataName>.\')
";
}

str genVisualiseTableImage(str dataName) {
    return

"
# visualise <dataName> as table image
if <dataName>:
    _headers = list(<dataName>[0].keys())
    _rows = [list(row.values()) for row in <dataName>]
    _num_cols = len(_headers)
    _num_rows = len(_rows)
    _fig_width = max(8, _num_cols * 2.0)
    _fig_height = max(2, (_num_rows + 1) * 0.5)
    _fig, _ax = plt.subplots(figsize=(_fig_width, _fig_height))
    _ax.axis(\'off\')
    _ax.axis(\'tight\')
    _tbl = _ax.table(
        cellText=_rows,
        colLabels=_headers,
        cellLoc=\'center\',
        loc=\'center\'
    )
    _tbl.auto_set_font_size(False)
    _tbl.set_fontsize(10)
    _tbl.auto_set_column_width(col=list(range(_num_cols)))
    for (row_idx, col_idx), cell in _tbl.get_celld().items():
        if row_idx == 0:
            cell.set_facecolor(\'#4472C4\')
            cell.set_text_props(color=\'white\', fontweight=\'bold\')
        elif row_idx % 2 == 0:
            cell.set_facecolor(\'#D9E2F3\')
        else:
            cell.set_facecolor(\'#FFFFFF\')
        cell.set_edgecolor(\'#BFBFBF\')
    plt.title(\'<dataName>\', fontsize=14, fontweight=\'bold\', pad=20)
    plt.tight_layout()
    plt.savefig(\'<dataName>_table.png\', dpi=150, bbox_inches=\'tight\')
    plt.close()
    print(\'Table image saved to <dataName>_table.png\')
else:
    print(\'No data to display for <dataName>.\')
";
}

str genVisualisePie(str dataName, str col) {
    return

"
# visualise <dataName> on <col> using pieChart
if <dataName>:
    _counts = {}
    for _row in <dataName>:
        _val = _row.get(\'<col>\', \'Unknown\')
        _counts[_val] = _counts.get(_val, 0) + 1
    
    _labels = list(_counts.keys())
    _sizes = list(_counts.values())
    
    plt.figure(figsize=(8, 8))
    plt.pie(_sizes, labels=_labels, autopct=\'%1.1f%%\', startangle=140)
    plt.title(\'Pie Chart of <col> in <dataName>\', fontsize=16, pad=20)
    plt.axis(\'equal\')
    plt.tight_layout()
    plt.savefig(\'<dataName>_<col>_pie.png\', dpi=150)
    plt.close()
    print(\'Pie chart saved to <dataName>_<col>_pie.png\')
else:
    print(\'No data to display for <dataName>.\')
";
}

str genVisualiseBar(str dataName, str col) {
    return

"
# visualise <dataName> on <col> using barChart
if <dataName>:
    _counts = {}
    for _row in <dataName>:
        _val = _row.get(\'<col>\', \'Unknown\')
        _counts[_val] = _counts.get(_val, 0) + 1
    
    _labels = list(_counts.keys())
    _values = list(_counts.values())
    
    plt.figure(figsize=(10, 6))
    plt.bar(_labels, _values, color=\'skyblue\', edgecolor=\'black\')
    plt.title(\'Bar Chart of <col> in <dataName>\', fontsize=16, pad=20)
    plt.xlabel(\'<col>\', fontsize=12)
    plt.ylabel(\'Count\', fontsize=12)
    plt.xticks(rotation=45, ha=\'right\')
    plt.tight_layout()
    plt.savefig(\'<dataName>_<col>_bar.png\', dpi=150)
    plt.close()
    print(\'Bar chart saved to <dataName>_<col>_bar.png\')
else:
    print(\'No data to display for <dataName>.\')
";
}

Maybe[str] genCondition(ASTCondition c) {
    switch(c) {
        case inList(col, t, values):
            return just("<genTypedAccess(col, t)> in <genList(values)>");
        case greaterEq(col, t, v):
            return just("<genTypedAccess(col, t)> \>= <genValue(v)>");
        case greater(col, t, v):
            return just("<genTypedAccess(col, t)> \> <genValue(v)>");
        case lessEq(col, t, v):
            return just("<genTypedAccess(col, t)> \<= <genValue(v)>");
        case less(col, t, v):
            return just("<genTypedAccess(col, t)> \< <genValue(v)>");
        case equals(col, t, v):
            return just("<genTypedAccess(col, t)> == <genValue(v)>");
        case dropna(col, t):
            return just("str(row[\"<col>\"]).strip() != \'\'");
        case keep(_, _):
            return nothing(); 
        default: throw "Unknown Condition";
    }
}

str genValue(ASTValue v) {
    switch(v) {
        case intVal(i): return "<i>";
        case floatVal(f): return "<f>";
        case stringVal(s): return "\"<s>\"";
        case boolVal(b): return b ? "True" : "False";
        case arrayVal(arr): return genList(arr);
        default: throw "Unknown type";
    }
}

str genList(list[ASTValue] values) {
    return "[" + intercalate(", ", [ genValue(v) | v <- values]) + "]";
}

str genTypedAccess(str col, ASTType t) {
    switch(t) {
        case intType():
            return "int(row[\"<col>\"])";
        case floatType():
            return "float(row[\"<col>\"])";
        case stringType():
            return "row[\"<col>\"]";
        case boolType():
            return "row[\"<col>\"] == \"true\"";
        default: throw "Unknown Typed Access";
    }
}

str getColumn(ASTCondition cond) {
    switch (cond) {
        case inList(col, _, _): return col;
        case greaterEq(col, _, _): return col;
        case greater(col, _, _): return col;
        case lessEq(col, _, _): return col;
        case less(col, _, _): return col;
        case equals(col, _, _): return col;
        case keep(col, _): return col;
        case dropna(col, _): return col;
        default: throw "Unknown condition";
    }
}

str genRowsConstrain(list[ASTCondition] conditions) {
    list[str] values = [getColumn(c) | c <- conditions];
    return "[" + intercalate(", ", ["\"<c>\"" | c <- values]) + "]";
}

// rename oldCol to newCol in source
str genRename(str source, str oldCol, str newCol) {
    return
"
for _row in <source>:
    _row[\'<newCol>\'] = _row.pop(\'<oldCol>\')
";
}

// sort source by col of type t, descending if specified
str genSort(str source, str col, ASTType t, bool descending) {
    str access = genTypedAccess(col, t);
    str rev = descending ? "True" : "False";
    return
"
<source>.sort(key=lambda row: <access>, reverse=<rev>)
";
}

// group cource by col, count occurences
str genGroupByCount(str source, str groupCol) {
    return
"
_groups = {}
for _row in <source>:
    _key = _row[\'<groupCol>\']
    _groups[_key] = _groups.get(_key, 0) + 1
print(\'GroupBy <groupCol> (count):\')
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {_groups[_key]}\')
";
}

// group source by aggregation (sum, avg, min, max)
str genGroupByAgg(str source, str groupCol, ASTAggType aggType, str valueCol, ASTType valType) {
    str typeFunc = genTypeFunc(valType);
    str aggName = getAggName(aggType);

    if (aggType == aggAvg()) {
        return genGroupByAvg(source, groupCol, valueCol, typeFunc);
    }
    if (aggType == aggMin()) {
        return genGroupByMinMax(source, groupCol, valueCol, typeFunc, "min", "\<");
    }
    if (aggType == aggMax()) {
        return genGroupByMinMax(source, groupCol, valueCol, typeFunc, "max", "\>");
    }
    // default: sum
    return genGroupBySum(source, groupCol, valueCol, typeFunc);
}

// GroupBy: <source> by <groupCol> (sum <valueCol>)
str genGroupBySum(str source, str groupCol, str valueCol, str typeFunc) {
    return
"
_groups = {}
for _row in <source>:
    _key = _row[\'<groupCol>\']
    _val = <typeFunc>(_row[\'<valueCol>\'])
    _groups[_key] = _groups.get(_key, 0) + _val
print(\'GroupBy <groupCol> (sum <valueCol>):\')
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {_groups[_key]}\')
";
}

// GroupBy: <source> by <groupCol> (avg <valueCol>)
str genGroupByAvg(str source, str groupCol, str valueCol, str typeFunc) {
    return
"
_groups = {}
_counts = {}
for _row in <source>:
    _key = _row[\'<groupCol>\']
    _val = <typeFunc>(_row[\'<valueCol>\'])
    _groups[_key] = _groups.get(_key, 0) + _val
    _counts[_key] = _counts.get(_key, 0) + 1
print(\'GroupBy <groupCol> (avg <valueCol>):\')
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {_groups[_key] / _counts[_key]}\')
";
}

// GroupBy: <source> by <groupCol> (<aggName> <valueCol>)
str genGroupByMinMax(str source, str groupCol, str valueCol, str typeFunc, str aggName, str op) {
    return
"
_groups = {}
for _row in <source>:
    _key = _row[\'<groupCol>\']
    _val = <typeFunc>(_row[\'<valueCol>\'])
    if _key not in _groups or _val <op> _groups[_key]:
        _groups[_key] = _val
print(\'GroupBy <groupCol> (<aggName> <valueCol>):\')
for _key in sorted(_groups.keys()):
    print(f\'  {_key}: {_groups[_key]}\')
";
}

// helper: get just the Python type function name
str genTypeFunc(ASTType t) {
    switch(t) {
        case intType(): return "int";
        case floatType(): return "float";
        case stringType(): return "str";
        case boolType(): return "bool";
        default: throw "Unknown type for aggregation";
    }
}

// helper: get aggregation name as string
str getAggName(ASTAggType aggType) {
    switch(aggType) {
        case aggSum(): return "sum";
        case aggAvg(): return "avg";
        case aggMin(): return "min";
        case aggMax(): return "max";
        default: throw "Unknown aggregation type";
    }
}

str genVisualiseTrend(str dataName, str xCol, str yCol) {
    return
"
# visualise <dataName> on <xCol> vs <yCol> using trendLine
if <dataName>:
    try:
        _x = [float(_row.get(\'<xCol>\', 0)) for _row in <dataName>]
        _y = [float(_row.get(\'<yCol>\', 0)) for _row in <dataName>]
        
        plt.figure(figsize=(10, 6))
        plt.scatter(_x, _y, color=\'blue\', alpha=0.5, label=\'Data Points\')
        
        _m, _b = np.polyfit(_x, _y, 1)
        _trend_y = [_m * xi + _b for xi in _x]
        plt.plot(_x, _trend_y, color=\'red\', linewidth=2, label=\'Trend Line (OLS)\')
        
        plt.title(\'Scatter Plot with Trend Line: <xCol> vs <yCol>\', fontsize=16, pad=20)
        plt.xlabel(\'<xCol>\', fontsize=12)
        plt.ylabel(\'<yCol>\', fontsize=12)
        plt.legend()
        plt.tight_layout()
        plt.savefig(\'<dataName>_<xCol>_vs_<yCol>_trend.png\', dpi=150)
        plt.close()
        print(f\'Trend line plot saved to <dataName>_<xCol>_vs_<yCol>_trend.png\')
    except Exception as e:
        print(f\'Could not plot trendline for <xCol> vs <yCol>. Make sure both columns contain numeric data! Error: {e}\')
else:
    print(\'No data to display for <dataName>.\')
";
}
