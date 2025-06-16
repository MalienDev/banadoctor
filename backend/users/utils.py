import logging
from django.conf import settings
from django.core.mail import send_mail
from django.template.loader import render_to_string
from django.utils.html import strip_tags

logger = logging.getLogger(__name__)

class Util:
    """Utility class for common operations"""
    
    @staticmethod
    def send_email(data):
        """
        Send an email using Django's send_mail function.
        
        Args:
            data (dict): Dictionary containing email details with keys:
                - 'email_subject': Subject of the email
                - 'email_body': Body content as HTML
                - 'to_email': List of recipient email addresses
                - 'from_email': (Optional) Sender email address
                - 'fail_silently': (Optional) Whether to fail silently
        """
        try:
            email_subject = data.get('email_subject', '')
            email_body = data.get('email_body', '')
            to_email = data.get('to_email')
            from_email = data.get('from_email', settings.DEFAULT_FROM_EMAIL)
            fail_silently = data.get('fail_silently', False)
            
            if not all([email_subject, email_body, to_email]):
                logger.error("Missing required email parameters")
                return False
                
            # Convert HTML to plain text for email clients that don't support HTML
            text_content = strip_tags(email_body)
            
            send_mail(
                subject=email_subject,
                message=text_content,
                from_email=from_email,
                recipient_list=to_email,
                html_message=email_body,
                fail_silently=fail_silently
            )
            return True
            
        except Exception as e:
            logger.error(f"Error sending email: {str(e)}")
            if not fail_silently:
                raise
            return False
    
    @staticmethod
    def send_template_email(template_name, context, subject, to_email, **kwargs):
        """
        Send an email using a template.
        
        Args:
            template_name (str): Path to the email template
            context (dict): Context variables for the template
            subject (str): Email subject
            to_email (str or list): Recipient email address(es)
            **kwargs: Additional arguments for send_mail
                      (from_email, fail_silently, etc.)
        """
        try:
            # Render HTML content from template
            html_message = render_to_string(template_name, context)
            
            # Convert HTML to plain text
            text_content = strip_tags(html_message)
            
            # Get or set default values
            from_email = kwargs.get('from_email', settings.DEFAULT_FROM_EMAIL)
            fail_silently = kwargs.get('fail_silently', False)
            
            # Ensure to_email is a list
            if isinstance(to_email, str):
                to_email = [to_email]
            
            # Send email
            send_mail(
                subject=subject,
                message=text_content,
                from_email=from_email,
                recipient_list=to_email,
                html_message=html_message,
                fail_silently=fail_silently
            )
            return True
            
        except Exception as e:
            logger.error(f"Error sending template email: {str(e)}")
            if not kwargs.get('fail_silently', False):
                raise
            return False
    
    @staticmethod
    def send_verification_email(user, request=None):
        """
        Send an email verification link to the user.
        
        Args:
            user: User instance
            request: HttpRequest object (optional, for building absolute URLs)
        """
        from django.contrib.sites.shortcuts import get_current_site
        from django.urls import reverse
        from django.utils.encoding import force_bytes
        from django.utils.http import urlsafe_base64_encode
        from django.contrib.auth.tokens import default_token_generator
        
        try:
            # Generate token for email verification
            token = default_token_generator.make_token(user)
            uid = urlsafe_base64_encode(force_bytes(user.pk))
            
            # Get current site domain
            if request:
                current_site = getattr(request, 'get_host', None) and request.get_host() or get_current_site(request).domain
            else:
                current_site = get_current_site(None).domain
            
            # Build verification URL
            relative_link = reverse('verify-email', kwargs={'uidb64': uid, 'token': token})
            verification_url = f"http://{current_site}{relative_link}"
            
            # Prepare email context
            email_context = {
                'user': user,
                'verification_url': verification_url,
                'site_name': current_site,
            }
            
            # Send email using template
            subject = 'Verify your email address'
            to_email = user.email
            
            return Util.send_template_email(
                'emails/verify_email.html',
                email_context,
                subject,
                to_email
            )
            
        except Exception as e:
            logger.error(f"Error sending verification email: {str(e)}")
            return False
