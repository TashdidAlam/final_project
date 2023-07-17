#base image
FROM openjdk:11

#exposing port for jar file
EXPOSE 8080

#adding jar file
ADD target/spark-lms-0.0.1-SNAPSHOT.jar spark-lms-0.0.1-SNAPSHOT.jar

#entrypoint to run the jar file
ENTRYPOINT ["java","-jar","/spark-lms-0.0.1-SNAPSHOT.jar"]
