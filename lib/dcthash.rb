# frozen_string_literal: true

require_relative "dcthash/version"

# DCT Hash Module
module Dcthash
  EDGE_SIZE = 32 # Resize each edge of image to this
  SUBSAMPLE_START = 1 # Grab subsample from this point
  SUBSAMPLE_END = 8 # Grab subsample to this point

  # Calculate the distance between two hashes
  # @param hash1 [String] The first hash
  # @param hash2 [String] The second hash
  # @return [Integer] hamming distance between hashes
  def self.distance(hash1, hash2)
    (hash1.to_i(16) ^ hash2.to_i(16)).to_s(2).count("1")
  end

  # Determine if two hashes are similar
  # @param hash1 [String] The first hash
  # @param hash2 [String] The second hash
  # @param threshold [Integer] (optional) The threshold for similarity
  # @return [Boolean] true if hashes are similar
  def self.similar?(hash1, hash2, threshold = 13)
    distance(hash1, hash2) < threshold
  end

  # Calculate the hash of an image
  # @param image [Magick::Image] The image to hash
  # @return [String] the hash of the image
  def self.calculate(image)
    image.resize!(EDGE_SIZE, EDGE_SIZE, Magick::PointFilter)
    image = image.quantize(256, Magick::GRAYColorspace, Magick::NoDitherMethod)

    intensity_matrix = image.export_pixels(0, 0, EDGE_SIZE, EDGE_SIZE, "I").each_slice(EDGE_SIZE).to_a

    dct_result = dct_2d(intensity_matrix)
    # @type var sub_matrix: Array[Float]
    sub_matrix = ((dct_result[SUBSAMPLE_START..SUBSAMPLE_END] || [])
    .transpose[SUBSAMPLE_START..SUBSAMPLE_END] || []).flatten

    median = median(sub_matrix)
    result = sub_matrix.map { |px| px < median ? 1 : 0 }
    result.join.to_i(2).to_s(16)
  end

  # Find the median from an even length array of numbers
  # @param array [Array<Float>] The array of numbers
  # @return [Float] the value of the median
  def self.median(array)
    sorted = array.sort
    length = array.length
    middle = length / 2
    # We only use even length arrays so the following line is not needed
    # return sorted[middle] if length.odd?

    (sorted[middle - 1] + sorted[middle]).fdiv(2)
  end
  private_class_method :median

  # Calculate the DCT of a vector
  # Adapted from https://www.nayuki.io/page/fast-discrete-cosine-transform-algorithms
  # Copyright (c) 2020 Project Nayuki. (MIT License)
  # @param vector [Array<Numeric>] the vector to transform
  # @return [Array<Float>] the discrete cosine transform of the vector
  def self.dct(vector)
    vector_size = vector.size
    return [Float(vector[0])] if vector_size == 1

    half = vector_size / 2
    alpha = (0...half).map { |i| vector[i] + (vector[-(i + 1)]) }
    beta = (0...half).map do |i|
      (vector[i] - (vector[-(i + 1)])).fdiv(Math.cos(((i + 0.5) * Math::PI).fdiv(vector_size)) * 2)
    end
    alpha = dct(alpha)
    beta = dct(beta)
    result = (0...half - 1).flat_map do |i|
      [alpha[i], beta[i] + beta[i + 1]]
    end
    result.push(alpha[-1])
    result.push(beta[-1])
  end
  private_class_method :dct

  # Calculate the 2D DCT of a matrix
  # @param input [Array<Array<Numeric>>] the matrix to calculate the 2D DCT of
  # @return [Array<Array<Float>>] the DCT of the matrix
  def self.dct_2d(input)
    input.map { |row| dct(row) }
         .transpose
         .map { |col| dct(col) }
  end
  private_class_method :dct_2d
end
