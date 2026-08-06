from django.contrib.auth.signals import user_logged_in
from django.dispatch import receiver
from django.utils import timezone
from .models import AuditLog

@receiver(user_logged_in)
def track_login(sender, user, request, **kwargs):
    user.last_login_ip = request.META.get('REMOTE_ADDR', '')
    user.last_login_device = request.META.get('HTTP_USER_AGENT', '')[:200]
    user.failed_login_attempts = 0
    user.save(update_fields=['last_login_ip', 'last_login_device', 'failed_login_attempts'])
    
    AuditLog.objects.create(
        user=user,
        action='LOGIN',
        table_name='User',
        record_id=user.id,
        timestamp=timezone.now()
    )
