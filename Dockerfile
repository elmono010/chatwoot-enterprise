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

# 7. Bypass de validaciones de Cloud y forzar Enterprise en controladores
RUN find enterprise -name "*.rb" -exec sed -i 's/def check_cloud_env/def check_cloud_env\n    return true\n/g' {} +
RUN find enterprise -name "*.rb" -exec sed -i 's/base.extend(Enterprise::Account)/# base.extend(Enterprise::Account)/g' {} +

# 8. Incrementar Timeout de Webhooks a 90 segundos (Parche de código)
RUN sed -i '/def webhook_timeout/,/end/c\  def webhook_timeout\n    env_timeout = ENV["WEBHOOK_TIMEOUT"].presence\&.to_i\n    return env_timeout if env_timeout\&.positive?\n    raw_timeout = GlobalConfig.get_value("WEBHOOK_TIMEOUT")\n    timeout = raw_timeout.presence\&.to_i\n    timeout\&.positive? ? timeout : 90\n  end' lib/webhooks/trigger.rb

# 9. Permitir embeber el CRM en Iframe (Eliminar X-Frame-Options globalmente en Rails)
RUN sed -i "s/config.load_defaults 7.0/config.load_defaults 7.0\\n    config.action_dispatch.default_headers.delete('X-Frame-Options')/g" config/application.rb

# Corregir permisos de forma global para evitar errores de caché y temporales
RUN mkdir -p /app/tmp /app/storage
RUN chown -R 1000:1000 /app

USER 1000
