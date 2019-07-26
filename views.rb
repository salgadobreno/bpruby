class BuyEntryView

  def initialize(h = {})
    title_tpl     = "| %{month}                      |\n"
    entry_tpl     = "| ${name}    -R$ ${value}/${p}m |\n"
    "| ----------------------------- |\n"
    "|                  -R$ ${mod}/d |\n"
    "| ${p}/${tp} █|█|█|█|▒|▒|       |\n"
    summary_tpl   = "| ----------------------------- |\n"
    "| PREV MOD:       -R$ ${pmod}/d |\n"

    @tpl = (title_tpl + entry_tpl + summary_tpl) % h
  end

  def print
    Kernel.print @tpl
  end
end

class DailyEntryView
  def initialize(h = {})
    title_tpl     = "|           %{date}             |\n" +
                    "| ----------------------------- |\n"
    entry_tpl     = "| %{edate}          R$ %{value} |\n"
    summary_tpl   = "|                  ------------ |\n" +
                    "| TOTAL:         -R$ %{total}/d |\n" +
                    "| PREV BALANCE:R$ %{pbalance}/d |\n" +
                    "|                  ------------ |\n" +
                    "| BALANCE:      R$ %{balance}/d |\n"
    @tpl = (title_tpl + entry_tpl + summary_tpl) % h
  end

  def print
    Kernel.print @tpl
  end
end

class FixedEntryView
  def initialize(h = {})
    #TODO: change in place stuff
    #name: grow right
    #value, mod: grow from right
    title_tpl     = "| %{title}                      |\n" +
                    "| ----------------------------- |\n"
    entry_tpl     = "| %{name}           R$ %{value} |\n" +
                    "|                   R$ %{mod}/d |\n"
    total_tpl     = "|                   ----------- |\n" +
                    "| TOTAL:            R$ 123,12/d |\n"
    summary_tpl   = "| ----------------------------- |\n"
                    "| V/D:                          |\n"
                    "| - Fixed V/D:       R$ 53,12/d |\n"
                    "| - MODIFIER:        -R$ 3,12/d |\n"
                    "|                    ---------- |\n"
                    "|                    R$ 50,00/d |\n"
    @tpl = (title_tpl + entry_tpl + total_tpl + summary_tpl) % h
  end

  def print
    Kernel.print @tpl
  end
end

module SCStringFormat
  CHAR = "#"
  TYPE = {
    in_place: lambda {|base, sub|
      char_i = base.index(CHAR)
      return base if char_i.nil?
      new = String.new(base)
      0.upto(sub.length - 1) {|i|
        new[char_i + i] = sub[i]
      }
      new
    },
    from_place: lambda {|base, sub|
      char_i = base.index(CHAR)
      return base if char_i.nil?
      new = String.new(base)
      0.upto(sub.length - 1) {|i|
        new[char_i - sub.length + 1 + i] = sub[i]
      }
      new
    },
    none: lambda {|base, sub|
      base.gsub(CHAR, sub)
    },
  }

  def self.format(base, sub, type)
    return TYPE[type].call(base, sub)
  end
end
