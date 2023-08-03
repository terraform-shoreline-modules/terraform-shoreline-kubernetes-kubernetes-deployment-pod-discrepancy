
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Kubernetes Deployment Pod Discrepancy
---

This incident type refers to an issue where the number of desired pods in a Kubernetes deployment does not match the number of actual pods running. This can cause problems with the functioning of the application or service running in the pods and may require investigation and resolution by the DevOps or engineering team.

### Parameters
```shell
# Environment Variables

export NAMESPACE="PLACEHOLDER"

export POD_NAME="PLACEHOLDER"

export CONTAINER_NAME="PLACEHOLDER"

export DEPLOYMENT_NAME="PLACEHOLDER"

export EXPECTED_NUMBER_OF_PODS="PLACEHOLDER"

export POD_LABEL="PLACEHOLDER"

export LOG_FILE="PLACEHOLDER"
```

## Debug

### Check the status of all deployments
```shell
kubectl get deployments
```

### Check the status of all pods in a specific namespace
```shell
kubectl get pods --namespace=${NAMESPACE}
```

### Get detailed information about a specific pod
```shell
kubectl describe pod ${POD_NAME}
```

### Check the logs of a specific pod
```shell
kubectl logs ${POD_NAME}
```

### Check the logs of a specific container in a pod
```shell
kubectl logs ${POD_NAME} ${CONTAINER_NAME}
```

### Check the events related to a specific pod
```shell
kubectl get events --field-selector involvedObject.name=${POD_NAME}
```

### Configuration error: The configuration of the Kubernetes deployment may have been changed without proper testing or validation. This could lead to an incorrect number of desired pods specified in the deployment configuration.
```shell
bash

#!/bin/bash



# Set variables

NAMESPACE=${NAMESPACE}

DEPLOYMENT=${DEPLOYMENT_NAME}

EXPECTED_PODS=${EXPECTED_NUMBER_OF_PODS}



# Get the current number of pods in the deployment

CURRENT_PODS=$(kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o=jsonpath='{.status.readyReplicas}')



# Check if the current and expected number of pods match

if [ $CURRENT_PODS -ne $EXPECTED_PODS ]; then

  echo "Error: The current number of pods ($CURRENT_PODS) in deployment $DEPLOYMENT does not match the expected number ($EXPECTED_PODS)."

  

  # Get the deployment configuration

  kubectl get deployment $DEPLOYMENT -n $NAMESPACE -o yaml > deployment.yaml

  

  echo "Deployment configuration:"

  cat deployment.yaml

  

  # Check for any recent changes to the deployment

  kubectl rollout history deployment/$DEPLOYMENT -n $NAMESPACE

  

  echo "Recent changes to the deployment:"

  kubectl rollout history deployment/$DEPLOYMENT -n $NAMESPACE

  

  # Check for any errors or warnings in the deployment events

  kubectl get events -n $NAMESPACE --field-selector involvedObject.name=$DEPLOYMENT | grep -E 'Warning|Error'

  

else

  echo "The current number of pods in deployment $DEPLOYMENT matches the expected number."

fi


```

### Application-specific issues: Issues with the application or service running in the pods can cause them to
```shell


#!/bin/bash



# Set variables

NAMESPACE=${NAMESPACE}

POD_LABEL=${POD_LABEL}

CONTAINER_NAME=${CONTAINER_NAME}

LOG_FILE=${LOG_FILE}



# Get pod name

POD_NAME=$(kubectl get pods -n $NAMESPACE -l $POD_LABEL -o jsonpath='{.items[0].metadata.name}')



# Get logs for container

kubectl logs -n $NAMESPACE $POD_NAME $CONTAINER_NAME > $LOG_FILE



# Check for errors

if grep -q "ERROR" $LOG_FILE; then

  echo "Application-specific issue detected: Errors found in container logs."

  echo "Please review the logs in $LOG_FILE for more details."

else

  echo "No application-specific issues detected."

fi



# Clean up log file

rm $LOG_FILE


```

## Repair

### Scale up the number of pods in the deployment to match the desired number.
```shell


#!/bin/bash



# Set variables for the deployment and desired number of pods

deployment=${DEPLOYMENT_NAME}

desired_pods=${EXPECTED_NUMBER_OF_PODS}



# Scale up the deployment to the desired number of pods

kubectl scale deployment $deployment --replicas=$desired_pods



# Verify that the deployment has been scaled up

kubectl get deployment $deployment


```

### Check the logs of the pods to see if any errors are occurring that might be preventing them from running.
```shell


#!/bin/bash



# Set environment variables

NAMESPACE=${NAMESPACE}

POD_NAME=${POD_NAME}



# Get logs from the pod

kubectl logs $POD_NAME -n $NAMESPACE



# Check for errors in the logs

if grep -q "error" $LOG_FILE; then

    echo "Errors detected in the logs."

    # Restart the pod to see if that resolves the issue

    kubectl delete pod $POD_NAME -n $NAMESPACE

else

    echo "No errors detected in the logs."

fi


```