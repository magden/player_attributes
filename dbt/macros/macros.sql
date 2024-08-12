{% macro get_user_panel_data() %}
    {% set sql %}
        SELECT * FROM `play-perfect-432018.game_events.user_panel`
    {% endset %}

    {% set results = run_query(sql) %}

    {% if results %}
        {% do log("Results fetched: " ~ results) %}
        {{ return(results) }}
    {% else %}
        {% do log("No results found") %}
        {{ return([]) }}  -- Return an empty list if there are no results
    {% endif %}
{% endmacro %}
