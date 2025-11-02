#!/bin/bash

echo "Starting E-Commerce Platform Infrastructure..."

# Make LocalStack init script executable
chmod +x infrastructure/localstack-init/init.sh

# Start all services
docker-compose up -d

echo "Waiting for services to be healthy..."

# Wait for PostgreSQL
echo "Waiting for PostgreSQL..."
until docker exec postgres-db pg_isready -U admin -d ecommerce > /dev/null 2>&1; do
  sleep 2
done
echo "PostgreSQL is ready!"

# Wait for MongoDB
echo "Waiting for MongoDB..."
until docker exec mongodb mongosh --eval "db.adminCommand('ping')" > /dev/null 2>&1; do
  sleep 2
done
echo "MongoDB is ready!"

# Wait for Redis
echo "Waiting for Redis..."
until docker exec redis-cache redis-cli -a redis123 ping > /dev/null 2>&1; do
  sleep 2
done
echo "Redis is ready!"

# Wait for Elasticsearch
echo "Waiting for Elasticsearch..."
until curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; do
  sleep 5
done
echo "Elasticsearch is ready!"

# Wait for Kafka
echo "Waiting for Kafka..."
until docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 > /dev/null 2>&1; do
  sleep 5
done
echo "Kafka is ready!"

# Wait for Keycloak
echo "Waiting for Keycloak..."
until curl -s http://localhost:8180/health/ready > /dev/null 2>&1; do
  sleep 5
done
echo "Keycloak is ready!"

# Wait for LocalStack
echo "Waiting for LocalStack..."
until curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; do
  sleep 3
done
echo "LocalStack is ready!"

echo ""
echo "All services are up and running!"
echo ""
echo "Service URLs:"
echo "  - Keycloak Admin: http://localhost:8180 (admin/admin)"
echo "  - Kafka UI: http://localhost:8090"
echo "  - Elasticsearch: http://localhost:9200"
echo "  - LocalStack: http://localhost:4566"
echo "  - PostgreSQL: localhost:5432 (admin/admin123)"
echo "  - MongoDB: localhost:27017 (admin/admin123)"
echo "  - Redis: localhost:6379 (password: redis123)"
echo ""
echo "Next steps:"
echo "  1. Configure Keycloak realm"
echo "  2. Build and run backend services"
echo "  3. Build and run frontend applications"
echo ""