class RequestSerializer < ActiveModel::Serializer
  attributes :email, :current_location

  def current_location
    [object.latitude.to_f, object.longitude.to_f]
  end

  def email
    object.user.email
  end
end
