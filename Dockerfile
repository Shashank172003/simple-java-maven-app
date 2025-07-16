# Stage 1: Build the application using Maven
FROM maven:3.9.6-eclipse-temurin-21 AS build

WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline

# Copy the rest of the source code and build the project
COPY src ./src
RUN mvn clean package -DskipTests

# Stage 2: Run the application with a slim JDK runtime
FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

# Copy the jar file from the build stage
COPY --from=build /app/target/*.jar app.jar

# Expose port (change according to your app)
EXPOSE 8080

# Start the application
ENTRYPOINT ["java", "-jar", "app.jar"]
