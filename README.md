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
  It is usually deployed to every machine that has applications needed to be monitored.
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
* Create docker container for Loki, Promtail and Grafana using Docker compose
* Create a config file for Promtail
* Setup Loki as data source in Grafana
* Analyze the data that available in the Loki data source

### Docker-Compose File

The [docker-compose.yml](loki-promtail-example/docker-compose.yml) file defines the individual services (Loki, Promtail and Grafana).
This includes, for example, the image to be used, the ports to be exposed, and volumes needed to be mounted.
The Docker socket, which is needed to witness Docker events, is mounted in the Promtail service under volume.
Since we have a filter built into the Promtail config (see next section), which is configured to only collect containers with the Docker label "logging=promtail" for logging and send them to Grafana Loki,
this label must be defined in the individual services.
The label "job" can later be used to distinguish between "management" and "app" applications.

```yml
    labels:
      logging: "promtail"
      job: "management"
```

### Config-files for Promtail

Before Promtail can send log data to Loki, it needs information about its environment and the existing applications whose logs are to be transmitted.
To do this, Promtail uses a mechanism from Prometheus called service discovery.
Just like Prometheus, Promtail is configured with a scrape_configs. 
Scrape_configs contains one or more entries that are executed for each discovered target.
In Promtail, there are several types of labels. For example, there are "meta-labels", but also "__path__" labels - which Promtail uses after detection to find out where the file to be read is located.

The metadata (container_name, file name, etc.) determined during service detection, which can be appended to the log line as a label for easier identification when querying logs in Loki,
can be converted to a desired form using the relabel_configs.
For this purpose, each entry in the scrape_configs can also contain a relabel_configs. 
Relabel_configs are a set of operations that can be used, for example, to change a label to a different target name.
They allow fine-grained control over what to include and what to discard, as well as over the final metadata to append to the log line (see official [documentation][11]).

In our promtail configuration [promtail-config.yaml](loki-promtail-example/promtail/config/promtail-config.yaml),
the container logs are collected through the Docker socket and then filtered so that only Docker containers with the Docker labels "logging=promtail" are collected.
Once the logs are collected, the existing meta labels are transformed using relabel_config. 
This gives us the container name as well as logstream and logging job.

```yml
scrape_configs:
  - job_name: container_scrape
    docker_sd_configs:
      - host: unix:///var/run/docker.sock
        refresh_interval: 5s
        filters:
          - name: label
            values: ["logging=promtail"]
    relabel_configs:
      - source_labels: ['__meta_docker_container_name']
        regex: '/(.*)'
        target_label: 'container'
      - source_labels: ['__meta_docker_container_log_stream']
        target_label: 'logstream'
      - source_labels: ['__meta_docker_container_label_job']
        target_label: 'job'
```

To allow more sophisticated filtering afterwards, Promtail allows labels to be set not only from service discovery, 
but also based on the content of individual log lines.
The pipeline_stages can be used to add or update labels, correct the timestamp or completely rewrite log lines. 
A pipeline is comprised of a set of 4 stages (see official [documentation][12]).
* Parsing stages (Parse the current log line and extract data out of it.)
* Transform stages (Transform extracted data from previous stages)
* Action stages (Take extracted data from previous stages and do something with them)
* Filtering stages (optionally apply a subset of stages or drop entries based on some condition)

### Setup Loki as data source in Grafana

So that we do not have to manually configure Loki in Grafana later, 
we can give the Grafana service a [datasource configuration](./loki-promtail-example/grafana/provisioning/datasources/loki.yml). 
When starting the service, Grafana automatically connects to Loki.


```yml
apiVersion: 1

datasources:
  - name: Loki
    type: loki
    url: http://loki:3100
    isDefault: true
```

### Analyze the data that is available in the Loki data source

Once you have everything prepared, you can start the services.

``docker-compose up -d``

Then navigate to grafana at http://localhost:3000 and select "explore" on the left. 
Select Loki as the database and select the container you are interested in. 
Run the query and you will see the logs at the bottom.

<img src="image/loki-explore.jpg" width="600">

The data can also be viewed in the dashboard provided. 
The configuration as well as the dashboard for this can be found in the folder [Dashboards](./loki-promtail-example/grafana/provisioning/dashboards/). To display the dashboard in Grafana, 
open the Dashboards tab on the left and select the "Promtail" dashboard.

#### Read in data from a test app
In the app-promtail folder you will find another [Docker-compose](loki-promtail-example/app/nginx-example.yaml) file. 
This creates an nginx app. As already in the Management Services, the Promtail labels are assigned here as well. 
Since this is an application outside the management level, we enter "App" for the job. 
This helps us to distinguish the applications later.

````yml
services:
  nginx-app:
    container_name: nginx-app
    image: nginx
    labels:
      logging: "promtail"
      job: "app"
    ports:
      - 8080:80
````
Start with:
``docker-compose -f nginx-example.yaml up -d``

The Apache HTTP server benchmarking tool "[ApacheBench][13]" can be used to generate an arbitrary number of queries.

ApacheBench is a command line tool included in the apache2-utils package. In addition to the number of queries to send, a timeout limit can be configured for the query header. ab sends the queries, waits for a response (until a user-specified timeout), and prints statistics as a report.

The following command, should generate 100 logs in the nginx-app container in the stderr stream.

````ab -n 100 -c 100 http://{Server}:8080/errortest````

<img src="image/nginx-error-dashboard.jpg" width="600">
After the command is executed, 100 entries are visible in the stderr stream in the dashboard.

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
[12]: https://grafana.com/docs/loki/latest/clients/promtail/pipelines/
[13]: https://httpd.apache.org/docs/current/programs/ab.html

