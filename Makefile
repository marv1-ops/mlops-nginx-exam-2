run-project:
	# run project
	@echo "Grafana UI: http://localhost:3000"

test-api:
	curl -X POST "https://localhost/predict" \
     -H "Content-Type: application/json" \
     -d '{"sentence": "Oh yeah, that was soooo cool!"}' \
	 --user admin:admin \
     --cacert ./deployments/nginx/certs/nginx.crt;
links:
	@echo "Grafana: http://localhost:3000"
	@echo "Prometheus: http://localhost:9090"
	@echo "API (HTTPS): https://localhost/predict"

# --- Préparation de la sécurité ---
setup:
	@echo "Préparation des certificats et de l'authentification..."
	mkdir -p ./deployments/nginx/certs
	# Génère le certificat SSL si absent
	openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
		-keyout ./deployments/nginx/certs/nginx.key \
		-out ./deployments/nginx/certs/nginx.crt \
		-subj "/CN=localhost"
	# Génère le mot de passe (admin/admin)
	printf "admin:$$(openssl passwd -apr1 admin)\n" > ./deployments/nginx/.htpasswd

# --- Gestion du projet  ---
start-project: setup
	docker-compose -p mlops-exam up -d --build

stop-project:
	docker-compose -p mlops-exam down

# --- Tests ---
test:
	@echo "Lancement des tests automatisés..."
	bash ./tests/run_tests.sh

test-api:
	@echo "Test rapide de l'API v1..."
	curl -k -X POST "https://localhost/predict" \
		-H "Content-Type: application/json" \
		-d '{"sentence": "I love this project!"}' \
		--user admin:admin