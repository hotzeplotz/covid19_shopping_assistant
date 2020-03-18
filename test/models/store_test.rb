# == Schema Information
#
# Table name: stores
#
#  id         :bigint           not null, primary key
#  name       :string
#  group      :string
#  street     :string
#  city       :string
#  district   :string
#  country    :string
#  zip_code   :string
#  latitude   :float
#  longitude  :float
#  capacity   :integer
#  details    :text
#  store_type :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  lonlat     :geometry         point, 0
#
require 'test_helper'

class StoreTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
