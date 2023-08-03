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