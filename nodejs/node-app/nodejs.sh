
#!/bin/bash

# Variables
BUCKET_NAME="pradeep-bucket-1999"
REGION="ap-south-1"
APP_DIR="pradeep-app"
ZIP_FILE="pradeep_nodejs.zip"

# Step 1: Create Node.js Application
echo "Setting up Node.js application..."
mkdir $APP_DIR
cd $APP_DIR
npm init -y

# Create a simple app.js
cat > pradeep.js <<EOL
const http = require('http');
const server = http.createServer((req, res) => {
    res.statusCode = 200;
    res.setHeader('Content-Type', 'text/plain');
    res.end('Hello World\n');
});
server.listen(3000, '172.25.98.108 ', () => {
    console.log('Server running at http://172.25.98.108 :3000/');
});
EOL

# Step 2: Install Dependencies
npm install

# Step 3: Build (Zip) the Application
echo "Building application..."
zip -r ../$ZIP_FILE *

# Go back to root directory
cd ..

# Step 4: Create S3 Bucket (if not exists)
if aws s3 ls "s3://$BUCKET_NAME" 2>&1 | grep -q 'NoSuchBucket'
then
    echo "Creating S3 bucket: $BUCKET_NAME..."
    aws s3 mb s3://$BUCKET_NAME --region $REGION
else
    echo "S3 bucket $BUCKET_NAME already exists."
fi

# Step 5: Deploy to S3
echo "Deploying application to S3..."
aws s3 cp $ZIP_FILE s3://$BUCKET_NAME/$ZIP_FILE

# Step 6: Make the ACLS enable (optional)
aws s3api put-bucket-ownership-controls --bucket $BUCKET_NAME --ownership-controls='{"Rules": [{"ObjectOwnership": "ObjectWriter"}]}'
aws s3api get-bucket-ownership-controls --bucket  $BUCKET_NAME

# step 7: Make the public access enable (optional)
aws s3api delete-public-access-block --bucket $BUCKET_NAME

# Step 8: Make the file public (optional)
aws s3api put-bucket-acl --bucket $BUCKET_NAME --acl public-read
aws s3api put-object-acl --bucket $BUCKET_NAME --key $ZIP_FILE --acl public-read


# End of script
echo "Deployment completed successfully!"