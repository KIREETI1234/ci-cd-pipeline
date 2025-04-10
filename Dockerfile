FROM openjdk:11-jre-slim
WORKDIR /app
COPY target/demo-1.0.0.jar app.jar
EXPOSE 5000
ENTRYPOINT ["java", "-jar", "app.jar"]
