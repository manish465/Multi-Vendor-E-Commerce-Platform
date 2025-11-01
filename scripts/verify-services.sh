#!/bin/bash

echo " Verifying E-Commerce Platform Services..."
echo ""

# Check Docker containers
echo " Docker Containers Status:"
docker-compose ps
echo ""

# Check PostgreSQL
echo " PostgreSQL:"
if docker exec postgres-db psql -U admin -d ecommerce -c "SELECT COUNT(*) FROM users;" > /dev/null 2>&1; then
  echo "   Connected successfully"
  echo "   Database tables:"
  docker exec postgres-db psql -U admin -d ecommerce -c "\dt" | grep "public"
else
  echo "   Connection failed"
fi
echo ""

# Check MongoDB
echo " MongoDB:"
if docker exec mongodb mongosh ecommerce --quiet --eval "db.categories.countDocuments()" > /dev/null 2>&1; then
  CATEGORY_COUNT=$(docker exec mongodb mongosh ecommerce --quiet --eval "db.categories.countDocuments()")
  echo "   Connected successfully"
  echo "   Collections:"
  docker exec mongodb mongosh ecommerce --quiet --eval "db.getCollectionNames()"
  echo "   Categories count: $CATEGORY_COUNT"
else
  echo "   Connection failed"
fi
echo ""

# Check Redis
echo " Redis:"
if docker exec redis-cache redis-cli -a redis123 PING > /dev/null 2>&1; then
  echo "   Connected successfully"
  REDIS_INFO=$(docker exec redis-cache redis-cli -a redis123 INFO server 2>/dev/null | grep "redis_version")
  echo "  $REDIS_INFO"
else
  echo "   Connection failed"
fi
echo ""

# Check Elasticsearch
echo " Elasticsearch:"
if curl -s http://localhost:9200/_cluster/health > /dev/null 2>&1; then
  echo "   Connected successfully"
  CLUSTER_HEALTH=$(curl -s http://localhost:9200/_cluster/health | grep -o '"status":"[^"]*"')
  echo "  $CLUSTER_HEALTH"
  echo "   Indices:"
  curl -s http://localhost:9200/_cat/indices?v | head -5
else
  echo "   Connection failed"
fi
echo ""

# Check Kafka
echo " Kafka:"
if docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 > /dev/null 2>&1; then
  echo "   Connected successfully"
  echo "   Topics:"
  docker exec kafka kafka-topics --bootstrap-server localhost:9092 --list 2>/dev/null || echo "  No topics created yet"
else
  echo "   Connection failed"
fi
echo ""

# Check Keycloak
echo " Keycloak:"
if curl -s http://localhost:8180/health/ready | grep -q "UP"; then
  echo "   Connected successfully"
  echo "   Admin Console: http://localhost:8180"
  echo "   Admin credentials: admin / admin"
else
  echo "   Connection failed"
fi
echo ""

# Check LocalStack
echo " LocalStack:"
if curl -s http://localhost:4566/_localstack/health > /dev/null 2>&1; then
  echo "   Connected successfully"
  echo "   S3 Buckets:"
  aws --endpoint-url=http://localhost:4566 s3 ls 2>/dev/null || echo "  Run: aws configure set aws_access_key_id test && aws configure set aws_secret_access_key test"
  echo "   Lambda Functions:"
  aws --endpoint-url=http://localhost:4566 lambda list-functions --query 'Functions[*].FunctionName' 2>/dev/null || echo "  (Configure AWS CLI first)"
else
  echo "   Connection failed"
fi
echo ""

echo " Verification complete!"
echo ""
echo " Troubleshooting:"
echo "  - If any service failed, check logs: docker-compose logs [service-name]"
echo "  - Restart a service: docker-compose restart [service-name]"
echo "  - Stop all services: docker-compose down"
echo "  - Start all services: docker-compose up -d"