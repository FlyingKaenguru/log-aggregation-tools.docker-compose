# Purpose of the repository
In this repository we will use both Elastic Stack and Grafana Loki with the three different log collectors Promtail, Logstash and Fluentd. As visualization tools we use Kibana and Grafana.

![Grafana](https://img.shields.io/badge/grafana-ea6428.svg?style=for-the-badge&logo=grafana&logoColor=white)
![elasticsearch](https://img.shields.io/badge/Elastic_Search-005571?style=for-the-badge&logo=elasticsearch&logoColor=white)
![kibana](https://img.shields.io/badge/Kibana-005571?style=for-the-badge&logo=Kibana&logoColor=white)
![Fluentd](https://img.shields.io/badge/Fluentd-64a5d0?style=for-the-badge&logo=Fluentd&logoColor=white)
![Logstash](https://img.shields.io/badge/Logstash-64a5d0?style=for-the-badge&logo=Logstash&logoColor=white)
![Docker](https://img.shields.io/badge/Docker-2CA5E0?style=for-the-badge&logo=docker&logoColor=white)


# Log-Aggregation
## What Is Log Aggregation

Log aggregation is the process of collecting log events from different sources in an IT infrastructure and standardizing them to enable faster log analysis.
By using log collectors, the collected logs are stored in a central location, which is why the process is also called log centralization.
There are a variety of log aggregators on the market. They vary, of course, but are based on a similar architecture with logging clients and/or agents on each host
that forward messages to collectors, which in turn forward them to a central location.

## Log Aggregation Tools

* **Elastic Stack:**
  The Elastic Stack is one of the most well-known and widely used log aggregation tools.
  It is a set of monitoring tools and known as ELK or EFK Stack - Elasticsearch (object store), Logstash or FluentD (log routing and aggregation), and Kibana for visualization.

  Elasticsearch is a search engine built on Apache Lucene. Once the log data is collected, it is stored as unstructured JSON objects.
  Both the key of the JSON object and the contents of the key are indexed. Elasticsearch indexes all data in every field.


* **PLG Stack:**
  The PLG stack, which consists of Promtail, Loki, and Grafana, is mostly known as Grafana Loki.

  Grafana Loki is a horizontally scalable, highly available, multi-tenant log aggregation system inspired by Prometheus.
  Unlike other logging systems, a Loki index is built from labels, leaving the original log message unindexed. Loki stores all data in a single object storage backend like S3.
  The Loki project was startedd at Grafana Labs in 2018 and is released under the AGPLv3 license.
  For more information about Loki, its components and functionality, please read the latest  [documentation][1] or my blog post ["Logging on a large scale with Grafana Loki"][2].


## How to aggregate logs

Log collectors run on servers, pull server metrics, analyze all logs, and then transmit them to systems like Elasticsearch.
It is their routing mechanism that ultimately enables log analysis.
Some of the most popular log agents are:

* [Promtail][4] Promtail acquires logs, turns the logs into streams, and pushes the streams to Loki through an HTTP API.
  The Promtail agent is designed for Loki installations and therefore it is the default agent for Loki.

* [Fluentd:][5] Fluentd is a cross-platform open source data collection software originally developed at Treasure Data under the Apache 2 license.
  It is written primarily in the Ruby programming language.
  It has plugin-architecture and with more than 500 plugins, many developed by the community, Fluentd can connect to many data sources and outputs.
  Most of Fluentd's plugins are decentralized and are located in various Git repositories. A list of all plugins can be found on the [official Fluentd site][9].
  Fluentd provides an in-built buffering system that can be configured based on the needs.
  It uses built-in parsers (JSON, Regex, CSV, etc.) for log parsing by default. Routing is based on tags.

* [Logstash:][6] Logstash comes from the developers of the Elasticsearch search engine.
  It is a free and open server-side data processing pipeline that ingests data from a variety of sources, transforms it and sends it to the desired destination.
  Logstash is written in JRuby and therefore requires a Java runtime environment on the host machine.
  It has about 200 plugins. These are centralized, i.e. all plugins are located in a central [Git repository][10].
  Logstah does not support a built-in buffering system and is limited to an in-memory queue that can hold up to 20 events.
  It relies mainly on external queues such as Redis or Kafka for consistency here.
  Events are forwarded based on if-else conditions.

_Hint_

Docker provides a built-in fluentd logging driver.
The logging driver sends container logs as structured log data to the fluentd collector.
In the case of Logstash, an additional agent (filebeat) is required on the container to send logs to Logstash.

## Data visualization tools

Grafana and Kibana are two popular open source tools that help users visualize and understand trends within vast amounts of log data

* **Grafana:** Grafana is a visualizing tool which supports Loki as a data source

* **[Kibana:][8]** Kibana is the visualization engine for elasticsearch data, with features like time-series analysis, machine learning, graph and location analysis.

## Query Languages

* LogQL is the query language for Loki. It is inspired my PromQL (Prometheus query language) and uses log labels for filtering and selecting the log data.
* Elasticsearch uses Query DSL and Lucene query language which provides full-text search capability.

------------------------------------

# Grafana Loki Installation & Configuration Tutorial

## Deployment modes
There are three different ways to roll out Loki. To learn more about the different modes, please read the [official documentation][2].

* Monolithic mode
* Simple scalable deployment mode
* Microservices mode

In our use case, we run Loki as a monolith. This is the simplest mode of operation.
Here, all microservice components of Loki are run within a single process as a single binary or Docker image.

## Grafana Loki with Promtail rolled out with Docker Compose

<img src="image/Grafana_Loki.jpg" alt="Grafana Loki Promtail setup" width="200">

**Approach**
* Create the Config file for Loki and Promtail
* Create docker container for Loki, Promtail and Grafana using Docker compose
* Setup Loki as data source in Grafana
* Analyze the data that available in the Loki data source

**Required**
* Config-files for Loki and Promtail

### [Promtail Scraping (Service Discovery)][11]

Before Promtail can send log data to Loki, it needs information about its environment and the existing applications whose logs are to be transmitted. 
For this, Promtail makes use of a mechanism from Prometheus, service discovery. 
Just like Prometheus, Promtail is configured with a scrape_configs.



---

[1]: https://grafana.com/docs/loki/latest/
[2]: https://blog.mi.hdm-stuttgart.de/index.php/2022/03/13/logging-im-grosen-masstab-mit-grafana-loki/
[3]: https://grafana.com/docs/loki/latest/fundamentals/architecture/deployment-modes/
[4]: https://grafana.com/docs/loki/latest/clients/promtail/
[5]: https://www.fluentd.org/
[6]: https://www.elastic.co/de/logstash/
[7]: https://www.elastic.co/guide/en/kibana/master/kuery-query.html
[8]: https://www.elastic.co/guide/en/kibana/master/introduction.html
[9]: https://www.fluentd.org/plugins/all
[10]: https://github.com/logstash-plugins
[11]: https://grafana.com/docs/loki/latest/clients/promtail/scraping/

