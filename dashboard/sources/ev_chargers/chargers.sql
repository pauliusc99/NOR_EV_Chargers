install spatial; load spatial;

select
    *,
    st_x(position)::DOUBLE as lat,
    st_y(position)::DOUBLE as lon
from fct_ev_chargers