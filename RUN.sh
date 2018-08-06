#!/bin/bash

KUBE_NAMESPACE=sdsu
export KUBE_NAMESPACE

MPI_CLUSTER_NAME=subflow
export MPI_CLUSTER_NAME

case "$1" in
    ring)
        kubectl -n $KUBE_NAMESPACE exec -it $MPI_CLUSTER_NAME-74c57d67d4-bqnc2 -- mpirun --allow-run-as-root \
            --hostfile /etc/mpihostfile \
            --mca btl tcp,self \
            -n 8 -npernode 1 --bind-to core \
            /nfs/subflow/k8s/ring
        ;;
    hpl)
        kubectl -n $KUBE_NAMESPACE exec -it $MPI_CLUSTER_NAME-74c57d67d4-bqnc2 -- mpirun --allow-run-as-root \
            --hostfile /etc/mpihostfile \
            --mca btl tcp,self \
	    --display-map \
            -n 64 -npernode 8 --bind-to core:overload-allowed \
            sh -c 'cd /nfs/hpl-2.2/bin/k8s; ./xhpl > xhpl.out 2>&1'
        ;;
    helm)
        kubectl -n $KUBE_NAMESPACE exec -it $MPI_CLUSTER_NAME-master -- mpiexec --allow-run-as-root \
            --hostfile /kube-openmpi/generated/hostfile \
            --display-map -n 4 -npernode 1 \
            sh -c 'echo $(hostname):hello'

        kubectl -n $KUBE_NAMESPACE exec -it $MPI_CLUSTER_NAME-master -- mpiexec --allow-run-as-root \
            --hostfile /kube-openmpi/generated/hostfile \
            --display-map -n 4 -npernode 1 \
            sh -c 'cd /nfs/subflow/exe; LD_LIBRARY_PATH=/nfs/subflow/lib; export LD_LIBRARY_PATH; ./subflow -omp 16 -i AlkSalHrdCO214.sdb -g FrioTHMC20x20x8.grid -k FrioTHMC20x20x8 > OUTPUT/FrioTHMC20x20x8-AlkSalHrdCO214.out 2>&1'
        ;;
    std)
        # kubectl get pods -o wide -n sdsu
        # subflow-74c57d67d4-4gfmg
        kubectl -n $KUBE_NAMESPACE exec -it $MPI_CLUSTER_NAME-74c57d67d4-bqnc2 -- mpirun --allow-run-as-root \
            --hostfile /etc/ssh/shosts.equiv \
            --display-map -n 4 -npernode 1 \
            sh -c 'cd /nfs/subflow/exe; ./subflow -omp 16 -i AlkSalHrdCO214.sdb -g FrioTHMC20x20x08.grid -k FrioTHMC20x20x08 > OUTPUT/FrioTHMC20x20x08-AlkSalHrdCO214.out 2>&1'
        ;;
    demo)
	HEADNODE=$MPI_CLUSTER_NAME-74c57d67d4-bqnc2
	export HEADNODE
        kubectl -n $KUBE_NAMESPACE exec -it $HEADNODE -- mpirun --allow-run-as-root \
            --hostfile /etc/ssh/shosts.equiv \
            --display-map -n 8 -npernode 1 \
            sh -c 'cd /nfs/subflow/exe; GRID=FrioTHMC20x20x08; export GRID; ./subflow -omp 4 -i demo.sdb -g $GRID.grid -k $GRID > OUTPUT/$GRID-demo.out 2>&1'
        ;;
    demo-comet)
	KUBE_NAMESPACE=sdsu-comet
	export KUBE_NAMESPACE
	HEADNODE=$MPI_CLUSTER_NAME-comet-6788dc75d5-pgw78
	export HEADNODE
        kubectl -n $KUBE_NAMESPACE exec -it $HEADNODE -- mpirun --allow-run-as-root \
            --hostfile /etc/ssh/shosts.equiv \
            --display-map -n 4 -npernode 1 \
	    --mca btl tcp,self \
            sh -c 'cd /nfs/subflow/exe; GRID=FrioTHMC20x20x16; export GRID; ./subflow -omp 4 -i demo.sdb -g $GRID.grid -k $GRID > OUTPUT/$GRID-demo.out 2>&1'
        ;;
  esac
