class convert():
    registers = {"%rax", "%rbx", "%rcx", "%rdx", "%rdi", "%rsi", "%rbp", "%rsp", "%r8", "%r9", "%r10", "%r11", "%r12", "%r13", "%r14", "%r15"}
    mapping = dict()
    labelMapping = dict()
    pc = 0
    filename = ""

    arithmeticOps = {"+", "-", "/", "*"}

    def __init__(self, filename):
        self.filename = filename

    def genAssembly(self, outputFileName):
        
        data = open(self.filename).readlines()
        outFile = open(outputFileName, 'w')
        intermediateFile = open("." + self.filename + "_intermediate.txt", 'w')

        for line in data:
            line = line.strip()
            tokens = line.split()

            if "=" in line:
                [intermediateFile.write(x + '\n') for x in self.convert_eq(line).split("\n")]

            elif len(tokens) == 2 and tokens[-1] == ":":
                intermediateFile.write(line + '\n')         

            elif tokens[0] == "if" and tokens[2] == "goto":
                [intermediateFile.write(x + '\n') for x in self.convert_if_branch(line).split("\n")]

            elif tokens[0] == "goto":
                [intermediateFile.write(x + '\n') for x in self.cvt_goto(line).split("\n")]

    def isInMap(self, dst):
        try:
            x = self.mapping[dst]
            return 1
        except:
            return 0

    def genAdd(self):
        x = self.pc
        self.pc += 1
        return "<" + "{:010d}".format(x) + ">   "
        

    def pullFromMap(self):
        pass

    def getReg(self, dst):
        if(self.isInMap(dst)):
            return self.getSrc(dst)

        if len(self.registers):
            return self.registers.pop()
        else:
            return self.pullFromMap()
    
    def addMapping(self, register, variable):
        self.mapping.update({variable : register})

    def getImmediate(self, number):
        # what
        return "$0x" + str(int(str(number), 16))



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
        
        dest_reg = self.getReg(tokens[0])

        self.addMapping(dest_reg, tokens[0])

        expr = tokens[2:]
        if len(expr) == 1:
            # src = tokens[2]
            
            src = self.getSrc(tokens[2])

            return self.genAdd() + "mov " + src + ", " + dest_reg
            
            
        else:
            if len(expr) == 2 and expr[0] == "not":
                return self.genAdd() + "compl $0x0, " + self.getSrc(expr[1]) + "\n" + \
                        self.genAdd() + "setle %al"+ "\n" + \
                        self.genAdd() + "movzbl %al, %eax\n" + \
                        self.genAdd() + "mov %eax, " + dest_reg

            src1 = self.getSrc(expr[0])
            src2 = self.getSrc(expr[2])

            # based on disas on gdb
            if "<" == expr[1]:
                return self.genAdd() +"compl " + src1 + ", " + src2 + "\n" + \
                        self.genAdd() +"setle %al"+ "\n" + \
                        self.genAdd() +"movzbl %al, %eax\n" + \
                        self.genAdd() +"mov %eax, " + dest_reg
            
            elif ">" == expr[1]:
                return self.genAdd() +"compl " + src1 + ", " + src2 + "\n" + \
                        self.genAdd() +    "setge %al"+ "\n" + \
                        self.genAdd() +    "movzbl %al, %eax\n" + \
                        self.genAdd() +    "mov %eax, " + dest_reg
                

            elif ">=" == expr[1]:
                return self.genAdd() +"compl " + src1 + ", " + src2 + "\n" + \
                          self.genAdd() +  "setg %al"+ "\n" + \
                          self.genAdd() +  "movzbl %al, %eax\n" + \
                           self.genAdd() + "mov %eax, " + dest_reg

            elif "<=" == expr[1]:
                return self.genAdd() +"compl " + src1 + ", " + src2 + "\n" + \
                        self.genAdd() +    "setl %al"+ "\n" + \
                         self.genAdd() +   "movzbl %al, %eax\n" + \
                          self.genAdd() +  "mov %eax, " + dest_reg
            
            elif "==" == expr[1]:
                return self.genAdd() +"compl " + src1 + ", " + src2 + "\n" + \
                        self.genAdd() +    "sete %al"+ "\n" + \
                        self.genAdd() +    "movzbl %al, %eax\n" + \
                        self.genAdd() +    "mov %eax, " + dest_reg

            elif "!=" == expr[1]:
                return self.genAdd() +"compl " + src1 + ", " + src2 + "\n" + \
                        self.genAdd() +    "sete %al"+ "\n" + \
                        self.genAdd() +    "movzbl %al, %eax\n" + \
                         self.genAdd() +   "mov %eax, " + dest_reg

            elif "+" == expr[1]:
                return self.genAdd() +"mov " + src1 + ", %edx\n" + \
                       self.genAdd() + "mov " + src2 + ", %eax\n" + \
                        self.genAdd() +"add %eax, %edx\n" + \
                       self.genAdd() + "mov %eax, " + dest_reg
            elif "-" == expr[1]:
                return self.genAdd() +"mov " + src1 + ", %edx\n" + \
                       self.genAdd() + "mov " + src2 + ", %eax\n" + \
                       self.genAdd() + "add %eax, %edx\n" + \
                       self.genAdd() + "mov %eax, " + dest_reg

            elif "*" == expr[1]:
                    return self.genAdd() +"mov " + src1 + ", %edx\n" + \
                            self.genAdd() +"mov " + src2 + ", %eax\n" + \
                           self.genAdd() + "imul /*THIS IS WRONG*/ %eax, %edx\n" + \
                           self.genAdd() + "mov %eax, " + dest_reg

            elif "/" == expr[1]:
                return self.genAdd() +"mov " + src1 + ", %edx\n" + \
                        self.genAdd() +"idivl /*THIS IS WRONG*/ " + src2 + ", %eax\n" + \
                        self.genAdd() +"add %eax, %edx\n" + \
                       self.genAdd() + "mov %eax, " + dest_reg



    def getAddr(self, label):
        return label

    def convert_if_branch(self, line):
        tokens = line.split()
        return self.genAdd() +"cmpl $0x0, " + self.getSrc(tokens[1]) + "\n" + \
                self.genAdd() +"jne " + self.getAddr(tokens[3])

 
    def cvt_goto(self, line):
        tokens = line.strip().split()
        return self.genAdd() +"jmp " + self.getAddr(tokens[1])