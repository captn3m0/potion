#Configuration Stuff
_.templateSettings =
  interpolate : /\{\{(.+?)\}\}/g #Gives us mustache style templating

#Our App
Potion = 
	render: (page,data={})->
		$.get "views/"+page+".html", (html)->
			html=_.template html, data
			$('body').html(html)
	init: ()->
		console.log 1
		Potion.render "login"

Potion.init()