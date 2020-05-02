import cvt

if __name__ == "__main__":

    generator = cvt.convert()

    file = open("input.txt").readlines()

    for line in file:
        line = line.strip()
        tokens = line.split()

        if "=" in line:
            # assignment
            print(generator.convert_eq(line))
        elif len(tokens) == 2 and tokens[-1] == ":":
            # label
            print(line)
        # elif 
        elif tokens[0] == "if" and tokens[2] == "goto":
            print(generator.convert_if_branch(line))
        elif tokens[0] == "goto":
            print(generator.cvt_goto(line))