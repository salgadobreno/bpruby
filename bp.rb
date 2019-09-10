$LOAD_PATH << '.'
require 'awesome_print'
require 'deep_merge/rails_compat'
require 'active_support'
require 'active_support/core_ext'
require 'pry'
#require 'pry-byebug'
#require 'pry-nav'
#require 'pry-rescue'
AwesomePrint.pry!

require 'date'
require 'time_difference'

load 'exts.rb'

load 'ledger.rb'
load 'entry.rb'
load 'views2.rb'

def self.add(entry)
  @ledger.add(entry)
  save if @autosave
end

def self.dlyadd(value)
  add(DailyEntry.new(value: value))
end

def self.fxadd(name, value)
  add(FixedEntry.new(name: name, value: value))
end

def self.init
  if File.exists?("data")
    @ledger = Marshal.load(File.read("data"))
  else
    @ledger = Ledger.new
  end
end

def self.save
  File.open("data", "w") {|f|
    f.write(Marshal.dump(@ledger))
  }
  p "success"
end

def self.balance
  @ledger.balance
end

def self.available
  @ledger.da
end

def self.dlist
  DailyEntryView.new(
    @ledger.data[:dly_entries].map
  ).print
end

def self.flist
  FixedEntryView.new(
    @ledger.data[:fxd_entries].map
  ).print
end

def self.blist
  BuyEntryView.new(
    @ledger.data[:buy_entries].map
  ).print
end

def set_watches(pry)
  pry.eval "watch flist"
end

init
@autosave = true
