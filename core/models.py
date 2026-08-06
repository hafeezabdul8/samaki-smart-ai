from django.db import models
from django.contrib.auth.models import AbstractUser


class User(AbstractUser):
    ROLE_CHOICES = [
        ('fisherman', 'Fisherman'),
        ('hotel_buyer', 'Hotel Buyer'),
        ('admin', 'Admin'),
    ]
    phone = models.CharField(max_length=15, blank=True, null=True)
    role = models.CharField(max_length=20, choices=ROLE_CHOICES, default='fisherman')
    location = models.CharField(max_length=100, blank=True, null=True)
    market = models.CharField(max_length=100, blank=True, null=True)
    hotel_name = models.CharField(max_length=200, blank=True, null=True)
    is_active = models.BooleanField(default=True)

    password_changed_at = models.DateTimeField(null=True, blank=True)
    failed_login_attempts = models.IntegerField(default=0)
    locked_until = models.DateTimeField(null=True, blank=True)
    last_login_ip = models.CharField(max_length=45, blank=True, null=True)
    last_login_device = models.CharField(max_length=200, blank=True, null=True)
    hotel_name = models.CharField(max_length=200, blank=True, null=True)
    location = models.CharField(max_length=100, blank=True, null=True)
    market = models.CharField(max_length=100, blank=True, null=True)

    def __str__(self):
        return f"{self.username} ({self.role})"


class FishSpecies(models.Model):
    STATUS_CHOICES = [
        ('green', 'Green'),
        ('amber', 'Amber'),
        ('red', 'Red'),
    ]
    name_en = models.CharField(max_length=100)
    name_sw = models.CharField(max_length=100)
    scientific_name = models.CharField(max_length=150, blank=True, null=True)
    status = models.CharField(max_length=10, choices=STATUS_CHOICES, default='green')
    note = models.TextField(blank=True, null=True)

    class Meta:
        verbose_name_plural = "Fish Species"

    def __str__(self):
        return f"{self.name_en} ({self.name_sw})"


class MarketPrice(models.Model):
    TAG_CHOICES = [
        ('High Demand', 'High Demand'),
        ('Fair Price', 'Fair Price'),
        ('Low Demand', 'Low Demand'),
    ]
    species = models.ForeignKey(FishSpecies, on_delete=models.CASCADE, related_name='prices')
    price_tzs = models.DecimalField(max_digits=10, decimal_places=2)
    tag = models.CharField(max_length=20, choices=TAG_CHOICES, default='Fair Price')
    recorded_at = models.DateTimeField(auto_now_add=True)
    created_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)

    class Meta:
        ordering = ['-recorded_at']

    def __str__(self):
        return f"{self.species.name_en} - TZS {self.price_tzs} ({self.tag})"


class HotelOrder(models.Model):
    STATUS_CHOICES = [
        ('pending', 'Pending'),
        ('accepted', 'Accepted'),
        ('fulfilled', 'Fulfilled'),
        ('cancelled', 'Cancelled'),
    ]
    buyer = models.ForeignKey(User, on_delete=models.CASCADE, related_name='orders')
    species = models.ForeignKey(FishSpecies, on_delete=models.CASCADE, related_name='orders')
    quantity_kg = models.DecimalField(max_digits=8, decimal_places=2)
    delivery_date = models.DateField()
    max_price_tzs = models.DecimalField(max_digits=10, decimal_places=2, blank=True, null=True)
    status = models.CharField(max_length=15, choices=STATUS_CHOICES, default='pending')
    accepted_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, related_name='accepted_orders')
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f"Order #{self.id} - {self.buyer.username} - {self.species.name_en}"

class AIPrediction(models.Model):
    species = models.ForeignKey(FishSpecies, on_delete=models.CASCADE, related_name='predictions')
    predicted_price_tzs = models.DecimalField(max_digits=10, decimal_places=2)
    confidence = models.FloatField(default=0.0)
    forecast_date = models.DateField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-forecast_date']

    def __str__(self):
        return f"Prediction: {self.species.name_en} @ TZS {self.predicted_price_tzs} on {self.forecast_date}"


class DeviceToken(models.Model):
    user = models.ForeignKey(User, on_delete=models.CASCADE, related_name='device_tokens')
    fcm_token = models.CharField(max_length=500)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return f"{self.user.username} - {self.fcm_token[:30]}..."


class AuditLog(models.Model):
    user = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True)
    action = models.CharField(max_length=50)
    table_name = models.CharField(max_length=50)
    record_id = models.IntegerField(blank=True, null=True)
    timestamp = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"{self.user} - {self.action} on {self.table_name} at {self.timestamp}"