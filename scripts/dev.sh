#!/usr/bin/env bash
set -e

echo "🚀 Starting DisasterAid V2.1 Dev Environment..."

# 1. Check for root .env
if [ ! -f .env ]; then
  echo "⚠️  Root .env not found. Creating from .env.example..."
  cp .env.example .env
  echo "✅ Created .env. PLEASE EDIT IT with real secrets if needed."
fi

# 2. Start PostgreSQL
echo "🐘 Spinning up PostgreSQL..."
docker compose up -d postgres

# 3. Wait for DB health
echo "⏳ Waiting for database to be ready..."
until docker compose exec postgres pg_isready -U disasteraid_user -d disasteraid; do
  sleep 1
done
echo "✅ Database is ready."

# 4. Install Backend Dependencies
echo "📦 Installing backend dependencies..."
cd backend && npm install && cd ..

# 5. Start Backend + Admin in Dev Mode
echo "🔥 Starting Backend and Admin Panel with Hot Reload..."
docker compose -f docker-compose.yml -f docker-compose.dev.yml up --build backend admin-panel
