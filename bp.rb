$LOAD_PATH << '.'
require 'awesome_print'
require 'deep_merge/rails_compat'
require 'active_support'
require 'active_support/core_ext'
require 'pry'
require 'pry-byebug'
#require 'pry-nav'
#require 'pry-rescue'
AwesomePrint.pry!

require 'date'
require 'time_difference'

load 'exts.rb'

load 'ledger.rb'
load 'entry.rb'
load 'views.rb'

$LEDGER = Ledger.new

def add(entry)
  $LEDGER.add(entry)
end

def init
  $LEDGER = Ledger.new
  watch $LEDGER.data
end

def dlist
  DailyEntryView.new(
    $LEDGER.data[:dly_entries].map
  ).print
end

def flist
  FixedEntryView.new(
    $LEDGER.data[:fxd_entries].map
  ).print
end

def blist
  BuyEntryView.new(
    $LEDGER.data[:buy_entries].map
  ).print
end
