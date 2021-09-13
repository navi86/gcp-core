This repo creates gcp common GCP infrastructure.
Resources that will be created during deploy:
1. GKE cluster for running common workloads
2. Jenkins server that has one declarative pipelins. Jenkins is configured JCasc approach and pipeline condigured using JDSL.
3. cloud storage bucket for state, iam sa, permissions ect that are required for insfrastructure