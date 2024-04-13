
# FROM golang:alpine

# # Définir le répertoire de travail dans le conteneur
# WORKDIR /app

# # Copier le code source dans le conteneur
# COPY . .

# # Compiler l'application Go
# RUN go build -o main .

# # Exposer le port sur lequel l'application écoute
# EXPOSE 8081

# # Commande pour exécuter l'application
# CMD ["go", "run" , "main.go"]


# Choose whatever you want, version >= 1.16
FROM golang:alpine

WORKDIR /app

RUN go install github.com/cosmtrek/air@latest
RUN go install github.com/joho/godotenv
RUN go install github.com/rs/cors



COPY go.mod go.sum ./
RUN go mod download


CMD ["air", "-c", ".air.toml"]