from django.contrib import admin
from .models import User, FishSpecies, MarketPrice, HotelOrder, AIPrediction, DeviceToken, AuditLog

@admin.register(User)
class UserAdmin(admin.ModelAdmin):
    list_display = ('username', 'phone', 'role', 'is_active')

@admin.register(FishSpecies)
class FishSpeciesAdmin(admin.ModelAdmin):
    list_display = ('name_en', 'name_sw', 'status')

@admin.register(MarketPrice)
class MarketPriceAdmin(admin.ModelAdmin):
    list_display = ('species', 'price_tzs', 'tag', 'recorded_at')

@admin.register(HotelOrder)
class HotelOrderAdmin(admin.ModelAdmin):
    list_display = ('buyer', 'species', 'quantity_kg', 'delivery_date', 'status')

@admin.register(AIPrediction)
class AIPredictionAdmin(admin.ModelAdmin):
    list_display = ('species', 'predicted_price_tzs', 'confidence', 'forecast_date')

@admin.register(DeviceToken)
class DeviceTokenAdmin(admin.ModelAdmin):
    list_display = ('user', 'fcm_token', 'created_at')

@admin.register(AuditLog)
class AuditLogAdmin(admin.ModelAdmin):
    list_display = ('user', 'action', 'table_name', 'timestamp')