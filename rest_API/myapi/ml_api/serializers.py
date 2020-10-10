from collections import OrderedDict

from django.contrib.auth import get_user_model
from rest_framework.fields import SkipField
from rest_framework import serializers
from rest_framework.authtoken.models import Token
from myapi.models import Data, Model

User = get_user_model()


class UserInfoSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ('username', 'id')


class UserTokenSerializer(serializers.ModelSerializer):
    class Meta:
        model = Token
        fields = ('key', 'user_id')


class UserDataSerializer(serializers.ModelSerializer):
    class Meta:
        model = Data
        fields = '__all__'

class UserModelSerializer(serializers.ModelSerializer):
    class Meta:
        model = Model
        fields = '__all__'


class ModelTrainNotificationSerializer(serializers.Serializer):
    status = serializers.CharField(required=True)
    extra = serializers.JSONField(required=False)

    def create(self, validated_data):
        pass

    def update(self, instance, validated_data):
        pass



