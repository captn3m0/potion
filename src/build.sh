#cd src
echo ".jade -> .js"
clientjade *.jade  > ../views.js

echo ".styl -> .css"
stylus style.styl -o ..

echo ".coffee -> .js"
coffee -b -c -o .. .

echo "Combining JS"
cat ../js/*.js > ../dist.js