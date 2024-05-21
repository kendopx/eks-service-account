

### Table of Contents
1.	What are IAM Roles for Kubernetes service accounts?
2.	Set up OIDC provider
3.	Creating the IAM role
4.	Create the SSM parameter
5.	Create the Kubernetes configuration
6.	Test that everything is working

### What are IAM Roles for Kubernetes service accounts?
The IAM Roles for Kubernetes service accounts allow us to associate an IAM role with a Kubernetes service account. This feature is available through the Amazon EKS Pod Identity Webhook. The IAM role for a service account is then used to provide AWS credentials to the pod or resource using the service account.

### Set up OIDC provider

### Item needed to create ServiceAccount in EKS 
1. OIDC Issuer - Already set up if you are running in EKS
2. OIDC provider
3. The IAM role that we want to associate with the service account
4. The Kubernetes service account that we want to associate with the IAM role

There are two parts to using OIDC an Issuer and a Provider. The issuer is the entity that issues the token, and the provider is the entity that validates the token. In our case, the issuer is handled by AWS, and Kubernetes handles the provider. When we create the EKS cluster, we already have an Issuer endpoint. If you want to use your OIDC issuer, you can provide that to EKS. But in this example, we'll stick to the issuer already in the EKS cluster.

### If you prefer to use AWS CLI, you can run the following AWS CLI command. Replace CLUSTER_NAME with your cluster name.

```sh
### Let's check first if an OIDC provider is already created for our cluster. Run the following command:
aws iam list-open-id-connect-providers
aws eks describe-cluster --name eks-cluster-2 --query "cluster.identity.oidc.issuer" --output text

### Step 1. Set the variables
CLUSTER_NAME="eks-cluster-2"
SERVICE_ACCOUNT_NAMESPACE="demo-svcaccount"
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query "Account" --output text)
OIDC_PROVIDER=$(aws eks describe-cluster --name ${CLUSTER_NAME} --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")


### Step 2. Create the IAM role for the account
./1_create_service_account.sh

### OR create the role manually
aws iam create-role --role-name IAM_ROLE_NAME --assume-role-policy-document file://trust2.json 

### Step 3. Create namespace for the account
kubectl apply -f 2_namespace.yaml

### Step 4. Create Service account
kubectl apply -f 3_serviceaccount.yaml

### Step 5. Create Service account
kubectl apply -f 4_iam-demo-pod.yaml
kubectl get pods -n demo
podname=$(kubectl get pods -n demo --no-headers| awk '{print $1}')
kubectl -n demo exec -it $podname — bash

### List role 
aws iam list-roles --output=json | jq '.Roles[] |  {role: .RoleName, user: .AssumeRolePolicyDocument.Statement[].Principal.AWS} | select(.user != null)'
```
