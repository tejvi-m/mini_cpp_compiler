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
    print_data_segment(data_segments)
