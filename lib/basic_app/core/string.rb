class String

  # remove leading whitespace from multi-line text uniformly to the left most
  # character, used for HEREDOCs
  def unindent
    gsub(/^#{scan(/^\s*/).min_by{|l|l.length}}/, "")
  end
end
