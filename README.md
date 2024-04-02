# **Ansible Playbook: Deploy a Kubernetes "Hello World" Application on KIND Cluster**

This Ansible playbook automates the deployment of a Kubernetes "Hello World" application on a cluster configured using the KIND (Kubernetes in Docker) tool. The playbook verifies if each prerequisite is installed. If any of the prerequisites is not found, the playbook takes care of installing it. After all the requirements are met, the playbook proceeds to create a Kubernetes cluster using KIND, deploys an Nginx Ingress Controller, installs a Helm chart of a simple "hello-world" application, and finally curls the output of the web application, to verify if the deployment is successful.



## **Prerequisites**

Before running this playbook, ensure that the following prerequisites are met:
- Ansible is installed on the control machine.
- The control machine has SSH access to the target hosts.
- Passwordless authentication is enabled between machines and your private key path is stored at /etc/ansible/ansible.cfg:
```
[defaults]
'private_key_file=/path/to/your/private_key'
```
- Internet access is available on the control machine and target hosts.
- An username with superuser privileges needs to be configured on the target host.

## Playbook Structure 
1. **Check for dependecies**. The playbook will check if some of the requirements are present of the machine
2. **Install dependencies**. If no other version was found on the target host, the playbook will install the newest version of the required software, by using scripts defined on the official websites.
3. **Create Kubernetes Cluster**. The playbook will create a kubernetes cluster by using the KIND tool. For the cluster name it uses an Ansible variable `kind_cluster_name` that can be defined at the start of the play. The config file can also be found under `../deployment_utilites/kind-config.yaml`
4. **Deploy Nginx Ingress Controller**. After the Kubernetes cluster is up and running, the playbook will deploy an Nginx Ingress Controller that will take care of managing inbound traffic to the application.
5. **Deploy the "Hello World" Application**. By using helm, this task is deploying a simple "Hello world" application, by using a local chart that is stored on the control machine. The helm chart that was used can be found at [helloworld-chart](https://artifacthub.io/packages/helm/crowdsec/helloworld).
6. **Verifying the output of the application**. After the successful deployment of the application, the playbook is sending a cURL request to the defined hostname and then it prints the output of the request.

## **Usage**
  Prior to running the application, please modify the `inventory.ini` file from the `ansible_playbook` directory, so that it suits your needs. The `ansible_user` should have superuser privileges on the target host:
  ```
[orange_interview]
host1 ansible_host=YOUR_IP ansible_user=YOUR_USERNAME
host2 ansible_host=YOUR_IP ansible_user=YOUR_USERNAME
```

After the inventory is validated and the target host is online, the playbook can be run by using the following command:
` ansible-playbook -i inventory.ini playbook.yaml --ask-become-pass `. The `--ask-become-pass` parameter will prompt for the password of the user that was defined under `inventory.ini`.
The playbook will then run all the tasks and will deploy the "hello world" application on Kubernetes, on top of a cluster defined with the KIND tool. The application output can be seen at the end of the playbook, as it follows:
![image](https://github.com/Dragos-Gerea/orange-services-task/assets/74601702/1d2f69c2-61a1-4c12-bc4f-5766c3dc8f2a)

## **Known issues**
In some rare scenarios, the `ValidatingWebhookConfiguration` will not get correctly deployed and the Ingress rule of the application will not get created. In this scenario, please run the following commands to delete the `ValidatingWebhookConfiguration` and the `kind cluster`, where YOUR_CLUSTER_NAME is the name of your kind cluster where the application is deployed:
```
kubectl delete -A ValidatingWebhookConfiguration ingress-nginx-admission
sudo kind delete cluster --name=YOUR_CLUSTER_NAME
```
After the deletion of the cluster, ` ansible-playbook -i inventory.ini playbook.yaml --ask-become-pass ` can be run again.


## **References** 
1. [Install Docker on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
2. [Kind-Quick Start](https://kind.sigs.k8s.io/docs/user/quick-start/)
3. [Install Kubectl on Linux](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
4. [Install Helm](https://helm.sh/docs/intro/install/)
5. [Nginx Ingress controller for Kind from Kubernetes official git](https://github.com/kubernetes/ingress-nginx/tree/main/deploy/static/provider/kind)
6. [Hello-World helm chart](https://artifacthub.io/packages/helm/crowdsec/helloworld)
7. [How to test ingress in a kind cluster](https://dustinspecker.com/posts/test-ingress-in-kind/)


