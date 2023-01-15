-- truncate tables
/*
 TRUNCATE discord_data.fact_messages,
 discord_data.dim_channel,
 discord_data.dim_channel_type,
 discord_data.dim_server;
 */
-- create temp tables
CREATE TEMP TABLE fact_messages_temp (
    message_id bigint UNIQUE NOT NULL,
    message_timestamp timestamp WITH time zone NOT NULL,
    contents text,
    attachment_link text,
    channel_id bigint NOT NULL,
    PRIMARY KEY (message_id)
);

CREATE TEMP TABLE dim_channel_temp (
    channel_id bigint UNIQUE NOT NULL,
    channel_name text,
    channel_type_key int NOT NULL,
    server_id bigint,
    PRIMARY KEY (channel_id)
);

CREATE TEMP TABLE dim_server_temp (
    server_id bigint UNIQUE NOT NULL,
    server_name text,
    PRIMARY KEY (server_id)
);

CREATE TEMP TABLE dim_channel_type_temp (
    channel_type_key int UNIQUE NOT NULL,
    channel_type text,
    PRIMARY KEY (channel_type_key)
);

-- update tables
COPY dim_channel_type_temp
FROM
    'C:\Users\Dante\Desktop\Projects\discord-analysis\dim_channel_type.csv' DELIMITER ',' CSV HEADER;

INSERT INTO
    discord_data.dim_channel_type
SELECT
    dctt.*
FROM
    dim_channel_type_temp dctt
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            discord_data.dim_channel_type dct
        WHERE
            dct.channel_type_key = dctt.channel_type_key
    );

COPY dim_server_temp (server_id, server_name)
FROM
    'C:\Users\Dante\Desktop\Projects\discord-analysis\dim_server.csv' DELIMITER ',' CSV HEADER;

INSERT INTO
    discord_data.dim_server
SELECT
    dst.*
FROM
    dim_server_temp dst
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            discord_data.dim_server ds
        WHERE
            ds.server_id = dst.server_id
    );

COPY dim_channel_temp (
    channel_id,
    channel_name,
    channel_type_key,
    server_id
)
FROM
    'C:\Users\Dante\Desktop\Projects\discord-analysis\dim_channel.csv' DELIMITER ',' CSV HEADER;

INSERT INTO
    discord_data.dim_channel
SELECT
    dct.*
FROM
    dim_channel_temp dct
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            discord_data.dim_channel dc
        WHERE
            dc.channel_id = dct.channel_id
    );

COPY fact_messages_temp (
    message_id,
    message_timestamp,
    contents,
    attachment_link,
    channel_id
)
FROM
    'C:\Users\Dante\Desktop\Projects\discord-analysis\fact_messages.csv' DELIMITER ',' CSV HEADER;

INSERT INTO
    discord_data.fact_messages
SELECT
    fmt.*
FROM
    fact_messages_temp fmt
WHERE
    NOT EXISTS (
        SELECT
            1
        FROM
            discord_data.fact_messages fm
        WHERE
            fm.message_id = fmt.message_id
    );

-- drop tables
DROP TABLE fact_messages_temp;

DROP TABLE dim_channel_temp;

DROP TABLE dim_channel_type_temp;

DROP TABLE dim_server_temp;