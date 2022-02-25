FROM receptor:latest

# Need pip installed
RUN dnf -y update && \
    dnf -y install python3-pip && \
    dnf clean all

# Upgrade pip to latest to avoid the following error when the cryptography package installs:
#    ModuleNotFoundError: No module named 'setuptools_rust'
RUN pip3 install -U pip

# Install latest versions of Ansible and Runner
RUN pip3 install ansible-runner && \
    pip3 install ansible-core

# Install custom config file and expose the referenced port
COPY receptor.conf /etc/receptor/receptor.conf
EXPOSE 2222
