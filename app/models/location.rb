class Location < ActiveRecord::Base
    TREASURE_LAT = 50.051227
    TREASURE_LON = 19.945704
    R = 6371000 # Earth' s radius

    belongs_to :user

    validates :latitude, presence: true, numericality: {greater_than_or_equal_to: -90, less_than_or_equal_to: 90}
    validates :longitude, presence: true, numericality: {greater_than_or_equal_to: -180, less_than_or_equal_to: 180}

    def radius
        # Haversine formula
        phi1 = Location.to_radians(self.latitude)
        phi2 = Location.to_radians(TREASURE_LAT)
        lambda1 = Location.to_radians(self.longitude)
        lambda2 = Location.to_radians(TREASURE_LON)
        h = Location.hav(phi2-phi1) + Math.cos(phi1)*Math.cos(phi2)*Location.hav(lambda2-lambda1)
        d = 2*R*Math.asin(Math.sqrt(h))
    end

    def treasure?
        radius <= 5
    end

    private

    def self.to_radians(deg)
      deg * Math::PI / 180
    end

    def self.hav(theta)
       (1-Math.cos(theta))/2  #/ Just a fix for syntax highlighting in jEdit
    end
end
