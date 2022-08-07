{% macro file_uploaded() %}
    REGEXP_EXTRACT(value, r'\.[a-zA-Z]*')
{%- endmacro %}

