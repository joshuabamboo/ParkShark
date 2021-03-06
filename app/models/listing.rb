class Listing < ActiveRecord::Base
  validates_presence_of :beginning_time, :ending_time, :price
  belongs_to :spot
  has_one :owner, :class_name => 'User', :through => :spot
  has_one :reservation

  def status
    self.available ? "Available" : "Occupied"
  end

  def is_available_between(start_time, end_time)
    if self.ending_time <= end_time && self.beginning_time <= start_time
      true
    else
      false
    end
  end
end
