###################
# Conditions
###################
FROM quay.io/redhatinsights/insights-conditional-service-conditions:latest AS conditions

###################
# Builder
###################
FROM registry.redhat.io/rhel8/go-toolset:1.14 AS builder
WORKDIR $GOPATH/src/github.com/redhatinsights/insights-conditional-service

USER 0

COPY . .

RUN make build && \
    chmod a+x bin/insights-conditional-service


###################
# Service
###################
FROM registry.redhat.io/ubi8-minimal:latest

# copy the service
COPY --from=builder $GOPATH/src/github.com/redhatinsights/insights-conditional-service/config/config.toml /config/config.toml
COPY --from=builder $GOPATH/src/github.com/redhatinsights/insights-conditional-service/bin/insights-conditional-service .

# copy the conditions
COPY --from=conditions /conditions /conditions
# COPY /rules /conditions

USER 1001

CMD ["/insights-conditional-service"]