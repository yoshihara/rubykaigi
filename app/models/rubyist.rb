class Rubyist < ActiveRecord::Base
  extend  ActiveSupport::Memoizable

  has_many :contributions

  validates_uniqueness_of :username
  validates_format_of :username, :with => /[\w-]+/
  validates_exclusion_of :username, :in => %w(new edit)

  validates_uniqueness_of :twitter_user_id, :allow_nil => true
  validates_uniqueness_of :identity_url, :allow_nil => true

  attr_protected :twitter_user_id, :identity_url

  def to_param
    username
  end

  def contributions_on(kaigi_year = RubyKaigi.latest.year)
    contributions.select{|c| c.kaigi.year == kaigi_year}
  end

  def individual_sponsor?(kaigi_year = RubyKaigi.latest.year)
    contribution_types_of(kaigi_year).include?('individual_sponsor')
  end

  def attendee?(kaigi_year = RubyKaigi.latest.year)
    __attendee?(kaigi_year) || individual_sponsor?(kaigi_year)
  end

  def party_attendee?(kaigi_year = RubyKaigi.latest.year)
    contribution_types_of(kaigi_year).include?('party_attendee')
  end

  private
  def contribution_types_of(kaigi_year)
    contributions.select {|c| c.ruby_kaigi.year == kaigi_year }.map(&:contribution_type)
  end
  memoize :contribution_types_of

  def __attendee?(kaigi_year)
    contribution_types_of(kaigi_year).include?('attendee')
  end
end
