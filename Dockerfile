# Imagen base de Python (puedes cambiar la versión si necesitas)
FROM python:3.9-slim

# Establecer el directorio de trabajo
WORKDIR /app

# Copiar requirements primero (para aprovechar cache en builds)
COPY requirements.txt .

# Instalar dependencias
RUN pip install --no-cache-dir -r requirements.txt

# Copiar el resto de los archivos de la aplicación
COPY . .

# Exponer el puerto (ajusta si tu server_automatic.py usa otro)
EXPOSE 8082

ENV OTEL_PYTHON_LOG_LEVEL=DEBUG

# Comando de arranque con OpenTelemetry instrumentation
CMD ["opentelemetry-instrument", \
    "--exporter_otlp_protocol", "http/protobuf", \
    "--traces_exporter", "otlp", \
    "--metrics_exporter", "otlp", \
    "--logs_exporter", "otlp", \
    "--exporter_otlp_endpoint", "http://simplest-collector.default.svc.cluster.local:4318", \
    "python", "server.py"]