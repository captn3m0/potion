#Configuration Stuff
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g #Gives us mustache style templating

#Our App
Potion = 
	
	attachEvents: ()->
		$(document).on 'click', '.login-submit', (e)->
			Potion.render "choose"
		null
	render: (page,data={})->
		$.get "views/"+page+".html", (html)->
			html=_.template html, data
			$('body').html(html)
		null
	init: ()->
		console.log 1
		Potion.render "login"
		Potion.attachEvents()
		null


Potion.init()