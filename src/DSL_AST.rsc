module DSL_AST

data ASTProgram
  = program(list[ASTCommand] commands);

data ASTCommand
  = load(str path, str name)
  | constrain(str source, str target, list[ASTCondition] conditions)
  | constrainD( list[ASTCondition] conditions)
  | visualise(str name)
  | visualiseD()
  | visualiseUsing(str name, str vizType)
  | visualiseUsingD( str vizType)
  | rename(str source, str oldCol, str newCol)
  | renameD( str oldCol, str newCol)
  | sortAsc(str source, str col, ASTType t)
  | sortAscD( str col, ASTType t)
  | sortDesc(str source, str col, ASTType t)
  | sortDescD( str col, ASTType t)
  | groupByCount(str source, str groupCol)
  | groupByCountD( str groupCol)
  | groupByAgg(str source, str groupCol, ASTAggType aggType, str valueCol, ASTType valType)
  | groupByAggD( str groupCol, ASTAggType aggType, str valueCol, ASTType valType)
  | visualisePie(str name, str col)
  | visualisePieD( str col)
  | visualiseBar(str name, str col)
  | visualiseBarD( str col)
  | visualiseTrend(str name, str xCol, str yCol)
  | visualiseTrendD( str xCol, str yCol)
  | linReg(str source, str yVal, list[str] xVals)
  | linRegD( str yVal, list[str] xVals)
  | multiLinReg(str source, str yVal, list[str] xVals)
  | multiLinRegD( str yVal, list[str] xVals)
  ;

data ASTCondition
  = inList(str column, ASTType t, list[ASTValue] values)
  | greaterEq(str column, ASTType t, ASTValue v)
  | greater(str column, ASTType t, ASTValue v)
  | lessEq(str column, ASTType t, ASTValue v)
  | less(str column, ASTType t, ASTValue v)
  | equals(str column, ASTType t, ASTValue v)
  | keep(str column, ASTType t)
  | dropna(str column, ASTType t)
  ;

data ASTType
  = intType()
  | floatType()
  | stringType()
  | boolType()
  ;

data ASTValue
  = intVal(int i)
  | floatVal(real r)
  | stringVal(str s)
  | boolVal(bool b)
  | arrayVal(list[ASTValue] arr)
  ;

data ASTAggType
  = aggSum()
  | aggAvg()
  | aggMin()
  | aggMax()
  ;