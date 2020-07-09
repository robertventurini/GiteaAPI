#
# User.rb
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


require 'json'

module GiteaAPI
	class User
		attr_reader :fullname
		attr_reader :email
		attr_reader :login
		attr_reader :id
		attr_reader :isAdmin
		attr_reader :avatarUrl
	
		attr_reader :language
		attr_reader :lastLogin
		attr_reader :created

		def initialize(jsonString)
			userHash = JSON.parse(jsonString)

			@id = userHash["id"]
			@isAdmin = userHash["is_admin"].to_s.downcase == "true" ## Convert into boolean
			@avatarUrl = userHash["avatar_url"]
			@created = userHash["created"]                          ## TODO: Consider conversion to date instance
			@email = userHash["email"]
			@fullname = userHash["full_name"]
			@language = userHash["language"]
			@lastLogin = userHash["last_login"]                     ## TODO: Consider conversion to date instance
			@login = userHash["login"]
		end 

		def to_s
			descriptionComponents = ["GiteaAPI::User {\n",
									"\tname: #{@fullname}\n",
									"\temail: #{@email}\n", 
									"\tlogin: #{@login}\n", 
									"\tisAdmin: #{@isAdmin}\n",
									"\tavatar: #{@avatarUrl}\n",
									"\tlanguage: #{@language}\n",
									"\tlastLogin: #{@lastLogin}\n",
									"}"]

    		return descriptionComponents.join("")
  		end

  		## Equality
  		def ==(other)
  			if other.is_a?(self.class) == false
  				return false
  			end

  			instance_variables.each do |ivar|
				mine = self.instance_variable_get(ivar)
				theirs = other.instance_variable_get(ivar)

				if mine != theirs
					return false
				end
			end

			return true
  		end
	end
end