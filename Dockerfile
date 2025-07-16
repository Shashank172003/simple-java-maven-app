# ---------- Stage 1: Build with Maven 3.9.9 ----------
FROM eclipse-temurin:21-jdk AS build

ENV MAVEN_VERSION=3.9.9
ENV MAVEN_HOME=/opt/maven

RUN apt-get update && apt-get install -y curl unzip tar \
  && curl -fsSL https://downloads.apache.org/maven/maven-3/${MAVEN_VERSION}/binaries/apache-maven-${MAVEN_VERSION}-bin.tar.gz | tar -xz -C /opt \
  && ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven \
  && ln -s /opt/maven/bin/mvn /usr/bin/mvn

ENV PATH="${MAVEN_HOME}/bin:${PATH}"

WORKDIR /app

COPY pom.xml .
RUN mvn dependency:go-offline

COPY src ./src
RUN mvn clean package -DskipTests

# ---------- Stage 2: Run ----------
FROM eclipse-temurin:21-jdk-alpine

WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
