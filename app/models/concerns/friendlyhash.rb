# Friendlyhash will replace the generated ActiveRecord id with a custom generated hash id.
# A migration will need to be added on model: rails g migration ... hash_id:string:index
#
# USAGE:
#  class User < ApplicationRecord
#    include Friendlyhash
#    ...


module Friendlyhash
  extend ActiveSupport::Concern

  included do
    extend ::FriendlyId
    before_create :set_hash_id
    friendly_id :hash_id
  end

  def set_hash_id
    hash_id = nil
    loop do
      hash_id = SecureRandom.urlsafe_base64(9).gsub(/-|_/,('a'..'z').to_a[rand(26)])
      break unless self.class.name.constantize.where(:hash_id => hash_id).exists?
    end
    self.hash_id = hash_id
  end

end
