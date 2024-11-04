'''
This python utility plots the dimension values of a vector dataset along with frequency of those values.
This script is useful to analyse a dataset. The current implementation is provided with a random dataset, but you can 
very well plugin in an actual dataset and then plot its values.
'''
import numpy as np
import matplotlib.pyplot as plt
import random
from matplotlib.ticker import FuncFormatter

SEED = 42

def set_seeds():
    """Set seeds for reproducibility"""
    np.random.seed(SEED)
    random.seed(SEED)

# normalize the vectors
def normalize(vectors, axis=1):
    return vectors / np.linalg.norm(vectors, axis=axis)[:, np.newaxis]

# generate the random vectors and then normalize those vectors
def generate_unit_vectors(n, dim):
    vectors = np.random.randn(n, dim)
    # Normalize to unit vectors
    vectors = normalize(vectors=vectors)
    return vectors


# generate the random vectors uniformly between -1 and 1 and then normalize those vectors
def generate_unit_vectors_with_uniform_random(n, dim):
    # Generate random vectors in the [-1, 1] range
    vectors = np.random.uniform(-1, 1, (n, dim))
    # Normalize to unit vectors
    vectors = normalize(vectors)
    return vectors

# plots the historgram
def plot_histogram(data, bins = 100, title="Vector Dimensions Distribution"):
    plt.hist(data, bins)
    plt.xlabel('Values')
    plt.ylabel('Frequency')
    plt.title(title)

    plt.show()

def main():
    set_seeds()
    # Example usage
    data = generate_unit_vectors(10000, 768)
    plot_histogram(data.flatten(), bins=int(len(data)/100)*2, title="Vector Dimensions Distribution with npRandom Function")
    plot_histogram(generate_unit_vectors_with_uniform_random(1000, 768).flatten(), bins=int(len(data)/100)*2, title="Vector Dimensions Distribution with Uniform distribution")

if __name__ == "__main__":
    main()
