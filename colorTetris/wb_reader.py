#with open ("dense_0_param0_int4.mem") as file:
#    count = 0
#    for line in file:
#        print(f"logic d0_w_{count};")
#        print(f"assign d0_w_{count} = {line.rstrip("\n")};")
#        count = count + 1
# dense* => layer* 
# param0 => weights 
# param1 => baises 

files = [
    "dense_0_param0_int4.mem",
    "dense_0_param1_int4.mem",
    "dense_1_param0_int4.mem",
    "dense_1_param1_int4.mem",
    "dense_2_param0_int4.mem",
    "dense_2_param1_int4.mem",
    "dense_3_param0_int4.mem",
    "dense_3_param1_int4.mem",
]

for filename in files:
    # Parse filename
    parts = filename.split('_')
    layer_num = parts[1]
    param_type = "weights" if parts[2] == "param0" else "biases"

    print(f"// --- layer{layer_num}_{param_type} ---")
    with open(filename) as file:
        count = 0
        for line in file:
            line_clean = line.strip()
            var_name = f"layer{layer_num}_{param_type}_{count}"
            print(f"logic {var_name};")
            print(f"assign {var_name} = {line_clean};")
            count += 1
    print()  # Blank line between files
