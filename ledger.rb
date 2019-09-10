class DailyEntries
  attr_accessor :map
  class DlyEntryHash < Hash
    def initialize(entry)
      self[entry.start_date || Date.today] = {
        entries: [entry],
        total: entry.value
      }
    end
  end

  def initialize
    @map = {
      Date.today => {
        entries: [],
        total: 0
      }
    }
  end

  def balance
    @map.sum {|k,v| @map[k][:total] }
  end

  def add(entry)
    @map.deeper_merge(DlyEntryHash.new(entry), {le_block: lambda {|x,y| x+y }})
  end
  alias_method :<<, :add
end

class FixedEntries
  attr_accessor :map
  def initialize
    @map = {
      income: SortedSet.new,
      expense: SortedSet.new,
      total: 0
    }
  end

  def add(entry)
    if entry.value >= 0
      @map[:income] << entry
    else
      @map[:expense] << entry
    end
    @map[:total] += entry.value
  end
  alias_method :<<, :add

  def available
    @map[:total]
  end
end

class BuyEntries
  attr_accessor :map
  class BuyEntrySlashes < Hash
    def initialize(entry)
      1.upto(entry.parcels) {|p|
        control_date = entry.start_date.next_month(p - 1)
        self["#{control_date.strftime("%m-%Y")}"] = {
          entries: [
            {
              parcel: p,
              parcels: entry.parcels,
              name: entry.name,
              mod: entry.modifier,
              value: entry.value,
              origin: entry
            }
          ],
          total: entry.modifier
        }
      }
    end
  end

  def initialize
    @map = {
      "#{Date.today.strftime("%m-%Y")}" => {
        entries: [],
        total: 0
      }
    }
  end

  #ind:
  # 0 = current
  #-1 = previous month
  # 1 = next month
  #def [](ind)
  #end

  def add(entry)
    @map.deeper_merge(BuyEntrySlashes.new(entry), {le_block: lambda {|x,y| x+y }, extend_existing_arrays: true})
  end
  alias_method :<<, :add

end

class Ledger
  attr_reader :data
  attr_reader :dailies
  attr_reader :fixeds
  attr_reader :buys

  def initialize
    @dailies = DailyEntries.new
    @fixeds = FixedEntries.new
    @buys = BuyEntries.new
    @data = {
      dly_entries: @dailies,
      fxd_entries: @fixeds,
      buy_entries: @buys,
    }
  end

  def vd
  end

  def da
    @fixeds.available
  end

  def balance
    @dailies.balance
  end

  def add(entry)
    case entry
    when DailyEntry
      @data[:dly_entries] << entry
    when FixedEntry
      @data[:fxd_entries] << entry
    when BuyEntry
      @data[:buy_entries] << entry
    else
      raise ArgumentError.new
    end
  end

  def rm(entry)
    #TODO: wont work with hashes without a origin-hash map
    case entry
    when DailyEntry
      @data[:dly_entries].delete entry
    when FixedEntry
      @data[:fxd_entries].delete entry
    when BuyEntry
      @data[:buy_entries].delete entry
    else
      raise ArgumentError.new
    end
  end

end
