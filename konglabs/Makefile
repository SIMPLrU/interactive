KONG_BUILD_TOOLS?=2.0.3
KONG_TEST_DATABASE?=postgres

setup-kong-build-tools:
        -rm -rf kong-build-tools; \
        git clone https://github.com/Kong/kong-build-tools.git; fi
        cd kong-build-tools; \
        git reset --hard ${KONG_BUILD_TOOLS}; \

run_cleanup_all:
-kubectl -n kong delete -f kong-dbless.yaml
-kubectl -n kong delete configmap kongdeclarative
kubectl delete -f kong-namespace.yaml

for ns in $(kubectl get ns --output=jsonpath={.items[*].metadata.name}); do kubectl delete ns/$ns; done;
kubectl delete service echo -n default
kubectl delete service httpbin -n default
kubectl delete service httpbin-2 -n default