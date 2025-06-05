# Observability Setup for BanaDoctor

This directory contains the configuration for the observability stack of the BanaDoctor application, including Prometheus, Grafana, Sentry, and the ELK stack (Elasticsearch, Logstash, Kibana).

## Table of Contents

1. [Prometheus](#prometheus)
2. [Grafana](#grafana)
3. [Sentry](#sentry)
4. [ELK Stack](#elk-stack)
5. [Setup Instructions](#setup-instructions)
6. [Usage](#usage)

## Prometheus

Prometheus is used for metrics collection and monitoring.

- **Configuration**: `prometheus/prometheus.yml`
- **Deployment**: `prometheus/prometheus-deployment.yaml`

## Grafana

Grafana is used for visualizing metrics collected by Prometheus.

- **Configuration**: `grafana/grafana-deployment.yaml`
- **Pre-configured Dashboards**:
  - Django Application Metrics
  - Kubernetes Cluster Metrics
  - Node Exporter Metrics

## Sentry

Sentry is used for error tracking and performance monitoring.

- **Django Integration**: `sentry/sentry-django.py`
- **Flutter Integration**: `sentry/sentry-flutter.md`

## ELK Stack

The ELK stack (Elasticsearch, Logstash, Kibana) is used for log aggregation and analysis.

- **Docker Compose**: `elastic-kibana/docker-compose.yml`
- **Filebeat Configuration**: `elastic-kibana/filebeat.yml`

## Setup Instructions

### Prerequisites

- Docker and Docker Compose
- Kubernetes cluster (for production deployment)
- kubectl configured to communicate with your cluster

### Local Development Setup

1. **Start ELK Stack**:
   ```bash
   cd observability/elastic-kibana
   docker-compose up -d
   ```

2. **Deploy to Kubernetes (Production)**:
   ```bash
   # Deploy Prometheus
   kubectl apply -f prometheus/prometheus-deployment.yaml
   
   # Deploy Grafana
   kubectl apply -f grafana/grafana-deployment.yaml
   
   # Deploy Filebeat
   kubectl create configmap filebeat-config --from-file=elastic-kibana/filebeat.yml
   kubectl apply -f elastic-kibana/filebeat-daemonset.yaml  # Create this file based on your needs
   ```

3. **Configure Django for Sentry**:
   Add to your Django settings:
   ```python
   from .sentry import init_sentry
   
   SENTRY_DSN = os.environ.get('SENTRY_DSN')
   if SENTRY_DSN:
       init_sentry(SENTRY_DSN, environment=os.environ.get('ENVIRONMENT', 'development'))
   ```

4. **Configure Flutter for Sentry**:
   Follow the instructions in `sentry/sentry-flutter.md`

## Usage

### Accessing the Dashboards

- **Grafana**: http://localhost:30300 (default credentials: admin/admin123)
- **Kibana**: http://localhost:5601
- **Prometheus**: http://localhost:30090

### Adding Custom Dashboards

1. **Grafana**:
   - Log in to Grafana
   - Navigate to Dashboards > Manage
   - Click "Import" and upload your dashboard JSON

2. **Kibana**:
   - Log in to Kibana
   - Navigate to Stack Management > Index Patterns
   - Create index patterns for your logs (e.g., `filebeat-*`)
   - Go to Discover to explore logs

### Monitoring Custom Metrics

To add custom metrics in Django:

```python
from prometheus_client import Counter, Histogram

# Define your metrics
REQUESTS = Counter('django_http_requests_total', 'Total HTTP requests', ['method', 'endpoint', 'status'])
REQUEST_LATENCY = Histogram('django_http_request_duration_seconds', 'Request latency in seconds', ['endpoint'])

# Use in your views
@REQUEST_LATENCY.time()
def my_view(request):
    REQUESTS.labels(method=request.method, endpoint=request.path, status=200).inc()
    # Your view logic
```

### Alerting

Configure alerts in Grafana or use Prometheus Alertmanager for more complex alerting rules.

## Troubleshooting

- **Prometheus not scraping targets**:
  - Check service discovery configuration
  - Verify that pods have the correct annotations:
    ```yaml
    annotations:
      prometheus.io/scrape: "true"
      prometheus.io/port: "8000"
    ```

- **No logs in Kibana**:
  - Check if Filebeat is running: `docker logs filebeat`
  - Verify Elasticsearch is healthy: `curl http://localhost:9200/_cluster/health`
  - Check Kibana index patterns

- **Sentry not capturing errors**:
  - Verify DSN is correctly set in environment variables
  - Check network connectivity to Sentry
  - Enable debug logging if needed

## Security Considerations

- Always secure your monitoring endpoints in production
- Use proper authentication for Grafana and Kibana
- Rotate credentials and API keys regularly
- Limit access to monitoring tools to authorized personnel only

## License

This configuration is provided as-is under the MIT License.
