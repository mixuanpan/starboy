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

output_filename = "generated_weights.sv"

with open(output_filename, "w") as out:
    for filename in files:
        # Parse filename
        parts = filename.split('_')
        layer_num = parts[1]
        param_type = "w" if parts[2] == "param0" else "b"

        out.write(f"// --- layer{layer_num}_{param_type} ---\n")
        with open(filename) as file:
            count = 0
            for line in file:
                line_clean = line.strip()
                var_name = f"d{layer_num}_{param_type}[{count}]"
                #out.write(f"logic [3:0] {var_name};\n")
                if (line_clean != ""): 
                    out.write(f"assign {var_name} = 4'h{line_clean};\n")
                    count += 1
        out.write("\n")  # Blank line between sections

print(f"Output written to {output_filename}")

