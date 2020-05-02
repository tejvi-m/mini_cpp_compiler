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

    def getSrc(self, src):
        # src = ""
        try:
            src = self.getImmediate(int(src))
        except ValueError:
            try:
                src = self.mapping[src]
            except KeyError:
                print("Key error on: ", src)
        
        return src
        

    def convert_eq(self, line):

        tokens = line.split()
        
        dest_reg = self.getReg()

        self.addMapping(dest_reg, tokens[0])

        expr = tokens[2:]
        if len(expr) == 1:
            # src = tokens[2]
            
            src = self.getSrc(tokens[2])

            return "mov " + dest_reg + ", " + src
            
            
        else:
            src1 = self.getSrc(expr[0])
            src2 = self.getSrc(expr[2])

            # based on disas on gdb
            if "<" == expr[1]:
                return "compl " + src1 + ", " + src2 + "\n" + \
                        "setle %al"+ "\n" + \
                        "movzbl %al, %eax\n" + \
                        "mov %eax, " + dest_reg
            else:
                pass

               