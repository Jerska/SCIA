require 'thread/pool'

pool = Thread.pool 4

$count = 0

def bench nb
  start = Time.now
  pool = Thread.pool 100
  nb.times do |i|
    pool.process i do |i|
      yield i
    end
  end
  pool.shutdown
  puts "[#{$count += 1}] Took #{Time.now - start} seconds"
end

$i = [0] * 10000
bench 10000 do |j|
  1000.times do
    $i[j] += 1
  end
end

$i = [0] * 10000
bench 10000 do |j|
  res = 0
  1000.times do
    res += 1
  end
  $i[j] = res
end
