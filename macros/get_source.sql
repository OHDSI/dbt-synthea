{%- macro get_source(source_name, table_name) -%}
    {%- if not var('seed_source', false) and table_name == 'source_to_concept_map_seed' -%}
        {%- do return(ref('source_to_concept_map_seed')) -%}
    {%- else -%}
        {%- do return(source(source_name, table_name)) -%}
    {%- endif -%}
{%- endmacro -%}
