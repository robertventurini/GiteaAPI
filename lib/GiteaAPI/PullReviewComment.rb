#
# PullReviewComment.rb
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
require 'net/http'

module GiteaAPI
	class PullReviewComment
		attr_reader :body
		attr_reader :commit_id
		attr_reader :created_at
		attr_reader :diff_hunk
		attr_reader :html_url
		attr_reader :id
		attr_reader :original_commit_id
		attr_reader :original_position
		attr_reader :path
		attr_reader :position
		attr_reader :pull_request_review_id
		attr_reader :pull_request_url
		attr_reader :updated_at
		attr_reader :user

		def initialize()
			@body = nil
			@commit_id = nil
			@created_at = nil
			@diff_hunk = nil
			@html_url = nil
			@id = nil
			@original_commit_id = nil
			@original_position = nil
			@path = nil
			@position = nil
			@pull_request_review_id = nil
			@pull_request_url = nil
			@updated_at = nil
			@user = nil
		end 

		def to_s
			description = "#{self.class.name} {\n"
			instance_variables.each do |ivar|
				variableName = ivar.to_s.gsub("@", "")
				description.concat("\t#{variableName}: #{instance_variable_get(ivar)}\n")
			end

			description.concat("}\n")
    		return description
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

  		## Deserialization
  		def self.fromJson(jsonString)
  			commentHash = JSON.parse(jsonString)
  			comment = PullReviewComment.new()
  			commentHash.each do |key, value|
    			next unless comment.instance_variable_defined?("@#{key}")
    			
    			if key == "user"
    				## Deserialize user object as GiteaAPI::User
    				user = GiteaAPI::User.new(value.to_json)
    				comment.instance_variable_set("@#{key}", user)
    			else
	    			comment.instance_variable_set("@#{key}", value)
	    		end
			end

			return comment
  		end

  		## Fetch set of comments on a given pr review
  		def self.fetch(auth, pullRequest, review)
  			## Build URL for fetching comments
			uri = URI("#{auth.url}/#{auth.repo}/pulls/#{pullRequest.prnum}/reviews/#{review.id}/comments")

            response = nil
			Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
  				request = Net::HTTP::Get.new(uri)
			    request['Authorization'] = "token #{auth.token}"
			    request['accept'] = "application/json"

  				response = http.request request
			end

			if response.code.to_i < 200 or response.code.to_i >= 300
				puts "Error: unexpected response code received from server: #{response.code}"
				puts response

				return nil
			end
			puts response.body
			exit
			jsonOutput = JSON.parse(response.body)
			comments = []

			for commentHash in jsonOutput
				aComment = self.fromJson(commentHash.to_json)
				comments.push(aComment)
			end

			return comments
  		end
  	end
end