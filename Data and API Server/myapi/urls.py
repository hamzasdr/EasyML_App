from django.urls import path , include
from rest_framework.authtoken.views import obtain_auth_token

from . import views

from rest_framework import routers

router = routers.DefaultRouter()
router.register('user', views.UserList, 'user')
# router.register('models', views.ModelList, 'model')
# router.register('neuralmodels', views.NeuralModelList, 'neuralmodel')
# router.register('layers', views.LayerList, 'layer')
# router.register('dense', views.DenseLayerList, 'dense')
# router.register('conv', views.ConvLayerList, 'conv')
router.register('data', views.DataList, 'data')
router.register('device', views.DeviceList, 'device')
# router.register('register', views.UserRegistrationList, 'register')


urlpatterns = [
     path('', include(router.urls), name='post_list'),
     path('ml/', include('myapi.ml_api.urls')),
     path('login/', obtain_auth_token, name='api_token_auth'),
     path('register/', views.UserRegistrationView.as_view(), name='register'),
     path('models/', views.ModelList.as_view(), name='model-list'),
     path('models/<int:pk>/', views.ModelDetail.as_view(), name='model-detail'),
     path('models/info/<int:data_pk>/', views.ModelInfoView.as_view(), name='model-info'),
     path('models/<int:model_pk>/layers/', views.LayerList.as_view(), name='layer-list'),
     path('models/<int:model_pk>/layers/<int:pk>/', views.LayerDetail.as_view(), name='layer-detail'),
     path('train/<int:model_pk>/', views.ModelTrainView.as_view(), name='train'),
     path('data/info/<int:data_pk>/', views.DataInfoLView.as_view(), name='data-info'),
     path('device/byid/<str:channel_id>/', views.DeviceByChannelIdView.as_view(), name='device-channel-id'),
     path('avatar/', views.UserAvatarUploadView.as_view(), name='avatar-upload')
]

