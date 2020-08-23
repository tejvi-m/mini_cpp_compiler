import re
import sys

RegSize = 3
maxNum = 0
flag = ""

def split_icg(filename):
    fp=open(filename,'r')
    icg=fp.read()
    fp.close()
    icg=re.sub('\n+','\n',icg)
    icg=re.sub(' +',' ',icg)
    icg=icg.split('\n')
    flag=0
    for i in range(len(icg)):
        icg[i]=icg[i].strip()
        if('#include' in icg[i]):
            icg[i]=' '
        elif('unsuccessful' in icg[i]):
            flag=1
            icg[i]=' '
        elif('successful' in icg[i]):
            flag=0
            icg[i]=' '
    icg='\n'.join(icg)
    icg=re.sub('\n+','\n',icg)
    icg=re.sub(' +',' ',icg)
    icg=icg.split('\n')
    return icg

def assign_reg(icg):
    global maxNum
    mappings = {}
    data_segments = set()
    j = 0
    for i in range(len(icg)):
        tokens = icg[i].strip().split()
        lhs = icg[i].split("=")[0]
        if(lhs not in mappings and "=" in tokens):
            if(j > RegSize):
                data_segments.add(lhs.strip())
            else:
                mappings[lhs.strip()] = "R" + str(j)
                j += 1
        else:
            pass
    # if(j > RegSize):
    #     maxNum = 0
    # else:
    #     maxNum = j
    maxNum = j-1
    return mappings, data_segments
def isTemp(var):
    # print(('t' in var) and (len(var) == 3))
    return (len(var) == 3) and ('t' in var)

def fill_data_seg(mappings, data_segments):
    # data_segments = set()
    keyList = list(mappings.keys())
    for i in range(len(keyList)):
        if(not isTemp(keyList[i].strip())):
            data_segments.add(keyList[i])
    return data_segments

def gen_assign_exps(mappings, data_segments, expanded_rhs, lhs):
    global maxNum
    if(lhs.strip() in data_segments):
        #load instructions.
        if(lhs.strip() not in mappings.keys()):
            some_reg = "R" + str(maxNum)
            temp_reg = "R" + str((maxNum + 1)%RegSize)

            if(expanded_rhs[0].isnumeric()):
                print("MOV " + temp_reg + ", #" + expanded_rhs[0])
            else:
                print("MOV " + temp_reg + ", " + mappings[expanded_rhs[0]])
            print("LDR " + some_reg + " ,=" + lhs.strip())
            print("STR " + temp_reg + " ,[" + some_reg +"]")
            mappings.update({lhs.strip() : some_reg})
            maxNum = (maxNum + 1)%RegSize
        else:

            temp_reg = "R" + str(maxNum)
            # print("!!!", temp_reg)
            if(expanded_rhs[0].isnumeric()):
                print("MOV " + temp_reg + ", #" + expanded_rhs[0])
            else:
                print("MOV " + temp_reg + ", " + mappings[expanded_rhs[0]])
            print("LDR " + mappings[lhs.strip()] + " ,=" + lhs.strip())
            print("STR " + temp_reg + " ,[" + mappings[lhs.strip()] +"]")
            # no need to increment here actually
            # maxNum = (maxNum + 1)%RegSize
    else:
        if(expanded_rhs[0].isnumeric()):
                print("MOV " + mappings[lhs.strip()] + ", #" + expanded_rhs[0])
        else:
            print("MOV " + mappings[lhs.strip()] + ", " + mappings[expanded_rhs[0]])
def gen_arith_exprs(mappings, data_segments, expanded_rhs, lhs):
    global maxNum
    global flag

    if(lhs.strip() not in mappings.keys()):
        another_reg = "R" + str(maxNum)
        mappings.update({lhs.strip() : another_reg})
        maxNum = (maxNum + 1) % RegSize

    if(expanded_rhs[1] == "+"):
        if(expanded_rhs[0].isnumeric()):
            print("ADD " + mappings[lhs.strip()] + ", " + mappings[expanded_rhs[2]] + ", #" + expanded_rhs[0])

        elif(expanded_rhs[2].isnumeric()):
            print("ADD " + mappings[lhs.strip()] + ", " + mappings[expanded_rhs[0]] + ", #" + expanded_rhs[2])

        else:
            print("ADD " + mappings[lhs.strip()] + ", " + mappings[expanded_rhs[0]] + ", " + mappings[expanded_rhs[2]])
    elif(expanded_rhs[1] == "*"):
        if(expanded_rhs[0].isnumeric()):
            print("MUL " + mappings[lhs.strip()] + ", " + mappings[expanded_rhs[2]] + ", #" + expanded_rhs[0])

        elif(expanded_rhs[2].isnumeric()):
            print("MUL " + mappings[lhs.strip()] + ", " + mappings[expanded_rhs[0]] + ", #" + expanded_rhs[2])

        else:
            print("MUL " + mappings[lhs.strip()] + ", " + mappings[expanded_rhs[0]] + ", " + mappings[expanded_rhs[2]])
    elif(expanded_rhs[1] == "-"):
        if(expanded_rhs[0].isnumeric()):
            print("SUB " + mappings[lhs.strip()] + ", #" + expanded_rhs[0] + ", " +  mappings[expanded_rhs[2]])

        elif(expanded_rhs[2].isnumeric()):
            print("SUB " + mappings[lhs.strip()] + ", " + mappings[expanded_rhs[0]] + ", #" + expanded_rhs[2])

        else:
            print("SUB " + mappings[lhs.strip()] + ", " + mappings[expanded_rhs[0]] + ", " + mappings[expanded_rhs[2]])
    else:
        #no divisions
        if(expanded_rhs[0].isnumeric()):
            temp_reg = "R" + str(maxNum)
            print("MOV " + temp_reg + ", #" + mappings[expanded_rhs[0]])
            print("CMP " +  temp_reg + ", " +  mappings[expanded_rhs[2]])

        elif(expanded_rhs[2].isnumeric()):
            print("CMP " +  mappings[expanded_rhs[0]] + ", #" + expanded_rhs[2])
            
        else:
            print("CMP " + mappings[expanded_rhs[0]] + ", " + mappings[expanded_rhs[2]])
        if(expanded_rhs[1] == "<"):
            flag = "LT"
        elif(expanded_rhs[1] == "<="):
            flag = "LE"
        elif(expanded_rhs[1] == ">"):
            flag = "GT"
        elif(expanded_rhs[1] == ">="):
            flag = "GE"
        elif(expanded_rhs[1] == "=="):
            flag = "EQ"
    if(lhs.strip() in data_segments):
        temp_reg = "R" + str(maxNum)
        print("LDR " + temp_reg + " ,=" + lhs.strip())
        print("STR "+ mappings[lhs.strip()] + ",["+ temp_reg +"]")
        maxNum = (maxNum + 1) % RegSize
def gen_branch_cond(tokens):
    print("B" + flag + " " + tokens[-1])

def change_flags():
    global flag
    if(flag == "LT"):
        flag = "GE"
    elif(flag == "LE"):
        flag = "GT"
    elif(flag == "GE"):
        flag = "LT"
    if(flag == "GT"):
        flag = "LE"
    if(flag == "EQ"):
        flag = "NE"

def gen_goto(tokens):
    print("B "+ tokens[-1])

def gen_exps(mappings, data_segments, icg):
    for i in range(len(icg)):
        tokens = icg[i].strip().split()
        if("=" in icg[i]):
            lhs, rhs = icg[i].split("=")
            expanded_rhs = rhs.strip().split()
            if(len(expanded_rhs) == 1):
                gen_assign_exps(mappings, data_segments, expanded_rhs, lhs)
            elif(len(expanded_rhs) == 3):
                gen_arith_exprs(mappings, data_segments, expanded_rhs, lhs)
            elif("not" in expanded_rhs):
                change_flags()
        elif len(tokens) == 2 and tokens[-1] == ":":
            # label
            print(icg[i])
        elif tokens[0] == "if" and tokens[2] == "goto":
            gen_branch_cond(tokens)
            #condition stuff
        elif tokens[0] == "goto":
            #goto stuff
            gen_goto(tokens)

def print_data_segment(data_segments):
    print(".DATA")
    for i in data_segments:
        print(i +": .WORD") #need to check this out
if __name__ == "__main__":
    icg = split_icg(sys.argv[1]) 
    print(icg)
    mappings, unassigned_vars = assign_reg(icg)
    data_segments = fill_data_seg(mappings, unassigned_vars)
    # data_segments.extend(unassigned_vars)
    data_segments = list(data_segments)
    print("maps", mappings, "data", data_segments)
    print(".TEXT")
    # generate the code
    gen_exps(mappings, data_segments, icg)
    print_data_segment(data_segments)
