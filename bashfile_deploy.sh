#!/bin/bash
text1="<groupId>org.codehaus.mojo</groupId>"
echo "Hi give me a branch ><"
cd /opt/source-code/intellivu
current_branch=`git branch | awk '/\*/ { print $2; }'`
echo current branch is: $current_branch
echo Enter branch name to deploy
read branch
if $current_branch=:$branch; then
    git pull
else
    stringPomWeb=`grep -n "<groupId>org.codehaus.mojo</groupId>" intelli-vu/pom.xml | xargs echo | cut -d ":" -f 1`
    stringPomEvent=`grep -n "<groupId>org.codehaus.mojo</groupId>" intelli-vu-event/pom.xml | xargs echo | cut -d ":" -f 1`
    numberLinePomWeb=`expr $stringPomWeb - 2`
    numberLineEndPomWeb=`expr $numberLinePomWeb + 47`
    numberLinePomEvent=`expr $stringPomEvent - 2`
    numberLineEndPomEvent=`expr $numberLinePomEvent + 47`
    echo checkout source code
    git reset --hard
    git checkout $branch
    git pull
    characterOpenComment='i<!--'
    characterCloseComment='i-->'
    echo edit pom file
    sed -i "$numberLinePomWeb$characterOpenComment" intelli-vu/pom.xml
    sed -i "$numberLineEndPomWeb$characterCloseComment" intelli-vu/pom.xml
    sed -i "$numberLinePomEvent$characterOpenComment" intelli-vu-event/pom.xml
    sed -i "$numberLineEndPomEvent$characterCloseComment" intelli-vu-event/pom.xml
fi
    mvn clean install -DskipTests
    echo coppy files
    scp intelli-vu/target/intelli-vu.war /usr/share/tomcat/webapps
    scp intelli-vu-event/target/intelli-vu-event.war .ssh hnguyen2@usla-ivev-q001.qa.vubiquity.com:./
    ssh hnguyen2@usla-ivev-q001.qa.vubiquity.com <<-'ENDSSH'
    sudo -s
    scp intelli-vu-event.war /usr/share/tomcat/webapps
    cd /usr/share/tomcat/bin
    killall java
    ./startup.sh & sleep 20
    ENDSSH
    cd /usr/share/tomcat/bin
    killall java
    ./startup.sh 
    tail -f ../logs/catalina.out
