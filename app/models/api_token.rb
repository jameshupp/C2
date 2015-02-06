class ApiToken < ActiveRecord::Base
  before_create :generate_token
  validates_presence_of :user_id, :cart_id
  belongs_to :cart
  belongs_to :user

  scope :unexpired, -> { where('expires_at >= ?', Time.now) }
  scope :unused, -> { where(used_at: nil) }
  scope :fresh, -> { unused.unexpired }

  def generate_token
    begin
      self.access_token = SecureRandom.hex
    end while self.class.exists?(access_token: access_token)
  end
end
