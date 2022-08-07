{% macro purchase_done_value_detail() %}
    REGEXP_EXTRACT(value, r'\.[0-9]*')
{%- endmacro %}

