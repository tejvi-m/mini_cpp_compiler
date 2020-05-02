import cvt

if __name__ == "__main__":

    generator = cvt.convert()

    file = open("input.txt").readlines()

    for line in file:
        line = line.strip()
        if "=" in line:
            # assignment
            print(generator.convert_eq(line))
        elif line[-1] == ":" and len(line.split()) == 1:
            # label
            print(line)
        # elif 
        else:
            pass