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
end

class NumV
    var num
    def init(num)
        self.num = num
    end
end

class BoolV
    var bool
    def init(bool)
        self.bool = bool
    end
end

class PrimV
    var op
    def init(op)
        self.op = op
    end
end

# Bindings are just values in the hashmap
typeenv = map()
typeenv.insert('true', BoolV(true))
typeenv.insert('false', BoolV(false))
typeenv.insert('+', PrimV('+'))
typeenv.insert('-', PrimV('-'))
typeenv.insert('*', PrimV('*'))
typeenv.insert('/', PrimV('/'))
typeenv.insert('<=', PrimV('<='))
typeenv.insert('equal?', PrimV('=='))

print(typeenv.item('+').op)

def interp(expr, env)
    if classname(expr) = 'NumC'
        return expr.n
    elif classname(expr) = 'IdC'
        return expr.s
    elif classname(expr) = 'StrC'
        return expr.s
    elif classname(expr) = 'BlamC'
        return CloV(BlamC.list, BlamC.expr, env)
    elif classname(expr) = 'AppC'
        return 1
    else
        return raise 'PAIG: syntax_error', expr
end
