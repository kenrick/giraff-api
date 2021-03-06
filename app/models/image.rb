class Image < ActiveRecord::Base
  has_many :favorites
  has_many :passes

  scope :unpassed_by, ->(user) {
    joins("left join passes p on p.image_id=images.id and p.user_id=#{User.sanitize(user.id)}").
    where('p.id is null')
  }
  scope :unfavorited_by, ->(user) {
    joins("left join favorites f on f.image_id=images.id and f.user_id=#{User.sanitize(user.id)}").
    where('f.id is null')
  }
  scope :unseen_by, ->(user) { unpassed_by(user).unfavorited_by(user) }

  def self.faved_by(user)
    # Yep, this is a pretty gnarly query. Perhaps we should cache the current
    # fave/pass in another table. eg: judgements
    joins(:favorites).
      joins("left join passes p on p.image_id=images.id and p.user_id=#{User.sanitize(user.id)}").
      where(favorites: { user_id: user.id }).
      where('p is null or p.created_at < favorites.created_at')
  end
end
