class Entry
  attr_reader :value, :start_date, :end_date, :name
  def initialize(attrs = {})
    @value = attrs[:value] || 0.0
    @start_date = attrs[:start_date] || Date.today
    @end_date = attrs[:end_date] || nil
    @name = attrs[:name] || "--"
    if @start_date.present? && @end_date.present?
      raise ArgumentError.new if @end_date < @start_date
    end
  end

  def <=>(other)
    self.start_date <=> other.start_date
  end
end

class DailyEntry < Entry
end

class FixedEntry < Entry
end

class BuyEntry < Entry
  def initialize(attrs = {})
    super(attrs)
    @start_date = (attrs[:start_date] || Date.today).at_beginning_of_month
    @end_date = (attrs[:end_date] || @start_date.next_month).at_beginning_of_month
  end

  def modifier
    (value/period_in_days).round(2)
  end

  def period_in_days
    TimeDifference.between(start_date, end_date).in_days
  end

  def parcels
    TimeDifference.between(start_date, end_date).in_calendar_months.to_i
  end

  def parcel
    return parcels if Date.today >= end_date
    return TimeDifference.between(Date.today, start_date).in_calendar_months.to_i + 1
  end

end
