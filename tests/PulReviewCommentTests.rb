#
# PulReviewCommentTests.rb
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

require_relative '../lib/GiteaApi/PullReviewComment.rb'
require_relative '../lib/GiteaApi/Authentication.rb'
require_relative '../lib/GiteaApi/PullRequest.rb'
require_relative '../lib/GiteaApi/PullRequestReview.rb'
require_relative 'TestAssertions.rb'

def _sampleJson()
	return "{\"id\": 10108,
		\"body\": \"We should be concealing C++ over time behind the backend framework to so that the client application can interop from Swift with a pure ObjC API. Lets reconsider the need here and revert as necessary.\",
		\"user\": {
		  \"id\": 0,
		  \"login\": \"john.developer\",
		  \"full_name\": \"John Developer\",
		  \"email\": \"john.developer@email.com\",
		  \"avatar_url\": \"https://git-server.com/user/avatar/john.developer/-1\",
		  \"language\": \"\",
		  \"is_admin\": false,
		  \"last_login\": \"0001-01-01T00:00:00Z\",
		  \"created\": \"2019-01-08T21:51:26Z\",
		  \"username\": \"john.developer\"
		},
		\"pull_request_review_id\": 2079,
		\"created_at\": \"2020-07-01T19:48:08Z\",
		\"updated_at\": \"2020-07-02T19:44:32Z\",
		\"path\": \"/Backend/BirdseyeView.mm\",
		\"commit_id\": \"7636adf5d3c54584a4588f074a7902163ce61a8d\",
		\"original_commit_id\": \"\",
		\"diff_hunk\": \"+#import <Backend/Backend.h>\",
		\"position\": 12,
		\"original_position\": 0,
		\"html_url\": \"https://git-server.com/GiteaOwner/FocusApp/pulls/619#issuecomment-10108\",
		\"pull_request_url\": \"https://git-server.com/GiteaOwner/FocusApp/pulls/619\"}"
end


def testEmptyComment()
	comment = GiteaAPI::PullReviewComment.new()

	begin 
		comment.instance_variables.each do |ivar|
			assertNil(comment.instance_variable_get(ivar), ivar.to_s.gsub("@", ""))
		end

	rescue StandardError => error
		puts "* testEmptyComment() failed with error: #{error}"
		return
	end

	puts "* testEmptyComment() passed"
end


def testCommentFromJson()
	json = _sampleJson()
	jsonHash = JSON.parse(json)
	comment = GiteaAPI::PullReviewComment.fromJson(json)

	begin 
		comment.instance_variables.each do |ivar|
			assertNotNil(comment.instance_variable_get(ivar), ivar.to_s.gsub("@", ""))
		end

	rescue StandardError => error
		puts "* testCommentFromJson() failed with error\n\t- #{error}"
		return
	end


	## Check for equivalence with json hash
	begin 
		comment.instance_variables.each do |ivar|
			ivarname = ivar.to_s.gsub("@", "")
			jsonHashValue = jsonHash[ivarname]
			if ivarname == "user"
				user = GiteaAPI::User.new(jsonHashValue.to_json)
				assertEqual(comment.instance_variable_get(ivar), user)

			else
				assertEqual(comment.instance_variable_get(ivar), jsonHashValue)
			end
		end

	rescue StandardError => error
		puts "* testCommentFromJson() failed with error\n\t- #{error}"
		return
	end

	puts "* testCommentFromJson() passed"
end

def testCommentEquivalence()
	json = _sampleJson()
	comment1 = GiteaAPI::PullReviewComment.fromJson(json)
	comment2 = GiteaAPI::PullReviewComment.fromJson(json)

	begin 
		assertEqual(comment1, comment2)
	rescue
		puts "* testCommentEquivalence() failed with error\n\t- #{error}"
	end

	puts "* testCommentEquivalence() passed"
end

testEmptyComment()
testCommentFromJson()
testCommentEquivalence()
