import re
import sys

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

def present(var_list, rhs):
    # print(var_list, rhs)
    for i in var_list:
        if(i.strip() in rhs):
            # print("yes")
            return True
    return False

def process(icg):
    master_map = {}
    var_list = []
    for i in range(len(icg)):
        if("=" in icg[i]):
            split_snippet = icg[i].split("=")
            lhs = split_snippet[0]
            var_list.append(lhs)
            rhs = split_snippet[-1]
            if(not present(var_list, rhs)):
                res = eval(rhs)
                master_map[lhs.strip()] = res
                icg[i] = lhs + "= " + str(res)
            else:
                continue
    
    return icg, master_map

def remove_reduntancy(processed_icg, master_map):
    


if __name__ == '__main__':
    code_statements = split_icg(sys.argv[1])
    print(code_statements)
    processed_icg, master_map = process(code_statements)
    print(processed_icg, master_map)
    compact_icg = remove_reduntancy(processed_icg, master_map)