{% macro create_synthea_tables() %}
    {% set database = target.database %}
    {% set schema = target.schema ~ '_synthea' %}
    {% do adapter.create_schema(api.Relation.create(database=database, schema=schema)) %}
    {% set sql %}
        {% if not check_if_exists(database, schema, "allergies") %}
            CREATE TABLE {{schema}}.allergies (
                {{adapter.quote('start')}}        {{api.Column.translate_type('date')}},
                {{adapter.quote('stop')}}         {{api.Column.translate_type('date')}},
                patient      {{api.Column.translate_type('varchar(1000)')}},
                encounter    {{api.Column.translate_type('varchar(1000)')}},
                code         {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('system')}}       {{api.Column.translate_type('varchar(255)')}},
                description  {{api.Column.translate_type('varchar(255)')}},
                {{adapter.quote('type')}}         {{api.Column.translate_type('varchar(255)')}},
                category     {{api.Column.translate_type('varchar(255)')}},
                reaction1    {{api.Column.translate_type('varchar(255)')}},
                description1 {{api.Column.translate_type('varchar(255)')}},
                severity1    {{api.Column.translate_type('varchar(255)')}},
                reaction2    {{api.Column.translate_type('varchar(255)')}},
                description2 {{api.Column.translate_type('varchar(255)')}},
                severity2    {{api.Column.translate_type('varchar(255)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "careplans") %}
            CREATE TABLE {{schema}}.careplans (
                id            {{api.Column.translate_type('varchar(1000)')}},
                {{adapter.quote('start')}}         {{api.Column.translate_type('date')}},
                {{adapter.quote('stop')}}          {{api.Column.translate_type('date')}},
                patient       {{api.Column.translate_type('varchar(1000)')}},
                encounter     {{api.Column.translate_type('varchar(1000)')}},
                code          {{api.Column.translate_type('varchar(100)')}},
                description   {{api.Column.translate_type('varchar(255)')}},
                reasoncode    {{api.Column.translate_type('varchar(255)')}},
                reasondescription {{api.Column.translate_type('varchar(255)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "conditions") %}
            CREATE TABLE {{schema}}.conditions (
                {{adapter.quote('start')}}         {{api.Column.translate_type('date')}},
                {{adapter.quote('stop')}}          {{api.Column.translate_type('date')}},
                patient       {{api.Column.translate_type('varchar(1000)')}},
                encounter     {{api.Column.translate_type('varchar(1000)')}},
                code          {{api.Column.translate_type('varchar(100)')}},
                description   {{api.Column.translate_type('varchar(255)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "encounters") %}
            CREATE TABLE {{schema}}.encounters (
                id              {{api.Column.translate_type('varchar(1000)')}},
                {{adapter.quote('start')}}           {{api.Column.translate_type('timestamp')}},
                {{adapter.quote('stop')}}            {{api.Column.translate_type('timestamp')}},
                patient         {{api.Column.translate_type('varchar(1000)')}},
                organization    {{api.Column.translate_type('varchar(1000)')}},
                provider        {{api.Column.translate_type('varchar(1000)')}},
                payer           {{api.Column.translate_type('varchar(1000)')}},
                encounterclass  {{api.Column.translate_type('varchar(1000)')}},
                code            {{api.Column.translate_type('varchar(100)')}},
                description     {{api.Column.translate_type('varchar(255)')}},
                base_encounter_cost {{api.Column.translate_type('float')}},
                total_claim_cost    {{api.Column.translate_type('float')}},
                payer_coverage      {{api.Column.translate_type('float')}},
                reasoncode      {{api.Column.translate_type('varchar(100)')}},
                reasondescription {{api.Column.translate_type('varchar(255)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "immunizations") %}
            CREATE TABLE {{schema}}.immunizations (
                {{adapter.quote('date')}}        {{api.Column.translate_type('timestamp')}},
                patient       {{api.Column.translate_type('varchar(1000)')}},
                encounter     {{api.Column.translate_type('varchar(1000)')}},
                code          {{api.Column.translate_type('varchar(100)')}},
                description   {{api.Column.translate_type('varchar(255)')}},
                base_cost     {{api.Column.translate_type('float')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "imaging_studies") %}
            CREATE TABLE {{schema}}.imaging_studies (
                id              {{api.Column.translate_type('varchar(1000)')}},
                {{adapter.quote('date')}}          {{api.Column.translate_type('timestamp')}},
                patient         {{api.Column.translate_type('varchar(1000)')}},
                encounter       {{api.Column.translate_type('varchar(1000)')}},
                series_uid      {{api.Column.translate_type('varchar(1000)')}},
                bodysite_code   {{api.Column.translate_type('varchar(100)')}},
                bodysite_description {{api.Column.translate_type('varchar(255)')}},
                modality_code   {{api.Column.translate_type('varchar(100)')}},
                modality_description {{api.Column.translate_type('varchar(255)')}},
                instance_uid    {{api.Column.translate_type('varchar(1000)')}},
                SOP_code        {{api.Column.translate_type('varchar(100)')}},
                SOP_description {{api.Column.translate_type('varchar(255)')}},
                procedure_code  {{api.Column.translate_type('varchar(255)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "medications") %}
            CREATE TABLE {{schema}}.medications (
                {{adapter.quote('start')}}         {{api.Column.translate_type('timestamp')}},
                {{adapter.quote('stop')}}          {{api.Column.translate_type('timestamp')}},
                patient       {{api.Column.translate_type('varchar(1000)')}},
                payer         {{api.Column.translate_type('varchar(1000)')}},
                encounter     {{api.Column.translate_type('varchar(1000)')}},
                code          {{api.Column.translate_type('varchar(100)')}},
                description   {{api.Column.translate_type('varchar(1000)')}},
                base_cost     {{api.Column.translate_type('float')}},
                payer_coverage    {{api.Column.translate_type('float')}},
                dispenses     {{api.Column.translate_type('int')}},
                totalcost     {{api.Column.translate_type('float')}},
                reasoncode    {{api.Column.translate_type('varchar(100)')}},
                reasondescription {{api.Column.translate_type('varchar(255)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "observations") %}
            CREATE TABLE {{schema}}.observations (
                {{adapter.quote('date')}}         {{api.Column.translate_type('timestamp')}},
                patient       {{api.Column.translate_type('varchar(1000)')}},
                encounter     {{api.Column.translate_type('varchar(1000)')}},
                category      {{api.Column.translate_type('varchar(1000)')}},
                code          {{api.Column.translate_type('varchar(100)')}},
                description   {{api.Column.translate_type('varchar(255)')}},
                value         {{api.Column.translate_type('varchar(1000)')}},
                units         {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('type')}}        {{api.Column.translate_type('varchar(100)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "organizations") %}
            CREATE TABLE {{schema}}.organizations (
                id              {{api.Column.translate_type('varchar(1000)')}},
                name          {{api.Column.translate_type('varchar(1000)')}},
                address         {{api.Column.translate_type('varchar(1000)')}},
                city            {{api.Column.translate_type('varchar(100)')}},
                state           {{api.Column.translate_type('varchar(100)')}},
                zip             {{api.Column.translate_type('varchar(100)')}},
                lat             {{api.Column.translate_type('float')}},
                lon             {{api.Column.translate_type('float')}},
                phone           {{api.Column.translate_type('varchar(100)')}},
                revenue         {{api.Column.translate_type('float')}},
                utilization     {{api.Column.translate_type('varchar(100)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "patients") %}
            CREATE TABLE {{schema}}.patients (
                id              {{api.Column.translate_type('varchar(1000)')}},
                {{adapter.quote('birthdate')}}       {{api.Column.translate_type('date')}},
                {{adapter.quote('deathdate')}}       {{api.Column.translate_type('date')}},
                {{adapter.quote('ssn')}}             {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('drivers')}}         {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('passport')}}        {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('prefix')}}          {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('first')}}           {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('last')}}            {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('suffix')}}          {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('maiden')}}          {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('marital')}}         {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('race')}}            {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('ethnicity')}}       {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('gender')}}          {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('birthplace')}}      {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('address')}}         {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('city')}}            {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('state')}}           {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('county')}}          {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('zip')}}             {{api.Column.translate_type('varchar(100)')}},
                {{adapter.quote('lat')}}             {{api.Column.translate_type('float')}},
                {{adapter.quote('lon')}}             {{api.Column.translate_type('float')}},
                healthcare_expenses {{api.Column.translate_type('float')}},
                healthcare_coverage {{api.Column.translate_type('float')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "procedures") %}
            CREATE TABLE {{schema}}.procedures (
                {{adapter.quote('start')}}         {{api.Column.translate_type('timestamp')}},
                {{adapter.quote('stop')}}          {{api.Column.translate_type('timestamp')}},
                patient       {{api.Column.translate_type('varchar(1000)')}},
                encounter     {{api.Column.translate_type('varchar(1000)')}},
                code          {{api.Column.translate_type('varchar(100)')}},
                description   {{api.Column.translate_type('varchar(255)')}},
                base_cost     {{api.Column.translate_type('float')}},
                reasoncode    {{api.Column.translate_type('varchar(1000)')}},
                reasondescription {{api.Column.translate_type('varchar(1000)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "providers") %}
            CREATE TABLE {{schema}}.providers (
                id varchar(1000),
                organization varchar(1000),
                name varchar(100),
                gender varchar(100),
                speciality varchar(100),
                address varchar(255),
                city varchar(100),
                state varchar(100),
                zip varchar(100),
                lat float,
                lon float,
                utilization float
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "devices") %}
            CREATE TABLE {{schema}}.devices (
                {{adapter.quote('start')}}         {{api.Column.translate_type('timestamp')}},
                {{adapter.quote('stop')}}          {{api.Column.translate_type('timestamp')}},
                patient       {{api.Column.translate_type('varchar(1000)')}},
                encounter     {{api.Column.translate_type('varchar(1000)')}},
                code          {{api.Column.translate_type('varchar(100)')}},
                description   {{api.Column.translate_type('varchar(255)')}},
                udi           {{api.Column.translate_type('varchar(255)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "claims") %}
            CREATE TABLE {{schema}}.claims (
                id                           {{api.Column.translate_type('varchar(1000)')}},
                patientid                    {{api.Column.translate_type('varchar(1000)')}},
                providerid                   {{api.Column.translate_type('varchar(1000)')}},
                primarypatientinsuranceid    {{api.Column.translate_type('varchar(1000)')}},
                secondarypatientinsuranceid  {{api.Column.translate_type('varchar(1000)')}},
                departmentid                 {{api.Column.translate_type('varchar(1000)')}},
                patientdepartmentid          {{api.Column.translate_type('varchar(1000)')}},
                diagnosis1                   {{api.Column.translate_type('varchar(1000)')}},
                diagnosis2                   {{api.Column.translate_type('varchar(1000)')}},
                diagnosis3                   {{api.Column.translate_type('varchar(1000)')}},
                diagnosis4                   {{api.Column.translate_type('varchar(1000)')}},
                diagnosis5                   {{api.Column.translate_type('varchar(1000)')}},
                diagnosis6                   {{api.Column.translate_type('varchar(1000)')}},
                diagnosis7                   {{api.Column.translate_type('varchar(1000)')}},
                diagnosis8                   {{api.Column.translate_type('varchar(1000)')}},
                referringproviderid          {{api.Column.translate_type('varchar(1000)')}},
                appointmentid                {{api.Column.translate_type('varchar(1000)')}},
                currentillnessdate           {{api.Column.translate_type('timestamp')}},
                servicedate                  {{api.Column.translate_type('timestamp')}},
                supervisingproviderid        {{api.Column.translate_type('varchar(1000)')}},
                status1                      {{api.Column.translate_type('varchar(1000)')}},
                status2                      {{api.Column.translate_type('varchar(1000)')}},
                statusp                      {{api.Column.translate_type('varchar(1000)')}},
                outstanding1                 {{api.Column.translate_type('float')}},
                outstanding2                 {{api.Column.translate_type('float')}},
                outstandingp                 {{api.Column.translate_type('float')}},
                lastbilleddate1              {{api.Column.translate_type('timestamp')}},
                lastbilleddate2              {{api.Column.translate_type('timestamp')}},
                lastbilleddatep              {{api.Column.translate_type('timestamp')}},
                healthcareclaimtypeid1       {{api.Column.translate_type('float')}},
                healthcareclaimtypeid2       {{api.Column.translate_type('float')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "claims_transactions") %}
            CREATE TABLE {{schema}}.claims_transactions (
                id                     {{api.Column.translate_type('varchar(1000)')}},
                claimid                {{api.Column.translate_type('varchar(1000)')}},
                chargeid               {{api.Column.translate_type('float')}},
                patientid              {{api.Column.translate_type('varchar(1000)')}},
                type                 {{api.Column.translate_type('varchar(1000)')}},
                amount                 {{api.Column.translate_type('float')}},
                method                 {{api.Column.translate_type('varchar(1000)')}},
                fromdate               {{api.Column.translate_type('timestamp')}},
                todate                 {{api.Column.translate_type('timestamp')}},
                placeofservice         {{api.Column.translate_type('varchar(1000)')}},
                procedurecode          {{api.Column.translate_type('varchar(1000)')}},
                modifier1              {{api.Column.translate_type('varchar(1000)')}},
                modifier2              {{api.Column.translate_type('varchar(1000)')}},
                diagnosisref1          {{api.Column.translate_type('float')}},
                diagnosisref2          {{api.Column.translate_type('float')}},
                diagnosisref3          {{api.Column.translate_type('float')}},
                diagnosisref4          {{api.Column.translate_type('float')}},
                units                  {{api.Column.translate_type('float')}},
                departmentid           {{api.Column.translate_type('float')}},
                notes                  {{api.Column.translate_type('varchar(1000)')}},
                unitamount             {{api.Column.translate_type('float')}},
                transferoutid          {{api.Column.translate_type('float')}},
                transfertype           {{api.Column.translate_type('varchar(1000)')}},
                payments               {{api.Column.translate_type('float')}},
                adjustments            {{api.Column.translate_type('float')}},
                transfers              {{api.Column.translate_type('float')}},
                outstanding            {{api.Column.translate_type('float')}},
                appointmentid          {{api.Column.translate_type('varchar(1000)')}},
                linenote               {{api.Column.translate_type('varchar(1000)')}},
                patientinsuranceid     {{api.Column.translate_type('varchar(1000)')}},
                feescheduleid          {{api.Column.translate_type('float')}},
                providerid             {{api.Column.translate_type('varchar(1000)')}},
                supervisingproviderid  {{api.Column.translate_type('varchar(1000)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "payer_transitions") %}
            CREATE TABLE {{schema}}.payer_transitions (
                patient           {{api.Column.translate_type('varchar(1000)')}},
                memberid         {{api.Column.translate_type('varchar(1000)')}},
                {{adapter.quote('start_year')}}       {{api.Column.translate_type('timestamp')}},
                {{adapter.quote('end_year')}}         {{api.Column.translate_type('timestamp')}},
                payer            {{api.Column.translate_type('varchar(1000)')}},
                secondary_payer  {{api.Column.translate_type('varchar(1000)')}},
                ownership        {{api.Column.translate_type('varchar(1000)')}},
                ownername       {{api.Column.translate_type('varchar(1000)')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "payers") %}
            CREATE TABLE {{schema}}.payers (
                id                       {{api.Column.translate_type('varchar(1000)')}},
                name                     {{api.Column.translate_type('varchar(1000)')}},
                address                  {{api.Column.translate_type('varchar(1000)')}},
                city                     {{api.Column.translate_type('varchar(1000)')}},
                state_headquartered      {{api.Column.translate_type('varchar(1000)')}},
                zip                      {{api.Column.translate_type('varchar(1000)')}},
                phone                    {{api.Column.translate_type('varchar(1000)')}},
                amount_covered           {{api.Column.translate_type('float')}},
                amount_uncovered         {{api.Column.translate_type('float')}},
                revenue                  {{api.Column.translate_type('float')}},
                covered_encounters       {{api.Column.translate_type('float')}},
                uncovered_encounters     {{api.Column.translate_type('float')}},
                covered_medications      {{api.Column.translate_type('float')}},
                uncovered_medications    {{api.Column.translate_type('float')}},
                covered_procedures       {{api.Column.translate_type('float')}},
                uncovered_procedures     {{api.Column.translate_type('float')}},
                covered_immunizations    {{api.Column.translate_type('float')}},
                uncovered_immunizations  {{api.Column.translate_type('float')}},
                unique_customers         {{api.Column.translate_type('float')}},
                qols_avg                 {{api.Column.translate_type('float')}},
                member_months            {{api.Column.translate_type('float')}}
            );
        {% endif %}
        {% if not check_if_exists(database, schema, "supplies") %}
            CREATE TABLE {{schema}}.supplies (
                {{adapter.quote('date')}}       {{api.Column.translate_type('date')}},
                patient      {{api.Column.translate_type('varchar(1000)')}},
                encounter    {{api.Column.translate_type('varchar(1000)')}},
                code         {{api.Column.translate_type('varchar(1000)')}},
                description  {{api.Column.translate_type('varchar(1000)')}},
                quantity     {{api.Column.translate_type('float')}}
            );
        {% endif %}
        COMMIT;
    {% endset %}

    {% do run_query(sql) %}
{% endmacro %}