import os
import sentry_sdk
from sentry_sdk.integrations.django import DjangoIntegration
from sentry_sdk.integrations.celery import CeleryIntegration
from sentry_sdk.integrations.redis import RedisIntegration

# Initialize Sentry
def init_sentry(dsn: str, environment: str = 'production', release: str = None):
    sentry_sdk.init(
        dsn=dsn,
        environment=environment,
        release=release or os.environ.get('GIT_COMMIT_SHA'),
        integrations=[
            DjangoIntegration(
                transaction_style='url',
                middleware_spans=True,
                signals_spans=False,
                cache_spans=False,
            ),
            CeleryIntegration(),
            RedisIntegration(),
        ],
        # Set traces_sample_rate to 1.0 to capture 100%
        # of transactions for performance monitoring.
        traces_sample_rate=0.1,
        # If you wish to associate users to errors (assuming you are using
        # django.contrib.auth) you may enable sending PII data.
        send_default_pii=True,
        # By default the SDK will try to use the SENTRY_RELEASE
        # environment variable, or infer a git commit
        # SHA as release, however you may want to set
        # something more human-readable.
        # release="myapp@1.0.0",
    )

    # Add user context
    from django.contrib.auth.models import AnonymousUser
    from django.core.exceptions import ObjectDoesNotExist
    import sys

    def add_user_context(user, **kwargs):
        if not user or not hasattr(user, 'is_authenticated'):
            return

        if user.is_authenticated:
            try:
                sentry_sdk.set_user({
                    'id': str(user.id),
                    'email': getattr(user, 'email', None),
                    'username': getattr(user, 'username', None),
                    'is_staff': getattr(user, 'is_staff', False),
                    'is_superuser': getattr(user, 'is_superuser', False),
                })
            except Exception:
                sentry_sdk.capture_exception(sys.exc_info())

    # Connect the signal
    from django.contrib.auth.signals import user_logged_in
    from django.dispatch import receiver

    @receiver(user_logged_in)
    def on_user_logged_in(sender, request, user, **kwargs):
        add_user_context(user)
