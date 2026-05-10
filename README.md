# Camel Kafka Demo
How it works:
|Step|What happens|
|---|---|
|routes.yaml|Camel Main auto-discovers this file from the classpath — no code registration needed
|Kafka consumer|Polls xml-topic on localhost:9092, autoOffsetReset=earliest so messages sent before startup are still consumed
|XPath string(//message)|Extracts all text content from the XML body, discarding tags|
File writer|Writes plain text to ./output/message-<timestamp>.txt|

```bash
camel-kafka-demo/
├── pom.xml                                    ← build + fat-jar config
├── start-kafka-and-send.sh                    ← Docker + message trigger
└── src/main/
    ├── java/com/example/CamelApp.java         ← 5-line entry point
    └── resources/
        ├── application.properties             ← broker URL + output dir
        └── camel/routes.yaml                  ← ALL integration logic
```

```bash
# Terminal 1 — start Kafka and fire the test message
chmod +x start-kafka-and-send.sh
./start-kafka-and-send.sh

# Terminal 2 — build the fat-jar and start Camel
mvn package -q
java -jar target/camel-kafka-demo-1.0.0.jar
```

The processed text file appears in ./output/. You can override any property without touching the YAML by passing e.g. --kafka.brokers=broker:9092 or -Doutput.dir=/tmp/out at startup.
