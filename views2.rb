
class BuyEntryView

  def initialize(h = {})
    title_tpl     = "| %{month}                      |\n"
    entry_tpl     = "| %{name}    -R$ %{value}/%{tp}m |\n" +
    "| ----------------------------- |\n" +
    "|                  -R$ %{mod}/d |\n" +
    "| %{p}/%{tp} █|█|█|█|▒|▒|       |\n"
    summary_tpl   = "| ----------------------------- |\n" +
    "| PREV MOD:       -R$ %{pmod}/d |\n"
    #TODO: missing MOD, TOTAL?

    r = ""
    h.each_key {|k|
      r << title_tpl % {month: k} #TODO: date
      h[k][:entries].each {|e|
        r << entry_tpl % {name: e[:name], value: e[:value], tp: e[:parcels], p: e[:parcel], mod: e[:mod], }
      }
      r << summary_tpl % {pmod: "todo"}
    }

    @tpl = r
  end

  def print
    Kernel.print @tpl
  end
end

class DailyEntryView
  def initialize(h = {})
    title_tpl     = "|             #               |\n" +
                    "| --------------------------- |\n"
    entry_tpl     = "| #                      R$ # |\n"
    summary_tpl   = "|                ------------ |\n" +
                    "| TOTAL:               R$ #/d |\n" +
                    "| PREV BALANCE:           #/d |\n" +
                    "|                ------------ |\n" +
                    "| BALANCE:               R$ # |\n"
    r = ""
    h.each_key {|day|
      r += SCStringFormat.new(title_tpl).format(day.strftime("%d/%m"), :in_place)
      h[day][:entries].each {|e|
        r += SCStringFormat.new(entry_tpl).format(e.start_date.strftime("%d/%m"), :in_place, e.value, :from_place)
      }
      r += SCStringFormat.new(summary_tpl).format(h[day][:total], :from_place, "TODO", :from_place, "TODO", :from_place)
    }
    @tpl = r
  end

  def print
    Kernel.print @tpl
  end
end

class FixedEntryView
  attr_accessor :r
  def initialize(h = {})
    sep = "----"
    r = []
    r << "IN" << sep
    in_total = 0
    h[:income].each {|e|
      r << "#{e.name} R$#{e.value}"
      r << "R$#{e.value/30}/d"
      in_total += e.value/30
    }
    r << sep << "total: R$#{in_total}"
    r << sep << "OUT"
    out_total = 0
    h[:expense].each {|e|
      r << "#{e.name} R$#{e.value}"
      r << "R$#{e.value/30}/d"
      out_total += e.value/30
    }
    r << sep << "total: R$#{out_total}"
    r << sep << "V/D"
    r << "- Fixed Total: R$#{in_total + out_total}"
    r << "- Fixed V/D: R$#{in_total + out_total/30}/d"
    r << "- Buys V/D: TODO"
    r << ""
    
    @r = r.join("\n")
  end

  def print
    Kernel.print @r
  end
end

class SCStringFormat
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

  def initialize(base)
    @base = base
  end

  def format(substitution, type, *more)
    r = self.class.format(@base, substitution, type, *more)
    r
  end

  def self.format(base, sub, type, *more)
    raise ArgumentError.new("Missing substitution or type param") if sub.nil? || type.nil?
    raise ArgumentError.new("Unrecognized type: #{type}") if !TYPE.keys.include?(type)
    r = TYPE[type].call(base, sub.to_s)
    if more.any?
      r = format(r, more[0], more[1], more.drop(2))
    end
  end
end
