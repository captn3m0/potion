#Configuration Stuff
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g #Gives us mustache style templating

#Our App
Potion = 
	render: (page,data={},controller)->
		$.get "views/"+page+".html", (html)->
			html=_.template html, data
			$('body').html html
			controller()
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
				user.repos (err,repos)->
					Potion.render "choose", repos, Potion.controller.choose
		choose: ()->
			#yet to fill

				
	init: ()->
		Potion.render "login", {}, Potion.controller.login

Potion.init()