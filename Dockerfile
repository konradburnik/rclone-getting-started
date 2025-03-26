FROM python:3.11-slim-bookworm 

# Install git, required to allow pip to install packages from git repositories
RUN apt-get update && \
    apt-get install --no-install-recommends -y git gnupg2 && \
    rm -rf /var/lib/apt/lists/*


# Upgrade package due to CVE-2024-45491, CVE-2024-45490, CVE-2024-45492
RUN apt-get update && apt-get install -y --only-upgrade libexpat1 

# Basic tools for installation of other tools
RUN apt-get install -y curl zip

# Install GCP CLI
RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] https://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-cli -y

# Install Azure CLI
RUN curl -sL https://aka.ms/InstallAzureCLIDeb | bash

# Install rclone
RUN curl https://rclone.org/install.sh | bash

ENTRYPOINT ["bash"]