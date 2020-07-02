Gem::Specification.new do |s|
  s.name        = 'GiteaAPI'
  s.version     = '1.0.0'
  s.date        = '2020-07-02'
  s.summary     = "Interact with Gitea API v1.1.1"
  s.description = "A gem for updating PRs in Gitea. Useful for build system integration"
  s.authors     = ["Robert Venturini"]
  s.email       = ''
  s.files       = ["lib/GiteaAPI.rb", 
                   "lib/GiteaAPI/Authentication.rb", 
                   "lib/GiteaAPI/PullRequest.rb", 
                   "lib/GiteaAPI/PullRequestReview.rb",
                   "lib/GiteaAPI/User.rb"
                   ]
  s.homepage    = 'https://github.com/robertventurini/GiteaAPI'
  s.license     = 'MIT'
end