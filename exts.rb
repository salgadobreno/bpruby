module DeepMerge
  def self.overwrite_unmergeables(source, dest, options)
    merge_debug = options[:merge_debug] || false
    overwrite_unmergeable = !options[:preserve_unmergeables]
    knockout_prefix = options[:knockout_prefix] || false
    di = options[:debug_indent] || ''
    le_block = options[:le_block]
    if knockout_prefix && overwrite_unmergeable
      if source.kind_of?(String) # remove knockout string from source before overwriting dest
        src_tmp = source.gsub(%r{^#{knockout_prefix}},"")
      elsif source.kind_of?(Array) # remove all knockout elements before overwriting dest
        src_tmp = source.delete_if {|ko_item| ko_item.kind_of?(String) && ko_item.match(%r{^#{knockout_prefix}}) }
      else
        src_tmp = source
      end
      if src_tmp == source # if we didn't find a knockout_prefix then we just overwrite dest
        puts "#{di}#{src_tmp.inspect} -over-> #{dest.inspect}" if merge_debug
        dest = src_tmp
      else # if we do find a knockout_prefix, then we just delete dest
        puts "#{di}\"\" -over-> #{dest.inspect}" if merge_debug
        dest = ""
      end
    elsif overwrite_unmergeable
      dest = source
    end
    if le_block
      dest = le_block.call(source, dest)
    end
    dest
  end
end
