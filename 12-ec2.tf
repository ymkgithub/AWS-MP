resource "aws_security_group" "my_app" {
  name        = "my-app"
  description = "Allow My App Access"
  vpc_id      = aws_vpc.env_vpc.id

  ingress {
    description     = "Allow Node Exporter Access"
    from_port       = 9100
    to_port         = 9100
    protocol        = "tcp"
    security_groups = [aws_eks_cluster.eks.vpc_config[0].cluster_security_group_id]
  }

  ingress {
    description = "Allow SSH Access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Generate a new private key using the TLS provider
resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 2048
}

# Upload the public key to AWS as a key pair
resource "aws_key_pair" "my_key" {
  key_name   = "${local.env_name}-mahesh-amp-key" # Name of the key pair in AWS
  public_key = tls_private_key.example.public_key_openssh
}

# Save the private key to a local file
resource "local_file" "private_key" {
  filename        = "${path.module}/amp_private_key.pem"
  content         = tls_private_key.example.private_key_pem
  file_permission = "0600" # Ensure correct permissions
}

resource "aws_instance" "my_app" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name      = aws_key_pair.my_key.key_name
  subnet_id     = aws_subnet.public_subnet_2.id
  vpc_security_group_ids = [
    aws_security_group.my_app.id
  ]

  user_data = <<EOF
#!/bin/bash

sudo -s
useradd --system --no-create-home --shell /bin/false node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
tar -xvf node_exporter-1.3.1.linux-amd64.tar.gz
mv node_exporter-1.3.1.linux-amd64/node_exporter /usr/local/bin/

cat <<EOT >> /etc/systemd/system/node_exporter.service
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

StartLimitIntervalSec=500
StartLimitBurst=5

[Service]
User=node_exporter
Group=node_exporter
Type=simple
Restart=on-failure
RestartSec=5s
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
EOT

systemctl enable node_exporter
systemctl start node_exporter
EOF

  tags = {
    Name        = "${local.env_name}-vpc"
    node-exporter = "true"
  }
}
