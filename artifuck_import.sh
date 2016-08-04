#!/bin/bash
################################################################
#Configuration section
system=not_configurated
#new repository configuration 
user=USER
password=PASSWORD
url=NEW_URL
repository=NEW_REPOS

#old repository configuration
#user=OLD_USER
#password=OLD_PASSWORD
old_url=OLD_URL
old_repository=OLD_REPOS
################################################################

function usage() {
    #
    #show usage infos
    #
    echo "" 
    echo "  ArtiFucktory Import Tool"
    echo "  "
    echo "  usage:"
    echo ""
    echo "  ./ArtiFucktory.sh full_artifact_repository_path"
    echo "  "
    echo "  example:"
    echo ""
    echo "  You want to move" 
    echo "  http://old_server:8081/artifactory/my-custom-repo/com/launcher/1.0/launcher-1.0.jar "
    echo "  to"
    echo "  http://new_server:8081/artifactory/my-custom-new-repo/com/launcher/1.0/launcher-1.0.jar"
    echo "  first set the environment on the config section of this script"
    echo "  (I'm working on a configuration wizard... but it isn't already done)"
    echo "  then run the script with the full path  of the artifact"
    echo "  "
    echo "  ./ArtiFucktory.sh /my-custom-new-repo/com/launcher/1.0/launcher-1.0.jar"
    echo "  "
    echo "  the script will download the jar file and the pom file from the old server" 
    echo "  and it will upload the artifacts on the new server"
    echo ""
}

function configure() {
    #
    #configure the script parameter
    #
    echo ""
    echo " Enter the old server address (eg: http://localhost:8081/artifactory)"
    read old_url
    echo " Enter the old root repository path (eg: my-custom-libs)"
    read old_repository
    echo ""
    echo " Enter the new server address (eg: http://localhost:8081/artifactory)"
    read new_url
    echo " Enter the new root repository path (eg: my-custom-libs)"
    read new_repository
    echo ""
    echo " Enter the new Repository username"
    read new_repo_user
    echo " Enter the new Repository password"
    read new_repo_password
    echo ""
    sed -i -e 's,OLD_URL,'$old_url',g' $0
    sed -i -e 's/OLD_REPOS/'$old_repository'/g' $0
    sed -i -e 's,NEW_URL,'$new_url',g' $0
    sed -i -e 's/NEW_REPOS/'$new_repository'/g' $0
    sed -i -e 's/USER/'$new_repo_user'/g' $0
    sed -i -e 's/PASSWORD/'$new_repo_password'/g' $0
    sed -i -e '0,/not_configurated/ s/not_configurated/configurated/' $0
    echo "Configuration DONE"

}

#main 
case $1 in
	"") usage ;;
	"-h") usage ;;
	"--help") usage ;;
	"?") usage ;;
	"--version")   echo "ArtiFucktory Import Tool Version 0.2"
                       echo "";;
        "--configure") configure ;;
        *)  clear
            if [[ $system = "not_configurated" ]]
                then
                    echo "The script is not configure, but don't worry we are going to configure right now."
                    configure
            fi
            artifact_repo_path=$1
            echo ""
            echo "Repository Path: $1"
            #echo "artifact file = $2"

            #artifact_file=${artifact_file::-4}
            #echo "artifact_file = $artifact_file"
            #echo ""
            artifact_repo_path=${artifact_repo_path::-4}
            echo "artifact_repo_path = $artifact_repo_path"

            file_name=`echo $artifact_repo_path | rev | cut -d/ -f1 | rev`
            echo ""
            echo "jar name = $file_name.jar"
            echo "pom name = $file_name.pom"
            echo ""
            echo "Getting artifacts from old repos"
            echo ""
            curl $old_url/$old_repository/$artifact_repo_path.jar > $file_name.jar
            curl $old_url/$old_repository/$artifact_repo_path.pom > $file_name.pom
            echo ""
            echo "Putting artifacts into new repos"
            echo ""
            #echo curl -u $user:$password --data-binary @$file_name.jar -X PUT "$url/$repository/$artifact_repo_path.jar"
            curl -u $user:$password --data-binary @$file_name.jar -X PUT "$url/$repository/$artifact_repo_path.jar"
            echo ""
            #echo curl -u $user:$password --data-binary @$file_name.pom -X PUT "$url/$repository/$artifact_repo_path.pom"
            curl -u $user:$password --data-binary @$file_name.pom -X PUT "$url/$repository/$artifact_repo_path.pom" ;;
esac
