codeforces(){
	if [[ $# -gt 1 ]]; then
		echo "Invalid Number of Arguments"
		return 1
	fi
	if [[ $# == 0 ]]; then
		echo -n "Opening: "
		echo "http://codeforces.com"
		xdg-open "http://codeforces.com" > /dev/null 2>/dev/null
		return 0	
	fi
	len=${#1}
	if [ $len -le 1 ]; then
		echo "Invalid Argument"
		return 2
	fi
	num=${1:0:len-1}
	dif=${1:len-1:1}
	lin="http://codeforces.com/problemset/problem/$num/$dif"
	echo -n "Opening: " 
	echo $lin
	xdg-open $lin > /dev/null 2>/dev/null
}
codeforces $1