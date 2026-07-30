function Check-Nodes {
    Write-Host "Checking Kubernetes Nodes..."
    $nodes = kubectl get nodes --no-headers | ForEach-Object {
        $fields = $_ -split '\s+'
        [PSCustomObject]@{
            NodeName = $fields[0]
            Status   = $fields[1]
        }
    }
 
    $allHealthy = $true
    foreach ($node in $nodes) {
        if ($node.Status -ne "Ready") {
            Write-Error "Node $($node.NodeName) is not healthy. Status: $($node.Status)"
            $allHealthy = $false
        } else {
            Write-Host "Node $($node.NodeName) is healthy."
        }
    }
 
    if (-not $allHealthy) {
        exit 1
    }
}
 
function Check-Pods {
    Write-Host "Checking Kubernetes Pods..."
    $pods = kubectl get pods --all-namespaces --no-headers | ForEach-Object {
        $fields = $_ -split '\s+'
        [PSCustomObject]@{
            Namespace = $fields[0]
            PodName   = $fields[1]
            Status    = $fields[3]  # Actual pod status
        }
    }
 
    $allHealthy = $true
    foreach ($pod in $pods) {
        if ($pod.Status -ne "Running" -and $pod.Status -ne "Completed") {
            Write-Error "Pod $($pod.PodName) in namespace $($pod.Namespace) is not healthy. Status: $($pod.Status)"
            $allHealthy = $false
        } else {
            Write-Host "Pod $($pod.PodName) in namespace $($pod.Namespace) is healthy."
        }
    }
 
    if (-not $allHealthy) {
        exit 1
    }
}
 
# Run the checks
Check-Nodes
Check-Pods
 
Write-Host "`n✅ All Kubernetes components are healthy."
exit 0