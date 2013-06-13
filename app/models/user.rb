class User < ActiveRecord::Base
  attr_accessible :email, :username

  validates_presence_of :email, :username
  validates_uniqueness_of :email, :username
end
