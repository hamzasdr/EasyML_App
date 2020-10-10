from django.contrib.auth import get_user_model
from django.db.migrations import serializer
from django.http import JsonResponse
from rest_framework import viewsets, status
from rest_framework.response import Response
from rest_framework.views import APIView

from airship import push_notification
from .serializers import UserInfoSerializer, UserTokenSerializer, UserDataSerializer, ModelTrainNotificationSerializer, \
    UserModelSerializer
from rest_framework import permissions
from .permissions import IsPrivileged
from rest_framework.authtoken.models import Token
from myapi.models import Data, Model, Device

User = get_user_model()


class UserInfoList(viewsets.ReadOnlyModelViewSet):
    queryset = User.objects.all()
    serializer_class = UserInfoSerializer
    permission_classes = [permissions.IsAuthenticated, IsPrivileged]


class UserTokenList(viewsets.ReadOnlyModelViewSet):
    queryset = Token.objects.all()
    serializer_class = UserTokenSerializer
    permission_classes = [permissions.IsAuthenticated, IsPrivileged]


class UserDataList(viewsets.ModelViewSet):
    queryset = Data.objects.all()
    serializer_class = UserDataSerializer
    permission_classes = [permissions.IsAuthenticated, IsPrivileged]


class UserModelList(viewsets.ModelViewSet):
    queryset = Model.objects.all()
    serializer_class = UserModelSerializer
    permission_classes = [permissions.IsAuthenticated, IsPrivileged]


class ModelTrainNotificationView(APIView):
    permission_classes = [permissions.IsAuthenticated, IsPrivileged]

    def post(self, request, model_pk, format=None):
        try:
            model = Model.objects.get(pk=model_pk)
            serializer = ModelTrainNotificationSerializer(data=request.data)
            message = ''
            if serializer.is_valid():
                if serializer.validated_data['status'] == 'done':
                    model.being_trained = False
                    model.save()
                    message = f"{model.name} has finished training!"
                elif serializer.validated_data['status'] == 'fail':
                    model.being_trained = False
                    model.save()
                    message = f"{model.name} has failed at training ☹"
                else:
                    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

            extra = serializer.validated_data.get('extra', {})
            extra['id'] = model_pk
            extra['owner'] = model.owner.id
            extra['status'] = serializer.validated_data['status']
            devices = list(Device.objects.filter(owner=model.owner, logged_in=True))
            print({'message': message, 'extra': extra})
            push_notification(devices=devices, title="EasyML", message=message, extra=extra)
            # TODO: Handle push notification response appropriately
            return JsonResponse({"detail": "Done."}, status=status.HTTP_200_OK)

        except Model.DoesNotExist:  # Model.objects.get(pk=...) couldn't find a model
            return JsonResponse({'detail': 'Model not found.'},
                                status=status.HTTP_404_NOT_FOUND)

