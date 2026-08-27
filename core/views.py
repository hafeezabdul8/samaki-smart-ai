from rest_framework import generics, permissions, status
from rest_framework.response import Response
from .serializers import RegisterSerializer, MarketPriceSerializer, HotelOrderSerializer, HotelOrderCreateSerializer, \
    FishSpeciesDetailSerializer, AdminAuditLogSerializer, AdminUserSerializer
from .models import User, MarketPrice, HotelOrder, FishSpecies, AuditLog
from rest_framework.views import APIView
from .ml.predict import predict_price, get_smart_recommendations, get_season
from .ml.forecast import forecast_7_days
from datetime import date, timedelta
from django.utils import timezone
from django.db.models import Count, Sum, Q
from .models import DeviceToken




class RegisterView(generics.CreateAPIView):
    queryset = User.objects.all()
    permission_classes = [permissions.AllowAny]
    serializer_class = RegisterSerializer

    def perform_create(self, serializer):
        user = serializer.save()
        AuditLog.objects.create(
            user=user,
            action='REGISTER',
            table_name='User',
            record_id=user.id
        )

class PriceFeedView(generics.ListAPIView):
    queryset = MarketPrice.objects.select_related('species').order_by('-recorded_at')[:50]
    permission_classes = [permissions.AllowAny]
    serializer_class = MarketPriceSerializer

class HotelOrderListCreateView(generics.ListCreateAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        user = self.request.user
        if user.role == 'hotel_buyer':
            return HotelOrder.objects.filter(buyer=user).order_by('-created_at')
        return HotelOrder.objects.select_related('buyer', 'species').all().order_by('-created_at')

    def get_serializer_class(self):
        if self.request.method == 'POST':
            return HotelOrderCreateSerializer
        return HotelOrderSerializer

    def perform_create(self, serializer):
        order = serializer.save(buyer=self.request.user)

        # Send push to all fishermen
        from .fcm_utils import send_push_notification

        fishermen_tokens = DeviceToken.objects.filter(
            user__role='fisherman'
        ).values_list('fcm_token', flat=True)

        send_push_notification(
            list(fishermen_tokens),
            title='New Fish Order! 🐟',
            body=f'{order.species.name_en} • {order.quantity_kg}kg • Delivery: {order.delivery_date}',
            data={'order_id': str(order.id), 'type': 'new_order'}
        )

        # Log
        AuditLog.objects.create(
            user=self.request.user,
            action='CREATE_ORDER',
            table_name='HotelOrder',
            record_id=order.id
        )

class PredictPriceView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        species = request.data.get('species')
        market = request.data.get('market')
        season = request.data.get('season')
        weather = request.data.get('weather')
        quantity_kg = float(request.data.get('quantity_kg', 10))

        if not all([species, market, season, weather]):
            return Response({'error': 'species, market, season, and weather are required'},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            predicted = predict_price(species, market, season, weather, quantity_kg)
            return Response({
                'species': species,
                'market': market,
                'season': season,
                'weather': weather,
                'quantity_kg': quantity_kg,
                'predicted_price_tzs': predicted
            })
        except ValueError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)

class ConservationAlertView(generics.ListAPIView):
    queryset = FishSpecies.objects.all().order_by('status', 'name_en')
    permission_classes = [permissions.AllowAny]
    serializer_class = FishSpeciesDetailSerializer


class OrderStatusUpdateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request, pk):
        try:
            order = HotelOrder.objects.get(pk=pk)
        except HotelOrder.DoesNotExist:
            return Response({'error': 'Order not found'}, status=status.HTTP_404_NOT_FOUND)

        new_status = request.data.get('status')

        if new_status not in ['accepted', 'fulfilled', 'cancelled']:
            return Response({'error': 'Invalid status. Use: accepted, fulfilled, cancelled'},
                            status=status.HTTP_400_BAD_REQUEST)

        if new_status == 'cancelled' and request.user != order.buyer:
            return Response({'error': 'Only the buyer can cancel this order'},
                            status=status.HTTP_403_FORBIDDEN)

        if order.status in ['fulfilled', 'cancelled']:
            return Response({'error': f'Order is already {order.status}'},
                            status=status.HTTP_400_BAD_REQUEST)

        # Record who accepted
        if new_status == 'accepted':
            order.accepted_by = request.user

        order.status = new_status
        order.save()

        AuditLog.objects.create(
            user=request.user,
            action=f'ORDER_{new_status.upper()}',
            table_name='HotelOrder',
            record_id=order.id
        )

        return Response(HotelOrderSerializer(order).data)

class DemandForecastView(APIView):
    permission_classes = [permissions.AllowAny]

    def post(self, request):
        species = request.data.get('species')
        market = request.data.get('market')
        avg_quantity = float(request.data.get('avg_quantity', 15))

        if not species or not market:
            return Response({'error': 'species and market are required'},
                            status=status.HTTP_400_BAD_REQUEST)

        try:
            forecasts = forecast_7_days(species, market, avg_quantity)
            return Response(forecasts)
        except ValueError as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class UserProfileView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        return Response({
            'id': request.user.id,
            'username': request.user.username,
            'role': request.user.role,
            'phone': request.user.phone,
        })


class AdminOrderListView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]
    serializer_class = HotelOrderSerializer

    def get_queryset(self):
        if self.request.user.role != 'admin':
            return HotelOrder.objects.none()
        return HotelOrder.objects.select_related('buyer', 'species').all().order_by('-created_at')


class ProfileUpdateView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def patch(self, request):
        user = request.user
        user.phone = request.data.get('phone', user.phone)
        user.location = request.data.get('location', user.location)
        user.market = request.data.get('market', user.market)
        user.hotel_name = request.data.get('hotel_name', user.hotel_name)
        user.save()

        AuditLog.objects.create(
            user=request.user,
            action='UPDATE_PROFILE',
            table_name='User',
            record_id=user.id
        )

        return Response({
            'id': user.id,
            'username': user.username,
            'phone': user.phone,
            'role': user.role,
            'location': user.location,
            'market': user.market,
            'hotel_name': user.hotel_name,
        })


class SmartRecommendationsView(APIView):
    permission_classes = [permissions.AllowAny]

    def get(self, request):
        try:
            recommendations = get_smart_recommendations()
            return Response({
                'current_season': get_season(date.today().month),
                'recommendations': recommendations,
                'ai_insight': 'Prices typically rise in Kusi due to reduced fishing activity from rough seas. Consider targeting high-value species during this period.'
            })
        except Exception as e:
            return Response({'error': str(e)}, status=400)

## ADMIN


class AdminDashboardView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request):
        if request.user.role != 'admin':
            return Response({'error': 'Unauthorized'}, status=403)

        total_users = User.objects.count()
        total_fishermen = User.objects.filter(role='fisherman').count()
        total_buyers = User.objects.filter(role='hotel_buyer').count()
        total_orders = HotelOrder.objects.count()
        pending_orders = HotelOrder.objects.filter(status='pending').count()
        active_sessions = User.objects.filter(last_login_ip__isnull=False).count()

        return Response({
            'total_users': total_users,
            'total_fishermen': total_fishermen,
            'total_buyers': total_buyers,
            'total_orders': total_orders,
            'pending_orders': pending_orders,
            'active_sessions': active_sessions,
            'ai_accuracy_price': 68.4,
            'ai_accuracy_demand': 89.9,
        })


class AdminUserListView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.role != 'admin':
            return User.objects.none()
        return User.objects.all().order_by('-date_joined')

    def get_serializer_class(self):
        return AdminUserSerializer


class AdminUserDetailView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def get(self, request, pk):
        if request.user.role != 'admin':
            return Response({'error': 'Unauthorized'}, status=403)
        try:
            user = User.objects.get(pk=pk)
            orders = HotelOrder.objects.filter(Q(buyer=user) | Q(accepted_by=user)).count()
            audit_logs = AuditLog.objects.filter(user=user).order_by('-timestamp')[:10]
            return Response({
                'id': user.id,
                'username': user.username,
                'phone': user.phone,
                'role': user.role,
                'location': user.location,
                'market': user.market,
                'hotel_name': user.hotel_name,
                'is_active': user.is_active,
                'last_login_ip': user.last_login_ip,
                'last_login_device': user.last_login_device,
                'failed_login_attempts': user.failed_login_attempts,
                'date_joined': user.date_joined,
                'total_orders': orders,
                'recent_activity': [{'action': log.action, 'table': log.table_name, 'time': log.timestamp} for log in
                                    audit_logs]
            })
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=404)


class AdminResetPasswordView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        if request.user.role != 'admin':
            return Response({'error': 'Unauthorized'}, status=403)
        try:
            user = User.objects.get(pk=pk)
            new_password = User.objects.make_random_password()
            user.set_password(new_password)
            user.password_changed_at = timezone.now()
            user.save()
            return Response({'message': 'Password reset', 'new_password': new_password})
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=404)


class AdminToggleUserStatusView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request, pk):
        if request.user.role != 'admin':
            return Response({'error': 'Unauthorized'}, status=403)
        try:
            user = User.objects.get(pk=pk)
            user.is_active = not user.is_active
            user.locked_until = None if user.is_active else timezone.now() + timedelta(days=30)
            user.save()
            return Response(
                {'message': f'User {"activated" if user.is_active else "locked"}', 'is_active': user.is_active})
        except User.DoesNotExist:
            return Response({'error': 'User not found'}, status=404)


class AdminAuditLogView(generics.ListAPIView):
    permission_classes = [permissions.IsAuthenticated]

    def get_queryset(self):
        if self.request.user.role != 'admin':
            return AuditLog.objects.none()
        return AuditLog.objects.select_related('user').all().order_by('-timestamp')[:200]

    def get_serializer_class(self):
        return AdminAuditLogSerializer


class DeviceTokenView(APIView):
    permission_classes = [permissions.IsAuthenticated]

    def post(self, request):
        token = request.data.get('fcm_token')
        if not token:
            return Response({'error': 'fcm_token required'}, status=400)

        DeviceToken.objects.update_or_create(
            user=request.user,
            fcm_token=token,
            defaults={'fcm_token': token}
        )
        return Response({'message': 'Token registered'})
