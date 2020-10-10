from django.urls import path, include
from . import views

from rest_framework import routers

router = routers.DefaultRouter()
router.register('user-info', views.UserInfoList, 'user-info')
router.register('user-token', views.UserTokenList, 'user-token')
router.register('user-data', views.UserDataList, 'user-data')
router.register('user-model', views.UserModelList, 'user-model')

urlpatterns = [
     path('', include(router.urls), name='ml_post_list'),
     path('notify/<int:model_pk>/', views.ModelTrainNotificationView.as_view())
]

