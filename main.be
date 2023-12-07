# Takes in a number
class NumC
    var n
    def init(n)
        self.n = n
    end
end
# takes in a String
class StrC
    var s
    def init(s)
        self.s = s
    end
end
# Takes in a Symbol..? (there is no difference between string and symbol in this language.)
class IdC
    var s
    def init(s)
        self.s = s
    end
end
# Takes a blam, and a list of its params
class AppC
    var blam, list
    def init(blam, list)
        self.blam = blam
        self.list = list
    end
end
# takes a list of params and where they are applied.
class BlamC
    var list, expr
    def init(list, expr)
        self.list = list
        self.expr = expr
    end
end
# Takes the start cond, and the cases for true and false.
class IfC
    var cond, tru, fal
    def init(cond, tru, fal)
        self.cond = cond
        self.tru = tru
        self.fal = fal
    end
end

# ----------------------------------------------

# Takes the list of vars, the function, and an env.
class CloV 
    var list, body, env
    def init(list, body, env)
        self.list = list
        self.body = body
        self.env = env
    end
end

class StrV
    var str
    def init(str)
        self.str = str
    end
    def equal(other)
        return self.str == other.str
    end
end

class NumV
    var num
    def init(num)
        self.num = num
    end
    def equal(other)
        return self.num == other.num
    end
end

class BoolV
    var bool
    def init(bool)
        self.bool = bool
    end
    def equal(other)
        return self.bool == other.bool
    end
end

class PrimV
    var op
    def init(op)
        self.op = op
    end
end

class Binding
    var sym, val
    def init(sym, val)
            self.sym = sym
            self.val = val
    end
end

# Bindings are just values in the hashmap
typeenv = []
typeenv.push(Binding('true', BoolV(true)))
typeenv.push(Binding('false', BoolV(false)))
typeenv.push(Binding('+', PrimV('+')))
typeenv.push(Binding('-', PrimV('-')))
typeenv.push(Binding('*', PrimV('*')))
typeenv.push(Binding('/', PrimV('/')))
typeenv.push(Binding('<=', PrimV('<=')))
typeenv.push(Binding('equal?', PrimV('==')))


def serialize(value)
    if classname(value) == 'NumV' 
        print(value.num)
    elif classname(value) == 'StrV'
        print(value.str)
    elif classname(value) == 'BoolV'
        print(value.bool)
    elif classname(value) == 'CloV'
        print("#<procedure>")
    else
        print("#<primop>")
    end 
end

def lookup(sym, env)
    for i : 0 .. env.size()-1
        if sym == env[i].sym
            return env[i].val
        end
    end 
    raise 'lookup PAIG: symbol not  found', sym
end


def interp(expr, env)
    if classname(expr) == 'NumC'
        return NumV(expr.n)
    elif classname(expr) == 'IdC'
        return lookup(expr.s, env)
    elif classname(expr) == 'StrC'
        return StrV(expr.s)
    elif classname(expr) == 'BlamC'
        return CloV(expr.list, expr.expr, env)
    elif classname(expr) == 'AppC'
        fval = interp(expr.blam, env)
        if classname(fval) == 'CloV'
            2
        elif classname(fval) == 'PrimV'
            left =  interp(expr.list[0], env)
            right = interp(expr.list[1], env)
            if fval.op == '=='
                if classname(left) == 'CloV' || classname(right) == 'CloV' &&
                   (classname(left) != 'NumV' || classname(left) != 'StrV' || classname(left) != 'BoolV') &&
                   (classname(right) != 'NumV' || classname(right) != 'StrV' || classname(right) != 'BoolV')
                   return BoolV(false)
                else
                    if classname(left) == classname(right)
                        return BoolV(left.equal(right))
                    else
                        return BoolV(false)
                    end
                end 
            end
            if classname(left) != "NumV" || classname(right) != "NumV"
                raise "interp PAIG: math with nonnumbers"
            end
            if fval.op == '+'
                return NumV( left.num + right.num)
            elif fval.op == '-'
                return NumV( left.num - right.num)
            elif fval.op == '*'
                return NumV( left.num * right.num)
            elif fval.op == '/'
                if right.num == 0
                    raise 'interp PAIG: Divide by 0'
                else
                    return NumV( left.num / right.num)
                end 
            elif fval.op == '<='
                return left.num <= right.num
            else
                raise 'interp PAIG: Invalid operator'
            end 
        end
    elif classname(expr) == 'IfC'
        if interp(expr.cond) == BoolV(true)
            return interp(expr.tru)
        elif interp(expr.cond) == BoolV(false)
            return interp(expr.fal)
        else
            raise 'interp PAIG: Conditional not a bool', expr.cond
        end
    else
        return raise 'interp PAIG: syntax_error', expr
    end
end

def topinterp(expr)
    serialize(interp( expr, typeenv))
end
# For Copy Pasting Tests
# serialize(interp( ), typeenv))
topinterp( NumC(3))
topinterp( StrC("berry kekw"))
topinterp(IdC("true"))
topinterp(IdC("false"))
topinterp(BlamC(['x', 'y'], AppC( IdC('+'), [NumC(1), NumC(1)])))
topinterp(AppC( IdC('+'), [NumC(1), NumC(12)]))
topinterp(AppC( IdC('-'), [NumC(15), NumC(30)]))
topinterp(AppC( IdC('*'), [NumC(8), NumC(-2)]))
topinterp(AppC( IdC('/'), [NumC(1000), NumC(5)]))
try 
    topinterp(AppC( IdC('/'), [NumC(1000), NumC(0)]))
except
    "interp PAIG: Divide by 0" as x 
end
topinterp(AppC( IdC('equal?'), [NumC(1000), NumC(5)]))
topinterp(AppC( IdC('equal?'), [NumC(5), NumC(5)])) 
topinterp(AppC( IdC('equal?'), [StrC("asdf"), NumC(5)])) 
topinterp(AppC( IdC('equal?'), [StrC("asdf"), StrC("asdf")])) 