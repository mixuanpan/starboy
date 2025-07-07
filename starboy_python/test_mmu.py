#!/usr/bin/env python3
#balls
"""MMU/MAC Software Benchmark Script

Usage:
    python3 test_mmu.py [--depth D] [--size S] [--iters N]

This script measures the time to perform vector-matrix multiplications
equivalent to your hardware MMU/MAC design (1×depth vector × depth×size matrix).
"""

import argparse
import time
import numpy as np

def benchmark(depth, size, iters):
    # Generate random input vector and weight matrix
    A = np.random.randint(-128, 128, size=(depth,), dtype=np.int32)
    B = np.random.randint(-128, 128, size=(depth, size), dtype=np.int32)

    # Warm up
    _ = A.dot(B)

    start = time.perf_counter()
    for _ in range(iters):
        C = A.dot(B)
    end = time.perf_counter()

    total_time = end - start
    avg_time = total_time / iters
    macs = depth * size
    throughput = macs / avg_time

    print(f"Depth: {depth}, Size: {size}, Iterations: {iters}")
    print(f"Average inference time: {avg_time*1e6:.2f} μs")
    print(f"MACs per inference: {macs}")
    print(f"Throughput: {throughput/1e6:.2f} MMAC/s")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="MMU/MAC Software Benchmark")
    parser.add_argument("--depth", type=int, default=4, help="Length of input vector")
    parser.add_argument("--size", type=int, default=4, help="Number of outputs")
    parser.add_argument("--iters", type=int, default=100000, help="Repetitions for averaging")
    args = parser.parse_args()
    benchmark(args.depth, args.size, args.iters)
