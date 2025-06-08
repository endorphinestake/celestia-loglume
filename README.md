
📡 Celestia LogLume — Production Monitoring Stack

🔍 Overview

LogLume is a production-ready solution for logging and monitoring a Celestia node, based on the Elasticsearch + Filebeat + Kibana stack, featuring secure API access, TLS, and Index Lifecycle Management (ILM).

🧩 Stack

- Celestia Node — generates logs
- Filebeat — collects and ships logs
- Elasticsearch — stores and indexes logs
- Kibana — visualizes log data
- NGINX — TLS reverse proxy (optional)

⚙️ Component Configuration

### 🔸 Elasticsearch

File: `/etc/elasticsearch/elasticsearch.yml`

```
node.name: "celestia-loglume"
network.host: 0.0.0.0
discovery.type: single-node
```

Restart:

```bash
sudo systemctl restart elasticsearch
sudo systemctl status elasticsearch
```

Health check:

```bash
curl -X GET "http://localhost:9200/_cluster/health?pretty"
```

### 🔸 Kibana

File: `/etc/kibana/kibana.yml`

```
server.host: "0.0.0.0"
elasticsearch.hosts: ["http://localhost:9200"]
elasticsearch.ssl.verificationMode: none

elasticsearch.serviceAccountToken: "PASTE_YOUR_API_KEY_HERE"

xpack.security.enabled: true
xpack.security.authc.api_key.enabled: true

logging:
  appenders:
    file:
      type: file
      fileName: /var/log/kibana/kibana.log
      layout:
        type: json
  root:
    appenders:
      - default
      - file
```

Access:
Open your browser: `http://<your_server_ip>:5601`

🔐 Security and TLS

### API Key

Generate an API key in Kibana:  
**Stack Management → Security → API Keys**

### TLS (recommended)

Elasticsearch:

```
xpack.security.http.ssl:
  enabled: true
  key: /etc/elasticsearch/certs/privkey.pem
  certificate: /etc/elasticsearch/certs/fullchain.pem
  certificate_authorities: ["/etc/elasticsearch/certs/ca.pem"]
```

Kibana:

```
elasticsearch.ssl.certificateAuthorities: ["/etc/kibana/certs/ca.pem"]
```

🌀 ILM (Index Lifecycle Management)

Create policy:

```bash
PUT _ilm/policy/log_policy
{
  "policy": {
    "phases": {
      "hot": {
        "actions": {
          "rollover": {
            "max_size": "5gb",
            "max_age": "7d"
          }
        }
      },
      "delete": {
        "min_age": "30d",
        "actions": {
          "delete": {}
        }
      }
    }
  }
}
```

Attach to template:

```bash
PUT _index_template/celestia_template
{
  "index_patterns": ["celestia-*"],
  "template": {
    "settings": {
      "index.lifecycle.name": "log_policy",
      "index.lifecycle.rollover_alias": "celestia"
    }
  }
}
```

📊 Creating a Dashboard

1. Log in to Kibana
2. Go to Discover → select index `filebeat-*` or `celestia-*`
3. Create Index Pattern
4. Build visualizations, filters, and alerts in Explore

📎 Log Storage

Log file path:  
`/var/log/celestia.log`

Example launch with logging:

```bash
nohup celestia start > /var/log/celestia.log 2>&1 &
```

🧪 API Key Test via curl

```bash
curl -X GET "http://localhost:9200/" -H "Authorization: ApiKey <BASE64_ENCODED_API_KEY>"
```

🔔 Monitoring and Alerts

```bash
sudo apt install metricbeat
sudo metricbeat setup
sudo systemctl start metricbeat
```

After that:
- Metrics dashboard appears in Kibana
- Set alerts via: Stack Management → Rules and Connectors

💬 Telegram/Slack Integration

- Slack via webhook URL
- Telegram via Bot API (you'll need bot token and chat_id)

In Kibana:  
**Stack Management → Rules and Connectors → Create connector**

🧰 Troubleshooting

🟥 Kibana won’t start

- Check `kibana.yml` syntax
- View logs:  
  `cat /var/log/kibana/kibana.log | jq`
- Check TLS certs if enabled

🟥 TLS not working

- Check file permissions on `.pem` files
- Validate cert:
  `openssl x509 -in fullchain.pem -text -noout`
