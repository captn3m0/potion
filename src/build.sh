echo ".jade -> .html"
jade . -P -D -o ..

echo ".styl -> .css"
stylus . -o ..

echo ".coffee -> .js"
coffee -b -c -o .. .