#!/bin/bash
echo "Type the version of Tomcat (6, 7 or 8), followed by the build number of the MicroStrategy release, followed by Mobile, WS or Web, followed by the desired image name.  Sample input for 931HF4 Web WAR file deployment on Tomcat 7:  7 9.3.360.018 Web t7931hf4web. Press ENTER to continue."

echo "Please type the version of Tomcat to deploy and press [ENTER]:"

read version

echo "Type the build number of MicroStrategy to deploy and press [ENTER]:"

read mstr

echo "Type Web, Mobile or WS and press [ENTER]:"

read mtype

echo "Type the desired image name and press [ENTER]:"

read iname

if [[ $mtype == "Web" || $mtype == "web" ]]; then
        mtype=""
fi


DIR=$(mktemp -d)
echo $DIR
cat <<- EOF > $DIR/Dockerfile
FROM tomcat:$version
MAINTAINER beep boop imma computer

#add war file to be deployed
COPY ./MicroStrategy$mtype.war /usr/local/tomcat/webapps/

#configure tomcat admin user
RUN sed -i "s#</tomcat-users>##g" /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '  <role rolename="manager-gui"/>' >>  /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '  <role rolename="manager-script"/>' >>  /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '  <role rolename="manager-jmx"/>' >>  /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '  <role rolename="manager-status"/>' >>  /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '  <role rolename="admin-gui"/>' >>  /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '  <role rolename="admin-script"/>' >>  /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '  <role rolename="manager"/>' >>  /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '  <role rolename="admin"/>' >>  /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '  <user username="admin" password="admin" roles="manager-gui, manager-script, manager, admin, manager-jmx, manager-status, admin-gui, admin-script"/>' >>  /usr/local/tomcat/conf/tomcat-users.xml; \
    echo '</tomcat-users>' >> /usr/local/tomcat/conf/tomcat-users.xml

#make sure war file size is increased prior to catalina start
RUN sed -i "s#52428800#5242880000#g" /usr/local/tomcat/webapps/manager/WEB-INF/web.xml;

CMD ["catalina.sh", "run"]
EOF
cp /cc2tech/$mstr/RELEASE/MicroStrategy$mtype.war $DIR/
docker build -t $iname $DIR
rm -r $DIR
