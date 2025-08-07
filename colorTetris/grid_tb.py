x = str(input("flat grid: "))
x = x[::-1]  # reverse
print("tetris grid:\n")

# Print the grid
i = 0
grid = []
while i < len(x):
    row = x[i:i+10]
    print(f"{row}")
    grid.append(row)
    i = i + 10

print("grid print done\n")

# Calculate metrics
num_rows = len(grid)
num_cols = len(grid[0]) if grid else 0

# 1. Calculate individual vertical heights for each column
heights = []
for col in range(num_cols):
    height = 0
    for row in range(num_rows):
        if grid[row][col] == '1':
            height = num_rows - row
            break
    heights.append(height)

print(f"Individual column heights: {heights}")

# 2. Sum of heights
sum_heights = sum(heights)
print(f"Sum of heights: {sum_heights}")

# 3. Sum of differences between adjacent heights
sum_differences = 0
for i in range(len(heights) - 1):
    sum_differences += abs(heights[i] - heights[i + 1])
print(f"Sum of height differences: {sum_differences}")

# 4. Count holes (empty spaces with at least one tile above in same column)
holes = 0
for col in range(num_cols):
    found_tile = False
    for row in range(num_rows):
        if grid[row][col] == '1':
            found_tile = True
        elif found_tile and grid[row][col] == '0':
            holes += 1

print(f"Number of holes: {holes}")

# 5. Count rows that are all 1's (complete lines)
complete_rows = 0
for row in grid:
    if all(cell == '1' for cell in row):
        complete_rows += 1

print(f"Number of complete rows (all 1's): {complete_rows}")
