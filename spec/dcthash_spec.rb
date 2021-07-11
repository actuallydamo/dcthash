# frozen_string_literal: true

RSpec.describe Dcthash do
  expected_values = JSON.parse(File.read("spec/fixtures/hashes.json"))

  it "has a version number" do
    expect(Dcthash::VERSION).not_to be_nil
  end

  describe ".distance" do
    subject(:distance) { described_class.distance(hash1, hash2) }

    let(:hash1) { "97087fa6f03c134d" }
    let(:hash2) { "97087fa697087fa6" }

    describe "when the hashes are different" do
      let(:hash2) { "97087fa697087fa6" }

      it "calculates the hamming distance" do
        expect(distance).to eq(18)
      end
    end

    describe "when the hashes are identical" do
      let(:hash2) { hash1 }

      it "calculates the hamming distance as 0" do
        expect(distance).to eq(0)
      end
    end
  end

  describe ".similar?" do
    subject(:similar?) { described_class.similar?(hash1, hash2) }

    context "when hashes are 14 apart" do
      let(:hash1) { "0000000000000000" }
      let(:hash2) { "0000000000003fff" }

      context "when no threshold is provided" do
        it "returns false" do
          expect(similar?).to be false
        end
      end

      context "when a higher threshold is provided" do
        subject(:similar?) { described_class.similar?(hash1, hash2, 15) }

        it "returns true" do
          expect(similar?).to be true
        end
      end

      context "when a lower threshold is provided" do
        subject(:similar?) { described_class.similar?(hash1, hash2, 10) }

        it "returns false" do
          expect(similar?).to be false
        end
      end
    end

    context "when images are resized" do
      Dir["spec/fixtures/*_small.png"].each do |file|
        context "when test image #{file}" do
          let(:full_img) { Magick::Image.read(file.gsub("_small", "")).first }
          let(:small_img) { Magick::Image.read(file).first }
          let(:hash1) { described_class.calculate(full_img) }
          let(:hash2) { described_class.calculate(small_img) }

          it "returns true" do
            expect(similar?).to be true
          end
        end
      end
    end

    context "when images are converted to jpeg" do
      subject(:similar?) { described_class.similar?(hash1, hash2, 5) }

      Dir["spec/fixtures/*.jpg"].each do |file|
        context "when test image #{file}" do
          let(:png_img) { Magick::Image.read(file.gsub("jpg", "png")).first }
          let(:jpg_img) { Magick::Image.read(file).first }
          let(:hash1) { described_class.calculate(png_img) }
          let(:hash2) { described_class.calculate(jpg_img) }

          it "returns true" do
            expect(similar?).to be true
          end
        end
      end
    end
  end

  describe ".calculate" do
    subject(:calculate) { described_class.calculate(img) }

    expected_values.each do |primary_image|
      context "when primary image #{primary_image['file']}" do
        let(:img) { Magick::Image.read("spec/fixtures/#{primary_image['file']}").first }

        it "returns the expected hash" do
          expect(calculate).to eq(primary_image["hash"])
        end

        expected_values.each do |secondary_image|
          next if primary_image["file"] == secondary_image["file"]

          context "when comparing with #{secondary_image['file']}" do
            let(:hash1) { primary_image["hash"] }
            let(:hash2) { secondary_image["hash"] }
            let(:testing_similar_images) do
              (primary_image["file"] == "00631801.png" && secondary_image["file"] == "00631701.png") ||
                (primary_image["file"] == "00631701.png" && secondary_image["file"] == "00631801.png")
            end
            let(:expected_distance) { testing_similar_images ? 13 : 19 }

            it "does not collide" do
              expect(described_class.distance(hash1, hash2)).to be > expected_distance
            end
          end
        end
      end
    end
  end
end
