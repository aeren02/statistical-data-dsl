module DSL_Checker

import DSL_AST;
import IO;

bool checkProgram(ASTProgram prog) {
    set[str] defined = {};
    bool hasErrors = false;

    bool hasLoad = false;
    for (cmd <- prog.commands) {
        if (cmd is load) hasLoad = true;
    }
    if (!hasLoad) {
        defined += {"defaultName"};
    }

    for (cmd <- prog.commands) {
        switch (cmd) {
            case load(_, name): {
                defined += {name};
            }
            case constrain(source, target, _): {
                if (source notin defined) {
                    println("❌ Semantic Error: Cannot constrain undefined dataset \'<source>\'. Please Load it first!");
                    hasErrors = true;
                } else {
                    defined += {target};
                }
            }
            case visualise(name): {
                if (name notin defined) { println("❌ Semantic Error: Cannot visualise undefined dataset \'<name>\'."); hasErrors = true; }
            }
            case visualiseUsing(name, _): {
                if (name notin defined) { println("❌ Semantic Error: Cannot visualise undefined dataset \'<name>\'."); hasErrors = true; }
            }
            case visualisePie(name, _): {
                if (name notin defined) { println("❌ Semantic Error: Cannot visualise undefined dataset \'<name>\'."); hasErrors = true; }
            }
            case visualiseBar(name, _): {
                if (name notin defined) { println("❌ Semantic Error: Cannot visualise undefined dataset \'<name>\'."); hasErrors = true; }
            }
            case visualiseTrend(name, _, _): {
                if (name notin defined) { println("❌ Semantic Error: Cannot visualise undefined dataset \'<name>\'."); hasErrors = true; }
            }
            case rename(source, _, _): {
                if (source notin defined) { println("❌ Semantic Error: Cannot rename columns in undefined dataset \'<source>\'."); hasErrors = true; }
            }
            case sortAsc(source, _, _): {
                if (source notin defined) { println("❌ Semantic Error: Cannot sort undefined dataset \'<source>\'."); hasErrors = true; }
            }
            case sortDesc(source, _, _): {
                if (source notin defined) { println("❌ Semantic Error: Cannot sort undefined dataset \'<source>\'."); hasErrors = true; }
            }
            case groupByCount(source, _): {
                if (source notin defined) { println("❌ Semantic Error: Cannot group undefined dataset \'<source>\'."); hasErrors = true; }
            }
            case groupByAgg(source, _, _, _, _): {
                if (source notin defined) { println("❌ Semantic Error: Cannot group undefined dataset \'<source>\'."); hasErrors = true; }
            }
            case linReg(source, _, _): {
                if (source notin defined) { println("❌ Semantic Error: Cannot perform regression on undefined dataset \'<source>\'."); hasErrors = true; }
            }
            case multiLinReg(source, _, _): {
                if (source notin defined) { println("❌ Semantic Error: Cannot perform multiple regression on undefined dataset \'<source>\'."); hasErrors = true; }
            }
        }
    }
    return hasErrors;
}
