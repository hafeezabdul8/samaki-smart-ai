from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import (RegisterView, PriceFeedView, HotelOrderListCreateView, PredictPriceView, ConservationAlertView,
                    OrderStatusUpdateView, DemandForecastView, UserProfileView, AdminOrderListView,
                    ProfileUpdateView, SmartRecommendationsView, AdminDashboardView, AdminUserListView,
                    AdminUserDetailView, AdminResetPasswordView, AdminToggleUserStatusView, AdminAuditLogView)



urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='login'),
    path('profile/', UserProfileView.as_view(), name='profile'),
    path('profile/update/', ProfileUpdateView.as_view(), name='profile_update'),
    path('admin/orders/', AdminOrderListView.as_view(), name='admin_orders'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('prices/', PriceFeedView.as_view(), name='price_feed'),
    path('orders/', HotelOrderListCreateView.as_view(), name='orders'),
    path('orders/<int:pk>/status/', OrderStatusUpdateView.as_view(), name='order_status_update'),
    path('predict/', PredictPriceView.as_view(), name='predict_price'),
    path('alerts/', ConservationAlertView.as_view(), name='conservation_alerts'),
    path('forecast/', DemandForecastView.as_view(), name='demand_forecast'),
    path('smart/', SmartRecommendationsView.as_view(), name='smart_recommendations'),


    path('admin/dashboard/', AdminDashboardView.as_view(), name='admin_dashboard'),
    path('admin/users/', AdminUserListView.as_view(), name='admin_users'),
    path('admin/users/<int:pk>/', AdminUserDetailView.as_view(), name='admin_user_detail'),
    path('admin/users/<int:pk>/reset-password/', AdminResetPasswordView.as_view(), name='admin_reset_password'),
    path('admin/users/<int:pk>/toggle-status/', AdminToggleUserStatusView.as_view(), name='admin_toggle_status'),
    path('admin/audit-logs/', AdminAuditLogView.as_view(), name='admin_audit_logs'),

]
