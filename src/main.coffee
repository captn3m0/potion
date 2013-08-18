#Our App
class Post
	constructor: (@path, cb) ->
		Potion.github.repository.read Potion.github.branch, @path, (err, data) =>
			if !err
				@originalText = @data = data
				cb?()
			else
				alert "There was an error in fetching this post"
	#save:
		#Potion.
	isDraft: () ->
		@path.slice(0, 7) == "_drafts"
	toHTML: () ->
		converter = new Showdown.converter() ;
		#Make sure that we do have YAML frontmatter.
		#Lets people shoot them in their foot, but the UX is better.
		try
			yaml = YAML.loadFront(@data)
			sourceText = yaml['__content']
		catch err
			#if no YAML was found, just accept complete blob as markdown.
			sourceText = @data
		converter.makeHtml sourceText
	hasChanged: () ->
		@originalText != @data
	title: () ->
		try
			title = YAML.loadFront(@data)['title']
			title || "Untitled"
		catch error
			"Untitled"
	save: (cb) ->
		if !@hasChanged()
			alert("No changes were made to the post.")
			return
		Potion.busy.show()
		repo = Potion.github.repository
		commitMessage = "Updated " + @title()
		repo.write Potion.github.branch, @path, @data, commitMessage, "utf-8", (err) =>
			Potion.busy.hide()
			if !err
				alert "Post Saved"
			else
				alert "There was an error in saving your post. Are you logged in?"
			cb?()
	publish: ->
		#Move it to _posts folder
		newPath = "_posts/" + Potion.Util.basename(@path)
		Potion.github.repository.move Potion.github.branch, @path, newPath, (err) =>
			if !err
				alert "Post published"
			else
				alert "There was an error in publishing the post. Are you logged in?"
			Potion.busy.hide()
			@path = newPath
			Potion.controller.editor()
	unpublish: ->
		newPath = "_drafts/" + Potion.Util.basename(@path)
		Potion.github.repository.move Potion.github.branch, @path, newPath, (err) =>
			if !err
				alert "Post moved to drafts."
			else
				alert "There was an error in unpublishing the post. Are you logged in?"
			Potion.busy.hide()
			@path = newPath
			Potion.controller.editor()
	attachEvents: () ->
		#Add hooks here
		$('.admin').click (e) ->
			Potion.Util.showFiles()
		$('#textpad').bind 'keyup input propertychange', (e) =>
			@data = $(e.target).val()
			$('.title').text @title()
		#Just make an updated commit
		$('.save').click (e) =>
			@save()
			@originalText = @data #so that hasChanged() now returns false
		$('.publish').click (e) =>
			if Potion.post.hasChanged()
				@save () =>
					Potion.busy.show()
					@publish()
			else
				@publish()
		$('.unpublish').click (e) =>
			#This is same as publish, except we move to drafts this time
			if Potion.post.hasChanged()
				@save () =>
					Potion.busy.show()
					@unpublish()
			else
				@unpublish()
		$('.previewbtn').click (e) =>
			if e.target.innerText == 'Preview'
				$('#editor textarea').hide()
				$('#editor .preview').html @toHTML()
				$('#editor .preview').show()
				$(e.target).text 'Edit'
			else
				$('#editor .preview').hide()
				$('textarea').text(@data).show()
				$(e.target).text 'Preview'
Potion =
	render: (page, data = {} , controller) ->
		#order is DOM, TEMPLATE, DATA
		x = jade.render(document.body, page, data)
		controller? (data)
	busy:
		show: () ->
			$('.busy').removeClass 'hidden'
		hide: () ->
			$('.busy').addClass 'hidden'
	controller:
		#Login controller handles login information
		login: () ->
			Potion.fixLayout()
			$('#password,#username').keyup (e) ->
				$('#login').click() if e.keyCode == 13
			$('#login').click () ->

				Potion.busy.show()
				username = $('#username').val()
				password = $('#password').val()
				Potion.github = new Github {
				 username: username,
				 password: password,
				 auth: "basic"
				} ;
				user = Potion.github.getUser() ;
				#After callback to handle the repos list
				after = (err, repos) ->
					if !err
						Potion.busy.hide()
						Potion.controller.choose repos
					else
						$('.notice').html("<p>There was an error while logging in to your account. Please check your username (and password). Please use your password if Potion is hitting the Github API rate-limits.").addClass('error')

				#We use different functions based on
				#whether we have password or not
				if password.length > 0
					user.repos after
				else
					#Our github lib doesn't support this
					#So we freestyle and use JQuery
					$.getJSON "https://api.github.com/users/"+username+"/repos?type=all&per_page=1000&sort=updated", (data) ->
						after null, data
					.error () ->
						after true, null

		#Choose a repository and a branch
		choose: (repos) ->
			Potion.render "choose", {list: repos}
			$('#continue').click () ->
				Potion.github.repo = $('#reponame').val().split('/')[1]
				Potion.github.user = $('#reponame').val().split('/')[0]
				Potion.github.branch = $('#branchname').val()
				#We store this data
				#Make requests to github to get the list of files
				Potion.busy.show()
				Potion.Util.showFiles()


		admin: (files) ->
			Potion.fixLayout()
			$(".right-pane, .options .btn[data-action='postsActive']").removeClass 'active'
			$(".center-pane, .options .btn[data-action='draftsActive']").addClass 'active'
			$(".file a").click (e) ->
				filePath = e.target.getAttribute('data-path')
				draft = true if e.target.getAttribute('data-draft') == "true"
				#We send the draft data to make sure that the buttons are correct
				Potion.busy.show()
				Potion.post = new Post filePath, () ->
					Potion.controller.editor()
			$('#newPostBtn').click (e) ->
				postFilePath = "_drafts/" + Potion.Util.titleToPath $('#newPostTitle').val()+".md"
				#We create a blank file first and then allow the user to edit it
				Potion.busy.show()
				Potion.defaultYAML.title = $('#newPostTitle').val()
				Potion.github.repository.write Potion.github.branch, postFilePath, YAML.createFront(Potion.defaultYAML), "New blank post", "utf-8", (err) ->
					if err
						Potion.busy.hide()
						alert "There was an error in creating the file. Are you logged in?"
					else
						Potion.post = new Post postFilePath, () ->
							Potion.controller.editor()
			$('#newPostTitle').keyup (e) ->
				$('#newPostBtn').click() if e.keyCode == 13 && e.target.value.length>0
		editor: () ->
			Potion.github.repository.read Potion.github.branch, Potion.post.path, (err, data) ->
				Potion.busy.hide()
				#Now we render the editor
				Potion.render "editor", Potion.post, () ->
					Potion.post.attachEvents()
					Potion.fixLayout()

	init: () ->
		Potion.render "login", {} , Potion.controller.login

		# Default .active on mobile layouts
		if $(".options.onMobile").css('display') is 'block'
			$("button.btn").eq(0).addClass('active')
			$(".left-pane").addClass('active')

		$(document).on 'click', '.options .btn', ->
			action = $(this).attr 'data-action'
			if action is 'draftsActive'
				$(".right-pane, .options .btn[data-action='postsActive']").removeClass 'active'
				$(".center-pane, .options .btn[data-action='draftsActive']").addClass 'active'
			if action is 'postsActive'
				$(".center-pane, .options .btn[data-action='draftsActive']").removeClass 'active'
				$(".right-pane, .options .btn[data-action='postsActive']").addClass 'active'
	fixLayout: () ->
		if $("textarea").length
			ratio = 900 / document.width
			$("textarea").css
				'left': (document.width - 900) / 2
				'right': (document.width - 900) / 2
				'max-width': parseInt(document.width*ratio).toString() + 'px'
		if $(".login-div").length
			# Scrollbar Fix
			$(".login-div").css {
				'height': (document.height - $(".top-line")[0].offsetHeight).toString() + 'px'
			}
		if $(".center-pane ul.drafts-list").length
			$(".center-pane ul.drafts-list").css {
				'height': (document.height - 106).toString() + 'px'
			}
		if $(".right-pane ul.published-list").length
			$(".right-pane ul.published-list").css {
				'height': (document.height - 60).toString() + 'px'
			}

	Util:
		getFiles: (cb) ->
			Potion.github.repository = Potion.github.getRepo Potion.github.user, Potion.github.repo
			Potion.github.repository.read Potion.github.branch, "_default.yml", (err, data) ->
				if err
					Potion.defaultYAML = 
						title: "Untitled"
						layout: "default"
				else
					Potion.defaultYAML = YAML.parse(data)
			Potion.github.repository.getTree Potion.github.branch + '?recursive=true', (err, data) ->
				#Break up the tree into drafts and posts
				if !err
					drafts = []
					posts = []
					for file in data
						if file.path.slice(0, 8) == "_drafts/"
							file.name = Potion.Util.pathToName file.path
							drafts.push file
						if file.path.slice(0, 7) == "_posts/" || file.path.slice(0,14) == "source/_posts/"
							file.name = Potion.Util.pathToName file.path
							posts.push file
					err = true if posts.length == 0 && drafts.length == 0
					#Reverse the arrays as they are in ascending order by date
					posts = posts.reverse()
					drafts = drafts.reverse()
				cb? err, drafts, posts
		showFiles: () ->
			Potion.Util.getFiles (err, drafts, posts) ->
				Potion.busy.hide()
				if err
					$('.notice').addClass('error').html "<p>There was an error while fetching this repository. Are you sure its a jekyll repo?</p>"
				else
					Potion.render "admin", {drafts: drafts, posts: posts} , Potion.controller.admin
		pathToName: (path) ->
			#Get the basename
			path = Potion.Util.basename path
			#Remove the extension
			path = path.substr( 0, path.lastIndexOf '.')|| path
			#remove the date
			try
				name = path.match(/\d{4}-\d{1,2}-\d{1,2}-(.*)/)[1]
			catch err
				#drafts are sometimes date-less in filenames
				#This is in-fact, what jeykll recommends for drafts.
				name = path
			#Auto-return
			name.replace(/-/g, ' ').toTitleCase()
		basename: (path) ->
			path.split('/').reverse()[0];
		titleToPath: (title) ->
			title.replace(/\ /g, '-').toLowerCase().replace(/[^-.\w\s]/gi, '')



$(document).ready () ->
	Potion.init()
	$(window).on 'resize', (e)->
		Potion.fixLayout()