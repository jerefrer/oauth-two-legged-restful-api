class ApiUser < ActiveRecord::Base
  attr_accessible :api_key, :email, :secret

  validates :email, :presence => true, :uniqueness => true

  before_create :generate_api_key_and_secret

  private

  def generate_api_key_and_secret
    begin
      self.api_key = OAuth::Helper.generate_key(40)[0,40]
      self.secret = OAuth::Helper.generate_key(40)[0,40]
    end while ApiUser.find_by_api_key_and_secret(api_key, secret)
  end
end
