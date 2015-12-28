FactoryGirl.define do
    factory :location do
        latitude { Forgery(:geo).latitude }
        longitude { Forgery(:geo).longitude }
        user

        factory :treasure_location do
            latitude { Location::TREASURE_LAT }
            longitude { Location::TREASURE_LON }
        end

        factory :near_location do
            latitude { Location::TREASURE_LAT - 0.00002 }
            longitude { Location::TREASURE_LON - 0.00002 }
        end

        factory :distant_location do
            latitude { Location::TREASURE_LAT - 2 }
            longitude { Location::TREASURE_LON - 2 }
        end
    end

end
