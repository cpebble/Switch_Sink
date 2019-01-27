dmenu_cmd="dmenu"
rofi_cmd="rofi -dmenu -p \"select sink\""
dmenu_cmd=$rofi_cmd

set_default_sink() {
	echo setting sink $1
	# Set default sink
	pacmd set-default-sink $1

	# Now switch streams to sink
	sources=$(pactl list short sink-inputs | awk '{print $1}')

	pactl list short sink-inputs|while read stream; do
	    streamId=$(echo $stream|cut '-d ' -f1)
	    echo "moving stream $streamId"
	    pactl move-sink-input "$streamId" "$1"
	done
}

sinks="$(pactl list sinks | grep -E -o -e "Sink #(.)" -e "Description: (.*)" )"
read -e -d '' pythoncode <<EOF
sinks = """$sinks"""
sinkl = sinks.splitlines()

newSinks = []
count = 0
while count < len(sinkl):
    n = sinkl[count].replace("Sink #", "")
    t = sinkl[count+1].replace("Description: ", "")
    newSinks += ["{}|    {}".format(n, t)]

    count += 2

for i in newSinks:
	print(i)
    
EOF
 
#echo "$pythoncode:"
#hsinkDescriptors="$(pactl list sinks |

sink=$(python -c "$pythoncode" | $dmenu_cmd)
sinkindex=$(echo "$sink" | cut -d "|" -f 1)
echo $sinkindex
set_default_sink $sinkindex
exit 0
