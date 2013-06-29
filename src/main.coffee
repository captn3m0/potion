#Our App
class Post
	constructor: (@path,cb)->
		Potion.github.repository.read Potion.github.branch, @path, (err, data)=>
			if !err
				@data=data
			cb?()
	#save:
		#Potion.
	isDraft: ()->
		@path.slice(0,7)=="_drafts"
	toHTML: ()->
		converter = new Showdown.converter();
		sourceText=YAML.loadFront(@data)['__content']
		converter.makeHtml sourceText
	title: ()->
		title=YAML.loadFront(@data)['title']

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
						$('.notice').html("<p>There was an error while logging in to your account. Please check your username (and password). Please use your password if Potion is hitting the Github API rate-limits.").addClass('error')
					Potion.busy.hide()
					Potion.controller.choose repos
				#We use different functions based on
				#whether we have password or not
				if password.length>0
					user.repos after
				else
					#Our github lib doesn't support this
					#So we freestyle and use JQuery
					$.getJSON "https://api.github.com/users/"+username+"/repos?type=all&per_page=1000&sort=updated", (data)->
						after null,data
					.error ()->
						after true,null

		#Choose a repository and a branch
		choose: (repos)->
			Potion.render "choose", {list:repos}
			$('#continue').click ()->
				Potion.github.repo=$('#reponame').val().split('/')[1]
				Potion.github.user=$('#reponame').val().split('/')[0]
				Potion.github.branch=$('#branchname').val()
				#We store this data
				#Make requests to github to get the list of files
				Potion.busy.show()
				Potion.Util.showFiles()
		admin: (files)->
			$(".file a").click (e)->
				filePath=e.target.getAttribute('data-path')
				draft=true if e.target.getAttribute('data-draft')=="true"
				#We send the draft data to make sure that the buttons are correct
				Potion.post=new Post filePath, ()->
					Potion.controller.editor()
		editor: ()->
			Potion.busy.show()
			Potion.github.repository.read Potion.github.branch, Potion.post.path, (err, data)->
				Potion.busy.hide()
				#Now we render the editor
				Potion.render "editor", Potion.post, ()->
					#Add hooks here
					$('.admin').click (e)->
						Potion.Util.showFiles()
					$('.save').click (e)->
					$('.preview').click (e)->
						if e.target.innerText=='Preview'
							$('#editor').html Potion.post.toHTML()
							e.target.innerText= 'Edit'
						else
							Potion.render "editor", Potion.post


	init: ()->
		Potion.render "login", {}, Potion.controller.login
	Util:
		getFiles: (cb)->
			Potion.github.repository = Potion.github.getRepo Potion.github.user, Potion.github.repo
			Potion.github.repository.getTree Potion.github.branch+'?recursive=true', (err,data)->
				#Break up the tree into drafts and posts
				if !err
					drafts=[]
					posts=[]
					for file in data
						if file.path.slice(0,8)=="_drafts/"
							file.name=Potion.Util.pathToName file.path
							drafts.push file
						if file.path.slice(0,7)=="_posts/"
							file.name=Potion.Util.pathToName file.path
							posts.push file
					err=true if posts.length==0 && drafts.length==0
					#Reverse the arrays as they are in ascending order by date
					posts=posts.reverse()
					drafts=drafts.reverse()
				cb? err, drafts, posts
		showFiles: ()->
			Potion.Util.getFiles (err,drafts,posts)->
				Potion.busy.hide()
				if(err)
					$('.notice').addClass('error').html "<p>There was an error while fetching this repository. Are you sure its a jekyll repo?</p>"
				else
					Potion.render "admin", {drafts:drafts,posts:posts}, Potion.controller.admin
		pathToName: (path)->
			#get the basename
			path=path.split('/').reverse()[0];
			#Remove the extension
			path=path.substr 0, path.lastIndexOf('.')
			#remove the date
			name=path.match(/\d{4}-\d{1,2}-\d{1,2}-(.*)/)[1]
			#Auto-return
			name.replace(/-/g,' ').toTitleCase()
$(document).ready ()->
	Potion.init()

#We will setup routing later...