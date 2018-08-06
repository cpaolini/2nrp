#!/bin/bash
namespace=$1
hosts=""
n=0
for host in `kubectl get pod -n $namespace -o=custom-columns=IP:status.podIP,NAME:.metadata.name | grep subflow`
do
    hosts="$hosts $host"
    if [ $n -eq 1 ];
    then
  	cores=`kubectl exec -it $host -n $namespace -- bash -c "grep -c ^processor /proc/cpuinfo"`
	cores=`tr -dc '[[:print:]]' <<< " $cores"`
	hosts+=$cores
	n=0
    else
	n=1
    fi
done
# echo $hosts
pods=`kubectl get pod -n $namespace -o=custom-columns=NAME:.metadata.name|sed -e '/NAME/d'|egrep '^subflow-'`
for pod in $pods
do
    # echo $pod
    kubectl exec -it $pod -n $namespace -- bash -c "/nfs/subflow/k8s/setup.sh $hosts"
done
for pod in $pods
do
    kubectl exec -it $pod -n $namespace -- bash -c "/nfs/subflow/k8s/updatekeys.sh"
done
