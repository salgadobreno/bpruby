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

$LEDGER = Ledger.new

def add(entry)
  $LEDGER.add(entry)
end

def init
  $LEDGER = Ledger.new
end
