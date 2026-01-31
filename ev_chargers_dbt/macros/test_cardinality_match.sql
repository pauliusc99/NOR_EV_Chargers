{% test cardinality_match(model, column_name, other_column_name)%}

with counts as (
    select 
        count(distinct({{column_name}})) as cnt_unq_cn,
        count(distinct({{other_column_name}})) as cnt_unq_ocn
    from {{model}}
)

from counts
where cnt_unq_cn != cnt_unq_ocn

{% endtest %}