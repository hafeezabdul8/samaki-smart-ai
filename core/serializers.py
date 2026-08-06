from rest_framework import serializers
from .models import User, MarketPrice, FishSpecies, HotelOrder, AuditLog


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    location = serializers.CharField(required=False, allow_blank=True)
    market = serializers.CharField(required=False, allow_blank=True)
    hotel_name = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ('username', 'phone', 'password', 'role', 'location', 'market', 'hotel_name')

    def create(self, validated_data):
        location = validated_data.pop('location', '')
        market = validated_data.pop('market', '')
        hotel_name = validated_data.pop('hotel_name', '')
        user = User.objects.create_user(
            username=validated_data['username'],
            phone=validated_data.get('phone', ''),
            password=validated_data['password'],
            role=validated_data.get('role', 'fisherman'),
            location=location,
            market=market,
            hotel_name=hotel_name,
        )
        return user

class FishSpeciesSerializer(serializers.ModelSerializer):
    class Meta:
        model = FishSpecies
        fields = ('id', 'name_en', 'name_sw', 'status', 'note')

class MarketPriceSerializer(serializers.ModelSerializer):
    species = FishSpeciesSerializer(read_only=True)

    class Meta:
        model = MarketPrice
        fields = ('id', 'species', 'price_tzs', 'tag', 'recorded_at')

class HotelOrderSerializer(serializers.ModelSerializer):
    species_name = serializers.CharField(source='species.name_en', read_only=True)
    buyer_name = serializers.CharField(source='buyer.username', read_only=True)
    buyer_phone = serializers.CharField(source='buyer.phone', read_only=True)
    buyer_hotel = serializers.CharField(source='buyer.hotel_name', read_only=True)
    buyer_location = serializers.CharField(source='buyer.location', read_only=True)
    accepted_by_name = serializers.CharField(source='accepted_by.username', read_only=True)
    accepted_by_phone = serializers.CharField(source='accepted_by.phone', read_only=True)
    accepted_by_market = serializers.CharField(source='accepted_by.market', read_only=True)

    class Meta:
        model = HotelOrder
        fields = ('id', 'buyer_name', 'buyer_phone', 'buyer_hotel', 'buyer_location',
                  'species', 'species_name', 'quantity_kg', 'delivery_date',
                  'max_price_tzs', 'status', 'accepted_by_name', 'accepted_by_phone',
                  'accepted_by_market', 'created_at', 'updated_at')
        read_only_fields = ('status',)


class HotelOrderCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = HotelOrder
        fields = ('species', 'quantity_kg', 'delivery_date', 'max_price_tzs')

    def validate_quantity_kg(self, value):
        if value < 1:
            raise serializers.ValidationError("Minimum 1 kg required")
        return value

class FishSpeciesDetailSerializer(serializers.ModelSerializer):
    class Meta:
        model = FishSpecies
        fields = ('id', 'name_en', 'name_sw', 'scientific_name', 'status', 'note')


class AdminUserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('id', 'username', 'phone', 'role', 'location', 'market',
                  'hotel_name', 'is_active', 'last_login_ip', 'last_login_device',
                  'failed_login_attempts', 'date_joined', 'last_login')


class AdminAuditLogSerializer(serializers.ModelSerializer):
    username = serializers.CharField(source='user.username', read_only=True)

    class Meta:
        model = AuditLog
        fields = ('id', 'username', 'action', 'table_name', 'record_id', 'timestamp')