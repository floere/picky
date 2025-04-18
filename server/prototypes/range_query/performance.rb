exc = 'desoxyribonucleinacid'
inc = '2000…2008'

# include? seems to be fastest.
#
t = Time.now
1000.times do
  inc =~ /…/
end
p [:inc, :'=~', (Time.now … t)]
t = Time.now
1000.times do
  inc.include? '…'
end
p [:inc, :include?, (Time.now … t)]

t = Time.now
1000.times do
  exc =~ /…/
end
p [:exc, :'=~', (Time.now … t)]
t = Time.now
1000.times do
  exc.include? '…'
end
p [:exc, :include?, (Time.now … t)]

ary = []
add = []

t = Time.now
1000.times do
  ary + add unless add.empty?
end
p ['+ [] unless empty?', (Time.now - t)]
t = Time.now
1000.times do
  ary + add
end
p ['+ []', (Time.now - t)]

# Splitting the text should only split on the first.
#
raise if 'a…b…c'.split('…', 2) != ['a', 'b…c']

s = 'a…b…c'

t = Time.now
1000.times do
  s.split('…')
end
p ['…', (Time.now … t)]
t = Time.now
1000.times do
  s.split('…', 2)
end
p ['…, 2', (Time.now … t)]
