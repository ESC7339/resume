# Dependency check
function Install-Node {
    if (-not (Get-Command choco -ErrorAction SilentlyContinue)) {
        Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
    }
    choco install -y nodejs
}


function install {
    New-Item -ItemType Directory -Path "myapp" | Out-Null
    Set-Location -Path "myapp"
    New-Item -ItemType Directory -Path "public", "routes", "views" | Out-Null
    npm init -y
    npm install express --save

    
    @"
const express = require('express');
const path = require('path');
const app = express();
const port = process.env.PORT || 3000;

app.use(express.static(path.join(__dirname, 'public')));

app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'views', 'index.html'));
});

app.listen(port, () => {
    console.log(`Server is running on http://localhost:\${port}`);
});
"@ | Out-File -FilePath "app.js" -Encoding utf8

    
    @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Boilerplate</title>
</head>
<body>
    <h1>Boilerplate H1</h1>
</body>
</html>
"@ | Out-File -FilePath "views\index.html" -Encoding utf8

    Write-Host "Web app setup complete."
}


Write-Host "Starting deployment of Node.js web app..."


if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Install-Node
}

install

