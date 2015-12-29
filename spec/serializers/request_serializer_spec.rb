require 'rails_helper'

RSpec.describe RequestSerializer, type: :serializer do
    it "should output correct JSON for Location object" do
        loc = build(:location)
        u = loc.user
        serializer = RequestSerializer.new(loc, root: false)
        jsonloc = serializer.to_json
        fjsonloc = JSON.parse(jsonloc)
        expect(fjsonloc['email']).to eq(u.email)
        expect(fjsonloc['current_location']).to eq([loc.latitude.to_f, loc.longitude.to_f])
    end

    it "should output correct JSON for array of Location objects" do
        loc1 = build(:location)
        loc2 = build(:location)
        u1 = loc1.user
        u2 = loc2.user
        serializer = ActiveModel::ArraySerializer.new([loc1, loc2], each_serializer: RequestSerializer)
        jsonlocs = serializer.to_json
        fjsonlocs = JSON.parse(jsonlocs)
        expect(fjsonlocs[0]['email']).to eq(u1.email)
        expect(fjsonlocs[0]['current_location']).to eq([loc1.latitude.to_f, loc1.longitude.to_f])
        expect(fjsonlocs[1]['email']).to eq(u2.email)
        expect(fjsonlocs[1]['current_location']).to eq([loc2.latitude.to_f, loc2.longitude.to_f])
    end
end