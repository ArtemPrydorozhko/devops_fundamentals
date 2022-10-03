which jq > /dev/null
if [[ "$?" == 1 ]]
then
	echo "Jq not found"
	echo "install it with: sudo apt install jq"
	exit 1
fi

filePath="$1"
shift


if [[ $filePath == '' ]]
then
	echo "No path provided!"
	exit 1
fi

fileDir=`echo "$filePath" | grep -oP '.*\/(?=([A-Za-z]+\.json))'`

#parsing args
while [ $# -gt 0 ]
do
	if [[ $1 == "--"* ]]
	then
		if [[ $1 == "--poll-for-source-changes" ]]
		then
			declare pollForSourceChanges="$2"
		else
			v="${1/--/}"
			declare "$v"="$2"
		fi
		shift
	fi
	shift
done

pipelineString=`cat $filePath`

#remove metadata
pipelineString=`echo $pipelineString | jq 'del(.metadata)'`

#update version
pipelineString=`echo $pipelineString | jq '.pipeline["version"] |= .+ 1'`

configJqPath=".pipeline[\"stages\"][0][\"actions\"][0][\"configuration\"]"

#update branch
if [[ $branch == '' ]]
then
	branch="main"
fi

pipelineString=`echo $pipelineString | jq "$configJqPath[\"Branch\"] |= \"$branch\""`

#update owner
if [[ $owner != '' ]]
then
	pipelineString=`echo $pipelineString | jq "$configJqPath[\"Owner\"] |= \"$owner\""`
fi


#update repo
if [[ $repo != '' ]]
then
	pipelineString=`echo $pipelineString | jq "$configJqPath[\"Repo\"] |= \"$repo\""`
fi

#update poll
if [[ $pollForSourceChanges != '' ]]
then
	poll="$poll-for-source-changes"
	pipelineString=`echo $pipelineString | jq "$configJqPath[\"PollForSourceChanges\"] |= \"$pollForSourceChanges\""`
fi

updatedJson="$fileDir/pipeline-$(date +'%Y-%m-%d').json"
echo $pipelineString > $updatedJson 
