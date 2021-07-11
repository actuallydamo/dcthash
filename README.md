# DCTHash

This is Ruby Gem that can be used to produce and compare perceptual image hashes.

## Installation

### Prerequisites

On Debian/Ubuntu/Mint, you can run:
```sh
sudo apt get install libmagickwand-dev
```

On Arch you can run:
```sh
pacman -Sy pkg-config imagemagick
```

On macOS, you can run:
```sh
brew install pkg-config imagemagick
```

### Gem Install

Install via Bundler
```sh
bundle add dcthash
```

Or install via RubyGems:
```sh
gem install dcthash
```

## Usage

```ruby
require "dcthash"
require "rmagick"

image1 = Magick::Image.read("image1.png").first
image2 = Magick::Image.read("image2.png").first

# Generate image hashes
hash1 = Dcthash.calculate(image1)
hash2 = Dcthash.calculate(image2)

# Determine if hashes are similar
similar = Dcthash.similar?(hash1, hash2, threshold = 13)

# Calculate difference between two hashes
distance = Dcthash.distance(hash1, hash2)
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/actuallydamo/dcthash.


## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
