#!/usr/bin/env bash
root_dir=$(pwd)
working_dir=$root_dir/apps
app_details=$root_dir/apps.json

get_release_info() {
    curl --silent "https://api.github.com/repos/$1/tags" | jq -r '.[0].name'
}

APPS=(
    'AntennaPod'
    'NewPipe'
    'FairEmail'
)

echo "Root Directory: $root_dir"
echo "Working Directory: $working_dir"
echo ""

for app in "${APPS[@]}"; do
    apprepo=$(cat $app_details | jq -r .$app.repository | head -n 1)
    appbranch=$(cat $app_details | jq -r .$app.branch | head -n 1)
    tag=$(get_release_info $apprepo)
    if [[ ! -f tags.txt ]]; then
        echo $app=$tag >> tags.txt
    else
    if [[ $(cat tags.txt | grep $app | sed 's/$app://') == $tag ]]; then
		    Already built $app with $tag tag
    else
	rm -rf $working_dir
        mkdir $working_dir && cd $working_dir
        echo "Downloading $app source"
        wget https://github.com/$apprepo/archive/$tag.zip
        echo "Decompressing $app source"
        unzip *.zip
	rm *zip
        cd $working_dir/*
        echo "sdk.dir=${ANDROID_SDK_PATH}" >> "local.properties"
	echo "org.gradle.jvmargs=-Xmx1g" >> "gradle.properties"
        ./gradlew clean build
	mv $(find $working_dir/ -type f -name '*release*apk') $root_dir/out
    fi
   fi
done