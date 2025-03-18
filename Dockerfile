# Use a base image with Java and Gradle installed
FROM openjdk:11-jdk-slim

# Install Python and pipenv for Python dependencies
RUN apt-get update && apt-get install -y \
    python3 \
    python3-pip \
    curl \
    && curl -sSL https://install.python-poetry.org | python3 - \
    && rm -rf /var/lib/apt/lists/*

# Install Gradle
RUN apt-get update && apt-get install -y wget unzip \
    && wget https://services.gradle.org/distributions/gradle-7.4-bin.zip \
    && unzip gradle-7.4-bin.zip -d /opt/gradle \
    && rm gradle-7.4-bin.zip \
    && ln -s /opt/gradle/gradle-7.4/bin/gradle /usr/bin/gradle

# Set the working directory
WORKDIR /app

# Copy the project files
COPY . .

# Install Python dependencies using pipenv
RUN pip install pipenv && pipenv install

# Build the Gradle project and run the application
RUN ./gradlew build

# Expose the application port
EXPOSE 8080

# Start the application
CMD ["./gradlew", "apprun"]
