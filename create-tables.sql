CREATE SCHEMA IF NOT EXISTS discord_data;

SET
    search_path TO discord_data;

-- create tables
CREATE TABLE IF NOT EXISTS fact_messages (
    message_id bigint UNIQUE NOT NULL,
    message_timestamp timestamp with time zone NOT NULL,
    contents text,
    attachment_link text,
    channel_id bigint NOT NULL,
    PRIMARY KEY (message_id)
);

CREATE TABLE IF NOT EXISTS dim_channel (
    channel_id bigint UNIQUE NOT NULL,
    channel_name text,
    channel_type_key int NOT NULL,
    server_id bigint,
    PRIMARY KEY (channel_id)
);

CREATE TABLE IF NOT EXISTS dim_server (
    server_id bigint UNIQUE NOT NULL,
    server_name text,
    PRIMARY KEY (server_id)
);

CREATE TABLE IF NOT EXISTS dim_channel_type (
    channel_type_key int UNIQUE NOT NULL,
    channel_type text,
    PRIMARY KEY (channel_type_key)
);

-- add foreign key references
ALTER TABLE
    fact_messages
ADD
    FOREIGN KEY (channel_id) REFERENCES dim_channel (channel_id);

ALTER TABLE
    dim_channel
ADD
    FOREIGN KEY (channel_type_key) REFERENCES dim_channel_type (channel_type_key);

ALTER TABLE
    dim_channel
ADD
    FOREIGN KEY (server_id) REFERENCES dim_server (server_id);

-- import data from csv
COPY dim_channel_type(channel_type_key, channel_type)
FROM
    'C:\Users\Dante\Desktop\Projects\discord-analysis\dim_channel_type.csv' DELIMITER ',' CSV HEADER;

COPY dim_server(server_id, server_name)
FROM
    'C:\Users\Dante\Desktop\Projects\discord-analysis\dim_server.csv' DELIMITER ',' CSV HEADER;

COPY dim_channel(
    channel_id,
    channel_name,
    channel_type_key,
    server_id
)
FROM
    'C:\Users\Dante\Desktop\Projects\discord-analysis\dim_channel.csv' DELIMITER ',' CSV HEADER;

COPY fact_messages(
    message_id,
    message_timestamp,
    contents,
    attachment_link,
    channel_id
)
FROM
    'C:\Users\Dante\Desktop\Projects\discord-analysis\fact_messages.csv' DELIMITER ',' CSV HEADER;