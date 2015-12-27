class Location < ActiveRecord::Base
    TREASURE_LAT = 50.051227
    TREASURE_LON = 19.945704

    belongs_to :user

    validates :latitude, presence: true, numericality: {greater_than_or_equal_to: -90, less_than_or_equal_to: 90}
    validates :longitude, presence: true, numericality: {greater_than_or_equal_to: -180, less_than_or_equal_to: 180}

    def radius
        # Haversine formula
        R = 6371000 # Earth' s radius
        phi1 = latitude * Math::PI / 180
        phi2 = TREASURE_LAT * Math::PI / 180
        dphi = (TREASURE_LAT - longitude) * Math::PI / 180
        dlambda = (latitude - TREASURE_LON) * Math::PI / 180
        a = Math.sin(dphi/2) * Math.sin(dphi/2) + Math.cos(phi1) * Math.cos(phi2) * Math.sin(dlambda/2) * Math.sin(dlambda/2)
        c = 2*Math.atan2(sqrt(a), sqrt(1-a))
        d = R*c
    end

    def treasure?
        radius <= 5
    end
end
