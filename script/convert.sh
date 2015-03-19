echo 'convert start'
cd `dirname $0`
cd ../
coffee -c -o output coffee/oden.coffee
