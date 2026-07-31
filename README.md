# Corda Enterprise Network Manager (CENM) deployment

Documentation on Corda Enterprise Network Manager (CENM) can be found at [CENM Deployment with Docker, Kubernetes and Helm charts](https://docs.r3.com/en/platform/corda/1.6/cenm/deployment-kubernetes.html).

## How to get deployment for particular CENM version:

| CENM version                 | Command to run      |
|------------------------------|---------------------|
| 1.6                          | git checkout v1.6   |
| 1.5.9                        | git checkout v1.5.9 |
<!-- | 1.3.5 (no longer maintained) | git checkout v1.3.5 |
| 1.4.4 (no longer maintained) | git checkout v1.4.4 | -->


## AMENDED FOR GCP
#### Assumptions:
- the namespace used is cenm. It is hardcoded in the pre-requesite script.
- Your GCP API are all enabled (Filestore, Kubernetes, Artifactory, etc.)
- your loadbalancer is delegated to GKE
- GKE has its CSIFilestore driver enabled running with n1-standard-1 and n1-standard-4 machines.


#### DevOps local machine preparation:
Clone locally this repo.

#### login first to your Google Artifactory
>  gcloud auth configure-docker us-central1-docker.pkg.dev

#### Create the docker secret:
> kubectl create secret docker-registry cenm-registry \
 --docker-server=https:<<URL-TO-YOUR-GCR>>\
--docker-username=oauth2accesstoken \
--docker-password="$(gcloud auth print-access-token)" \
--docker-email=my-email@address.used \
-n cenm

Run the pre-requesite  _./prereq.sh_ script to:
- create the cenm Kubernetes namespace
- create two new _StorageClasses_ (_cenm_, and _cenm-shared_)
- create the linked role and rolebinding.
- Please add the user pod subnetwork used by the GKE into the filestore configurations (currently left with "default" value). 
  As indicated below:
    -         parameters:
                  tier: standard
                  network: YOUR_NETWORK_NAME

Navigate to k8s directory and run:
> ./bootstrap.cenm --ACCEPT_LICENSE Y --auto

- you should 

To Remove the CENM deployment run the below commands:
> export CENM_PREFIX=cenm
> helm delete ${CENM_PREFIX}-auth ${CENM_PREFIX}-gateway ${CENM_PREFIX}-idman ${CENM_PREFIX}-nmap ${CENM_PREFIX}-notary ${CENM_PREFIX}-pki ${CENM_PREFIX}-hsm ${CENM_PREFIX}-signer ${CENM_PREFIX}-zone ${CENM_PREFIX}-idman-ip ${CENM_PREFIX}-notary-ip