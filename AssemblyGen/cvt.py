class convert():
    registers = {"%rax", "%rbx", "%rcx", "%rdx", "%rdi", "%rsi", "%rbp", "%rsp", "%r8", "%r9", "%r10", "%r11", "%r12", "%r13", "%r14", "%r15"}
    mapping = dict()

    arithmeticOps = {"+", "-", "/", "*"}

    def __init__(self):
        pass
    
    def pullFromMap(self):
        pass

    def getReg(self):
        if len(self.registers):
            return self.registers.pop()
        else:
            return self.pullFromMap()
    
    def addMapping(self, register, variable):
        self.mapping.update({variable : register})

    def getImmediate(self, number):
        # what
        return str(number)

    def convert_eq(self, line):

        tokens = line.split()
        
        dest_reg = self.getReg()

        self.addMapping(dest_reg, tokens[0])

        expr = tokens[2:]
        if len(expr) == 1:
            src = tokens[2]

            try:
                src = self.getImmediate(int(src))
            except ValueError:
                try:
                    src = self.mapping[src]
                except KeyError:
                    pass

            return "mov " + dest_reg + ", " + src
            
        else:

            pass
