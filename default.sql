

DROP TABLE IF EXISTS kafka_simple_event_consumer;
DROP TABLE IF EXISTS kafka_simple_event_phys_table;
DROP TABLE IF EXISTS kafka_simple_event_mat_view;

CREATE TABLE kafka_simple_event_consumer
(
    uuid String,
    first_name String,
    last_name String,
    middle_name String,
    timestamp String
) ENGINE = Kafka SETTINGS
    kafka_broker_list = 'kafka',
    kafka_topic_list = 'my_topic',
    kafka_group_name = 'foo',
    kafka_format = 'JSON';

CREATE TABLE kafka_simple_event_phys_table
(
    uuid String,
    first_name String,
    last_name String,
    middle_name String,
    timestamp String
)
ENGINE = MergeTree()
ORDER BY (uuid);

CREATE MATERIALIZED VIEW kafka_simple_event_mat_view TO kafka_simple_event_phys_table
    AS SELECT * FROM kafka_simple_event_consumer;

SELECT * FROM kafka_simple_event_mat_view;



DROP TABLE IF EXISTS kafka_music_event_consumer;
DROP TABLE IF EXISTS kafka_music_event_phys_table;
DROP TABLE IF EXISTS kafka_music_event_mat_view;

CREATE TABLE kafka_music_event_consumer
(
    event_params String,
    event_timestamp_ms String
) ENGINE = Kafka SETTINGS
    kafka_broker_list = 'kafka',
    kafka_topic_list = 'music_events',
    kafka_group_name = 'foo',
    kafka_format = 'JSON';

CREATE TABLE kafka_music_event_phys_table
(
    event_params String,
    event_timestamp_ms String,
    uuid UUID DEFAULT generateUUIDv4()
)
ENGINE = MergeTree()
ORDER BY (uuid);

CREATE MATERIALIZED VIEW kafka_music_event_mat_view TO kafka_music_event_phys_table
    AS SELECT * FROM kafka_music_event_consumer;

SELECT * FROM kafka_music_event_mat_view;

SELECT *
FROM kafka_music_event_mat_view
WHERE 1=1
AND JSONExtractInt(event_params, 'event_type_id') = 1;



--Фильтрация по событиям воспроизведения треков:
SELECT 
    JSONExtractString(event_params, 'user_id') AS user_id,
    JSONExtractString(event_params, 'track_id') AS track_id,
    event_timestamp_ms
FROM kafka_music_event_mat_view
WHERE JSONExtractInt(event_params, 'event_type_id') = 1
ORDER BY event_timestamp_ms DESC
LIMIT 100;