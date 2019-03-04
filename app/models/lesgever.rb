# == Schema Information
#
# Table name: lesgevers
#
#  id                     :integer          not null, primary key
#  name                   :string(255)
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0)
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#

class Lesgever < ActiveRecord::Base
  has_many :groups
  has_and_belongs_to_many :roles
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable,
  # :lockable, :timeoutable and :omniauthable, :registerable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable
validates_presence_of :name
validates_uniqueness_of :name
  # Setup accessible (or protected) attributes for your model
  attr_accessible :name,:email, :password, :password_confirmation, :remember_me, :role_ids

  # http://www.tonyamoyal.com/2010/07/28/rails-authentication-with-devise-and-cancan-customizing-devise-controllers/
  def role?(role)
    # return !!self.roles.find_by_name(role.to_s)   <-- vorige versie, find_by deprecated met rails 4.0
    return !self.roles.where(name: role.to_s).empty?
  end
end
