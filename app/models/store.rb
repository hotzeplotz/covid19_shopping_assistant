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
class Store < ApplicationRecord
  RADIUS = 5000
  PROJECTION = 4326

  has_many :status_crowdsources

  # geocoded_by :address
  # reverse_geocoded_by :latitude, :longitude

  enum store_type: { 'supermarket': 1, 'pharmacy': 2, 'restaurant': 3 }

  validates :capacity, allow_nil: true, numericality: { greater_than: 0 }

  # after_validation :reverse_geocode
  # after_validation :geocode
  after_save :set_lonlat
  after_create :create_crowdsource_status

  def address
    [street, city].compact.join(',')
  end

  def self.search(search)
    return all unless search

    where('name ilike ? OR "group" ilike ? OR street ilike ? OR district ilike ? OR city ilike ?',
          "%#{search}%", "%#{search}%",
          "%#{search}%", "%#{search}%",
          "%#{search}%")
  end

  def self.retrieve_stores(lat, lon)
    query = <<~SQL
ST_CONTAINS(
  ST_BUFFER(
    ST_SetSRID(
      ST_MakePoint(#{lon}, #{lat}), 4326)::geography,
    #{RADIUS})::geometry,
    lonlat)
SQL

    Store.where(query)
  end

  private

  # x: longitude
  # y: latitude
  def set_lonlat
    return unless persisted? && latitude.present? && longitude.present?

    sql = <<~SQL
UPDATE stores
SET lonlat = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
WHERE id = #{id}
    SQL
    ActiveRecord::Base.connection.execute sql
  end

  def create_crowdsource_status
    status = StatusCrowdsourceUser.where(store_id: id).first
    return if status

    StatusCrowdsource.create(store_id: id, updated_time: Time.now)
  end
end
