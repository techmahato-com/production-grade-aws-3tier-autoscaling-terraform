#!/bin/bash
set -euo pipefail

# Log all output
exec > >(tee /var/log/userdata-tomcat.log) 2>&1
echo "=== Tomcat Bootstrap Started: $(date) ==="

# Update system
yum update -y

# Install Java 11 and dependencies
yum install -y java-11-amazon-corretto-headless amazon-cloudwatch-agent

# Create tomcat user
useradd -r -m -U -d /opt/tomcat -s /bin/false tomcat || true

# Download and install Tomcat
TOMCAT_VERSION="9.0.93"
cd /tmp
curl -sO "https://dlcdn.apache.org/tomcat/tomcat-9/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
tar xzf "apache-tomcat-${TOMCAT_VERSION}.tar.gz"
mv "apache-tomcat-${TOMCAT_VERSION}/" /opt/tomcat/
chown -R tomcat:tomcat /opt/tomcat

# Remove default webapps (security hardening)
rm -rf /opt/tomcat/webapps/ROOT /opt/tomcat/webapps/docs /opt/tomcat/webapps/examples /opt/tomcat/webapps/host-manager

# Create systemd service
cat > /etc/systemd/system/tomcat.service <<'EOF'
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking
User=tomcat
Group=tomcat

Environment=JAVA_HOME=/usr/lib/jvm/java-11-amazon-corretto
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseG1GC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Tomcat
systemctl daemon-reload
systemctl enable tomcat
systemctl start tomcat

# Configure CloudWatch Agent
cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json <<'CW'
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/opt/tomcat/logs/catalina.out",
            "log_group_name": "/aws/ec2/tomcat/catalina",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "mem": {
        "measurement": ["mem_used_percent"]
      },
      "swap": {
        "measurement": ["swap_used_percent"]
      },
      "disk": {
        "measurement": ["used_percent"],
        "resources": ["/"]
      }
    }
  }
}
CW

/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
  -a fetch-config -m ec2 \
  -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json -s

echo "=== Tomcat Bootstrap Completed: $(date) ==="
