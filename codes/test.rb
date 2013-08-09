
def test(a)
	if a and not a.empty?
		puts 'sss'
  else
		puts 'ddd'
	end
end

test(nil)
test([])

test([1, 3])
