FROM chatwoot/chatwoot:v4.13.0

USER root

# --- PARCHES PARA ACTIVAR ENTERPRISE ---

# 1. Forzar Plan Enterprise en el Hub
RUN sed -i "s/InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN')\&.value || 'community'/'enterprise'/g" lib/chatwoot_hub.rb

# 2. Forzar Identidad Enterprise en ChatwootApp
RUN sed -i "s/root.join('enterprise').exist?/true/g" lib/chatwoot_app.rb
RUN sed -i "s/enterprise? && !chatwoot_cloud? && GlobalConfig.get_value('INSTALLATION_PRICING_PLAN') == 'enterprise'/true/g" lib/chatwoot_app.rb

# 3. Forzar el Job de sincronización para que mantenga 'enterprise' en la base de datos
RUN sed -i "s/value: @instance_info\['plan'\]/value: 'enterprise'/g" enterprise/app/jobs/enterprise/internal/check_new_versions_job.rb
RUN sed -i "s/value: @instance_info\['plan_quantity'\]/value: 100/g" enterprise/app/jobs/enterprise/internal/check_new_versions_job.rb

# 4. Habilitar funciones Premium en el modelo de Featurable
RUN sed -i 's/def feature_enabled?(name)/def feature_enabled?(name)\n    feature = Featurable::FEATURE_LIST.find { |f| f["name"] == name.to_s }\n    return true if feature \&\& feature["premium"]\n/g' app/models/concerns/featurable.rb

# 5. Forzar cantidad de licencias ilimitadas en el Hub
RUN sed -i "s/InstallationConfig.find_by(name: 'INSTALLATION_PRICING_PLAN_QUANTITY')\&.value || 0/1000/g" lib/chatwoot_hub.rb

# 6. Forzar límites de agentes en el modelo de cuenta
RUN sed -i 's/def agent_limits/def agent_limits\n    return ChatwootApp.max_limit\n/g' enterprise/app/models/enterprise/account/plan_usage_and_limits.rb

# Corregir permisos de forma global para evitar errores de caché y temporales
RUN mkdir -p /app/tmp /app/storage
RUN chown -R 1000:1000 /app

USER 1000
