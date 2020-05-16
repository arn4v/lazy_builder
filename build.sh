#!/usr/bin/env bash

. ~/.keystores/props-myapps

try() {
    [[ $- = *e* ]]; SAVED_OPT_E=$?
    set +e
}

catch() {
    export ex_code=$?
    (( $SAVED_OPT_E )) && set +e
    return $ex_code
}

if [[ ! $1 == "SmartPack" ]]; then
    sed -i 's/org.gradle.jvmargs=.*//' gradle.properties
    echo "org.gradle.jvmargs=-Xmx3g -XX:MaxPermSize=2048m -XX:+HeapDumpOnOutOfMemoryError -Dfile.encoding=UTF-8" >> gradle.properties
else
    echo "Nothing to do here"
fi

if [[ $1 == "LibreraPro" ]] ;then
    touch ~/.gradle/gradle.properties
    echo "RELEASE_STORE_FILE=~/.keystores/myapps.pkcs12" >> ~/.gradle/gradle.properties
    echo "RELEASE_STORE_PASSWORD=$keystorePassword" >> ~/.gradle/gradle.properties
    echo "RELEASE_KEY_ALIAS=$keystoreAlias" >> ~/.gradle/gradle.properties
    echo "RELEASE_KEY_PASSWORD=$keystorePassword" >> ~/.gradle/gradle.properties
    bash Builder/link_to_mupdf_1.16.1.sh
    ./gradlew clean assembleFdroid || echo "Failed"
    rm ~/.gradle/gradle.properties
elif [[ $1 == "AntennaPod" ]]; then
    echo "releaseStoreFile=$keystoreFile" >> gradle.properties
    echo "releaseStorePassword=$keystorePassword" >> gradle.properties
    echo "releaseKeyAlias=$keystoreAlias" >> gradle.properties
    echo "releaseKeyPassword=$keystorePassword" >> gradle.properties
    ./gradlew clean build || echo "Failed"
elif [[ $1 == "SmartPack" ]]; then
    ./gradlew clean build || echo "Failed"
else
    ./gradlew clean build || echo "Failed"
fi
