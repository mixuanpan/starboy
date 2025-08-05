with open ("dense_0_param0_int4.mem") as file:
    count = 0
    for line in file:
        print(f"logic d0_w_{count};")
        print(f"assign d0_w_{count} = {line.rstrip("\n")};")
        count = count + 1
# dense* => layer* 
# param0 => weights 
# param1 => baises 
