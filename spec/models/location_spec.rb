require 'rails_helper'

RSpec.describe Location, type: :model do
    it { is_expected.to validate_presence_of(:latitude) }
    it { is_expected.to validate_presence_of(:longitude) }
    it { is_expected.to validate_numericality_of(:latitude).is_less_than_or_equal_to(90) }
    it { is_expected.to validate_numericality_of(:latitude).is_greater_than_or_equal_to(-90) }
    it { is_expected.to validate_numericality_of(:longitude).is_less_than_or_equal_to(180) }
    it { is_expected.to validate_numericality_of(:longitude).is_greater_than_or_equal_to(-180) }
    describe "radius" do
        it "should be zero on exact treasure location" do
            l = build(:treasure_location)
            expect(l.radius).to eq(0)
        end

        it "should be greater than zero on not exact treasure location" do
            l1 = build(:near_location)
            l2 = build(:distant_location)
            expect(l1.radius).to be > 0
            expect(l2.radius).to be > 0
        end

        it "should be less than five on near location" do
            l = build(:near_location)
            expect(l.radius).to be < 5
        end
    end
    describe "treasure?" do
        it "should be true on exact treasure location" do
            l = build(:treasure_location)
            expect(l).to be_treasure
        end
        it "should be true on near location" do
            l = build(:near_location)
            expect(l).to be_treasure
        end
        it "should be false on distant location" do
            l = build(:distant_location)
            expect(l).not_to be_treasure
        end
    end
end
