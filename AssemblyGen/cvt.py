class convert():
    registers = {"%rax", "%rbx", "%rcx", "%rdx", "%rdi", "%rsi", "%rbp", "%rsp", "%r8", "%r9", "%r10", "%r11", "%r12", "%r13", "%r14", "%r15"}
    mapping = dict()

    arithmeticOps = {"+", "-", "/", "*"}

    def __init__(self):
        pass
    
    def isInMap(self, dst):
        try:
            x = self.mapping[dst]
            return 1
        except:
            return 0

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
        
        dest_reg = self.getReg(tokens[0])

        self.addMapping(dest_reg, tokens[0])

        expr = tokens[2:]
        if len(expr) == 1:
            # src = tokens[2]
            
            src = self.getSrc(tokens[2])

            return "mov " + src + ", " + dest_reg
            
            
        else:
            if len(expr) == 2 and expr[0] == "not":
                return "compl $0x0, " + self.getSrc(expr[1]) + "\n" + \
                        "setle %al"+ "\n" + \
                        "movzbl %al, %eax\n" + \
                        "mov %eax, " + dest_reg

            src1 = self.getSrc(expr[0])
            src2 = self.getSrc(expr[2])

            # based on disas on gdb
            if "<" == expr[1]:
                return "compl " + src1 + ", " + src2 + "\n" + \
                        "setle %al"+ "\n" + \
                        "movzbl %al, %eax\n" + \
                        "mov %eax, " + dest_reg
            
            elif ">" == expr[1]:
                return "compl " + src1 + ", " + src2 + "\n" + \
                            "setge %al"+ "\n" + \
                            "movzbl %al, %eax\n" + \
                            "mov %eax, " + dest_reg
                

            elif ">=" == expr[1]:
                return "compl " + src1 + ", " + src2 + "\n" + \
                            "setg %al"+ "\n" + \
                            "movzbl %al, %eax\n" + \
                            "mov %eax, " + dest_reg

            elif "<=" == expr[1]:
                return "compl " + src1 + ", " + src2 + "\n" + \
                            "setl %al"+ "\n" + \
                            "movzbl %al, %eax\n" + \
                            "mov %eax, " + dest_reg
            
            elif "==" == expr[1]:
                return "compl " + src1 + ", " + src2 + "\n" + \
                            "sete %al"+ "\n" + \
                            "movzbl %al, %eax\n" + \
                            "mov %eax, " + dest_reg

            elif "!=" == expr[1]:
                return "compl " + src1 + ", " + src2 + "\n" + \
                            "sete %al"+ "\n" + \
                            "movzbl %al, %eax\n" + \
                            "mov %eax, " + dest_reg

            elif "+" == expr[1]:
                return "mov " + src1 + ", %edx\n" + \
                        "mov " + src2 + ", %eax\n" + \
                        "add %eax, %edx\n" + \
                        "mov %eax, " + dest_reg




    def getAddr(self, label):
        return label

    def convert_if_branch(self, line):
        tokens = line.split()
        return "cmpl $0x0, " + self.getSrc(tokens[1]) + "\n" + \
                "jne " + self.getAddr(tokens[3])

 
    def cvt_goto(self, line):
        tokens = line.strip().split()
        return "jmp " + self.getAddr(tokens[1])