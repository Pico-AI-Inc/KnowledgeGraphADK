:param {
  // Define the file path root and the individual file names required for loading.
  // https://neo4j.com/docs/operations-manual/current/configuration/file-locations/
  file_path_root: 'file:///', // Change this to the folder your script can access the files at.
  file_0: 'equipment.csv',
  file_1: 'room_areas.csv',
  file_2: 'measurements.csv',
  file_3: 'parts.csv',
  file_4: 'part_specifications.csv',
  file_5: 'alarms.csv',
  file_6: 'asset_classes.csv',
  file_7: 'preventative_maintenance_routines.csv',
  file_8: 'storage_locations.csv',
  file_9: 'vendors.csv',
  file_10: 'work_orders.csv',
  file_11: 'hvacmodes.csv',
  file_12: 'measurement_equipment_mapping.csv'
};

// CONSTRAINT creation
// -------------------
//
// Create node uniqueness constraints, ensuring no duplicates for the given node label and ID property exist in the database. This also ensures no duplicates are introduced in future.
//
// NOTE: The following constraint creation syntax is generated based on the current connected database version 2025.5.0.
CREATE CONSTRAINT `id_Equipment_uniq` IF NOT EXISTS
FOR (n: `Equipment`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_Room_uniq` IF NOT EXISTS
FOR (n: `Room`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_Measurement_uniq` IF NOT EXISTS
FOR (n: `Measurement`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_Part_uniq` IF NOT EXISTS
FOR (n: `Part`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_SPECIFICATION_uniq` IF NOT EXISTS
FOR (n: `Specification`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_Alarm_uniq` IF NOT EXISTS
FOR (n: `Alarm`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_Asset_Class_uniq` IF NOT EXISTS
FOR (n: `Asset Class`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_Maintenance_Routine_uniq` IF NOT EXISTS
FOR (n: `Maintenance Routine`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_Storage_Location_uniq` IF NOT EXISTS
FOR (n: `Storage Location`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_Vendor_uniq` IF NOT EXISTS
FOR (n: `Vendor`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `id_Work_Order_uniq` IF NOT EXISTS
FOR (n: `Work Order`)
REQUIRE (n.`id`) IS UNIQUE;
CREATE CONSTRAINT `network_point_Network_Point_uniq` IF NOT EXISTS
FOR (n: `Network Point`)
REQUIRE (n.`network_point`) IS UNIQUE;
CREATE CONSTRAINT `present_system mode_Mode_Name_uniq` IF NOT EXISTS
FOR (n: `Mode Name`)
REQUIRE (n.`present system mode`) IS UNIQUE;

:param {
  idsToSkip: []
};

// NODE load
// ---------
//
// Load nodes in batches, one node label at a time. Nodes will be created using a MERGE statement to ensure a node with the same label and ID property remains unique. Pre-existing nodes found by a MERGE statement will have their other properties set to the latest values encountered in a load file.
//
// NOTE: Any nodes with IDs in the 'idsToSkip' list parameter will not be loaded.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Equipment` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`manufacturer` = row.`manufacturer`
  SET n.`model` = row.`model`
  SET n.`name` = row.`name`
  SET n.`year_installed` = toInteger(trim(row.`year_installed`))
  SET n.`repair_and_maintenance_cost` = row.`repair_and_maintenance_cost`
  SET n.`lifespan` = toInteger(trim(row.`lifespan`))
  SET n.`replacement_cost` = toInteger(trim(row.`replacement_cost`))
  SET n.`efficiency` = toInteger(trim(row.`efficiency`))
  SET n.`drawing_location` = row.`drawing_location`
  SET n.`asset_class_id` = row.`asset_class_id`
  SET n.`unique_identifier` = row.`unique_identifier`
  SET n.`manual_location` = row.`manual_location`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_1) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Room` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`name` = row.`name`
  SET n.`profile_id` = row.`profile_id`
  SET n.`category` = row.`category`
  SET n.`floor` = toInteger(trim(row.`floor`))
  SET n.`type` = row.`type`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Measurement` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`value` = row.`value`
  SET n.`error` = row.`error`
  // Your script contains the datetime datatype. Our app attempts to convert dates to ISO 8601 date format before passing them to the Cypher function.
  // This conversion cannot be done in a Cypher script load. Please ensure that your CSV file columns are in ISO 8601 date format to ensure equivalent loads.
  SET n.`recorded_time` = datetime(row.`recorded_time`)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_3) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Part` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`name` = row.`name`
  SET n.`quantity` = row.`quantity`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_4) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Specification` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`name` = row.`name`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_5) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Alarm` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`message` = row.`message`
  SET n.`active` = toLower(trim(row.`active`)) IN ['1','true','yes']
  // Your script contains the datetime datatype. Our app attempts to convert dates to ISO 8601 date format before passing them to the Cypher function.
  // This conversion cannot be done in a Cypher script load. Please ensure that your CSV file columns are in ISO 8601 date format to ensure equivalent loads.
  SET n.`recorded_time` = datetime(row.`recorded_time`)
  SET n.`status` = row.`status`
  SET n.`type` = row.`type`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_6) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Asset Class` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`name` = row.`name`
  SET n.`parent_id` = row.`parent_id`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_7) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Maintenance Routine` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`issue_type` = row.`issue_type`
  SET n.`issue_description` = row.`issue_description`
  SET n.`category` = row.`category`
  SET n.`recurrence` = row.`recurrence`
  SET n.`status` = row.`status`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_8) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Storage Location` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`floor` = toInteger(trim(row.`floor`))
  SET n.`location` = row.`location`
  SET n.`department` = row.`department`
  SET n.`content` = row.`content`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_9) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Vendor` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`name` = row.`name`
  SET n.`phone_numbers` = row.`phone_numbers`
  SET n.`emails` = row.`emails`
  SET n.`service_provided` = row.`service_provided`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_10) AS row
WITH row
WHERE NOT row.`id` IN $idsToSkip AND NOT row.`id` IS NULL
CALL {
  WITH row
  MERGE (n: `Work Order` { `id`: row.`id` })
  SET n.`id` = row.`id`
  SET n.`status` = row.`status`
  SET n.`order_number` = toInteger(trim(row.`order_number`))
  SET n.`type` = row.`type`
  SET n.`description` = row.`description`
  SET n.`priority` = row.`priority`
  SET n.`requestor` = row.`requestor`
  SET n.`assigned_to` = row.`assigned_to`
  SET n.`team` = row.`team`
  SET n.`guest` = row.`guest`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row
WHERE NOT row.`network_point` IN $idsToSkip AND NOT row.`network_point` IS NULL
CALL {
  WITH row
  MERGE (n: `Network Point` { `network_point`: row.`network_point` })
  SET n.`network_point` = row.`network_point`
  SET n.`control_program` = row.`control_program`
  SET n.`unique_identifier` = row.`unique_identifier`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_11) AS row
WITH row
WHERE NOT row.`present system mode` IN $idsToSkip AND NOT toInteger(trim(row.`present system mode`)) IS NULL
CALL {
  WITH row
  MERGE (n: `Mode Name` { `present system mode`: toInteger(trim(row.`present system mode`)) })
  SET n.`present system mode` = toInteger(trim(row.`present system mode`))
  SET n.`mode` = row.`mode`
} IN TRANSACTIONS OF 10000 ROWS;


// RELATIONSHIP load
// -----------------
//
// Load relationships in batches, one relationship type at a time. Relationships are created using a MERGE statement, meaning only one relationship of a given type will ever be created between a pair of nodes.
LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Equipment` { `id`: row.`id` })
  MATCH (target: `Room` { `id`: row.`room_area_id` })
  MERGE (source)-[r: `LOCATEDIN`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_12) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Equipment` { `id`: row.`equipment_id` })
  MATCH (target: `Measurement` { `id`: row.`measurement_id` })
  MERGE (source)-[r: `HASMEASUREMENT`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_3) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Equipment` { `id`: row.`equipment_id` })
  MATCH (target: `Part` { `id`: row.`id` })
  MERGE (source)-[r: `HASPART`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_4) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Part` { `id`: row.`part_id` })
  MATCH (target: `Specification` { `id`: row.`id` })
  MERGE (source)-[r: `HASSPECIFICATION`]->(target)
  SET r.`value` = row.`value`
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_5) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Equipment` { `id`: row.`equipment_id` })
  MATCH (target: `Alarm` { `id`: row.`id` })
  MERGE (source)-[r: `HASALARM`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_0) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Equipment` { `id`: row.`id` })
  MATCH (target: `Asset Class` { `id`: row.`asset_class_id` })
  MERGE (source)-[r: `PARTOF`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_6) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Asset Class` { `id`: row.`id` })
  MATCH (target: `Asset Class` { `id`: row.`parent_id` })
  MERGE (source)-[r: `HASPARENTCLASS`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_7) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Equipment` { `id`: row.`equipment_id` })
  MATCH (target: `Maintenance Routine` { `id`: row.`id` })
  MERGE (source)-[r: `HASROUTINE`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_7) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Room` { `id`: row.`room_area_id` })
  MATCH (target: `Maintenance Routine` { `id`: row.`id` })
  MERGE (source)-[r: `HASROUTINE`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_10) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Equipment` { `id`: row.`equipment_id` })
  MATCH (target: `Work Order` { `id`: row.`id` })
  MERGE (source)-[r: `HASORDER`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row 
CALL {
  WITH row
  MATCH (source: `Network Point` { `network_point`: row.`network_point` })
  MATCH (target: `Measurement` { `id`: row.`id` })
  MERGE (source)-[r: `HASMEASUREMENT`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;

LOAD CSV WITH HEADERS FROM ($file_path_root + $file_2) AS row
WITH row 
WHERE row.`network_point` = 'Present System Mode'
CALL {
  WITH row
  MATCH (source: `Measurement` { `id`: row.`id` })
  MATCH (target: `Mode Name` { `present system mode`: toInteger(trim(row.`value`)) })
  MERGE (source)-[r: `HASNAME`]->(target)
} IN TRANSACTIONS OF 10000 ROWS;



// CREATE FULLTEXT INDEX generic_names_and_descriptions FOR (n:Equipment|Room|Measurement|Part|SPECIFICATION|Alarm|`Asset Class`|`Maintenance Routine`|`Storage Location`|Vendor|`Work Order`|`Network Point`) ON EACH [
//     n.name,
//     n.unique_identifier,
//     n.network_point,
//     n.mode,
//     n.description,
//     n.message,
//     n.service_provided,
//     n.issue_description,
//     n.content,
//     n.requestor
// ]

// CREATE VECTOR INDEX chunkEmbeddingIndex FOR (c:Chunk) ON (c.embedding)
// OPTIONS { indexConfig: {
//  `vector.dimensions`: 768,
//  `vector.similarity_function`: 'cosine'
// }}
