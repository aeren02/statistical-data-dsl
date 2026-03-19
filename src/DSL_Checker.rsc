module DSL_Checker

import DSL_AST;

void checkProgram(ASTProgram prog) {
    set[str] defined = {};

    for (cmd <- prog.commands) {
        switch (cmd) {
            case load(_, name): {
                defined += {name};
            }
            case constrain(source, target, _): {
                if (source notin defined) {
                    throw "Semantic Error: Cannot constrain undefined dataset \'<source>\'. Please Load it first!";
                }
                defined += {target};
            }
            case visualise(name): {
                if (name notin defined) throw "Semantic Error: Cannot visualise undefined dataset \'<name>\'.";
            }
            case visualiseUsing(name, _): {
                if (name notin defined) throw "Semantic Error: Cannot visualise undefined dataset \'<name>\'.";
            }
            case visualisePie(name, _): {
                if (name notin defined) throw "Semantic Error: Cannot visualise undefined dataset \'<name>\'.";
            }
            case visualiseBar(name, _): {
                if (name notin defined) throw "Semantic Error: Cannot visualise undefined dataset \'<name>\'.";
            }
            case visualiseTrend(name, _, _): {
                if (name notin defined) throw "Semantic Error: Cannot visualise undefined dataset \'<name>\'.";
            }
            case rename(source, _, _): {
                if (source notin defined) throw "Semantic Error: Cannot rename columns in undefined dataset \'<source>\'.";
            }
            case sortAsc(source, _, _): {
                if (source notin defined) throw "Semantic Error: Cannot sort undefined dataset \'<source>\'.";
            }
            case sortDesc(source, _, _): {
                if (source notin defined) throw "Semantic Error: Cannot sort undefined dataset \'<source>\'.";
            }
            case groupByCount(source, _): {
                if (source notin defined) throw "Semantic Error: Cannot group undefined dataset \'<source>\'.";
            }
            case groupByAgg(source, _, _, _, _): {
                if (source notin defined) throw "Semantic Error: Cannot group undefined dataset \'<source>\'.";
            }
        }
    }
}
