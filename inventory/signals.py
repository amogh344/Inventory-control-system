
# inventory/signals.py

from django.db.models.signals import post_save
from django.dispatch import receiver
from django.core.mail import send_mail
from django.conf import settings
from .models import Product, User

@receiver(post_save, sender=Product)
def product_change_notifier(sender, instance, created, **kwargs):
    """
    Listens for changes to a Product instance and sends notifications for:
    1. A new product being created.
    2. An existing product's stock falling to or below the minimum level.
    """
    
    # First, find all Admin and Manager users to notify
    recipients = User.objects.filter(
        role__in=[User.Role.ADMIN, User.Role.MANAGER]
    )
    recipient_emails = [user.email for user in recipients if user.email]

    # If there's no one to notify, do nothing.
    if not recipient_emails:
        return

    # --- Case 1: A new product was created ---
    if created:
        subject = f"New Product Added: {instance.name}"
        message = (
            f"A new product has been added to the inventory by a user:\n\n"
            f"Product Name: {instance.name}\n"
            f"SKU: {instance.sku}\n"
            f"Category: {instance.category}\n"
            f"Unit Price: ${instance.unit_price}\n"
            f"Initial Stock: {instance.stock_quantity}\n"
        )
        send_mail(
            subject,
            message,
            settings.EMAIL_HOST_USER,
            recipient_emails,
            fail_silently=False
        )
        print(f"New product notification sent for '{instance.name}'")

    # --- Case 2: An existing product's stock is now low ---
    # The 'not created' check prevents sending two emails if a product is created already low on stock.
    elif not created and instance.stock_quantity <= instance.min_stock_level:
        subject = f"Low Stock Alert: {instance.name}"
        
        # Add a helpful supplier suggestion to the email
        supplier_suggestion = "No preferred supplier is set for this item."
        if instance.preferred_supplier:
            supplier_suggestion = (
                f"Consider creating a purchase order from the preferred supplier:\n"
                f"Supplier Name: {instance.preferred_supplier.name}\n"
                f"Supplier Email: {instance.preferred_supplier.email}"
            )

        message = (
            f"The stock for product '{instance.name}' (SKU: {instance.sku}) is running low.\n\n"
            f"Current Stock: {instance.stock_quantity}\n"
            f"Minimum Stock Level: {instance.min_stock_level}\n\n"
            f"{supplier_suggestion}"
        )
        
        send_mail(
            subject,
            message,
            settings.EMAIL_HOST_USER,
            recipient_emails,
            fail_silently=False
        )
        print(f"Low stock alert email sent for '{instance.name}'")