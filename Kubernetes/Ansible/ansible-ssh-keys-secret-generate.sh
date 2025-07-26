# Generate SSH key pair
ssh-keygen -t rsa -b 4096 -f ansible-key -N ""

# Create secret
kubectl create secret generic ansible-ssh-keys \
  --from-file=id_rsa=ansible-key \
  --from-file=id_rsa.pub=ansible-key.pub \
  -n devops