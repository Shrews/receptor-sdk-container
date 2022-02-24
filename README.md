Preparing a Receptor Development Environment
============================================

This repo is intended to assist a developer with building a Podman container
image that runs receptor and is setup to receive work payloads suitable for
ansible-runner.

The steps outlined here were performed on an Ubuntu Impish (21.10) system.

Step 1 - Build a Base Receptor Container Image
----------------------------------------------

This will build a _podman_ image, by default.

* git clone https://github.com/ansible/receptor.git
* cd receptor
* make container

You should now have an image named _localhost/receptor:latest_. This does not
contain installations of Ansible or ansible-runner, so those will have to be
installed in the next step.

Step 2 - Complete the Container Image Build
-------------------------------------------

With the base container now built, we build on that, installing everything we
need, using a custom podman Containerfile and installing a custom receptor
configuration file.

* git clone https://github.com/Shrews/receptor-sdk-container.git
* cd receptor-sdk-container
* podman build -t receptor:sdk .

And now you should have the container image _localhost/receptor:sdk_ available.
This will be the image used in the next steps.

Step 3 - Test the Container Image
---------------------------------

The steps below that use ansible-runner use the _demo_ sample private data
directory (or a copy of it) that is included with the ansible-runner repository.
It contains a _test.yml_ playbook to run, and is used to generate artifact files
when processing the returned data.

* Start receptor in a container named “_server_”:

  podman run -p 2222:2222 –rm –name server receptor:sdk

* Use ansible-runner to create a work payload:

  ansible-runner transmit demo -p test.yml > /tmp/mypayload

* Use receptorctl on the container to submit the job:

  cat /tmp/mypayload | podman exec -i server receptorctl --socket=tcp://localhost:2222 work submit mycommand -p - -f > /tmp/response

* Alternatively, if you have receptorctl available on your local machine:

  receptorctl --socket=tcp://localhost:2222 work submit mycommand -p /tmp/mypayload -f > /tmp/response

* Use ansible-runner to process the response:

  ansible-runner process demo < /tmp/response
