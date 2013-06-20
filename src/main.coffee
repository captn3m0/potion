#Our App
Potion = 
	render: (page,data={},controller)->
		x=jade.render(document.body, page, data)
		controller()
	busy:
		show: ()->
			$('.busy').show()
		hide: ()->
			$('.busy').hide()
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
					Potion.busy.show()
					Potion.render "choose", {list:repos}, Potion.controller.choose
		choose: ()->
			#yet to fill
				
	init: ()->
		Potion.render "login", {}, Potion.controller.login

$(document).ready ()->
	Potion.init()

.ajaxComplete ()->
	$('.busy').hide()
.ajaxStart ()->