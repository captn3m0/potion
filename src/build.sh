echo ".jade -> .html"
jade . -P -D -o ../views/
mv ../views/index.html ..
echo ".styl -> .css"
stylus style.styl -o ..

echo ".coffee -> .js"
coffee -b -c -o .. .

echo "Combining JS"
cat ../js/*.js > ../dist.js