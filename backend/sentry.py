import os
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.redis import RedisIntegration
from sentry_sdk.integrations.celery import CeleryIntegration
from sentry_sdk.integrations.logging import LoggingIntegration

# Configuration de Sentry
sentry_sdk.init(
    dsn=os.getenv('SENTRY_DSN'),
    environment=os.getenv('SENTRY_ENVIRONMENT', 'production'),
    release=f"banadoctor@{os.getenv('GIT_COMMIT_SHA', 'local')}",
    # Activer les traces de performance
    traces_sample_rate=float(os.getenv('SENTRY_TRACES_SAMPLE_RATE', '0.1')),
    # Activer les profils de performance (nécessite l'option Performance dans Sentry)
    _experiments={
        'profiles_sample_rate': float(os.getenv('SENTRY_PROFILES_SAMPLE_RATE', '0.1')),
    },
    # Intégrations
    integrations=[
        DjangoIntegration(
            transaction_style='url',
            middleware_spans=True,
            signals_spans=False,
            cache_spans=False,
        ),
        RedisIntegration(),
        CeleryIntegration(),
        LoggingIntegration(
            level=int(os.getenv('SENTRY_LOG_LEVEL', '10')),  # 10 = DEBUG, 20 = INFO, etc.
            event_level=int(os.getenv('SENTRY_EVENT_LEVEL', '40')),  # 40 = ERROR
        ),
    ],
    # Configuration par défaut
    send_default_pii=os.getenv('SENTRY_SEND_DEFAULT_PII', 'False').lower() == 'true',
    debug=os.getenv('SENTRY_DEBUG', 'False').lower() == 'true',
    # Filtrage des données sensibles
    before_send=lambda event, hint: filter_sensitive_data(event),
    before_breadcrumb=lambda breadcrumb, hint: filter_breadcrumb(breadcrumb),
)

def _filter_request_headers(request_event):
    """Filters sensitive headers from the request event."""
    if 'headers' in request_event:
        sensitive_headers = ['authorization', 'cookie', 'set-cookie', 'x-csrftoken', 'x-api-key']
        for header in sensitive_headers:
            if header in request_event['headers']:
                request_event['headers'][header] = '[FILTERED]'

def _filter_request_data(request_event):
    """Filters sensitive data from the request body."""
    if 'data' in request_event and isinstance(request_event['data'], dict):
        sensitive_fields = ['password', 'token', 'secret', 'key', 'api_key', 'access_token', 'refresh_token']
        for field in sensitive_fields:
            if field in request_event['data']:
                request_event['data'][field] = '[FILTERED]'

def _filter_event_tags(event):
    """Filters sensitive tags from the event."""
    if 'tags' in event:
        sensitive_tags = ['password', 'token', 'secret', 'key']
        for tag in sensitive_tags:
            if tag in event['tags']:
                event['tags'][tag] = '[FILTERED]'

def filter_sensitive_data(event):
    """Filtre les données sensibles des événements Sentry."""
    # Ne pas envoyer d'événements sans stacktrace
    if 'exception' not in event and 'message' not in event:
        return None
        
    if 'request' in event:
        _filter_request_headers(event['request'])
        _filter_request_data(event['request'])
    
    _filter_event_tags(event)
    
    return event

def filter_breadcrumb(breadcrumb):
    """Filtre les données sensibles des breadcrumbs Sentry."""
    # Ne pas suivre les requêtes vers les ressources statiques
    if breadcrumb.get('category') == 'http' and 'static' in breadcrumb.get('data', {}).get('url', ''):
        return None
        
    # Filtrer les données sensibles
    if 'data' in breadcrumb and isinstance(breadcrumb['data'], dict):
        sensitive_fields = ['password', 'token', 'secret', 'key', 'api_key']
        for field in sensitive_fields:
            if field in breadcrumb['data']:
                breadcrumb['data'][field] = '[FILTERED]'
    
    return breadcrumb

# Configuration des alertes Sentry
def configure_alerts():
    """Configure les alertes Sentry."""
    from sentry_sdk import configure_scope
    
    with configure_scope() as scope:
        # Tags globaux pour toutes les erreurs
        scope.set_tag('environment', os.getenv('SENTRY_ENVIRONMENT', 'production'))
        scope.set_tag('version', os.getenv('APP_VERSION', 'unknown'))
        
        # Configuration des utilisateurs (si disponible)
        # if hasattr(request, 'user') and request.user.is_authenticated:
        #     scope.user = {
        #         'id': request.user.id,
        #         'email': request.user.email,
        #         'username': request.user.username,
        #     }


def capture_message(message, level='info', **kwargs):
    """Capture un message personnalisé dans Sentry."""
    return sentry_sdk.capture_message(message, level=level, **kwargs)

def capture_exception(exception=None, **kwargs):
    """Capture une exception dans Sentry."""
    return sentry_sdk.capture_exception(exception, **kwargs)
