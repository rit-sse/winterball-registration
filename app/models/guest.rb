class Guest < ActiveRecord::Base
  validates_uniqueness_of :ticketnumber
  validates_presence_of :name, :ticketnumber
  validates_format_of :ticketnumber, :with => /^\d{1,3}$/i, :message => "must be a three digit number."
end
