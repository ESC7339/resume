#!/bin/bash

# Dependency check
install_node() {
    echo "Installing Node.js and npm..."
    if [ -x "$(command -v apt-get)" ]; then
        curl -fsSL https://deb.nodesource.com/setup_16.x | sudo -E bash -
        sudo apt-get install -y nodejs
    elif [ -x "$(command -v yum)" ]; then
        curl -fsSL https://rpm.nodesource.com/setup_16.x | sudo bash -
        sudo yum install -y nodejs
    else
        echo "Package manager not supported. Please install Node.js manually."
        exit 1
    fi
}


create_web_app() {
    echo "Creating web app directory structure..."
    mkdir -p myapp
    cd myapp || exit
    mkdir -p public routes views

    echo "Initializing npm..."
    npm init -y

    echo "Installing dependencies..."
    npm install express --save

    echo "Injecting code..."

    # Inject boiler plate
    cat << 'EOF' > app.js
const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'index.html'));
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});
EOF


    cat << 'EOF' > views/index.html
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>My Node.js App</title>
</head>
<body>
    <h1>Welcome to My Node.js Web App!</h1>
</body>
</html>
EOF

    echo "Web app setup complete."
}


echo "Starting deployment of Node.js web app..."

# Check if Node is installed
if ! [ -x "$(command -v node)" ]; then
    install_node
fi

create_web_app

echo "To start the web app, run: node app.js"
