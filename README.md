# Chatwoot Enterprise (Bypass) for Dokploy

Este repositorio contiene una configuración lista para desplegar **Chatwoot v4.13.0** en modo **Enterprise** de forma gratuita en tu propio VPS usando **Dokploy** o Docker Compose.

## Características desbloqueadas
- Agentes ilimitados
- Custom Branding (Remoción de "Powered by Chatwoot")
- SLA, Auditoría y Roles personalizados
- Integración con Captain (IA)
- SAML/SSO y más.

## Instalación en Dokploy

1. Crea una nueva aplicación en Dokploy conectada a este repositorio.
2. Copia el contenido de `.env.example` a las **Environment Variables** de tu aplicación.
3. Genera un `SECRET_KEY_BASE` seguro.
4. Despliega la aplicación.
5. Una vez desplegada, abre la terminal del contenedor `rails` y ejecuta:
   ```bash
   cd /app
   RAILS_ENV=production ./bin/rails runner "InstallationConfig.find_or_initialize_by(name: 'INSTALLATION_PRICING_PLAN').update!(value: 'enterprise', locked: true)"
   ```

## Archivos incluidos
- `Dockerfile`: Parches automáticos de bypass.
- `docker-compose.yml`: Orquestación de servicios (Rails, Sidekiq, Postgres con vectores, Redis).
- `init-vector.sql`: Inicialización de base de datos para IA.

## Créditos
Configuración preparada para la comunidad. Úsalo bajo tu propia responsabilidad.
