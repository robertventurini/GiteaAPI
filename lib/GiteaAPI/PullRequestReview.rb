#
# PullRequestReview.rb
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

require_relative './User.rb'
require_relative './PullRequest.rb'

module GiteaAPI
	PullRequestReviewState = { "approve" => "APPROVED", "reject" => "REQUEST_CHANGES"}

	class PullRequestReview
		attr_reader :body                       ## String 
		attr_reader :numOfComments              ## Integer
		attr_reader :commitId                   ## String
		attr_reader :htmlUrl                    ## String
		attr_reader :id                         ## Integer
		attr_reader :official                   ## Boolean
		attr_reader :pullRequestUrl             ## String
		attr_reader :stale                      ## Boolean
		attr_reader :state                      ## String
		attr_reader :submitted                  ## Date (as String)
		attr_reader :user                       ## GiteaAPI::User

		def initialize(jsonString)
			reviewHash = JSON.parse(jsonString)

			@body = reviewHash["body"]
			@numOfComments = reviewHash["comments_count"]
			@commitId = reviewHash["commit_id"]
			@htmlUrl = reviewHash["html_url"]
			@id = reviewHash["id"]
			@official = reviewHash["official"].to_s.downcase == "true" ## Convert into boolean
			@pullRequestUrl = reviewHash["pull_request_url"]
			@stale = reviewHash["stale"].to_s.downcase == "true" ## Convert into boolean
			@state = reviewHash["state"]
			@submitted = reviewHash["submitted_at"]
			@user = GiteaAPI::User.new(reviewHash["user"].to_json)
		end 

		def to_s
			description = "GiteaAPI::PullRequestReview {\n"
			description.concat("\tstate: #{@state}\n") 
			description.concat("\tuser: #{@user}\n")
			description.concat("\tbody: #{@body}\n")
			description.concat("}\n")

    		return description
  		end

  		## Returns the set of reviews for a given pull request object; returns nil if unsuccessful
		 # 'auth' is required and must be of type GiteaAPI::Authentication
		 # 'pullRequest' is required and must be of type GiteaAPI::PullRequest
		def self.fetch(auth, pullRequest)
			if auth.is_a?(GiteaAPI::Authentication) == false 
				puts "ERROR: PullRequestReview.fetch first argument must be of type 'GiteaAPI::Authentication'"
				return nil
			end

			if pullRequest.is_a?(GiteaAPI::PullRequest) == false
				puts "ERROR: PullRequestReview.fetch 'pullRequest' argument must be of type 'GiteaAPI::PullRequest'"
				return nil
			end

			## Build URL for request
			uri = URI("#{auth.url}/#{auth.repo}/pulls/#{pullRequest.prnum}/reviews")
			
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

			jsonOutput = JSON.parse(response.body)
			pullRequestReviews = []

			for reviewHash in jsonOutput
				aReview = GiteaAPI::PullRequestReview.new(reviewHash.to_json)
				pullRequestReviews.push(aReview)
			end

			return pullRequestReviews
		end

  		## If successful, deletes the review on the gitea server and returns true
  		 # otherwise returns false if an error occurred.
  		 #
  		 # 'auth' is required and must be of type GiteaAPI::Authentication
		 # 'pullRequest' is required and must be of type GiteaAPI::PullRequest
		 # 'reviewId' is required and must be string or integer
		 #
  		 # Callers should cleanup local instances of a reviews that were deleted
  		 # successfully to avoid further interaction issues with the Gitea server.
		def delete(auth, pullRequest)
			uri = URI("#{auth.url}/#{auth.repo}/pulls/#{pullRequest.prnum}/reviews/#{@id}")
			
            response = nil
			Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
  				request = Net::HTTP::Delete.new(uri)
			    request['Authorization'] = "token #{auth.token}"
			    request['accept'] = "application/json"
			    
  				response = http.request request
			end

			if response.code.to_i < 200 or response.code.to_i >= 300
				puts "Error: unexpected response code received from server: #{response.code}"
				puts response

				return false
			end

			return true
		end
	end
end