#
# Authentication.rb
#
# Copyright 2020 Robert Venturini
#
# Permission is hereby granted, free of charge, to any person obtaining a copy of this software 
# and associated documentation files (the "Software"), to deal in the Software without restriction, 
# including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, 
# and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, 
# subject to the following conditions: The above copyright notice and this permission notice shall 
# be included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT 
# LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN 
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, 
# WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
# SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module GiteaAPI
	class Authentication
		def self.new(*args, &blk)
			if args.count < 2
				return nil
			end

			for i in 0..2
				arg = args[i]
				if arg.is_a?(String) == false
					return nil
				end
			end
			
    		o = allocate
    		o.send(:initialize, *args, &blk)
    		return o
  		end

		def initialize(baseURL, repo, token)
			@url = baseURL
			@token = token
			@repo = repo
		end

		def to_s
			descriptionComponents = ["GiteaAPI::Authentication {\n",
									"\tapi url: #{@@url}\n",
									"\trepo: #{@repo}\n", 
									"\ttoken: #{@token}\n",
									"}"]

    		return descriptionComponents.join("")
  		end

		attr_reader :url
		attr_reader :repo
		attr_reader :token
	end
end