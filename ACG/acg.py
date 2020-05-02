import re
import sys


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
    j = 0
    for i in range(len(icg)):
        tokens = icg[i].strip().split()
        lhs = icg[i].split("=")[0]
        if(lhs not in mappings and "=" in tokens):
            mappings[lhs.strip()] = "R" + str(j)
            j += 1
        else:
            pass
    maxNum = j
    return mappings
def isTemp(var):
    # print(('t' in var) and (len(var) == 3))
    return (len(var) == 3) and ('t' in var)

def fill_data_seg(mappings):
    data_segments = []
    keyList = list(mappings.keys())
    for i in range(len(keyList)):
        if(not isTemp(keyList[i].strip())):
            data_segments.append(keyList[i])
    return data_segments

def gen_assign_exps(mappings, data_segments, expanded_rhs, lhs):
    global maxNum
    if(lhs.strip() in data_segments):
        #load instructions.
        temp_reg = "R" + str(maxNum)
        if(expanded_rhs[0].isnumeric()):
            print("MOV " + temp_reg + ", #" + expanded_rhs[0])
        else:
            print("MOV " + temp_reg + ", " + mappings[expanded_rhs[0]])
        print("LDR " + mappings[lhs.strip()] + " ,=" + lhs.strip())
        print("STR " + temp_reg + " ,[" + mappings[lhs.strip()] +"]")
        # maxNum += 1 not sure if this benifits in reducinf num of registers
    else:
        print("MOV " + mappings[lhs.strip()] + ", #" + expanded_rhs[0])

def gen_exps(mappings, data_segments, icg):
    for i in range(len(icg)):
        tokens = icg[i].strip().split()
        if("=" in icg[i]):
            lhs, rhs = icg[i].split("=")
            expanded_rhs = rhs.strip().split()
            if(len(expanded_rhs) == 1):
                gen_assign_exps(mappings, data_segments, expanded_rhs, lhs)
            elif(len(expanded_rhs) == 3):
                # arithmetic and other ops   
                pass
        elif len(tokens) == 2 and tokens[-1] == ":":
            # label
            print(icg[i])
        elif tokens[0] == "if" and tokens[2] == "goto":
            # print("conds", flag)
            #condition stuff
            pass
        elif tokens[0] == "goto":
            #goto stuff
            # print("g othere")
            pass

def print_data_segment(data_segments):
    print(".DATA")
    for i in data_segments:
        print(i +": .WORD") #need to check this out
if __name__ == "__main__":
    icg = split_icg(sys.argv[1]) 
    print(icg)
    mappings = assign_reg(icg)
    data_segments = fill_data_seg(mappings)
    print("maps", mappings, "data", data_segments)
    print(".TEXT")
    # generate the code
    gen_exps(mappings, data_segments, icg)
    print_data_segment(data_segments)
