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
        if(i[0].strip() in rhs):
            # print("yes")
            return True
    return False

def process(icg):
    master_map = {}
    var_list = {}
    for i in range(len(icg)):
        if("=" in icg[i]):
            split_snippet = icg[i].split("=")
            lhs = split_snippet[0]
            if(lhs not in var_list):
                var_list[lhs] = i
            rhs = split_snippet[-1]
            if(not present(var_list, rhs)):
                res = eval(rhs)
                master_map[lhs.strip()] = res
                icg[i] = lhs + "= " + str(res)
            else:
                continue
    
    return icg, master_map, var_list

def redefine_rhs(master_map, rhs, vars_used):
    split_rhs = rhs.split()
    # print("rhs", split_rhs)
    for i in range(len(split_rhs)):
        if(split_rhs[i] in master_map):
            if(split_rhs[i] not in vars_used):
                vars_used[split_rhs[i]] = 1
            split_rhs[i] = str(master_map[split_rhs[i]])
            
    return " ".join(split_rhs)

def substitute_vals(code, master_map):
    vars_used = {}
    for i in range(len(code)):
        if("=" in code[i]):
            split_snippet = code[i].split("=")
            lhs = split_snippet[0]
            rhs = split_snippet[-1]
            rhs = redefine_rhs(master_map, rhs, vars_used)
            res = eval(rhs)
            master_map[lhs.strip()] = res
            code[i] = lhs + "= " + str(res)                
    return code, vars_used

def remove_redundant(code, var_list, vars_used):
    print(vars_used, var_list)
    idx = []
    for rhs in vars_used.keys():
        for lhs in var_list.keys():
            if(lhs.strip() == rhs.strip()):
                # print(var_list[lhs])
                idx.append(var_list[lhs])     
    res = []
    for i in range(len(code)):
        if(i not in idx):
            res.append(code[i])
    return res
if __name__ == '__main__':
    code_statements = split_icg(sys.argv[1])
    # print(code_statements)
    processed_icg, master_map, var_list = process(code_statements)
    print(processed_icg)
    substituted_icg, vars_used = substitute_vals(processed_icg, master_map)
    # print('\n'.join(substituted_icg))
    compact_icg = remove_redundant(substituted_icg, var_list, vars_used)
    print('\n'.join(compact_icg))