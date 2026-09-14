#!/bin/bash
set -e

echo "=== Waypoint Setup ==="
echo ""

# Check Node.js
if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js not found. Install from https://nodejs.org"
    exit 1
fi

# Check Flutter
if ! command -v flutter &> /dev/null; then
    echo "ERROR: Flutter not found. Install from https://flutter.dev"
    exit 1
fi

# Check backend .env
if [ ! -f backend/.env ]; then
    echo "ERROR: backend/.env not found."
    echo "Copy backend/.env.example to backend/.env and fill in your API keys."
    exit 1
fi

# Source .env to check keys
source backend/.env

if [ "$DATABASE_URL" = "postgresql://user:password@ep-xxx.us-east-2.aws.neon.tech/waypoint?sslmode=require" ] || [ -z "$DATABASE_URL" ]; then
    echo "ERROR: DATABASE_URL not set in backend/.env"
    echo "Get from: https://console.neon.tech"
    exit 1
fi

if [ "$OPENROUTER_API_KEY" = "sk-or-v1-xxxxxxxxxxxxxxxxxxxxxxxx" ] || [ -z "$OPENROUTER_API_KEY" ]; then
    echo "ERROR: OPENROUTER_API_KEY not set in backend/.env"
    echo "Get from: https://openrouter.ai"
    exit 1
fi

echo "Installing backend dependencies..."
cd backend && npm install && cd ..

echo "Running database migrations..."
cd backend && npm run migrate && cd ..

echo "Installing Flutter dependencies..."
flutter pub get

echo ""
echo "=== Setup Complete ==="
echo ""
echo "To start the backend:  cd backend && npm run dev"
echo "To start the frontend: flutter run -d chrome"
echo ""
echo "For deployment, push to GitHub and connect to:"
echo "  - Backend:  https://render.com (auto-deploy from repo)"
echo "  - Frontend: https://pages.cloudflare.com (flutter build web → build/web)"
