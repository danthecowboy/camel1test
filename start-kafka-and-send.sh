#!/usr/bin/env bash
# ─────────────────────────────────────────────────────────────
#  start-kafka-and-send.sh
#
#  1. Starts a single-node Kafka broker (KRaft, no Zookeeper)
#     using the official apache/kafka image
#  2. Creates the topic "xml-topic"
#  3. Sends a sample XML message
#  4. Prints instructions to run the Camel app
#
#  Requirements: Docker
# ─────────────────────────────────────────────────────────────
set -euo pipefail

CONTAINER="kafka-camel-demo"
TOPIC="xml-topic"
IMAGE="apache/kafka:3.9.2"
KAFKA_BIN="/opt/kafka/bin"

# ── 1. Start Kafka ────────────────────────────────────────────
echo "▶ Starting Kafka container..."

docker rm -f "$CONTAINER" 2>/dev/null || true

docker run -d \
  --name "$CONTAINER" \
  -p 9092:9092 \
  -e KAFKA_NODE_ID=1 \
  -e KAFKA_PROCESS_ROLES=broker,controller \
  -e KAFKA_LISTENERS=PLAINTEXT://:9092,CONTROLLER://:9093 \
  -e KAFKA_ADVERTISED_LISTENERS=PLAINTEXT://localhost:9092 \
  -e KAFKA_LISTENER_SECURITY_PROTOCOL_MAP=CONTROLLER:PLAINTEXT,PLAINTEXT:PLAINTEXT \
  -e KAFKA_CONTROLLER_QUORUM_VOTERS=1@localhost:9093 \
  -e KAFKA_CONTROLLER_LISTENER_NAMES=CONTROLLER \
  -e KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR=1 \
  -e KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR=1 \
  -e KAFKA_TRANSACTION_STATE_LOG_MIN_ISR=1 \
  -e KAFKA_LOG_DIRS=/tmp/kraft-combined-logs \
  -e CLUSTER_ID=5L6g3nShT-eMCtK--X86sw \
  "$IMAGE"

# ── 2. Wait until Kafka is ready ──────────────────────────────
echo -n "⏳ Waiting for Kafka to be ready"
until docker exec "$CONTAINER" \
        "$KAFKA_BIN/kafka-topics.sh" --bootstrap-server localhost:9092 --list &>/dev/null; do
  echo -n "."
  sleep 2
done
echo " ready!"

# ── 3. Create topic ───────────────────────────────────────────
echo "▶ Creating topic '${TOPIC}'..."
docker exec "$CONTAINER" "$KAFKA_BIN/kafka-topics.sh" \
  --bootstrap-server localhost:9092 \
  --create \
  --topic "$TOPIC" \
  --partitions 1 \
  --replication-factor 1 \
  --if-not-exists

# ── 4. Send XML message ───────────────────────────────────────
XML_MESSAGE='<?xml version="1.0" encoding="UTF-8"?><message><content>Hello from Apache Camel via Kafka!</content><timestamp>2026-05-10</timestamp></message>'

echo "▶ Sending XML message to topic '${TOPIC}'..."
echo "$XML_MESSAGE" | docker exec -i "$CONTAINER" \
  "$KAFKA_BIN/kafka-console-producer.sh" \
  --bootstrap-server localhost:9092 \
  --topic "$TOPIC"

echo ""
echo "✅ Message sent!"
echo ""
echo "─────────────────────────────────────────────────────────"
echo " Now start the Camel app in another terminal:"
echo ""
echo "   mvn package -q"
echo "   java -jar target/camel-kafka-demo-1.0.0.jar"
echo ""
echo " Processed text files will appear in: ./output/"
echo "─────────────────────────────────────────────────────────"
