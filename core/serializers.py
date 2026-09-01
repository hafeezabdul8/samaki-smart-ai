from rest_framework import serializers
from .models import User, MarketPrice, FishSpecies, HotelOrder, AuditLog, ChatMessage, OrderMedia, ChatRoom, FishProduct


class RegisterSerializer(serializers.ModelSerializer):
    password = serializers.CharField(write_only=True, min_length=6)
    location = serializers.CharField(required=False, allow_blank=True)
    market = serializers.CharField(required=False, allow_blank=True)
    hotel_name = serializers.CharField(required=False, allow_blank=True)
    security_question = serializers.CharField(required=False, allow_blank=True)
    security_answer = serializers.CharField(required=False, allow_blank=True)

    class Meta:
        model = User
        fields = ('username', 'phone', 'password', 'role', 'location', 'market', 'hotel_name',
                  'security_question', 'security_answer')

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
            security_question=validated_data.get('security_question', ''),
            security_answer=validated_data.get('security_answer', ''),
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



class ChatMessageSerializer(serializers.ModelSerializer):
    sender_name = serializers.CharField(source='sender.username', read_only=True)
    sender_role = serializers.CharField(source='sender.role', read_only=True)

    class Meta:
        model = ChatMessage
        fields = ('id', 'sender', 'sender_name', 'sender_role', 'message', 'created_at')
        read_only_fields = ('sender',)


class OrderMediaSerializer(serializers.ModelSerializer):
    uploader_name = serializers.CharField(source='uploader.username', read_only=True)

    class Meta:
        model = OrderMedia
        fields = ('id', 'uploader', 'uploader_name', 'media_type', 'file_url', 'created_at')
        read_only_fields = ('uploader',)


class ChatRoomSerializer(serializers.ModelSerializer):
    messages = ChatMessageSerializer(many=True, read_only=True)
    media = OrderMediaSerializer(many=True, read_only=True)
    order_id = serializers.IntegerField(source='order.id', read_only=True)
    buyer_name = serializers.CharField(source='order.buyer.username', read_only=True)
    fisherman_name = serializers.CharField(source='order.accepted_by.username', read_only=True)

    class Meta:
        model = ChatRoom
        fields = ('id', 'order_id', 'buyer_name', 'fisherman_name', 'messages', 'media', 'created_at')



class FishProductSerializer(serializers.ModelSerializer):
    fisherman_name = serializers.CharField(source='fisherman.username', read_only=True)
    fisherman_phone = serializers.CharField(source='fisherman.phone', read_only=True)
    fisherman_market = serializers.CharField(source='fisherman.market', read_only=True)
    species_name = serializers.CharField(source='species.name_en', read_only=True)
    species_name_sw = serializers.CharField(source='species.name_sw', read_only=True)

    class Meta:
        model = FishProduct
        fields = ('id', 'fisherman', 'fisherman_name', 'fisherman_phone', 'fisherman_market',
                  'species', 'species_name', 'species_name_sw', 'photo_url',
                  'price_per_kg', 'ai_suggested_price', 'quantity_kg', 'market',
                  'description', 'status', 'created_at', 'expires_at')
        read_only_fields = ('fisherman', 'ai_suggested_price')


class FishProductCreateSerializer(serializers.ModelSerializer):
    class Meta:
        model = FishProduct
        fields = ('species', 'photo_url', 'price_per_kg', 'quantity_kg', 'market', 'description', 'expires_at')