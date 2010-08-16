# encoding: utf-8
#
module UmlautSubstituter
  def substitute_umlauts text
    trans = ActiveSupport::Multibyte.proxy_class.new(text).normalize(:kd)

    # substitute special cases
    #
    trans.gsub!('ß', 'ss')

    # substitute umlauts (of A,O,U,a,o,u)
    #
    trans.gsub!(/([AOUaou])\314\210/u, '\1e')

    # get rid of ecutes, graves and …
    #
    trans.unpack('U*').select { |cp|
      cp < 0x0300 || cp > 0x035F
    }.pack('U*')
  end
end