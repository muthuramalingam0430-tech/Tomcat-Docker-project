FROM tomcat:10.1-jdk17
COPY webapp/ /usr/local/tomcat/webapps/ROOT/
EXPOSE 8080
CMD ["catalina.sh", "run"]
