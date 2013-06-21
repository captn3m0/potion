#Our App
Potion = 
	render: (page,data={},controller)->
		#order is DOM, TEMPLATE, DATA
		x=jade.render(document.body, page, data)
		controller?(data)
	busy:
		show: ()->
			$('.busy').removeClass('hidden')
		hide: ()->
			$('.busy').addClass('hidden')
	controller: 
		#Login controller handles login information
		login: ()->
			$('#password,#username').keyup (e)->
				$('#login').click() if e.keyCode==13
			$('#login').click ()->

				Potion.busy.show()
				username=$('#username').val()
				password=$('#password').val()
				Potion.github = new Github {
				  username: username,
				  password: password,
				  auth: "basic"
				};
				user = Potion.github.getUser();
				#After callback to handle the repos list
				after =(err,repos)->
					if err
						$('.notice').html("<p>There was an error while logging in to your account. Please check your username (and password).").addClass('error')
					Potion.busy.hide()
					Potion.controller.choose repos
				#We use different functions based on
				#whether we have password or not
				if password.length>0
					user.repos after
				else
					#Our github lib doesn't support this
					#So we freestyle and use JQuery
					$.getJSON "https://api.github.com/users/"+username+"/repos", (data)->
						after null,data
					.error ()->
						after true,null

		#Choose a repository and a branch
		choose: (repos)->
			Potion.render "choose", {list:repos}
			$('#continue').click ()->
				reponame=$('#reponame').val().split('/')[1]
				username=$('#reponame').val().split('/')[0]
				branch=$('#branchname').val()
				repo = Potion.github.getRepo(username, reponame);
				#Make requests to github to get the list of files
				Potion.busy.show()
				repo.getTree branch+'?recursive=true', (err,data)->
					Potion.busy.hide()
					#Break up the tree into drafts and posts
					drafts=[]
					posts=[]
					for file in data
						drafts.push file if file.path.slice(0,8)=="_drafts/"
						posts.push  file if file.path.slice(0,7)=="_posts/"
					Potion.render "admin", {drafts:drafts,posts:posts}, Potion.controller.admin
					
		admin: (files)->
			console.log files
	init: ()->
		Potion.render "login", {}, Potion.controller.login

$(document).ready ()->
	Potion.init()

#We will setup routing later...