## Verifying Cluster State

```sql
    SELECT
        host_name,
        host_address,
        replica_num
    FROM system.clusters
    WHERE cluster = 'cluster_2s2r'
```

## Sample Data

```sql
    CREATE DATABASE dbx_local ON CLUSTER 'cluster_2s2r';
    CREATE DATABASE lab ON CLUSTER 'cluster_2s2r';

    -- local table
    CREATE TABLE dbx_local.events ON CLUSTER 'cluster_2s2r' (
        time DateTime,
        event_id  Int32,
        uuid UUID
    )
    ENGINE = ReplicatedMergeTree('/clickhouse/tables/{cluster}/{shard}/events_v01', '{replica}')
    PARTITION BY toYYYYMM(time)
    ORDER BY (event_id);

    -- distributed table view
    CREATE TABLE lab.events ON CLUSTER 'cluster_2s2r' AS dbx_local.events
    ENGINE = Distributed('cluster_2s2r', 'dbx_local', 'events', event_id);

    -- generate data
    INSERT INTO lab.events(time, event_id, uuid)
    SELECT toDateTime('2022-01-01 00:00:00') + (rand() % (toDateTime('2023-12-31 23:59:59') - toDateTime('2022-01-01 00:00:00'))) tim,
        (1 + rand() % 1000000) as event_id, 
        b FROM generateRandom('b UUID', 1, 10, 2) 
    LIMIT 1000;

    -- checks
    select count() from dbx_local.events;
    select count() from lab.events;
```

### Query all shards/replicas

```sql
SELECT * FROM
(
    SELECT hostName(), *
    FROM remote('clickhouse-blue-1', 'dbx_local', 'events')
    UNION ALL
    SELECT hostName(), *
    FROM remote('clickhouse-blue-2', 'dbx_local', 'events')
    UNION ALL
    SELECT hostName(), *
    FROM remote('clickhouse-green-1', 'dbx_local', 'events')
    UNION ALL
    SELECT hostName(), *
    FROM remote('clickhouse-green-2', 'dbx_local', 'events')
);
```