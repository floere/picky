# By default, Picky uses Yajl.
#
# It has proven to be the fastest, most
# memory conservative adapter of them all.
#
MultiJson.use :yajl if defined? ::Yajl