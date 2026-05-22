{% macro drop_stale_dbt_backups() %}
    {% if execute %}
        {% set backup_relations = [
            {"schema": "intermediate", "identifier": "int_energy_weather_hourly__dbt_backup"},
            {"schema": "marts", "identifier": "fct_energy_weather_hourly__dbt_backup"},
            {"schema": "marts", "identifier": "mart_energy_weather_daily__dbt_backup"},
            {"schema": "marts", "identifier": "mart_energy_weather_by_condition__dbt_backup"}
        ] %}

        {% for item in backup_relations %}
            {% set relation = adapter.get_relation(
                database=target.database,
                schema=item["schema"],
                identifier=item["identifier"]
            ) %}

            {% if relation is not none %}
                {% do adapter.drop_relation(relation) %}
            {% endif %}
        {% endfor %}
    {% endif %}
{% endmacro %}
