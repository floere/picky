class EachRSSItemProxy
  def each(&block)
    require 'rss'
    require 'open-uri'
    rss_feed = 'http://florianhanke.com/blog/atom.xml'
    rss_content = ''
    open rss_feed do |f|
       rss_content = f.read
    end
    rss = RSS::Parser.parse rss_content, true
    rss.items.each &block
  rescue
    # Don't call block, no data.
  end
end

RSSIndex = Picky::Index.new :rss do
  key_format :to_i
  source     EachRSSItemProxy.new
  key_format :to_s

  category   :title
  # etc...
end