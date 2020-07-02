#
# PullRequest.rb
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

require_relative './Authentication.rb'
require_relative './PullRequestReview.rb'
require_relative './User.rb'

module GiteaAPI
	PullRequestState = { "closed" => "closed", "open" => "open", "all" => "all" } 
	PullRequestSort = { 
		"oldest" => "oldest",
		"recentupdate" => "recentupdate", 
		"leastupdate" => "leastupdate",
		"mostcomment" => "mostcomment", 
		"leastcomment" => "leastcomment",
		"priority" => "priority"
	}

	class PullRequest
		attr_reader :id
		attr_reader :prnum
		attr_reader :url
		attr_reader :target
		attr_reader :source
		attr_reader :title
		attr_reader :description
		attr_reader :author
		attr_reader :state

		def initialize(jsonString)
			prHash = JSON.parse(jsonString)

			@id = prHash["id"]
			@prnum = prHash["number"]
			@url = prHash["html_url"]
			@target = prHash["base"]["ref"]   ## TODO: Specify Branch Model
			@source =  prHash["head"]["ref"]  ## TODO: Specify Branch Model

			@title = prHash["title"]
			@description = prHash["body"]
			@author = GiteaAPI::User.new(prHash["user"].to_json)  ## Downconvert back ot a json string and pass on to User initializtion
			@state = prHash["state"]
		end 

		def to_s
			## Author is of type user and warrants special indentation
			unalteredAuthorComponents = @author.to_s.split("\n")
			indentedAuthorComponents = []

			unalteredAuthorComponents.each_with_index do |component, index|
				if index != 0
					component.prepend("\t")
				end

				indentedAuthorComponents.push component
			end

			authorDescription = indentedAuthorComponents.join("\n")

			descriptionComponents = ["GiteaAPI::PullRequest {\n",
									 "\tnumber: #{@prnum}\n", 
									 "\ttitle: #{@title}\n",
									 "\tauthor: #{authorDescription}\n",
									 "\tstate: #{@state}\n",
									 "\tid: #{@id}\n",
									 "\ttarget: #{@target}\n", 
									 "\tsource: #{@source}\n",
									 "\tdescription: #{@description}\n",
									 "}"]
			return descriptionComponents.join("")
  		end

  		## Returns the set of pull requests matching the state filter and sort criteria. 
		 # Nil is returned if the request could not be made, or a response code other than 200 received.
		 #
		 # 'auth' is required and must be of type GiteaAPI::Authentication
		 # 'pullRequestState' defaults to PullRequestState["open"]
		 # 'pullRequestSort' defaults PullRequestSort["recentupdate"]
		 # 'limit' defaults to unlimited (0)
		def self.fetch(auth, pullRequestState=nil, pullRequestSort=nil, limit=0)
			if auth.is_a?(GiteaAPI::Authentication) == false 
				puts "ERROR: PullRequest.fetch first argument must be of type 'GiteaAPI::Authentication'"
				return nil
			end

			## Setup defaults if caller omitted string values for state and sort
			pullRequestState = pullRequestState.is_a?(String) ? pullRequestState : PullRequestState["open"]
			pullRequestSort = pullRequestSort.is_a?(String) ? pullRequestSort : PullRequestSort["recentupdate"]


			## Build URL for request
			url = "#{auth.url}/#{auth.repo}/pulls?state=#{pullRequestState}&sort=#{pullRequestSort}"

			## Enforce limit (if caller provided any)
			if limit > 0 
				url = "#{url}&limit=#{limit}"
			end
			
			uri = URI(url)
			
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
			pullRequests = []

			for prHash in jsonOutput
				pr = GiteaAPI::PullRequest.new(prHash.to_json)
				pullRequests.push(pr)
			end

			return pullRequests
		end

		## Returns nil if request was unsuccessful, otherwise returns the review that was generated
		def review(auth, message, approve=true)
			if auth.is_a?(GiteaAPI::Authentication) == false 
				puts "ERROR: PullRequest.review first argument must be of type 'GiteaAPI::Authentication'"
				return nil
			end

			if message.is_a?(String) == false or (!!approve != approve)
				return nil
			end

			uri = URI("#{auth.url}/#{auth.repo}/pulls/#{@prnum}/reviews")
			
            response = nil
			Net::HTTP.start(uri.host, uri.port, :use_ssl => uri.scheme == 'https') do |http|
  				request = Net::HTTP::Post.new(uri)
			    request['Authorization'] = "token #{auth.token}"
			    request['accept'] = "application/json"
			    request['Content-Type'] = "application/json"
			    request.body = {:body => message, :event => approve ? "APPROVED" : "REQUEST_CHANGES"}.to_json
  				response = http.request request
			end

			if response.code.to_i < 200 or response.code.to_i >= 300
				puts "Network error occurred: #{response.code}"
				return nil
			end

			return GiteaAPI::PullRequestReview.new(response.body)
		end
	end
end