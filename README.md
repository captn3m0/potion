potion
======
Potion is github-pages compatible editor for jekyll websites

##Explain that, please
Potion is a completely client-side (serverless) editor for jekyll blogs. 
It uses the Jekyll specifications for listing drafts, posts and allows 
you to edit your blogs completely in the browser. It does this by using the
github API. 

##Why not OAuth
Github allows for 2 authentication methods, OAuth and Basic Auth. We choose 
the later, because it allows us to remain serverless (for eg, <http://prose.io> uses GateKeeper).
An additional advantage is that, since there are no authentication tokens involved, you are
not handing keys to your private repos to anyone. The password is stored nowhere, and is kept 
in memory for the duration of your session. If you close the tab, you will have to login again.

##Compatible with Github Pages
Potion is compatible with github pages, which means that you can add Potion as a submodule to
your own blog, and it will be available at `http://username.github.com/potion`. Self-hosting
means you will have to update potion manually, but it also means that we cannot slip in malicious
code to steal your passwords at any time.

##Features
When Potion will be complete, it will boast of the following features:

1. Image and other binary uploads.
2. YAML editor for editing YAML-front matter.
3. Distraction free markdown editor with live-preview.
4. Clean, simple and a minimalist interface.

##Setup Instructions

1. Download the latest build of Potion from #TODO
2. Put it inside an admin folder of your blog
3. Open <http://username.github.com/admin/>

###Alternative Install

1. Clone the Potion repo inside your blog (`username.github.com`)
2. Checkout the build branch (`git checkout build`)
3. Open <http://username.github.com/potion>

##Contribute
You can setup Potion as a sublime project by copying the `sample.sublime-project` file to 
`potion.sublime-project` and editing the root. Dependencies for development include:

- clientjade (`npm install clientjade`)
- stylus (`npm install stylus`)
- coffee-script (`npm install coffee-script`)

##Contributors
- Abhay Rana <me@captnemo.in>
- Tushar Kant <nanu.clickity@gmail.com>

##Licence
Licenced under the MIT Licence.
