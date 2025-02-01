FROM ubuntu:20.04

WORKDIR /app

COPY . /app

# Copy and set permissions for the entry point script
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Install system dependencies (curl, unzip) for AWS CLI installation
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install AWS CLI
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" \
    && unzip awscliv2.zip \
    && ./aws/install \
    && rm -rf awscliv2.zip aws

# Verify AWS CLI installation
RUN aws --version

# Creates a non-root user with an explicit UID and adds permission to access the /app folder
RUN adduser --disabled-password --gecos "" skywalker && \
    mkdir -p /app/credentials && \
    chown -R skywalker:skywalker /app && \
    chmod -R 777 /app/credentials

USER skywalker

# Configure AWS CLI using environment variables
RUN mkdir -p /home/skywalker/.aws && \
    echo "[default]" > /home/skywalker/.aws/credentials && \
    echo "aws_access_key_id=$AWS_ACCESS_KEY_ID" >> /home/skywalker/.aws/credentials && \
    echo "aws_secret_access_key=$AWS_SECRET_ACCESS_KEY" >> /home/skywalker/.aws/credentials && \
    echo "[default]" > /home/skywalker/.aws/config && \
    echo "region=$AWS_DEFAULT_REGION" >> /home/skywalker/.aws/config

# Set AWS environment variables
ENV AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
ENV AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
ENV AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION}

# Set entry point to run the entrypoint script first
ENTRYPOINT ["/entrypoint.sh"]

CMD tail -f /dev/null
