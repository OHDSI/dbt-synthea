{% macro create_synthea_tables() %}
    {% set database = target.database %}
    {% set schema = target.schema ~ '_synthea' %}
    {% do adapter.create_schema(api.Relation.create(database=database, schema=schema)) %}
    {% set sql %}
        {% if not check_if_exists(database, schema, "allergies") %}
            CREATE TABLE {{schema}}.allergies (
                "start"        DATE,
                "stop"         DATE,
                patient      VARCHAR(1000),
                encounter    VARCHAR(1000),
                code         VARCHAR(100),
                "system"       VARCHAR(255),
                description  VARCHAR(255),
                "type"       VARCHAR(255),
                category     VARCHAR(255),
                reaction1    VARCHAR(255),
                description1 VARCHAR(255),
                severity1    VARCHAR(255),
                reaction2    VARCHAR(255),
                description2 VARCHAR(255),
                severity2    VARCHAR(255)
                );
        {% endif %}
        {% if not check_if_exists(database, schema, "careplans") %}
            CREATE TABLE {{schema}}.careplans (
                id            VARCHAR(1000),
                "start"         DATE,
                "stop"          DATE,
                patient       VARCHAR(1000),
                encounter     VARCHAR(1000),
                code          VARCHAR(100),
                description   VARCHAR(255),
                reasoncode    VARCHAR(255),
                reasondescription   VARCHAR(255)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "conditions") %}
            CREATE TABLE {{schema}}.conditions (
                "start"         DATE,
                "stop"          DATE,
                patient       VARCHAR(1000),
                encounter     VARCHAR(1000),
                code          VARCHAR(100),
                description   VARCHAR(255)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "encounters") %}
            CREATE TABLE {{schema}}.encounters (
                id              VARCHAR(1000),
                "start"           TIMESTAMP,
                "stop"            TIMESTAMP,
                patient         VARCHAR(1000),
                organization    VARCHAR(1000),
                "provider"        VARCHAR(1000),
                payer           VARCHAR(1000),
                encounterclass  VARCHAR(1000),
                code            VARCHAR(100),
                description     VARCHAR(255),
                base_encounter_cost NUMERIC,
                total_claim_cost    NUMERIC,
                payer_coverage  NUMERIC,
                reasoncode      VARCHAR(100),
                reasondescription VARCHAR(255)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "immunizations") %}
            CREATE TABLE {{schema}}.immunizations (
                "date"        TIMESTAMP,
                patient       VARCHAR(1000),
                encounter     VARCHAR(1000),
                code          VARCHAR(100),
                description   VARCHAR(255),
                base_cost     NUMERIC
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "imaging_studies") %}
            CREATE TABLE {{schema}}.imaging_studies (
                id              VARCHAR(1000),
                "date"          TIMESTAMP,
                patient         VARCHAR(1000),
                encounter       VARCHAR(1000),
                series_uid      VARCHAR(1000),
                bodysite_code   VARCHAR(100),
                bodysite_description    VARCHAR(255),
                modality_code   VARCHAR(100),
                modality_description    VARCHAR(255),
                instance_uid    VARCHAR(1000),
                SOP_code        VARCHAR(100),
                SOP_description VARCHAR(255),
                procedure_code  VARCHAR(255)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "medications") %}
            CREATE TABLE {{schema}}.medications (
                "start"         TIMESTAMP,
                "stop"          TIMESTAMP,
                patient       VARCHAR(1000),
                payer         VARCHAR(1000),
                encounter     VARCHAR(1000),
                code          VARCHAR(100),
                description   VARCHAR(1000),
                base_cost     NUMERIC,
                payer_coverage    NUMERIC,
                dispenses     INT,
                totalcost     NUMERIC,
                reasoncode    VARCHAR(100),
                reasondescription   VARCHAR(255)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "observations") %}
            CREATE TABLE {{schema}}.observations (
                "date"         TIMESTAMP,
                patient       VARCHAR(1000),
                encounter     VARCHAR(1000),
                category      VARCHAR(1000),
                code          VARCHAR(100),
                description   VARCHAR(255),
                "value"         VARCHAR(1000),
                units         VARCHAR(100),
                "type"        VARCHAR(100)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "organizations") %}
            CREATE TABLE {{schema}}.organizations (
                id              VARCHAR(1000),
                "name"          VARCHAR(1000),
                address         VARCHAR(1000),
                city            VARCHAR(100),
                state           VARCHAR(100),
                zip             VARCHAR(100),
                lat             NUMERIC,
                lon             NUMERIC,
                phone           VARCHAR(100),
                revenue         NUMERIC,
                utilization     VARCHAR(100)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "patients") %}
            CREATE TABLE {{schema}}.patients (
                id              VARCHAR(1000),
                birthdate       DATE,
                deathdate       DATE,
                ssn             VARCHAR(100),
                drivers         VARCHAR(100),
                passport        VARCHAR(100),
                prefix          VARCHAR(100),
                "first"           VARCHAR(100),
                "last"            VARCHAR(100),
                suffix          VARCHAR(100),
                maiden          VARCHAR(100),
                marital         VARCHAR(100),
                race            VARCHAR(100),
                ethnicity       VARCHAR(100),
                gender          VARCHAR(100),
                birthplace      VARCHAR(100),
                address         VARCHAR(100),
                city            VARCHAR(100),
                state           VARCHAR(100),
                county          VARCHAR(100),
                zip             VARCHAR(100),
                lat             NUMERIC,
                lon             NUMERIC,
                healthcare_expenses NUMERIC,
                healthcare_coverage NUMERIC
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "procedures") %}
            CREATE TABLE {{schema}}.procedures (
                "start"         TIMESTAMP,
                "stop"          TIMESTAMP,
                patient       VARCHAR(1000),
                encounter     VARCHAR(1000),
                code          VARCHAR(100),
                description   VARCHAR(255),
                base_cost     NUMERIC,
                reasoncode    VARCHAR(1000),
                reasondescription VARCHAR(1000)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "providers") %}
            CREATE TABLE {{schema}}.providers (
                id VARCHAR(1000),
                organization VARCHAR(1000),
                name VARCHAR(100),
                gender VARCHAR(100),
                speciality VARCHAR(100),
                address VARCHAR(255),
                city VARCHAR(100),
                state VARCHAR(100),
                zip VARCHAR(100),
                lat NUMERIC,
                lon NUMERIC,
                utilization NUMERIC
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "devices") %}
            CREATE TABLE {{schema}}.devices (
                "start"         TIMESTAMP,
                "stop"          TIMESTAMP,
                patient       VARCHAR(1000),
                encounter     VARCHAR(1000),
                code          VARCHAR(100),
                description   VARCHAR(255),
                udi           VARCHAR(255)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "claims") %}
            CREATE TABLE {{schema}}.claims (
                id                           VARCHAR(1000),
                patientid                    VARCHAR(1000),
                providerid                   VARCHAR(1000),
                primarypatientinsuranceid    VARCHAR(1000),
                secondarypatientinsuranceid  VARCHAR(1000),
                departmentid                 VARCHAR(1000),
                patientdepartmentid          VARCHAR(1000),
                diagnosis1                   VARCHAR(1000),
                diagnosis2                   VARCHAR(1000),
                diagnosis3                   VARCHAR(1000),
                diagnosis4                   VARCHAR(1000),
                diagnosis5                   VARCHAR(1000),
                diagnosis6                   VARCHAR(1000),
                diagnosis7                   VARCHAR(1000),
                diagnosis8                   VARCHAR(1000),
                referringproviderid          VARCHAR(1000),
                appointmentid                VARCHAR(1000),
                currentillnessdate           TIMESTAMP,
                servicedate                  TIMESTAMP,
                supervisingproviderid        VARCHAR(1000),
                status1                      VARCHAR(1000),
                status2                      VARCHAR(1000),
                statusp                      VARCHAR(1000),
                outstanding1                 NUMERIC,
                outstanding2                 NUMERIC,
                outstandingp                 NUMERIC,
                lastbilleddate1              TIMESTAMP,
                lastbilleddate2              TIMESTAMP,
                lastbilleddatep              TIMESTAMP,
                healthcareclaimtypeid1       NUMERIC,
                healthcareclaimtypeid2       NUMERIC
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "claims_transactions") %}
            CREATE TABLE {{schema}}.claims_transactions (
                id                     VARCHAR(1000),
                claimid                VARCHAR(1000),
                chargeid               NUMERIC,
                patientid              VARCHAR(1000),
                "type"                 VARCHAR(1000),
                amount                 NUMERIC,
                method                 VARCHAR(1000),
                fromdate               TIMESTAMP,
                todate                 TIMESTAMP,
                placeofservice         VARCHAR(1000),
                procedurecode          VARCHAR(1000),
                modifier1              VARCHAR(1000),
                modifier2              VARCHAR(1000),
                diagnosisref1          NUMERIC,
                diagnosisref2          NUMERIC,
                diagnosisref3          NUMERIC,
                diagnosisref4          NUMERIC,
                units                  NUMERIC,
                departmentid           NUMERIC,
                notes                  VARCHAR(1000),
                unitamount             NUMERIC,
                transferoutid          NUMERIC,
                transfertype           VARCHAR(1000),
                payments               NUMERIC,
                adjustments            NUMERIC,
                transfers              NUMERIC,
                outstanding            NUMERIC,
                appointmentid          VARCHAR(1000),
                linenote               VARCHAR(1000),
                patientinsuranceid     VARCHAR(1000),
                feescheduleid          NUMERIC,
                providerid             VARCHAR(1000),
                supervisingproviderid  VARCHAR(1000)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "payer_transitions") %}
            CREATE TABLE {{schema}}.payer_transitions (
                patient           VARCHAR(1000),
                memberid         VARCHAR(1000),
                start_year       TIMESTAMP,
                end_year         TIMESTAMP,
                payer            VARCHAR(1000),
                secondary_payer  VARCHAR(1000),
                ownership        VARCHAR(1000),
                ownername       VARCHAR(1000)
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "payers") %}
            CREATE TABLE {{schema}}.payers (
                id                       VARCHAR(1000),
                name                     VARCHAR(1000),
                address                  VARCHAR(1000),
                city                     VARCHAR(1000),
                state_headquartered      VARCHAR(1000),
                zip                      VARCHAR(1000),
                phone                    VARCHAR(1000),
                amount_covered           NUMERIC,
                amount_uncovered         NUMERIC,
                revenue                  NUMERIC,
                covered_encounters       NUMERIC,
                uncovered_encounters     NUMERIC,
                covered_medications      NUMERIC,
                uncovered_medications    NUMERIC,
                covered_procedures       NUMERIC,
                uncovered_procedures     NUMERIC,
                covered_immunizations    NUMERIC,
                uncovered_immunizations  NUMERIC,
                unique_customers         NUMERIC,
                qols_avg                 NUMERIC,
                member_months            NUMERIC
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "supplies") %}
            CREATE TABLE {{schema}}.supplies (
                "date"       DATE,
                patient      VARCHAR(1000),
                encounter    VARCHAR(1000),
                code         VARCHAR(1000),
                description  VARCHAR(1000),
                quantity     NUMERIC
            );
        {% endif %}
        COMMIT;
    {% endset %}

    {% do run_query(sql) %}
{% endmacro %}