#Our App
Potion = 
	render: (page,data={},controller)->
		x=jade.render(document.body, page, data)
		controller?()
	busy:
		show: ()->
			$('.busy').removeClass('hidden')
		hide: ()->
			$('.busy').addClass('hidden')
	controller: 
		#Login controller handles login information
		login: ()->
			$('#password').keyup (e)->
				$('#login').click() if e.keyCode==13
			$('#login').click ()->
				Potion.github = new Github {
				  username: $('#username').val(),
				  password: $('#password').val(),
				  auth: "basic"
				};
				user = Potion.github.getUser();
				Potion.busy.show()
				user.repos (err,repos)->
					Potion.busy.hide()
					Potion.controller.choose repos
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
				repo.getTree branch+'?recursive=true', (err,tree)->
					Potion.busy.hide()
					console.log err if err
					console.log tree
				
	init: ()->
		Potion.render "login", {}, Potion.controller.login

$(document).ready ()->
	Potion.init()

#We will setup routing later...