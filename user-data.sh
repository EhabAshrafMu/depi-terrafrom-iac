#!/bin/bash
set -e

# Log everything
exec > >(tee /var/log/user-data.log)
exec 2>&1

echo "=== Starting Diginnocent Application Setup ==="

# Update and install Docker
apt-get update
apt-get install -y ca-certificates curl gnupg git lsb-release

# Add Docker repository
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg

echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  tee /etc/apt/sources.list.d/docker.list > /dev/null

apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin docker-buildx git postgresql-client python3-pip

# Start Docker
systemctl start docker
systemctl enable docker

# Clone repository
mkdir -p /opt/diginnocent
cd /opt/diginnocent
# amazonq-ignore-next-line
git clone ${github_repo_url} .

# Create .env file
cat > .env <<EOF
DEBUG=False
SECRET_KEY=${django_secret_key}
# amazonq-ignore-next-line
ALLOWED_HOSTS=*
# amazonq-ignore-next-line
DATABASE_URL=sqlite:///db.sqlite3
EOF

# Set permissions
chown -R ubuntu:ubuntu /opt/diginnocent

# Build and start
docker compose build
docker compose up -d

# Create superuser
# amazonq-ignore-next-line
sleep 20
docker compose exec -T web python manage.py shell <<'EOF'
from django.contrib.auth import get_user_model
User = get_user_model()
if not User.objects.filter(username='admin').exists():
    # amazonq-ignore-next-line
    User.objects.create_superuser('admin', 'admin@example.com', 'changeme123')
EOF

echo "=== Setup Complete ==="
echo "Application: http://\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "Admin: http://\$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)/admin"
echo "Credentials: admin/changeme123"