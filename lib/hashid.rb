class HashId
	class Error < StandardError; end

	def initialize(salt = nil)
		@salt = salt || 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'
		
		@letters = [
			'P0MVLWNTZD',
			'UE58X2VSCT',
			'43Z0Y9AQLS',
			'V5Q1P4E8L9',
			'MOIRZCWXED',
			'7NBYXCZU9R',
			'G2S90I84MC',
			'TQAMIWH4ZC',
			'POERHBYA1F',
			'XKO20UB3IL',
			'Y0NTH78VSO',
			'P4DE6VUZLK',
			'9OKN2JLQGI',
			'61UTFSN0BR',
			'R7ZAHJVGE9',
			'ADHIZ5WNUQ',
			'Z9SPX2OQI5',
			'V7YFEU4PTJ',
			'YZVFD6UXNG',
			'VH8UDLCE93',
			'W0H5GMTFZK',
			'GXE6CT2VOP',
			'QH2FLZOM9V',
			'MBGHIF78PU',
			'MHS04FY8L7',
			'E95IGRSMZ1',
			'MN8AILRB95',
			'S7JVO4EHCD',
			'GT01ZPLVUA',
			'9OKN2JLQGI',
			'DUF24AGTSN',
			'4ASPNFJ2BR',
			'OR465YEXQV',
			'DUF24AGTSN',
			'M78PCRAGKS',
			'D8LVQSKA7U'
		]
		
		@indexes = [
			[0,0],
			[0,1],
			[1,0],
			[2,0],
			[0,2],
			[1,1],
			[2,1],
			[1,2]
		]
	end
	
	def self.generate_salt
		'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890'.split(//).shuffle.join('')
	end
	
	def encrypt(string, len = 8)
	
		# Require a fixnum for the encryption process
		raise Error, 'HashID.encrypt expected a Fixnum as its argument' unless string.is_a?(Fixnum)
		
		# Require a fixnum for the encryption process
		raise Error, 'HashID.encrypt must have a length of no less then 6' unless string.is_a?(Fixnum)
	
		# Prep the string for encryption
		string = string.to_s.rjust(len, '0')
	
		# Get the salt ids to use
		saltids = Array.new
		random = [*0..35].shuffle
		3.times{saltids<<random.shift}
		
		# Get the letters cooresponding to the salts
		salts = saltids.collect{|x|@letters[x]}
		
		# Go ahead and convert the numbers into the new format
		i=2;string=string.split(//).collect{|x|i==2?i=0:i+=1;salts[i][x.to_i,1]}.join('')
		
		# Turn the salt ids into their letter forms
		saltids.collect!{|x|@salt[x,1]}
		
		# Get the index id and the indexes
		indexid = [*0..7].shuffle.first
		injections = @indexes[indexid]
		
		# Inject the indexes and index id
		string.insert(injections.first, saltids[0])
		string.insert(string.length - injections.last, saltids[1])
		string << saltids[2] + @salt[indexid,1]
	end
	
	def decrypt(string)
	
		# Require a string for the decryption process
		raise Error, 'HashID.decrypt expected a String as its argument' unless string.is_a?(String)
	
		# Prep the string for decryption
		string = string.upcase.gsub(/[^A-Z0-9]+/, '').split(//)
		
		# Require no less then 8 characters
		raise Error, 'A minimum of 8 characters is required for decryption' if string.length < 8
		
		begin
			# Get the indexes and index id
			indexid = @salt.index(string.pop)
			injections = @indexes[indexid]
			
			# Go ahead and locate the salts
			saltids = [string.pop]
			saltids << string.slice!(string.length - 1 - injections.last)
			saltids << string.slice!(injections.first)
			
			# Go ahead and reverse and determine the salt ids
			saltids = saltids.reverse.collect{|x|@salt.index(x)}
			
			# Get the letters cooresponding to the salts
			salts = saltids.collect{|x|@letters[x]}
			
			# Go ahead and convert the alphanumeric id back into numbers
			i=2;string=string.collect{|x|i==2?i=0:i+=1;salts[i].index(x)}.join('')
			
			# Return the integer
			return string.to_i
		rescue
			raise Error, 'The ID provided was not decryptable'
		end
	end
end

# Convert Fixnum to HashId (String)
class Fixnum
	def to_hashid(salt = nil)
		HashId.new(salt).encrypt(self)
	end
end

# Convert HashId (String) to Fixnum
class String
	def from_hashid(salt = nil)
		HashId.new(salt).decrypt(self)
	end
end

# Rails 3 Extension
if defined? ActiveRecord::Base
	module KellyLSB
	module HashId
		extend ActiveSupport::Concern

		module ClassMethods
			def hashid(salt)
				send(:include, Module.new {
					send(:define_method, :id) do |*args|
						_id = read_attribute(:id)
						return _id unless _id.respond_to?(:to_hashid)
						_id.to_hashid(salt).parameterize
					end
				})

				send(:extend, Module.new {
					send(:define_method, :find_by_hashid) do |hashid|
						hashid = hashid.from_hashid(salt) if hashid.is_a?(String)
						find(hashid)
					end
				})
			end
		end
	end
	end

	ActiveRecord::Base.send(:include, KellyLSB::HashId)
end