class Post < ActiveRecord::Base
  belongs_to :catalogue

  default_scope  { order(:saving => :desc) }
end
