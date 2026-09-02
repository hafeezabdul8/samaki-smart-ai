from django.urls import path
from rest_framework_simplejwt.views import TokenObtainPairView, TokenRefreshView
from .views import (RegisterView, PriceFeedView, HotelOrderListCreateView, PredictPriceView, ConservationAlertView,
                    OrderStatusUpdateView, DemandForecastView, UserProfileView, AdminOrderListView,
                    ProfileUpdateView, SmartRecommendationsView, AdminDashboardView, AdminUserListView,
                    AdminUserDetailView, AdminResetPasswordView, AdminToggleUserStatusView, AdminAuditLogView,
                    DeviceTokenView, ChatRoomView, ChatMessagesView, SendMessageView, UploadMediaView,
                    FishProductListView, FishProductCreateView, FishProductDetailView, FishProductMineView,
                    OrderFromProductView, UploadProductPhotoView, AdminReportsView, ForgotPasswordView,
                    ResetPasswordWithSecurityView, OrderHistoryView, FishProductUpdateDeleteView)



urlpatterns = [
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', TokenObtainPairView.as_view(), name='login'),
    path('profile/', UserProfileView.as_view(), name='profile'),
    path('profile/update/', ProfileUpdateView.as_view(), name='profile_update'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token_refresh'),
    path('prices/', PriceFeedView.as_view(), name='price_feed'),
    path('orders/', HotelOrderListCreateView.as_view(), name='orders'),
    path('orders/<int:pk>/status/', OrderStatusUpdateView.as_view(), name='order_status_update'),
    path('predict/', PredictPriceView.as_view(), name='predict_price'),
    path('alerts/', ConservationAlertView.as_view(), name='conservation_alerts'),
    path('forecast/', DemandForecastView.as_view(), name='demand_forecast'),
    path('smart/', SmartRecommendationsView.as_view(), name='smart_recommendations'),
    path('device-token/', DeviceTokenView.as_view(), name='device_token'),
    path('chat/orders/<int:order_id>/room/', ChatRoomView.as_view(), name='chat_room'),
    path('chat/orders/<int:order_id>/messages/', ChatMessagesView.as_view(), name='chat_messages'),
    path('chat/orders/<int:order_id>/send/', SendMessageView.as_view(), name='send_message'),
    path('chat/orders/<int:order_id>/media/', UploadMediaView.as_view(), name='upload_media'),
    path('orders/history/', OrderHistoryView.as_view(), name='order_history'),
    path('products/<int:product_id>/update/', FishProductUpdateDeleteView.as_view(), name='product_update_delete'),
    path('products/', FishProductListView.as_view(), name='product_list'),
    path('products/create/', FishProductCreateView.as_view(), name='product_create'),
    path('products/my/', FishProductMineView.as_view(), name='product_mine'),
    path('products/<int:product_id>/', FishProductDetailView.as_view(), name='product_detail'),
    path('products/<int:product_id>/order/', OrderFromProductView.as_view(), name='order_from_product'),
    path('products/upload-photo/', UploadProductPhotoView.as_view(), name='upload_product_photo'),
    path('forgot-password/', ForgotPasswordView.as_view(), name='forgot_password'),
    path('reset-password/', ResetPasswordWithSecurityView.as_view(), name='reset_password'),



    path('admin/dashboard/', AdminDashboardView.as_view(), name='admin_dashboard'),
    path('admin/users/', AdminUserListView.as_view(), name='admin_users'),
    path('admin/orders/', AdminOrderListView.as_view(), name='admin_orders'),
    path('admin/users/<int:pk>/', AdminUserDetailView.as_view(), name='admin_user_detail'),
    path('admin/users/<int:pk>/reset-password/', AdminResetPasswordView.as_view(), name='admin_reset_password'),
    path('admin/users/<int:pk>/toggle-status/', AdminToggleUserStatusView.as_view(), name='admin_toggle_status'),
    path('admin/audit-logs/', AdminAuditLogView.as_view(), name='admin_audit_logs'),
    path('admin/reports/', AdminReportsView.as_view(), name='admin_reports'),

]
