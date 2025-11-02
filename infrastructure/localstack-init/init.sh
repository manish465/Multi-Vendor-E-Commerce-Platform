#!/bin/bash

echo "Waiting for LocalStack to be ready..."
sleep 10

echo "Creating S3 buckets..."

# Create S3 buckets
awslocal s3 mb s3://product-images --region us-east-1
awslocal s3 mb s3://user-avatars --region us-east-1
awslocal s3 mb s3://invoices --region us-east-1
awslocal s3 mb s3://vendor-documents --region us-east-1

echo "S3 buckets created successfully!"

# Set bucket CORS configuration for product-images
awslocal s3api put-bucket-cors \
  --bucket product-images \
  --cors-configuration '{
    "CORSRules": [
      {
        "AllowedOrigins": ["*"],
        "AllowedMethods": ["GET", "PUT", "POST", "DELETE", "HEAD"],
        "AllowedHeaders": ["*"],
        "ExposeHeaders": ["ETag"],
        "MaxAgeSeconds": 3000
      }
    ]
  }'

echo "CORS configured for product-images bucket"

# Set bucket policy for public read access on product-images
awslocal s3api put-bucket-policy \
  --bucket product-images \
  --policy '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Sid": "PublicReadGetObject",
        "Effect": "Allow",
        "Principal": "*",
        "Action": "s3:GetObject",
        "Resource": "arn:aws:s3:::product-images/*"
      }
    ]
  }'

echo "Public read access configured for product-images"

# List all buckets
echo "Available S3 buckets:"
awslocal s3 ls

# Create IAM role for Lambda
awslocal iam create-role \
  --role-name lambda-execution-role \
  --assume-role-policy-document '{
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "lambda.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  }'

echo "IAM role created for Lambda functions"

# Attach policies to Lambda role
awslocal iam attach-role-policy \
  --role-name lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole

awslocal iam attach-role-policy \
  --role-name lambda-execution-role \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

echo "Policies attached to Lambda role"

echo "Creating Lambda functions..."

# Create a simple Lambda function for invoice generation (placeholder)
mkdir -p /tmp/lambda-functions/invoice-generator
cat > /tmp/lambda-functions/invoice-generator/index.js << 'EOF'
exports.handler = async (event) => {
    console.log('Invoice Generator Lambda triggered');
    console.log('Event:', JSON.stringify(event, null, 2));
    
    // Parse the order data
    const order = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
    
    // Simulate invoice generation
    const invoice = {
        invoiceNumber: `INV-${order.orderNumber}`,
        orderNumber: order.orderNumber,
        generatedAt: new Date().toISOString(),
        status: 'GENERATED',
        s3Url: `http://localhost:4566/invoices/${order.orderNumber}.pdf`
    };
    
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify(invoice)
    };
};
EOF

# Create a simple Lambda function for image processing (placeholder)
mkdir -p /tmp/lambda-functions/image-processor
cat > /tmp/lambda-functions/image-processor/index.js << 'EOF'
exports.handler = async (event) => {
    console.log('Image Processor Lambda triggered');
    console.log('Event:', JSON.stringify(event, null, 2));
    
    // Parse the request
    const request = typeof event.body === 'string' ? JSON.parse(event.body) : event.body;
    
    // Simulate image processing
    const result = {
        originalUrl: request.imageUrl,
        thumbnailUrl: request.imageUrl.replace('.jpg', '_thumb.jpg'),
        mediumUrl: request.imageUrl.replace('.jpg', '_medium.jpg'),
        processedAt: new Date().toISOString(),
        status: 'PROCESSED'
    };
    
    return {
        statusCode: 200,
        headers: {
            'Content-Type': 'application/json',
            'Access-Control-Allow-Origin': '*'
        },
        body: JSON.stringify(result)
    };
};
EOF

# Create ZIP files for Lambda functions
cd /tmp/lambda-functions/invoice-generator && zip -r invoice-generator.zip index.js
cd /tmp/lambda-functions/image-processor && zip -r image-processor.zip index.js

# Create Lambda functions in LocalStack
awslocal lambda create-function \
  --function-name invoiceGenerator \
  --runtime nodejs18.x \
  --role arn:aws:iam::000000000000:role/lambda-execution-role \
  --handler index.handler \
  --zip-file fileb:///tmp/lambda-functions/invoice-generator/invoice-generator.zip \
  --timeout 30 \
  --memory-size 256

echo "Invoice Generator Lambda created"

awslocal lambda create-function \
  --function-name imageProcessor \
  --runtime nodejs18.x \
  --role arn:aws:iam::000000000000:role/lambda-execution-role \
  --handler index.handler \
  --zip-file fileb:///tmp/lambda-functions/image-processor/image-processor.zip \
  --timeout 30 \
  --memory-size 512

echo "Image Processor Lambda created"

# List all Lambda functions
echo "Available Lambda functions:"
awslocal lambda list-functions --query 'Functions[*].[FunctionName,Runtime,Handler]' --output table

echo "LocalStack initialization completed successfully!"