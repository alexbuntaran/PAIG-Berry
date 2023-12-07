# -------------------------------------------- EXPRC -------------------------------------------- #

class NumC
    var num
    def init(num)
        self.num = num
    end
end

class StrC
    var str
    def init(str)
        self.str = str
    end
end

class IdC
    var sym
    def init(sym)
        self.sym = sym
    end
end

class BlamC
    var params, body
    def init(params, body)
        self.params = params
        self.body = body
    end
end

class AppC
    var func, args
    def init(func, args)
        self.func = func
        self.args = args
    end
end

class IfC
    var cond, tru, fal
    def init(cond, tru, fal)
        self.cond = cond
        self.tru = tru
        self.fal = fal
    end
end

# -------------------------------------------- VALUE -------------------------------------------- #

class NumV
    var num
    def init(num)
        self.num = num
    end
end

class StrV
    var str
    def init(str)
        self.str = str
    end
end

class BoolV
    var bool
    def init(bool)
        self.bool = bool
    end
end

class CloV 
    var params, body, env
    def init(params, body, env)
        self.params = params
        self.body = body
        self.env = env
    end
end

class PrimopV
    var op
    def init(op)
        self.op = op
    end
end

# ----------------------------------------- ENVIRONMENT ----------------------------------------- #

class Binding
    var sym, val
    def init(sym, val)
            self.sym = sym
            self.val = val
    end
end

# Creates the initial top level environment
def make_initial_env()
    env = []
    env.push(Binding("true", BoolV(true)))
    env.push(Binding("false", BoolV(false)))
    env.push(Binding("+", PrimopV("+")))
    env.push(Binding("-", PrimopV("-")))
    env.push(Binding("*", PrimopV("*")))
    env.push(Binding("/", PrimopV("/")))
    env.push(Binding("<=", PrimopV("<=")))
    env.push(Binding("equal?", PrimopV("equal?")))
    env.push(Binding("error", PrimopV("error")))

    return env
end

# Takes in a symbol and environment and returns the corresponding Value in environment
def env_lookup(sym, env)
    for i : 0 .. env.size() - 1
        idx = env.size() - i - 1
        if sym == env[idx].sym
            return env[idx].val
        end
    end 

    raise "env_lookup - PAIG: symbol not found", sym
end

# ------------------------------------------ SERIALIZE ------------------------------------------ #

# Takes in a Value and prints out the corresponding value
def serialize(value)
    case = classname(value)
    if case == "NumV" 
        print(value.num)
    elif case == "StrV"
        print(value.str)
    elif case == "BoolV"
        print(value.bool)
    elif case == "CloV"
        print("#<procedure>")
    elif case == "PrimopV"
        print("#<primop>")
    else
        raise "serialize - PAIG: invalid value", case
    end 
end

# ----------------------------------------- INTERPRETER ----------------------------------------- #

def interp_binop(args, op)
    if args.size() != 2
        raise "interp_binop - PAIG: invalid number of args", args.size()
    elif classname(args[0]) != "NumV" || classname(args[1]) != "NumV"
        raise "interp_binop - PAIG: one or more of the args is not a number", args[0] args[1]
    end

    if op == "+"
        return NumV(args[0].num + args[1].num)
    elif op == "-"
        return NumV(args[0].num - args[1].num)
    elif op == "*"
        return NumV(args[0].num * args[1].num)
    elif op == "/"
        return NumV(args[0].num / args[1].num)
    elif op == "<="
        return BoolV(args[0].num <= args[1].num)
    else
        raise "interp_binop - PAIG: invalid operator", op
    end
end

def interp_equal(args)
    if args.size() != 2
        raise "interp_equal - PAIG: invalid number of args", args.size()
    end

    if classname(args[0]) == "NumV" && classname(args[1]) == "NumV"
        return BoolV(args[0].num == args[1].num)
    elif classname(args[0]) == "StrV" && classname(args[1]) == "Strv"
        return BoolV(args[0].str == args[1].str)
    elif classname(args[0]) == "BoolV" && classname(args[1]) == "BoolV"
        return BoolV(args[0].bool == args[1].bool)
    else
        return BoolV(false)
    end
end

def interp_error(args)
    if args.size() != 1
        raise "interp_error - PAIG: invalid number of args", args.size()
    else
        raise "user-error", serialize(args[0])
    end
end

# Takes in an ExprC and environment and returns the corresponding Value
def interp(expr, env)
    case = classname(expr)
    if case == "NumC"
        return NumV(expr.num)
    elif case == "StrC"
        return StrV(expr.str)
    elif case == "IdC"
        return env_lookup(expr.sym, env)
    elif case == "BlamC"
        return CloV(expr.params, expr.body, env)
    elif case == "AppC"
        # interp the args
        args = []
        for i : 0 .. expr.args.size() - 1
            args.push(interp(expr.args[i], env))
        end
        
        # get the func definition
        func = interp(expr.func, env)

        # match the type of function
        case = classname(func)
        if case == "PrimopV"
            op = func.op
            if op == "+" || op == "-" || op == "*" || op == "/" || op == "<="
                return interp_binop(args, op)
            elif op == "equal?"
                return interp_equal(args)
            elif op == "error"
                return interp_error(args)
            else
                raise "interp - PAIG: invalid PrimopV", op
            end
        elif case == "CloV"
            if args.size() != func.params.size()
                raise "interp - PAIG: number of args not equal to number of params", args.size() func.params.size()
            else
                # create bindings for extended-env
                bindings = []
                for i : 0 .. func.params.size() - 1
                    bindings.push(Binding(func.params[i], args[i]))
                end

                # create extended-env (appends bindings to CloV-env)
                extended_env = []
                for i : 0 .. func.env.size() - 1
                    extended_env.push(func.env[i])
                end
                for i : 0 .. bindings.size() - 1
                    extended_env.push(bindings[i])
                end
                
                return interp(func.body, extended_env)
            end
        else
            raise "interp - PAIG: function does not exist", case
        end
    elif case == "IfC"
        cond = interp(expr.cond. env)
        if cond == BoolV(true)
            return interp(expr.tru, env)
        elif cond == BoolV(false)
            return interp(expr.fal, env)
        else
            raise "interp - PAIG: conditional not a bool", expr.cond
        end
    else
        raise "interp - PAIG: invalid ExprC", case
    end
end

# --------------------------------------- TOP INTERPRETER --------------------------------------- #

# Takes in an ExprC and interprets the ast and prints out the corresponding output
def top_interp(expr)
    serialize(interp(expr, make_initial_env()))
end

# ------------------------------------------ TEST CASES ----------------------------------------- #

# serialize(interp( ), env))
# top_interp( NumC(3))
# top_interp( StrC("berry kekw"))
# top_interp(IdC("true"))
# top_interp(IdC("false"))
# top_interp(BlamC(["x", "y"], AppC( IdC("+"), [NumC(1), NumC(1)])))
# top_interp(AppC( IdC("+"), [NumC(1), NumC(12)]))
# top_interp(AppC( IdC("-"), [NumC(15), NumC(30)]))
# top_interp(AppC( IdC("*"), [NumC(8), NumC(-2)]))
# top_interp(AppC( IdC("/"), [NumC(1000), NumC(5)]))
# try 
#     top_interp(AppC( IdC("/"), [NumC(1000), NumC(0)]))
# except
#     "interp PAIG: Divide by 0" as x 
# end
# top_interp(AppC( IdC("equal?"), [NumC(1000), NumC(5)]))
# top_interp(AppC( IdC("equal?"), [NumC(5), NumC(5)])) 
# top_interp(AppC( IdC("equal?"), [StrC("asdf"), NumC(5)])) 
# top_interp(AppC( IdC("equal?"), [StrC("asdf"), StrC("asdf")]))

top_interp(NumC(10))
top_interp(IdC("true"))
top_interp(IdC("false"))
top_interp(IdC("+"))
top_interp(AppC(BlamC(["x"], AppC(IdC("+"), [IdC("x"), NumC(1)])), [NumC(1)]))
top_interp(AppC(IdC("+"), [NumC(10), NumC(20)]))