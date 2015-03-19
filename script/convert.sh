echo 'convert start'
cd `dirname $0`
cd ../
coffee -c -o oden.js coffee/oden.coffee
