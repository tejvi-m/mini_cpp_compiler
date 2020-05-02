import cvt

if __name__ == "__main__":

    generator = cvt.convert()

    file = open("input.txt").readlines()

    for line in file:
        if "=" in line:
            # assignment
            print(generator.convert_eq(line))
        else:
            pass