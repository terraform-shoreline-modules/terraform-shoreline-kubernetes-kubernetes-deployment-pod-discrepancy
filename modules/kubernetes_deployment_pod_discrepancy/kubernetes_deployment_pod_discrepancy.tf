resource "shoreline_notebook" "kubernetes_deployment_pod_discrepancy" {
  name       = "kubernetes_deployment_pod_discrepancy"
  data       = file("${path.module}/data/kubernetes_deployment_pod_discrepancy.json")
  depends_on = [shoreline_action.invoke_pod_checker,shoreline_action.invoke_get_pod_logs,shoreline_action.invoke_scale_deployment,shoreline_action.invoke_get_pod_logs]
}

resource "shoreline_file" "pod_checker" {
  name             = "pod_checker"
  input_file       = "${path.module}/data/pod_checker.sh"
  md5              = filemd5("${path.module}/data/pod_checker.sh")
  description      = "Configuration error: The configuration of the Kubernetes deployment may have been changed without proper testing or validation. This could lead to an incorrect number of desired pods specified in the deployment configuration."
  destination_path = "/agent/scripts/pod_checker.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "get_pod_logs" {
  name             = "get_pod_logs"
  input_file       = "${path.module}/data/get_pod_logs.sh"
  md5              = filemd5("${path.module}/data/get_pod_logs.sh")
  description      = "Application-specific issues: Issues with the application or service running in the pods can cause them to"
  destination_path = "/agent/scripts/get_pod_logs.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "scale_deployment" {
  name             = "scale_deployment"
  input_file       = "${path.module}/data/scale_deployment.sh"
  md5              = filemd5("${path.module}/data/scale_deployment.sh")
  description      = "Scale up the number of pods in the deployment to match the desired number."
  destination_path = "/agent/scripts/scale_deployment.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_file" "get_pod_logs" {
  name             = "get_pod_logs"
  input_file       = "${path.module}/data/get_pod_logs.sh"
  md5              = filemd5("${path.module}/data/get_pod_logs.sh")
  description      = "Check the logs of the pods to see if any errors are occurring that might be preventing them from running."
  destination_path = "/agent/scripts/get_pod_logs.sh"
  resource_query   = "host"
  enabled          = true
}

resource "shoreline_action" "invoke_pod_checker" {
  name        = "invoke_pod_checker"
  description = "Configuration error: The configuration of the Kubernetes deployment may have been changed without proper testing or validation. This could lead to an incorrect number of desired pods specified in the deployment configuration."
  command     = "`chmod +x /agent/scripts/pod_checker.sh && /agent/scripts/pod_checker.sh`"
  params      = ["DEPLOYMENT_NAME","EXPECTED_NUMBER_OF_PODS","NAMESPACE"]
  file_deps   = ["pod_checker"]
  enabled     = true
  depends_on  = [shoreline_file.pod_checker]
}

resource "shoreline_action" "invoke_get_pod_logs" {
  name        = "invoke_get_pod_logs"
  description = "Application-specific issues: Issues with the application or service running in the pods can cause them to"
  command     = "`chmod +x /agent/scripts/get_pod_logs.sh && /agent/scripts/get_pod_logs.sh`"
  params      = ["LOG_FILE","POD_NAME","CONTAINER_NAME","NAMESPACE","POD_LABEL"]
  file_deps   = ["get_pod_logs"]
  enabled     = true
  depends_on  = [shoreline_file.get_pod_logs]
}

resource "shoreline_action" "invoke_scale_deployment" {
  name        = "invoke_scale_deployment"
  description = "Scale up the number of pods in the deployment to match the desired number."
  command     = "`chmod +x /agent/scripts/scale_deployment.sh && /agent/scripts/scale_deployment.sh`"
  params      = ["DEPLOYMENT_NAME","EXPECTED_NUMBER_OF_PODS"]
  file_deps   = ["scale_deployment"]
  enabled     = true
  depends_on  = [shoreline_file.scale_deployment]
}

resource "shoreline_action" "invoke_get_pod_logs" {
  name        = "invoke_get_pod_logs"
  description = "Check the logs of the pods to see if any errors are occurring that might be preventing them from running."
  command     = "`chmod +x /agent/scripts/get_pod_logs.sh && /agent/scripts/get_pod_logs.sh`"
  params      = ["LOG_FILE","POD_NAME","NAMESPACE"]
  file_deps   = ["get_pod_logs"]
  enabled     = true
  depends_on  = [shoreline_file.get_pod_logs]
}

