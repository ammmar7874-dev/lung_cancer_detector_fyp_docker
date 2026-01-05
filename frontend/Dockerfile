# Stage 1: Build the Flutter Web app
FROM debian:latest AS build-env

# Install dependencies for Flutter
RUN apt-get update && apt-get install -y curl git wget unzip xz-utils libglu1-mesa

# Install Flutter SDK
RUN git clone https://github.com/flutter/flutter.git /usr/local/flutter
ENV PATH="/usr/local/flutter/bin:/usr/local/flutter/bin/cache/dart-sdk/bin:${PATH}"

# Setup workspace
WORKDIR /app
COPY . .

# Initialize Flutter and build the web project
RUN flutter doctor
RUN flutter build web

# Stage 2: Serve the compiled web files using Nginx
FROM nginx:alpine
COPY --from=build-env /app/build/web /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]