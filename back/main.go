package main

import (
	"fmt"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	_ "github.com/lib/pq"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

type Test struct {
	gorm.Model
	Name  string
	Value string
}

func main() {
	//Configuration de la connexion à la base de données
	dsn := fmt.Sprintf("host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		goDotEnvVariable("POSTGRES_HOST"),
		goDotEnvVariable("POSTGRES_PORT"),
		goDotEnvVariable("POSTGRES_USER"),
		goDotEnvVariable("POSTGRES_PASSWORD"),
		goDotEnvVariable("POSTGRES_DB"))

	log.Printf("Test displaying env variables  : %s", goDotEnvVariable("TEST_ENV"))

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		panic("échec de la connexion à la base de données")
	}
	log.Println("Connexion réussie à la base de données. Démarrage du serveur sur http://localhost:8081")

	// Création automatique de la table "tests" basée sur le modèle Test
	err = db.AutoMigrate(&Test{})
	if err != nil {
		panic("Creation of the table failed")
	}

	db.Create(&Test{Name: "Exemple", Value: "Valeur"})

	mux := http.NewServeMux()
	mux.HandleFunc("/test", func(w http.ResponseWriter, r *http.Request) {
		fmt.Fprintf(w, "Succesfull connection to GO API!")
	})

	// Wrap the mux with the CORS middleware
	wrappedMux := applyCORS(mux)

	// Démarrage du serveur web
	fmt.Println("Server listening to port 8081...")
	http.ListenAndServe(":8081", wrappedMux)

}

func goDotEnvVariable(key string) string {

	// load .env file
	err := godotenv.Load(".env")

	if err != nil {
		log.Fatalf("Error loading .env file")
	}

	return os.Getenv(key)
}

// Middleware to apply CORS headers
func applyCORS(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		// Set CORS headers
		w.Header().Set("Access-Control-Allow-Origin", "*")
		w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
		w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")

		if r.Method == "OPTIONS" {
			// If this is a preflight OPTIONS request, send an OK status and return
			w.WriteHeader(http.StatusOK)
			return
		}

		// Call the next handler, which can be another middleware in the chain, or the final handler.
		next.ServeHTTP(w, r)
	})
}
