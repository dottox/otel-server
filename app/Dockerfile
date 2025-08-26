FROM python:3.9-slim

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

COPY . .

EXPOSE 8082

ENV OTEL_PYTHON_LOG_LEVEL=DEBUG

# Importante instalar el auto-instrumentation antes de ejecutar la aplicación
RUN ["opentelemetry-bootstrap", "-a", "install"]

# Usar opentelemetry-instrument para ejecutar la aplicación con auto-instrumentación
# Python auto-instrument solo permite mediante el protocolo http/protobuf
CMD ["opentelemetry-instrument", \
    "--exporter_otlp_protocol", "http/protobuf", \
    "--traces_exporter", "otlp,console", \
    "--metrics_exporter", "otlp,console", \
    "--logs_exporter", "otlp,console", \
    "--exporter_otlp_endpoint", "http://simplest-collector.default.svc.cluster.local:4318", \
    "python", "server.py"]
